import 'package:go_router/go_router.dart';

import '../features/cart/cart_screen.dart';
import '../features/checkout/checkout_screen.dart';
import '../features/catalog/catalog_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/printing/print_queue_screen.dart';
import '../features/printing/printer_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/shell/cashier_shell.dart';

GoRouter createAppRouter() => GoRouter(
  initialLocation: '/catalog',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          CashierShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/catalog',
              builder: (context, state) => const CatalogScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/cart',
              builder: (context, state) => const CartScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
              routes: [
                GoRoute(
                  path: 'printer',
                  builder: (context, state) => const PrinterScreen(),
                ),
                GoRoute(
                  path: 'print-queue',
                  builder: (context, state) => const PrintQueueScreen(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/checkout',
      builder: (context, state) => const CheckoutScreen(),
    ),
  ],
);
