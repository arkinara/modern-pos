// Live contract proof for the Android catalog refresh path.
// Run against a local API after seeding:
//   CATALOG_API_BASE_URL=http://localhost:4000 flutter test test/catalog_refresh_proof_test.dart
// The default test run skips this file because no API base URL is provided.
// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:modern_pos_api_client/api.dart';

const _ownerEmail = 'owner@example.test';
const _deviceId = '00000000-0000-4000-8000-000000000099';

void main() {
  final baseUrl = Platform.environment['CATALOG_API_BASE_URL'];

  test(
    'owner catalog changes appear through the Dart client after refresh',
    () async {
      final root = baseUrl;
      if (root == null) {
        return;
      }

      final apiClient = ApiClient(basePath: '$root/v1');
      final authApi = AuthApi(apiClient);
      final catalogApi = CatalogApi(apiClient);

      final password =
          Platform.environment['SEED_PASSWORD'] ?? 'modern-pos-demo-password';
      final session = await authApi.authMobileLogin(
        Login(email: _ownerEmail, password: password, deviceId: _deviceId),
      );
      expect(session, isNotNull);
      apiClient.addDefaultHeader(
        'Authorization',
        'Bearer ${session!.accessToken}',
      );

      final outletId = session.user.outletIds.first;
      final categories = await catalogApi.catalogCategories(outletId);
      expect(categories, isNotEmpty);
      final categoryId = categories!.first.id;

      final unique = 'Dart Refresh ${DateTime.now().millisecondsSinceEpoch}';
      final created = await catalogApi.catalogCreate(
        outletId,
        MenuWrite(
          name: unique,
          description: 'Contract refresh proof.',
          categoryId: categoryId,
          variants: [
            VariantWrite(
              name: 'Default',
              priceMinor: 10000,
              stockPolicy: VariantWriteStockPolicyEnum.UNTRACKED,
            ),
          ],
        ),
      );
      expect(created, isNotNull);
      print(
        'created ${created!.id} price=${created.variants.first.priceMinor}',
      );

      final firstPage = await catalogApi.catalogList(outletId, search: unique);
      final firstRead = firstPage!.items.firstWhere(
        (menu) => menu.id == created.id,
      );
      expect(firstRead.variants.first.priceMinor, 10000);
      print('read back price=${firstRead.variants.first.priceMinor}');

      final variant = firstRead.variants.first;
      final updated = await catalogApi.catalogUpdateVariant(
        outletId,
        variant.id,
        VariantUpdate(
          name: variant.name,
          priceMinor: 12500,
          stockPolicy: VariantUpdateStockPolicyEnum.TRACKED,
          enabled: true,
          revision: variant.revision,
        ),
      );
      expect(updated!.id, variant.id);
      expect(updated.priceMinor, 12500);
      expect(updated.availableUnits, 0);
      print(
        'updated variant=${updated.id} price=${updated.priceMinor} '
        'policy=${updated.stockPolicy} availableUnits=${updated.availableUnits}',
      );

      final refreshedPage = await catalogApi.catalogList(
        outletId,
        search: unique,
      );
      final refreshed = refreshedPage!.items.firstWhere(
        (menu) => menu.id == created.id,
      );
      expect(refreshed.variants.first.priceMinor, 12500);
      expect(
        refreshed.variants.first.stockPolicy,
        VariantStockPolicyEnum.TRACKED,
      );
      print(
        'refreshed price=${refreshed.variants.first.priceMinor} '
        'policy=${refreshed.variants.first.stockPolicy}',
      );

      await catalogApi.catalogArchive(
        outletId,
        created.id,
        CatalogArchiveRequest(revision: refreshed.revision),
      );

      final afterArchivePage = await catalogApi.catalogList(
        outletId,
        search: unique,
      );
      final archived = afterArchivePage!.items.firstWhere(
        (menu) => menu.id == created.id,
      );
      expect(archived.archived, isTrue);
      print('archived read-back archived=${archived.archived}');
    },
    skip: baseUrl == null
        ? 'Set CATALOG_API_BASE_URL to run the live catalog refresh proof.'
        : false,
  );
}
