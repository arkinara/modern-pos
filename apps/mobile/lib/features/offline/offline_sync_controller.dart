import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modern_pos_api_client/api.dart' hide PrintJob;

import '../checkout/checkout_gateway.dart';
import '../checkout/checkout_models.dart';
import 'offline_sale_models.dart';
import 'offline_sale_store.dart';

class OfflineSyncState {
  const OfflineSyncState({
    this.records = const [],
    this.running = false,
    this.message,
    this.reconciliation,
    this.error,
    this.loadFailed = false,
  });

  final List<OfflineSaleRecord> records;
  final bool running;
  final String? message;
  final OfflineReconciliation? reconciliation;
  final String? error;
  final bool loadFailed;

  OfflineSyncSummary get summary => OfflineSyncSummary.fromRecords(records);

  List<OfflineSaleRecord> get active =>
      records.where((record) => record.isActive).toList(growable: false);

  OfflineSyncState copyWith({
    List<OfflineSaleRecord>? records,
    bool? running,
    String? message,
    OfflineReconciliation? reconciliation,
    String? error,
    bool? loadFailed,
    bool clearMessage = false,
    bool clearError = false,
    bool clearReconciliation = false,
  }) {
    return OfflineSyncState(
      records: records ?? this.records,
      running: running ?? this.running,
      message: clearMessage ? null : (message ?? this.message),
      reconciliation: clearReconciliation
          ? null
          : (reconciliation ?? this.reconciliation),
      error: clearError ? null : (error ?? this.error),
      loadFailed: loadFailed ?? this.loadFailed,
    );
  }
}

final offlineSyncControllerProvider =
    AsyncNotifierProvider<OfflineSyncController, OfflineSyncState>(
      OfflineSyncController.new,
    );

/// Replays the encrypted queue in order. Only one replay may run at a time;
/// repeated taps and automatic triggers share the same in-process guard.
class OfflineSyncController extends AsyncNotifier<OfflineSyncState> {
  static const _maxAttempts = 8;
  static const _baseBackoff = Duration(seconds: 2);
  static const _maxBackoff = Duration(minutes: 5);

  bool _running = false;

  OfflineSaleStore get _store => ref.read(offlineSaleStoreProvider);

  CheckoutGateway get _gateway => ref.read(checkoutGatewayProvider);

  @override
  Future<OfflineSyncState> build() async {
    return _load();
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(_load);
  }

  Future<OfflineSyncState> _load() async {
    try {
      return OfflineSyncState(records: await _store.loadAll());
    } catch (error) {
      return OfflineSyncState(
        loadFailed: true,
        error:
            'The encrypted queue could not be read: $error. No plaintext '
            'fallback was attempted.',
      );
    }
  }

  Future<void> syncAll() async {
    if (_running) {
      return;
    }
    _running = true;
    final current = state.value ?? await _load();
    state = AsyncData(
      current.copyWith(running: true, clearError: true, clearMessage: true),
    );

    try {
      var records = await _store.loadAll();
      for (final stored in records) {
        if (!stored.isActive) {
          continue;
        }
        if (stored.state == OfflineSaleState.conflict) {
          continue;
        }
        final now = DateTime.now();
        var record = stored;
        if (record.state == OfflineSaleState.inFlight) {
          // A crash after claiming but before the result is an uncertain
          // outcome. Resolve it with sales_recover before any resubmission.
          await _store.markUncertain(
            record.idempotencyKey,
            'The previous sync was interrupted before a result was recorded.',
            now,
          );
          record = record.copyWith(
            state: OfflineSaleState.uncertain,
            lastError: 'The previous sync was interrupted before a result was recorded.',
            updatedAt: now,
          );
        }
        final due = record.nextAttemptAt;
        if (due != null && due.isAfter(now)) {
          continue;
        }
        if (!await _store.claim(record.idempotencyKey, now)) {
          continue;
        }
        await _syncRecord(record);
      }
      records = await _store.loadAll();
      state = AsyncData(
        OfflineSyncState(
          records: records,
          running: false,
          message: _messageFor(records),
        ),
      );
      if (records.any((record) => record.state == OfflineSaleState.synced)) {
        await reconcile(silent: true);
      }
    } catch (error) {
      state = AsyncData(
        (state.value ?? current).copyWith(
          running: false,
          error: 'Sync stopped: $error',
        ),
      );
    } finally {
      _running = false;
    }
  }

