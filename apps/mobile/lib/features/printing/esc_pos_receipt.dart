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

  Map<String, Object?> toJson() => {
    'name': name,
    'variantName': variantName,
    'quantity': quantity,
    'unitPriceMinor': unitPriceMinor,
    'lineTotalMinor': lineTotalMinor,
  };

  static ReceiptLineItem? fromJson(Map<String, Object?>? json) {
    if (json == null) {
      return null;
    }
    final name = json['name'];
    final quantity = json['quantity'];
    final unitPrice = json['unitPriceMinor'];
    final lineTotal = json['lineTotalMinor'];
    if (name is! String ||
        quantity is! int ||
        unitPrice is! int ||
        lineTotal is! int) {
      return null;
    }
    return ReceiptLineItem(
      name: name,
      variantName: json['variantName'] as String?,
      quantity: quantity,
      unitPriceMinor: unitPrice,
      lineTotalMinor: lineTotal,
    );
  }
}

/// Everything the byte-stream builder needs to render a receipt.
///
/// The financial fields are copied from the server `Sale` snapshot and never
/// recomputed on the device. [copy] marks a deliberate reprint so the paper is
/// not mistaken for the original.
class ReceiptData {
  const ReceiptData({
    required this.outletName,
    required this.items,
    required this.subtotalMinor,
    required this.totalMinor,
    required this.currency,
    required this.currencyExponent,
    this.businessName,
    this.address,
    this.receiptHeader,
    this.title = 'SALE RECEIPT',
    this.copy = false,
    this.serviceMinor = 0,
    this.taxMinor = 0,
    this.reference,
    this.issuedAtLabel,
    this.tenderLabel,
    this.tenderedMinor,
    this.changeMinor,
    this.paymentReference,
    this.footerLines = const [],
  });

  final String? businessName;
  final String outletName;
  final String? address;
  final String? receiptHeader;
  final String title;
  final bool copy;
  final List<ReceiptLineItem> items;
  final int subtotalMinor;
  final int serviceMinor;
  final int taxMinor;
  final int totalMinor;
  final String currency;
  final int currencyExponent;
  final String? reference;
  final String? issuedAtLabel;
  final String? tenderLabel;
  final int? tenderedMinor;
  final int? changeMinor;
  final String? paymentReference;
  final List<String> footerLines;

  MoneyFormat get money =>
      MoneyFormat(currency: currency, currencyExponent: currencyExponent);

  /// The same immutable sale snapshot marked as a deliberate COPY reprint.
  ReceiptData asCopy() {
    return ReceiptData(
      businessName: businessName,
      outletName: outletName,
      address: address,
      receiptHeader: receiptHeader,
      title: title,
      copy: true,
      items: items,
      subtotalMinor: subtotalMinor,
      serviceMinor: serviceMinor,
      taxMinor: taxMinor,
      totalMinor: totalMinor,
      currency: currency,
      currencyExponent: currencyExponent,
      reference: reference,
      issuedAtLabel: issuedAtLabel,
      tenderLabel: tenderLabel,
      tenderedMinor: tenderedMinor,
      changeMinor: changeMinor,
      paymentReference: paymentReference,
      footerLines: [
        ...footerLines.where((line) => !line.startsWith('COPY - ')),
        'COPY - reprinted from the completed sale.',
      ],
    );
  }

  Map<String, Object?> toJson() => {
    'businessName': businessName,
    'outletName': outletName,
    'address': address,
    'receiptHeader': receiptHeader,
    'title': title,
    'copy': copy,
    'items': items.map((item) => item.toJson()).toList(growable: false),
    'subtotalMinor': subtotalMinor,
    'serviceMinor': serviceMinor,
    'taxMinor': taxMinor,
    'totalMinor': totalMinor,
    'currency': currency,
    'currencyExponent': currencyExponent,
    'reference': reference,
    'issuedAtLabel': issuedAtLabel,
    'tenderLabel': tenderLabel,
    'tenderedMinor': tenderedMinor,
    'changeMinor': changeMinor,
    'paymentReference': paymentReference,
    'footerLines': footerLines,
  };

