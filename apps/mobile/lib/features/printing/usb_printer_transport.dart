import 'package:flutter/services.dart';

import 'printer_models.dart';
import 'printer_transport.dart';

/// Android USB host transport.
///
/// The Kotlin host owns USB permission, endpoint discovery and bulk transfer.
/// Framing and state transitions are unit-tested with a fake platform channel;
/// physical delivery is `PENDING - requires USB printer model + Android device`
/// and this class never claims that paper was printed.
class UsbPrinterTransport implements PrinterTransport {
  UsbPrinterTransport({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel('modern_pos/printer_usb');

  final MethodChannel _channel;
  bool _connected = false;

  @override
  bool get isConnected => _connected;

  @override
  Future<List<PrinterConnection>> discover() async {
    try {
      final devices = await _channel.invokeListMethod<Object?>('listDevices');
      final connections = <PrinterConnection>[];
      for (final entry in devices ?? const <Object?>[]) {
        final map = (entry as Map?)?.cast<String, Object?>();
        final deviceId = map?['deviceId'] as String?;
        if (deviceId == null || deviceId.isEmpty) {
          continue;
        }
        connections.add(
          PrinterConnection(
            transport: PrinterTransportType.usb,
            name: map?['name'] as String? ?? deviceId,
            address: deviceId,
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
    if (connection.transport != PrinterTransportType.usb) {
      throw const PrinterException(
        PrinterFailureKind.unsupportedTransport,
        'The USB transport only accepts a USB connection.',
      );
    }
    try {
      await _channel.invokeMethod<bool>('connect', {
        'deviceId': connection.address,
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
        'No USB printer connection is open.',
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
        'USB printer platform channel unavailable on this platform.',
        platformCode: 'missing_plugin',
      );
    }
    return PrinterException(fallback, error.toString());
  }
}
