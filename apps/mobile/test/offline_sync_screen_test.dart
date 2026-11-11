import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modern_pos_mobile/features/checkout/checkout_gateway.dart';
import 'package:modern_pos_mobile/features/checkout/checkout_models.dart';
import 'package:modern_pos_mobile/features/offline/offline_sale_models.dart';
import 'package:modern_pos_mobile/features/offline/offline_sale_store.dart';
import 'package:modern_pos_mobile/features/offline/offline_sync_screen.dart';
import 'package:modern_pos_mobile/theme/app_theme.dart';

import 'support/checkout_fakes.dart';
import 'support/offline_fakes.dart';

OfflineSalePayload payload({String key = 'screen-key-1'}) {
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
    amountMinor: 50000,
    tenderedMinor: 50000,
    reference: null,
    totalMinor: 50000,
    currency: 'IDR',
    currencyExponent: 0,
    createdAt: DateTime.utc(2026, 11, 11, 8),
    orderId: '00000000-0000-4000-8000-000000000201',
    quoteId: '00000000-0000-4000-8000-000000000202',
    orderVersion: 1,
  );
}

Future<void> pumpScreen(
  WidgetTester tester,
  InMemoryOfflineSaleStore store,
  FakeCheckoutGateway gateway,
) async {
  tester.view.physicalSize = const Size(320, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        offlineSaleStoreProvider.overrideWithValue(store),
        checkoutGatewayProvider.overrideWithValue(gateway),
      ],
      child: MaterialApp(
        theme: buildAppTheme(),
        home: const OfflineSyncScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('empty queue explains that nothing is pending', (tester) async {
    await pumpScreen(tester, InMemoryOfflineSaleStore(), FakeCheckoutGateway());

    expect(find.text('Sync status'), findsOneWidget);
    expect(find.text('No offline sales queued'), findsOneWidget);
    expect(find.text('Pending 0'), findsOneWidget);
  });

  testWidgets('pending sale syncs from the screen', (tester) async {
    final store = InMemoryOfflineSaleStore();
    final gateway = FakeCheckoutGateway();
    await store.upsert(payload());
    await pumpScreen(tester, store, gateway);

    expect(find.text('Pending 1'), findsOneWidget);
    expect(find.text('Offline sales needing attention'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Sync now'));
    await tester.pumpAndSettle();

    expect(gateway.finalizeCalls, 1);
    expect(find.text('Synced 1'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Recent synced sales'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Recent synced sales'), findsOneWidget);
  });

  testWidgets('conflict reason and cashier action are visible', (tester) async {
    final store = InMemoryOfflineSaleStore();
    await store.upsert(payload());
    await store.markConflict(
      'screen-key-1',
      'INSUFFICIENT_STOCK: Insufficient stock for this sale',
    );
    await pumpScreen(tester, store, FakeCheckoutGateway());

    expect(find.text('Conflict 1'), findsOneWidget);
    expect(find.textContaining('INSUFFICIENT_STOCK'), findsOneWidget);
    expect(find.textContaining('Cashier action'), findsOneWidget);
    expect(
      find.widgetWithText(FilledButton, 'Retry after review'),
      findsOneWidget,
    );
  });
}
