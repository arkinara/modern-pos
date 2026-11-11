import 'package:modern_pos_api_client/api.dart' hide PrintJob;

import '../checkout/checkout_models.dart';

/// Durable states for a sale that may be submitted more than once.
///
/// `PENDING` and `UNCERTAIN` are safe to retry. `CONFLICT` requires a cashier
/// decision because the server rejected the recorded sale. `FAILED` is a
/// permanent local failure (for example corrupt ciphertext or a missing key).
enum OfflineSaleState {
  pending,
  inFlight,
  synced,
  uncertain,
  conflict,
  failed;

  static OfflineSaleState fromWire(String value) {
    return OfflineSaleState.values.firstWhere(
      (state) => state.name == value,
      orElse: () => OfflineSaleState.pending,
    );
  }

  String get label {
    return switch (this) {
      OfflineSaleState.pending => 'Pending',
      OfflineSaleState.inFlight => 'In flight',
      OfflineSaleState.synced => 'Synced',
      OfflineSaleState.uncertain => 'Outcome unknown',
      OfflineSaleState.conflict => 'Conflict',
      OfflineSaleState.failed => 'Failed',
    };
  }

  bool get blocksNewSale =>
      this == OfflineSaleState.pending ||
      this == OfflineSaleState.inFlight ||
      this == OfflineSaleState.uncertain ||
      this == OfflineSaleState.conflict;
}

/// One immutable cart line recorded with an offline sale. Names are a
/// point-in-time snapshot; the server remains authoritative for price and tax.
class OfflineSaleLine {
  const OfflineSaleLine({
    required this.variantId,
    required this.name,
    required this.variantName,
    required this.quantity,
    required this.unitPriceMinor,
  });

  final String variantId;
  final String name;
  final String variantName;
  final int quantity;
  final int unitPriceMinor;

  Map<String, dynamic> toJson() => {
    'variantId': variantId,
    'name': name,
    'variantName': variantName,
    'quantity': quantity,
    'unitPriceMinor': unitPriceMinor,
  };

  static OfflineSaleLine? fromJson(Map<String, dynamic> json) {
    final variantId = json['variantId'];
    final name = json['name'];
    final variantName = json['variantName'];
    final quantity = json['quantity'];
    final unitPriceMinor = json['unitPriceMinor'];
    if (variantId is! String ||
        name is! String ||
        variantName is! String ||
        quantity is! int ||
        unitPriceMinor is! int) {
      return null;
    }
    return OfflineSaleLine(
      variantId: variantId,
      name: name,
      variantName: variantName,
      quantity: quantity,
      unitPriceMinor: unitPriceMinor,
    );
  }
}

/// Exact sale request retained on the device. The JSON representation is the
/// only value written to the encrypted queue; no field below is stored in
/// plaintext in SQLite.
class OfflineSalePayload {
  const OfflineSalePayload({
    required this.idempotencyKey,
    required this.orderKey,
    required this.outletId,
    required this.deviceId,
    required this.lines,
    required this.tenderKind,
    required this.amountMinor,
    required this.tenderedMinor,
    required this.reference,
    required this.totalMinor,
    required this.currency,
    required this.currencyExponent,
    required this.createdAt,
    this.orderId,
    this.quoteId,
    this.orderVersion,
  });

  final String idempotencyKey;

  /// Key used when a cold offline sale still needs its draft order created.
  /// Persisted so a retry cannot create a second draft.
  final String orderKey;
  final String outletId;
  final String deviceId;
  final List<OfflineSaleLine> lines;
  final TenderKind tenderKind;
  final int amountMinor;
  final int tenderedMinor;
  final String? reference;
  final int totalMinor;
  final String currency;
  final int currencyExponent;
  final DateTime createdAt;
  final String? orderId;
  final String? quoteId;
  final int? orderVersion;

  bool get hasServerDraft => orderId != null && quoteId != null;

  PaymentInput paymentFor(int serverTotalMinor) {
    return switch (tenderKind) {
      TenderKind.cash => PaymentInput(
        kind: PaymentInputKindEnum.CASH,
        amountMinor: serverTotalMinor,
        tenderedMinor: tenderedMinor,
      ),
      TenderKind.manualExternal => PaymentInput(
        kind: PaymentInputKindEnum.MANUAL_EXTERNAL,
        amountMinor: serverTotalMinor,
        reference: reference,
      ),
    };
  }

  bool get tenderSufficient {
    return switch (tenderKind) {
      TenderKind.cash => tenderedMinor >= totalMinor,
      TenderKind.manualExternal => true,
    };
  }

  Map<String, dynamic> toJson() => {
    'idempotencyKey': idempotencyKey,
    'orderKey': orderKey,
    'outletId': outletId,
    'deviceId': deviceId,
    'lines': lines.map((line) => line.toJson()).toList(growable: false),
    'tenderKind': tenderKind.wire.toJson(),
    'amountMinor': amountMinor,
    'tenderedMinor': tenderedMinor,
    'reference': reference,
    'totalMinor': totalMinor,
    'currency': currency,
    'currencyExponent': currencyExponent,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'orderId': orderId,
    'quoteId': quoteId,
    'orderVersion': orderVersion,
  };

