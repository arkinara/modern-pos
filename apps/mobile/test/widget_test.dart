import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modern_pos_api_client/api.dart';
import 'package:modern_pos_mobile/app.dart';
import 'package:modern_pos_mobile/features/auth/auth_controller.dart';
import 'package:modern_pos_mobile/features/cart/cart_controller.dart';
import 'package:modern_pos_mobile/features/catalog/catalog_controller.dart';
import 'package:modern_pos_mobile/core/providers.dart';
import 'package:modern_pos_mobile/features/checkout/checkout_repository.dart';
import 'package:modern_pos_mobile/features/payments/payments_gateway.dart';

import 'support/checkout_fakes.dart';
import 'support/payment_fakes.dart';
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
          checkoutRepositoryProvider.overrideWithValue(
            InMemoryCheckoutRepository(),
          ),
          apiHealthProvider.overrideWith((ref) async => 'ok'),
          paymentsGatewayProvider.overrideWithValue(
            FakePaymentsGateway(
              payments: [
                testOnlinePayment(
                  status: OnlinePaymentListItemStatusEnum.PENDING,
                ),
              ],
            ),
          ),
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
    expect(find.text('Online payments'), findsOneWidget);
    expect(find.text('SALE-ONLINE-1'), findsOneWidget);
    expect(find.text('Pending - 35000 IDR'), findsOneWidget);
  });

  testWidgets('refreshing an online payment resolves the server state', (
    tester,
  ) async {
    final gateway = FakePaymentsGateway(
      payments: [
        testOnlinePayment(status: OnlinePaymentListItemStatusEnum.PENDING),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(
            () => FakeAuthController(testSession()),
          ),
          catalogRepositoryProvider.overrideWithValue(
            FakeCatalogRepository(testSnapshot()),
          ),
          cartRepositoryProvider.overrideWithValue(InMemoryCartRepository()),
          checkoutRepositoryProvider.overrideWithValue(
            InMemoryCheckoutRepository(),
          ),
          apiHealthProvider.overrideWith((ref) async => 'ok'),
          paymentsGatewayProvider.overrideWithValue(gateway),
        ],
        child: const ModernPosApp(),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Status'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Refresh payment status'));
    await tester.pumpAndSettle();

    expect(gateway.refreshCalls, 1);
    expect(find.text('Succeeded - 35000 IDR'), findsOneWidget);
  });
}
