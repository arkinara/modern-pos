import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/providers.dart';
import '../checkout/checkout_models.dart';
import 'offline_crypto.dart';
import 'offline_sale_models.dart';

/// Encrypted durable queue used by both checkout recovery and offline sync.
///
/// The only plaintext columns are the idempotency key, state, counters and
/// timestamps needed for indexing. The sale payload is always decrypted before
/// use and never reconstructed from a plaintext fallback.
abstract interface class OfflineSaleStore {
  Future<OfflineSaleRecord?> loadById(String idempotencyKey);

  Future<OfflineSaleRecord?> loadLatestActive();

  Future<List<OfflineSaleRecord>> loadAll();

  Future<bool> upsert(
    OfflineSalePayload payload, {
    OfflineSaleState state = OfflineSaleState.pending,
    String? saleReference,
    String? lastError,
    DateTime? nextAttemptAt,
  });

  Future<void> replacePayload(OfflineSalePayload payload);

  Future<bool> claim(String idempotencyKey, DateTime now);

  Future<void> requeue(String idempotencyKey, DateTime now);

  Future<void> markSynced(String idempotencyKey, String saleReference);

  Future<void> markPending(
    String idempotencyKey,
    String message,
    DateTime nextAttemptAt,
  );

  Future<void> markUncertain(
    String idempotencyKey,
    String message,
    DateTime nextAttemptAt,
  );

  Future<void> markConflict(String idempotencyKey, String reason);

  Future<void> markFailed(String idempotencyKey, String reason);

  Future<void> delete(String idempotencyKey);
}

class DriftOfflineSaleStore implements OfflineSaleStore {
  DriftOfflineSaleStore(this._database, this._cipher);

  final AppDatabase _database;
  final OfflineCipher _cipher;

  @override
  Future<OfflineSaleRecord?> loadById(String idempotencyKey) async {
    final query = _database.select(_database.checkoutIntents)
      ..where((table) => table.idempotencyKey.equals(idempotencyKey));
    final row = await query.getSingleOrNull();
    return row == null ? null : await _decode(row);
  }

  @override
  Future<OfflineSaleRecord?> loadLatestActive() async {
    final query = _database.select(_database.checkoutIntents)
      ..where(
        (table) => table.syncState.isIn([
          OfflineSaleState.pending.name,
          OfflineSaleState.inFlight.name,
          OfflineSaleState.uncertain.name,
          OfflineSaleState.conflict.name,
        ]),
      )
      ..orderBy([(table) => OrderingTerm.desc(table.createdAt)])
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row == null ? null : await _decode(row);
  }

  @override
  Future<List<OfflineSaleRecord>> loadAll() async {
    final query = _database.select(_database.checkoutIntents)
      ..orderBy([(table) => OrderingTerm.desc(table.createdAt)]);
    final rows = await query.get();
    return [for (final row in rows) await _decode(row)];
  }

  @override
  Future<bool> upsert(
    OfflineSalePayload payload, {
    OfflineSaleState state = OfflineSaleState.pending,
    String? saleReference,
    String? lastError,
    DateTime? nextAttemptAt,
  }) async {
    final existing = await loadById(payload.idempotencyKey);
    if (existing != null && existing.state == OfflineSaleState.synced) {
      return false;
    }
    final envelope = await _cipher.encryptJson(payload.toJson());
    await _database
        .into(_database.checkoutIntents)
        .insertOnConflictUpdate(
          CheckoutIntentsCompanion.insert(
            idempotencyKey: payload.idempotencyKey,
            deviceId: '',
            outletId: '',
            orderId: '',
            quoteId: '',
            paymentJson: '{}',
            totalMinor: 0,
            currency: '',
            currencyExponent: 0,
            status: Value(_statusFor(state)),
            saleReference: Value(saleReference),
            syncState: Value(state.name),
            payloadCipher: Value(envelope.ciphertext),
            payloadNonce: Value(envelope.nonce),
            payloadMac: Value(envelope.mac),
            keyVersion: Value(envelope.keyVersion),
            payloadDigest: Value(envelope.plaintextSha256),
            attempts: const Value(0),
            nextAttemptAt: Value(nextAttemptAt),
            lastError: Value(lastError),
            createdAt: payload.createdAt,
            updatedAt: DateTime.now(),
          ),
        );
    return true;
  }

