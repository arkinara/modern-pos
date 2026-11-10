import 'dart:typed_data';

import 'package:modern_pos_mobile/features/printing/esc_pos_receipt.dart';
import 'package:modern_pos_mobile/features/printing/print_job_models.dart';
import 'package:modern_pos_mobile/features/printing/print_queue_repository.dart';
import 'package:modern_pos_mobile/features/printing/printer_config_store.dart';
import 'package:modern_pos_mobile/features/printing/printer_models.dart';
import 'package:modern_pos_mobile/features/printing/printer_permissions.dart';
import 'package:modern_pos_mobile/features/printing/printer_transport.dart';
import 'package:modern_pos_mobile/features/printing/receipt_identity.dart';

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

class InMemoryPrintQueueRepository implements PrintQueueRepository {
  final Map<String, PrintJob> jobs = {};
  final List<PrintAuditEntry> audits = [];

  @override
  Future<void> save(PrintJob job) async {
    jobs[job.id] = job;
  }

  @override
  Future<void> update(PrintJob job) async {
    jobs[job.id] = job;
  }

  @override
  Future<PrintJob?> byId(String id) async => jobs[id];

  @override
  Future<PrintJob?> findOriginalForSale(String saleId) async {
    for (final job in jobs.values) {
      if (job.saleId == saleId && !job.copy) {
        return job;
      }
    }
    return null;
  }

  @override
  Future<List<PrintJob>> loadJobs() async =>
      jobs.values.toList(growable: false)
        ..sort((left, right) => right.createdAt.compareTo(left.createdAt));

  @override
  Future<List<PrintJob>> loadActive() async =>
      jobs.values.where((job) => job.active).toList(growable: false);

  @override
  Future<void> appendAudit(PrintAuditEntry entry) async {
    audits.add(entry);
  }

  @override
  Future<List<PrintAuditEntry>> loadAudits({String? saleId}) async {
    return audits
        .where((entry) => saleId == null || entry.saleId == saleId)
        .toList(growable: false);
  }
}

class FakeReceiptIdentityRepository implements ReceiptIdentityRepository {
  FakeReceiptIdentityRepository([
    this.identity = const ReceiptIdentity(
      businessName: 'Modern POS Demo',
      outletName: 'Main Outlet',
      address: 'Jl. Example No. 1',
      receiptHeader: 'Modern POS Demo',
      receiptFooter: 'Thank you',
    ),
  ]);

  ReceiptIdentity? identity;
  int loadCount = 0;

  @override
  Future<ReceiptIdentity?> load(String outletId) async {
    loadCount++;
    return identity;
  }
}

PrintJob testPrintJob({
  String id = 'job-1',
  String saleId = 'sale-1',
  PrintJobState state = PrintJobState.queued,
  int attempts = 0,
  bool copy = false,
}) {
  final now = DateTime.utc(2026, 1, 1, 10);
  return PrintJob(
    id: id,
    saleId: saleId,
    saleReference: 'SALE-1',
    outletId: 'outlet-1',
    deviceId: 'device-1',
    printerConfig: testPrinterConfig(),
    receipt: const ReceiptData(
      outletName: 'Main Outlet',
      items: [],
      subtotalMinor: 0,
      totalMinor: 0,
      currency: 'IDR',
      currencyExponent: 0,
      reference: 'SALE-1',
    ),
    state: state,
    copy: copy,
    attempts: attempts,
    createdAt: now,
    updatedAt: now,
  );
}
