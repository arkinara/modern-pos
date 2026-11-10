import 'esc_pos_receipt.dart';
import 'printer_models.dart';

/// Local delivery states. `SENT` means the transport accepted the byte stream;
/// it is not proof that paper came out. `uncertain` is deliberately honest:
/// bytes may or may not have reached the printer and must not be resent
/// automatically.
enum PrintJobState {
  queued('queued', 'QUEUED', 'Queued'),
  sending('sending', 'SENDING', 'Sending'),
  sent('sent', 'SENT', 'Sent'),
  failed('failed', 'FAILED', 'Failed'),
  uncertain('uncertain', 'UNKNOWN', 'Delivery unknown');

  const PrintJobState(this.storageName, this.wireName, this.label);

  final String storageName;
  final String wireName;
  final String label;

  bool get isTerminal => this == PrintJobState.sent;
  bool get isRetryable =>
      this == PrintJobState.failed || this == PrintJobState.queued;
  bool get isUncertain => this == PrintJobState.uncertain;

  static PrintJobState fromStorage(String? value) {
    return PrintJobState.values.firstWhere(
      (state) => state.storageName == value,
      orElse: () => PrintJobState.queued,
    );
  }

  static PrintJobState fromWire(String? value) {
    return PrintJobState.values.firstWhere(
      (state) => state.wireName == value,
      orElse: () => PrintJobState.queued,
    );
  }
}

enum PrintAuditAction {
  enqueue,
  retry,
  sent,
  failed,
  uncertain,
  reprint,
  mirror;

  static PrintAuditAction fromStorage(String? value) {
    return PrintAuditAction.values.firstWhere(
      (action) => action.name == value,
      orElse: () => PrintAuditAction.enqueue,
    );
  }
}

/// One immutable receipt snapshot plus its durable delivery metadata.
class PrintJob {
  const PrintJob({
    required this.id,
    required this.saleId,
    required this.saleReference,
    required this.outletId,
    required this.deviceId,
    required this.receipt,
    required this.state,
    required this.copy,
    required this.attempts,
    required this.createdAt,
    required this.updatedAt,
    this.printerConfigId,
    this.printerConfig,
    this.lastError,
    this.serverMirrored = false,
  });

  final String id;
  final String saleId;
  final String saleReference;
  final String outletId;
  final String deviceId;
  final String? printerConfigId;
  final PrinterConfig? printerConfig;
  final ReceiptData receipt;
  final PrintJobState state;
  final bool copy;
  final int attempts;
  final String? lastError;
  final bool serverMirrored;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get active =>
      state == PrintJobState.queued ||
      state == PrintJobState.sending ||
      state == PrintJobState.failed ||
      state == PrintJobState.uncertain;

  PrintJob copyWith({
    PrintJobState? state,
    int? attempts,
    String? lastError,
    bool clearLastError = false,
    bool? serverMirrored,
    PrinterConfig? printerConfig,
    DateTime? updatedAt,
  }) {
    return PrintJob(
      id: id,
      saleId: saleId,
      saleReference: saleReference,
      outletId: outletId,
      deviceId: deviceId,
      printerConfigId: printerConfigId,
      printerConfig: printerConfig ?? this.printerConfig,
      receipt: receipt,
      state: state ?? this.state,
      copy: copy,
      attempts: attempts ?? this.attempts,
      lastError: clearLastError ? null : (lastError ?? this.lastError),
      serverMirrored: serverMirrored ?? this.serverMirrored,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

class PrintAuditEntry {
  const PrintAuditEntry({
    required this.jobId,
    required this.saleId,
    required this.action,
    required this.actorId,
    required this.actorEmail,
    required this.copy,
    required this.detail,
    required this.createdAt,
  });

  final String jobId;
  final String saleId;
  final PrintAuditAction action;
  final String actorId;
  final String actorEmail;
  final bool copy;
  final String detail;
  final DateTime createdAt;
}

/// Bounded retry policy for known-not-sent failures only.
///
/// Ambiguous delivery (`uncertain`) is never auto-resubmitted. The manual
/// recovery path is a visible COPY reprint that the cashier chooses.
abstract final class PrintRetryPolicy {
  static const maxAttempts = 5;
  static const maxAutomaticAttempts = 3;

  static Duration delayForAttempt(int attempt) {
    if (attempt <= 1) {
      return const Duration(seconds: 5);
    }
    if (attempt == 2) {
      return const Duration(seconds: 15);
    }
    return const Duration(seconds: 60);
  }

  static bool shouldAutoRetry(PrintJob job) {
    return job.state == PrintJobState.failed &&
        job.attempts < maxAutomaticAttempts &&
        job.attempts < maxAttempts;
  }

  static bool canRetry(PrintJob job) {
    return job.state == PrintJobState.failed && job.attempts < maxAttempts;
  }
}
