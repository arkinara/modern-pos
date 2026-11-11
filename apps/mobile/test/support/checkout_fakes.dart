import 'dart:async';

import 'package:modern_pos_api_client/api.dart';
import 'package:modern_pos_mobile/core/device_identity.dart';
import 'package:modern_pos_mobile/features/checkout/checkout_gateway.dart';
import 'package:modern_pos_mobile/features/checkout/checkout_models.dart';
import 'package:modern_pos_mobile/features/checkout/checkout_repository.dart';
import 'package:modern_pos_mobile/features/printing/esc_pos_receipt.dart';
import 'package:modern_pos_mobile/features/printing/printer_adapter.dart';
import 'package:modern_pos_mobile/features/printing/printer_models.dart';

class FixedDeviceIdentity implements DeviceIdentity {
  FixedDeviceIdentity([this.value = '00000000-0000-4000-8000-000000000099']);

  final String value;

  @override
  Future<String> deviceId() async => value;
}

class InMemoryCheckoutRepository implements CheckoutRepository {
  final Map<String, PendingCheckout> rows = {};

  PendingCheckout? get pending {
    for (final row in rows.values) {
      if (row.status == PendingCheckoutStatus.pending) {
        return row;
      }
    }
    return null;
  }

  @override
  Future<PendingCheckout?> loadPending() async => pending;

  @override
  Future<PendingCheckout?> loadByKey(String idempotencyKey) async =>
      rows[idempotencyKey];

  @override
  Future<void> savePending(PendingCheckout next) async {
    rows[next.idempotencyKey] = next;
  }

  @override
  Future<void> markConfirmed(
    String idempotencyKey,
    String saleReference,
  ) async {
    final row = rows[idempotencyKey];
    if (row != null) {
      rows[idempotencyKey] = row.copyWith(
        status: PendingCheckoutStatus.confirmed,
        saleReference: saleReference,
      );
    }
  }

  @override
  Future<void> markFailed(String idempotencyKey) async {
    final row = rows[idempotencyKey];
    if (row != null) {
      rows[idempotencyKey] = row.copyWith(status: PendingCheckoutStatus.failed);
    }
  }

  @override
  Future<void> delete(String idempotencyKey) async {
    rows.remove(idempotencyKey);
  }
}

class FakeCheckoutGateway implements CheckoutGateway {
  bool online = true;
  CheckoutApiException? pingError;
  CheckoutApiException? createOrderError;
  CheckoutApiException? createQuoteError;
  CheckoutApiException? finalizeError;
  CheckoutApiException? recoverError;

  Order order = testOrder();
  Quote? quote;
  Finalized finalized = testFinalized();

  Completer<Finalized>? finalizeGate;
  Future<Finalized> Function()? onFinalize;
  Future<Finalized> Function()? onRecover;

  int pingCalls = 0;
  int createOrderCalls = 0;
  int createQuoteCalls = 0;
  int finalizeCalls = 0;
  int recoverCalls = 0;
  int listSalesCalls = 0;

  String? lastOrderKey;
  String? lastFinalizeKey;
  Finalize? lastFinalizePayload;
  String? lastRecoverKey;
  String? lastRecoverDeviceId;
  List<Sale> serverSales = const [];

  @override
  Future<bool> ping() async {
    pingCalls++;
    final failure = pingError;
    if (failure != null) {
      throw failure;
    }
    return online;
  }

  @override
  Future<Order> createOrder({
    required String outletId,
    required String deviceId,
    required String idempotencyKey,
    required List<OrderWriteLinesInner> lines,
  }) async {
    createOrderCalls++;
    lastOrderKey = idempotencyKey;
    final failure = createOrderError;
    if (failure != null) {
      throw failure;
    }
    return order;
  }

  @override
  Future<Quote> createQuote({
    required String outletId,
    required String orderId,
    required int orderVersion,
  }) async {
    createQuoteCalls++;
    final failure = createQuoteError;
    if (failure != null) {
      throw failure;
    }
    return quote ?? testQuote(orderId: orderId);
  }

  @override
  Future<Finalized> finalize({
    required String outletId,
    required String idempotencyKey,
    required Finalize payload,
  }) async {
    finalizeCalls++;
    lastFinalizeKey = idempotencyKey;
    lastFinalizePayload = payload;
    final failure = finalizeError;
    if (failure != null) {
      throw failure;
    }
    final handler = onFinalize;
    if (handler != null) {
      return handler();
    }
    final gate = finalizeGate;
    if (gate != null) {
      return gate.future;
    }
    return finalized;
  }

  @override
  Future<Finalized> recover({
    required String outletId,
    required String key,
    required String deviceId,
  }) async {
    recoverCalls++;
    lastRecoverKey = key;
    lastRecoverDeviceId = deviceId;
    final failure = recoverError;
    if (failure != null) {
      throw failure;
    }
    final handler = onRecover;
    if (handler != null) {
      return handler();
    }
    return finalized;
  }

  @override
  Future<SalePage> listSales({
    required String outletId,
    DateTime? from,
    DateTime? to,
    String? cursor,
    int limit = 100,
  }) async {
    listSalesCalls++;
    return SalePage(items: serverSales, nextCursor: null);
  }
}

class FakeReceiptPrinter implements PrinterAdapter {
  FakeReceiptPrinter({this.connected = true, this.throwOnPrint = false});

  bool connected;
  bool throwOnPrint;
  int printCount = 0;
  ReceiptData? lastData;

  @override
  bool get isConnected => connected;

  @override
  Future<void> connect(PrinterConfig config) async {
    connected = true;
  }