  Future<void> retry(String idempotencyKey) async {
    final record = await _store.loadById(idempotencyKey);
    if (record == null) {
      await refresh();
      return;
    }
    if (record.state == OfflineSaleState.synced) {
      await refresh();
      return;
    }
    await _store.requeue(idempotencyKey, DateTime.now());
    await refresh();
    await syncAll();
  }

  Future<void> discard(String idempotencyKey) async {
    await _store.markFailed(
      idempotencyKey,
      'Discarded by the cashier. The server never confirmed a sale for this '
      'key; keep the paper reconciliation.',
    );
    await refresh();
    if (state.value != null) {
      state = AsyncData(
        state.value!.copyWith(
          message: 'Offline sale removed from the active queue.',
        ),
      );
    }
  }

  Future<OfflineReconciliation?> reconcile({bool silent = false}) async {
    try {
      final records = await _store.loadAll();
      final synced = records
          .where((record) => record.state == OfflineSaleState.synced)
          .toList(growable: false);
      if (synced.isEmpty) {
        final empty = OfflineReconciliation(
          checkedAt: DateTime.now(),
          localSynced: 0,
          serverMatched: 0,
          missingKeys: const [],
          salesChecked: 0,
        );
        if (!silent && state.value != null) {
          state = AsyncData(state.value!.copyWith(reconciliation: empty));
        }
        return empty;
      }

      final serverOrderIds = <String>{};
      final serverReferences = <String>{};
      var salesChecked = 0;
      final outlets = synced.map((record) => record.payload.outletId).toSet();
      for (final outletId in outlets) {
        String? cursor;
        for (var page = 0; page < 20; page++) {
          final result = await _gateway.listSales(
            outletId: outletId,
            cursor: cursor,
            limit: 100,
          );
          for (final sale in result.items) {
            serverOrderIds.add(sale.orderId);
            serverReferences.add(sale.reference);
            salesChecked++;
          }
          final next = result.nextCursor;
          if (next == null || next == cursor) {
            break;
          }
          cursor = next;
        }
      }

      final missing = <String>[];
      for (final record in synced) {
        final orderId = record.payload.orderId;
        final reference = record.saleReference;
        final found =
            (orderId != null && serverOrderIds.contains(orderId)) ||
            (reference != null && serverReferences.contains(reference));
        if (!found) {
          missing.add(record.idempotencyKey);
        }
      }
      final report = OfflineReconciliation(
        checkedAt: DateTime.now(),
        localSynced: synced.length,
        serverMatched: synced.length - missing.length,
        missingKeys: List.unmodifiable(missing),
        salesChecked: salesChecked,
      );
      if (!silent && state.value != null) {
        state = AsyncData(
          state.value!.copyWith(
            reconciliation: report,
            message: report.matches
                ? 'Sales reconciliation matches the server.'
                : 'Sales reconciliation found ${missing.length} missing '
                      'sale(s). Do not delete local evidence.',
          ),
        );
      } else if (silent && state.value != null) {
        state = AsyncData(state.value!.copyWith(reconciliation: report));
      }
      return report;
    } catch (error) {
      if (!silent && state.value != null) {
        state = AsyncData(
          state.value!.copyWith(error: 'Reconciliation failed: $error'),
        );
      }
      return null;
    }
  }