  static OfflineSalePayload? fromJson(Map<String, dynamic> json) {
    final idempotencyKey = json['idempotencyKey'];
    final orderKey = json['orderKey'];
    final outletId = json['outletId'];
    final deviceId = json['deviceId'];
    final linesRaw = json['lines'];
    final kind = PaymentInputKindEnum.fromJson(json['tenderKind']);
    final amountMinor = json['amountMinor'];
    final tenderedMinor = json['tenderedMinor'];
    final totalMinor = json['totalMinor'];
    final currency = json['currency'];
    final currencyExponent = json['currencyExponent'];
    final createdAt = json['createdAt'];
    if (idempotencyKey is! String ||
        orderKey is! String ||
        outletId is! String ||
        deviceId is! String ||
        linesRaw is! List ||
        kind == null ||
        amountMinor is! int ||
        tenderedMinor is! int ||
        totalMinor is! int ||
        currency is! String ||
        currencyExponent is! int ||
        createdAt is! String) {
      return null;
    }
    final lines = <OfflineSaleLine>[];
    for (final raw in linesRaw) {
      if (raw is! Map) {
        return null;
      }
      final line = OfflineSaleLine.fromJson(raw.cast<String, dynamic>());
      if (line == null) {
        return null;
      }
      lines.add(line);
    }
    final parsedCreatedAt = DateTime.tryParse(createdAt);
    if (parsedCreatedAt == null) {
      return null;
    }
    return OfflineSalePayload(
      idempotencyKey: idempotencyKey,
      orderKey: orderKey,
      outletId: outletId,
      deviceId: deviceId,
      lines: List.unmodifiable(lines),
      tenderKind: kind == PaymentInputKindEnum.CASH
          ? TenderKind.cash
          : TenderKind.manualExternal,
      amountMinor: amountMinor,
      tenderedMinor: tenderedMinor,
      reference: json['reference'] as String?,
      totalMinor: totalMinor,
      currency: currency,
      currencyExponent: currencyExponent,
      createdAt: parsedCreatedAt,
      orderId: json['orderId'] as String?,
      quoteId: json['quoteId'] as String?,
      orderVersion: json['orderVersion'] as int?,
    );
  }

  OfflineSalePayload copyWith({
    List<OfflineSaleLine>? lines,
    int? amountMinor,
    int? totalMinor,
    String? orderId,
    String? quoteId,
    int? orderVersion,
  }) {
    return OfflineSalePayload(
      idempotencyKey: idempotencyKey,
      orderKey: orderKey,
      outletId: outletId,
      deviceId: deviceId,
      lines: lines ?? this.lines,
      tenderKind: tenderKind,
      amountMinor: amountMinor ?? this.amountMinor,
      tenderedMinor: tenderedMinor,
      reference: reference,
      totalMinor: totalMinor ?? this.totalMinor,
      currency: currency,
      currencyExponent: currencyExponent,
      createdAt: createdAt,
      orderId: orderId ?? this.orderId,
      quoteId: quoteId ?? this.quoteId,
      orderVersion: orderVersion ?? this.orderVersion,
    );
  }
}

/// A decrypted queue row plus its durable synchronization state.
class OfflineSaleRecord {
  const OfflineSaleRecord({
    required this.payload,
    required this.state,
    required this.attempts,
    required this.createdAt,
    required this.updatedAt,
    this.nextAttemptAt,
    this.lastError,
    this.saleReference,
  });

  final OfflineSalePayload payload;
  final OfflineSaleState state;
  final int attempts;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? nextAttemptAt;
  final String? lastError;
  final String? saleReference;

  String get idempotencyKey => payload.idempotencyKey;

  bool get isActive => state.blocksNewSale;

  OfflineSaleRecord copyWith({
    OfflineSaleState? state,
    int? attempts,
    DateTime? nextAttemptAt,
    String? lastError,
    String? saleReference,
    OfflineSalePayload? payload,
    DateTime? updatedAt,
  }) {
    return OfflineSaleRecord(
      payload: payload ?? this.payload,
      state: state ?? this.state,
      attempts: attempts ?? this.attempts,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      lastError: lastError ?? this.lastError,
      saleReference: saleReference ?? this.saleReference,
    );
  }
}

/// Counts shown by the cashier sync screen.
class OfflineSyncSummary {
  const OfflineSyncSummary({
    this.pending = 0,
    this.inFlight = 0,
    this.synced = 0,
    this.uncertain = 0,
    this.conflict = 0,
    this.failed = 0,
  });

  final int pending;
  final int inFlight;
  final int synced;
  final int uncertain;
  final int conflict;
  final int failed;

  int get active => pending + inFlight + uncertain + conflict;

  int get total => pending + inFlight + synced + uncertain + conflict + failed;

  bool get isClear => active == 0 && failed == 0;

  static OfflineSyncSummary fromRecords(Iterable<OfflineSaleRecord> records) {
    var pending = 0;
    var inFlight = 0;
    var synced = 0;
    var uncertain = 0;
    var conflict = 0;
    var failed = 0;
    for (final record in records) {
      switch (record.state) {
        case OfflineSaleState.pending:
          pending++;
        case OfflineSaleState.inFlight:
          inFlight++;
        case OfflineSaleState.synced:
          synced++;
        case OfflineSaleState.uncertain:
          uncertain++;
        case OfflineSaleState.conflict:
          conflict++;
        case OfflineSaleState.failed:
          failed++;
      }
    }
    return OfflineSyncSummary(
      pending: pending,
      inFlight: inFlight,
      synced: synced,
      uncertain: uncertain,
      conflict: conflict,
      failed: failed,
    );
  }
}

/// Result of comparing locally synced keys with the server sales ledger.
class OfflineReconciliation {
  const OfflineReconciliation({
    required this.checkedAt,
    required this.localSynced,
    required this.serverMatched,
    required this.missingKeys,
    required this.salesChecked,
  });

  final DateTime checkedAt;
  final int localSynced;
  final int serverMatched;
  final List<String> missingKeys;
  final int salesChecked;

  bool get matches => missingKeys.isEmpty && serverMatched == localSynced;

  String get summary {
    if (localSynced == 0) {
      return 'No synced sales to reconcile.';
    }
    return '$serverMatched of $localSynced synced sales found on the server '
        '($salesChecked sales returned).';
  }
}
