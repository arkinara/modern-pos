// ignore_for_file: prefer_initializing_formals

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modern_pos_api_client/api.dart' hide PrintJob;

import '../../core/device_identity.dart';
import '../auth/auth_controller.dart';
import 'printer_adapter.dart';
import 'printer_controller.dart';
import 'printer_config_store.dart';
import 'printer_models.dart';
import 'print_job_models.dart';
import 'print_job_mirror.dart';
import 'print_queue_repository.dart';
import 'receipt_identity.dart';
import 'sale_receipt.dart';

/// Owns the print lifecycle after a sale is committed.
///
/// This service never calls the sales/finalize API and never mutates a sale.
/// A print failure therefore cannot repeat checkout or create a second sale.
class PrintQueueService {
  PrintQueueService({
    required PrintQueueRepository repository,
    required PrinterAdapter adapter,
    required PrinterConfigStore configStore,
    ReceiptIdentityRepository? identityRepository,
    PrintJobMirror? mirror,
    String actorId = '',
    String actorEmail = '',
  }) : _repository = repository,
       _adapter = adapter,
       _configStore = configStore,
       _identityRepository = identityRepository,
       _mirror = mirror,
       _actorId = actorId,
       _actorEmail = actorEmail;

  final PrintQueueRepository _repository;
  final PrinterAdapter _adapter;
  final PrinterConfigStore _configStore;
  final ReceiptIdentityRepository? _identityRepository;
  final PrintJobMirror? _mirror;
  final String _actorId;
  final String _actorEmail;
  final Set<String> _inFlight = {};

  static const noPrinterMessage =
      'No printer is configured on this device. Configure a printer, then '
      'retry this job.';

  Future<PrintJob> enqueueSale({
    required Sale sale,
    required String outletId,
    required String deviceId,
    bool copy = false,
  }) async {
    if (!copy) {
      final existing = await _repository.findOriginalForSale(sale.id);
      if (existing != null) {
        return existing;
      }
    }

    final identity = await _loadIdentity(outletId);
    final config = await _configStore.load();
    final receipt = receiptDataForSale(sale, identity: identity, copy: copy);
    final now = DateTime.now();
    final job = PrintJob(
      id: copy ? generateUuidV4() : sale.id,
      saleId: sale.id,
      saleReference: sale.reference,
      outletId: outletId,
      deviceId: deviceId,
      printerConfigId: config?.serverId,
      printerConfig: config,
      receipt: receipt,
      state: PrintJobState.queued,
      copy: copy,
      attempts: 0,
      createdAt: now,
      updatedAt: now,
    );

    await _repository.save(job);
    await _audit(
      job,
      copy ? PrintAuditAction.reprint : PrintAuditAction.enqueue,
      detail: copy ? 'COPY reprint requested' : 'Receipt queued after sale',
    );
    final mirrored = await _mirrorCreate(job);
    if (mirrored) {
      final next = job.copyWith(
        serverMirrored: true,
        updatedAt: DateTime.now(),
      );
      await _repository.update(next);
      await _audit(next, PrintAuditAction.mirror, detail: 'Job mirrored');
      return next;
    }
    return job;
  }

  Future<PrintJob> reprintSale({
    required Sale sale,
    required String outletId,
    required String deviceId,
  }) async {
    final existing = await _repository.findOriginalForSale(sale.id);
    final identity = await _loadIdentity(outletId);
    final config = await _configStore.load();
    final receipt = existing != null
        ? existing.receipt.asCopy()
        : receiptDataForSale(sale, identity: identity, copy: true);
    final now = DateTime.now();
    final job = PrintJob(
      id: generateUuidV4(),
      saleId: sale.id,
      saleReference: sale.reference,
      outletId: outletId,
      deviceId: deviceId,
      printerConfigId: config?.serverId,
      printerConfig: config,
      receipt: receipt,
      state: PrintJobState.queued,
      copy: true,
      attempts: 0,
      createdAt: now,
      updatedAt: now,
    );

    await _repository.save(job);
    await _audit(
      job,
      PrintAuditAction.reprint,
      detail:
          'COPY reprint from receipt view'
          '${existing == null ? '' : '; original job ${existing.id}'}',
    );
    final mirrored = await _mirrorCreate(job);
    if (mirrored) {
      final next = job.copyWith(
        serverMirrored: true,
        updatedAt: DateTime.now(),
      );
      await _repository.update(next);
      await _audit(next, PrintAuditAction.mirror, detail: 'Job mirrored');
      return processJob(next.id);
    }
    return processJob(job.id);
  }