  Future<void> _syncRecord(OfflineSaleRecord record) async {
    final key = record.idempotencyKey;
    var payload = record.payload;
    try {
      if (record.state == OfflineSaleState.uncertain) {
        try {
          final recovered = await _gateway.recover(
            outletId: payload.outletId,
            key: key,
            deviceId: payload.deviceId,
          );
          await _store.markSynced(key, recovered.sale.reference);
          return;
        } on CheckoutApiException catch (error) {
          if (error.statusCode == 404) {
            // Definitive: no sale for this key. Continue with the submission.
          } else if (error.statusCode == 409 &&
              error.code == 'IDEMPOTENCY_IN_PROGRESS') {
            await _store.markUncertain(
              key,
              'The server is still processing this checkout.',
              _nextAttempt(record.attempts),
            );
            return;
          } else {
            await _handleFailure(record, error);
            return;
          }
        }
      }

      if (!payload.hasServerDraft) {
        final order = await _gateway.createOrder(
          outletId: payload.outletId,
          deviceId: payload.deviceId,
          idempotencyKey: payload.orderKey,
          lines: payload.lines
              .map(
                (line) => OrderWriteLinesInner(
                  variantId: line.variantId,
                  quantity: line.quantity,
                ),
              )
              .toList(growable: false),
        );
        final quote = await _gateway.createQuote(
          outletId: payload.outletId,
          orderId: order.id,
          orderVersion: order.version,
        );
        final mismatch = _totalMismatch(payload, quote);
        if (mismatch != null) {
          await _store.markConflict(key, mismatch);
          return;
        }
        payload = payload.copyWith(
          orderId: order.id,
          quoteId: quote.id,
          orderVersion: order.version,
          amountMinor: quote.totals.totalMinor,
          totalMinor: quote.totals.totalMinor,
        );
        await _store.replacePayload(payload);
      }

      var quote = await _finalizeWithCurrentQuote(payload);
      if (quote == null) {
        // A fresh quote is required. This is only possible when the original
        // draft order still exists and its version is known.
        final orderId = payload.orderId;
        final orderVersion = payload.orderVersion;
        if (orderId == null || orderVersion == null) {
          await _store.markConflict(
            key,
            'The original quote expired and the draft order version is not '
            'available. Re-ring the sale; do not reuse the tender.',
          );
          return;
        }
        final refreshed = await _gateway.createQuote(
          outletId: payload.outletId,
          orderId: orderId,
          orderVersion: orderVersion,
        );
        final mismatch = _totalMismatch(payload, refreshed);
        if (mismatch != null) {
          await _store.markConflict(key, mismatch);
          return;
        }
        payload = payload.copyWith(
          quoteId: refreshed.id,
          amountMinor: refreshed.totals.totalMinor,
          totalMinor: refreshed.totals.totalMinor,
        );
        await _store.replacePayload(payload);
        quote = await _finalizeWithCurrentQuote(payload);
        if (quote == null) {
          await _store.markConflict(
            key,
            'The server rejected the refreshed quote.',
          );
          return;
        }
      }

      await _store.markSynced(key, quote.sale.reference);
    } on CheckoutApiException catch (error) {
      await _handleFailure(record, error);
    } catch (error) {
      await _store.markUncertain(
        key,
        'Unexpected sync failure: $error',
        _nextAttempt(record.attempts),
      );
    }
  }

  Future<Finalized?> _finalizeWithCurrentQuote(
    OfflineSalePayload payload,
  ) async {
    final orderId = payload.orderId;
    final quoteId = payload.quoteId;
    if (orderId == null || quoteId == null) {
      return null;
    }
    try {
      return await _gateway.finalize(
        outletId: payload.outletId,
        idempotencyKey: payload.idempotencyKey,
        payload: Finalize(
          deviceId: payload.deviceId,
          orderId: orderId,
          quoteId: quoteId,
          payment: payload.paymentFor(payload.amountMinor),
        ),
      );
    } on CheckoutApiException catch (error) {
      if (error.statusCode == 409 &&
          (error.code == 'QUOTE_EXPIRED' || error.code == 'QUOTE_STALE')) {
        return null;
      }
      rethrow;
    }
  }

