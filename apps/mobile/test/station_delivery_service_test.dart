import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:modern_pos_api_client/api.dart';
import 'package:modern_pos_mobile/features/printing/kitchen_ticket.dart';
import 'package:modern_pos_mobile/features/printing/printer_adapter.dart';
import 'package:modern_pos_mobile/features/printing/printer_models.dart';
import 'package:modern_pos_mobile/features/printing/station_delivery_service.dart';
import 'package:modern_pos_mobile/features/printing/station_job_dispatch.dart';

import 'support/printer_fakes.dart';
import 'support/station_job_fakes.dart';

const _outlet = 'outlet-1';
const _kitchen = 'station-kitchen';
const _bar = 'station-bar';

StationDeliveryService _service(
  FakeStationJobGateway gateway,
  FakePrinterTransport transport,
) {
  return StationDeliveryService(
    gateway: gateway,
    adapter: EscPosPrinterAdapter(transport: transport),
    configStore: InMemoryPrinterConfigStore(testPrinterConfig()),
  );
}

FakeStationJobGateway _twoStationGateway() {
  return FakeStationJobGateway(
    stations: [
      testStation(id: _kitchen, name: 'Kitchen'),
      testStation(id: _bar, name: 'Bar', kind: StationKind.BAR),
    ],
    jobs: [
      testStationJob(
        id: 'job-food',
        stationId: _kitchen,
        stationName: 'Kitchen',
        itemName: 'Chicken Rice',
        variantName: 'Regular',
        quantity: 2,
        modifiers: [StationJobModifier(name: 'Spicy', quantity: 1)],
      ),
      testStationJob(
        id: 'job-drink',
        stationId: _bar,
        stationName: 'Bar',
        variantId: 'variant-2',
        itemName: 'Iced Coffee',
        variantName: 'Large',
      ),
    ],
  );
}

String _text(FakePrinterTransport transport) {
  final bytes = transport.lastBytes;
  if (bytes == null) {
    return '';
  }
  return String.fromCharCodes(bytes);
}

