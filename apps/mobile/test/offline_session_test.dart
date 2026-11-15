import 'package:dio/dio.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modern_pos_api_client/api.dart';
import 'package:modern_pos_mobile/app.dart';
import 'package:modern_pos_mobile/core/device_identity.dart';
import 'package:modern_pos_mobile/core/providers.dart';
import 'package:modern_pos_mobile/features/auth/auth_controller.dart';
import 'package:modern_pos_mobile/features/auth/offline_session_store.dart';
import 'package:modern_pos_mobile/features/cart/cart_controller.dart';
import 'package:modern_pos_mobile/features/cart/cart_line.dart';
import 'package:modern_pos_mobile/features/catalog/catalog_controller.dart';
import 'package:modern_pos_mobile/features/catalog/catalog_snapshot_store.dart';
import 'package:modern_pos_mobile/features/checkout/checkout_gateway.dart';
import 'package:modern_pos_mobile/features/checkout/checkout_models.dart';
import 'package:modern_pos_mobile/features/checkout/checkout_repository.dart';
import 'package:modern_pos_mobile/features/offline/offline_sale_models.dart';
import 'package:modern_pos_mobile/features/offline/offline_sale_store.dart';
import 'package:modern_pos_mobile/features/offline/offline_sync_controller.dart';
import 'package:modern_pos_mobile/features/payments/payments_gateway.dart';

import 'support/checkout_fakes.dart';
import 'support/fakes.dart';
import 'support/offline_fakes.dart';
import 'support/payment_fakes.dart';

DioException _networkFailure() {
  return DioException(
    requestOptions: RequestOptions(path: '/v1/auth/mobile/refresh'),
    type: DioExceptionType.connectionError,
    message: 'No network',
  );
}

DioException _unauthorized() {
  final options = RequestOptions(path: '/v1/auth/mobile/refresh');
  return DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    response: Response<dynamic>(requestOptions: options, statusCode: 401),
  );
}

OfflineSalePayload _offlinePayload({String key = 'offline-key-1'}) {
  return OfflineSalePayload(
    idempotencyKey: key,
    orderKey: 'order-$key',
    outletId: 'outlet-1',
    deviceId: 'device-1',
    lines: const [
      OfflineSaleLine(
        variantId: 'variant-1',
        name: 'Tea',
        variantName: 'Default',
        quantity: 1,
        unitPriceMinor: 50000,
      ),
    ],
    tenderKind: TenderKind.cash,
    amountMinor: 50000,
    tenderedMinor: 50000,
    reference: null,
    totalMinor: 50000,
    currency: 'IDR',
    currencyExponent: 0,
    createdAt: DateTime.utc(2026, 11, 15, 8),
  );
}

CartLine _cartLine() {
  return const CartLine(
    menuId: 'tea',
    variantId: 'tea-default',
    itemName: 'Tea',
    variantName: 'Default',
    unitPriceMinor: 18000,
    quantity: 1,
    currency: 'IDR',
    currencyExponent: 0,
  );
}

class AuthHarness {
  AuthHarness({
    AuthRefreshPolicy policy = const AuthRefreshPolicy(
      baseRetryDelay: Duration(milliseconds: 5),
      maxRetryAttempts: 4,
    ),
  }) {
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(repository),
        secureStorageProvider.overrideWithValue(storage),
        deviceIdentityProvider.overrideWithValue(
          FixedDeviceIdentity('device-1'),
        ),
        offlineSessionStoreProvider.overrideWithValue(offlineStore),
        offlineQueueScopeStoreProvider.overrideWithValue(scopeStore),
        offlineSaleStoreProvider.overrideWithValue(queueStore),
        cartRepositoryProvider.overrideWithValue(cart),
        catalogSnapshotStoreProvider.overrideWithValue(snapshotStore),
        authRefreshPolicyProvider.overrideWithValue(policy),
        checkoutGatewayProvider.overrideWithValue(gateway),
      ],
    );
    addTearDown(container.dispose);
  }

  final FakeAuthRepository repository = FakeAuthRepository();
  final InMemorySecureStorage storage = InMemorySecureStorage();
  final InMemoryOfflineSessionStore offlineStore =
      InMemoryOfflineSessionStore();
  final InMemoryOfflineQueueScopeStore scopeStore =
      InMemoryOfflineQueueScopeStore();
  final InMemoryOfflineSaleStore queueStore = InMemoryOfflineSaleStore();
  final InMemoryCartRepository cart = InMemoryCartRepository();
  final InMemoryCatalogSnapshotStore snapshotStore =
      InMemoryCatalogSnapshotStore();
  final FakeCheckoutGateway gateway = FakeCheckoutGateway();
  late final ProviderContainer container;

  AuthController get controller =>
      container.read(authControllerProvider.notifier);

  Future<AuthSession?> restore() =>
      container.read(authControllerProvider.future);

  AuthSession? get session => container.read(authControllerProvider).value;
}

