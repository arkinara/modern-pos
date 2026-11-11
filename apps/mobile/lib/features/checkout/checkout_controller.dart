import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modern_pos_api_client/api.dart' hide PrintJob;

import '../../core/device_identity.dart';
import '../auth/auth_controller.dart';
import '../cart/cart_controller.dart';
import '../printing/print_job_models.dart';
import '../offline/offline_sale_models.dart';
import '../offline/offline_sale_store.dart';
import '../printing/print_queue_service.dart';
import 'checkout_gateway.dart';
import 'checkout_models.dart';
import 'checkout_repository.dart';

final checkoutControllerProvider =
    AsyncNotifierProvider<CheckoutController, CheckoutState>(
      CheckoutController.new,
    );

/// Coordinates the draft order, immutable quote and single finalize request.
///
/// The controller persists the checkout key and exact payload before the
/// network call. Any pending intent blocks a new sale until recovery resolves
/// it with the same key.
class CheckoutController extends AsyncNotifier<CheckoutState> {
  bool _writeInFlight = false;
  Timer? _pollTimer;
  int _pollAttempts = 0;
  int _notFoundConfirmations = 0;

  static const _maxPollAttempts = 15;
  static const _maxNotFoundConfirmations = 3;

  CheckoutRepository get _repository => ref.read(checkoutRepositoryProvider);

  CheckoutGateway get _gateway => ref.read(checkoutGatewayProvider);

  OfflineSaleStore get _offlineStore => ref.read(offlineSaleStoreProvider);

  @override
  Future<CheckoutState> build() async {
    ref.onDispose(() => _pollTimer?.cancel());
    final pending = await ref.watch(checkoutRepositoryProvider).loadPending();
    if (pending != null) {
      return CheckoutState(
        phase: CheckoutPhase.recovering,
        pending: pending,
        message: 'An earlier checkout has an unknown outcome.',
      );
    }
    return const CheckoutState();
  }

  Future<String> _requireOutletId() async {
    final session = await ref.read(authControllerProvider.future);
    final outletIds = session?.user.outletIds ?? const <String>[];
    if (outletIds.isEmpty) {
      throw const CheckoutApiException(
        code: 'NO_OUTLET',
        message: 'This session has no authorized outlet.',
      );
    }
    return outletIds.first;
  }

  /// Creates a fresh draft order and quote. Online confirmation is required;
  /// the cart stays on the device when the server cannot be reached.
  Future<void> start() async {
    final current = await future;
    if (_writeInFlight) {
      return;
    }
    if (current.pending != null) {
      state = AsyncData(
        current.copyWith(
          phase: CheckoutPhase.blocked,
          message:
              'Resolve the earlier checkout before starting a new sale. '
              'Its outcome is not known yet.',
        ),
      );
      return;
    }
    if (current.isBusy) {
      return;
    }

    _writeInFlight = true;
    _notFoundConfirmations = 0;
    state = AsyncData(
      current.copyWith(
        phase: CheckoutPhase.preparing,
        clearMessage: true,
        clearPrintMessage: true,
        clearPending: true,
        clearQuote: true,
        clearSale: true,
        clearOrder: true,
        serverConfirmed: false,
        enteredMinor: 0,
        reference: '',
      ),
    );

    try {
      final cart = await ref.read(cartControllerProvider.future);
      if (cart.lines.isEmpty) {
        throw const CheckoutApiException(
          code: 'EMPTY_CART',
          message: 'Add at least one item before checkout.',
        );
      }

      final outletId = await _requireOutletId();
      final deviceId = await ref.read(deviceIdentityProvider).deviceId();
      final online = await _gateway.ping();
      if (!online) {
        throw const CheckoutApiException(
          code: 'OFFLINE',
          message:
              'No confirmed server connection. Reconnect to complete this '
              'sale; the cart is saved on this device.',
          retryable: true,
        );
      }

      final orderKey = generateUuidV4();
      final order = await _gateway.createOrder(
        outletId: outletId,
        deviceId: deviceId,
        idempotencyKey: orderKey,
        lines: cart.lines
            .map(
              (line) => OrderWriteLinesInner(
                variantId: line.variantId,
                quantity: line.quantity,
              ),
            )
            .toList(growable: false),
      );
      final quote = await _gateway.createQuote(
        outletId: outletId,
        orderId: order.id,
        orderVersion: order.version,
      );

      state = AsyncData(
        CheckoutState(
          phase: CheckoutPhase.awaitingTender,
          order: order,
          quote: quote,
          serverConfirmed: true,
          orderKey: orderKey,
        ),
      );
    } on CheckoutApiException catch (error) {
      state = AsyncData(
        CheckoutState(
          phase: CheckoutPhase.error,
          message: _actionableMessage(error),
        ),
      );
    } catch (_) {
      state = const AsyncData(
        CheckoutState(
          phase: CheckoutPhase.error,
          message:
              'Checkout could not start. Your cart is still saved on this '
              'device. Retry when the connection is stable.',
        ),
      );
    } finally {
      _writeInFlight = false;
    }
  }

