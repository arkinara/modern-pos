import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modern_pos_api_client/api.dart';
import 'package:modern_pos_mobile/core/device_identity.dart';
import 'package:modern_pos_mobile/features/auth/auth_controller.dart';
import 'package:modern_pos_mobile/features/cart/cart_controller.dart';
import 'package:modern_pos_mobile/features/cart/cart_line.dart';
import 'package:modern_pos_mobile/features/checkout/checkout_gateway.dart';
import 'package:modern_pos_mobile/features/checkout/checkout_models.dart';
import 'package:modern_pos_mobile/features/checkout/checkout_repository.dart';
import 'package:modern_pos_mobile/features/checkout/checkout_screen.dart';
import 'package:modern_pos_mobile/features/printing/print_job_mirror.dart';
import 'package:modern_pos_mobile/features/printing/print_queue_repository.dart';
import 'package:modern_pos_mobile/features/printing/printer_controller.dart';
import 'package:modern_pos_mobile/features/printing/receipt_identity.dart';
import 'package:modern_pos_mobile/theme/app_theme.dart';

import 'support/checkout_fakes.dart';
import 'support/fakes.dart';
import 'support/printer_fakes.dart';

class WidgetHarness {
  WidgetHarness({
    FakeCheckoutGateway? gateway,
    InMemoryCheckoutRepository? repository,
    FakeReceiptPrinter? printer,
  }) : gateway = gateway ?? FakeCheckoutGateway(),
       repository = repository ?? InMemoryCheckoutRepository(),
       printer = printer ?? FakeReceiptPrinter(connected: false);

  final FakeCheckoutGateway gateway;
  final InMemoryCheckoutRepository repository;
  final FakeReceiptPrinter printer;
  final InMemoryPrintQueueRepository printRepository =
      InMemoryPrintQueueRepository();
  final InMemoryCartRepository cartRepository = InMemoryCartRepository();
  late final InMemoryPrinterConfigStore configStore =
      InMemoryPrinterConfigStore(
        printer.connected ? testPrinterConfig() : null,
      );

