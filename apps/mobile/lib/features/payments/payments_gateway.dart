import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modern_pos_api_client/api.dart';

import '../../core/providers.dart';
import '../auth/auth_controller.dart';

class PaymentsApiException implements Exception {
  const PaymentsApiException({
    required this.code,
    required this.message,
    this.statusCode,
  });

  final String code;
  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

abstract interface class PaymentsGateway {
  Future<List<OnlinePaymentListItem>> listPayments(String outletId);

  Future<OnlinePayment> refreshPayment({
    required String outletId,
    required String saleId,
  });
}

class HttpPaymentsGateway implements PaymentsGateway {
  HttpPaymentsGateway(this._dio, this._accessToken);

  final Dio _dio;
  final String _accessToken;

  Options get _options =>
      Options(headers: {'Authorization': 'Bearer $_accessToken'});

  String _base(String outletId) =>
      '/v1/outlets/${Uri.encodeComponent(outletId)}';

  @override
  Future<List<OnlinePaymentListItem>> listPayments(String outletId) async {
    return _guard(() async {
      final response = await _dio.get<dynamic>(
        '${_base(outletId)}/online-payments',
        queryParameters: const {'limit': 50},
        options: _options,
      );
      final page = OnlinePaymentList.fromJson(response.data);
      if (page == null) {
        throw const FormatException('Invalid online payment list');
      }
      return page.items;
    });
  }

  @override
  Future<OnlinePayment> refreshPayment({
    required String outletId,
    required String saleId,
  }) async {
    return _guard(() async {
      final response = await _dio.post<dynamic>(
        '${_base(outletId)}/sales/${Uri.encodeComponent(saleId)}'
        '/online-payment/refresh',
        options: _options,
      );
      final payment = OnlinePayment.fromJson(response.data);
      if (payment == null) {
        throw const FormatException('Invalid online payment response');
      }
      return payment;
    });
  }

  Future<T> _guard<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on PaymentsApiException {
      rethrow;
    } on DioException catch (error) {
      final body = error.response?.data;
      if (body is Map) {
        final code = body['code'];
        final message = body['message'];
        return _throwMapped(
          PaymentsApiException(
            statusCode: error.response?.statusCode,
            code: code is String ? code : 'HTTP_ERROR',
            message: message is String
                ? message
                : 'The payment provider request failed.',
          ),
        );
      }
      final timeout =
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout;
      return _throwMapped(
        PaymentsApiException(
          statusCode: error.response?.statusCode,
          code: timeout ? 'NETWORK_TIMEOUT' : 'PROVIDER_UNREACHABLE',
          message: 'Provider unreachable. The server-side payment state is unchanged.',
        ),
      );
    } on FormatException catch (error) {
      return _throwMapped(
        PaymentsApiException(code: 'INVALID_RESPONSE', message: error.message),
      );
    }
  }

  Never _throwMapped(PaymentsApiException error) => throw error;
}

final paymentsGatewayProvider = Provider<PaymentsGateway>((ref) {
  final session = ref.watch(authControllerProvider).value;
  if (session == null) {
    throw StateError('Online payments require an authenticated session.');
  }
  return HttpPaymentsGateway(ref.watch(dioProvider), session.accessToken);
});
