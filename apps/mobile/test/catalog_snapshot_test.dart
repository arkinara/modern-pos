import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modern_pos_mobile/core/database/app_database.dart';
import 'package:modern_pos_mobile/features/catalog/catalog_snapshot_store.dart';
import 'package:modern_pos_mobile/features/offline/offline_crypto.dart';
import 'package:path/path.dart' as p;

import 'support/fakes.dart';
import 'support/offline_fakes.dart';

const _marker = 'PLAINTEXT_CATALOG_MARKER_123456';

void main() {
  late Directory temp;
  late String databasePath;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('catalog_snapshot_test');
    databasePath = p.join(temp.path, 'snapshot.sqlite');
  });

  tearDown(() async {
    await temp.delete(recursive: true);
  });

  test('scoped snapshot survives restart without plaintext and never crosses owners', () async {
    final secrets = InMemoryOfflineSecretStore();
    final firstDb = AppDatabase.forTesting(NativeDatabase(File(databasePath)));
    final firstStore = DriftCatalogSnapshotStore(
      firstDb,
      OfflineCipher(secrets),
    );
    final fetchedAt = DateTime.utc(2026, 11, 15, 7, 30);

    await firstStore.save(
      userId: 'user-a',
      outletId: 'outlet-1',
      snapshot: testSnapshot(
        menus: [
          testMenu(
            id: 'secret-item',
            name: 'Secret Latte $_marker',
            categoryId: 'drinks',
            variants: [testVariant(id: 'secret-default', priceMinor: 12345)],
          ),
        ],
      ),
      fetchedAt: fetchedAt,
    );

    final key = secrets.key;
    expect(key, isNotNull);
    final rawRows = await firstDb
        .customSelect('SELECT * FROM offline_catalog_snapshots')
        .get();
    expect(rawRows, hasLength(1));
    for (final value in rawRows.single.data.values) {
      if (value is String) {
        expect(value, isNot(contains(_marker)));
        expect(value, isNot(contains(key!)));
      }
    }

    await firstDb.close();

    final secondDb = AppDatabase.forTesting(NativeDatabase(File(databasePath)));
    addTearDown(secondDb.close);
    final secondStore = DriftCatalogSnapshotStore(
      secondDb,
      OfflineCipher(secrets),
    );

    final restored = await secondStore.load(
      userId: 'user-a',
      outletId: 'outlet-1',
    );
    expect(restored, isNotNull);
    expect(
      restored!.fetchedAt.millisecondsSinceEpoch,
      fetchedAt.millisecondsSinceEpoch,
    );
    expect(restored.snapshot.menus.single.name, contains(_marker));
    expect(restored.snapshot.menus.single.variants.single.priceMinor, 12345);

    expect(
      await secondStore.load(userId: 'user-b', outletId: 'outlet-1'),
      isNull,
    );
    expect(
      await secondStore.load(userId: 'user-a', outletId: 'outlet-2'),
      isNull,
    );

    await secondStore.clear();
    expect(
      await secondStore.load(userId: 'user-a', outletId: 'outlet-1'),
      isNull,
    );
  });
}
