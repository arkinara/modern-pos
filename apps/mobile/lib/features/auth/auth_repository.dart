import 'package:dio/dio.dart';
import 'package:modern_pos_api_client/api.dart';

class AuthRepository {
  AuthRepository(this._dio);

  final Dio _dio;

  Future<MobileSession> signIn({
    required String email,
    required String password,
    required String deviceId,
  }) async {
    final response = await _dio.post<dynamic>(
      '/v1/auth/mobile/login',
      data: Login(
        email: email.trim().toLowerCase(),
        password: password,
        deviceId: deviceId,
      ).toJson(),
    );

    return _session(response.data);
  }

  Future<MobileSession> refresh({
    required String refreshToken,
    required String deviceId,
  }) async {
    final response = await _dio.post<dynamic>(
      '/v1/auth/mobile/refresh',
      data: AuthMobileRefreshRequest(
        refreshToken: refreshToken,
        deviceId: deviceId,
      ).toJson(),
    );

    return _session(response.data);
  }

  Future<void> signOut(String accessToken) async {
    await _dio.post<void>(
      '/v1/auth/logout',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
  }

  MobileSession _session(dynamic body) {
    if (body is! Map) {
      throw DioException.badResponse(
        statusCode: 500,
        requestOptions: RequestOptions(path: '/v1/auth'),
        response: Response<dynamic>(
          requestOptions: RequestOptions(path: '/v1/auth'),
          statusCode: 500,
          data: body,
        ),
      );
    }

    final session = MobileSession.fromJson(body);
    if (session == null) {
      throw const FormatException('Invalid session response');
    }

    return session;
  }
}
