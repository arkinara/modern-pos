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

@DriftDatabase(tables: [RecoveryJobs, CartEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async => m.createAll(),
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.createTable(cartEntries);
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
