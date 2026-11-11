import 'package:modern_pos_api_client/api.dart' hide PrintJob;

import '../../core/formatting/money.dart';
import '../printing/print_job_models.dart';

/// Tender kinds exposed by the contract. No card provider charge is made; the
/// manual kind only records an external payment that the cashier has seen.
enum TenderKind { cash, manualExternal }

extension TenderKindWire on TenderKind {
  PaymentInputKindEnum get wire {
    return switch (this) {
      TenderKind.cash => PaymentInputKindEnum.CASH,
      TenderKind.manualExternal => PaymentInputKindEnum.MANUAL_EXTERNAL,
    };
  }

  String get label {
    return switch (this) {
      TenderKind.cash => 'Cash',
      TenderKind.manualExternal => 'Manual external',
    };
  }
}

/// Exact payment payload persisted with the checkout intent before the
/// finalize request is sent.
class PaymentDraft {
  const PaymentDraft({
    required this.kind,
    required this.amountMinor,
    this.tenderedMinor,
    this.reference,
  });

  final TenderKind kind;
  final int amountMinor;
  final int? tenderedMinor;
  final String? reference;

  PaymentInput toInput() {
    return PaymentInput(
      kind: kind.wire,
      amountMinor: amountMinor,
      tenderedMinor: tenderedMinor,
      reference: reference,
    );
  }

  Map<String, dynamic> toJson() => {
    'kind': kind.wire.toJson(),
    'amountMinor': amountMinor,
    if (tenderedMinor != null) 'tenderedMinor': tenderedMinor,
    if (reference != null) 'reference': reference,
  };

  static PaymentDraft? fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }
    final kind = PaymentInputKindEnum.fromJson(json['kind']);
    final amount = json['amountMinor'];
    if (kind == null || amount is! int) {
      return null;
    }
    return PaymentDraft(
      kind: kind == PaymentInputKindEnum.CASH
          ? TenderKind.cash
          : TenderKind.manualExternal,
      amountMinor: amount,
      tenderedMinor: json['tenderedMinor'] as int?,
      reference: json['reference'] as String?,
    );
  }
}

enum PendingCheckoutStatus { pending, confirmed, failed }

/// A checkout key and its exact submitted payload. Written to Drift before the
/// network call so a kill or timeout can be resolved with the same key.
class PendingCheckout {
  const PendingCheckout({
    required this.idempotencyKey,
    required this.deviceId,
    required this.outletId,
    required this.orderId,
    required this.quoteId,
    required this.payment,
    required this.totalMinor,
    required this.currency,
    required this.currencyExponent,
    required this.createdAt,
    this.status = PendingCheckoutStatus.pending,
    this.saleReference,
    this.orderKey = '',
    this.orderVersion,
  });

  final String idempotencyKey;
  final String deviceId;
  final String outletId;
  final String orderId;
  final String quoteId;
  final PaymentDraft payment;
  final int totalMinor;
  final String currency;
  final int currencyExponent;
  final DateTime createdAt;
  final PendingCheckoutStatus status;
  final String? saleReference;
  final String orderKey;
  final int? orderVersion;

  MoneyFormat get money =>
      MoneyFormat(currency: currency, currencyExponent: currencyExponent);

  Finalize toFinalize() {
    return Finalize(
      deviceId: deviceId,
      orderId: orderId,
      quoteId: quoteId,
      payment: payment.toInput(),
    );
  }

  PendingCheckout copyWith({
    PendingCheckoutStatus? status,
    String? saleReference,
  }) {
    return PendingCheckout(
      idempotencyKey: idempotencyKey,
      deviceId: deviceId,
      outletId: outletId,
      orderId: orderId,
      quoteId: quoteId,
      payment: payment,
      totalMinor: totalMinor,
      currency: currency,
      currencyExponent: currencyExponent,
      createdAt: createdAt,
      status: status ?? this.status,
      saleReference: saleReference ?? this.saleReference,
      orderKey: orderKey,
      orderVersion: orderVersion,
    );
  }
}

/// Client-side checkout state machine. `COMPLETING`, `RECOVERING` and
/// `UNKNOWN` are UI states; only the server proves sale outcome.
enum CheckoutPhase {
  idle,
  preparing,
  awaitingTender,
  submitting,
  recovering,
  inFlight,
  quoteExpired,
  queuedOffline,
  completed,
  blocked,
  error,
}

class CheckoutState {
  const CheckoutState({
    this.phase = CheckoutPhase.idle,
    this.pending,
    this.order,
    this.quote,
    this.sale,
    this.message,
    this.printMessage,
    this.printJob,
    this.tenderKind = TenderKind.cash,
    this.enteredMinor = 0,
    this.reference = '',
    this.serverConfirmed = false,
    this.replayed = false,
    this.offlineKey,
    this.offlineTotalMinor,
    this.orderKey,
  });

