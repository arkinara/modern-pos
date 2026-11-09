import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../auth/auth_controller.dart';
import 'catalog_models.dart';
import 'catalog_repository.dart';

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  final session = ref.watch(authControllerProvider).value;
  if (session == null) {
    throw StateError('Catalog requires an authenticated session');
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

  Future<CatalogSnapshot> _load() {
    final session = ref.watch(authControllerProvider).value;
    if (session == null || session.user.outletIds.isEmpty) {
      throw StateError('No outlet is assigned to this session');
    }
    final repository = ref.watch(catalogRepositoryProvider);
    return repository.load(session.user.outletIds.first);
  }
}
