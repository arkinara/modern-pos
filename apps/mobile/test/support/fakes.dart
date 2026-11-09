import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modern_pos_api_client/api.dart';
import 'package:modern_pos_mobile/features/auth/auth_controller.dart';
import 'package:modern_pos_mobile/features/cart/cart_line.dart';
import 'package:modern_pos_mobile/features/cart/cart_repository.dart';
import 'package:modern_pos_mobile/features/catalog/catalog_models.dart';
import 'package:modern_pos_mobile/features/catalog/catalog_repository.dart';

AuthSession testSession({String outletId = 'outlet-1'}) {
  return AuthSession(
    accessToken: 'test-access-token',
    user: User(
      id: 'user-1',
      email: 'cashier@example.test',
      role: UserRoleEnum.CASHIER,
      outletIds: [outletId],
    ),
  );
}

Category testCategory({
  required String id,
  required String name,
  bool archived = false,
}) {
  return Category(id: id, name: name, version: 1, archived: archived);
}

Variant testVariant({
  required String id,
  String name = 'Default',
  required int priceMinor,
  bool enabled = true,
  int? availableUnits,
  VariantStockPolicyEnum stockPolicy = VariantStockPolicyEnum.UNTRACKED,
}) {
  return Variant(
    id: id,
    name: name,
    priceMinor: priceMinor,
    stockPolicy: stockPolicy,
    revision: 1,
    enabled: enabled,
    availableUnits: availableUnits,
  );
}

Menu testMenu({
  required String id,
  required String name,
  required String categoryId,
  String description = '',
  bool archived = false,
  List<Variant>? variants,
}) {
  return Menu(
    id: id,
    name: name,
    description: description,
    categoryId: categoryId,
    revision: 1,
    archived: archived,
    variants: variants ?? [testVariant(id: '$id-default', priceMinor: 10000)],
  );
}

CatalogSnapshot testSnapshot({
  List<Category>? categories,
  List<Menu>? menus,
  String currency = 'IDR',
  int currencyExponent = 0,
}) {
  return CatalogSnapshot(
    categories: categories ?? [testCategory(id: 'drinks', name: 'Drinks')],
    menus: menus ?? const [],
    currency: currency,
    currencyExponent: currencyExponent,
  );
}

class FakeCatalogRepository implements CatalogRepository {
  FakeCatalogRepository(this.snapshot);

  CatalogSnapshot snapshot;
  Object? failure;
  int loadCount = 0;

  @override
  Future<CatalogSnapshot> load(String outletId) async {
    loadCount++;
    final error = failure;
    if (error != null) {
      throw error;
    }
    return snapshot;
  }
}

class InMemoryCartRepository implements CartRepository {
  final Map<String, CartLine> _lines = {};

  int get length => _lines.length;

  @override
  Future<void> clear() async => _lines.clear();

  @override
  Future<void> delete(String menuId, String variantId) async {
    _lines.remove('$menuId::$variantId');
  }

  @override
  Future<List<CartLine>> load() async =>
      List.unmodifiable(_lines.values.toList(growable: false));

  @override
  Future<void> save(CartLine line) async {
    _lines[line.key] = line;
  }
}

class FakeAuthController extends AuthController {
  FakeAuthController(this.session);

  AuthSession? session;

  @override
  Future<AuthSession?> build() async => session;

  void expire() {
    session = null;
    state = const AsyncData(null);
  }

  void restore(AuthSession next) {
    session = next;
    state = AsyncData(next);
  }
}