  /// Fetches a new quote after the server reports QUOTE_EXPIRED or QUOTE_STALE.
  /// The cashier must review the new total and submit again; nothing is
  /// re-priced or re-submitted silently.
  Future<void> refreshQuote() async {
    final current = await future;
    if (_writeInFlight) {
      return;
    }
    final order = current.order;
    if (order == null) {
      await start();
      return;
    }

    _writeInFlight = true;
    try {
      final quote = await _gateway.createQuote(
        outletId: await _requireOutletId(),
        orderId: order.id,
        orderVersion: order.version,
      );
      state = AsyncData(
        current.copyWith(
          phase: CheckoutPhase.awaitingTender,
          quote: quote,
          clearPending: true,
          enteredMinor: 0,
          reference: '',
          serverConfirmed: true,
          message:
              'A new quote was loaded. Review the amount before submitting.',
        ),
      );
    } on CheckoutApiException catch (error) {
      state = AsyncData(
        current.copyWith(
          phase: CheckoutPhase.error,
          message: _actionableMessage(error),
        ),
      );
    } finally {
      _writeInFlight = false;
    }
  }

  void setTenderKind(TenderKind kind) {
    final current = state.value;
    if (current == null || !_isEditable(current)) {
      return;
    }
    state = AsyncData(
      current.copyWith(tenderKind: kind, enteredMinor: 0, clearMessage: true),
    );
  }

  void appendDigit(String digit) {
    final current = state.value;
    if (current == null || !_isEditable(current)) {
      return;
    }
    if (digit.length != 1 || int.tryParse(digit) == null) {
      return;
    }
    final text = '${current.enteredMinor}$digit';
    final value = int.tryParse(text);
    if (value == null || text.length > 15) {
      return;
    }
    state = AsyncData(current.copyWith(enteredMinor: value));
  }

  void backspace() {
    final current = state.value;
    if (current == null || !_isEditable(current)) {
      return;
    }
    final text = current.enteredMinor.toString();
    final next = text.length <= 1
        ? 0
        : int.tryParse(text.substring(0, text.length - 1));
    state = AsyncData(current.copyWith(enteredMinor: next ?? 0));
  }

  void clearEntered() {
    final current = state.value;
    if (current == null || !_isEditable(current)) {
      return;
    }
    state = AsyncData(current.copyWith(enteredMinor: 0));
  }

  void useExactAmount() {
    final current = state.value;
    if (current == null || !_isEditable(current)) {
      return;
    }
    state = AsyncData(current.copyWith(enteredMinor: current.dueMinor));
  }

  void setReference(String value) {
    final current = state.value;
    if (current == null || !_isEditable(current)) {
      return;
    }
    state = AsyncData(current.copyWith(reference: value));
  }

  bool _isEditable(CheckoutState current) {
    return current.phase == CheckoutPhase.awaitingTender &&
        !current.isBusy &&
        current.serverConfirmed;
  }

