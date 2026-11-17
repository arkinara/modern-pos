// ignore_for_file: prefer_initializing_formals

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modern_pos_api_client/api.dart';

import 'kitchen_ticket.dart';
import 'printer_adapter.dart';
import 'printer_config_store.dart';
import 'printer_controller.dart';
import 'printer_models.dart';
import 'station_job_gateway.dart';

enum StationDeliveryOutcome {
  sent,
  failed,
  uncertain,
  conflict,
  noPrinter,
  skipped,
}

class StationDeliveryResult {
  const StationDeliveryResult({
    required this.jobId,
    required this.stationId,
    required this.itemName,
    required this.kind,
    required this.outcome,
    this.message,
  });

  final String jobId;
  final String stationId;
  final String itemName;
  final StationJobKind kind;
  final StationDeliveryOutcome outcome;
  final String? message;

  bool get delivered => outcome == StationDeliveryOutcome.sent;

  StationDeliveryResult copyWith({
    StationDeliveryOutcome? outcome,
    String? message,
  }) {
    return StationDeliveryResult(
      jobId: jobId,
      stationId: stationId,
      itemName: itemName,
      kind: kind,
      outcome: outcome ?? this.outcome,
      message: message ?? this.message,
    );
  }
}

/// Claims queued station jobs on the server and writes kitchen tickets through
/// the existing printer adapter. It never calls sales, payment or stock APIs.
///
/// A `SENDING` job is left untouched during normal polling. `recoverInterrupted`
/// is the explicit restart path: it marks stale claims `UNKNOWN` and never
/// resends them automatically. A missing ticket requires an operator COPY.
class StationDeliveryService {
  StationDeliveryService({
    required StationJobGateway gateway,
    required PrinterAdapter adapter,
    required PrinterConfigStore configStore,
  }) : _gateway = gateway,
       _adapter = adapter,
       _configStore = configStore;

  final StationJobGateway _gateway;
  final PrinterAdapter _adapter;
  final PrinterConfigStore _configStore;

  Future<List<StationDeliveryResult>> deliverPending(
    String outletId, {
    List<String>? stationIds,
  }) async {
    final ids = stationIds ?? await _stationIds(outletId);
    final results = <StationDeliveryResult>[];
    for (final stationId in ids) {
      results.addAll(await deliverStation(outletId, stationId));
    }
    return results;
  }

  Future<List<StationDeliveryResult>> deliverStation(
    String outletId,
    String stationId,
  ) async {
    final jobs = await _gateway.listJobs(
      outletId,
      stationId,
      state: StationJobStateEnum.QUEUED.toString(),
    );
    if (jobs.isEmpty) {
      return const [];
    }
    final config = await _configStore.load();
    if (config == null) {
      return jobs
          .map(
            (job) => _result(
              job,
              StationDeliveryOutcome.noPrinter,
              StationJobPrinterMessage.noPrinter,
            ),
          )
          .toList(growable: false);
    }

    final results = <StationDeliveryResult>[];
    for (final job in jobs) {
      results.add(await _deliverOne(outletId, job, config));
    }
    return results;
  }

  /// Explicit operator COPY. Creates a new server reprint job and delivers it.
  /// The uncertain original is never rewritten or resent.
  Future<StationDeliveryResult> copyJob({
    required String outletId,
    required String jobId,
  }) async {
    final copy = await _gateway.reprint(outletId: outletId, jobId: jobId);
    final config = await _configStore.load();
    if (config == null) {
      return _result(
        copy,
        StationDeliveryOutcome.noPrinter,
        StationJobPrinterMessage.noPrinter,
      );
    }
    return _deliverOne(outletId, copy, config);
  }

  /// Requeues a known-failed job and sends one attempt. Callers must not use
  /// this for `UNKNOWN`; that state requires the explicit COPY decision.
  Future<StationDeliveryResult> retryFailed({
    required String outletId,
    required String jobId,
  }) async {
    final requeued = await _gateway.retry(outletId: outletId, jobId: jobId);
    final config = await _configStore.load();
    if (config == null) {
      return _result(
        requeued,
        StationDeliveryOutcome.noPrinter,
        StationJobPrinterMessage.noPrinter,
      );
    }
    return _deliverOne(outletId, requeued, config);
  }