Future<void> _waitFor(bool Function() condition) async {
  final deadline = DateTime.now().add(const Duration(seconds: 4));
  while (!condition() && DateTime.now().isBefore(deadline)) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

void main() {
  test('restart while offline within the allowance restores a scoped session and keeps the queue', () async {
    final h = AuthHarness();
    h.storage.values['pos_refresh_token'] = 'refresh-1';
    await h.offlineStore.write(
      OfflineSessionProfile(
        user: testMobileSession().user,
        authorizedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    );
    await h.queueStore.upsert(_offlinePayload());
    h.repository.onRefresh = ({
      required refreshToken,
      required deviceId,
    }) async => throw _networkFailure();

    final restored = await h.restore();

    expect(restored, isNotNull);
    expect(restored!.offline, isTrue);
    expect(restored.canSyncOnline, isFalse);
    expect(restored.user.outletIds, ['outlet-1']);
    expect(h.queueStore.rows, hasLength(1));
  });

  test('expired offline authorization requires sign-in', () async {
    final h = AuthHarness();
    h.storage.values['pos_refresh_token'] = 'refresh-1';
    await h.offlineStore.write(
      OfflineSessionProfile(
        user: testMobileSession().user,
        authorizedAt: DateTime.now().subtract(const Duration(hours: 13)),
      ),
    );
    h.repository.onRefresh = ({
      required refreshToken,
      required deviceId,
    }) async => throw _networkFailure();

    final restored = await h.restore();

    expect(restored, isNull);
  });

  test('a new install without a refresh token cannot sell offline', () async {
    final h = AuthHarness();
    await h.offlineStore.write(
      OfflineSessionProfile(
        user: testMobileSession().user,
        authorizedAt: DateTime.now(),
      ),
    );

    final restored = await h.restore();

    expect(restored, isNull);
    expect(h.offlineStore.profile, isNull);
  });

  test(
    '401 refresh revokes authorization, keeps the queue for its owner',
    () async {
      final h = AuthHarness();
      h.storage.values['pos_refresh_token'] = 'refresh-1';
      await h.offlineStore.write(
        OfflineSessionProfile(
          user: testMobileSession().user,
          authorizedAt: DateTime.now(),
        ),
      );
      await h.queueStore.upsert(_offlinePayload());
      await h.snapshotStore.save(
        userId: 'user-1',
        outletId: 'outlet-1',
        snapshot: testSnapshot(),
      );
      h.repository.onRefresh = ({
        required refreshToken,
        required deviceId,
      }) async => throw _unauthorized();

      final restored = await h.restore();

      expect(restored, isNull);
      expect(h.storage.values.containsKey('pos_refresh_token'), isFalse);
      expect(h.offlineStore.profile, isNull);
      expect(h.snapshotStore.rows, isEmpty);
      expect(h.queueStore.rows, hasLength(1));
    },
  );

  test('transient refresh outage retries and recovers online', () async {
    final h = AuthHarness();
    h.storage.values['pos_refresh_token'] = 'refresh-1';
    await h.offlineStore.write(
      OfflineSessionProfile(
        user: testMobileSession().user,
        authorizedAt: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
    );
    var calls = 0;
    h.repository.onRefresh =
        ({required refreshToken, required deviceId}) async {
          calls++;
          if (calls <= 2) {
            throw _networkFailure();
          }
          return testMobileSession(
            accessToken: 'access-3',
            refreshToken: 'refresh-3',
          );
        };

    final first = await h.restore();
    expect(first!.offline, isTrue);

    await _waitFor(() => h.session?.canSyncOnline ?? false);

    expect(h.repository.refreshCalls, greaterThanOrEqualTo(3));
    expect(h.session?.offline, isFalse);
    expect(h.session?.accessToken, 'access-3');
    expect(h.storage.values['pos_refresh_token'], 'refresh-3');
  });

  test(
    'a different account cannot read the previous owner queue or cache',
    () async {
      final h = AuthHarness();
      h.repository.onSignIn =
          ({required email, required password, required deviceId}) async {
            return testMobileSession(
              user: User(
                id: 'user-a',
                email: 'a@example.test',
                role: UserRoleEnum.CASHIER,
                outletIds: const ['outlet-1'],
              ),
              accessToken: 'access-a',
              refreshToken: 'refresh-a',
            );
          };
      await h.restore();
      await h.controller.signIn(email: 'a@example.test', password: 'pw');
      expect(h.scopeStore.scope?.userId, 'user-a');

      await h.queueStore.upsert(_offlinePayload());
      await h.cart.save(_cartLine());
      await h.snapshotStore.save(
        userId: 'user-a',
        outletId: 'outlet-1',
        snapshot: testSnapshot(),
      );

      await h.controller.signOut();
      expect(h.snapshotStore.rows, isEmpty);
      expect(h.queueStore.rows, hasLength(1));

      h.repository.onSignIn =
          ({required email, required password, required deviceId}) async {
            return testMobileSession(
              user: User(
                id: 'user-b',
                email: 'b@example.test',
                role: UserRoleEnum.CASHIER,
                outletIds: const ['outlet-2'],
              ),
              accessToken: 'access-b',
              refreshToken: 'refresh-b',
            );
          };
      await h.controller.signIn(email: 'b@example.test', password: 'pw');

      expect(h.scopeStore.scope?.userId, 'user-b');
      expect(h.scopeStore.scope?.outletId, 'outlet-2');
      expect(h.queueStore.rows, isEmpty);
      expect(h.cart.length, 0);
      expect(h.snapshotStore.rows, isEmpty);
    },
  );

  test(
    'offline session never replays the queue without a server token',
    () async {
      final store = InMemoryOfflineSaleStore();
      final gateway = FakeCheckoutGateway();
      await store.upsert(_offlinePayload());
      final container = ProviderContainer(
        overrides: [
          authControllerProvider.overrideWith(
            () => FakeAuthController(testSession(offline: true)),
          ),
          offlineSaleStoreProvider.overrideWithValue(store),
          checkoutGatewayProvider.overrideWithValue(gateway),
        ],
      );
      addTearDown(container.dispose);

      await container.read(offlineSyncControllerProvider.future);
      await container.read(offlineSyncControllerProvider.notifier).syncAll();

      expect(gateway.finalizeCalls, 0);
      expect(
        container.read(offlineSyncControllerProvider).value?.message,
        contains('Reconnect'),
      );
    },
  );

  testWidgets(
    'offline restart reaches the scoped cashier catalog instead of sign-in',
    (tester) async {
      final snapshotStore = InMemoryCatalogSnapshotStore();
      await snapshotStore.save(
        userId: 'user-1',
        outletId: 'outlet-1',
        snapshot: testSnapshot(
          categories: [testCategory(id: 'drinks', name: 'Drinks')],
          menus: [testMenu(id: 'tea', name: 'Tea', categoryId: 'drinks')],
        ),
        fetchedAt: DateTime.now().subtract(const Duration(minutes: 30)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith(
              () => FakeAuthController(testSession(offline: true)),
            ),
            catalogRepositoryProvider.overrideWithValue(
              FakeCatalogRepository(testSnapshot()),
            ),
            catalogSnapshotStoreProvider.overrideWithValue(snapshotStore),
            cartRepositoryProvider.overrideWithValue(InMemoryCartRepository()),
            checkoutRepositoryProvider.overrideWithValue(
              InMemoryCheckoutRepository(),
            ),
            offlineSaleStoreProvider.overrideWithValue(
              InMemoryOfflineSaleStore(),
            ),
            apiHealthProvider.overrideWith((ref) async => 'ok'),
            paymentsGatewayProvider.overrideWithValue(FakePaymentsGateway()),
          ],
          child: const ModernPosApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Cashier sign in'), findsNothing);
      expect(find.textContaining('Offline mode.'), findsOneWidget);
      expect(find.text('Tea'), findsOneWidget);
      expect(find.text('Offline menu snapshot'), findsOneWidget);
      expect(find.textContaining('minute(s) ago'), findsOneWidget);
    },
  );
}
