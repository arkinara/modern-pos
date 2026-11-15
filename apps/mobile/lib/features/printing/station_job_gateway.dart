import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modern_pos_api_client/api.dart';

import '../../core/device_identity.dart';
import '../../core/providers.dart';
import '../auth/auth_controller.dart';

/// A conflict means another consumer already claimed or changed the job. The
/// caller must not send it again and should refresh the station queue.
class StationJobConflictException implements Exception {
  const StationJobConflictException(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => message;
}

class StationJobApiException implements Exception {
  const StationJobApiException({
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

/// Server boundary for station queues and their exclusive delivery claim.
///
/// Claims use the existing `station_jobs_update_state` endpoint with a
/// compare-and-set on `QUEUED -> SENDING`; the loser receives a conflict.
abstract interface class StationJobGateway {
  Future<List<Station>> listStations(String outletId);

  Future<List<StationJob>> listJobs(
    String outletId,
    String stationId, {
    String? state,
    int limit = 100,
  });

  Future<StationJob> claim({
    required String outletId,
    required String jobId,
    required int attempts,
  });

  Future<StationJob> markState({
    required String outletId,
    required String jobId,
    required StationJobStateEnum state,
    required int attempts,
    String? lastError,
  });

  Future<StationJob> retry({required String outletId, required String jobId});

  Future<StationJob> reprint({
    required String outletId,
    required String jobId,
    String? idempotencyKey,
  });

  Future<List<StationJob>> dispatch({
    required String outletId,
    required String orderId,
    required String idempotencyKey,
    required StationJobKind kind,
    String? saleId,
    required List<StationJobLine> lines,
  });
}

class HttpStationJobGateway implements StationJobGateway {
  HttpStationJobGateway(this._dio, this._accessToken);

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
  Future<List<Station>> listStations(String outletId) async {
    return _guard(() async {
      final response = await _dio.get<dynamic>(
        '${_base(outletId)}/stations',
        options: _options,
      );
      final data = response.data;
      if (data is! List) {
        throw const FormatException('Invalid station list response');
      }
      return data
          .map(Station.fromJson)
          .whereType<Station>()
          .toList(growable: false);
    });
  }

  @override
  Future<List<StationJob>> listJobs(
    String outletId,
    String stationId, {
    String? state,
    int limit = 100,
  }) async {
    return _guard(() async {
      final response = await _dio.get<dynamic>(
        '${_base(outletId)}/stations/'
        '${Uri.encodeComponent(stationId)}/jobs',
        queryParameters: {'limit': limit, 'state': ?state},
        options: _options,
      );
      final page = StationJobPage.fromJson(response.data);
      if (page == null) {
        throw const FormatException('Invalid station job list response');
      }
      return page.items;
    });
  }

  @override
  Future<StationJob> claim({
    required String outletId,
    required String jobId,
    required int attempts,
  }) {
    return _updateState(
      outletId: outletId,
      jobId: jobId,
      state: StationJobStateEnum.SENDING,
      attempts: attempts,
    );
  }

  @override
  Future<StationJob> markState({
    required String outletId,
    required String jobId,
    required StationJobStateEnum state,
    required int attempts,
    String? lastError,
  }) {
    return _updateState(
      outletId: outletId,
      jobId: jobId,
      state: state,
      attempts: attempts,
      lastError: lastError,
    );
  }

  Future<StationJob> _updateState({
    required String outletId,
    required String jobId,
    required StationJobStateEnum state,
    required int attempts,
    String? lastError,
  }) async {
    return _guard(() async {
      final response = await _dio.patch<dynamic>(
        '${_base(outletId)}/station-jobs/${Uri.encodeComponent(jobId)}',
        data: StationJobStateWrite(
          state: StationJobStateWriteStateEnum.fromJson(state.toString())!,
          attempts: attempts,
          lastError: lastError,
        ).toJson(),
        options: _options,
      );
      return _requireJob(response.data);
    });
  }

  @override
  Future<StationJob> retry({
    required String outletId,
    required String jobId,
  }) async {
    return _guard(() async {
      final response = await _dio.post<dynamic>(
        '${_base(outletId)}/station-jobs/'
        '${Uri.encodeComponent(jobId)}/retry',
        options: _options,
      );
      return _requireJob(response.data);
    });
  }

  @override
  Future<StationJob> reprint({
    required String outletId,
    required String jobId,
    String? idempotencyKey,
  }) async {
    final key = idempotencyKey ?? generateUuidV4();
    return _guard(() async {
      final response = await _dio.post<dynamic>(
        '${_base(outletId)}/station-jobs/'
        '${Uri.encodeComponent(jobId)}/reprints',
        options: _withIdempotency(key),
      );
      return _requireJob(response.data);
    });
  }

  @override
  Future<List<StationJob>> dispatch({
    required String outletId,
    required String orderId,
    required String idempotencyKey,
    required StationJobKind kind,
    String? saleId,
    required List<StationJobLine> lines,
  }) async {
    return _guard(() async {
      final response = await _dio.post<dynamic>(
        '${_base(outletId)}/orders/${Uri.encodeComponent(orderId)}/station-jobs',
        data: StationJobWrite(
          kind: kind,
          saleId: saleId,
          lines: lines,
        ).toJson(),
        options: _withIdempotency(idempotencyKey),
      );
      final data = response.data;
      if (data is! List) {
        throw const FormatException('Invalid station job response');
      }
      return data
          .map(StationJob.fromJson)
          .whereType<StationJob>()
          .toList(growable: false);
    });
  }

  StationJob _requireJob(dynamic data) {
    final job = StationJob.fromJson(data);
    if (job == null) {
      throw const FormatException('Invalid station job response');
    }
    return job;
  }

  Future<T> _guard<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on StationJobConflictException {
      rethrow;
    } on DioException catch (error) {
      final response = error.response;
      final body = response?.data;
      final status = response?.statusCode;
      if (body is Map) {
        final code = body['code'];
        final message = body['message'];
        final resolvedCode = code is String ? code : 'HTTP_ERROR';
        final resolvedMessage = message is String
            ? message
            : 'The server rejected the station job request.';
        if (status == 409) {
          throw StationJobConflictException(resolvedCode, resolvedMessage);
        }
        throw StationJobApiException(
          statusCode: status,
          code: resolvedCode,
          message: resolvedMessage,
        );
      }
      throw StationJobApiException(
        statusCode: status,
        code: status == 409 ? 'JOB_CONFLICT' : 'NETWORK',
        message:
            'The station queue could not be reached. Reconnect and refresh '
            'the queue.',
      );
    } on FormatException catch (error) {
      throw StationJobApiException(
        code: 'INVALID_RESPONSE',
        message: error.message,
      );
    }
  }
}

/// Used when no signed-in session exists; every call fails visibly instead of
/// pretending a ticket was delivered.
class UnavailableStationJobGateway implements StationJobGateway {
  const UnavailableStationJobGateway();

  StationJobApiException get _failure => const StationJobApiException(
    code: 'NOT_AUTHENTICATED',
    message: 'Sign in before delivering kitchen tickets.',
  );

  @override
  Future<List<Station>> listStations(String outletId) async => throw _failure;

  @override
  Future<List<StationJob>> listJobs(
    String outletId,
    String stationId, {
    String? state,
    int limit = 100,
  }) async => throw _failure;

  @override
  Future<StationJob> claim({
    required String outletId,
    required String jobId,
    required int attempts,
  }) async => throw _failure;

  @override
  Future<StationJob> markState({
    required String outletId,
    required String jobId,
    required StationJobStateEnum state,
    required int attempts,
    String? lastError,
  }) async => throw _failure;

  @override
  Future<StationJob> retry({
    required String outletId,
    required String jobId,
  }) async => throw _failure;

  @override
  Future<StationJob> reprint({
    required String outletId,
    required String jobId,
    String? idempotencyKey,
  }) async => throw _failure;

  @override
  Future<List<StationJob>> dispatch({
    required String outletId,
    required String orderId,
    required String idempotencyKey,
    required StationJobKind kind,
    String? saleId,
    required List<StationJobLine> lines,
  }) async => throw _failure;
}

final stationJobGatewayProvider = Provider<StationJobGateway>((ref) {
  final session = ref.watch(authControllerProvider).value;
  if (session == null) {
    return const UnavailableStationJobGateway();
  }
  return HttpStationJobGateway(ref.watch(dioProvider), session.accessToken);
});
