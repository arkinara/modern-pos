import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modern_pos_api_client/api.dart';

import '../../core/providers.dart';
import '../auth/auth_controller.dart';

class TableOrdersException implements Exception {
  const TableOrdersException({
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

abstract interface class TableOrdersGateway {
  Future<List<Table>> listTables(String outletId);

  Future<List<Order>> listOpenOrders(String outletId);

  Future<Order> openTableOrder({
    required String outletId,
    required String deviceId,
    required String idempotencyKey,
    required String tableId,
    required List<OrderWriteLinesInner> lines,
  });

  Future<Order> transfer({
    required String outletId,
    required String orderId,
    required int version,
    required String tableId,
  });

  Future<SplitResult> split({
    required String outletId,
    required String orderId,
    required String idempotencyKey,
    required int version,
    required List<SplitBill> bills,
  });

  Future<void> cancel({
    required String outletId,
    required String orderId,
    required int version,
  });
}

class HttpTableOrdersGateway implements TableOrdersGateway {
  HttpTableOrdersGateway(this._dio, this._accessToken);

  final Dio _dio;
  final String _accessToken;

  Options get _options =>
      Options(headers: {'Authorization': 'Bearer $_accessToken'});

  Options _withIdempotency(String key) => Options(
    headers: {'Authorization': 'Bearer $_accessToken', 'Idempotency-Key': key},
  );

  String _base(String outletId) =>
      '/v1/outlets/${Uri.encodeComponent(outletId)}';

  @override
  Future<List<Table>> listTables(String outletId) async {
    return _guard(() async {
      final response = await _dio.get<dynamic>(
        '${_base(outletId)}/tables',
        options: _options,
      );
      final page = TablePage.fromJson(response.data);
      if (page == null) {
        throw const FormatException('Invalid table list response');
      }
      return page.items;
    });
  }

  @override
  Future<List<Order>> listOpenOrders(String outletId) async {
    return _guard(() async {
      final response = await _dio.get<dynamic>(
        '${_base(outletId)}/orders',
        queryParameters: const {'limit': 200},
        options: _options,
      );
      final page = OrderPage.fromJson(response.data);
      if (page == null) {
        throw const FormatException('Invalid open order response');
      }
      return page.items;
    });
  }

  @override
  Future<Order> openTableOrder({
    required String outletId,
    required String deviceId,
    required String idempotencyKey,
    required String tableId,
    required List<OrderWriteLinesInner> lines,
  }) async {
    return _guard(() async {
      final response = await _dio.post<dynamic>(
        '${_base(outletId)}/orders',
        data: OrderWrite(
          deviceId: deviceId,
          lines: lines,
          tableId: tableId,
        ).toJson(),
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
  Future<Order> transfer({
    required String outletId,
    required String orderId,
    required int version,
    required String tableId,
  }) async {
    return _guard(() async {
      final response = await _dio.post<dynamic>(
        '${_base(outletId)}/orders/${Uri.encodeComponent(orderId)}/transfer',
        data: TransferWrite(version: version, tableId: tableId).toJson(),
        options: _options,
      );
      final order = Order.fromJson(response.data);
      if (order == null) {
        throw const FormatException('Invalid order response');
      }
      return order;
    });
  }

  @override
  Future<SplitResult> split({
    required String outletId,
    required String orderId,
    required String idempotencyKey,
    required int version,
    required List<SplitBill> bills,
  }) async {
    return _guard(() async {
      final response = await _dio.post<dynamic>(
        '${_base(outletId)}/orders/${Uri.encodeComponent(orderId)}/splits',
        data: SplitWrite(version: version, bills: bills).toJson(),
        options: _withIdempotency(idempotencyKey),
      );
      final result = SplitResult.fromJson(response.data);
      if (result == null) {
        throw const FormatException('Invalid split response');
      }
      return result;
    });
  }

  @override
  Future<void> cancel({
    required String outletId,
    required String orderId,
    required int version,
  }) async {
    return _guard(() async {
      await _dio.post<dynamic>(
        '${_base(outletId)}/orders/${Uri.encodeComponent(orderId)}/cancel',
        data: OrderCancelRequest(version: version).toJson(),
        options: _options,
      );
    });
  }

  Future<T> _guard<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on DioException catch (error) {
      final response = error.response;
      final body = response?.data;
      if (body is Map) {
        final code = body['code'];
        final message = body['message'];
        return throw TableOrdersException(
          statusCode: response?.statusCode,
          code: code is String ? code : 'HTTP_ERROR',
          message: message is String
              ? message
              : 'The server rejected the table order request.',
        );
      }
      return throw const TableOrdersException(
        code: 'NETWORK',
        message:
            'No confirmed server connection. Reconnect and retry; the order '
            'is unchanged on the server.',
      );
    } on FormatException catch (error) {
      throw TableOrdersException(
        code: 'INVALID_RESPONSE',
        message: error.message,
      );
    }
  }
}

final tableOrdersGatewayProvider = Provider<TableOrdersGateway>((ref) {
  final session = ref.watch(authControllerProvider).value;
  if (session == null) {
    throw StateError('Table orders require an authenticated session.');
  }
  return HttpTableOrdersGateway(ref.watch(dioProvider), session.accessToken);
});
