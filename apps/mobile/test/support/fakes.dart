import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:modern_pos_api_client/api.dart';
import 'package:modern_pos_mobile/features/auth/auth_controller.dart';
import 'package:modern_pos_mobile/features/auth/auth_repository.dart';
import 'package:modern_pos_mobile/features/cart/cart_line.dart';
import 'package:modern_pos_mobile/features/cart/cart_repository.dart';
import 'package:modern_pos_mobile/features/catalog/catalog_models.dart';
import 'package:modern_pos_mobile/features/catalog/catalog_repository.dart';

AuthSession testSession({
  String outletId = 'outlet-1',
  String userId = 'user-1',
  bool offline = false,
}) {
  return AuthSession(
    accessToken: offline ? '' : 'test-access-token',
    user: User(
      id: userId,
      email: 'cashier@example.test',
      role: UserRoleEnum.CASHIER,
      outletIds: [outletId],
    ),
    offline: offline,
    authorizedAt: DateTime.now(),
  );
}

MobileSession testMobileSession({
  User? user,
  String accessToken = 'test-access-token',
  String refreshToken = 'test-refresh-token',
}) {
  return MobileSession(
    accessToken: accessToken,
    refreshToken: refreshToken,
    expiresInSeconds: MobileSessionExpiresInSecondsEnum.number600,
    user:
        user ??
        User(
          id: 'user-1',
          email: 'cashier@example.test',
          role: UserRoleEnum.CASHIER,
          outletIds: const ['outlet-1'],
        ),
  );
}

class InMemorySecureStorage extends FlutterSecureStorage {
  InMemorySecureStorage();

  final Map<String, String> values = {};

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return values[key];
  }

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      values.remove(key);
    } else {
      values[key] = value;
    }
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    values.remove(key);
  }
}

class FakeAuthRepository extends AuthRepository {
  FakeAuthRepository() : super(Dio());

  int refreshCalls = 0;
  int signInCalls = 0;
  int signOutCalls = 0;

  Future<MobileSession> Function({
    required String refreshToken,
    required String deviceId,
  })?
  onRefresh;
  Future<MobileSession> Function({
    required String email,
    required String password,
    required String deviceId,
  })?
  onSignIn;

  @override
  Future<MobileSession> refresh({
    required String refreshToken,
    required String deviceId,
  }) {
    refreshCalls++;
    final handler = onRefresh;
    if (handler != null) {
      return handler(refreshToken: refreshToken, deviceId: deviceId);
    }
    return Future.value(testMobileSession(refreshToken: refreshToken));
  }

  @override
  Future<MobileSession> signIn({
    required String email,
    required String password,
    required String deviceId,
  }) {
    signInCalls++;
    final handler = onSignIn;
    if (handler != null) {
      return handler(email: email, password: password, deviceId: deviceId);
    }
    return Future.value(testMobileSession());
  }

  @override
  Future<void> signOut(String accessToken) async {
    signOutCalls++;
  }
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
