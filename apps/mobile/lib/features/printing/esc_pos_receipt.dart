import 'dart:typed_data';

import '../../core/formatting/money.dart';
import 'printer_encoding.dart';
import 'printer_models.dart';
import 'receipt_layout.dart';

/// One receipt line item. Money is integer minor units and is never converted
/// through a floating point value.
class ReceiptLineItem {
  const ReceiptLineItem({
    required this.name,
    required this.quantity,
    required this.unitPriceMinor,
    required this.lineTotalMinor,
    this.variantName,
  });

  final String name;
  final String? variantName;
  final int quantity;
  final int unitPriceMinor;
  final int lineTotalMinor;
}

/// Everything the byte-stream builder needs to render a receipt.
class ReceiptData {
  const ReceiptData({
    required this.outletName,
    required this.items,
    required this.subtotalMinor,
    required this.totalMinor,
    required this.currency,
    required this.currencyExponent,
    this.title = 'SALE RECEIPT',
    this.serviceMinor = 0,
    this.taxMinor = 0,
    this.reference,
    this.issuedAtLabel,
    this.footerLines = const [],
  });

  final String outletName;
  final String title;
  final List<ReceiptLineItem> items;
  final int subtotalMinor;
  final int serviceMinor;
  final int taxMinor;
  final int totalMinor;
  final String currency;
  final int currencyExponent;
  final String? reference;
  final String? issuedAtLabel;
  final List<String> footerLines;

  MoneyFormat get money =>
      MoneyFormat(currency: currency, currencyExponent: currencyExponent);
}

/// Pure ESC/POS byte-stream builder.
///
/// The command set used here is the common ESC/POS subset. Which of these
/// commands a real printer honours (text, cut, cash drawer, code page) is
/// `PENDING — requires printer model`; see `docs/printer-validation.md`.
class EscPosReceiptBuilder {
  const EscPosReceiptBuilder();

  Uint8List build(
    ReceiptData data,
    PrinterConfig config, {
    bool cut = true,
    bool openCashDrawer = false,
  }) {
    final writer = _EscPosWriter(
      columns: config.paperWidth.columns,
      encoding: config.encoding,
    );

    writer.initialise();
    writer.alignment(_Align.center);
    writer.bold(true);
    writer.line(data.outletName);
    writer.bold(false);
    writer.line(data.title);
    writer.alignment(_Align.left);
    writer.line(ReceiptLayout.divider(writer.columns));

    if (data.reference != null && data.reference!.isNotEmpty) {
      writer.line('Ref: ${data.reference}');
    }
    if (data.issuedAtLabel != null && data.issuedAtLabel!.isNotEmpty) {
      writer.line(data.issuedAtLabel!);
    }
    if (data.reference != null || data.issuedAtLabel != null) {
      writer.line(ReceiptLayout.divider(writer.columns));
    }

    for (final item in data.items) {
      for (final line in ReceiptLayout.wrap(item.name, writer.columns)) {
        writer.line(line);
      }
      if (item.variantName != null && item.variantName!.isNotEmpty) {
        for (final line in ReceiptLayout.wrap(
          item.variantName!,
          writer.columns,
        )) {
          writer.line(line);
        }
      }
      final unit = data.money.format(item.unitPriceMinor);
      final total = data.money.format(item.lineTotalMinor);
      for (final line in ReceiptLayout.columns(
        '${item.quantity} x $unit',
        total,
        writer.columns,
      )) {
        writer.line(line);
      }
    }

    writer.line(ReceiptLayout.divider(writer.columns));
    writer.columnsLine('Subtotal', data.money.format(data.subtotalMinor));
    if (data.serviceMinor != 0) {
      writer.columnsLine('Service', data.money.format(data.serviceMinor));
    }
    if (data.taxMinor != 0) {
      writer.columnsLine('Tax', data.money.format(data.taxMinor));
    }
    writer.bold(true);
    writer.columnsLine('TOTAL', data.money.format(data.totalMinor));
    writer.bold(false);
    writer.line(ReceiptLayout.divider(writer.columns));

    writer.alignment(_Align.center);
    for (final footer in data.footerLines) {
      for (final line in ReceiptLayout.wrap(footer, writer.columns)) {
        writer.line(line);
      }
    }
    writer.alignment(_Align.left);
    writer.feed(2);
    if (openCashDrawer) {
      writer.cashDrawer();
    }
    if (cut) {
      writer.cut();
    }
    return writer.toBytes();
  }

  /// Small, clearly labelled test receipt used by the cashier Test print action.
  Uint8List buildTestReceipt(
    PrinterConfig config, {
    String? issuedAtLabel,
    bool cut = true,
    bool openCashDrawer = false,
  }) {
    return build(
      ReceiptData(
        outletName: 'Modern POS',
        title: 'PRINTER TEST',
        reference: 'TEST-${config.paperWidth.millimetres}MM',
        issuedAtLabel: issuedAtLabel,
        items: const [
          ReceiptLineItem(
            name: 'Sample item',
            variantName: 'Default',
            quantity: 1,
            unitPriceMinor: 1000,
            lineTotalMinor: 1000,
          ),
        ],
        subtotalMinor: 1000,
        totalMinor: 1000,
        currency: 'IDR',
        currencyExponent: 0,
        footerLines: const [
          'Test print only.',
          'Physical output requires device verification.',
        ],
      ),
      config,
      cut: cut,
      openCashDrawer: openCashDrawer,
    );
  }
}

enum _Align { left, center, right }

class _EscPosWriter {
  _EscPosWriter({required this.columns, required this.encoding});

  final int columns;
  final PrinterEncoding encoding;
  final List<int> _bytes = [];

  void initialise() => _add(const [0x1B, 0x40]);

  void alignment(_Align value) {
    final code = switch (value) {
      _Align.left => 0,
      _Align.center => 1,
      _Align.right => 2,
    };
    _add([0x1B, 0x61, code]);
  }

  void bold(bool enabled) => _add([0x1B, 0x45, enabled ? 1 : 0]);

  void text(String value) => _add(PrinterTextEncoder.encode(value, encoding));

  void line(String value) {
    text(value);
    newline();
  }

  void columnsLine(String left, String right) {
    for (final line in ReceiptLayout.columns(left, right, columns)) {
      this.line(line);
    }
  }

  void newline() => _add(const [0x0A]);

  void feed(int lines) => _add([0x1B, 0x64, lines]);

  /// ESC p - pulse the cash drawer kick-out connector.
  void cashDrawer() => _add(const [0x1B, 0x70, 0x00, 0x19, 0xFA]);

  /// GS V - full cut with feed (partial cut is model dependent).
  void cut() => _add(const [0x1D, 0x56, 0x42, 0x00]);

  void _add(List<int> value) => _bytes.addAll(value);

  Uint8List toBytes() => Uint8List.fromList(_bytes);
}
