import 'package:flutter_test/flutter_test.dart';
import 'package:modern_pos_mobile/features/printing/esc_pos_receipt.dart';
import 'package:modern_pos_mobile/features/printing/printer_models.dart';

import 'support/printer_fakes.dart';

bool _contains(List<int> bytes, List<int> needle) {
  if (needle.isEmpty || bytes.length < needle.length) {
    return false;
  }
  for (var start = 0; start <= bytes.length - needle.length; start++) {
    var matches = true;
    for (var offset = 0; offset < needle.length; offset++) {
      if (bytes[start + offset] != needle[offset]) {
        matches = false;
        break;
      }
    }
    if (matches) {
      return true;
    }
  }
  return false;
}

List<int> _ascii(String value) => value.codeUnits;

int _countNewlines(List<int> bytes) =>
    bytes.where((byte) => byte == 0x0A).length;

void main() {
  const builder = EscPosReceiptBuilder();

  const data = ReceiptData(
    outletName: 'Modern POS',
    title: 'SALE RECEIPT',
    reference: 'SALE-1',
    issuedAtLabel: '2026-11-09 10:00',
    items: [
      ReceiptLineItem(
        name: 'Latte',
        variantName: 'Large',
        quantity: 2,
        unitPriceMinor: 25000,
        lineTotalMinor: 50000,
      ),
    ],
    subtotalMinor: 50000,
    serviceMinor: 2500,
    taxMinor: 2750,
    totalMinor: 55250,
    currency: 'IDR',
    currencyExponent: 0,
    footerLines: ['Thank you'],
  );

  test('starts with the ESC/POS initialise command', () {
    final bytes = builder.build(data, testPrinterConfig());
    expect(bytes.sublist(0, 2), [0x1B, 0x40]);
  });

  test('encodes text and formats money in integer minor units', () {
    final bytes = builder.build(data, testPrinterConfig());
    expect(_contains(bytes, _ascii('Modern POS')), isTrue);
    expect(_contains(bytes, _ascii('Latte')), isTrue);
    expect(_contains(bytes, _ascii('Rp50.000')), isTrue);
    expect(_contains(bytes, _ascii('Rp55.250')), isTrue);
    expect(_contains(bytes, _ascii('SALE-1')), isTrue);
  });

  test('ends with feed and a full cut command by default', () {
    final bytes = builder.build(data, testPrinterConfig());
    expect(_contains(bytes, const [0x1B, 0x64, 0x02]), isTrue);
    expect(bytes.sublist(bytes.length - 4), const [0x1D, 0x56, 0x42, 0x00]);
  });

  test('can omit cut and optionally pulse the cash drawer', () {
    final noCut = builder.build(data, testPrinterConfig(), cut: false);
    expect(_contains(noCut, const [0x1D, 0x56, 0x42, 0x00]), isFalse);

    final drawer = builder.build(
      data,
      testPrinterConfig(),
      openCashDrawer: true,
    );
    expect(_contains(drawer, const [0x1B, 0x70, 0x00, 0x19, 0xFA]), isTrue);
  });

  test('honours the selected text encoding', () {
    const cafe = ReceiptData(
      outletName: 'Café',
      items: [],
      subtotalMinor: 0,
      totalMinor: 0,
      currency: 'IDR',
      currencyExponent: 0,
    );
    final cp437 = builder.build(
      cafe,
      testPrinterConfig(encoding: PrinterEncoding.cp437),
    );
    expect(_contains(cp437, const [0x43, 0x61, 0x66, 0x82]), isTrue);

    final utf8 = builder.build(
      cafe,
      testPrinterConfig(encoding: PrinterEncoding.utf8),
    );
    expect(_contains(utf8, [0x43, 0x61, 0x66, 0xC3, 0xA9]), isTrue);
  });

  test('uses the selected paper width for wrapping', () {
    const wideData = ReceiptData(
      outletName: 'Wide',
      items: [
        ReceiptLineItem(
          name: 'A very long product name that must wrap somewhere across the paper width',
          quantity: 1,
          unitPriceMinor: 1000,
          lineTotalMinor: 1000,
        ),
      ],
      subtotalMinor: 1000,
      totalMinor: 1000,
      currency: 'IDR',
      currencyExponent: 0,
    );
    final narrow = builder.build(
      wideData,
      testPrinterConfig(paperWidth: PaperWidth.mm58),
    );
    final wide = builder.build(
      wideData,
      testPrinterConfig(paperWidth: PaperWidth.mm80),
    );
    expect(_countNewlines(narrow), greaterThan(_countNewlines(wide)));
  });

  test('test receipt is clearly labelled as a test', () {
    final bytes = builder.buildTestReceipt(testPrinterConfig());
    expect(_contains(bytes, _ascii('PRINTER TEST')), isTrue);
    expect(_contains(bytes, _ascii('TEST-58MM')), isTrue);
    expect(_contains(bytes, _ascii('Physical output requires device')), isTrue);
    expect(_contains(bytes, _ascii('verification.')), isTrue);
  });
}