  @override
  Future<void> replacePayload(OfflineSalePayload payload) async {
    final envelope = await _cipher.encryptJson(payload.toJson());
    await (_database.update(_database.checkoutIntents)..where(
          (table) => table.idempotencyKey.equals(payload.idempotencyKey),
        ))
        .write(
          CheckoutIntentsCompanion(
            payloadCipher: Value(envelope.ciphertext),
            payloadNonce: Value(envelope.nonce),
            payloadMac: Value(envelope.mac),
            keyVersion: Value(envelope.keyVersion),
            payloadDigest: Value(envelope.plaintextSha256),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  @override
  Future<bool> claim(String idempotencyKey, DateTime now) async {
    final updated =
        await (_database.update(_database.checkoutIntents)..where(
              (table) =>
                  table.idempotencyKey.equals(idempotencyKey) &
                  table.syncState.isIn([
                    OfflineSaleState.pending.name,
                    OfflineSaleState.uncertain.name,
                  ]) &
                  (table.nextAttemptAt.isNull() |
                      table.nextAttemptAt.isSmallerOrEqualValue(now)),
            ))
            .write(
              CheckoutIntentsCompanion(
                syncState: Value(OfflineSaleState.inFlight.name),
                updatedAt: Value(now),
                attempts: const Value.absent(),
              ),
            );
    if (updated != 1) {
      return false;
    }
    await (_database.update(
      _database.checkoutIntents,
    )..where((table) => table.idempotencyKey.equals(idempotencyKey))).write(
      CheckoutIntentsCompanion(
        attempts: Value((await _attempts(idempotencyKey)) + 1),
      ),
    );
    return true;
  }

  @override
  Future<void> requeue(String idempotencyKey, DateTime now) async {
    await _transition(
      idempotencyKey,
      OfflineSaleState.pending,
      nextAttemptAt: now,
      clearError: true,
    );
  }

  @override
  Future<void> markSynced(String idempotencyKey, String saleReference) async {
    await _transition(
      idempotencyKey,
      OfflineSaleState.synced,
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
    await _transition(
      idempotencyKey,
      OfflineSaleState.pending,
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
    await _transition(
      idempotencyKey,
      OfflineSaleState.uncertain,
      lastError: message,
      nextAttemptAt: nextAttemptAt,
    );
  }

  @override
  Future<void> markConflict(String idempotencyKey, String reason) async {
    await _transition(
      idempotencyKey,
      OfflineSaleState.conflict,
      lastError: reason,
    );
  }

  @override
  Future<void> markFailed(String idempotencyKey, String reason) async {
    await _transition(
      idempotencyKey,
      OfflineSaleState.failed,
      lastError: reason,
    );
  }

  @override
  Future<void> delete(String idempotencyKey) async {
    await (_database.delete(
      _database.checkoutIntents,
    )..where((table) => table.idempotencyKey.equals(idempotencyKey))).go();
  }

  Future<void> _transition(
    String idempotencyKey,
    OfflineSaleState state, {
    String? saleReference,
    String? lastError,
    DateTime? nextAttemptAt,
    bool clearError = false,
  }) async {
    await (_database.update(
      _database.checkoutIntents,
    )..where((table) => table.idempotencyKey.equals(idempotencyKey))).write(
      CheckoutIntentsCompanion(
        syncState: Value(state.name),
        status: Value(_statusFor(state)),
        saleReference: saleReference == null
            ? const Value.absent()
            : Value(saleReference),
        lastError: clearError
            ? const Value(null)
            : (lastError == null ? const Value.absent() : Value(lastError)),
        nextAttemptAt: nextAttemptAt == null
            ? const Value.absent()
            : Value(nextAttemptAt),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  String _statusFor(OfflineSaleState state) {
    return switch (state) {
      OfflineSaleState.synced => PendingCheckoutStatus.confirmed.name,
      OfflineSaleState.failed => PendingCheckoutStatus.failed.name,
      _ => PendingCheckoutStatus.pending.name,
    };
  }

  Future<int> _attempts(String idempotencyKey) async {
    final query = _database.select(_database.checkoutIntents)
      ..where((table) => table.idempotencyKey.equals(idempotencyKey));
    final row = await query.getSingleOrNull();
    return row?.attempts ?? 0;
  }

  Future<OfflineSaleRecord> _decode(CheckoutIntent row) async {
    final cipher = row.payloadCipher;
    final payload = cipher == null || cipher.isEmpty
        ? _legacyPayload(row)
        : await _decrypt(row, cipher);
    return OfflineSaleRecord(
      payload: payload,
      state: OfflineSaleState.fromWire(row.syncState),
      attempts: row.attempts,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      nextAttemptAt: row.nextAttemptAt,
      lastError: row.lastError,
      saleReference: row.saleReference,
    );
  }

  Future<OfflineSalePayload> _decrypt(CheckoutIntent row, String cipher) async {
    final nonce = row.payloadNonce;
    final mac = row.payloadMac;
    final digest = row.payloadDigest;
    if (nonce == null || mac == null || digest == null) {
      throw const OfflineDecryptionException(
        'encrypted row is missing nonce, MAC or digest',
      );
    }
    final decoded = await _cipher.decryptJson(
      OfflineCipherEnvelope(
        ciphertext: cipher,
        nonce: nonce,
        mac: mac,
        keyVersion: row.keyVersion,
        plaintextSha256: digest,
      ),
    );
    final payload = OfflineSalePayload.fromJson(decoded);
    if (payload == null) {
      throw const OfflineDecryptionException('decrypted payload is invalid');
    }
    return payload;
  }

  OfflineSalePayload _legacyPayload(CheckoutIntent row) {
    if (row.paymentJson.trim().isEmpty || row.paymentJson == '{}') {
      throw const OfflineDecryptionException(
        'encrypted row has no ciphertext and no legacy payload',
      );
    }
    final payment = PaymentDraft.fromJson(
      jsonDecode(row.paymentJson) as Map<String, dynamic>?,
    );
    if (payment == null) {
      throw const OfflineDecryptionException(
        'legacy payment payload is invalid',
      );
    }
    return OfflineSalePayload(
      idempotencyKey: row.idempotencyKey,
      orderKey: row.idempotencyKey,
      outletId: row.outletId,
      deviceId: row.deviceId,
      lines: const [],
      tenderKind: payment.kind,
      amountMinor: payment.amountMinor,
      tenderedMinor: payment.tenderedMinor ?? payment.amountMinor,
      reference: payment.reference,
      totalMinor: row.totalMinor,
      currency: row.currency,
      currencyExponent: row.currencyExponent,
      createdAt: row.createdAt,
      orderId: row.orderId.isEmpty ? null : row.orderId,
      quoteId: row.quoteId.isEmpty ? null : row.quoteId,
    );
  }
}

class OfflineCryptoProviderNotConfiguredException implements Exception {
  const OfflineCryptoProviderNotConfiguredException();
}

final offlineSecretStoreProvider = Provider<OfflineSecretStore>((ref) {
  return SecureOfflineSecretStore(ref.watch(secureStorageProvider));
});

final offlineCipherProvider = Provider<OfflineCipher>((ref) {
  return OfflineCipher(ref.watch(offlineSecretStoreProvider));
});

final offlineSaleStoreProvider = Provider<OfflineSaleStore>((ref) {
  return DriftOfflineSaleStore(
    ref.watch(appDatabaseProvider),
    ref.watch(offlineCipherProvider),
  );
});
