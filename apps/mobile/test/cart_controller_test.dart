import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modern_pos_mobile/core/database/app_database.dart';
import 'package:modern_pos_mobile/core/providers.dart';
import 'package:modern_pos_mobile/features/auth/auth_controller.dart';
import 'package:modern_pos_mobile/features/cart/cart_controller.dart';
import 'package:modern_pos_mobile/features/cart/cart_repository.dart';
import 'package:modern_pos_mobile/features/cart/cart_line.dart';

import 'support/fakes.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  ProviderContainer createContainer({
    CartRepository? cartRepository,
    FakeAuthController? auth,
  }) {
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        authControllerProvider.overrideWith(
          () => auth ?? FakeAuthController(testSession()),
        ),
        if (cartRepository != null)
          cartRepositoryProvider.overrideWithValue(cartRepository),
      ],
    );
    addTearDown(container.dispose);
    container.listen(cartControllerProvider, (_, _) {}, fireImmediately: true);
    return container;
  }

  test(
    'add, change quantity, remove and clear use integer minor units',
    () async {
      final container = createContainer();
      final controller = container.read(cartControllerProvider.notifier);
      final menu = testMenu(id: 'tea', name: 'Tea', categoryId: 'drinks');
      final variant = menu.variants.first;

      await controller.add(
        menu: menu,
        variant: variant,
        currency: 'IDR',
        currencyExponent: 0,
      );
      await controller.add(
        menu: menu,
        variant: variant,
        currency: 'IDR',
        currencyExponent: 0,
      );

      var state = container.read(cartControllerProvider).value!;
      expect(state.lineCount, 1);
      expect(state.lines.single.quantity, 2);
      expect(state.lines.single.subtotalMinor, 20000);
      expect(state.totalMinor, 20000);
      expect(state.lines.single.money.format(state.totalMinor), 'Rp20.000');

      await controller.decrement('tea', variant.id);
      state = container.read(cartControllerProvider).value!;
      expect(state.lines.single.quantity, 1);

      await controller.decrement('tea', variant.id);
      state = container.read(cartControllerProvider).value!;
      expect(
        state.lines.single.quantity,
        1,
        reason: 'quantity never reaches 0',
      );

      await controller.remove('tea', variant.id);
      expect(container.read(cartControllerProvider).value!.isEmpty, isTrue);

      await controller.add(
        menu: menu,
        variant: variant,
        currency: 'IDR',
        currencyExponent: 0,
      );
      await controller.clear();
      expect(container.read(cartControllerProvider).value!.isEmpty, isTrue);
      expect(await database.select(database.cartEntries).get(), isEmpty);
    },
  );

  test('cart persists across rebuild and a 401 session expiry', () async {
    final auth = FakeAuthController(testSession());
    final container = createContainer(auth: auth);
    await container.read(authControllerProvider.future);
    final menu = testMenu(id: 'tea', name: 'Tea', categoryId: 'drinks');

    await container
        .read(cartControllerProvider.notifier)
        .add(
          menu: menu,
          variant: menu.variants.first,
          currency: 'IDR',
          currencyExponent: 0,
        );
    expect(container.read(cartControllerProvider).value!.lineCount, 1);

    (container.read(authControllerProvider.notifier) as FakeAuthController)
        .expire();
    await Future<void>.delayed(Duration.zero);

    final afterExpiry = await container.read(cartControllerProvider.future);
    expect(afterExpiry.lineCount, 1);
    expect(afterExpiry.lines.single.itemName, 'Tea');

    final restarted = createContainer();
    final restored = await restarted.read(cartControllerProvider.future);
    expect(restored.lineCount, 1);
    expect(restored.lines.single.variantName, 'Default');
  });

  test('huge quantity is clamped to a sane maximum', () async {
    final repository = InMemoryCartRepository();
    final container = createContainer(cartRepository: repository);
    final controller = container.read(cartControllerProvider.notifier);
    final menu = testMenu(id: 'rice', name: 'Rice', categoryId: 'food');

    await controller.add(
      menu: menu,
      variant: menu.variants.first,
      currency: 'IDR',
      currencyExponent: 0,
    );
    for (var index = 1; index < CartLine.maxQuantity + 20; index++) {
      await controller.increment('rice', menu.variants.first.id);
    }

    final state = container.read(cartControllerProvider).value!;
    expect(state.lines.single.quantity, CartLine.maxQuantity);
    expect(state.totalMinor, 10000 * CartLine.maxQuantity);
  });
}
