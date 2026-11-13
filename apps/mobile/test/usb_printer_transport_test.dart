import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modern_pos_mobile/features/printing/printer_models.dart';
import 'package:modern_pos_mobile/features/printing/usb_printer_transport.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('modern_pos/printer_usb');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() async {
    messenger.setMockMethodCallHandler(channel, null);
  });

  test(
    'discovers, connects and writes bytes through the USB channel',
    () async {
      final calls = <String>[];
      messenger.setMockMethodCallHandler(channel, (call) async {
        calls.add(call.method);
        return switch (call.method) {
          'listDevices' => <Object?>[
            {'deviceId': 'usb-1', 'name': 'USB thermal printer'},
          ],
          _ => true,
        };
      });

      final transport = UsbPrinterTransport();
      final devices = await transport.discover();
      expect(devices, hasLength(1));
      expect(devices.single.transport, PrinterTransportType.usb);
      expect(devices.single.address, 'usb-1');

      await transport.connect(
        const PrinterConnection(
          transport: PrinterTransportType.usb,
          name: 'USB thermal printer',
          address: 'usb-1',
        ),
      );
      expect(transport.isConnected, isTrue);
      await transport.write(Uint8List.fromList([0x1B, 0x40]));
      await transport.disconnect();
      expect(transport.isConnected, isFalse);
      expect(calls, ['listDevices', 'connect', 'write', 'disconnect']);
    },
  );

  test('classifies a USB write failure as connection lost', () async {
    var failWrites = false;
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'write' && failWrites) {
        throw PlatformException(
          code: 'connection_lost',
          message: 'cable removed',
        );
      }
      return true;
    });

    final transport = UsbPrinterTransport();
    await transport.connect(
      const PrinterConnection(
        transport: PrinterTransportType.usb,
        name: 'USB thermal printer',
        address: 'usb-1',
      ),
    );
    failWrites = true;
    await expectLater(
      transport.write(Uint8List.fromList([0x1B])),
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
}
