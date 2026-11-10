import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modern_pos_api_client/api.dart';
import 'package:modern_pos_mobile/core/device_identity.dart';
import 'package:modern_pos_mobile/features/auth/auth_controller.dart';
import 'package:modern_pos_mobile/features/cart/cart_controller.dart';
import 'package:modern_pos_mobile/features/cart/cart_line.dart';
import 'package:modern_pos_mobile/features/checkout/checkout_controller.dart';
import 'package:modern_pos_mobile/features/checkout/checkout_gateway.dart';
import 'package:modern_pos_mobile/features/checkout/checkout_models.dart';
import 'package:modern_pos_mobile/features/checkout/checkout_repository.dart';
import 'package:modern_pos_mobile/features/printing/print_job_mirror.dart';
import 'package:modern_pos_mobile/features/printing/print_job_models.dart';
import 'package:modern_pos_mobile/features/printing/print_queue_repository.dart';
import 'package:modern_pos_mobile/features/printing/printer_controller.dart';
import 'package:modern_pos_mobile/features/printing/receipt_identity.dart';

import 'support/checkout_fakes.dart';
import 'support/fakes.dart';
import 'support/printer_fakes.dart';

CartLine cartLine({int quantity = 1}) {
  return CartLine(
    menuId: 'tea',
    variantId: 'variant-1',
    itemName: 'Tea',
    variantName: 'Default',
    unitPriceMinor: 50000,
    quantity: quantity,
    currency: 'IDR',
    currencyExponent: 0,
  );
}

class Harness {
  Harness({
    FakeCheckoutGateway? gateway,
    InMemoryCheckoutRepository? repository,
    FakeReceiptPrinter? printer,
  }) : gateway = gateway ?? FakeCheckoutGateway(),
       repository = repository ?? InMemoryCheckoutRepository(),
       printer = printer ?? FakeReceiptPrinter(connected: false) {
    printRepository = InMemoryPrintQueueRepository();
    configStore = InMemoryPrinterConfigStore(
      this.printer.connected ? testPrinterConfig() : null,
    );
    container = ProviderContainer(
      overrides: [
        authControllerProvider.overrideWith(
          () => FakeAuthController(testSession(outletId: 'outlet-1')),
        ),
        cartRepositoryProvider.overrideWithValue(cartRepository),
        checkoutRepositoryProvider.overrideWithValue(this.repository),
        checkoutGatewayProvider.overrideWithValue(this.gateway),
        deviceIdentityProvider.overrideWithValue(FixedDeviceIdentity()),
        printerAdapterProvider.overrideWithValue(this.printer),
        printQueueRepositoryProvider.overrideWithValue(printRepository),
        printerConfigStoreProvider.overrideWithValue(configStore),
        receiptIdentityRepositoryProvider.overrideWithValue(
          FakeReceiptIdentityRepository(),
        ),
        printJobMirrorProvider.overrideWithValue(const NoopPrintJobMirror()),
      ],
    );
    addTearDown(container.dispose);
  }

  final FakeCheckoutGateway gateway;
  final InMemoryCheckoutRepository repository;
  final FakeReceiptPrinter printer;
  late final InMemoryPrintQueueRepository printRepository;
  late final InMemoryPrinterConfigStore configStore;
  final InMemoryCartRepository cartRepository = InMemoryCartRepository();
  late final ProviderContainer container;

  CheckoutController get controller =>
      container.read(checkoutControllerProvider.notifier);

  Future<CheckoutState> load() async {
    await container.read(authControllerProvider.future);
    await cartRepository.save(cartLine());
    return container.read(checkoutControllerProvider.future);
  }
}

