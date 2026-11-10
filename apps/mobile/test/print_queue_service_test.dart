import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modern_pos_mobile/core/database/app_database.dart';
import 'package:modern_pos_mobile/features/printing/print_job_models.dart';
import 'package:modern_pos_mobile/features/printing/print_job_mirror.dart';
import 'package:modern_pos_mobile/features/printing/print_queue_repository.dart';
import 'package:modern_pos_mobile/features/printing/print_queue_service.dart';
import 'package:modern_pos_mobile/features/printing/printer_adapter.dart';
import 'package:modern_pos_mobile/features/printing/printer_models.dart';

import 'support/checkout_fakes.dart';
import 'support/printer_fakes.dart';

class _Harness {
  _Harness({
    FakeReceiptPrinter? printer,
    InMemoryPrinterConfigStore? store,
    AppDatabase? database,
  }) : printer = printer ?? FakeReceiptPrinter(connected: true),
       store = store ?? InMemoryPrinterConfigStore(testPrinterConfig()),
       database = database ?? AppDatabase.forTesting(NativeDatabase.memory()) {
    repository = DriftPrintQueueRepository(this.database);
    service = _service(this.printer, repository, this.store);
  }

  final FakeReceiptPrinter printer;
  final InMemoryPrinterConfigStore store;
  final AppDatabase database;
  late final DriftPrintQueueRepository repository;
  late final PrintQueueService service;

  PrintQueueService _service(
    PrinterAdapter adapter,
    PrintQueueRepository repo,
    InMemoryPrinterConfigStore store,
  ) {
    return PrintQueueService(
      repository: repo,
      adapter: adapter,
      configStore: store,
      identityRepository: FakeReceiptIdentityRepository(),
      mirror: const NoopPrintJobMirror(),
      actorId: 'cashier-1',
      actorEmail: 'cashier@example.test',
    );
  }

  Future<void> dispose() => database.close();
}

