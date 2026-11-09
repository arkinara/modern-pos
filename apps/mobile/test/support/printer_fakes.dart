import 'dart:typed_data';

import 'package:modern_pos_mobile/features/printing/printer_config_store.dart';
import 'package:modern_pos_mobile/features/printing/printer_models.dart';
import 'package:modern_pos_mobile/features/printing/printer_permissions.dart';
import 'package:modern_pos_mobile/features/printing/printer_transport.dart';

class FakePrinterTransport implements PrinterTransport {
  FakePrinterTransport({this.devices = const []});

  List<PrinterConnection> devices;
  Object? discoverFailure;
  Object? connectFailure;
  Object? writeFailure;
  bool connected = false;
  int connectCount = 0;
  int writeCount = 0;
  int disconnectCount = 0;
  Uint8List? lastBytes;

  @override
  Future<List<PrinterConnection>> discover() async {
    final failure = discoverFailure;
    if (failure != null) {
      throw failure;
    }
    return devices;
  }

  @override
  Future<void> connect(PrinterConnection connection) async {
    connectCount++;
    final failure = connectFailure;
    if (failure != null) {
      connected = false;
      throw failure;
    }
    connected = true;
  }

  @override
  Future<void> write(Uint8List bytes) async {
    final failure = writeFailure;
    if (failure != null) {
      connected = false;
      throw failure;
    }
    writeCount++;
    lastBytes = bytes;
  }

  @override
  Future<void> disconnect() async {
    disconnectCount++;
    connected = false;
  }

  @override
  bool get isConnected => connected;
}

class FakePrinterPermissions implements PrinterPermissionService {
  FakePrinterPermissions({
    this.status = PrinterPermissionStatus.denied,
    this.requestResult = PrinterPermissionStatus.granted,
  });

  PrinterPermissionStatus status;
  PrinterPermissionStatus requestResult;
  int checkCount = 0;
  int requestCount = 0;

  @override
  Future<PrinterPermissionStatus> check() async {
    checkCount++;
    return status;
  }

  @override
  Future<PrinterPermissionStatus> request() async {
    requestCount++;
    status = requestResult;
    return requestResult;
  }
}

class InMemoryPrinterConfigStore implements PrinterConfigStore {
  InMemoryPrinterConfigStore([this.config]);

  PrinterConfig? config;
  int saveCount = 0;
  int clearCount = 0;

  @override
  Future<void> clear() async {
    clearCount++;
    config = null;
  }

  @override
  Future<PrinterConfig?> load() async => config;

  @override
  Future<void> save(PrinterConfig next) async {
    saveCount++;
    config = next;
  }
}

PrinterConfig testPrinterConfig({
  PrinterTransportType transport = PrinterTransportType.bluetoothClassic,
  PaperWidth paperWidth = PaperWidth.mm58,
  PrinterEncoding encoding = PrinterEncoding.cp437,
  String address = 'AA:BB:CC:DD:EE:FF',
  String name = 'Test printer',
}) {
  return PrinterConfig(
    connection: PrinterConnection(
      transport: transport,
      name: name,
      address: address,
    ),
    paperWidth: paperWidth,
    encoding: encoding,
  );
}
