import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modern_pos_api_client/api.dart';

import '../../core/providers.dart';
import '../../theme/app_theme.dart';
import '../payments/online_payments_controller.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final health = ref.watch(apiHealthProvider);
    final payments = ref.watch(onlinePaymentsControllerProvider);

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
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Online payments',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            IconButton(
              tooltip: 'Refresh online payments',
              onPressed: () =>
                  ref.read(onlinePaymentsControllerProvider.notifier).load(),
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        const SizedBox(height: 8),
        payments.when(
          loading: () => const Card(
            child: ListTile(
              leading: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              title: Text('Loading online payments'),
              subtitle: Text('Resolving server-side provider state'),
            ),
          ),
          error: (error, _) => Card(
            color: PosColors.dangerSoft,
            child: ListTile(
              leading: const Icon(Icons.cloud_off, color: PosColors.danger),
              title: const Text('Provider unreachable'),
              subtitle: const Text(
                'The sale and payment records are unchanged. Retry when the connection returns.',
              ),
              trailing: TextButton(
                onPressed: () =>
                    ref.read(onlinePaymentsControllerProvider.notifier).load(),
                child: const Text('Retry'),
              ),
            ),
          ),
          data: (items) {
            if (items.isEmpty) {
              return const Card(
                child: ListTile(
                  leading: Icon(
                    Icons.payments_outlined,
                    color: PosColors.muted,
                  ),
                  title: Text('No online payments yet'),
                  subtitle: Text(
                    'Online payment status appears here after checkout.',
                  ),
                ),
              );
            }
            return Column(
              children: [
                for (final payment in items)
                  _PaymentTile(
                    payment: payment,
                    onRefresh: () => ref
                        .read(onlinePaymentsControllerProvider.notifier)
                        .refreshSale(payment.saleId),
                  ),
              ],
            );
          },
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

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({required this.payment, required this.onRefresh});

  final OnlinePaymentListItem payment;
  final VoidCallback onRefresh;

  Color get _statusColor {
    return switch (payment.status) {
      OnlinePaymentListItemStatusEnum.SUCCEEDED => PosColors.success,
      OnlinePaymentListItemStatusEnum.FAILED => PosColors.danger,
      OnlinePaymentListItemStatusEnum.PENDING => PosColors.warning,
      _ => PosColors.muted,
    };
  }

  String get _statusLabel {
    return switch (payment.status) {
      OnlinePaymentListItemStatusEnum.SUCCEEDED => 'Succeeded',
      OnlinePaymentListItemStatusEnum.FAILED => 'Failed',
      OnlinePaymentListItemStatusEnum.PENDING => 'Pending',
      OnlinePaymentListItemStatusEnum.REFUNDED => 'Refunded',
      OnlinePaymentListItemStatusEnum.PARTIALLY_REFUNDED =>
        'Partially refunded',
    };
  }

  @override
  Widget build(BuildContext context) {
    final actionable =
        payment.status == OnlinePaymentListItemStatusEnum.PENDING ||
        payment.status == OnlinePaymentListItemStatusEnum.FAILED;
    return Card(
      child: ListTile(
        leading: Icon(Icons.qr_code_2, color: _statusColor),
        title: Text(payment.saleReference),
        subtitle: Text(
          '$_statusLabel - ${payment.amountMinor} ${payment.currency}',
          style: TextStyle(color: _statusColor),
        ),
        trailing: actionable
            ? IconButton(
                tooltip:
                    payment.status == OnlinePaymentListItemStatusEnum.FAILED
                    ? 'Retry online payment'
                    : 'Refresh payment status',
                onPressed: onRefresh,
                icon: Icon(
                  payment.status == OnlinePaymentListItemStatusEnum.FAILED
                      ? Icons.replay
                      : Icons.refresh,
                ),
              )
            : null,
      ),
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
