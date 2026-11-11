import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modern_pos_mobile/features/checkout/checkout_gateway.dart';
import 'package:modern_pos_mobile/features/checkout/checkout_models.dart';
import 'package:modern_pos_mobile/features/offline/offline_sale_models.dart';
import 'package:modern_pos_mobile/features/offline/offline_sale_store.dart';
import 'package:modern_pos_mobile/features/offline/offline_sync_controller.dart';

import 'support/checkout_fakes.dart';
import 'support/offline_fakes.dart';

OfflineSalePayload salePayload({
  String key = 'offline-key-1',
  bool withDraft = true,
  int totalMinor = 50000,
  int tenderedMinor = 50000,
}) {
  return OfflineSalePayload(
    idempotencyKey: key,
    orderKey: 'order-$key',
    outletId: 'outlet-1',
    deviceId: 'device-1',
    lines: const [
      OfflineSaleLine(
        variantId: 'variant-1',
        name: 'Tea',
        variantName: 'Default',
        quantity: 1,
        unitPriceMinor: 50000,
      ),
    ],
    tenderKind: TenderKind.cash,
    amountMinor: totalMinor,
    tenderedMinor: tenderedMinor,
    reference: null,
    totalMinor: totalMinor,
    currency: 'IDR',
    currencyExponent: 0,
    createdAt: DateTime.utc(2026, 11, 11, 8),
    orderId: withDraft ? '00000000-0000-4000-8000-000000000201' : null,
    quoteId: withDraft ? '00000000-0000-4000-8000-000000000202' : null,
    orderVersion: withDraft ? 1 : null,
  );
}

class SyncHarness {
  SyncHarness({FakeCheckoutGateway? gateway})
    : gateway = gateway ?? FakeCheckoutGateway() {
    container = ProviderContainer(
      overrides: [
        offlineSaleStoreProvider.overrideWithValue(store),
        checkoutGatewayProvider.overrideWithValue(this.gateway),
      ],
    );
    addTearDown(container.dispose);
  }

  final FakeCheckoutGateway gateway;
  final InMemoryOfflineSaleStore store = InMemoryOfflineSaleStore();
  late final ProviderContainer container;

  OfflineSyncController get controller =>
      container.read(offlineSyncControllerProvider.notifier);

  Future<OfflineSyncState> load() =>
      container.read(offlineSyncControllerProvider.future);

  OfflineSyncState get state =>
      container.read(offlineSyncControllerProvider).requireValue;
}

