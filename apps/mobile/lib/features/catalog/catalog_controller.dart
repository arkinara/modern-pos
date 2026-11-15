import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../auth/auth_controller.dart';
import 'catalog_models.dart';
import 'catalog_repository.dart';
import 'catalog_snapshot_store.dart';

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  final session = ref.watch(authControllerProvider).value;
  if (session == null || session.offline) {
    throw StateError('Catalog requires an online authenticated session');
  }
  return HttpCatalogRepository(ref.watch(dioProvider), session.accessToken);
});

final catalogControllerProvider =
    AsyncNotifierProvider.autoDispose<CatalogController, CatalogSnapshot>(
      CatalogController.new,
    );

class CatalogController extends AsyncNotifier<CatalogSnapshot> {
  @override
  Future<CatalogSnapshot> build() {
    return _load();
  }

  /// Re-reads the catalog. Called by pull-to-refresh and the explicit retry
  /// actions. Unsent cart lines live in Drift and are never touched here.
  Future<void> refresh() async {
    state = await AsyncValue.guard(_load);
  }

  Future<CatalogSnapshot> _load() async {
    final session = ref.watch(authControllerProvider).value;
    if (session == null || session.user.outletIds.isEmpty) {
      throw StateError('No outlet is assigned to this session');
    }
    final outletId = session.user.outletIds.first;
    final store = ref.watch(catalogSnapshotStoreProvider);

    if (session.offline) {
      final cached = await _readCache(store, session.user.id, outletId);
      if (cached == null) {
        throw StateError(
          'No saved menu is available on this device. Reconnect to load the '
          'menu before taking offline orders.',
        );
      }
      return cached;
    }

    final repository = ref.watch(catalogRepositoryProvider);
    try {
      final snapshot = await repository.load(outletId);
      final fetchedAt = DateTime.now();
      try {
        await store.save(
          userId: session.user.id,
          outletId: outletId,
          snapshot: snapshot,
          fetchedAt: fetchedAt,
        );
      } catch (_) {
        // A cache write failure must not hide a successful online read.
      }
      return snapshot.copyWith(fetchedAt: fetchedAt, fromCache: false);
    } on DioException catch (error) {
      if (!_canUseCache(error)) {
        rethrow;
      }
      final cached = await _readCache(store, session.user.id, outletId);
      if (cached == null) {
        rethrow;
      }
      return cached;
    }
  }

  bool _canUseCache(DioException error) {
    final status = error.response?.statusCode;
    return error.response == null || (status != null && status >= 500);
  }

  Future<CatalogSnapshot?> _readCache(
    CatalogSnapshotStore store,
    String userId,
    String outletId,
  ) async {
    try {
      final cached = await store.load(userId: userId, outletId: outletId);
      if (cached == null) {
        return null;
      }
      return cached.snapshot.copyWith(
        fetchedAt: cached.fetchedAt,
        fromCache: true,
      );
    } catch (_) {
      // A corrupt or unreadable snapshot is reported as absent, never as a
      // plaintext fallback.
      return null;
    }
  }
}
