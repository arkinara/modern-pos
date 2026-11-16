import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modern_pos_api_client/api.dart';

import '../../core/database/app_database.dart';
import '../../core/providers.dart';
import '../offline/offline_crypto.dart';
import '../offline/offline_sale_store.dart';
import 'catalog_models.dart';

/// Catalog data plus the time it was read from the server. The snapshot is
/// scoped to one user and outlet and is never shown as fresh.
class CachedCatalogSnapshot {
  const CachedCatalogSnapshot({
    required this.snapshot,
    required this.fetchedAt,
  });

  final CatalogSnapshot snapshot;
  final DateTime fetchedAt;
}

abstract interface class CatalogSnapshotStore {
  Future<CachedCatalogSnapshot?> load({
    required String userId,
    required String outletId,
  });

  Future<void> save({
    required String userId,
    required String outletId,
    required CatalogSnapshot snapshot,
    DateTime? fetchedAt,
  });

  Future<void> clear();
}

/// AES-256-GCM snapshot storage in its own table. The plaintext catalog never
/// enters SQLite and a different user or outlet cannot read the row.
class DriftCatalogSnapshotStore implements CatalogSnapshotStore {
  DriftCatalogSnapshotStore(this._database, this._cipher);

  final AppDatabase _database;
  final OfflineCipher _cipher;

  @override
  Future<CachedCatalogSnapshot?> load({
    required String userId,
    required String outletId,
  }) async {
    final query = _database.select(_database.offlineCatalogSnapshots)
      ..where(
        (table) =>
            table.userId.equals(userId) & table.outletId.equals(outletId),
      );
    final row = await query.getSingleOrNull();
    if (row == null) {
      return null;
    }
    final decoded = await _cipher.decryptJson(
      OfflineCipherEnvelope(
        ciphertext: row.payloadCipher,
        nonce: row.payloadNonce,
        mac: row.payloadMac,
        keyVersion: row.keyVersion,
        plaintextSha256: row.payloadDigest,
      ),
    );
    final snapshot = _decode(decoded);
    if (snapshot == null) {
      throw const OfflineDecryptionException('catalog snapshot is invalid');
    }
    return CachedCatalogSnapshot(snapshot: snapshot, fetchedAt: row.fetchedAt);
  }

  @override
  Future<void> save({
    required String userId,
    required String outletId,
    required CatalogSnapshot snapshot,
    DateTime? fetchedAt,
  }) async {
    final envelope = await _cipher.encryptJson(_encode(snapshot));
    await _database
        .into(_database.offlineCatalogSnapshots)
        .insertOnConflictUpdate(
          OfflineCatalogSnapshotsCompanion.insert(
            userId: userId,
            outletId: outletId,
            payloadCipher: envelope.ciphertext,
            payloadNonce: envelope.nonce,
            payloadMac: envelope.mac,
            keyVersion: Value(envelope.keyVersion),
            payloadDigest: envelope.plaintextSha256,
            fetchedAt: fetchedAt ?? DateTime.now(),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  @override
  Future<void> clear() =>
      _database.delete(_database.offlineCatalogSnapshots).go();

  Map<String, dynamic> _encode(CatalogSnapshot snapshot) {
    return {
      'categories': [
        for (final category in snapshot.categories) category.toJson(),
      ],
      'menus': [
        for (final menu in snapshot.menus)
          {
            ...menu.toJson(),
            'variants': [for (final variant in menu.variants) variant.toJson()],
          },
      ],
      'currency': snapshot.currency,
      'currencyExponent': snapshot.currencyExponent,
    };
  }

  CatalogSnapshot? _decode(Map<String, dynamic> json) {
    final currency = json['currency'];
    final currencyExponent = json['currencyExponent'];
    if (currency is! String || currencyExponent is! int) {
      return null;
    }
    return CatalogSnapshot(
      categories: Category.listFromJson(json['categories']),
      menus: Menu.listFromJson(json['menus']),
      currency: currency,
      currencyExponent: currencyExponent,
    );
  }
}

final catalogSnapshotStoreProvider = Provider<CatalogSnapshotStore>((ref) {
  return DriftCatalogSnapshotStore(
    ref.watch(appDatabaseProvider),
    ref.watch(offlineCipherProvider),
  );
});