  static ReceiptData? fromJson(Map<String, Object?>? json) {
    if (json == null) {
      return null;
    }
    final outletName = json['outletName'];
    final items = json['items'];
    final subtotal = json['subtotalMinor'];
    final total = json['totalMinor'];
    final currency = json['currency'];
    final exponent = json['currencyExponent'];
    if (outletName is! String ||
        items is! List ||
        subtotal is! int ||
        total is! int ||
        currency is! String ||
        exponent is! int) {
      return null;
    }
    final parsedItems = <ReceiptLineItem>[];
    for (final item in items) {
      final parsed = ReceiptLineItem.fromJson(
        (item as Map?)?.cast<String, Object?>(),
      );
      if (parsed != null) {
        parsedItems.add(parsed);
      }
    }
    final footer = json['footerLines'];
    return ReceiptData(
      businessName: json['businessName'] as String?,
      outletName: outletName,
      address: json['address'] as String?,
      receiptHeader: json['receiptHeader'] as String?,
      title: json['title'] as String? ?? 'SALE RECEIPT',
      copy: json['copy'] == true,
      items: parsedItems,
      subtotalMinor: subtotal,
      serviceMinor: json['serviceMinor'] as int? ?? 0,
      taxMinor: json['taxMinor'] as int? ?? 0,
      totalMinor: total,
      currency: currency,
      currencyExponent: exponent,
      reference: json['reference'] as String?,
      issuedAtLabel: json['issuedAtLabel'] as String?,
      tenderLabel: json['tenderLabel'] as String?,
      tenderedMinor: json['tenderedMinor'] as int?,
      changeMinor: json['changeMinor'] as int?,
      paymentReference: json['paymentReference'] as String?,
      footerLines: footer is List
          ? footer.whereType<String>().toList(growable: false)
          : const [],
    );
  }
}

enum ReceiptLineAlignment { left, center }

/// One line of plain receipt text and its alignment. Keeping this pure makes
/// wrapping and content testable without bytes or hardware.
class ReceiptDocumentLine {
  const ReceiptDocumentLine(
    this.text, {
    this.alignment = ReceiptLineAlignment.left,
    this.bold = false,
  });

  final String text;
  final ReceiptLineAlignment alignment;
  final bool bold;
}

