import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/providers.dart';
import 'checkout_models.dart';

/// Durable checkout intent storage. The pending row is the proof that a key
/// left the device and must be resolved before another sale starts.
abstract interface class CheckoutRepository {
  Future<PendingCheckout?> loadPending();

  Future<PendingCheckout?> loadByKey(String idempotencyKey);

  Future<void> savePending(PendingCheckout pending);

  Future<void> markConfirmed(String idempotencyKey, String saleReference);

  Future<void> markFailed(String idempotencyKey);

  Future<void> delete(String idempotencyKey);
}

class DriftCheckoutRepository implements CheckoutRepository {
  DriftCheckoutRepository(this._database);

  final AppDatabase _database;

  @override
  Future<PendingCheckout?> loadPending() async {
    final query = _database.select(_database.checkoutIntents)
      ..where(
        (table) => table.status.equals(PendingCheckoutStatus.pending.name),
      )
      ..orderBy([(table) => OrderingTerm.desc(table.createdAt)])
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row == null ? null : _toPending(row);
  }

  @override
  Future<PendingCheckout?> loadByKey(String idempotencyKey) async {
    final query = _database.select(_database.checkoutIntents)
      ..where((table) => table.idempotencyKey.equals(idempotencyKey));
    final row = await query.getSingleOrNull();
    return row == null ? null : _toPending(row);
  }

  @override
  Future<void> savePending(PendingCheckout pending) async {
    await _database
        .into(_database.checkoutIntents)
        .insertOnConflictUpdate(
          CheckoutIntentsCompanion.insert(
            idempotencyKey: pending.idempotencyKey,
            deviceId: pending.deviceId,
            outletId: pending.outletId,
            orderId: pending.orderId,
            quoteId: pending.quoteId,
            paymentJson: jsonEncode(pending.payment.toJson()),
            totalMinor: pending.totalMinor,
            currency: pending.currency,
            currencyExponent: pending.currencyExponent,
            status: Value(pending.status.name),
            saleReference: Value(pending.saleReference),
            createdAt: pending.createdAt,
            updatedAt: DateTime.now(),
          ),
        );
  }

  @override
  Future<void> markConfirmed(
    String idempotencyKey,
    String saleReference,
  ) async {
    await (_database.update(
      _database.checkoutIntents,
    )..where((table) => table.idempotencyKey.equals(idempotencyKey))).write(
      CheckoutIntentsCompanion(
        status: Value(PendingCheckoutStatus.confirmed.name),
        saleReference: Value(saleReference),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> markFailed(String idempotencyKey) async {
    await (_database.update(
      _database.checkoutIntents,
    )..where((table) => table.idempotencyKey.equals(idempotencyKey))).write(
      CheckoutIntentsCompanion(
        status: Value(PendingCheckoutStatus.failed.name),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> delete(String idempotencyKey) async {
    await (_database.delete(
      _database.checkoutIntents,
    )..where((table) => table.idempotencyKey.equals(idempotencyKey))).go();
  }

  PendingCheckout _toPending(CheckoutIntent row) {
    return PendingCheckout(
      idempotencyKey: row.idempotencyKey,
      deviceId: row.deviceId,
      outletId: row.outletId,
      orderId: row.orderId,
      quoteId: row.quoteId,
      payment:
          PaymentDraft.fromJson(
            jsonDecode(row.paymentJson) as Map<String, dynamic>?,
          ) ??
          const PaymentDraft(
            kind: TenderKind.cash,
            amountMinor: 0,
            tenderedMinor: 0,
          ),
      totalMinor: row.totalMinor,
      currency: row.currency,
      currencyExponent: row.currencyExponent,
      createdAt: row.createdAt,
      status: PendingCheckoutStatus.values.firstWhere(
        (value) => value.name == row.status,
        orElse: () => PendingCheckoutStatus.pending,
      ),
      saleReference: row.saleReference,
    );
  }
}

final checkoutRepositoryProvider = Provider<CheckoutRepository>((ref) {
  return DriftCheckoutRepository(ref.watch(appDatabaseProvider));
});
