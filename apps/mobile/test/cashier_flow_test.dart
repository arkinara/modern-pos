import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modern_pos_mobile/app.dart';
import 'package:modern_pos_mobile/features/auth/auth_controller.dart';
import 'package:modern_pos_mobile/features/cart/cart_controller.dart';
import 'package:modern_pos_mobile/features/catalog/catalog_controller.dart';
import 'package:modern_pos_mobile/features/catalog/catalog_models.dart';
import 'package:modern_pos_mobile/features/checkout/checkout_repository.dart';

import 'support/checkout_fakes.dart';
import 'support/fakes.dart';

void main() {
  late FakeCatalogRepository catalog;
  late InMemoryCartRepository cartRepository;
  late FakeAuthController auth;
  late ProviderContainer container;

  CatalogSnapshot fixture() {
    final drinks = testCategory(id: 'drinks', name: 'Drinks');
    final food = testCategory(id: 'food', name: 'Food');
    return testSnapshot(
      categories: [drinks, food],
      menus: [
        testMenu(
          id: 'latte',
          name: 'Latte',
          categoryId: 'drinks',
          description: 'Espresso with milk',
          variants: [
            testVariant(id: 'latte-small', name: 'Small', priceMinor: 25000),
            testVariant(id: 'latte-large', name: 'Large', priceMinor: 30000),
          ],
        ),
        testMenu(
          id: 'tea',
          name: 'Tea',
          categoryId: 'drinks',
          variants: [testVariant(id: 'tea-default', priceMinor: 18000)],
        ),
        testMenu(
          id: 'espresso',
          name: 'Espresso',
          categoryId: 'drinks',
          variants: [
            testVariant(
              id: 'espresso-default',
              priceMinor: 20000,
              availableUnits: 0,
            ),
          ],
        ),
        testMenu(
          id: 'cake',
          name: 'Cake',
          categoryId: 'food',
          archived: true,
          variants: [testVariant(id: 'cake-default', priceMinor: 15000)],
        ),
      ],
    );
  }

  Future<void> pumpApp(WidgetTester tester) async {
    catalog = FakeCatalogRepository(fixture());
    cartRepository = InMemoryCartRepository();
    auth = FakeAuthController(testSession());
    container = ProviderContainer(
      overrides: [
        authControllerProvider.overrideWith(() => auth),
        catalogRepositoryProvider.overrideWithValue(catalog),
        cartRepositoryProvider.overrideWithValue(cartRepository),
        checkoutRepositoryProvider.overrideWithValue(
          InMemoryCheckoutRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const ModernPosApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> goTo(WidgetTester tester, String label) async {
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text(label),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'browses categories, searches variants and adds a single variant',
    (tester) async {
      await pumpApp(tester);

      expect(find.text('Latte'), findsOneWidget);
      expect(find.text('Tea'), findsOneWidget);
      expect(find.text('Rp18.000'), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byType(FilterChip),
          matching: find.text('Food'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Cake'), findsOneWidget);
      expect(find.text('Tea'), findsNothing);

      await tester.tap(
        find.descendant(
          of: find.byType(FilterChip),
          matching: find.text('All'),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Large');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
      expect(find.text('Latte'), findsOneWidget);
      expect(find.text('Tea'), findsNothing);

      await tester.enterText(find.byType(TextField), '');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tea'));
      await tester.pumpAndSettle();
      expect(cartRepository.length, 1);

      await goTo(tester, 'Cart');
      expect(find.text('Tea'), findsOneWidget);
      expect(find.text('Rp18.000'), findsWidgets);
      expect(
        find.textContaining('server quote at checkout is authoritative'),
        findsOneWidget,
      );
    },
  );

  testWidgets('debounced search matches item names', (tester) async {
    await pumpApp(tester);

    await tester.enterText(find.byType(TextField), 'tea');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    expect(find.text('Tea'), findsOneWidget);
    expect(find.text('Latte'), findsNothing);
    expect(find.text('Espresso'), findsNothing);
  });

  testWidgets('disabled catalog items render disabled and reject taps', (
    tester,
  ) async {
    await pumpApp(tester);

    catalog.snapshot = testSnapshot(
      categories: [testCategory(id: 'drinks', name: 'Drinks')],
      menus: [
        testMenu(
          id: 'decaf',
          name: 'Decaf',
          categoryId: 'drinks',
          variants: [
            testVariant(
              id: 'decaf-default',
              name: 'Cup',
              priceMinor: 22000,
              enabled: false,
            ),
          ],
        ),
      ],
    );
    await container.read(catalogControllerProvider.notifier).refresh();
    await tester.pumpAndSettle();

    expect(find.text('Decaf'), findsOneWidget);
    expect(find.text('Unavailable'), findsOneWidget);

    final card = find.ancestor(
      of: find.text('Decaf'),
      matching: find.byType(Card),
    );
    expect(card, findsOneWidget);
    final opacity = tester.widget<Opacity>(
      find.descendant(of: card, matching: find.byType(Opacity)),
    );
    expect(opacity.opacity, lessThan(1));
    expect(
      find.descendant(of: card, matching: find.byIcon(Icons.block)),
      findsOneWidget,
    );

    await tester.ensureVisible(find.text('Decaf'));
    await tester.tap(find.text('Decaf'));
    await tester.pumpAndSettle();
    expect(cartRepository.length, 0);
  });

  testWidgets('multi-variant item requires an explicit variant choice', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('Latte'));
    await tester.pumpAndSettle();
    expect(find.text('Choose a variant to add.'), findsOneWidget);
    expect(find.text('Small'), findsOneWidget);
    expect(find.text('Large'), findsOneWidget);

    await tester.tap(find.text('Large'));
    await tester.pumpAndSettle();
    expect(cartRepository.length, 1);

    await goTo(tester, 'Cart');
    expect(find.text('Large'), findsOneWidget);
    expect(find.text('Rp30.000'), findsWidgets);
  });

  testWidgets('unavailable and archived items stay visible but disabled', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(
      find.descendant(of: find.byType(FilterChip), matching: find.text('Food')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Archived'), findsOneWidget);

    await tester.tap(find.text('Cake'));
    await tester.pumpAndSettle();
    expect(cartRepository.length, 0);

    await tester.tap(
      find.descendant(of: find.byType(FilterChip), matching: find.text('All')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Out of stock'), findsOneWidget);

    await tester.ensureVisible(find.text('Espresso'));
    await tester.tap(find.text('Espresso'));
    await tester.pumpAndSettle();
    expect(cartRepository.length, 0);

    await goTo(tester, 'Cart');
    expect(find.text('Cart is empty'), findsOneWidget);
  });

  testWidgets('search no matches and empty catalog use empty states', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.enterText(find.byType(TextField), 'no such item');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    expect(find.text('No matching items'), findsOneWidget);
    expect(find.text('Could not load menu'), findsNothing);

    catalog.snapshot = testSnapshot(categories: const [], menus: const []);
    await container.read(catalogControllerProvider.notifier).refresh();
    await tester.pumpAndSettle();
    expect(find.text('No menu items yet'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Retry'), findsOneWidget);
  });

  testWidgets('offline catalog shows retry and recovers', (tester) async {
    await pumpApp(tester);

    catalog.failure = DioException.connectionError(
      requestOptions: RequestOptions(path: '/v1/outlets/outlet-1/menu'),
      reason: 'offline',
    );
    await container.read(catalogControllerProvider.notifier).refresh();
    await tester.pumpAndSettle();
    expect(find.text('You are offline'), findsOneWidget);

    catalog.failure = null;
    await tester.tap(find.widgetWithText(FilledButton, 'Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Tea'), findsOneWidget);
  });

  testWidgets('quantity changes, remove and clear keep totals clear', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('Tea'));
    await tester.pumpAndSettle();

    await goTo(tester, 'Cart');
    expect(find.text('Rp18.000'), findsWidgets);

    await tester.tap(find.byTooltip('Increase quantity of Tea'));
    await tester.pumpAndSettle();
    expect(find.text('Rp36.000'), findsWidgets);

    await tester.tap(find.byTooltip('Decrease quantity of Tea'));
    await tester.pumpAndSettle();
    expect(find.text('Rp18.000'), findsWidgets);

    await tester.tap(find.byTooltip('Decrease quantity of Tea'));
    await tester.pumpAndSettle();
    expect(cartRepository.length, 1);
    expect(find.text('Rp18.000'), findsWidgets);

    await tester.tap(find.text('Clear cart'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keep cart'));
    await tester.pumpAndSettle();
    expect(cartRepository.length, 1);

    await tester.tap(find.text('Clear cart'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Clear cart'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Cart is empty'), findsOneWidget);
    expect(cartRepository.length, 0);
  });

  testWidgets('refresh mid-cart and 401 expiry preserve unsent lines', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('Tea'));
    await tester.pumpAndSettle();
    expect(cartRepository.length, 1);

    catalog.snapshot = testSnapshot(
      categories: [testCategory(id: 'drinks', name: 'Drinks')],
      menus: [
        testMenu(
          id: 'latte',
          name: 'Latte',
          categoryId: 'drinks',
          variants: [testVariant(id: 'latte-default', priceMinor: 25000)],
        ),
      ],
    );
    await container.read(catalogControllerProvider.notifier).refresh();
    await tester.pumpAndSettle();

    await goTo(tester, 'Cart');
    expect(find.text('Tea'), findsOneWidget);
    expect(find.textContaining('Item is no longer available'), findsOneWidget);

    auth.expire();
    await tester.pumpAndSettle();
    expect(find.text('Cashier sign in'), findsOneWidget);
    expect(cartRepository.length, 1);

    auth.restore(testSession());
    await tester.pumpAndSettle();
    await goTo(tester, 'Cart');
    expect(find.text('Tea'), findsOneWidget);
    expect(find.textContaining('Item is no longer available'), findsOneWidget);
  });

  testWidgets('catalog fits 320px without overflow', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpApp(tester);

    expect(find.text('Latte'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('supports 200% text at 320px without overflow', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await pumpApp(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('Search menu'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Tea'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('Tea'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tea'));
    await tester.pumpAndSettle();
    await goTo(tester, 'Cart');
    expect(find.text('Tea'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('cart line availability stays advisory and never drops the line', () {
    final snapshot = fixture();
    expect(
      cartLineUnavailableReason(
        snapshot,
        menuId: 'tea',
        variantId: 'tea-default',
      ),
      isNull,
    );
    expect(
      cartLineUnavailableReason(
        snapshot,
        menuId: 'missing',
        variantId: 'missing-default',
      ),
      'Item is no longer available',
    );
    expect(
      cartLineUnavailableReason(
        snapshot,
        menuId: 'espresso',
        variantId: 'espresso-default',
      ),
      'Out of stock',
    );
  });
}
