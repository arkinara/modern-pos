import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modern_pos_api_client/api.dart';

import '../../core/providers.dart';
import '../auth/auth_controller.dart';
import 'checkout_models.dart';

/// Boundary around the sales contract used by checkout. Widget and controller
/// tests replace this with a fake so call counts and failure modes are exact.
abstract interface class CheckoutGateway {
  Future<bool> ping();

  Future<Order> createOrder({
    required String outletId,
    required String deviceId,
    required String idempotencyKey,
    required List<OrderWriteLinesInner> lines,
  });

  Future<Quote> createQuote({
    required String outletId,
    required String orderId,
    required int orderVersion,
  });

  Future<Finalized> finalize({
    required String outletId,
    required String idempotencyKey,
    required Finalize payload,
  });

  Future<Finalized> recover({
    required String outletId,
    required String key,
    required String deviceId,
  });

  Future<SalePage> listSales({
    required String outletId,
    DateTime? from,
    DateTime? to,
    String? cursor,
    int limit = 100,
  });
}

class HttpCheckoutGateway implements CheckoutGateway {
  HttpCheckoutGateway(this._dio, this._accessToken);

  final Dio _dio;
  final String _accessToken;

  static const _pingTimeout = Duration(seconds: 4);

  Options get _options =>
      Options(headers: {'Authorization': 'Bearer $_accessToken'});

  Options _withIdempotency(String key) => Options(
    headers: {'Authorization': 'Bearer $_accessToken', 'Idempotency-Key': key},
  );

  @override
  Future<bool> ping() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/health',
        options: Options(
          receiveTimeout: _pingTimeout,
          sendTimeout: _pingTimeout,
        ),
      );
      return response.statusCode == 200 && response.data?['status'] == 'ok';
    } on DioException {
      return false;
    }
  }

  @override
  Future<Order> createOrder({
    required String outletId,
    required String deviceId,
    required String idempotencyKey,
    required List<OrderWriteLinesInner> lines,
  }) async {
    return _guard(() async {
      final response = await _dio.post<dynamic>(
        '/v1/outlets/${Uri.encodeComponent(outletId)}/orders',
        data: OrderWrite(deviceId: deviceId, lines: lines).toJson(),
        options: _withIdempotency(idempotencyKey),
      );
      final order = Order.fromJson(response.data);
      if (order == null) {
        throw const FormatException('Invalid order response');
      }
      return order;
    });
  }

  @override
  Future<Quote> createQuote({
    required String outletId,
    required String orderId,
    required int orderVersion,
  }) async {
    return _guard(() async {
      final response = await _dio.post<dynamic>(
        '/v1/outlets/${Uri.encodeComponent(outletId)}/orders/'
        '${Uri.encodeComponent(orderId)}/quotes',
        data: OrderQuoteRequest(orderVersion: orderVersion).toJson(),
        options: _options,
      );
      final quote = Quote.fromJson(response.data);
      if (quote == null) {
        throw const FormatException('Invalid quote response');
      }
      return quote;
    });
  }

  @override
  Future<Finalized> finalize({
    required String outletId,
    required String idempotencyKey,
    required Finalize payload,
  }) async {
    return _guard(() async {
      final response = await _dio.post<dynamic>(
        '/v1/outlets/${Uri.encodeComponent(outletId)}/sales/finalize',
        data: payload.toJson(),
        options: _withIdempotency(idempotencyKey),
      );
      final finalized = Finalized.fromJson(response.data);
      if (finalized == null) {
        throw const FormatException('Invalid finalize response');
      }
      return finalized;
    });
  }

  @override
  Future<Finalized> recover({
    required String outletId,
    required String key,
    required String deviceId,
  }) async {
    return _guard(() async {
      final response = await _dio.get<dynamic>(
        '/v1/outlets/${Uri.encodeComponent(outletId)}/checkout-requests/'
        '${Uri.encodeComponent(key)}',
        queryParameters: {'deviceId': deviceId},
        options: _options,
      );
      final finalized = Finalized.fromJson(response.data);
      if (finalized == null) {
        throw const FormatException('Invalid recovery response');
      }
      return finalized;
    });
  }

  @override
  Future<SalePage> listSales({
    required String outletId,
    DateTime? from,
    DateTime? to,
    String? cursor,
    int limit = 100,
  }) async {
    return _guard(() async {
      final response = await _dio.get<dynamic>(
        '/v1/outlets/${Uri.encodeComponent(outletId)}/sales',
        queryParameters: {
          'limit': limit,
          'from': ?from?.toUtc().toIso8601String(),
          'to': ?to?.toUtc().toIso8601String(),
          'cursor': ?cursor,
        },
        options: _options,
      );
      final page = SalePage.fromJson(response.data);
      if (page == null) {
        throw const FormatException('Invalid sales response');
      }
      return page;
    });
  }

  Future<T> _guard<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on CheckoutApiException {
      rethrow;
    } on DioException catch (error) {
      throw _mapDioError(error);
    } on FormatException catch (error) {
      throw CheckoutApiException(
        code: 'INVALID_RESPONSE',
        message: error.message,
        retryable: true,
      );
    }
  }

  CheckoutApiException _mapDioError(DioException error) {
    final response = error.response;
    final body = response?.data;
    if (body is Map) {
      final code = body['code'];
      final message = body['message'];
      final details = body['details'];
      return CheckoutApiException(
        statusCode: response?.statusCode,
        code: code is String ? code : 'HTTP_ERROR',
        message: message is String
            ? message
            : 'The server rejected the checkout request.',
        retryable: body['retryable'] == true,
        details: details is Map
            ? details.map((key, value) => MapEntry('$key', value))
            : const {},
      );
    }

    final isTimeout =
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout;
    return CheckoutApiException(
      statusCode: response?.statusCode,
      code: isTimeout ? 'NETWORK_TIMEOUT' : 'NETWORK',
      message:
          'No confirmed server connection. Reconnect and retry; the same '
          'checkout key is used until the outcome is known.',
      retryable: true,
    );
  }
}

final checkoutGatewayProvider = Provider<CheckoutGateway>((ref) {
  final session = ref.watch(authControllerProvider).value;
  if (session == null) {
    throw StateError('Checkout requires an authenticated session.');
  }
  return HttpCheckoutGateway(ref.watch(dioProvider), session.accessToken);
});
