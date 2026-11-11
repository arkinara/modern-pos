import 'package:modern_pos_mobile/features/offline/offline_crypto.dart';
import 'package:modern_pos_mobile/features/offline/offline_sale_models.dart';
import 'package:modern_pos_mobile/features/offline/offline_sale_store.dart';

class InMemoryOfflineSecretStore implements OfflineSecretStore {
  String? key;

  @override
  Future<String?> readKey() async => key;

  @override
  Future<void> writeKey(String base64Key) async {
    key = base64Key;
  }
}

class InMemoryOfflineSaleStore implements OfflineSaleStore {
  final Map<String, OfflineSaleRecord> rows = {};

  @override
  Future<OfflineSaleRecord?> loadById(String idempotencyKey) async =>
      rows[idempotencyKey];

  @override
  Future<OfflineSaleRecord?> loadLatestActive() async {
    final active = rows.values.where((record) => record.isActive).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return active.isEmpty ? null : active.first;
  }

  @override
  Future<List<OfflineSaleRecord>> loadAll() async {
    final values = rows.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return values;
  }

  @override
  Future<bool> upsert(
    OfflineSalePayload payload, {
    OfflineSaleState state = OfflineSaleState.pending,
    String? saleReference,
    String? lastError,
    DateTime? nextAttemptAt,
  }) async {
    final existing = rows[payload.idempotencyKey];
    if (existing != null && existing.state == OfflineSaleState.synced) {
      return false;
    }
    final now = DateTime.now();
    rows[payload.idempotencyKey] = OfflineSaleRecord(
      payload: payload,
      state: state,
      attempts: 0,
      createdAt: payload.createdAt,
      updatedAt: now,
      nextAttemptAt: nextAttemptAt,
      lastError: lastError,
      saleReference: saleReference,
    );
    return true;
  }

  @override
  Future<void> replacePayload(OfflineSalePayload payload) async {
    final row = rows[payload.idempotencyKey];
    if (row != null) {
      rows[payload.idempotencyKey] = row.copyWith(
        payload: payload,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<bool> claim(String idempotencyKey, DateTime now) async {
    final row = rows[idempotencyKey];
    if (row == null ||
        (row.state != OfflineSaleState.pending &&
            row.state != OfflineSaleState.uncertain)) {
      return false;
    }
    final due = row.nextAttemptAt;
    if (due != null && due.isAfter(now)) {
      return false;
    }
    rows[idempotencyKey] = row.copyWith(
      state: OfflineSaleState.inFlight,
      attempts: row.attempts + 1,
      updatedAt: now,
    );
    return true;
  }

  @override
  Future<void> requeue(String idempotencyKey, DateTime now) async {
    final row = rows[idempotencyKey];
    if (row != null) {
      rows[idempotencyKey] = OfflineSaleRecord(
        payload: row.payload,
        state: OfflineSaleState.pending,
        attempts: row.attempts,
        createdAt: row.createdAt,
        updatedAt: now,
        saleReference: row.saleReference,
      );
    }
  }

  @override
  Future<void> markSynced(String idempotencyKey, String saleReference) async {
    _set(
      idempotencyKey,
      state: OfflineSaleState.synced,
      saleReference: saleReference,
      clearError: true,
    );
  }

  @override
  Future<void> markPending(
    String idempotencyKey,
    String message,
    DateTime nextAttemptAt,
  ) async {
    _set(
      idempotencyKey,
      state: OfflineSaleState.pending,
      lastError: message,
      nextAttemptAt: nextAttemptAt,
    );
  }

  @override
  Future<void> markUncertain(
    String idempotencyKey,
    String message,
    DateTime nextAttemptAt,
  ) async {
    _set(
      idempotencyKey,
      state: OfflineSaleState.uncertain,
      lastError: message,
      nextAttemptAt: nextAttemptAt,
    );
  }

  @override
  Future<void> markConflict(String idempotencyKey, String reason) async {
    _set(idempotencyKey, state: OfflineSaleState.conflict, lastError: reason);
  }

  @override
  Future<void> markFailed(String idempotencyKey, String reason) async {
    _set(idempotencyKey, state: OfflineSaleState.failed, lastError: reason);
  }

  @override
  Future<void> delete(String idempotencyKey) async {
    rows.remove(idempotencyKey);
  }

  void _set(
    String idempotencyKey, {
    required OfflineSaleState state,
    String? saleReference,
    String? lastError,
    DateTime? nextAttemptAt,
    bool clearError = false,
  }) {
    final row = rows[idempotencyKey];
    if (row == null) {
      return;
    }
    rows[idempotencyKey] = OfflineSaleRecord(
      payload: row.payload,
      state: state,
      attempts: row.attempts,
      createdAt: row.createdAt,
      updatedAt: DateTime.now(),
      nextAttemptAt: nextAttemptAt,
      lastError: clearError ? null : (lastError ?? row.lastError),
      saleReference: saleReference ?? row.saleReference,
    );
  }
}
