import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modern_pos_api_client/api.dart';

import '../../core/device_identity.dart';
import '../auth/auth_controller.dart';
import '../cart/cart_controller.dart';
import 'table_orders_gateway.dart';

class TableOrderRow {
  const TableOrderRow({required this.table, required this.order});

  final Table table;
  final Order? order;

  bool get isOccupied => order != null;
}

class TableOrdersState {
  const TableOrdersState({this.tables = const [], this.orders = const []});

  final List<Table> tables;
  final List<Order> orders;

  List<TableOrderRow> get rows => List.unmodifiable(
    tables.map(
      (table) => TableOrderRow(table: table, order: _orderFor(table.id)),
    ),
  );

  int get occupiedCount => rows.where((row) => row.isOccupied).length;

  Order? _orderFor(String tableId) {
    for (final order in orders) {
      if (order.tableId == tableId) {
        return order;
      }
    }
    return null;
  }
}

final tableOrdersControllerProvider =
    AsyncNotifierProvider.autoDispose<TableOrdersController, TableOrdersState>(
      TableOrdersController.new,
    );

class TableOrdersController extends AsyncNotifier<TableOrdersState> {
  bool _busy = false;

  TableOrdersGateway get _gateway => ref.read(tableOrdersGatewayProvider);

  @override
  Future<TableOrdersState> build() async {
    return _load();
  }

  Future<TableOrdersState> _load() async {
    final outletId = await _requireOutletId();
    final results = await Future.wait<dynamic>([
      _gateway.listTables(outletId),
      _gateway.listOpenOrders(outletId),
    ]);
    return TableOrdersState(
      tables: results[0] as List<Table>,
      orders: results[1] as List<Order>,
    );
  }

  Future<String> _requireOutletId() async {
    final session = await ref.read(authControllerProvider.future);
    final outletIds = session?.user.outletIds ?? const <String>[];
    if (outletIds.isEmpty) {
      throw const TableOrdersException(
        code: 'NO_OUTLET',
        message: 'This session has no authorized outlet.',
      );
    }
    return outletIds.first;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<Order> open(Table table) async {
    await _ensureIdle();
    _busy = true;
    state = const AsyncLoading();
    try {
      final cart = await ref.read(cartControllerProvider.future);
      if (cart.lines.isEmpty) {
        throw const TableOrdersException(
          code: 'EMPTY_CART',
          message: 'Add items to the cart before opening a table order.',
        );
      }

      final outletId = await _requireOutletId();
      final deviceId = await ref.read(deviceIdentityProvider).deviceId();
      final order = await _gateway.openTableOrder(
        outletId: outletId,
        deviceId: deviceId,
        idempotencyKey: generateUuidV4(),
        tableId: table.id,
        lines: cart.lines
            .map(
              (line) => OrderWriteLinesInner(
                variantId: line.variantId,
                quantity: line.quantity,
              ),
            )
            .toList(growable: false),
      );
      await ref.read(cartControllerProvider.notifier).clear();
      state = await AsyncValue.guard(_load);
      return order;
    } catch (_) {
      state = await AsyncValue.guard(_load);
      rethrow;
    } finally {
      _busy = false;
    }
  }

  Future<Order> transfer(Order order, Table table) async {
    await _ensureIdle();
    _busy = true;
    state = const AsyncLoading();
    try {
      final outletId = await _requireOutletId();
      final moved = await _gateway.transfer(
        outletId: outletId,
        orderId: order.id,
        version: order.version,
        tableId: table.id,
      );
      state = await AsyncValue.guard(_load);
      return moved;
    } catch (_) {
      state = await AsyncValue.guard(_load);
      rethrow;
    } finally {
      _busy = false;
    }
  }

  Future<SplitResult> splitTwoWays(Order order) async {
    await _ensureIdle();
    _busy = true;
    final bills = _twoWayBills(order);
    state = const AsyncLoading();
    try {
      final outletId = await _requireOutletId();
      final result = await _gateway.split(
        outletId: outletId,
        orderId: order.id,
        idempotencyKey: generateUuidV4(),
        version: order.version,
        bills: bills,
      );
      state = await AsyncValue.guard(_load);
      return result;
    } catch (_) {
      state = await AsyncValue.guard(_load);
      rethrow;
    } finally {
      _busy = false;
    }
  }

  Future<void> cancel(Order order) async {
    await _ensureIdle();
    _busy = true;
    state = const AsyncLoading();
    try {
      final outletId = await _requireOutletId();
      await _gateway.cancel(
        outletId: outletId,
        orderId: order.id,
        version: order.version,
      );
      state = await AsyncValue.guard(_load);
    } catch (_) {
      state = await AsyncValue.guard(_load);
      rethrow;
    } finally {
      _busy = false;
    }
  }

  List<SplitBill> _twoWayBills(Order order) {
    final first = <OrderWriteLinesInner>[];
    final second = <OrderWriteLinesInner>[];

    for (final line in order.lines) {
      final left = (line.quantity + 1) ~/ 2;
      final right = line.quantity - left;
      if (left > 0) {
        first.add(
          OrderWriteLinesInner(variantId: line.variantId, quantity: left),
        );
      }
      if (right > 0) {
        second.add(
          OrderWriteLinesInner(variantId: line.variantId, quantity: right),
        );
      }
    }

    if (first.isEmpty || second.isEmpty) {
      throw const TableOrdersException(
        code: 'SPLIT_IMPOSSIBLE',
        message:
            'This order has only single units, so it cannot be split into two '
            'non-empty bills. Add a quantity or choose another order.',
      );
    }

    return [SplitBill(lines: first), SplitBill(lines: second)];
  }

  Future<void> _ensureIdle() async {
    if (_busy) {
      throw const TableOrdersException(
        code: 'BUSY',
        message: 'Another table-order change is still being applied.',
      );
    }
  }
}
