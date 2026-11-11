import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modern_pos_mobile/core/database/app_database.dart';
import 'package:modern_pos_mobile/features/checkout/checkout_models.dart';
import 'package:modern_pos_mobile/features/offline/offline_crypto.dart';
import 'package:modern_pos_mobile/features/offline/offline_sale_models.dart';
import 'package:modern_pos_mobile/features/offline/offline_sale_store.dart';
import 'package:path/path.dart' as p;

import 'support/offline_fakes.dart';

const _marker = 'PLAINTEXT_SALE_MARKER_987654';

OfflineSalePayload payload({String key = 'key-1'}) {
  return OfflineSalePayload(
    idempotencyKey: key,
    orderKey: 'order-$key',
    outletId: 'outlet-1',
    deviceId: 'device-1',
    lines: const [
      OfflineSaleLine(
        variantId: 'variant-1',
        name: 'Secret Latte $_marker',
        variantName: 'Large',
        quantity: 2,
        unitPriceMinor: 25000,
      ),
    ],
    tenderKind: TenderKind.cash,
    amountMinor: 50000,
    tenderedMinor: 60000,
    reference: _marker,
    totalMinor: 50000,
    currency: 'IDR',
    currencyExponent: 0,
    createdAt: DateTime.utc(2026, 11, 11, 8),
  );
}

void main() {
  late Directory temp;
  late String databasePath;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('offline_repo_test');
    databasePath = p.join(temp.path, 'queue.sqlite');
  });

  tearDown(() async {
    await temp.delete(recursive: true);
  });

  test('pending sale survives a database restart, decrypts, and has no plaintext or key in storage', () async {
    final secrets = InMemoryOfflineSecretStore();
    final firstDb = AppDatabase.forTesting(NativeDatabase(File(databasePath)));
    final firstStore = DriftOfflineSaleStore(firstDb, OfflineCipher(secrets));

    await firstStore.upsert(payload());
    final key = secrets.key;
    expect(key, isNotNull);

    final rawRows = await firstDb
        .customSelect('SELECT * FROM checkout_intents')
        .get();
    expect(rawRows, hasLength(1));
    final row = rawRows.single.data;
    expect(row['payload_cipher'], isNotNull);
    expect(row['payload_nonce'], isNotNull);
    expect(row['payload_mac'], isNotNull);
    expect(row['payload_digest'], isNotNull);
    for (final value in row.values) {
      if (value is String) {
        expect(value, isNot(contains(_marker)));
        expect(value, isNot(contains(key!)));
      }
    }

    await firstDb.close();

    final secondDb = AppDatabase.forTesting(NativeDatabase(File(databasePath)));
    addTearDown(secondDb.close);
    final secondStore = DriftOfflineSaleStore(secondDb, OfflineCipher(secrets));
    final restored = await secondStore.loadById('key-1');

    expect(restored, isNotNull);
    expect(restored!.state, OfflineSaleState.pending);
    expect(restored.payload.reference, _marker);
    expect(restored.payload.lines.single.name, contains(_marker));
    expect(restored.payload.tenderedMinor, 60000);
    expect(restored.payload.totalMinor, 50000);
  });

  test(
    'corrupt ciphertext fails loud instead of returning plaintext',
    () async {
      final secrets = InMemoryOfflineSecretStore();
      final db = AppDatabase.forTesting(NativeDatabase(File(databasePath)));
      addTearDown(db.close);
      final store = DriftOfflineSaleStore(db, OfflineCipher(secrets));
      await store.upsert(payload());
      await db.customStatement(
        "UPDATE checkout_intents SET payload_mac = 'AAAA' "
        "WHERE idempotency_key = 'key-1'",
      );

      await expectLater(
        () => store.loadById('key-1'),
        throwsA(isA<OfflineDecryptionException>()),
      );
    },
  );

  test(
    'missing key fails loud and never decodes a plaintext fallback',
    () async {
      final secrets = InMemoryOfflineSecretStore();
      final db = AppDatabase.forTesting(NativeDatabase(File(databasePath)));
      final store = DriftOfflineSaleStore(db, OfflineCipher(secrets));
      await store.upsert(payload());
      await db.close();

      final reopened = AppDatabase.forTesting(
        NativeDatabase(File(databasePath)),
      );
      addTearDown(reopened.close);
      final withoutKey = DriftOfflineSaleStore(
        reopened,
        OfflineCipher(InMemoryOfflineSecretStore()),
      );

      await expectLater(
        () => withoutKey.loadById('key-1'),
        throwsA(isA<OfflineKeyMissingException>()),
      );
    },
  );
}
