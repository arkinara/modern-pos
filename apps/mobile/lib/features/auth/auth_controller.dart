import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:modern_pos_api_client/api.dart';

import '../../core/device_identity.dart';
import '../../core/providers.dart';
import '../cart/cart_controller.dart';
import '../cart/cart_repository.dart';
import '../catalog/catalog_snapshot_store.dart';
import '../offline/offline_sale_store.dart';
import 'auth_repository.dart';
import 'offline_session_store.dart';

const _refreshTokenKey = 'pos_refresh_token';

class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.user,
    this.offline = false,
    this.authorizedAt,
  });

  final String accessToken;
  final User user;

  /// True when this session was restored from the persisted authorized
  /// profile after a transient refresh failure. It has no server access token.
  final bool offline;

  /// Time of the last successful server login or refresh. Used to enforce the
  /// offline allowance after a restart.
  final DateTime? authorizedAt;

  /// Only an online-authorized session may call the API or replay the queue.
  bool get canSyncOnline => !offline && accessToken.isNotEmpty;
}

/// Tunables for refresh scheduling and offline recovery. Tests override the
/// delays so bounded retries run without wall-clock waits.
class AuthRefreshPolicy {
  const AuthRefreshPolicy({
    this.offlineAllowance = defaultOfflineSessionAllowance,
    this.refreshLead = const Duration(seconds: 60),
    this.baseRetryDelay = const Duration(seconds: 2),
    this.maxRetryDelay = const Duration(minutes: 5),
    this.maxRetryAttempts = 6,
  });

  final Duration offlineAllowance;
  final Duration refreshLead;
  final Duration baseRetryDelay;
  final Duration maxRetryDelay;
  final int maxRetryAttempts;
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(dioProvider));
});

final authRefreshPolicyProvider = Provider<AuthRefreshPolicy>((ref) {
  return const AuthRefreshPolicy();
});

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthSession?>(AuthController.new);

class AuthController extends AsyncNotifier<AuthSession?> {
  Timer? _timer;
  int _retryAttempts = 0;
  late AuthRepository _repository;
  late FlutterSecureStorage _storage;
  late DeviceIdentity _deviceIdentity;
  late AuthRefreshPolicy _policy;
  late OfflineSessionStore _offlineStore;
  late OfflineQueueScopeStore _scopeStore;
  late CatalogSnapshotStore _snapshotStore;
  late OfflineSaleStore _queueStore;
  late CartRepository _cartRepository;

