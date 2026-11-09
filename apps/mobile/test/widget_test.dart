import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modern_pos_mobile/app.dart';
import 'package:modern_pos_mobile/features/auth/auth_controller.dart';
import 'package:modern_pos_mobile/features/cart/cart_controller.dart';
import 'package:modern_pos_mobile/features/catalog/catalog_controller.dart';
import 'package:modern_pos_mobile/core/providers.dart';

import 'support/fakes.dart';

void main() {
  testWidgets('shows the sign-in screen when there is no session', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(() => FakeAuthController(null)),
        ],
        child: const ModernPosApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Cashier sign in'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });

  testWidgets('renders the cashier shell for an authenticated session', (
    tester,
  ) async {
    final catalog = FakeCatalogRepository(
      testSnapshot(
        menus: [testMenu(id: 'tea', name: 'Tea', categoryId: 'drinks')],
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(
            () => FakeAuthController(testSession()),
          ),
          catalogRepositoryProvider.overrideWithValue(catalog),
          cartRepositoryProvider.overrideWithValue(InMemoryCartRepository()),
          apiHealthProvider.overrideWith((ref) async => 'ok'),
        ],
        child: const ModernPosApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Catalog'), findsWidgets);
    expect(find.text('Tea'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Cart'),
      ),
      findsOneWidget,
    );

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Status'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Cashier shell'), findsOneWidget);
  });
}
