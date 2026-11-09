import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:modern_pos_api_client/api.dart';

import '../../core/device_identity.dart';
import '../../core/providers.dart';
import 'auth_repository.dart';

const _refreshTokenKey = 'pos_refresh_token';

class AuthSession {
  const AuthSession({required this.accessToken, required this.user});

  final String accessToken;
  final User user;
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(dioProvider));
});

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthSession?>(AuthController.new);

class AuthController extends AsyncNotifier<AuthSession?> {
  Timer? _timer;
  late AuthRepository _repository;
  late FlutterSecureStorage _storage;
  late DeviceIdentity _deviceIdentity;

  @override
  Future<AuthSession?> build() async {
    _repository = ref.read(authRepositoryProvider);
    _storage = ref.read(secureStorageProvider);
    _deviceIdentity = ref.read(deviceIdentityProvider);
    ref.onDispose(() => _timer?.cancel());

    ref
        .read(dioProvider)
        .interceptors
        .add(
          InterceptorsWrapper(
            onError: (error, handler) {
              final path = error.requestOptions.path;
              if (error.response?.statusCode == 401 &&
                  path != '/v1/auth/mobile/login') {
                unawaited(handleUnauthorized());
              }
              handler.next(error);
            },
          ),
        );

    final deviceId = await _deviceIdentity.deviceId();
    final refreshToken = await _storage.read(key: _refreshTokenKey);
    if (refreshToken == null) {
      return null;
    }

    try {
      final session = await _repository.refresh(
        refreshToken: refreshToken,
        deviceId: deviceId,
      );
      await _saveSession(session);
      _scheduleRefresh(session);
      return _toAuthSession(session);
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) {
        await _clearStoredSession();
      }
      return null;
    } on FormatException {
      await _clearStoredSession();
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
      await _saveSession(session);
      _scheduleRefresh(session);
      return _toAuthSession(session);
    });
  }

  Future<void> signOut() async {
    final session = state.value;
    if (session != null) {
      try {
        await _repository.signOut(session.accessToken);
      } on DioException {
        // Local sign-out must still succeed when the API is unreachable.
      }
    }

    await _clearStoredSession();
    state = const AsyncData(null);
  }

  Future<void> handleUnauthorized() async {
    _timer?.cancel();
    await _clearStoredSession();
    state = const AsyncData(null);
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
      await _saveSession(session);
      _scheduleRefresh(session);
      state = AsyncData(_toAuthSession(session));
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) {
        await handleUnauthorized();
      }
    } on FormatException {
      await handleUnauthorized();
    }
  }

  void _scheduleRefresh(MobileSession session) {
    _timer?.cancel();
    final seconds = int.tryParse(session.expiresInSeconds.toString()) ?? 600;
    final delay = Duration(seconds: max(5, seconds - 60));
    _timer = Timer(delay, () {
      unawaited(_refreshSession());
    });
  }

  Future<void> _saveSession(MobileSession session) async {
    await _storage.write(key: _refreshTokenKey, value: session.refreshToken);
  }

  Future<void> _clearStoredSession() async {
    _timer?.cancel();
    await _storage.delete(key: _refreshTokenKey);
  }

  AuthSession _toAuthSession(MobileSession session) {
    return AuthSession(accessToken: session.accessToken, user: session.user);
  }
}
