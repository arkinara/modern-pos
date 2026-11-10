import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modern_pos_mobile/features/printing/print_job_models.dart';
import 'package:modern_pos_mobile/features/printing/print_queue_controller.dart';
import 'package:modern_pos_mobile/features/printing/print_queue_screen.dart';
import 'package:modern_pos_mobile/theme/app_theme.dart';

import 'support/printer_fakes.dart';

class _FakeQueueController extends PrintQueueController {
  _FakeQueueController(this.jobs, {this.failure});

  final List<PrintJob> jobs;
  final Object? failure;

  @override
  Future<List<PrintJob>> build() async {
    final error = failure;
    if (error != null) {
      throw error;
    }
    return jobs;
  }

  @override
  Future<void> resume() async {}
}

Future<void> _pump(
  WidgetTester tester,
  List<PrintJob> jobs, {
  Object? failure,
  Size size = const Size(360, 900),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        printQueueControllerProvider.overrideWith(
          () => _FakeQueueController(jobs, failure: failure),
        ),
      ],
      child: MaterialApp(
        theme: buildAppTheme(),
        home: const PrintQueueScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('empty queue explains durable jobs without fake success', (
    tester,
  ) async {
    await _pump(tester, const []);

    expect(find.text('No print jobs yet'), findsOneWidget);
    expect(find.textContaining('durable receipt job'), findsOneWidget);
  });

  testWidgets('shows queued, sent, failed and uncertain states honestly', (
    tester,
  ) async {
    final jobs = [
      testPrintJob(id: 'q', state: PrintJobState.queued),
      testPrintJob(id: 's', state: PrintJobState.sent),
      testPrintJob(id: 'f', state: PrintJobState.failed, attempts: 1),
      testPrintJob(id: 'u', state: PrintJobState.uncertain, copy: true),
    ];

    await _pump(tester, jobs, size: const Size(320, 2000));

    expect(find.text('Queued'), findsOneWidget);
    expect(find.text('Sent'), findsOneWidget);
    expect(find.text('Failed'), findsOneWidget);
    expect(find.text('Delivery unknown'), findsOneWidget);
    expect(find.text('COPY'), findsOneWidget);
    expect(
      find.textContaining('Paper delivery is not verified'),
      findsOneWidget,
    );
    expect(find.textContaining('Not retried automatically'), findsOneWidget);
    expect(find.text('Retry'), findsWidgets);
    expect(find.text('Reprint COPY'), findsWidgets);

    expect(tester.takeException(), isNull);
  });

  testWidgets('queue load failure offers a retry instead of an empty state', (
    tester,
  ) async {
    await _pump(tester, const [], failure: StateError('queue unavailable'));

    expect(find.text('Could not load the print queue'), findsOneWidget);
    expect(find.textContaining('queue unavailable'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Retry'), findsOneWidget);
  });
}
