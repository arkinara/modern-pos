import 'package:flutter_test/flutter_test.dart';
import 'package:modern_pos_api_client/api.dart';
import 'package:modern_pos_mobile/features/printing/esc_pos_receipt.dart';
import 'package:modern_pos_mobile/features/printing/receipt_identity.dart';
import 'package:modern_pos_mobile/features/printing/sale_receipt.dart';

import 'support/checkout_fakes.dart';

const _identity = ReceiptIdentity(
  businessName: 'Modern POS Demo',
  outletName: 'Main Outlet',
  address: 'Jl. Example No. 1, Jakarta',
  receiptHeader: 'Modern POS Demo',
  receiptFooter: 'Thank you for your visit',
);

Sale _sale() {
  return testSale(
      totalMinor: 57250,
      subtotalMinor: 50000,
      tenderedMinor: 100000,
      changeMinor: 42750,
      lines: [
        SaleLine(
          id: 'line-1',
          variantId: 'variant-1',
          name:
              'Iced latte with extra oat milk and a very long descriptive name',
          variantName: 'Large',
          quantity: 2,
          unitPriceMinor: 25000,
          lineSubtotalMinor: 50000,
        ),
      ],
    )
    ..totals = Totals(
      subtotalMinor: 50000,
      serviceMinor: 2500,
      taxMinor: 4750,
      totalMinor: 57250,
    );
}

void main() {
  test(
    'receipt copies identity, reference, outlet-local time and all totals',
    () {
      final sale = _sale();
      final data = receiptDataForSale(sale, identity: _identity);
      final lines = ReceiptDocument.build(
        data,
        32,
      ).map((line) => line.text).toList(growable: false);

      expect(lines, contains('Modern POS Demo'));
      expect(lines, contains('Main Outlet'));
      expect(lines.join('').replaceAll(' ', ''), contains(sale.reference));
      expect(lines, contains('2026-01-01 17:00'));
      expect(lines.join('\n'), contains('Subtotal'));
      expect(lines.join('\n'), contains('Rp50.000'));
      expect(lines.join('\n'), contains('Rp2.500'));
      expect(lines.join('\n'), contains('Rp4.750'));
      expect(lines.join('\n'), contains('Rp57.250'));
      expect(lines.join('\n'), contains('Cash tendered'));
      expect(lines.join('\n'), contains('Rp100.000'));
      expect(lines.join('\n'), contains('Change'));
      expect(lines.join('\n'), contains('Rp42.750'));
    },
  );

  test('missing money values match the server Sale totals exactly', () {
    final sale = _sale();
    final data = receiptDataForSale(sale, identity: _identity);

    expect(data.subtotalMinor, sale.totals.subtotalMinor);
    expect(data.serviceMinor, sale.totals.serviceMinor);
    expect(data.taxMinor, sale.totals.taxMinor);
    expect(data.totalMinor, sale.totals.totalMinor);
    expect(data.tenderedMinor, sale.payment.tenderedMinor);
    expect(data.changeMinor, sale.payment.changeMinor);
  });

  test(
    'long item names wrap inside the column width without losing the price',
    () {
      final data = receiptDataForSale(_sale(), identity: _identity);
      final lines = ReceiptDocument.build(data, 32);

      for (final line in lines) {
        expect(line.text.length, lessThanOrEqualTo(32));
      }
      final itemLines = lines.map((line) => line.text).toList(growable: false);
      expect(itemLines, contains('Iced latte with extra oat milk'));
      expect(
        itemLines.any((line) => line.trim().endsWith('Rp50.000')),
        isTrue,
        reason: 'qty x unit and line total must stay aligned across wrapping',
      );
      expect(itemLines.any((line) => line.contains('2 x Rp25.000')), isTrue);
    },
  );

  test('many lines stay within the paper width', () {
    final items = List<SaleLine>.generate(
      30,
      (index) => SaleLine(
        id: 'line-$index',
        variantId: 'variant-$index',
        name: 'Menu item number $index with a long enough name',
        variantName: 'Default',
        quantity: 1,
        unitPriceMinor: 1000,
        lineSubtotalMinor: 1000,
      ),
    );
    final sale = testSale(
      subtotalMinor: 30000,
      totalMinor: 30000,
      lines: items,
    );
    final data = receiptDataForSale(sale, identity: _identity);

    for (final line in ReceiptDocument.build(data, 32)) {
      expect(line.text.length, lessThanOrEqualTo(32));
    }
  });

  test('COPY reprint is marked on the paper and in the footer', () {
    final data = receiptDataForSale(_sale(), identity: _identity, copy: true);
    final lines = ReceiptDocument.build(
      data,
      32,
    ).map((line) => line.text).toList(growable: false);

    expect(lines, contains('COPY'));
    expect(lines, contains('REPRINT - NOT AN ORIGINAL'));
    expect(lines.any((line) => line.contains('COPY - reprinted')), isTrue);
    expect(data.totalMinor, 57250);
  });
}
