import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';
import 'cart_line.dart';

/// Durable cart storage boundary. Drift is the production implementation;
/// tests may substitute an in-memory queue.
abstract interface class CartRepository {
  Future<List<CartLine>> load();

  Future<void> save(CartLine line);

  Future<void> delete(String menuId, String variantId);

  Future<void> clear();
}

class DriftCartRepository implements CartRepository {
  DriftCartRepository(this._database);

  final AppDatabase _database;

  @override
  Future<List<CartLine>> load() async {
    final query = _database.select(_database.cartEntries)
      ..orderBy([
        (table) => OrderingTerm.asc(table.updatedAt),
        (table) => OrderingTerm.asc(table.menuId),
      ]);
    final rows = await query.get();
    return rows.map(_toLine).toList(growable: false);
  }

  @override
  Future<void> save(CartLine line) async {
    await _database
        .into(_database.cartEntries)
        .insertOnConflictUpdate(
          CartEntriesCompanion.insert(
            menuId: line.menuId,
            variantId: line.variantId,
            itemName: line.itemName,
            variantName: line.variantName,
            unitPriceMinor: line.unitPriceMinor,
            quantity: Value(line.quantity),
            currency: Value(line.currency),
            currencyExponent: Value(line.currencyExponent),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  @override
  Future<void> delete(String menuId, String variantId) async {
    await (_database.delete(_database.cartEntries)..where(
          (table) =>
              table.menuId.equals(menuId) & table.variantId.equals(variantId),
        ))
        .go();
  }

  @override
  Future<void> clear() async {
    await _database.delete(_database.cartEntries).go();
  }

  CartLine _toLine(CartEntry row) {
    return CartLine(
      menuId: row.menuId,
      variantId: row.variantId,
      itemName: row.itemName,
      variantName: row.variantName,
      unitPriceMinor: row.unitPriceMinor,
      quantity: row.quantity,
      currency: row.currency,
      currencyExponent: row.currencyExponent,
    );
  }
}
