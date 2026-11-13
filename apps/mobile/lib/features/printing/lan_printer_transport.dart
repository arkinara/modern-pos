import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'printer_models.dart';
import 'printer_transport.dart';

/// Raw TCP (typically port 9100) transport for network receipt printers.
///
/// This transport is exercised on this host against a local TCP listener:
/// [write] completes only after the socket accepted the byte stream. Physical
/// paper output remains `PENDING - requires LAN printer model` until a real
/// device is tested.
class LanPrinterTransport implements PrinterTransport {
  LanPrinterTransport({this.timeout = const Duration(seconds: 5)});

  final Duration timeout;
  Socket? _socket;

  @override
  bool get isConnected => _socket != null;

  @override
  Future<List<PrinterConnection>> discover() async {
    // Raw TCP printers do not advertise themselves; the address is entered by
    // the operator. Discovery stays empty rather than claiming a scan result.
    return const [];
  }

  @override
  Future<void> connect(PrinterConnection connection) async {
    if (connection.transport != PrinterTransportType.network) {
      throw const PrinterException(
        PrinterFailureKind.unsupportedTransport,
        'The LAN transport only accepts a network connection.',
      );
    }
    final target = parseAddress(connection.address);
    await disconnect();
    try {
      final socket = await Socket.connect(
        target.host,
        target.port,
        timeout: timeout,
      );
      socket.setOption(SocketOption.tcpNoDelay, true);
      _socket = socket;
    } on TimeoutException {
      _socket = null;
      throw PrinterException(
        PrinterFailureKind.connectionLost,
        'LAN printer ${target.host}:${target.port} did not accept the connection in time.',
        platformCode: 'connection_timeout',
      );
    } on SocketException catch (error) {
      _socket = null;
      throw PrinterException(
        PrinterFailureKind.connectionLost,
        'LAN printer ${target.host}:${target.port} refused or dropped the connection: ${error.message}',
        platformCode: 'connection_failed',
      );
    }
  }

  @override
  Future<void> write(Uint8List bytes) async {
    final socket = _socket;
    if (socket == null) {
      throw const PrinterException(
        PrinterFailureKind.notConnected,
        'No LAN printer connection is open.',
      );
    }
    try {
      socket.add(bytes);
      await socket.flush();
    } on SocketException catch (error) {
      await disconnect();
      throw PrinterException(
        PrinterFailureKind.connectionLost,
        'The LAN connection dropped while sending bytes: ${error.message}',
        platformCode: 'connection_lost',
      );
    } catch (error) {
      await disconnect();
      throw PrinterException(
        PrinterFailureKind.connectionLost,
        'The LAN connection failed while sending bytes: $error',
        platformCode: 'connection_lost',
      );
    }
  }

  @override
  Future<void> disconnect() async {
    final socket = _socket;
    _socket = null;
    if (socket == null) {
      return;
    }
    try {
      socket.destroy();
    } catch (_) {
      // The socket is already unusable; local state is closed.
    }
  }

  /// Parses `host:port`. A bare host uses the conventional raw-print port 9100.
  static ({String host, int port}) parseAddress(String address) {
    final value = address.trim();
    if (value.isEmpty) {
      throw const PrinterException(
        PrinterFailureKind.deviceNotFound,
        'Enter a LAN printer address as host:port.',
      );
    }
    var host = value;
    var port = 9100;
    final separator = value.lastIndexOf(':');
    if (separator > 0 && value.indexOf(':') == separator) {
      host = value.substring(0, separator);
      final parsed = int.tryParse(value.substring(separator + 1));
      if (parsed == null || parsed < 1 || parsed > 65535) {
        throw const PrinterException(
          PrinterFailureKind.deviceNotFound,
          'The LAN port must be a number between 1 and 65535.',
        );
      }
      port = parsed;
    }
    if (host.isEmpty) {
      throw const PrinterException(
        PrinterFailureKind.deviceNotFound,
        'Enter a LAN printer host name or IP address.',
      );
    }
    return (host: host, port: port);
  }
}
