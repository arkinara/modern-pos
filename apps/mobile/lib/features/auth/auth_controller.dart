import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:modern_pos_api_client/api.dart';

import '../../core/providers.dart';
import 'auth_repository.dart';

const _refreshTokenKey = 'pos_refresh_token';
const _deviceIdKey = 'pos_device_id';

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

  @override
  Future<AuthSession?> build() async {
    _repository = ref.read(authRepositoryProvider);
    _storage = ref.read(secureStorageProvider);
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

    final deviceId = await _deviceId();
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
      final deviceId = await _deviceId();
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

    final deviceId = await _deviceId();

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

  Future<String> _deviceId() async {
    final existing = await _storage.read(key: _deviceIdKey);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final generated = _generateUuidV4();
    await _storage.write(key: _deviceIdKey, value: generated);
    return generated;
  }

  String _generateUuidV4() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }
}
