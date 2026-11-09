import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modern_pos_mobile/features/printing/printer_controller.dart';
import 'package:modern_pos_mobile/features/printing/printer_models.dart';
import 'package:modern_pos_mobile/features/printing/printer_permissions.dart';
import 'package:modern_pos_mobile/features/printing/printer_screen.dart';
import 'package:modern_pos_mobile/theme/app_theme.dart';

import 'support/printer_fakes.dart';

Future<void> _reveal(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    220,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('guides first-run setup, then connects and test prints', (
    tester,
  ) async {
    final transport = FakePrinterTransport();
    final permissions = FakePrinterPermissions();
    final store = InMemoryPrinterConfigStore();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          printerTransportProvider.overrideWithValue(transport),
          printerPermissionServiceProvider.overrideWithValue(permissions),
          printerConfigStoreProvider.overrideWithValue(store),
        ],
        child: MaterialApp(theme: buildAppTheme(), home: const PrinterScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No printer configured yet'), findsOneWidget);
    expect(find.textContaining('not verified on this project'), findsWidgets);

    await tester.enterText(
      find.byType(TextFormField).last,
      'AA:BB:CC:DD:EE:FF',
    );
    await _reveal(tester, find.text('Save configuration'));
    await tester.tap(find.text('Save configuration'));
    await tester.pumpAndSettle();

    expect(store.config?.connection.address, 'AA:BB:CC:DD:EE:FF');
    await _reveal(tester, find.text('Disconnected'));
    expect(find.text('Disconnected'), findsOneWidget);

    await _reveal(tester, find.text('Grant Bluetooth permission'));
    await tester.tap(find.text('Grant Bluetooth permission'));
    await tester.pumpAndSettle();
    expect(permissions.requestCount, 1);
    await _reveal(tester, find.text('Bluetooth permission granted'));
    expect(find.text('Bluetooth permission granted'), findsOneWidget);

    await _reveal(tester, find.text('Connect'));
    await tester.tap(find.text('Connect'));
    await tester.pumpAndSettle();
    expect(transport.connected, isTrue);
    await _reveal(tester, find.text('Connected'));
    expect(find.text('Connected'), findsOneWidget);

    await _reveal(tester, find.text('Test print'));
    await tester.tap(find.text('Test print'));
    await tester.pumpAndSettle();
    expect(transport.writeCount, 1);
    await _reveal(tester, find.textContaining('Test print bytes sent'));
    expect(find.textContaining('Test print bytes sent'), findsOneWidget);
  });

  testWidgets('shows an explicit warning for an unsupported transport', (
    tester,
  ) async {
    final transport = FakePrinterTransport();
    final permissions = FakePrinterPermissions(
      status: PrinterPermissionStatus.granted,
    );
    final store = InMemoryPrinterConfigStore(
      testPrinterConfig(transport: PrinterTransportType.network),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          printerTransportProvider.overrideWithValue(transport),
          printerPermissionServiceProvider.overrideWithValue(permissions),
          printerConfigStoreProvider.overrideWithValue(store),
        ],
        child: MaterialApp(theme: buildAppTheme(), home: const PrinterScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await _reveal(
      tester,
      find.textContaining('is not verified on this project'),
    );
    expect(
      find.textContaining('is not verified on this project'),
      findsWidgets,
    );
    expect(find.text('Connect'), findsNothing);
    expect(find.text('Test print'), findsNothing);
  });
}