  @override
  Future<void> disconnect() async {
    connected = false;
  }

  @override
  Future<void> printReceipt(ReceiptData data) async {
    printCount++;
    lastData = data;
    if (throwOnPrint) {
      throw const PrinterException(
        PrinterFailureKind.connectionLost,
        'Simulated printer failure',
      );
    }
  }

  @override
  Future<void> testPrint() async {}
}

CalculationRules testCalculation({
  int taxBps = 0,
  int serviceBps = 0,
  int currencyExponent = 0,
}) {
  return CalculationRules(
    taxBps: taxBps,
    serviceBps: serviceBps,
    pricingMode: CalculationRulesPricingModeEnum.EXCLUSIVE,
    currencyExponent: currencyExponent,
    rounding: CalculationRulesRoundingEnum.HALF_UP,
  );
}

Order testOrder({
  String id = '00000000-0000-4000-8000-000000000201',
  String deviceId = '00000000-0000-4000-8000-000000000099',
  int version = 1,
  List<OrderWriteLinesInner>? lines,
}) {
  return Order(
    id: id,
    deviceId: deviceId,
    state: OrderStateEnum.DRAFT,
    version: version,
    lines: lines ?? [OrderWriteLinesInner(variantId: 'variant-1', quantity: 1)],
  );
}

Quote testQuote({
  String id = '00000000-0000-4000-8000-000000000202',
  String orderId = '00000000-0000-4000-8000-000000000201',
  int orderVersion = 1,
  int totalMinor = 50000,
  int subtotalMinor = 50000,
  String currency = 'IDR',
  int currencyExponent = 0,
  DateTime? expiresAt,
  List<QuoteLinesInner>? lines,
}) {
  return Quote(
    id: id,
    orderId: orderId,
    orderVersion: orderVersion,
    settingsVersion: 1,
    currency: currency,
    currencyExponent: currencyExponent,
    calculation: testCalculation(currencyExponent: currencyExponent),
    expiresAt: expiresAt ?? DateTime.now().add(const Duration(seconds: 60)),
    totals: Totals(
      subtotalMinor: subtotalMinor,
      serviceMinor: 0,
      taxMinor: 0,
      totalMinor: totalMinor,
    ),
    lines:
        lines ??
        [
          QuoteLinesInner(
            variantId: 'variant-1',
            name: 'Tea',
            variantName: 'Default',
            quantity: 1,
            unitPriceMinor: subtotalMinor,
            lineSubtotalMinor: subtotalMinor,
            recipeVersion: null,
          ),
        ],
  );
}

Sale testSale({
  String id = '00000000-0000-4000-8000-000000000203',
  String orderId = '00000000-0000-4000-8000-000000000201',
  String reference = 'SALE-00000000-0000-4000-8000-000000000201',
  int totalMinor = 50000,
  int subtotalMinor = 50000,
  int tenderedMinor = 100000,
  int changeMinor = 50000,
  String currency = 'IDR',
  int currencyExponent = 0,
  PaymentKindEnum kind = PaymentKindEnum.CASH,
  List<SaleLine>? lines,
}) {
  return Sale(
    id: id,
    orderId: orderId,
    reference: reference,
    state: SaleStateEnum.COMPLETED,
    currency: currency,
    currencyExponent: currencyExponent,
    timezone: 'Asia/Jakarta',
    completedAt: DateTime.utc(2026, 1, 1, 10),
    calculation: testCalculation(currencyExponent: currencyExponent),
    totals: Totals(
      subtotalMinor: subtotalMinor,
      serviceMinor: 0,
      taxMinor: 0,
      totalMinor: totalMinor,
    ),
    lines:
        lines ??
        [
          SaleLine(
            id: 'sale-line-1',
            variantId: 'variant-1',
            name: 'Tea',
            variantName: 'Default',
            quantity: 1,
            unitPriceMinor: subtotalMinor,
            lineSubtotalMinor: subtotalMinor,
          ),
        ],
    payment: Payment(
      kind: kind,
      status: PaymentStatusEnum.RECORDED,
      amountMinor: totalMinor,
      tenderedMinor: kind == PaymentKindEnum.CASH ? tenderedMinor : null,
      changeMinor: kind == PaymentKindEnum.CASH ? changeMinor : null,
      reference: kind == PaymentKindEnum.CASH ? null : 'EXTERNAL-1',
    ),
  );
}

Finalized testFinalized({Sale? sale, bool replayed = false}) {
  return Finalized(sale: sale ?? testSale(), replayed: replayed);
}

PendingCheckout testPending({
  String key = '00000000-0000-4000-8000-000000000301',
  String deviceId = '00000000-0000-4000-8000-000000000099',
  String outletId = 'outlet-1',
  String orderId = '00000000-0000-4000-8000-000000000201',
  String quoteId = '00000000-0000-4000-8000-000000000202',
  int totalMinor = 50000,
  PendingCheckoutStatus status = PendingCheckoutStatus.pending,
  String? saleReference,
}) {
  return PendingCheckout(
    idempotencyKey: key,
    deviceId: deviceId,
    outletId: outletId,
    orderId: orderId,
    quoteId: quoteId,
    payment: PaymentDraft(
      kind: TenderKind.cash,
      amountMinor: totalMinor,
      tenderedMinor: totalMinor,
    ),
    totalMinor: totalMinor,
    currency: 'IDR',
    currencyExponent: 0,
    createdAt: DateTime.utc(2026, 1, 1),
    status: status,
    saleReference: saleReference,
  );
}
