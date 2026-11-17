import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modern_pos_mobile/core/database/app_database.dart';
import 'package:modern_pos_mobile/features/printing/print_queue_repository.dart';
import 'package:modern_pos_mobile/features/printing/printer_models.dart';

import 'support/printer_fakes.dart';

void main() {
  test(
    'automatic cutter defaults to off for new and legacy configurations',
    () {
      final config = testPrinterConfig();
      expect(config.automaticCutter, isFalse);
      final legacy = config.toJson()..remove('automaticCutter');
      expect(PrinterConfig.fromJson(legacy)!.automaticCutter, isFalse);
    },
  );

  for (final enabled in [false, true]) {
    test('persists automatic cutter set to $enabled', () {
      final config = testPrinterConfig().copyWith(automaticCutter: enabled);
      final restored = PrinterConfig.fromJson(config.toJson())!;
      expect(restored.automaticCutter, enabled);
      expect(restored.copyWith().automaticCutter, enabled);
      expect(
        restored.copyWith(automaticCutter: !enabled).automaticCutter,
        !enabled,
      );
    });

    test('queued receipt retains automatic cutter set to $enabled', () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = DriftPrintQueueRepository(database);
      final job = testPrintJob().copyWith(
        printerConfig: testPrinterConfig().copyWith(automaticCutter: enabled),
      );
      await repository.save(job);
      final restored = await repository.byId(job.id);
      expect(restored!.printerConfig!.automaticCutter, enabled);
    });
  }
}
