import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';
import '../auth/auth_controller.dart';
import '../cart/cart_controller.dart';
import '../offline/offline_sync_controller.dart';

/// Cashier shell: catalog and cart are first-class destinations. The existing
/// dashboard and settings screens stay reachable and keep working.
class CashierShell extends ConsumerWidget {
  const CashierShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  static const _titles = ['Catalog', 'Cart', 'Settings', 'Status'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartControllerProvider);
    final lines = cart.value?.lineCount ?? 0;
    final offlineActive =
        ref.watch(offlineSyncControllerProvider).value?.summary.active ?? 0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: PosColors.ink,
        foregroundColor: PosColors.surface,
        title: Text(_titles[navigationShell.currentIndex]),
        actions: [
          IconButton(
            tooltip: 'Offline sales and sync',
            onPressed: () => context.push('/settings/offline-sync'),
            icon: Badge.count(
              count: offlineActive,
              isLabelVisible: offlineActive > 0,
              child: const Icon(Icons.cloud_sync_outlined),
            ),
          ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Catalog',
          ),
          NavigationDestination(
            icon: Badge.count(
              count: lines,
              isLabelVisible: lines > 0,
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            selectedIcon: Badge.count(
              count: lines,
              isLabelVisible: lines > 0,
              child: const Icon(Icons.shopping_cart),
            ),
            label: 'Cart',
          ),
          const NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune),
            label: 'Settings',
          ),
          const NavigationDestination(
            icon: Icon(Icons.info_outline),
            selectedIcon: Icon(Icons.info),
            label: 'Status',
          ),
        ],
      ),
    );
  }
}
