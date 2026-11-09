import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// Small durable recovery queue for print jobs and in-flight references.
/// Offline sale reconciliation remains out of scope until Phase 2.
class RecoveryJobs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get reference => text().unique()();
  TextColumn get payload => text().withDefault(const Constant('{}'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Unsent cashier cart lines. Persisting these keeps work safe across catalog
/// refreshes, app restarts and an expired mobile session. Checkout and server
/// reconciliation belong to #12.
class CartEntries extends Table {
  TextColumn get menuId => text()();
  TextColumn get variantId => text()();
  TextColumn get itemName => text()();
  TextColumn get variantName => text()();
  IntColumn get unitPriceMinor => integer()();
  IntColumn get quantity => integer().withDefault(const Constant(1))();
  TextColumn get currency => text().withDefault(const Constant('IDR'))();
  IntColumn get currencyExponent => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {menuId, variantId};
}

/// Durable checkout intent written before the finalize request leaves the
/// device. The server key is `(outletId, deviceId, idempotencyKey)`; retaining
/// the exact payload lets a restart resolve the unknown outcome with the same
/// key instead of starting a second sale.
class CheckoutIntents extends Table {
  TextColumn get idempotencyKey => text()();
  TextColumn get deviceId => text()();
  TextColumn get outletId => text()();
  TextColumn get orderId => text()();
  TextColumn get quoteId => text()();
  TextColumn get paymentJson => text()();
  IntColumn get totalMinor => integer()();
  TextColumn get currency => text()();
  IntColumn get currencyExponent => integer()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  TextColumn get saleReference => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {idempotencyKey};
}

@DriftDatabase(tables: [RecoveryJobs, CartEntries, CheckoutIntents])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async => m.createAll(),
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.createTable(cartEntries);
        }
        if (from < 3) {
          await m.createTable(checkoutIntents);
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(p.join(directory.path, 'modern_pos.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
