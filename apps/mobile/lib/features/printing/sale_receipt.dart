import 'package:modern_pos_api_client/api.dart';
import 'package:timezone/data/latest_10y.dart' as timezone_data;
import 'package:timezone/timezone.dart' as tz;

import 'esc_pos_receipt.dart';
import 'receipt_identity.dart';

bool _timezonesReady = false;

void _ensureTimezones() {
  if (_timezonesReady) {
    return;
  }
  timezone_data.initializeTimeZones();
  _timezonesReady = true;
}

/// Builds the immutable receipt snapshot from the server sale payload.
///
/// Financial values are copied from [Sale.totals] and `SaleLine` snapshots; no
/// device-side arithmetic can change the amount printed. [copy] is the only
/// difference between an original and a deliberate reprint.
ReceiptData receiptDataForSale(
  Sale sale, {
  ReceiptIdentity? identity,
  bool copy = false,
}) {
  final receiptIdentity = identity ?? ReceiptIdentity.fallback;
  final payment = sale.payment;
  final isCash = payment.kind == PaymentKindEnum.CASH;
  final tenderLabel = switch (payment.kind) {
    PaymentKindEnum.CASH => 'Cash tendered',
    PaymentKindEnum.ONLINE => 'Online payment',
    _ => 'Manual external',
  };
  final footer = <String>[
    if (receiptIdentity.receiptFooter.isNotEmpty) receiptIdentity.receiptFooter,
    if (copy) 'COPY - reprinted from the completed sale.',
  ];

  return ReceiptData(
    businessName: receiptIdentity.businessName,
    outletName: receiptIdentity.outletName,
    address: receiptIdentity.address,
    receiptHeader: receiptIdentity.receiptHeader,
    copy: copy,
    items: sale.lines
        .map(
          (line) => ReceiptLineItem(
            name: line.name,
            variantName: line.variantName,
            quantity: line.quantity,
            unitPriceMinor: line.unitPriceMinor,
            lineTotalMinor: line.lineSubtotalMinor,
          ),
        )
        .toList(growable: false),
    subtotalMinor: sale.totals.subtotalMinor,
    serviceMinor: sale.totals.serviceMinor,
    taxMinor: sale.totals.taxMinor,
    totalMinor: sale.totals.totalMinor,
    currency: sale.currency,
    currencyExponent: sale.currencyExponent,
    reference: sale.reference,
    issuedAtLabel: outletLocalLabel(sale.completedAt, sale.timezone),
    tenderLabel: tenderLabel,
    tenderedMinor: isCash
        ? (payment.tenderedMinor ?? payment.amountMinor)
        : payment.amountMinor,
    changeMinor: isCash ? (payment.changeMinor ?? 0) : null,
    paymentReference: payment.reference,
    footerLines: footer,
  );
}

/// Renders the completed-at instant in the outlet IANA zone, not the device
/// zone. An unknown zone falls back to the device local clock without claiming
/// the outlet zone was applied.
String outletLocalLabel(DateTime instant, String timezone) {
  try {
    _ensureTimezones();
    final location = tz.getLocation(timezone);
    final local = tz.TZDateTime.from(instant.toUtc(), location);
    return _format(local);
  } catch (_) {
    return _format(instant.toLocal());
  }
}

String _format(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '${value.year}-$month-$day $hour:$minute';
}
