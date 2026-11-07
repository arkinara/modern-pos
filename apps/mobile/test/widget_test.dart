import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modern_pos_mobile/app.dart';
import 'package:modern_pos_mobile/core/providers.dart';

void main() {
  testWidgets('renders the cashier shell', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [apiHealthProvider.overrideWith((ref) async => 'ok')],
        child: const ModernPosApp(),
      ),
    );

    await tester.pump();

    expect(find.text('Modern POS'), findsOneWidget);
    expect(find.text('Cashier shell'), findsOneWidget);
  });
}
