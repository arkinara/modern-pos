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

/// Durable checkout and offline-sale queue. The exact payload is encrypted
/// with AES-256-GCM before the row is written; `payloadCipher`, `payloadNonce`
/// and `payloadMac` are base64 envelopes. The legacy metadata columns are kept
/// for schema compatibility but are deliberately blank for encrypted rows.
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
  TextColumn get syncState => text().withDefault(const Constant('pending'))();
  TextColumn get payloadCipher => text().nullable()();
  TextColumn get payloadNonce => text().nullable()();
  TextColumn get payloadMac => text().nullable()();
  TextColumn get keyVersion => text().withDefault(const Constant('v1'))();
  TextColumn get payloadDigest => text().nullable()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextAttemptAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {idempotencyKey};
}

/// Durable receipt print queue. The row is written before any bytes are sent so
/// a crash or disconnect cannot lose the sale's print request. `state` uses
/// `PrintJobState` wire names.
class PrintQueueJobs extends Table {
  TextColumn get id => text()();
  TextColumn get saleId => text()();
  TextColumn get saleReference => text()();
  TextColumn get outletId => text()();
  TextColumn get deviceId => text()();
  TextColumn get printerConfigId => text().nullable()();
  TextColumn get printerConfigJson => text().nullable()();
  TextColumn get receiptJson => text()();
  TextColumn get state => text().withDefault(const Constant('queued'))();
  BoolColumn get copy => boolean().withDefault(const Constant(false))();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  BoolColumn get serverMirrored =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Local audit trail for print attempts and deliberate COPY reprints. The
/// mirrored API record is diagnostic; this table is the device-owned evidence.
class PrintQueueAudits extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get jobId => text()();
  TextColumn get saleId => text()();
  TextColumn get action => text()();
  TextColumn get actorId => text()();
  TextColumn get actorEmail => text()();
  BoolColumn get copy => boolean().withDefault(const Constant(false))();
  TextColumn get detail => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(
  tables: [
    RecoveryJobs,
    CartEntries,
    CheckoutIntents,
    PrintQueueJobs,
    PrintQueueAudits,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 5;

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
        if (from < 4) {
          await m.createTable(printQueueJobs);
          await m.createTable(printQueueAudits);
        }
        if (from < 5) {
          await m.addColumn(checkoutIntents, checkoutIntents.syncState);
          await m.addColumn(checkoutIntents, checkoutIntents.payloadCipher);
          await m.addColumn(checkoutIntents, checkoutIntents.payloadNonce);
          await m.addColumn(checkoutIntents, checkoutIntents.payloadMac);
          await m.addColumn(checkoutIntents, checkoutIntents.keyVersion);
          await m.addColumn(checkoutIntents, checkoutIntents.payloadDigest);
          await m.addColumn(checkoutIntents, checkoutIntents.attempts);
          await m.addColumn(checkoutIntents, checkoutIntents.nextAttemptAt);
          await m.addColumn(checkoutIntents, checkoutIntents.lastError);
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
