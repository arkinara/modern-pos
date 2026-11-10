import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:modern_pos_api_client/api.dart';
import 'package:modern_pos_mobile/features/printing/esc_pos_receipt.dart';
import 'package:modern_pos_mobile/features/printing/receipt_identity.dart';
import 'package:modern_pos_mobile/features/printing/sale_receipt.dart';

/// Verification harness for ticket #18. It is skipped unless a live finalize
/// response is supplied, so the regular test suite never depends on a server.
void main() {
  final payloadPath = Platform.environment['RECEIPT_SALE_JSON'];

  test('renders the identity, reference, local time, items, tax/service, tender and change from a live sale payload', () {
    final raw = jsonDecode(
      File(payloadPath!).readAsStringSync(),
    ) as Map<String, dynamic>;
    final saleJson = (raw['sale'] ?? raw) as Map<String, dynamic>;
    final sale = Sale.fromJson(saleJson);
    expect(sale, isNotNull);

    const identity = ReceiptIdentity(
      businessName: 'Modern POS Demo',
      outletName: 'Main Outlet',
      address: 'Jl. Example No. 1, Jakarta',
      receiptHeader: 'Modern POS Demo',
      receiptFooter: 'Thank you for your visit',
    );
    final data = receiptDataForSale(sale!, identity: identity);
    final lines = ReceiptDocument.build(
      data,
      32,
    ).map((line) => line.text).toList(growable: false);
    final text = lines.join('\n');

    expect(lines, contains('Modern POS Demo'));
    expect(lines, contains('Main Outlet'));
    expect(text, contains('Ref:'));
    expect(text.replaceAll('\n', ''), contains(sale.reference));
    expect(text, contains('2026-11-11 01:56'));
    expect(text, contains('T18 Latte'));
    expect(text, contains('Regular'));
    expect(text, contains('3 x Rp20.000'));
    expect(text, contains('Subtotal'));
    expect(text, contains('Rp60.000'));
    expect(text, contains('Service'));
    expect(text, contains('Rp3.000'));
    expect(text, contains('Tax'));
    expect(text, contains('Rp6.300'));
    expect(text, contains('Rp69.300'));
    expect(text, contains('Cash tendered'));
    expect(text, contains('Rp70.000'));
    expect(text, contains('Change'));
    expect(text, contains('Rp700'));
    expect(data.reference, sale.reference);
    expect(data.totalMinor, sale.totals.totalMinor);
    expect(data.tenderedMinor, sale.payment.tenderedMinor);
    expect(data.changeMinor, sale.payment.changeMinor);
    for (final line in lines) {
      expect(line.length, lessThanOrEqualTo(32));
    }
  }, skip: payloadPath == null ? 'RECEIPT_SALE_JSON is not set' : false);
}