  @override
  Future<AuthSession?> build() async {
    _repository = ref.read(authRepositoryProvider);
    _storage = ref.read(secureStorageProvider);
    _deviceIdentity = ref.read(deviceIdentityProvider);
    _policy = ref.read(authRefreshPolicyProvider);
    _offlineStore = ref.read(offlineSessionStoreProvider);
    _scopeStore = ref.read(offlineQueueScopeStoreProvider);
    _snapshotStore = ref.read(catalogSnapshotStoreProvider);
    _queueStore = ref.read(offlineSaleStoreProvider);
    _cartRepository = ref.read(cartRepositoryProvider);
    ref.onDispose(() => _timer?.cancel());

    ref
        .read(dioProvider)
        .interceptors
        .add(
          InterceptorsWrapper(
            onError: (error, handler) {
              final path = error.requestOptions.path;
              final current = state.value;
              if (error.response?.statusCode == 401 &&
                  path != '/v1/auth/mobile/login' &&
                  path != '/v1/auth/mobile/refresh' &&
                  current != null &&
                  current.canSyncOnline) {
                unawaited(handleUnauthorized());
              }
              handler.next(error);
            },
          ),
        );

    final deviceId = await _deviceIdentity.deviceId();
    final refreshToken = await _storage.read(key: _refreshTokenKey);
    final profile = await _offlineStore.read();
    if (refreshToken == null) {
      await _offlineStore.clear();
      return null;
    }

    try {
      final session = await _repository.refresh(
        refreshToken: refreshToken,
        deviceId: deviceId,
      );
      await _acceptOnlineSession(session);
      return _toAuthSession(session);
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) {
        await _clearAuthorization();
        return null;
      }
      if (profile != null && _profileAllowsOffline(profile)) {
        _scheduleRetry();
        return _offlineSession(profile);
      }
      return null;
    } on FormatException {
      await _clearAuthorization();
      return null;
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final deviceId = await _deviceIdentity.deviceId();
      final session = await _repository.signIn(
        email: email,
        password: password,
        deviceId: deviceId,
      );
      await _acceptOnlineSession(session);
      return _toAuthSession(session);
    });
  }

  Future<void> signOut() async {
    final session = state.value;
    if (session != null && session.canSyncOnline) {
      try {
        await _repository.signOut(session.accessToken);
      } on DioException {
        // Local sign-out must still succeed when the API is unreachable.
      }
    }

    await _clearAuthorization();
    state = const AsyncData(null);
  }

  Future<void> handleUnauthorized() async {
    _timer?.cancel();
    await _clearAuthorization();
    state = const AsyncData(null);
  }

  /// Manual reconnect from the offline banner. Resets the bounded retry budget
  /// before attempting one refresh.
  Future<void> retryRefreshNow() async {
    _retryAttempts = 0;
    await _refreshSession();
  }

  Future<void> _refreshSession() async {
    final refreshToken = await _storage.read(key: _refreshTokenKey);
    if (refreshToken == null) {
      await handleUnauthorized();
      return;
    }

    final deviceId = await _deviceIdentity.deviceId();

    try {
      final session = await _repository.refresh(
        refreshToken: refreshToken,
        deviceId: deviceId,
      );
      await _acceptOnlineSession(session);
      state = AsyncData(_toAuthSession(session));
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) {
        await handleUnauthorized();
        return;
      }
      await _handleTransientRefreshFailure();
    } on FormatException {
      await handleUnauthorized();
    }
  }

  Future<void> _handleTransientRefreshFailure() async {
    final current = state.value;
    if (current != null && current.offline) {
      final profile = await _offlineStore.read();
      if (profile == null || !_profileAllowsOffline(profile)) {
        await handleUnauthorized();
        return;
      }
    }
    _scheduleRetry();
  }

  void _scheduleRefresh(MobileSession session) {
    _timer?.cancel();
    final seconds = int.tryParse(session.expiresInSeconds.toString()) ?? 600;
    final lead = _policy.refreshLead.inSeconds;
    final delay = Duration(seconds: max(5, seconds - lead));
    _timer = Timer(delay, () {
      unawaited(_refreshSession());
    });
  }

  void _scheduleRetry() {
    _timer?.cancel();
    if (_retryAttempts >= _policy.maxRetryAttempts) {
      return;
    }
    _retryAttempts++;
    final delay = _backoff(_retryAttempts);
    _timer = Timer(delay, () {
      unawaited(_refreshSession());
    });
  }

  Duration _backoff(int attempt) {
    final exponent = (attempt - 1).clamp(0, 10);
    final millis = _policy.baseRetryDelay.inMilliseconds * (1 << exponent);
    return Duration(
      milliseconds: min(millis, _policy.maxRetryDelay.inMilliseconds),
    );
  }

  bool _profileAllowsOffline(OfflineSessionProfile profile) {
    return profile.withinAllowance(DateTime.now(), _policy.offlineAllowance);
  }

  Future<void> _acceptOnlineSession(MobileSession session) async {
    await _saveSession(session);
    await _offlineStore.write(
      OfflineSessionProfile(user: session.user, authorizedAt: DateTime.now()),
    );
    await _enforceQueueScope(session.user);
    _retryAttempts = 0;
    _scheduleRefresh(session);
  }

  /// Keeps local cached data scoped to one user and outlet. A different owner
  /// cannot read or replay the previous owner's queue, cart or catalog.
  Future<void> _enforceQueueScope(User user) async {
    final outletId = user.outletIds.isEmpty ? '' : user.outletIds.first;
    final next = OfflineQueueScope(userId: user.id, outletId: outletId);
    final existing = await _scopeStore.read();

    if (existing != null && !existing.matches(next)) {
      await _clearOwnedData();
    } else if (existing == null) {
      // Fail closed for data that predates the scope marker: never expose an
      // unowned queue to the first account that signs in.
      try {
        final records = await _queueStore.loadAll();
        if (records.isNotEmpty) {
          await _clearOwnedData();
        }
      } catch (_) {
        await _clearOwnedData();
      }
    }

    await _scopeStore.write(next);
  }

  Future<void> _clearOwnedData() async {
    try {
      await _queueStore.clearAll();
    } catch (_) {
      // The owner scope is still replaced below; a corrupt queue is never
      // decrypted as a fallback.
    }
    try {
      await _cartRepository.clear();
    } catch (_) {
      // Cart cleanup must not block authentication.
    }
    try {
      await _snapshotStore.clear();
    } catch (_) {
      // Snapshot cleanup must not block authentication.
    }
  }

  Future<void> _saveSession(MobileSession session) async {
    await _storage.write(key: _refreshTokenKey, value: session.refreshToken);
  }

  /// Clears the server authorization and cached catalog data but deliberately
  /// keeps the encrypted queue and its owner scope. The same user can sign
  /// back in and recover; a different user clears the queue in
  /// [_enforceQueueScope].
  Future<void> _clearAuthorization() async {
    _timer?.cancel();
    _retryAttempts = 0;
    await _storage.delete(key: _refreshTokenKey);
    await _offlineStore.clear();
    try {
      await _snapshotStore.clear();
    } catch (_) {
      // Sign-out must not fail because cached data could not be removed.
    }
  }

  AuthSession _offlineSession(OfflineSessionProfile profile) {
    return AuthSession(
      accessToken: '',
      user: profile.user,
      offline: true,
      authorizedAt: profile.authorizedAt,
    );
  }

  AuthSession _toAuthSession(MobileSession session) {
    return AuthSession(
      accessToken: session.accessToken,
      user: session.user,
      authorizedAt: DateTime.now(),
    );
  }
}
