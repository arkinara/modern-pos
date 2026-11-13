import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modern_pos_mobile/features/printing/printer_controller.dart';
import 'package:modern_pos_mobile/features/printing/printer_models.dart';
import 'package:modern_pos_mobile/features/printing/printer_permissions.dart';

import 'support/printer_fakes.dart';

void main() {
  late FakePrinterTransport transport;
  late FakePrinterPermissions permissions;
  late InMemoryPrinterConfigStore store;
  late ProviderContainer container;

  PrinterController controller() =>
      container.read(printerControllerProvider.notifier);

  Future<PrinterState> current() async =>
      container.read(printerControllerProvider.future);

  Future<void> pump() async {
    transport = FakePrinterTransport();
    permissions = FakePrinterPermissions();
    store = InMemoryPrinterConfigStore();
    container = ProviderContainer(
      overrides: [
        printerTransportFactoryProvider.overrideWithValue(
          FakePrinterTransportFactory(transport),
        ),
        printerPermissionServiceProvider.overrideWithValue(permissions),
        printerConfigStoreProvider.overrideWithValue(store),
      ],
    );
    addTearDown(container.dispose);
    await current();
  }

  test('starts in the never-configured state', () async {
    await pump();
    final state = await current();
    expect(state.status, PrinterConnectionStatus.unconfigured);
    expect(state.config, isNull);
    expect(state.failureKind, isNull);
  });

  test('saves, connects and sends a test print', () async {
    await pump();
    permissions.status = PrinterPermissionStatus.granted;

    await controller().saveConfig(testPrinterConfig());
    expect(store.saveCount, 1);

    await controller().connect();
    var state = await current();
    expect(state.status, PrinterConnectionStatus.connected);
    expect(transport.connected, isTrue);
    expect(state.failureKind, isNull);

    await controller().testPrint();
    state = await current();
    expect(transport.writeCount, 1);
    expect(state.lastTestPrintAt, isNotNull);
    expect(state.message, contains('Test print bytes sent'));
  });

  test('denied permission is visible and can be requested again', () async {
    await pump();
    await controller().saveConfig(testPrinterConfig());

    await controller().connect();
    var state = await current();
    expect(state.failureKind, PrinterFailureKind.permissionDenied);
    expect(state.status, PrinterConnectionStatus.disconnected);
    expect(transport.connectCount, 0);
    expect(state.message, contains('Tap Grant Bluetooth permission'));

    permissions.requestResult = PrinterPermissionStatus.granted;
    await controller().requestPermissions();
    state = await current();
    expect(permissions.requestCount, 1);
    expect(state.permissionsGranted, isTrue);

    await controller().connect();
    state = await current();
    expect(state.status, PrinterConnectionStatus.connected);
  });

  test('connection loss mid-test is recoverable', () async {
    await pump();
    permissions.status = PrinterPermissionStatus.granted;
    await controller().saveConfig(testPrinterConfig());
    await controller().connect();

    transport.writeFailure = const PrinterException(
      PrinterFailureKind.connectionLost,
      'socket closed',
    );
    await controller().testPrint();
    var state = await current();
    expect(state.failureKind, PrinterFailureKind.connectionLost);
    expect(state.status, PrinterConnectionStatus.disconnected);
    expect(state.message, contains('connection dropped'));

    transport.writeFailure = null;
    await controller().connect();
    await controller().testPrint();
    state = await current();
    expect(state.status, PrinterConnectionStatus.connected);
    expect(transport.writeCount, 1);
    expect(state.failureKind, isNull);
  });

  test(
    'LAN transport skips Bluetooth permission and connects via the factory',
    () async {
      await pump();
      permissions.status = PrinterPermissionStatus.denied;
      await controller().saveConfig(
        testPrinterConfig(
          transport: PrinterTransportType.network,
          address: '127.0.0.1:9100',
        ),
      );
      var state = await current();
      expect(state.transportSupported, isTrue);
      expect(state.permissionsGranted, isTrue);
      expect(permissions.checkCount, 1);
      expect(state.message, contains('Physical delivery'));

      await controller().connect();
      state = await current();
      expect(state.failureKind, isNull);
      expect(state.status, PrinterConnectionStatus.connected);
      expect(transport.connectCount, 1);
      expect(permissions.checkCount, 1);

      await controller().testPrint();
      state = await current();
      expect(transport.writeCount, 1);
      expect(state.lastTestPrintAt, isNotNull);
    },
  );

  test('discovers paired devices and classifies a missing device', () async {
    await pump();
    permissions.status = PrinterPermissionStatus.granted;
    await controller().saveConfig(testPrinterConfig());

    transport.devices = const [
      PrinterConnection(
        transport: PrinterTransportType.bluetoothClassic,
        name: 'Counter printer',
        address: '11:22:33:44:55:66',
      ),
    ];
    await controller().discover();
    var state = await current();
    expect(state.discovered, hasLength(1));
    expect(state.discovered.single.name, 'Counter printer');

    transport.discoverFailure = const PrinterException(
      PrinterFailureKind.deviceNotFound,
      'not paired',
    );
    await controller().discover();
    state = await current();
    expect(state.failureKind, PrinterFailureKind.deviceNotFound);
    expect(state.discovered, isEmpty);
  });

  test(
    'clearing the configuration disconnects and resets to first-run',
    () async {
      await pump();
      permissions.status = PrinterPermissionStatus.granted;
      await controller().saveConfig(testPrinterConfig());
      await controller().connect();

      await controller().clearConfig();
      final state = await current();
      expect(state.status, PrinterConnectionStatus.unconfigured);
      expect(state.config, isNull);
      expect(store.config, isNull);
      expect(transport.connected, isFalse);
    },
  );
}
