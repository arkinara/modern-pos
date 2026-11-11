import 'package:flutter/material.dart' hide Table;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modern_pos_api_client/api.dart';
import 'package:modern_pos_mobile/features/auth/auth_controller.dart';
import 'package:modern_pos_mobile/features/cart/cart_controller.dart';
import 'package:modern_pos_mobile/features/tables/table_orders_gateway.dart';
import 'package:modern_pos_mobile/features/tables/tables_screen.dart';

import 'support/fakes.dart';

class FakeTableOrdersGateway implements TableOrdersGateway {
  FakeTableOrdersGateway({
    this.tables = const [],
    this.orders = const [],
    this.failure,
  });

  List<Table> tables;
  List<Order> orders;
  Object? failure;
  int transferCalls = 0;

  @override
  Future<List<Table>> listTables(String outletId) async {
    if (failure != null) {
      throw failure!;
    }
    return tables;
  }

  @override
  Future<List<Order>> listOpenOrders(String outletId) async {
    if (failure != null) {
      throw failure!;
    }
    return orders;
  }

  @override
  Future<Order> openTableOrder({
    required String outletId,
    required String deviceId,
    required String idempotencyKey,
    required String tableId,
    required List<OrderWriteLinesInner> lines,
  }) async {
    throw const TableOrdersException(
      code: 'EMPTY_CART',
      message: 'Add items to the cart before opening a table order.',
    );
  }

  @override
  Future<Order> transfer({
    required String outletId,
    required String orderId,
    required int version,
    required String tableId,
  }) async {
    transferCalls += 1;
    final order = orders.firstWhere((row) => row.id == orderId);
    final moved = Order(
      id: order.id,
      deviceId: order.deviceId,
      state: order.state,
      version: order.version + 1,
      lines: order.lines,
      tableId: tableId,
      tableLabel: tables.firstWhere((row) => row.id == tableId).label,
    );
    orders = [moved];
    return moved;
  }

  @override
  Future<SplitResult> split({
    required String outletId,
    required String orderId,
    required String idempotencyKey,
    required int version,
    required List<SplitBill> bills,
  }) async {
    throw const TableOrdersException(
      code: 'SPLIT_IMPOSSIBLE',
      message: 'This order cannot be split.',
    );
  }

  @override
  Future<void> cancel({
    required String outletId,
    required String orderId,
    required int version,
  }) async {
    orders = const [];
  }
}

Table table(String id, String label) =>
    Table(id: id, label: label, seatCount: 4, active: true);

Order order(String id, String tableId, String tableLabel) => Order(
  id: id,
  deviceId: 'device-1',
  state: OrderStateEnum.DRAFT,
  version: 1,
  lines: [OrderWriteLinesInner(variantId: 'variant-1', quantity: 2)],
  tableId: tableId,
  tableLabel: tableLabel,
);

Future<void> pumpTables(
  WidgetTester tester,
  FakeTableOrdersGateway gateway,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authControllerProvider.overrideWith(
          () => FakeAuthController(testSession()),
        ),
        tableOrdersGatewayProvider.overrideWithValue(gateway),
      ],
      child: const MaterialApp(home: Scaffold(body: TablesScreen())),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  for (final width in [320.0, 768.0, 1024.0, 1440.0]) {
    testWidgets('responsive tables layout at ${width.toInt()}px', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await pumpTables(
        tester,
        FakeTableOrdersGateway(
          tables: [table('t1', 'T1'), table('t2', 'T2')],
          orders: [order('o1', 't1', 'T1')],
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('T1'), findsOneWidget);
      expect(find.text('Split 2 ways'), findsOneWidget);
    });
  }

  testWidgets('shows table state and explains reservation policy', (
    tester,
  ) async {
    final gateway = FakeTableOrdersGateway(
      tables: [table('t1', 'T1'), table('t2', 'T2')],
      orders: [order('o1', 't1', 'T1')],
    );

    await pumpTables(tester, gateway);

    expect(find.text('T1'), findsOneWidget);
    expect(find.text('T2'), findsOneWidget);
    expect(find.text('Open'), findsOneWidget);
    expect(find.text('Free'), findsOneWidget);
    expect(find.textContaining('reserves no stock'), findsOneWidget);
    expect(find.text('Split 2 ways'), findsOneWidget);
  });

  testWidgets('transfers an open order to another table', (tester) async {
    final gateway = FakeTableOrdersGateway(
      tables: [table('t1', 'T1'), table('t2', 'T2')],
      orders: [order('o1', 't1', 'T1')],
    );

    await pumpTables(tester, gateway);
    await tester.tap(find.text('Transfer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Move to T2'));
    await tester.pumpAndSettle();

    expect(gateway.transferCalls, 1);
    expect(find.text('Order moved to T2.'), findsOneWidget);
  });

  testWidgets('opening an empty cart explains what to do', (tester) async {
    final gateway = FakeTableOrdersGateway(tables: [table('t1', 'T1')]);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(
            () => FakeAuthController(testSession()),
          ),
          cartRepositoryProvider.overrideWithValue(InMemoryCartRepository()),
          tableOrdersGatewayProvider.overrideWithValue(gateway),
        ],
        child: const MaterialApp(home: Scaffold(body: TablesScreen())),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open order'));
    await tester.pumpAndSettle();

    expect(
      find.text('Add items to the cart before opening a table order.'),
      findsOneWidget,
    );
  });

  testWidgets('shows the empty state when no tables exist', (tester) async {
    await pumpTables(tester, FakeTableOrdersGateway());

    expect(find.text('No tables yet'), findsOneWidget);
  });

  testWidgets('shows the failure state with retry', (tester) async {
    await pumpTables(
      tester,
      FakeTableOrdersGateway(
        failure: const TableOrdersException(
          code: 'NETWORK',
          message: 'No confirmed server connection.',
        ),
      ),
    );

    expect(find.text('Could not load tables'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}