  /// Deliberate COPY reprint of an existing job. The new job carries `copy`
  /// true and a new id; the original delivery state is never rewritten.
  Future<PrintJob> reprintJob(String jobId) async {
    final original = await _repository.byId(jobId);
    if (original == null) {
      throw StateError('Print job $jobId no longer exists.');
    }
    final config = await _configStore.load() ?? original.printerConfig;
    final now = DateTime.now();
    final job = PrintJob(
      id: generateUuidV4(),
      saleId: original.saleId,
      saleReference: original.saleReference,
      outletId: original.outletId,
      deviceId: original.deviceId,
      printerConfigId: config?.serverId,
      printerConfig: config,
      receipt: original.receipt.asCopy(),
      state: PrintJobState.queued,
      copy: true,
      attempts: 0,
      createdAt: now,
      updatedAt: now,
    );

    await _repository.save(job);
    await _audit(
      job,
      PrintAuditAction.reprint,
      detail:
          'COPY reprint of job ${original.id} '
          '(${original.state.label}, attempts ${original.attempts})',
    );
    final mirrored = await _mirrorCreate(job);
    if (mirrored) {
      final next = job.copyWith(
        serverMirrored: true,
        updatedAt: DateTime.now(),
      );
      await _repository.update(next);
      await _audit(next, PrintAuditAction.mirror, detail: 'Job mirrored');
      return processJob(next.id);
    }
    return processJob(job.id);
  }

  Future<PrintJob?> job(String id) => _repository.byId(id);

  Future<List<PrintJob>> jobs() => _repository.loadJobs();

  Future<List<PrintJob>> activeJobs() => _repository.loadActive();

  Future<List<PrintAuditEntry>> auditsForSale(String saleId) =>
      _repository.loadAudits(saleId: saleId);

  /// Resumes the durable queue after a restart. An interrupted `SENDING` row is
  /// promoted to `UNCERTAIN`; it is never resent automatically because the
  /// bytes may already have reached the printer.
  Future<List<PrintJob>> recoverInterruptedJobs() async {
    final active = await _repository.loadActive();
    for (final job in active) {
      if (job.state == PrintJobState.sending) {
        await _transition(
          job,
          PrintJobState.uncertain,
          lastError:
              'The app stopped while sending. Physical delivery is unknown; '
              'use Reprint COPY if paper is missing.',
          action: PrintAuditAction.uncertain,
          detail: 'App restart while SENDING',
        );
      }
    }
    return _repository.loadJobs();
  }