  Future<void> pump(
    WidgetTester tester, {
    Size size = const Size(440, 1400),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await cartRepository.save(
      const CartLine(
        menuId: 'tea',
        variantId: 'variant-1',
        itemName: 'Tea',
        variantName: 'Default',
        unitPriceMinor: 50000,
        quantity: 1,
        currency: 'IDR',
        currencyExponent: 0,
      ),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(
            () => FakeAuthController(testSession(outletId: 'outlet-1')),
          ),
          cartRepositoryProvider.overrideWithValue(cartRepository),
          checkoutRepositoryProvider.overrideWithValue(repository),
          checkoutGatewayProvider.overrideWithValue(gateway),
          deviceIdentityProvider.overrideWithValue(FixedDeviceIdentity()),
          printerAdapterProvider.overrideWithValue(printer),
          printQueueRepositoryProvider.overrideWithValue(printRepository),
          printerConfigStoreProvider.overrideWithValue(configStore),
          receiptIdentityRepositoryProvider.overrideWithValue(
            FakeReceiptIdentityRepository(),
          ),
          printJobMirrorProvider.overrideWithValue(const NoopPrintJobMirror()),
        ],
        child: MaterialApp(
          theme: buildAppTheme(),
          home: const CheckoutScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }
}

Future<void> tapKeys(WidgetTester tester, String digits) async {
  for (final digit in digits.split('')) {
    await tester.tap(find.widgetWithText(OutlinedButton, digit));
    await tester.pump();
  }
}

void main() {
  testWidgets(
    'cashier enters tender, sees live change and the sale reference',
    (tester) async {
      final h = WidgetHarness();
      await h.pump(tester);

      expect(find.text('Amount due'), findsOneWidget);
      expect(find.text('Rp50.000'), findsWidgets);

      await tapKeys(tester, '65000');
      expect(find.text('Rp15.000'), findsWidgets);
      expect(find.textContaining('Short by'), findsNothing);

      await tester.tap(find.widgetWithText(FilledButton, 'Complete sale'));
      await tester.pumpAndSettle();

      expect(find.text('Sale completed'), findsOneWidget);
      expect(find.text(testSale().reference), findsOneWidget);
      expect(find.text('Rp50.000'), findsWidgets);
      expect(h.gateway.finalizeCalls, 1);
    },
  );

  testWidgets('duplicate taps produce exactly one finalize request', (
    tester,
  ) async {
    final gate = Completer<Finalized>();
    final h = WidgetHarness(
      gateway: FakeCheckoutGateway()..finalizeGate = gate,
    );
    await h.pump(tester);

    await tester.tap(find.text('Exact amount'));
    await tester.pump();

    final button = find.widgetWithText(FilledButton, 'Complete sale');
    await tester.tap(button);
    await tester.tap(button);
    await tester.pump();

    expect(h.gateway.finalizeCalls, 1);

    gate.complete(testFinalized());
    await tester.pumpAndSettle();
    expect(find.text('Sale completed'), findsOneWidget);
    expect(h.gateway.finalizeCalls, 1);
  });

  testWidgets('tender below the amount due leaves completion disabled', (
    tester,
  ) async {
    final h = WidgetHarness();
    await h.pump(tester);

    await tapKeys(tester, '400');

    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Complete sale'),
    );
    expect(button.onPressed, isNull);
    expect(find.textContaining('Short by'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Complete sale'));
    await tester.pump();
    expect(h.gateway.finalizeCalls, 0);
  });

  testWidgets('offline checkout is blocked with an actionable message', (
    tester,
  ) async {
    final h = WidgetHarness(gateway: FakeCheckoutGateway()..online = false);
    await h.pump(tester);

    expect(
      find.textContaining('No confirmed server connection'),
      findsOneWidget,
    );
    expect(find.widgetWithText(FilledButton, 'Retry'), findsOneWidget);
    expect(h.gateway.createOrderCalls, 0);
    expect(await h.cartRepository.load(), hasLength(1));
  });

  testWidgets(
    'restart resolves a persisted key and shows the recovered receipt',
    (tester) async {
      final repository = InMemoryCheckoutRepository();
      final pending = testPending();
      repository.rows[pending.idempotencyKey] = pending;
      final h = WidgetHarness(
        repository: repository,
        gateway: FakeCheckoutGateway()
          ..finalized = testFinalized(sale: testSale(), replayed: true),
      );
      await h.pump(tester);

      expect(find.text('Sale completed'), findsOneWidget);
      expect(
        find.textContaining('Recovered from the existing checkout key'),
        findsOneWidget,
      );
      expect(h.gateway.recoverCalls, 1);
      expect(h.gateway.lastRecoverKey, pending.idempotencyKey);
      expect(h.gateway.finalizeCalls, 0);
    },
  );

  testWidgets(
    'expired quote asks for a fresh quote instead of re-pricing silently',
    (tester) async {
      final h = WidgetHarness();
      await h.pump(tester);
      await tester.tap(find.text('Exact amount'));
      await tester.pump();

      h.gateway.finalizeError = const CheckoutApiException(
        statusCode: 409,
        code: 'QUOTE_EXPIRED',
        message: 'Quote has expired; request a new quote before charging',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Complete sale'));
      await tester.pumpAndSettle();

      expect(find.text('Quote needs a refresh'), findsOneWidget);
      expect(
        find.widgetWithText(FilledButton, 'Get new quote'),
        findsOneWidget,
      );
      expect(h.gateway.finalizeCalls, 1);

      h.gateway.finalizeError = null;
      h.gateway.quote = testQuote(totalMinor: 55000);
      await tester.tap(find.widgetWithText(FilledButton, 'Get new quote'));
      await tester.pumpAndSettle();

      expect(find.text('Amount due'), findsOneWidget);
      expect(find.text('Rp55.000'), findsWidgets);
      expect(h.gateway.createQuoteCalls, 2);
      expect(h.gateway.finalizeCalls, 1);
    },
  );

  testWidgets('receipt and print controls fit a 320px cashier screen', (
    tester,
  ) async {
    final h = WidgetHarness();
    await h.pump(tester, size: const Size(320, 2200));

    await tester.tap(find.text('Exact amount'));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Complete sale'));
    await tester.pumpAndSettle();

    expect(find.text('Sale completed'), findsOneWidget);
    expect(find.text('Reprint COPY'), findsOneWidget);
    expect(find.textContaining('Queued'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'print failure after sale shows a warning and does not repeat checkout',
    (tester) async {
      final h = WidgetHarness(
        printer: FakeReceiptPrinter(connected: true, throwOnPrint: true),
      );
      await h.pump(tester);

      await tester.tap(find.text('Exact amount'));
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Complete sale'));
      await tester.pumpAndSettle();

      expect(find.text('Sale completed'), findsOneWidget);
      expect(find.textContaining('could not print'), findsOneWidget);
      expect(h.gateway.finalizeCalls, 1);
      expect(h.printer.printCount, 1);
    },
  );
}
