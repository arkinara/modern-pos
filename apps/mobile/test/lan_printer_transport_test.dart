import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:modern_pos_mobile/features/printing/lan_printer_transport.dart';
import 'package:modern_pos_mobile/features/printing/printer_adapter.dart';
import 'package:modern_pos_mobile/features/printing/printer_models.dart';

void main() {
  test('parses host:port and defaults to raw TCP port 9100', () {
    final explicit = LanPrinterTransport.parseAddress('192.168.1.50:9101');
    expect(explicit.host, '192.168.1.50');
    expect(explicit.port, 9101);

    final fallback = LanPrinterTransport.parseAddress('printer.local');
    expect(fallback.host, 'printer.local');
    expect(fallback.port, 9100);

    expect(
      () => LanPrinterTransport.parseAddress('printer.local:99999'),
      throwsA(
        isA<PrinterException>().having(
          (error) => error.kind,
          'kind',
          PrinterFailureKind.deviceNotFound,
        ),
      ),
    );
  });

  test('writes the ESC/POS test stream to a real local TCP listener', () async {
    final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final received = BytesBuilder();
    final firstBytes = Completer<Uint8List>();
    final subscription = server.listen((socket) {
      socket.listen(
        (chunk) {
          received.add(chunk);
          if (!firstBytes.isCompleted && received.length > 0) {
            firstBytes.complete(received.toBytes());
          }
        },
        onDone: () {
          if (!firstBytes.isCompleted) {
            firstBytes.complete(received.toBytes());
          }
        },
      );
    });

    final transport = LanPrinterTransport();
    final adapter = EscPosPrinterAdapter(transport: transport);
    try {
      await adapter.connect(testNetworkConfig('127.0.0.1:${server.port}'));
      expect(adapter.isConnected, isTrue);
      await adapter.testPrint();
      final bytes = await firstBytes.future.timeout(const Duration(seconds: 3));
      expect(bytes, isNotEmpty);
      expect(bytes.first, 0x1B);
      expect(received.length, bytes.length);
    } finally {
      await adapter.disconnect();
      await subscription.cancel();
      await server.close();
    }
  });

  test('classifies a refused LAN connection as connection lost', () async {
    final transport = LanPrinterTransport(
      timeout: const Duration(milliseconds: 500),
    );
    await expectLater(
      transport.connect(testNetworkConnection('127.0.0.1:1')),
      throwsA(
        isA<PrinterException>().having(
          (error) => error.kind,
          'kind',
          PrinterFailureKind.connectionLost,
        ),
      ),
    );
    expect(transport.isConnected, isFalse);
  });

  test('rejects a write after the local connection is closed', () async {
    final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final accept = server.listen((socket) {
      socket.listen((_) {});
    });
    final transport = LanPrinterTransport();
    try {
      await transport.connect(
        testNetworkConnection('127.0.0.1:${server.port}'),
      );
      await transport.disconnect();
      await expectLater(
        transport.write(Uint8List.fromList([0x1B])),
        throwsA(
          isA<PrinterException>().having(
            (error) => error.kind,
            'kind',
            PrinterFailureKind.notConnected,
          ),
        ),
      );
    } finally {
      await accept.cancel();
      await server.close();
    }
  });
}

PrinterConfig testNetworkConfig(String address) => PrinterConfig(
  connection: testNetworkConnection(address),
  paperWidth: PaperWidth.mm58,
  encoding: PrinterEncoding.cp437,
);

PrinterConnection testNetworkConnection(String address) => PrinterConnection(
  transport: PrinterTransportType.network,
  name: 'LAN printer',
  address: address,
);
