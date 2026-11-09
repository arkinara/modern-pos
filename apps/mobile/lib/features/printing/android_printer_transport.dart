import 'package:flutter/services.dart';

import 'printer_models.dart';
import 'printer_transport.dart';

/// Android Bluetooth Classic (RFCOMM/SPP) transport.
///
/// The Kotlin host owns the socket and paired-device discovery. Calls are
/// classified into [PrinterException]s so the cashier UI can show a specific,
/// retryable state. Physical delivery is `PENDING — requires printer model +
/// Android device`; this class never claims that paper was printed.
class AndroidBluetoothPrinterTransport implements PrinterTransport {
  AndroidBluetoothPrinterTransport({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel('modern_pos/printer');

  final MethodChannel _channel;
  bool _connected = false;

  @override
  bool get isConnected => _connected;

  @override
  Future<List<PrinterConnection>> discover() async {
    try {
      final devices = await _channel.invokeListMethod<Object?>(
        'listPairedDevices',
      );
      final connections = <PrinterConnection>[];
      for (final entry in devices ?? const <Object?>[]) {
        final map = (entry as Map?)?.cast<String, Object?>();
        final address = map?['address'] as String?;
        if (address == null || address.isEmpty) {
          continue;
        }
        connections.add(
          PrinterConnection(
            transport: PrinterTransportType.bluetoothClassic,
            name: map?['name'] as String? ?? address,
            address: address,
          ),
        );
      }
      return connections;
    } catch (error) {
      throw _classify(error, PrinterFailureKind.deviceNotFound);
    }
  }

  @override
  Future<void> connect(PrinterConnection connection) async {
    if (connection.transport != PrinterTransportType.bluetoothClassic) {
      throw const PrinterException(
        PrinterFailureKind.unsupportedTransport,
        'Only the Bluetooth Classic transport is implemented.',
      );
    }
    try {
      await _channel.invokeMethod<bool>('connect', {
        'address': connection.address,
      });
      _connected = true;
    } catch (error) {
      _connected = false;
      throw _classify(error, PrinterFailureKind.connectionLost);
    }
  }

  @override
  Future<void> write(Uint8List bytes) async {
    if (!_connected) {
      throw const PrinterException(
        PrinterFailureKind.notConnected,
        'No printer connection is open.',
      );
    }
    try {
      await _channel.invokeMethod<bool>('write', {'bytes': bytes});
    } catch (error) {
      _connected = false;
      throw _classify(error, PrinterFailureKind.connectionLost);
    }
  }

  @override
  Future<void> disconnect() async {
    _connected = false;
    try {
      await _channel.invokeMethod<bool>('disconnect');
    } on MissingPluginException {
      // Nothing to close when the host platform is unavailable.
    } on PlatformException {
      // The local connection state is already torn down.
    }
  }

  PrinterException _classify(Object error, PrinterFailureKind fallback) {
    if (error is PrinterException) {
      return error;
    }
    if (error is PlatformException) {
      return PrinterException(
        PrinterException.kindFromPlatformCode(error.code),
        error.message ?? error.code,
        platformCode: error.code,
      );
    }
    if (error is MissingPluginException) {
      return PrinterException(
        PrinterFailureKind.unknown,
        'Printer platform channel unavailable on this platform.',
        platformCode: 'missing_plugin',
      );
    }
    return PrinterException(fallback, error.toString());
  }
}