  Future<PrintJob> processJob(String jobId) async {
    if (_inFlight.contains(jobId)) {
      return (await _repository.byId(jobId))!;
    }
    _inFlight.add(jobId);
    try {
      var job = await _repository.byId(jobId);
      if (job == null) {
        throw StateError('Print job $jobId no longer exists.');
      }
      if (job.state == PrintJobState.sent ||
          job.state == PrintJobState.uncertain) {
        return job;
      }
      if (job.state == PrintJobState.sending) {
        return await _transition(
          job,
          PrintJobState.uncertain,
          lastError:
              'Sending was interrupted. Physical delivery is unknown; use '
              'Reprint COPY if paper is missing.',
          action: PrintAuditAction.uncertain,
          detail: 'Interrupted SENDING state',
        );
      }

      final config = await _configStore.load() ?? job.printerConfig;
      if (config == null) {
        final next = job.copyWith(
          state: PrintJobState.queued,
          lastError: noPrinterMessage,
          updatedAt: DateTime.now(),
        );
        await _repository.update(next);
        return next;
      }
      if (!config.transport.implemented) {
        return await _transition(
          job,
          PrintJobState.failed,
          attempts: job.attempts,
          lastError:
              '${config.transport.label} is not implemented in this build. '
              'Choose Bluetooth Classic.',
          action: PrintAuditAction.failed,
        );
      }
      if (job.state == PrintJobState.failed &&
          job.attempts >= PrintRetryPolicy.maxAttempts) {
        return job;
      }

      if (!_adapter.isConnected) {
        try {
          await _adapter.connect(config);
        } catch (error) {
          return await _transition(
            job,
            PrintJobState.failed,
            attempts: job.attempts + 1,
            lastError: _messageFor(error),
            action: PrintAuditAction.failed,
            detail: 'Connect failed; delivery known not sent',
          );
        }
      }

      job = await _transition(
        job,
        PrintJobState.sending,
        attempts: job.attempts + 1,
        clearLastError: true,
        action: PrintAuditAction.retry,
        detail: 'Attempt ${job.attempts + 1}',
      );

      try {
        await _adapter.printReceipt(job.receipt);
        return await _transition(
          job,
          PrintJobState.sent,
          action: PrintAuditAction.sent,
          detail: 'Transport accepted bytes; paper delivery not verified',
        );
      } catch (error) {
        return await _transition(
          job,
          PrintJobState.uncertain,
          lastError: _messageFor(error),
          action: PrintAuditAction.uncertain,
          detail: 'Write failed after SENDING; delivery unknown',
        );
      }
    } finally {
      _inFlight.remove(jobId);
    }
  }

  Future<PrintJob> retryJob(String jobId) async {
    final job = await _repository.byId(jobId);
    if (job == null) {
      throw StateError('Print job $jobId no longer exists.');
    }
    if (job.state == PrintJobState.uncertain) {
      return reprintJob(jobId);
    }
    return processJob(jobId);
  }

  Future<PrintJob> _transition(
    PrintJob job,
    PrintJobState state, {
    int? attempts,
    String? lastError,
    bool clearLastError = false,
    required PrintAuditAction action,
    String detail = '',
  }) async {
    final next = job.copyWith(
      state: state,
      attempts: attempts,
      lastError: lastError,
      clearLastError: clearLastError,
      updatedAt: DateTime.now(),
    );
    await _repository.update(next);
    await _audit(next, action, detail: detail);
    await _mirrorUpdate(next);
    return next;
  }

  Future<void> _audit(
    PrintJob job,
    PrintAuditAction action, {
    String detail = '',
  }) {
    return _repository.appendAudit(
      PrintAuditEntry(
        jobId: job.id,
        saleId: job.saleId,
        action: action,
        actorId: _actorId,
        actorEmail: _actorEmail,
        copy: job.copy,
        detail: detail,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<ReceiptIdentity?> _loadIdentity(String outletId) async {
    try {
      return await _identityRepository?.load(outletId);
    } catch (_) {
      return null;
    }
  }

  Future<bool> _mirrorCreate(PrintJob job) async {
    try {
      return await _mirror?.create(job) ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> _mirrorUpdate(PrintJob job) async {
    if (_mirror == null) {
      return;
    }
    try {
      if (!job.serverMirrored) {
        final created = await _mirrorCreate(job);
        if (created) {
          await _repository.update(
            job.copyWith(serverMirrored: true, updatedAt: DateTime.now()),
          );
          await _audit(
            job.copyWith(serverMirrored: true),
            PrintAuditAction.mirror,
            detail: 'Job mirrored after retry',
          );
        }
      }
      await _mirror.update(job);
    } catch (_) {
      // Mirroring is diagnostic. Local execution remains authoritative.
    }
  }

  String _messageFor(Object error) {
    if (error is PrinterException) {
      return error.userMessage;
    }
    return 'The printer operation failed. Check the connection and retry.';
  }
}

final printQueueServiceProvider = Provider<PrintQueueService>((ref) {
  final session = ref.watch(authControllerProvider).value;
  return PrintQueueService(
    repository: ref.watch(printQueueRepositoryProvider),
    adapter: ref.watch(printerAdapterProvider),
    configStore: ref.watch(printerConfigStoreProvider),
    identityRepository: ref.watch(receiptIdentityRepositoryProvider),
    mirror: ref.watch(printJobMirrorProvider),
    actorId: session?.user.id ?? '',
    actorEmail: session?.user.email ?? '',
  );
});