  /// Restart recovery. Stale `SENDING` claims become `UNKNOWN`, never a resend.
  Future<List<StationDeliveryResult>> recoverInterrupted(
    String outletId, {
    List<String>? stationIds,
  }) async {
    final ids = stationIds ?? await _stationIds(outletId);
    final results = <StationDeliveryResult>[];
    for (final stationId in ids) {
      final jobs = await _gateway.listJobs(
        outletId,
        stationId,
        state: StationJobStateEnum.SENDING.toString(),
      );
      for (final job in jobs) {
        final updated = await _gateway.markState(
          outletId: outletId,
          jobId: job.id,
          state: StationJobStateEnum.UNKNOWN,
          attempts: job.attempts,
          lastError: StationJobPrinterMessage.restartUnknown,
        );
        results.add(
          _result(
            updated,
            StationDeliveryOutcome.uncertain,
            StationJobPrinterMessage.restartUnknown,
          ),
        );
      }
    }
    return results;
  }

  Future<StationDeliveryResult> _deliverOne(
    String outletId,
    StationJob job,
    PrinterConfig config,
  ) async {
    final StationJob claimed;
    try {
      claimed = await _gateway.claim(
        outletId: outletId,
        jobId: job.id,
        attempts: job.attempts + 1,
      );
    } on StationJobConflictException catch (error) {
      return _result(job, StationDeliveryOutcome.conflict, error.message);
    } catch (error) {
      return _result(job, StationDeliveryOutcome.skipped, '$error');
    }

    try {
      if (!_adapter.isConnected) {
        await _adapter.connect(config);
      }
    } catch (error) {
      final message = _messageFor(error);
      try {
        await _gateway.markState(
          outletId: outletId,
          jobId: claimed.id,
          state: StationJobStateEnum.UNKNOWN,
          attempts: claimed.attempts,
          lastError: message,
        );
      } catch (_) {
        // The local outcome stays honest even if the server is unreachable.
      }
      return _result(claimed, StationDeliveryOutcome.uncertain, message);
    }

    try {
      await _adapter.printKitchenTicket(_ticketFor(claimed));
    } catch (error) {
      final message = _messageFor(error);
      try {
        await _gateway.markState(
          outletId: outletId,
          jobId: claimed.id,
          state: StationJobStateEnum.UNKNOWN,
          attempts: claimed.attempts,
          lastError: message,
        );
      } catch (_) {
        // Unreachable server cannot turn unknown delivery into success.
      }
      return _result(claimed, StationDeliveryOutcome.uncertain, message);
    }

    try {
      final sent = await _gateway.markState(
        outletId: outletId,
        jobId: claimed.id,
        state: StationJobStateEnum.SENT,
        attempts: claimed.attempts,
      );
      return _result(sent, StationDeliveryOutcome.sent, null);
    } catch (error) {
      return _result(
        claimed,
        StationDeliveryOutcome.sent,
        'Printed; server state update failed: $error',
      );
    }
  }

  KitchenTicket _ticketFor(StationJob job) {
    return KitchenTicket(
      jobId: job.id,
      stationName: job.stationName,
      orderReference: job.orderReference,
      kind: KitchenTicketKind.fromWire(job.kind.toString()),
      itemName: job.itemName,
      variantName: job.variantName,
      quantity: job.quantity,
      modifiers: job.modifiers
          .map(
            (modifier) => KitchenTicketModifier(
              name: modifier.name ?? modifier.modifierId ?? '',
              quantity: modifier.quantity ?? 1,
            ),
          )
          .where((modifier) => modifier.name.isNotEmpty)
          .toList(growable: false),
      copy: job.copy,
      reprintOfId: job.reprintOfId,
      issuedAtLabel: _label(job.createdAt),
    );
  }

  Future<List<String>> _stationIds(String outletId) async {
    final stations = await _gateway.listStations(outletId);
    return stations.map((station) => station.id).toList(growable: false);
  }

  StationDeliveryResult _result(
    StationJob job,
    StationDeliveryOutcome outcome,
    String? message,
  ) {
    return StationDeliveryResult(
      jobId: job.id,
      stationId: job.stationId,
      itemName: job.itemName,
      kind: job.kind,
      outcome: outcome,
      message: message,
    );
  }

  String _messageFor(Object error) {
    if (error is PrinterException) {
      return error.userMessage;
    }
    return 'The kitchen ticket could not be written. Check the printer and '
        'use COPY only after checking the paper.';
  }

  String _label(DateTime value) {
    final local = value.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.year}-$month-$day $hour:$minute';
  }
}

abstract final class StationJobPrinterMessage {
  static const noPrinter =
      'No printer is configured on this device. Configure a printer before '
      'delivering kitchen tickets.';
  static const restartUnknown =
      'The app restarted while sending. Paper delivery is unknown; use COPY '
      'only if the ticket is missing.';
}

final stationDeliveryServiceProvider = Provider<StationDeliveryService>((ref) {
  return StationDeliveryService(
    gateway: ref.watch(stationJobGatewayProvider),
    adapter: ref.watch(printerAdapterProvider),
    configStore: ref.watch(printerConfigStoreProvider),
  );
});
