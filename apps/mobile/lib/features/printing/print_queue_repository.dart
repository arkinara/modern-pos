import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/providers.dart';
import 'esc_pos_receipt.dart';
import 'print_job_models.dart';
import 'printer_models.dart';

/// Durable boundary for the local print queue and its audit trail. The Drift
/// implementation is the production store; tests substitute an in-memory
/// implementation and can therefore prove restart survival without plugins.
abstract interface class PrintQueueRepository {
  Future<void> save(PrintJob job);

  Future<void> update(PrintJob job);

  Future<PrintJob?> byId(String id);

  Future<PrintJob?> findOriginalForSale(String saleId);

  Future<List<PrintJob>> loadJobs();

  Future<List<PrintJob>> loadActive();

  Future<void> appendAudit(PrintAuditEntry entry);

  Future<List<PrintAuditEntry>> loadAudits({String? saleId});
}

class DriftPrintQueueRepository implements PrintQueueRepository {
  DriftPrintQueueRepository(this._database);

  final AppDatabase _database;

  @override
  Future<void> save(PrintJob job) async {
    await _database
        .into(_database.printQueueJobs)
        .insertOnConflictUpdate(_companion(job));
  }

  @override
  Future<void> update(PrintJob job) async {
    await (_database.update(
      _database.printQueueJobs,
    )..where((table) => table.id.equals(job.id))).write(_companion(job));
  }

  @override
  Future<PrintJob?> byId(String id) async {
    final query = _database.select(_database.printQueueJobs)
      ..where((table) => table.id.equals(id));
    final row = await query.getSingleOrNull();
    return row == null ? null : _toJob(row);
  }

  @override
  Future<PrintJob?> findOriginalForSale(String saleId) async {
    final query = _database.select(_database.printQueueJobs)
      ..where((table) => table.saleId.equals(saleId) & table.copy.equals(false))
      ..orderBy([(table) => OrderingTerm.asc(table.createdAt)])
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row == null ? null : _toJob(row);
  }

  @override
  Future<List<PrintJob>> loadJobs() async {
    final query = _database.select(_database.printQueueJobs)
      ..orderBy([(table) => OrderingTerm.desc(table.createdAt)]);
    final rows = await query.get();
    return rows.map(_toJob).toList(growable: false);
  }

  @override
  Future<List<PrintJob>> loadActive() async {
    final states = [
      PrintJobState.queued.storageName,
      PrintJobState.sending.storageName,
      PrintJobState.failed.storageName,
      PrintJobState.uncertain.storageName,
    ];
    final query = _database.select(_database.printQueueJobs)
      ..where((table) => table.state.isIn(states))
      ..orderBy([(table) => OrderingTerm.asc(table.createdAt)]);
    final rows = await query.get();
    return rows.map(_toJob).toList(growable: false);
  }

  @override
  Future<void> appendAudit(PrintAuditEntry entry) async {
    await _database
        .into(_database.printQueueAudits)
        .insert(
          PrintQueueAuditsCompanion.insert(
            jobId: entry.jobId,
            saleId: entry.saleId,
            action: entry.action.name,
            actorId: entry.actorId,
            actorEmail: entry.actorEmail,
            copy: Value(entry.copy),
            detail: Value(entry.detail),
            createdAt: Value(entry.createdAt),
          ),
        );
  }

  @override
  Future<List<PrintAuditEntry>> loadAudits({String? saleId}) async {
    final query = _database.select(_database.printQueueAudits);
    if (saleId != null) {
      query.where((table) => table.saleId.equals(saleId));
    }
    query.orderBy([(table) => OrderingTerm.desc(table.createdAt)]);
    final rows = await query.get();
    return rows
        .map(
          (row) => PrintAuditEntry(
            jobId: row.jobId,
            saleId: row.saleId,
            action: PrintAuditAction.fromStorage(row.action),
            actorId: row.actorId,
            actorEmail: row.actorEmail,
            copy: row.copy,
            detail: row.detail,
            createdAt: row.createdAt,
          ),
        )
        .toList(growable: false);
  }

  PrintQueueJobsCompanion _companion(PrintJob job) {
    return PrintQueueJobsCompanion(
      id: Value(job.id),
      saleId: Value(job.saleId),
      saleReference: Value(job.saleReference),
      outletId: Value(job.outletId),
      deviceId: Value(job.deviceId),
      printerConfigId: Value(job.printerConfigId),
      printerConfigJson: Value(
        job.printerConfig == null
            ? null
            : jsonEncode(job.printerConfig!.toJson()),
      ),
      receiptJson: Value(jsonEncode(job.receipt.toJson())),
      state: Value(job.state.storageName),
      copy: Value(job.copy),
      attempts: Value(job.attempts),
      lastError: Value(job.lastError),
      serverMirrored: Value(job.serverMirrored),
      createdAt: Value(job.createdAt),
      updatedAt: Value(job.updatedAt),
    );
  }

  PrintJob _toJob(PrintQueueJob row) {
    final receipt = ReceiptData.fromJson(_decode(row.receiptJson));
    final configJson = _decode(row.printerConfigJson);
    return PrintJob(
      id: row.id,
      saleId: row.saleId,
      saleReference: row.saleReference,
      outletId: row.outletId,
      deviceId: row.deviceId,
      printerConfigId: row.printerConfigId,
      printerConfig: configJson == null
          ? null
          : PrinterConfig.fromJson(configJson),
      receipt: receipt ?? _emptyReceipt(row.saleReference),
      state: PrintJobState.fromStorage(row.state),
      copy: row.copy,
      attempts: row.attempts,
      lastError: row.lastError,
      serverMirrored: row.serverMirrored,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  Map<String, Object?>? _decode(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    try {
      return (jsonDecode(value) as Map).cast<String, Object?>();
    } catch (_) {
      return null;
    }
  }

  ReceiptData _emptyReceipt(String reference) {
    return ReceiptData(
      outletName: 'Unknown outlet',
      items: const [],
      subtotalMinor: 0,
      totalMinor: 0,
      currency: 'IDR',
      currencyExponent: 0,
      reference: reference,
    );
  }
}

final printQueueRepositoryProvider = Provider<PrintQueueRepository>((ref) {
  return DriftPrintQueueRepository(ref.watch(appDatabaseProvider));
});
