import 'dart:typed_data';

import 'printer_models.dart';

/// Byte transport boundary. The adapter talks only to this interface so tests
/// can substitute an in-memory transport and hardware can replace the Android
/// implementation without touching receipt layout.
abstract interface class PrinterTransport {
  Future<List<PrinterConnection>> discover();

  Future<void> connect(PrinterConnection connection);

  Future<void> write(Uint8List bytes);

  Future<void> disconnect();

  bool get isConnected;
}