  String? _totalMismatch(OfflineSalePayload payload, Quote quote) {
    if (quote.currency != payload.currency ||
        quote.currencyExponent != payload.currencyExponent) {
      return 'Server currency changed from ${payload.currency} to '
          '${quote.currency}. Cashier review is required.';
    }
    if (quote.totals.totalMinor != payload.totalMinor) {
      return 'Server total ${quote.totals.totalMinor} differs from the '
          'offline total ${payload.totalMinor}. Cashier must review the '
          'amount or refund before retrying.';
    }
    if (payload.tenderKind == TenderKind.cash &&
        payload.tenderedMinor < quote.totals.totalMinor) {
      return 'Tendered ${payload.tenderedMinor} is below the server total '
          '${quote.totals.totalMinor}. Collect the shortfall before retrying.';
    }
    return null;
  }

  Future<void> _handleFailure(
    OfflineSaleRecord record,
    CheckoutApiException error,
  ) async {
    final key = record.idempotencyKey;
    final nextAttempt = record.attempts + 1;
    final reason = _reason(error);

    if (error.statusCode == 409 && error.code == 'IDEMPOTENCY_IN_PROGRESS') {
      await _store.markUncertain(
        key,
        'The server is still processing this checkout. Resolve with the same '
        'key.',
        _nextAttempt(nextAttempt),
      );
      return;
    }
    if (error.statusCode == 409 && error.code == 'IDEMPOTENCY_CONFLICT') {
      await _store.markConflict(key, reason);
      return;
    }
    if (error.statusCode == 409 && error.code == 'ORDER_ALREADY_COMPLETED') {
      try {
        final recovered = await _gateway.recover(
          outletId: record.payload.outletId,
          key: key,
          deviceId: record.payload.deviceId,
        );
        await _store.markSynced(key, recovered.sale.reference);
        return;
      } on CheckoutApiException {
        await _store.markConflict(key, reason);
        return;
      }
    }
    if (error.statusCode != null && error.statusCode! >= 500) {
      await _store.markUncertain(key, reason, _nextAttempt(nextAttempt));
      return;
    }
    if (error.isOffline || error.code == 'NETWORK') {
      await _store.markPending(key, reason, _nextAttempt(nextAttempt));
      return;
    }
    if (error.code == 'NETWORK_TIMEOUT') {
      await _store.markUncertain(key, reason, _nextAttempt(nextAttempt));
      return;
    }
    if (!error.retryable &&
        error.statusCode != null &&
        error.statusCode! < 500) {
      if (error.statusCode == 401 || error.statusCode == 403) {
        await _store.markFailed(key, reason);
      } else {
        await _store.markConflict(key, reason);
      }
      return;
    }
    if (nextAttempt >= _maxAttempts) {
      await _store.markFailed(
        key,
        'Sync failed after $nextAttempt attempts. $reason',
      );
      return;
    }
    await _store.markUncertain(key, reason, _nextAttempt(nextAttempt));
  }

  String _reason(CheckoutApiException error) {
    final details = error.details.isEmpty
        ? ''
        : ' ${jsonEncode(error.details)}';
    final status = error.statusCode == null ? '' : ' (${error.statusCode})';
    return '${error.code}$status: ${error.message}$details';
  }

  DateTime _nextAttempt(int attempts) => DateTime.now().add(_backoff(attempts));

  Duration _backoff(int attempts) {
    final exponent = attempts.clamp(0, 8);
    final millis = _baseBackoff.inMilliseconds * (1 << exponent);
    return Duration(
      milliseconds: millis > _maxBackoff.inMilliseconds
          ? _maxBackoff.inMilliseconds
          : millis,
    );
  }

  String _messageFor(List<OfflineSaleRecord> records) {
    final summary = OfflineSyncSummary.fromRecords(records);
    if (summary.active > 0) {
      return '${summary.active} offline sale(s) still need attention.';
    }
    if (summary.synced > 0) {
      return 'All offline sales are confirmed on the server.';
    }
    return 'No offline sales are queued.';
  }
}
