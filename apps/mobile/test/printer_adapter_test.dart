import 'package:flutter_test/flutter_test.dart';
import 'package:modern_pos_mobile/features/printing/esc_pos_receipt.dart';
import 'package:modern_pos_mobile/features/printing/printer_adapter.dart';
import 'package:modern_pos_mobile/features/printing/printer_models.dart';

import 'support/printer_fakes.dart';

void main() {
  const data = ReceiptData(
    outletName: 'Modern POS',
    items: [
      ReceiptLineItem(
        name: 'Tea',
        quantity: 1,
        unitPriceMinor: 18000,
        lineTotalMinor: 18000,
      ),
    ],
    subtotalMinor: 18000,
    totalMinor: 18000,
    currency: 'IDR',
    currencyExponent: 0,
  );

  test('connects, sends a test print and a receipt byte stream', () async {
    final transport = FakePrinterTransport();
    final adapter = EscPosPrinterAdapter(transport: transport);

    await adapter.connect(testPrinterConfig());
    expect(adapter.isConnected, isTrue);
    expect(transport.connectCount, 1);

    await adapter.testPrint();
    expect(transport.writeCount, 1);
    expect(transport.lastBytes, isNotEmpty);
    expect(transport.lastBytes!.first, 0x1B);

    await adapter.printReceipt(data);
    expect(transport.writeCount, 2);
    expect(transport.lastBytes, isNotEmpty);

    await adapter.disconnect();
    expect(adapter.isConnected, isFalse);
    expect(transport.disconnectCount, 1);
  });

  test('rejects a test print before the connection is open', () async {
    final adapter = EscPosPrinterAdapter(transport: FakePrinterTransport());
    await expectLater(
      adapter.testPrint(),
      throwsA(
        isA<PrinterException>().having(
          (error) => error.kind,
          'kind',
          PrinterFailureKind.notConnected,
        ),
      ),
    );
  });

  test('rejects transports without an adapter', () async {
    final adapter = EscPosPrinterAdapter(transport: FakePrinterTransport());
    await expectLater(
      adapter.connect(
        testPrinterConfig(transport: PrinterTransportType.network),
      ),
      throwsA(
        isA<PrinterException>().having(
          (error) => error.kind,
          'kind',
          PrinterFailureKind.unsupportedTransport,
        ),
      ),
    );
  });

  test('propagates a classified connection loss from the transport', () async {
    final transport = FakePrinterTransport();
    final adapter = EscPosPrinterAdapter(transport: transport);
    await adapter.connect(testPrinterConfig());
    transport.writeFailure = const PrinterException(
      PrinterFailureKind.connectionLost,
      'socket closed',
    );

    await expectLater(
      adapter.testPrint(),
      throwsA(
        isA<PrinterException>().having(
          (error) => error.kind,
          'kind',
          PrinterFailureKind.connectionLost,
        ),
      ),
    );
    expect(adapter.isConnected, isFalse);
  });
}