void main() {
  test(
    'queued job survives a database restart and resumes without the sale',
    () async {
      final directory = Directory.systemTemp.createTempSync('print-queue-');
      final file = File('${directory.path}/queue.sqlite');
      final sale = testSale();
      final store = InMemoryPrinterConfigStore(testPrinterConfig());

      final firstDb = AppDatabase.forTesting(NativeDatabase(file));
      final firstRepository = DriftPrintQueueRepository(firstDb);
      final first = PrintQueueService(
        repository: firstRepository,
        adapter: FakeReceiptPrinter(connected: true),
        configStore: store,
        identityRepository: FakeReceiptIdentityRepository(),
        mirror: const NoopPrintJobMirror(),
        actorId: 'cashier-1',
        actorEmail: 'cashier@example.test',
      );
      final queued = await first.enqueueSale(
        sale: sale,
        outletId: 'outlet-1',
        deviceId: 'device-1',
      );
      expect(queued.state, PrintJobState.queued);
      expect(queued.saleId, sale.id);
      await firstDb.close();

      final secondDb = AppDatabase.forTesting(NativeDatabase(file));
      final secondRepository = DriftPrintQueueRepository(secondDb);
      final restartedPrinter = FakeReceiptPrinter(connected: true);
      final second = PrintQueueService(
        repository: secondRepository,
        adapter: restartedPrinter,
        configStore: store,
        identityRepository: FakeReceiptIdentityRepository(),
        mirror: const NoopPrintJobMirror(),
        actorId: 'cashier-1',
        actorEmail: 'cashier@example.test',
      );

      final loaded = await second.recoverInterruptedJobs();
      expect(loaded, hasLength(1));
      expect(loaded.single.id, queued.id);
      expect(loaded.single.state, PrintJobState.queued);

      final processed = await second.processJob(queued.id);
      expect(processed.state, PrintJobState.sent);
      expect(restartedPrinter.printCount, 1);
      expect(await secondRepository.findOriginalForSale(sale.id), isNotNull);
      await secondDb.close();
      directory.deleteSync(recursive: true);
    },
  );

  test(
    'known print failure is recorded as uncertain and never auto-resent',
    () async {
      final harness = _Harness(
        printer: FakeReceiptPrinter(connected: true, throwOnPrint: true),
      );
      addTearDown(harness.dispose);
      final sale = testSale();

      final queued = await harness.service.enqueueSale(
        sale: sale,
        outletId: 'outlet-1',
        deviceId: 'device-1',
      );
      final failed = await harness.service.processJob(queued.id);

      expect(failed.state, PrintJobState.uncertain);
      expect(failed.attempts, 1);
      expect(failed.lastError, isNotNull);
      expect(harness.printer.printCount, 1);

      final again = await harness.service.processJob(queued.id);
      expect(again.state, PrintJobState.uncertain);
      expect(
        harness.printer.printCount,
        1,
        reason: 'ambiguous job is not resent',
      );

      final audits = await harness.service.auditsForSale(sale.id);
      expect(
        audits.any((entry) => entry.action == PrintAuditAction.uncertain),
        isTrue,
      );
    },
  );

  test(
    'connect failure is failed (known not sent) and retry sends once',
    () async {
      final transport = FakePrinterTransport()
        ..connectFailure = const PrinterException(
          PrinterFailureKind.notConnected,
          'Printer off',
        );
      final adapter = EscPosPrinterAdapter(transport: transport);
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final store = InMemoryPrinterConfigStore(testPrinterConfig());
      final service = PrintQueueService(
        repository: DriftPrintQueueRepository(database),
        adapter: adapter,
        configStore: store,
        identityRepository: FakeReceiptIdentityRepository(),
        mirror: const NoopPrintJobMirror(),
        actorId: 'cashier-1',
        actorEmail: 'cashier@example.test',
      );
      final sale = testSale();

      final queued = await service.enqueueSale(
        sale: sale,
        outletId: 'outlet-1',
        deviceId: 'device-1',
      );
      final failed = await service.processJob(queued.id);
      expect(failed.state, PrintJobState.failed);
      expect(transport.writeCount, 0);

      transport.connectFailure = null;
      final retried = await service.retryJob(queued.id);
      expect(retried.state, PrintJobState.sent);
      expect(transport.writeCount, 1);
      expect(retried.attempts, 2);
    },
  );

  test('no configured printer leaves an actionable queued job', () async {
    final harness = _Harness(store: InMemoryPrinterConfigStore());
    addTearDown(harness.dispose);
    final sale = testSale();

    final queued = await harness.service.enqueueSale(
      sale: sale,
      outletId: 'outlet-1',
      deviceId: 'device-1',
    );
    final result = await harness.service.processJob(queued.id);

    expect(result.state, PrintJobState.queued);
    expect(result.attempts, 0);
    expect(result.lastError, contains('No printer is configured'));
    expect(harness.printer.printCount, 0);

    harness.store.config = testPrinterConfig();
    final sent = await harness.service.retryJob(queued.id);
    expect(sent.state, PrintJobState.sent);
    expect(harness.printer.printCount, 1);
  });

  test(
    'restart while SENDING becomes UNCERTAIN and is not auto-resent',
    () async {
      final harness = _Harness();
      addTearDown(harness.dispose);
      final sale = testSale();
      final queued = await harness.service.enqueueSale(
        sale: sale,
        outletId: 'outlet-1',
        deviceId: 'device-1',
      );
      await harness.repository.save(
        queued.copyWith(state: PrintJobState.sending, attempts: 1),
      );

      final recovered = await harness.service.recoverInterruptedJobs();
      expect(recovered.single.state, PrintJobState.uncertain);
      expect(recovered.single.lastError, contains('unknown'));
      expect(harness.printer.printCount, 0);
    },
  );

  test(
    'reprint is a distinct COPY job with audit and one original per sale',
    () async {
      final harness = _Harness();
      addTearDown(harness.dispose);
      final sale = testSale();

      final original = await harness.service.enqueueSale(
        sale: sale,
        outletId: 'outlet-1',
        deviceId: 'device-1',
      );
      final sent = await harness.service.processJob(original.id);
      expect(sent.state, PrintJobState.sent);

      final duplicateEnqueue = await harness.service.enqueueSale(
        sale: sale,
        outletId: 'outlet-1',
        deviceId: 'device-1',
      );
      expect(duplicateEnqueue.id, original.id);

      final copy = await harness.service.reprintJob(original.id);
      expect(copy.id, isNot(original.id));
      expect(copy.copy, isTrue);
      expect(copy.receipt.copy, isTrue);
      expect(copy.state, PrintJobState.sent);
      expect(harness.printer.printCount, 2);

      final audits = await harness.service.auditsForSale(sale.id);
      expect(
        audits.any(
          (entry) =>
              entry.action == PrintAuditAction.reprint &&
              entry.copy &&
              entry.actorId == 'cashier-1',
        ),
        isTrue,
      );
      final originalAfter = await harness.repository.byId(original.id);
      expect(originalAfter!.state, PrintJobState.sent);
      expect(originalAfter.copy, isFalse);
    },
  );

  test('auto retry stays bounded and never applies to uncertain jobs', () {
    final queued = testPrintJob(state: PrintJobState.failed, attempts: 1);
    final uncertain = testPrintJob(state: PrintJobState.uncertain, attempts: 1);

    expect(PrintRetryPolicy.shouldAutoRetry(queued), isTrue);
    expect(PrintRetryPolicy.shouldAutoRetry(uncertain), isFalse);
    expect(PrintRetryPolicy.delayForAttempt(1), const Duration(seconds: 5));
    expect(PrintRetryPolicy.delayForAttempt(2), const Duration(seconds: 15));
    expect(PrintRetryPolicy.delayForAttempt(3), const Duration(seconds: 60));

    final exhausted = testPrintJob(
      state: PrintJobState.failed,
      attempts: PrintRetryPolicy.maxAttempts,
    );
    expect(PrintRetryPolicy.shouldAutoRetry(exhausted), isFalse);
    expect(PrintRetryPolicy.canRetry(exhausted), isFalse);
  });
}
