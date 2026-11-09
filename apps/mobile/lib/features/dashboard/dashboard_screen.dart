import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../theme/app_theme.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final health = ref.watch(apiHealthProvider);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Cashier shell',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        const Text(
          'Android-first scaffold. Menu, stock and sale flows arrive in later Phase 1 tickets.',
        ),
        const SizedBox(height: 20),
        health.when(
          data: (status) => _StatusTile(
            icon: Icons.check_circle_outline,
            color: PosColors.success,
            label: 'API $status',
          ),
          loading: () => const _StatusTile(
            icon: Icons.sync,
            color: PosColors.muted,
            label: 'Checking API',
          ),
          error: (_, _) => const _StatusTile(
            icon: Icons.cloud_off,
            color: PosColors.danger,
            label: 'API unreachable',
          ),
        ),
        const SizedBox(height: 20),
        const Card(
          child: ListTile(
            leading: Icon(Icons.route_outlined),
            title: Text('Navigation ready'),
            subtitle: Text(
              'go_router, Riverpod, Dio, Drift and the generated Dart client are wired.',
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusTile extends StatelessWidget {
  const _StatusTile({
    required this.icon,
    required this.color,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(label),
        subtitle: const Text('GET /health'),
      ),
    );
  }
}