  /// Sends the finalize request exactly once. The key and exact payload are
  /// written to Drift before the request leaves the device.
  Future<void> submit() async {
    if (_writeInFlight) {
      return;
    }
    final current = state.value;
    if (current == null) {
      return;
    }
    final quote = current.quote;
    final order = current.order;
    if (current.phase != CheckoutPhase.awaitingTender ||
        quote == null ||
        order == null) {
      return;
    }
    if (!current.serverConfirmed) {
      state = AsyncData(
        current.copyWith(
          phase: CheckoutPhase.blocked,
          message:
              'No confirmed server connection. Reconnect before completing '
              'the sale; the cart remains on this device.',
        ),
      );
      return;
    }
    if (!current.tenderSufficient) {
      state = AsyncData(
        current.copyWith(
          message: current.tenderKind == TenderKind.cash
              ? 'Tender is less than the amount due.'
              : 'Manual external amount must equal the amount due.',
        ),
      );
      return;
    }

    _writeInFlight = true;
    PendingCheckout? pending;
    try {
      final payment = PaymentDraft(
        kind: current.tenderKind,
        amountMinor: quote.totals.totalMinor,
        tenderedMinor: current.tenderKind == TenderKind.cash
            ? current.enteredMinor
            : null,
        reference: current.tenderKind == TenderKind.manualExternal
            ? _optionalReference(current.reference)
            : null,
      );
      pending = PendingCheckout(
        idempotencyKey: generateUuidV4(),
        deviceId: await ref.read(deviceIdentityProvider).deviceId(),
        outletId: await _requireOutletId(),
        orderId: order.id,
        quoteId: quote.id,
        payment: payment,
        totalMinor: quote.totals.totalMinor,
        currency: quote.currency,
        currencyExponent: quote.currencyExponent,
        createdAt: DateTime.now(),
        orderKey: current.orderKey ?? generateUuidV4(),
        orderVersion: order.version,
      );

      await _repository.savePending(pending);
      state = AsyncData(
        current.copyWith(
          phase: CheckoutPhase.submitting,
          pending: pending,
          clearMessage: true,
        ),
      );

      final finalized = await _gateway.finalize(
        outletId: pending.outletId,
        idempotencyKey: pending.idempotencyKey,
        payload: pending.toFinalize(),
      );
      await _completeSale(finalized, pending);
    } on CheckoutApiException catch (error) {
      await _handleSubmitError(error, pending);
    } catch (_) {
      if (pending != null) {
        await _offlineStore.markUncertain(
          pending.idempotencyKey,
          'The sale outcome is unknown. Resolve with the same checkout key.',
          DateTime.now().add(const Duration(seconds: 2)),
        );
        state = AsyncData(
          (state.value ?? current).copyWith(
            phase: CheckoutPhase.blocked,
            pending: pending,
            message:
                'The sale outcome is unknown. Reconnect and check the server '
                'with the same checkout key before trying again.',
          ),
        );
      }
    } finally {
      _writeInFlight = false;
    }
  }

  /// Captures a sale from the local cart while the API is unreachable. The
  /// encrypted queue holds the exact lines and tender. At sync the server
  /// creates the draft order and quote; a changed total or insufficient stock
  /// becomes a visible conflict instead of a silent second sale.
  Future<void> queueOfflineSale() async {
    if (_writeInFlight) {
      return;
    }
    final current = await future;
    final cart = await ref.read(cartControllerProvider.future);
    if (cart.lines.isEmpty) {
      state = AsyncData(
        current.copyWith(
          phase: CheckoutPhase.blocked,
          message: 'Add at least one item before recording an offline sale.',
        ),
      );
      return;
    }

    _writeInFlight = true;
    try {
      final outletId = await _requireOutletId();
      final deviceId = await ref.read(deviceIdentityProvider).deviceId();
      final first = cart.lines.first;
      final totalMinor = cart.totalMinor;
      final payload = OfflineSalePayload(
        idempotencyKey: generateUuidV4(),
        orderKey: generateUuidV4(),
        outletId: outletId,
        deviceId: deviceId,
        lines: cart.lines
            .map(
              (line) => OfflineSaleLine(
                variantId: line.variantId,
                name: line.itemName,
                variantName: line.variantName,
                quantity: line.quantity,
                unitPriceMinor: line.unitPriceMinor,
              ),
            )
            .toList(growable: false),
        tenderKind: TenderKind.cash,
        amountMinor: totalMinor,
        tenderedMinor: totalMinor,
        reference: null,
        totalMinor: totalMinor,
        currency: first.currency,
        currencyExponent: first.currencyExponent,
        createdAt: DateTime.now(),
      );
      await _offlineStore.upsert(payload);
      await ref.read(cartRepositoryProvider).clear();
      ref.invalidate(cartControllerProvider);
      state = AsyncData(
        CheckoutState(
          phase: CheckoutPhase.queuedOffline,
          offlineKey: payload.idempotencyKey,
          offlineTotalMinor: totalMinor,
          message:
              'Offline sale saved as cash at the local cart total. The server '
              'confirms price, tax, service and stock during sync. If the total '
              'changed, the sale becomes a conflict and must be reviewed.',
        ),
      );
    } catch (error) {
      state = AsyncData(
        current.copyWith(
          phase: CheckoutPhase.blocked,
          message:
              'The offline sale could not be stored encryptedly: $error. '
              'Do not take payment; retry after checking device storage.',
        ),
      );
    } finally {
      _writeInFlight = false;
    }
  }

