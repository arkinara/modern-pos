import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modern_pos_api_client/api.dart' hide PrintJob;

import 'print_job_models.dart';
import 'print_queue_service.dart';

final printQueueControllerProvider =
    AsyncNotifierProvider<PrintQueueController, List<PrintJob>>(
      PrintQueueController.new,
    );

class PrintQueueController extends AsyncNotifier<List<PrintJob>> {
  final Map<String, Timer> _retryTimers = {};

  PrintQueueService get _service => ref.read(printQueueServiceProvider);

  @override
  Future<List<PrintJob>> build() async {
    ref.onDispose(() {
      for (final timer in _retryTimers.values) {
        timer.cancel();
      }
      _retryTimers.clear();
    });
    final jobs = await _service.recoverInterruptedJobs();
    _scheduleAutoRetries(jobs);
    return jobs;
  }

  Future<void> refresh() async {
    final jobs = await _service.jobs();
    state = AsyncData(jobs);
    _scheduleAutoRetries(jobs);
  }

  /// Processes queued jobs once after a restart. `SENDING` rows were already
  /// promoted to `UNCERTAIN` and are never auto-resubmitted.
  Future<void> resume() async {
    final service = _service;
    final jobs = await service.jobs();
    var changed = false;
    for (final job in jobs) {
      if (job.state == PrintJobState.queued) {
        await service.processJob(job.id);
        changed = true;
      }
    }
    if (changed) {
      await refresh();
    } else {
      _scheduleAutoRetries(jobs);
    }
  }

  Future<PrintJob?> retry(String jobId) async {
    final job = await _service.job(jobId);
    if (job == null) {
      return null;
    }
    final result = job.state == PrintJobState.uncertain
        ? await _service.reprintJob(jobId)
        : await _service.retryJob(jobId);
    await refresh();
    return result;
  }

  Future<PrintJob?> reprint(String jobId) async {
    final result = await _service.reprintJob(jobId);
    await refresh();
    return result;
  }

  Future<PrintJob?> enqueueSale({
    required Sale sale,
    required String outletId,
    required String deviceId,
  }) async {
    final job = await _service.enqueueSale(
      sale: sale,
      outletId: outletId,
      deviceId: deviceId,
    );
    final processed = await _service.processJob(job.id);
    await refresh();
    return processed;
  }

  Future<PrintJob?> reprintSale({
    required Sale sale,
    required String outletId,
    required String deviceId,
  }) async {
    final job = await _service.reprintSale(
      sale: sale,
      outletId: outletId,
      deviceId: deviceId,
    );
    await refresh();
    return job;
  }

  void _scheduleAutoRetries(List<PrintJob> jobs) {
    final activeIds = <String>{};
    for (final job in jobs) {
      if (!PrintRetryPolicy.shouldAutoRetry(job)) {
        continue;
      }
      activeIds.add(job.id);
      if (_retryTimers.containsKey(job.id)) {
        continue;
      }
      final delay = PrintRetryPolicy.delayForAttempt(job.attempts + 1);
      _retryTimers[job.id] = Timer(delay, () {
        _retryTimers.remove(job.id);
        unawaited(_autoRetry(job.id));
      });
    }
    for (final id in _retryTimers.keys.toList(growable: false)) {
      if (!activeIds.contains(id)) {
        _retryTimers.remove(id)?.cancel();
      }
    }
  }

  Future<void> _autoRetry(String jobId) async {
    final job = await _service.job(jobId);
    if (job == null || !PrintRetryPolicy.shouldAutoRetry(job)) {
      return;
    }
    await _service.retryJob(jobId);
    await refresh();
  }
}