void main() {
  test('routes each station job to its own fake transport', () async {
    final gateway = _twoStationGateway();
    final kitchenTransport = FakePrinterTransport();
    final barTransport = FakePrinterTransport();

    final kitchenResults = await _service(
      gateway,
      kitchenTransport,
    ).deliverStation(_outlet, _kitchen);
    final barResults = await _service(
      gateway,
      barTransport,
    ).deliverStation(_outlet, _bar);

    expect(kitchenResults.single.outcome, StationDeliveryOutcome.sent);
    expect(barResults.single.outcome, StationDeliveryOutcome.sent);
    expect(kitchenTransport.writeCount, 1);
    expect(barTransport.writeCount, 1);
    expect(_text(kitchenTransport), contains('Chicken Rice'));
    expect(_text(kitchenTransport), contains('Spicy'));
    expect(_text(kitchenTransport), isNot(contains('Iced Coffee')));
    expect(_text(barTransport), contains('Iced Coffee'));
    expect(_text(barTransport), isNot(contains('Chicken Rice')));
    expect(gateway.saleWrites, 0);
    expect(gateway.stockWrites, 0);
  });

  test('amend and cancel tickets keep the stable reference and kind', () {
    final original = KitchenTicket(
      jobId: 'job-1',
      stationName: 'Kitchen',
      orderReference: 'SALE-ORDER-1',
      kind: KitchenTicketKind.original,
      itemName: 'Chicken Rice',
      variantName: 'Regular',
      quantity: 2,
      modifiers: const [],
    );
    final amend = KitchenTicket(
      jobId: 'job-2',
      stationName: 'Kitchen',
      orderReference: 'SALE-ORDER-1',
      kind: KitchenTicketKind.amend,
      itemName: 'Chicken Rice',
      variantName: 'Regular',
      quantity: 3,
      modifiers: const [],
    );
    final cancel = KitchenTicket(
      jobId: 'job-3',
      stationName: 'Kitchen',
      orderReference: 'SALE-ORDER-1',
      kind: KitchenTicketKind.cancel,
      itemName: 'Chicken Rice',
      variantName: 'Regular',
      quantity: 1,
      modifiers: const [],
    );

    String text(KitchenTicket ticket) => KitchenTicketDocument.build(
      ticket,
      32,
    ).map((line) => line.text).join('\n');

    expect(text(original), contains('ORIGINAL'));
    expect(text(amend), contains('AMENDMENT'));
    expect(text(cancel), contains('CANCELLATION'));
    expect(text(amend), contains('Order: SALE-ORDER-1'));
    expect(text(cancel), contains('Order: SALE-ORDER-1'));
    expect(text(amend), contains('3 x Chicken Rice'));
    expect(text(cancel), contains('1 x Chicken Rice'));
    expect(text(cancel), contains('ITEM CANCELLED'));
  });

  test('mid-write disconnect ends UNKNOWN and is never auto-resent', () async {
    final gateway = FakeStationJobGateway(
      stations: [testStation(id: _kitchen, name: 'Kitchen')],
      jobs: [testStationJob(id: 'job-food', stationId: _kitchen)],
    );
    final transport = FakePrinterTransport()
      ..writeFailure = const PrinterException(
        PrinterFailureKind.connectionLost,
        'Printer disconnected mid-write',
      );
    final service = _service(gateway, transport);

    final first = await service.deliverStation(_outlet, _kitchen);
    expect(first.single.outcome, StationDeliveryOutcome.uncertain);
    expect(gateway.jobs.single.state, StationJobStateEnum.UNKNOWN);
    expect(transport.writeAttempts, 1);
    expect(transport.writeCount, 0);

    final second = await service.deliverPending(
      _outlet,
      stationIds: [_kitchen],
    );
    expect(second, isEmpty);
    expect(transport.writeAttempts, 1);
    expect(gateway.jobs.single.state, StationJobStateEnum.UNKNOWN);
  });

  test(
    'restart recovery marks stale SENDING as UNKNOWN without sending',
    () async {
      final gateway = FakeStationJobGateway(
        stations: [testStation(id: _kitchen, name: 'Kitchen')],
        jobs: [
          testStationJob(
            id: 'job-food',
            stationId: _kitchen,
            state: StationJobStateEnum.SENDING,
            attempts: 1,
          ),
        ],
      );
      final transport = FakePrinterTransport();
      final service = _service(gateway, transport);

      final recovered = await service.recoverInterrupted(
        _outlet,
        stationIds: [_kitchen],
      );

      expect(recovered.single.outcome, StationDeliveryOutcome.uncertain);
      expect(gateway.jobs.single.state, StationJobStateEnum.UNKNOWN);
      expect(transport.writeAttempts, 0);
    },
  );

  test('two concurrent consumers cannot both claim and send one job', () async {
    final gateway = FakeStationJobGateway(
      stations: [testStation(id: _kitchen, name: 'Kitchen')],
      jobs: [testStationJob(id: 'job-food', stationId: _kitchen)],
    );
    gateway.claimGate = Completer<void>();
    final firstTransport = FakePrinterTransport();
    final secondTransport = FakePrinterTransport();
    final first = _service(gateway, firstTransport);
    final second = _service(gateway, secondTransport);

    final firstRun = first.deliverStation(_outlet, _kitchen);
    final secondRun = second.deliverStation(_outlet, _kitchen);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    gateway.claimGate!.complete();
    final results = await Future.wait([firstRun, secondRun]);

    final outcomes = results.expand((rows) => rows).map((row) => row.outcome);
    expect(outcomes, contains(StationDeliveryOutcome.sent));
    expect(outcomes, contains(StationDeliveryOutcome.conflict));
    expect(firstTransport.writeAttempts + secondTransport.writeAttempts, 1);
    expect(gateway.jobs.single.state, StationJobStateEnum.SENT);
    expect(gateway.claimCalls, 2);
    expect(gateway.saleWrites, 0);
    expect(gateway.stockWrites, 0);
  });

  test(
    'explicit COPY sends a new copy and leaves the unknown original',
    () async {
      final gateway = FakeStationJobGateway(
        stations: [testStation(id: _kitchen, name: 'Kitchen')],
        jobs: [
          testStationJob(
            id: 'job-food',
            stationId: _kitchen,
            state: StationJobStateEnum.UNKNOWN,
            attempts: 1,
            lastError: 'Write failed after SENDING; delivery unknown',
          ),
        ],
      );
      final transport = FakePrinterTransport();
      final service = _service(gateway, transport);

      final result = await service.copyJob(
        outletId: _outlet,
        jobId: 'job-food',
      );

      expect(result.outcome, StationDeliveryOutcome.sent);
      expect(gateway.reprintCalls, 1);
      final original = gateway.jobs.firstWhere((job) => job.id == 'job-food');
      final copy = gateway.jobs.firstWhere((job) => job.copy);
      expect(original.state, StationJobStateEnum.UNKNOWN);
      expect(copy.state, StationJobStateEnum.SENT);
      expect(copy.reprintOfId, 'job-food');
      expect(copy.orderReference, original.orderReference);
      expect(transport.writeAttempts, 1);
      expect(_text(transport), contains('COPY - NOT AN ORIGINAL'));
      expect(gateway.saleWrites, 0);
      expect(gateway.stockWrites, 0);
    },
  );

  test(
    'dispatch keeps the app order lines and kind on the server call',
    () async {
      final gateway = FakeStationJobGateway();
      final order = Order(
        id: 'order-1',
        deviceId: 'device-1',
        state: OrderStateEnum.DRAFT,
        version: 1,
        lines: [
          OrderWriteLinesInner(variantId: 'variant-1', quantity: 2),
          OrderWriteLinesInner(variantId: 'variant-2', quantity: 1),
        ],
      );

      await dispatchOrderStationJobs(
        gateway: gateway,
        outletId: _outlet,
        idempotencyKey: '00000000-0000-4000-8000-000000000001',
        order: order,
        kind: StationJobKind.CANCEL,
      );

      expect(gateway.dispatched, hasLength(1));
      final call = gateway.dispatched.single;
      expect(call['orderId'], 'order-1');
      expect(call['kind'], 'CANCEL');
      final lines = call['lines']! as List<Object?>;
      expect(lines, hasLength(2));
      expect(gateway.saleWrites, 0);
      expect(gateway.stockWrites, 0);
    },
  );
}