  String? _optionalReference(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  /// Retries the exact same key and payload after a retryable failure.
  Future<void> retrySameKey() async {
    if (_writeInFlight) {
      return;
    }
    final current = state.value;
    if (current == null) {
      return;
    }
    final pending = current.pending;
    if (pending == null) {
      return;
    }

    _writeInFlight = true;
    state = AsyncData(
      current.copyWith(
        phase: CheckoutPhase.submitting,
        message: 'Retrying with the same checkout key.',
      ),
    );
    try {
      final finalized = await _gateway.finalize(
        outletId: pending.outletId,
        idempotencyKey: pending.idempotencyKey,
        payload: pending.toFinalize(),
      );
      await _completeSale(finalized, pending);
    } on CheckoutApiException catch (error) {
      await _handleSubmitError(error, pending);
    } catch (_) {
      state = AsyncData(
        current.copyWith(
          phase: CheckoutPhase.blocked,
          pending: pending,
          message:
              'Still could not confirm the sale. The same key is retained; '
              'check again when the connection is stable.',
        ),
      );
    } finally {
      _writeInFlight = false;
    }
  }

  Future<void> _handleSubmitError(
    CheckoutApiException error,
    PendingCheckout? pending,
  ) async {
    final current = state.value ?? const CheckoutState();

    if (error.statusCode == 422) {
      if (pending != null) {
        await _repository.delete(pending.idempotencyKey);
      }
      state = AsyncData(
        current.copyWith(
          phase: CheckoutPhase.awaitingTender,
          clearPending: true,
          message: error.message,
        ),
      );
      return;
    }

    if (error.statusCode == 409 && error.code == 'QUOTE_EXPIRED') {
      await _deletePending(pending);
      state = AsyncData(
        current.copyWith(
          phase: CheckoutPhase.quoteExpired,
          clearPending: true,
          serverConfirmed: true,
          message:
              '${error.message} Request a fresh quote and review the new '
              'total before submitting again.',
        ),
      );
      return;
    }

    if (error.statusCode == 409 && error.code == 'QUOTE_STALE') {
      await _deletePending(pending);
      state = AsyncData(
        current.copyWith(
          phase: CheckoutPhase.quoteExpired,
          clearPending: true,
          serverConfirmed: true,
          message:
              '${error.message} Request a fresh quote and review the new '
              'total before submitting again.',
        ),
      );
      return;
    }

    if (error.statusCode == 409 && error.code == 'ORDER_ALREADY_COMPLETED') {
      await _deletePending(pending);
      await _clearCart();
      state = const AsyncData(
        CheckoutState(
          phase: CheckoutPhase.error,
          serverConfirmed: true,
          message:
              'This order was already completed on the server. Do not ring '
              'it again; check the sale history for the reference.',
        ),
      );
      return;
    }

    if (error.statusCode == 409 && error.code == 'IDEMPOTENCY_CONFLICT') {
      if (pending != null) {
        await _offlineStore.markConflict(
          pending.idempotencyKey,
          '${error.message} The key was reused with a different payload.',
        );
      }
      state = AsyncData(
        current.copyWith(
          phase: CheckoutPhase.blocked,
          pending: pending ?? current.pending,
          message:
              '${error.message} Use Check again; do not submit a new sale.',
        ),
      );
      return;
    }

    if (error.statusCode == 409 && error.code == 'IDEMPOTENCY_IN_PROGRESS') {
      if (pending != null) {
        await _offlineStore.markUncertain(
          pending.idempotencyKey,
          'The server is still processing this checkout.',
          DateTime.now().add(const Duration(seconds: 2)),
        );
      }
      state = AsyncData(
        current.copyWith(
          phase: CheckoutPhase.inFlight,
          pending: pending ?? current.pending,
          message:
              'The server is still processing this checkout. Wait for the '
              'result; do not submit again.',
        ),
      );
      _schedulePoll();
      return;
    }

    if (pending != null) {
      if (error.retryable || error.isOffline) {
        await _offlineStore.markUncertain(
          pending.idempotencyKey,
          error.message,
          DateTime.now().add(const Duration(seconds: 2)),
        );
      } else {
        await _offlineStore.markConflict(
          pending.idempotencyKey,
          '${error.code}: ${error.message}',
        );
      }
    }
    state = AsyncData(
      current.copyWith(
        phase: CheckoutPhase.blocked,
        pending: pending ?? current.pending,
        message: error.retryable || error.isOffline
            ? 'The sale outcome is unknown. Reconnect and check the server '
                  'with the same checkout key; do not start a new sale.'
            : error.message,
      ),
    );
  }

  Future<void> _deletePending(PendingCheckout? pending) async {
    if (pending != null) {
      await _repository.delete(pending.idempotencyKey);
    }
  }

  /// First action after a timeout, kill or restart. A 404 is the only answer
  /// that permits a new attempt; in-flight and unknown answers keep blocking.
  Future<void> recoverPending() async {
    if (_writeInFlight) {
      return;
    }
    final current = await future;
    final pending = current.pending ?? await _repository.loadPending();
    if (pending == null) {
      state = const AsyncData(CheckoutState());
      return;
    }

    _writeInFlight = true;
    state = AsyncData(
      current.copyWith(
        phase: CheckoutPhase.recovering,
        pending: pending,
        message: 'Checking the server for the earlier checkout.',
      ),
    );

    try {
      final finalized = await _gateway.recover(
        outletId: pending.outletId,
        key: pending.idempotencyKey,
        deviceId: pending.deviceId,
      );
      await _completeSale(finalized, pending);
    } on CheckoutApiException catch (error) {
      if (error.statusCode == 404) {
        _notFoundConfirmations++;
        if (_notFoundConfirmations < _maxNotFoundConfirmations) {
          state = AsyncData(
            current.copyWith(
              phase: CheckoutPhase.inFlight,
              pending: pending,
              message:
                  'The server has no completed sale for this key yet. '
                  'Rechecking before permitting a new attempt; do not submit '
                  'a new sale.',
            ),
          );
          _schedulePoll();
        } else {
          await _repository.markFailed(pending.idempotencyKey);
          _pollTimer?.cancel();
          _pollAttempts = 0;
          _notFoundConfirmations = 0;
          state = const AsyncData(
            CheckoutState(
              phase: CheckoutPhase.idle,
              message:
                  'The server did not record the earlier attempt. You can start '
                  'a new sale; it will use a new checkout key.',
            ),
          );
        }
      } else if (error.statusCode == 409 &&
          error.code == 'IDEMPOTENCY_IN_PROGRESS') {
        _notFoundConfirmations = 0;
        state = AsyncData(
          current.copyWith(
            phase: CheckoutPhase.inFlight,
            pending: pending,
            message:
                'The server is still processing the earlier checkout. '
                'Waiting; do not submit again.',
          ),
        );
        _schedulePoll();
      } else if (error.isOffline) {
        await _offlineStore.markUncertain(
          pending.idempotencyKey,
          error.message,
          DateTime.now().add(const Duration(seconds: 2)),
        );
        state = AsyncData(
          current.copyWith(
            phase: CheckoutPhase.blocked,
            pending: pending,
            message:
                'Could not confirm the earlier sale. Reconnect and check '
                'again; the same key is retained.',
          ),
        );
      } else {
        await _offlineStore.markUncertain(
          pending.idempotencyKey,
          error.message,
          DateTime.now().add(const Duration(seconds: 2)),
        );
        state = AsyncData(
          current.copyWith(
            phase: CheckoutPhase.blocked,
            pending: pending,
            message: error.message,
          ),
        );
      }
    } finally {
      _writeInFlight = false;
    }
  }

  void _schedulePoll() {
    _pollTimer?.cancel();
    if (_pollAttempts >= _maxPollAttempts) {
      final current = state.value;
      if (current != null) {
        state = AsyncData(
          current.copyWith(
            phase: CheckoutPhase.blocked,
            message:
                'The server is still processing the checkout. Tap Check again '
                'to poll; do not submit a new sale.',
          ),
        );
      }
      return;
    }
    _pollAttempts++;
    _pollTimer = Timer(const Duration(seconds: 2), () {
      final current = state.value;
      if (current == null) {
        return;
      }
      if (current.phase == CheckoutPhase.inFlight ||
          (current.phase == CheckoutPhase.blocked && current.pending != null)) {
        unawaited(recoverPending());
      }
    });
  }

  /// After the receipt is acknowledged the client returns to a clean state.
  void acknowledge() {
    _pollTimer?.cancel();
    _pollAttempts = 0;
    _notFoundConfirmations = 0;
    state = const AsyncData(CheckoutState());
  }

  Future<void> _completeSale(
    Finalized finalized,
    PendingCheckout pending,
  ) async {
    _pollTimer?.cancel();
    _pollAttempts = 0;
    _notFoundConfirmations = 0;
    final sale = finalized.sale;
    await _repository.markConfirmed(pending.idempotencyKey, sale.reference);
    state = AsyncData(
      CheckoutState(
        phase: CheckoutPhase.completed,
        pending: pending.copyWith(
          status: PendingCheckoutStatus.confirmed,
          saleReference: sale.reference,
        ),
        sale: sale,
        serverConfirmed: true,
        replayed: finalized.replayed,
      ),
    );
    await _clearCart();
    await _printBestEffort(sale, pending);
  }

  Future<void> _clearCart() async {
    try {
      await ref.read(cartRepositoryProvider).clear();
      ref.invalidate(cartControllerProvider);
    } catch (_) {
      // The sale is already committed; a local cart cleanup failure must not
      // change the checkout outcome.
    }
  }

  Future<void> _printBestEffort(Sale sale, PendingCheckout pending) async {
    try {
      final service = ref.read(printQueueServiceProvider);
      final job = await service.enqueueSale(
        sale: sale,
        outletId: pending.outletId,
        deviceId: pending.deviceId,
      );
      final processed = await service.processJob(job.id);
      _mergePrintResult(sale, processed);
    } catch (_) {
      _mergePrintMessage(
        sale,
        'Sale completed, but the receipt could not be queued. The sale is '
        'final; do not repeat checkout.',
      );
    }
  }

  void _mergePrintResult(Sale sale, PrintJob job) {
    final current = state.value;
    if (current == null ||
        current.sale == null ||
        current.sale!.id != sale.id) {
      return;
    }
    state = AsyncData(
      current.copyWith(printJob: job, printMessage: _printMessage(job)),
    );
  }

  String _printMessage(PrintJob job) {
    return switch (job.state) {
      PrintJobState.sent =>
        'Sale completed. Receipt sent to the printer. Paper delivery is not '
            'verified.',
      PrintJobState.failed =>
        'Sale completed, but the receipt could not print. Retry the print job '
            'from Settings > Print queue; do not repeat checkout.',
      PrintJobState.uncertain =>
        'Sale completed, but the receipt could not print with confirmed '
            'delivery. Delivery is unknown; use Reprint COPY if paper is '
            'missing. Do not repeat checkout.',
      PrintJobState.queued =>
        'Sale completed. The receipt is queued. '
            '${job.lastError ?? 'Configure a printer, then retry the job.'}',
      PrintJobState.sending =>
        'Sale completed. The receipt is being sent to the printer.',
    };
  }

  void _mergePrintMessage(Sale sale, String message) {
    final current = state.value;
    if (current == null ||
        current.sale == null ||
        current.sale!.id != sale.id) {
      return;
    }
    state = AsyncData(current.copyWith(printMessage: message));
  }

  /// Retries a known-not-sent failure. An uncertain job is deliberately
  /// converted into a COPY reprint rather than silently resent.
  Future<void> retryPrint() async {
    final current = state.value;
    final job = current?.printJob;
    if (current == null || job == null) {
      return;
    }
    final service = ref.read(printQueueServiceProvider);
    try {
      final result = job.state == PrintJobState.uncertain
          ? await service.reprintJob(job.id)
          : await service.retryJob(job.id);
      state = AsyncData(
        current.copyWith(printJob: result, printMessage: _printMessage(result)),
      );
    } catch (_) {
      state = AsyncData(
        current.copyWith(
          printMessage:
              'The print job could not be retried. Check the printer and try '
              'again from Settings > Print queue.',
        ),
      );
    }
  }

  /// Manual reprint from the completed-sale view. The output is marked COPY
  /// and the action is appended to the local audit trail.
  Future<void> reprintCopy() async {
    final current = state.value;
    final sale = current?.sale;
    final pending = current?.pending;
    if (current == null || sale == null || pending == null) {
      return;
    }
    final service = ref.read(printQueueServiceProvider);
    try {
      final result = await service.reprintSale(
        sale: sale,
        outletId: pending.outletId,
        deviceId: pending.deviceId,
      );
      state = AsyncData(
        current.copyWith(printJob: result, printMessage: _printMessage(result)),
      );
    } catch (_) {
      state = AsyncData(
        current.copyWith(
          printMessage:
              'The COPY reprint could not be queued. Check the printer and '
              'try again from Settings > Print queue.',
        ),
      );
    }
  }

  String _actionableMessage(CheckoutApiException error) {
    if (error.isOffline) {
      return 'No confirmed server connection. Reconnect to complete this '
          'sale; the cart is saved on this device.';
    }
    return error.message;
  }
}
