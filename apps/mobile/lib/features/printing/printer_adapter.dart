import 'dart:typed_data';

import 'esc_pos_receipt.dart';
import 'printer_models.dart';
import 'printer_transport.dart';
import 'printer_transport_factory.dart';

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
    PrinterTransport? transport,
    PrinterTransportFactory? transports,
    this.builder = const EscPosReceiptBuilder(),
  }) : _fixedTransport = transport,
       _transports = transports ?? const PlatformPrinterTransportFactory();

  final PrinterTransport? _fixedTransport;
  final PrinterTransportFactory _transports;
  final EscPosReceiptBuilder builder;
  PrinterTransport? _activeTransport;
  PrinterConfig? _config;

  @override
  bool get isConnected => _activeTransport?.isConnected ?? false;

  @override
  Future<void> connect(PrinterConfig config) async {
    if (!config.transport.implemented) {
      throw PrinterException(
        PrinterFailureKind.unsupportedTransport,
        'Transport ${config.transport.wireName} has no adapter in this build.',
      );
    }
    await _activeTransport?.disconnect();
    final transport = _fixedTransport ?? _transports.create(config.transport);
    await transport.connect(config.connection);
    _activeTransport = transport;
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
    final transport = _activeTransport;
    _activeTransport = null;
    _config = null;
    if (transport != null) {
      await transport.disconnect();
    }
  }

  PrinterConfig _requireConfig() {
    final config = _config;
    if (config == null) {
      throw const PrinterException(
        PrinterFailureKind.notConnected,
        'No printer is configured for this session.',
      );
    }
    if (!isConnected) {
      throw const PrinterException(
        PrinterFailureKind.notConnected,
        'The printer connection is closed.',
      );
    }
    return config;
  }

  Future<void> _send(Uint8List bytes) async {
    final transport = _activeTransport;
    if (transport == null) {
      throw const PrinterException(
        PrinterFailureKind.notConnected,
        'The printer connection is closed.',
      );
    }
    await transport.write(bytes);
  }
}
