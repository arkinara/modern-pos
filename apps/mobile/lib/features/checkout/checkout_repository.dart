import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../offline/offline_sale_models.dart';
import '../offline/offline_sale_store.dart';
import 'checkout_models.dart';

/// Durable checkout intent storage. The row is encrypted by [OfflineSaleStore]
/// before it reaches SQLite, so a pending sale survives restarts without
/// writing the payment or order payload in plaintext.
abstract interface class CheckoutRepository {
  Future<PendingCheckout?> loadPending();

  Future<PendingCheckout?> loadByKey(String idempotencyKey);

  Future<void> savePending(PendingCheckout pending);

  Future<void> markConfirmed(String idempotencyKey, String saleReference);

  Future<void> markFailed(String idempotencyKey);

  Future<void> delete(String idempotencyKey);
}

class DriftCheckoutRepository implements CheckoutRepository {
  DriftCheckoutRepository(this._store);

  final OfflineSaleStore _store;

  @override
  Future<PendingCheckout?> loadPending() async {
    final record = await _store.loadLatestActive();
    return record == null ? null : _toPending(record);
  }

  @override
  Future<PendingCheckout?> loadByKey(String idempotencyKey) async {
    final record = await _store.loadById(idempotencyKey);
    return record == null ? null : _toPending(record);
  }

  @override
  Future<void> savePending(PendingCheckout pending) async {
    await _store.upsert(
      OfflineSalePayload(
        idempotencyKey: pending.idempotencyKey,
        orderKey: pending.orderKey.isEmpty
            ? pending.idempotencyKey
            : pending.orderKey,
        outletId: pending.outletId,
        deviceId: pending.deviceId,
        lines: const [],
        tenderKind: pending.payment.kind,
        amountMinor: pending.payment.amountMinor,
        tenderedMinor: pending.payment.tenderedMinor ?? pending.totalMinor,
        reference: pending.payment.reference,
        totalMinor: pending.totalMinor,
        currency: pending.currency,
        currencyExponent: pending.currencyExponent,
        createdAt: pending.createdAt,
        orderId: pending.orderId,
        quoteId: pending.quoteId,
        orderVersion: pending.orderVersion,
      ),
      saleReference: pending.saleReference,
    );
  }

  @override
  Future<void> markConfirmed(
    String idempotencyKey,
    String saleReference,
  ) async {
    await _store.markSynced(idempotencyKey, saleReference);
  }

  @override
  Future<void> markFailed(String idempotencyKey) async {
    await _store.markFailed(
      idempotencyKey,
      'The server did not record this checkout after recovery.',
    );
  }

  @override
  Future<void> delete(String idempotencyKey) async {
    await _store.delete(idempotencyKey);
  }

  PendingCheckout _toPending(OfflineSaleRecord record) {
    final payload = record.payload;
    final state = switch (record.state) {
      OfflineSaleState.synced => PendingCheckoutStatus.confirmed,
      OfflineSaleState.failed => PendingCheckoutStatus.failed,
      _ => PendingCheckoutStatus.pending,
    };
    return PendingCheckout(
      idempotencyKey: payload.idempotencyKey,
      deviceId: payload.deviceId,
      outletId: payload.outletId,
      orderId: payload.orderId ?? '',
      quoteId: payload.quoteId ?? '',
      payment: PaymentDraft(
        kind: payload.tenderKind,
        amountMinor: payload.amountMinor,
        tenderedMinor: payload.tenderedMinor,
        reference: payload.reference,
      ),
      totalMinor: payload.totalMinor,
      currency: payload.currency,
      currencyExponent: payload.currencyExponent,
      createdAt: payload.createdAt,
      status: state,
      saleReference: record.saleReference,
      orderKey: payload.orderKey,
      orderVersion: payload.orderVersion,
    );
  }
}

final checkoutRepositoryProvider = Provider<CheckoutRepository>((ref) {
  return DriftCheckoutRepository(ref.watch(offlineSaleStoreProvider));
});