void main() {
  test(
    'replays a cold offline sale with the same order and checkout keys',
    () async {
      final h = SyncHarness();
      await h.load();
      await h.store.upsert(salePayload(withDraft: false));

      await h.controller.syncAll();

      expect(h.gateway.createOrderCalls, 1);
      expect(h.gateway.createQuoteCalls, 1);
      expect(h.gateway.finalizeCalls, 1);
      expect(h.gateway.lastFinalizeKey, 'offline-key-1');
      expect(h.state.records.single.state, OfflineSaleState.synced);
      expect(h.state.records.single.saleReference, testSale().reference);
      expect(h.state.records.single.payload.orderId, isNotNull);
    },
  );

  test(
    'replay of an already synced item never sends a second finalize',
    () async {
      final h = SyncHarness();
      await h.load();
      await h.store.upsert(salePayload());
      await h.controller.syncAll();
      expect(h.gateway.finalizeCalls, 1);

      await h.controller.syncAll();
      await h.controller.retry('offline-key-1');

      expect(h.gateway.finalizeCalls, 1);
      expect(h.state.records.single.state, OfflineSaleState.synced);
    },
  );

  test('parallel sync triggers are single-flight and submit once', () async {
    final h = SyncHarness();
    await h.load();
    await h.store.upsert(salePayload());
    final gate = Completer<void>();
    h.gateway.onFinalize = () async {
      await gate.future;
      return testFinalized();
    };

    final first = h.controller.syncAll();
    final second = h.controller.syncAll();
    await Future<void>.delayed(Duration.zero);
    expect(h.gateway.finalizeCalls, 1);
    gate.complete();
    await Future.wait([first, second]);

    expect(h.gateway.finalizeCalls, 1);
    expect(h.state.records.single.state, OfflineSaleState.synced);
  });

  test(
    'uncertain outcome is resolved through sales_recover, not resubmitted',
    () async {
      final h = SyncHarness();
      await h.load();
      await h.store.upsert(salePayload());
      await h.store.markUncertain(
        'offline-key-1',
        'timeout',
        DateTime.now().subtract(const Duration(seconds: 1)),
      );

      await h.controller.syncAll();

      expect(h.gateway.recoverCalls, 1);
      expect(h.gateway.lastRecoverKey, 'offline-key-1');
      expect(h.gateway.finalizeCalls, 0);
      expect(h.state.records.single.state, OfflineSaleState.synced);
    },
  );

  test('server stock rejection becomes a conflict with the reason', () async {
    final h = SyncHarness();
    await h.load();
    await h.store.upsert(salePayload());
    h.gateway.finalizeError = const CheckoutApiException(
      statusCode: 422,
      code: 'INSUFFICIENT_STOCK',
      message: 'Insufficient stock for this sale',
      details: {
        'shortages': [
          {'name': 'Milk', 'required': '2', 'available': '0'},
        ],
      },
    );

    await h.controller.syncAll();

    final record = h.state.records.single;
    expect(record.state, OfflineSaleState.conflict);
    expect(record.lastError, contains('INSUFFICIENT_STOCK'));
    expect(record.lastError, contains('Milk'));
    expect(h.gateway.finalizeCalls, 1);
  });

  test('server total change is a conflict before finalize', () async {
    final h = SyncHarness();
    await h.load();
    await h.store.upsert(salePayload(withDraft: false, totalMinor: 50000));
    h.gateway.quote = testQuote(totalMinor: 55000);

    await h.controller.syncAll();

    final record = h.state.records.single;
    expect(record.state, OfflineSaleState.conflict);
    expect(record.lastError, contains('differs'));
    expect(h.gateway.finalizeCalls, 0);
  });

  test(
    'unreachable server keeps the sale pending with bounded backoff',
    () async {
      final h = SyncHarness();
      await h.load();
      await h.store.upsert(salePayload());
      h.gateway.finalizeError = const CheckoutApiException(
        code: 'NETWORK',
        message: 'No confirmed server connection',
        retryable: true,
      );

      await h.controller.syncAll();

      var record = h.state.records.single;
      expect(record.state, OfflineSaleState.pending);
      expect(record.attempts, 1);
      expect(record.lastError, contains('NETWORK'));
      expect(record.nextAttemptAt, isNotNull);
      expect(record.nextAttemptAt!.isAfter(DateTime.now()), isTrue);
      expect(h.store.rows, hasLength(1));

      h.gateway.finalizeError = null;
      await h.controller.retry('offline-key-1');
      record = h.state.records.single;
      expect(record.state, OfflineSaleState.synced);
      expect(h.gateway.finalizeCalls, 2);
    },
  );

  test(
    'two devices racing the same low stock: one sale, one clean conflict',
    () async {
      final gateway = FakeCheckoutGateway();
      var accepted = 0;
      gateway.onFinalize = () async {
        accepted++;
        if (accepted == 1) {
          return testFinalized(sale: testSale(orderId: 'device-order-a'));
        }
        throw const CheckoutApiException(
          statusCode: 422,
          code: 'INSUFFICIENT_STOCK',
          message:
              'Insufficient stock for this sale; no negative balance created',
        );
      };
      final a = SyncHarness(gateway: gateway);
      final b = SyncHarness(gateway: gateway);
      await a.load();
      await b.load();
      await a.store.upsert(salePayload(key: 'device-a', withDraft: false));
      await b.store.upsert(salePayload(key: 'device-b', withDraft: false));

      await Future.wait([a.controller.syncAll(), b.controller.syncAll()]);

      final states = [
        a.state.records.single.state,
        b.state.records.single.state,
      ];
      expect(
        states.where((state) => state == OfflineSaleState.synced),
        hasLength(1),
      );
      expect(
        states.where((state) => state == OfflineSaleState.conflict),
        hasLength(1),
      );
      expect(gateway.finalizeCalls, 2);
      final conflicts = [
        a.state.records.single,
        b.state.records.single,
      ].where((record) => record.state == OfflineSaleState.conflict);
      expect(conflicts.single.lastError, contains('INSUFFICIENT_STOCK'));
    },
  );

  test('reconciliation checks synced keys against server sales', () async {
    final h = SyncHarness();
    await h.load();
    await h.store.upsert(salePayload());
    await h.controller.syncAll();
    h.gateway.serverSales = [testSale()];

    final report = await h.controller.reconcile();

    expect(report, isNotNull);
    expect(report!.matches, isTrue);
    expect(report.localSynced, 1);
    expect(report.serverMatched, 1);
    expect(report.missingKeys, isEmpty);
  });

  test('reconciliation reports a missing server sale', () async {
    final h = SyncHarness();
    await h.load();
    await h.store.upsert(salePayload());
    await h.controller.syncAll();
    h.gateway.serverSales = const [];

    final report = await h.controller.reconcile();

    expect(report, isNotNull);
    expect(report!.matches, isFalse);
    expect(report.missingKeys, contains('offline-key-1'));
  });

  test(
    'an interrupted in-flight row is recovered instead of resubmitted',
    () async {
      final h = SyncHarness();
      await h.load();
      await h.store.upsert(salePayload());
      await h.store.claim('offline-key-1', DateTime.now());
      expect(h.store.rows['offline-key-1']!.state, OfflineSaleState.inFlight);

      await h.controller.syncAll();

      expect(h.gateway.recoverCalls, 1);
      expect(h.gateway.finalizeCalls, 0);
      expect(h.state.records.single.state, OfflineSaleState.synced);
    },
  );
}