void main() {
  group('tender and change', () {
    test('cash change and shortfall stay in integer minor units', () {
      final quote = testQuote(totalMinor: 50000);
      final enough = CheckoutState(
        phase: CheckoutPhase.awaitingTender,
        quote: quote,
        enteredMinor: 65000,
        serverConfirmed: true,
      );
      expect(enough.changeMinor, 15000);
      expect(enough.shortfallMinor, 0);
      expect(enough.tenderSufficient, isTrue);
      expect(enough.canSubmit, isTrue);

      final short = enough.copyWith(enteredMinor: 40000);
      expect(short.changeMinor, 0);
      expect(short.shortfallMinor, 10000);
      expect(short.tenderSufficient, isFalse);
      expect(short.canSubmit, isFalse);
    });

    test('manual external requires the exact amount due', () {
      final exact = CheckoutState(
        phase: CheckoutPhase.awaitingTender,
        quote: testQuote(totalMinor: 50000),
        tenderKind: TenderKind.manualExternal,
        enteredMinor: 50000,
        serverConfirmed: true,
      );
      expect(exact.tenderSufficient, isTrue);
      expect(exact.copyWith(enteredMinor: 50001).tenderSufficient, isFalse);
    });
  });

  test(
    'starts online, creates one draft order and quote, then awaits tender',
    () async {
      final h = Harness();
      await h.load();
      await h.controller.start();

      final state = h.container.read(checkoutControllerProvider).requireValue;
      expect(state.phase, CheckoutPhase.awaitingTender);
      expect(state.serverConfirmed, isTrue);
      expect(state.dueMinor, 50000);
      expect(h.gateway.pingCalls, 1);
      expect(h.gateway.createOrderCalls, 1);
      expect(h.gateway.createQuoteCalls, 1);
    },
  );

  test(
    'persists the checkout key and payload before finalize and submits once',
    () async {
      final h = Harness();
      await h.load();
      await h.controller.start();
      h.controller.useExactAmount();

      var sawPendingBeforeNetwork = false;
      h.gateway.onFinalize = () async {
        sawPendingBeforeNetwork = h.repository.pending != null;
        return testFinalized();
      };

      final first = h.controller.submit();
      final second = h.controller.submit();
      await Future.wait([first, second]);

      expect(sawPendingBeforeNetwork, isTrue);
      expect(h.gateway.finalizeCalls, 1);
      expect(h.repository.pending, isNull);
      expect(
        h.repository.rows.values.single.status,
        PendingCheckoutStatus.confirmed,
      );
      final state = h.container.read(checkoutControllerProvider).requireValue;
      expect(state.phase, CheckoutPhase.completed);
      expect(state.sale?.reference, testSale().reference);
    },
  );

  test('cash sale shows reference and change and clears the cart', () async {
    final h = Harness();
    await h.load();
    await h.controller.start();
    for (final digit in '65000'.split('')) {
      h.controller.appendDigit(digit);
    }
    expect(
      h.container.read(checkoutControllerProvider).requireValue.changeMinor,
      15000,
    );

    await h.controller.submit();

    final state = h.container.read(checkoutControllerProvider).requireValue;
    expect(state.phase, CheckoutPhase.completed);
    expect(state.sale?.reference, testSale().reference);
    expect(state.sale?.payment.changeMinor, 50000);
    expect(await h.cartRepository.load(), isEmpty);
    expect(h.gateway.finalizeCalls, 1);
  });

  test(
    'client rejects tender below the amount due without a network write',
    () async {
      final h = Harness();
      await h.load();
      await h.controller.start();
      for (final digit in '400'.split('')) {
        h.controller.appendDigit(digit);
      }

      await h.controller.submit();

      expect(h.gateway.finalizeCalls, 0);
      expect(h.repository.pending, isNull);
      final state = h.container.read(checkoutControllerProvider).requireValue;
      expect(state.phase, CheckoutPhase.awaitingTender);
      expect(state.message, contains('less than the amount due'));
    },
  );

  test('manual external sends the exact total and no tender', () async {
    final h = Harness();
    await h.load();
    await h.controller.start();
    h.controller.setTenderKind(TenderKind.manualExternal);
    h.controller.appendDigit('1');
    expect(
      h.container.read(checkoutControllerProvider).requireValue.canSubmit,
      isFalse,
    );
    await h.controller.submit();
    expect(h.gateway.finalizeCalls, 0);

    h.controller.useExactAmount();
    h.controller.setReference('BANK-42');
    await h.controller.submit();

    final payload = h.gateway.lastFinalizePayload!;
    expect(payload.payment.kind, PaymentInputKindEnum.MANUAL_EXTERNAL);
    expect(payload.payment.amountMinor, 50000);
    expect(payload.payment.tenderedMinor, isNull);
    expect(payload.payment.reference, 'BANK-42');
    expect(h.gateway.finalizeCalls, 1);
  });

  test(
    'expired quote is surfaced and requires a fresh quote and manual submit',
    () async {
      final h = Harness();
      await h.load();
      await h.controller.start();
      h.controller.useExactAmount();
      final firstKey = h.gateway.lastFinalizeKey;
      h.gateway.finalizeError = const CheckoutApiException(
        statusCode: 409,
        code: 'QUOTE_EXPIRED',
        message: 'Quote has expired; request a new quote before charging',
      );

      await h.controller.submit();

      var state = h.container.read(checkoutControllerProvider).requireValue;
      expect(state.phase, CheckoutPhase.quoteExpired);
      expect(state.message, contains('Request a fresh quote'));
      expect(h.repository.pending, isNull);
      expect(h.gateway.finalizeCalls, 1);

      h.gateway.quote = testQuote(totalMinor: 55000);
      await h.controller.refreshQuote();
      state = h.container.read(checkoutControllerProvider).requireValue;
      expect(state.phase, CheckoutPhase.awaitingTender);
      expect(state.dueMinor, 55000);
      expect(h.gateway.createQuoteCalls, 2);

      h.controller.useExactAmount();
      h.gateway.finalizeError = null;
      await h.controller.submit();
      expect(h.gateway.finalizeCalls, 2);
      expect(h.gateway.lastFinalizeKey, isNot(firstKey));
      expect(
        h.container.read(checkoutControllerProvider).requireValue.phase,
        CheckoutPhase.completed,
      );
    },
  );

  test(
    'restart with a pending key recovers it before permitting a new sale',
    () async {
      final repository = InMemoryCheckoutRepository();
      final pending = testPending();
      repository.rows[pending.idempotencyKey] = pending;
      final gateway = FakeCheckoutGateway()
        ..finalized = testFinalized(sale: testSale(), replayed: true);
      final h = Harness(repository: repository, gateway: gateway);
      await h.load();

      var state = h.container.read(checkoutControllerProvider).requireValue;
      expect(state.phase, CheckoutPhase.recovering);
      expect(state.pending?.idempotencyKey, pending.idempotencyKey);

      await h.controller.start();
      state = h.container.read(checkoutControllerProvider).requireValue;
      expect(state.phase, CheckoutPhase.blocked);
      expect(h.gateway.createOrderCalls, 0);

      await h.controller.recoverPending();
      state = h.container.read(checkoutControllerProvider).requireValue;
      expect(state.phase, CheckoutPhase.completed);
      expect(state.replayed, isTrue);
      expect(h.gateway.recoverCalls, 1);
      expect(h.gateway.lastRecoverKey, pending.idempotencyKey);
      expect(h.gateway.lastRecoverDeviceId, pending.deviceId);
      expect(h.gateway.finalizeCalls, 0);
      expect(h.repository.pending, isNull);
      expect(await h.cartRepository.load(), isEmpty);
    },
  );

  test(
    'repeated not-found is required before a new key is permitted',
    () async {
      final repository = InMemoryCheckoutRepository();
      final pending = testPending();
      repository.rows[pending.idempotencyKey] = pending;
      final gateway = FakeCheckoutGateway()
        ..recoverError = const CheckoutApiException(
          statusCode: 404,
          code: 'NOT_FOUND',
          message: 'No completed checkout is recorded for this key',
        );
      final h = Harness(repository: repository, gateway: gateway);
      await h.load();

      await h.controller.recoverPending();
      var state = h.container.read(checkoutControllerProvider).requireValue;
      expect(state.phase, CheckoutPhase.inFlight);
      expect(state.pending, isNotNull);
      expect(h.repository.pending, isNotNull);

      await h.controller.start();
      expect(h.gateway.createOrderCalls, 0);

      await h.controller.recoverPending();
      await h.controller.recoverPending();
      state = h.container.read(checkoutControllerProvider).requireValue;
      expect(state.phase, CheckoutPhase.idle);
      expect(state.message, contains('did not record'));
      expect(h.repository.pending, isNull);
      expect(h.gateway.recoverCalls, 3);

      await h.controller.start();
      h.controller.useExactAmount();
      await h.controller.submit();
      state = h.container.read(checkoutControllerProvider).requireValue;
      expect(state.phase, CheckoutPhase.completed);
      expect(h.gateway.lastFinalizeKey, isNot(pending.idempotencyKey));
    },
  );

  test(
    'in-flight key stays blocked and is polled without resubmitting',
    () async {
      final repository = InMemoryCheckoutRepository();
      final pending = testPending();
      repository.rows[pending.idempotencyKey] = pending;
      final gateway = FakeCheckoutGateway()
        ..recoverError = const CheckoutApiException(
          statusCode: 409,
          code: 'IDEMPOTENCY_IN_PROGRESS',
          message: 'This checkout is still being processed; retry shortly',
          retryable: true,
        );
      final h = Harness(repository: repository, gateway: gateway);
      await h.load();
      await h.controller.recoverPending();

      final state = h.container.read(checkoutControllerProvider).requireValue;
      expect(state.phase, CheckoutPhase.inFlight);
      expect(state.pending, isNotNull);
      expect(h.gateway.finalizeCalls, 0);

      await h.controller.start();
      expect(h.gateway.createOrderCalls, 0);
      expect(
        h.container.read(checkoutControllerProvider).requireValue.pending,
        isNotNull,
      );
    },
  );

  test(
    'retryable server error keeps the key and retries the same payload',
    () async {
      final h = Harness();
      await h.load();
      await h.controller.start();
      h.controller.useExactAmount();
      h.gateway.finalizeError = const CheckoutApiException(
        statusCode: 503,
        code: 'TRANSACTION_RETRY_EXHAUSTED',
        message: 'Checkout could not commit',
        retryable: true,
      );

      await h.controller.submit();
      var state = h.container.read(checkoutControllerProvider).requireValue;
      expect(state.phase, CheckoutPhase.blocked);
      expect(state.pending, isNotNull);
      final key = h.gateway.lastFinalizeKey;
      expect(h.gateway.finalizeCalls, 1);

      h.gateway.finalizeError = null;
      await h.controller.retrySameKey();
      state = h.container.read(checkoutControllerProvider).requireValue;
      expect(state.phase, CheckoutPhase.completed);
      expect(h.gateway.finalizeCalls, 2);
      expect(h.gateway.lastFinalizeKey, key);
    },
  );

  test('offline start blocks completion and preserves the cart', () async {
    final h = Harness();
    await h.load();
    h.gateway.online = false;

    await h.controller.start();

    final state = h.container.read(checkoutControllerProvider).requireValue;
    expect(state.phase, CheckoutPhase.error);
    expect(state.message, contains('No confirmed server connection'));
    expect(h.gateway.createOrderCalls, 0);
    expect(await h.cartRepository.load(), hasLength(1));
  });

  test('print failure never repeats the finalize request', () async {
    final printer = FakeReceiptPrinter(connected: true, throwOnPrint: true);
    final h = Harness(printer: printer);
    await h.load();
    await h.controller.start();
    h.controller.useExactAmount();

    await h.controller.submit();

    final state = h.container.read(checkoutControllerProvider).requireValue;
    expect(h.gateway.finalizeCalls, 1);
    expect(printer.printCount, 1);
    expect(state.phase, CheckoutPhase.completed);
    expect(state.printMessage, contains('could not print'));
    expect(h.printRepository.jobs, hasLength(1));
    final job = h.printRepository.jobs.values.single;
    expect(job.state, PrintJobState.uncertain);
    expect(job.copy, isFalse);

    h.controller.acknowledge();
    expect(h.gateway.finalizeCalls, 1);
  });

  test(
    'no configured printer leaves a durable queued job and one sale',
    () async {
      final h = Harness();
      await h.load();
      await h.controller.start();
      h.controller.useExactAmount();

      await h.controller.submit();

      final state = h.container.read(checkoutControllerProvider).requireValue;
      expect(state.phase, CheckoutPhase.completed);
      expect(state.printJob?.state, PrintJobState.queued);
      expect(state.printMessage, contains('queued'));
      expect(h.printRepository.jobs, hasLength(1));
      expect(h.gateway.finalizeCalls, 1);
    },
  );

  test('manual reprint creates a COPY job with an audit entry', () async {
    final printer = FakeReceiptPrinter(connected: true);
    final h = Harness(printer: printer);
    await h.load();
    await h.controller.start();
    h.controller.useExactAmount();
    await h.controller.submit();

    final first = h.container.read(checkoutControllerProvider).requireValue;
    expect(first.printJob?.state, PrintJobState.sent);
    expect(printer.printCount, 1);

    await h.controller.reprintCopy();

    final after = h.container.read(checkoutControllerProvider).requireValue;
    expect(after.printJob?.copy, isTrue);
    expect(after.printJob?.receipt.copy, isTrue);
    expect(printer.printCount, 2);
    expect(h.printRepository.jobs, hasLength(2));
    expect(
      h.printRepository.audits.any(
        (entry) => entry.action.name == 'reprint' && entry.copy,
      ),
      isTrue,
    );
    expect(h.gateway.finalizeCalls, 1);
  });
}
