import 'dart:typed_data';

import 'esc_pos_receipt.dart';
import 'printer_models.dart';
import 'printer_transport.dart';

/// Adapter named in ARCHITECTURE.md section 8. The app depends on this
/// interface; the transport and byte-stream builder are injected behind it.
abstract interface class PrinterAdapter {
  Future<void> connect(PrinterConfig config);

  Future<void> testPrint();

  Future<void> printReceipt(ReceiptData data);

  Future<void> disconnect();

  bool get isConnected;
}

/// Renders ESC/POS bytes for receipt data and writes them to the transport.
///
/// A successful [testPrint] means the byte stream was accepted by the transport
/// socket. It is not proof of physical output until a real device is tested.
class EscPosPrinterAdapter implements PrinterAdapter {
  EscPosPrinterAdapter({
    required this.transport,
    this.builder = const EscPosReceiptBuilder(),
  });

  final PrinterTransport transport;
  final EscPosReceiptBuilder builder;
  PrinterConfig? _config;

  @override
  bool get isConnected => transport.isConnected;

  @override
  Future<void> connect(PrinterConfig config) async {
    if (!config.transport.implemented) {
      throw PrinterException(
        PrinterFailureKind.unsupportedTransport,
        'Transport ${config.transport.wireName} has no adapter in this build.',
      );
    }
    await transport.connect(config.connection);
    _config = config;
  }

  @override
  Future<void> testPrint() async {
    final config = _requireConfig();
    await _send(builder.buildTestReceipt(config));
  }

  @override
  Future<void> printReceipt(ReceiptData data) async {
    final config = _requireConfig();
    await _send(builder.build(data, config));
  }

  @override
  Future<void> disconnect() async {
    await transport.disconnect();
  }

  PrinterConfig _requireConfig() {
    final config = _config;
    if (config == null) {
      throw const PrinterException(
        PrinterFailureKind.notConnected,
        'No printer is configured for this session.',
      );
    }
    if (!transport.isConnected) {
      throw const PrinterException(
        PrinterFailureKind.notConnected,
        'The printer connection is closed.',
      );
    }
    return config;
  }

  Future<void> _send(Uint8List bytes) async {
    await transport.write(bytes);
  }
}
