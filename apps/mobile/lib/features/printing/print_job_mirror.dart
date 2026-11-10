import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../auth/auth_controller.dart';
import 'print_job_models.dart';

/// Best-effort diagnostic mirror of the local print queue.
///
/// The local Drift queue is authoritative for execution and paper state. A
/// mirror failure must never block the sale, a retry or a reprint. The
/// `printing_*` contract requires a server printer-configuration id, so jobs
/// are mirrored only when one can be resolved for this device.
abstract interface class PrintJobMirror {
  Future<bool> create(PrintJob job);

  Future<void> update(PrintJob job);
}

class NoopPrintJobMirror implements PrintJobMirror {
  const NoopPrintJobMirror();

  @override
  Future<bool> create(PrintJob job) async => false;

  @override
  Future<void> update(PrintJob job) async {}
}

class HttpPrintJobMirror implements PrintJobMirror {
  HttpPrintJobMirror(this._dio, this._accessToken);

  final Dio _dio;
  final String _accessToken;

  Options get _options =>
      Options(headers: {'Authorization': 'Bearer $_accessToken'});

  @override
  Future<bool> create(PrintJob job) async {
    final printerConfigId =
        job.printerConfigId ??
        await _resolvePrinterConfigId(job.outletId, job.deviceId);
    if (printerConfigId == null) {
      return false;
    }
    try {
      await _dio.post<dynamic>(
        '/v1/outlets/${Uri.encodeComponent(job.outletId)}/print-jobs',
        data: {
          'id': job.id,
          'saleId': job.saleId,
          'deviceId': job.deviceId,
          'printerConfigId': printerConfigId,
          'copy': job.copy,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $_accessToken',
            'Idempotency-Key': job.id,
          },
        ),
      );
      return true;
    } on DioException {
      return false;
    }
  }

  @override
  Future<void> update(PrintJob job) async {
    try {
      await _dio.patch<dynamic>(
        '/v1/outlets/${Uri.encodeComponent(job.outletId)}/print-jobs/'
        '${Uri.encodeComponent(job.id)}',
        data: {
          'deviceId': job.deviceId,
          'state': job.state.wireName,
          'attempts': job.attempts,
          'lastError': job.lastError,
        },
        options: _options,
      );
    } on DioException {
      // Diagnostic metadata only; local delivery facts win.
    }
  }

  Future<String?> _resolvePrinterConfigId(
    String outletId,
    String deviceId,
  ) async {
    try {
      final response = await _dio.get<dynamic>(
        '/v1/outlets/${Uri.encodeComponent(outletId)}/printers',
        queryParameters: {'deviceId': deviceId},
        options: _options,
      );
      final data = response.data;
      if (data is List && data.isNotEmpty) {
        final first = data.first;
        if (first is Map) {
          final id = first['id'];
          if (id is String && id.isNotEmpty) {
            return id;
          }
        }
      }
    } on DioException {
      return null;
    }
    return null;
  }
}

final printJobMirrorProvider = Provider<PrintJobMirror>((ref) {
  final session = ref.watch(authControllerProvider).value;
  if (session == null) {
    return const NoopPrintJobMirror();
  }
  return HttpPrintJobMirror(ref.watch(dioProvider), session.accessToken);
});
