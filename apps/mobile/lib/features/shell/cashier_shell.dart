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

  static const _titles = ['Catalog', 'Cart', 'Tables', 'Settings', 'Status'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartControllerProvider);
    final lines = cart.value?.lineCount ?? 0;
    final offlineActive =
        ref.watch(offlineSyncControllerProvider).value?.summary.active ?? 0;
    final session = ref.watch(authControllerProvider).value;

    return Scaffold(
      appBar: AppBar(
        bottom: session?.offline == true
            ? PreferredSize(
                preferredSize: const Size.fromHeight(56),
                child: _OfflineSessionBanner(session: session!),
              )
            : null,
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
            icon: Icon(Icons.table_restaurant_outlined),
            selectedIcon: Icon(Icons.table_restaurant),
            label: 'Tables',
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

class _OfflineSessionBanner extends ConsumerWidget {
  const _OfflineSessionBanner({required this.session});

  final AuthSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authorizedAt = session.authorizedAt;
    return Container(
      width: double.infinity,
      color: PosColors.warningSoft,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.cloud_off, size: 20, color: PosColors.warning),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Offline mode. Menu and queued sales are from this device'
              '${authorizedAt == null ? '' : ' (last authorized ${_clock(authorizedAt)})'}. '
              'Sales are captured locally; reconnect to sync.',
              style: const TextStyle(
                color: PosColors.warning,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
            onPressed: () =>
                ref.read(authControllerProvider.notifier).retryRefreshNow(),
            child: const Text('Reconnect'),
          ),
        ],
      ),
    );
  }

  String _clock(DateTime value) {
    final local = value.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