  final CheckoutPhase phase;
  final PendingCheckout? pending;
  final Order? order;
  final Quote? quote;
  final Sale? sale;
  final String? message;
  final String? printMessage;
  final PrintJob? printJob;
  final TenderKind tenderKind;
  final int enteredMinor;
  final String reference;
  final bool serverConfirmed;
  final bool replayed;
  final String? offlineKey;
  final int? offlineTotalMinor;
  final String? orderKey;

  bool get hasPending => pending != null;

  bool get isBusy =>
      phase == CheckoutPhase.preparing ||
      phase == CheckoutPhase.submitting ||
      phase == CheckoutPhase.recovering;

  bool get isComplete => phase == CheckoutPhase.completed && sale != null;

  MoneyFormat get money {
    final completed = sale;
    if (completed != null) {
      return MoneyFormat(
        currency: completed.currency,
        currencyExponent: completed.currencyExponent,
      );
    }
    final priced = quote;
    if (priced != null) {
      return MoneyFormat(
        currency: priced.currency,
        currencyExponent: priced.currencyExponent,
      );
    }
    return PendingCheckoutMoney.fallback;
  }

  int get dueMinor => sale?.totals.totalMinor ?? quote?.totals.totalMinor ?? 0;

  int get subtotalMinor =>
      sale?.totals.subtotalMinor ?? quote?.totals.subtotalMinor ?? 0;

  int get serviceMinor =>
      sale?.totals.serviceMinor ?? quote?.totals.serviceMinor ?? 0;

  int get taxMinor => sale?.totals.taxMinor ?? quote?.totals.taxMinor ?? 0;

  /// Cash change is never negative; shortfalls are surfaced separately.
  int get changeMinor {
    if (tenderKind != TenderKind.cash) {
      return 0;
    }
    final change = enteredMinor - dueMinor;
    return change > 0 ? change : 0;
  }

  int get shortfallMinor {
    if (tenderKind != TenderKind.cash) {
      return 0;
    }
    final shortfall = dueMinor - enteredMinor;
    return shortfall > 0 ? shortfall : 0;
  }

  bool get tenderSufficient {
    if (quote == null || phase == CheckoutPhase.submitting) {
      return false;
    }
    return switch (tenderKind) {
      TenderKind.cash => enteredMinor >= dueMinor,
      TenderKind.manualExternal => enteredMinor == dueMinor,
    };
  }

  bool get canSubmit =>
      phase == CheckoutPhase.awaitingTender &&
      serverConfirmed &&
      tenderSufficient &&
      !isBusy;

  CheckoutState copyWith({
    CheckoutPhase? phase,
    PendingCheckout? pending,
    Order? order,
    Quote? quote,
    Sale? sale,
    String? message,
    String? printMessage,
    PrintJob? printJob,
    TenderKind? tenderKind,
    int? enteredMinor,
    String? reference,
    bool? serverConfirmed,
    bool? replayed,
    String? offlineKey,
    int? offlineTotalMinor,
    String? orderKey,
    bool clearPending = false,
    bool clearQuote = false,
    bool clearSale = false,
    bool clearOrder = false,
    bool clearMessage = false,
    bool clearPrintMessage = false,
    bool clearPrintJob = false,
  }) {
    return CheckoutState(
      phase: phase ?? this.phase,
      pending: clearPending ? null : (pending ?? this.pending),
      order: clearOrder ? null : (order ?? this.order),
      quote: clearQuote ? null : (quote ?? this.quote),
      sale: clearSale ? null : (sale ?? this.sale),
      message: clearMessage ? null : (message ?? this.message),
      printMessage: clearPrintMessage
          ? null
          : (printMessage ?? this.printMessage),
      printJob: clearPrintJob ? null : (printJob ?? this.printJob),
      tenderKind: tenderKind ?? this.tenderKind,
      enteredMinor: enteredMinor ?? this.enteredMinor,
      reference: reference ?? this.reference,
      serverConfirmed: serverConfirmed ?? this.serverConfirmed,
      replayed: replayed ?? this.replayed,
      offlineKey: offlineKey ?? this.offlineKey,
      offlineTotalMinor: offlineTotalMinor ?? this.offlineTotalMinor,
      orderKey: orderKey ?? this.orderKey,
    );
  }
}

abstract final class PendingCheckoutMoney {
  static const fallback = MoneyFormat(currency: 'IDR', currencyExponent: 0);
}

/// Stable, human-readable failure classification for checkout actions.
class CheckoutApiException implements Exception {
  const CheckoutApiException({
    required this.code,
    required this.message,
    this.statusCode,
    this.retryable = false,
    this.details = const {},
  });

  final int? statusCode;
  final String code;
  final String message;
  final bool retryable;
  final Map<String, dynamic> details;

  bool get isOffline => code == 'OFFLINE' || code == 'NETWORK';

  String? get reason => details['reason'] as String?;

  @override
  String toString() => 'CheckoutApiException($statusCode $code: $message)';
}