/// Pure receipt body builder. The ESC/POS writer only adds commands around the
/// lines produced here, so unit tests cover the exact visible content.
abstract final class ReceiptDocument {
  static List<ReceiptDocumentLine> build(ReceiptData data, int columns) {
    if (columns <= 0) {
      return const [];
    }
    final lines = <ReceiptDocumentLine>[];
    final money = data.money;

    final business = data.businessName;
    if (business != null && business.isNotEmpty) {
      for (final line in ReceiptLayout.wrap(business, columns)) {
        lines.add(_center(line, bold: true));
      }
      for (final line in ReceiptLayout.wrap(data.outletName, columns)) {
        lines.add(_center(line));
      }
    } else {
      for (final line in ReceiptLayout.wrap(data.outletName, columns)) {
        lines.add(_center(line, bold: true));
      }
    }
    if (data.address != null && data.address!.isNotEmpty) {
      for (final line in ReceiptLayout.wrap(data.address!, columns)) {
        lines.add(_center(line));
      }
    }
    if (data.receiptHeader != null && data.receiptHeader!.isNotEmpty) {
      for (final line in ReceiptLayout.wrap(data.receiptHeader!, columns)) {
        lines.add(_center(line));
      }
    }
    lines.add(ReceiptDocumentLine(ReceiptLayout.divider(columns)));

    if (data.copy) {
      lines.add(_center('COPY', bold: true));
      lines.add(_center('REPRINT - NOT AN ORIGINAL'));
      lines.add(ReceiptDocumentLine(ReceiptLayout.divider(columns)));
    }

    for (final line in ReceiptLayout.wrap(data.title, columns)) {
      lines.add(_center(line, bold: true));
    }
    lines.add(ReceiptDocumentLine(ReceiptLayout.divider(columns)));

    if (data.reference != null && data.reference!.isNotEmpty) {
      for (final line in ReceiptLayout.wrap(
        'Ref: ${data.reference}',
        columns,
      )) {
        lines.add(ReceiptDocumentLine(line));
      }
    }
    if (data.issuedAtLabel != null && data.issuedAtLabel!.isNotEmpty) {
      for (final line in ReceiptLayout.wrap(data.issuedAtLabel!, columns)) {
        lines.add(ReceiptDocumentLine(line));
      }
    }
    if ((data.reference != null && data.reference!.isNotEmpty) ||
        (data.issuedAtLabel != null && data.issuedAtLabel!.isNotEmpty)) {
      lines.add(ReceiptDocumentLine(ReceiptLayout.divider(columns)));
    }

    for (final item in data.items) {
      for (final line in ReceiptLayout.wrap(item.name, columns)) {
        lines.add(ReceiptDocumentLine(line));
      }
      if (item.variantName != null && item.variantName!.isNotEmpty) {
        for (final line in ReceiptLayout.wrap(item.variantName!, columns)) {
          lines.add(ReceiptDocumentLine(line));
        }
      }
      final unit = money.format(item.unitPriceMinor);
      final total = money.format(item.lineTotalMinor);
      for (final line in ReceiptLayout.columns(
        '${item.quantity} x $unit',
        total,
        columns,
      )) {
        lines.add(ReceiptDocumentLine(line));
      }
    }

    lines.add(ReceiptDocumentLine(ReceiptLayout.divider(columns)));
    _addColumns(lines, 'Subtotal', money.format(data.subtotalMinor), columns);
    if (data.serviceMinor != 0) {
      _addColumns(lines, 'Service', money.format(data.serviceMinor), columns);
    }
    if (data.taxMinor != 0) {
      _addColumns(lines, 'Tax', money.format(data.taxMinor), columns);
    }
    for (final line in ReceiptLayout.columns(
      'TOTAL',
      money.format(data.totalMinor),
      columns,
    )) {
      lines.add(ReceiptDocumentLine(line, bold: true));
    }
    lines.add(ReceiptDocumentLine(ReceiptLayout.divider(columns)));

    if (data.tenderLabel != null || data.tenderedMinor != null) {
      _addColumns(
        lines,
        data.tenderLabel ?? 'Tendered',
        data.tenderedMinor == null ? '' : money.format(data.tenderedMinor!),
        columns,
      );
    }
    if (data.changeMinor != null) {
      _addColumns(lines, 'Change', money.format(data.changeMinor!), columns);
    }
    if (data.paymentReference != null && data.paymentReference!.isNotEmpty) {
      _addColumns(lines, 'Reference', data.paymentReference!, columns);
    }

    for (final footer in data.footerLines) {
      for (final line in ReceiptLayout.wrap(footer, columns)) {
        lines.add(_center(line));
      }
    }

    return lines;
  }

  static ReceiptDocumentLine _center(String text, {bool bold = false}) {
    return ReceiptDocumentLine(
      text,
      alignment: ReceiptLineAlignment.center,
      bold: bold,
    );
  }

  static void _addColumns(
    List<ReceiptDocumentLine> lines,
    String left,
    String right,
    int columns,
  ) {
    for (final line in ReceiptLayout.columns(left, right, columns)) {
      lines.add(ReceiptDocumentLine(line));
    }
  }
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
    for (final line in ReceiptDocument.build(data, writer.columns)) {
      writer.alignment(line.alignment);
      writer.bold(line.bold);
      writer.line(line.text);
    }
    writer.alignment(ReceiptLineAlignment.left);
    writer.bold(false);
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
        businessName: 'Modern POS',
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
        tenderLabel: 'Cash tendered',
        tenderedMinor: 1000,
        changeMinor: 0,
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

class _EscPosWriter {
  _EscPosWriter({required this.columns, required this.encoding});

  final int columns;
  final PrinterEncoding encoding;
  final List<int> _bytes = [];

  void initialise() => _add(const [0x1B, 0x40]);

  void alignment(ReceiptLineAlignment value) {
    final code = value == ReceiptLineAlignment.center ? 1 : 0;
    _add([0x1B, 0x61, code]);
  }

  void bold(bool enabled) => _add([0x1B, 0x45, enabled ? 1 : 0]);

  void text(String value) => _add(PrinterTextEncoder.encode(value, encoding));

  void line(String value) {
    text(value);
    newline();
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
