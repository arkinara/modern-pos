import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatting/money.dart';
import '../../theme/app_theme.dart';
import '../checkout/checkout_models.dart';
import 'offline_sale_models.dart';
import 'offline_sync_controller.dart';

class OfflineSyncScreen extends ConsumerWidget {
  const OfflineSyncScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(offlineSyncControllerProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: PosColors.ink,
        foregroundColor: PosColors.surface,
        title: const Text('Offline sync'),
        actions: [
          IconButton(
            tooltip: 'Refresh queue',
            onPressed: () =>
                ref.read(offlineSyncControllerProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 12),
                Text('Opening the encrypted offline queue'),
              ],
            ),
          ),
        ),
        error: (error, _) => _ErrorPanel(
          message: '$error',
          onRetry: () =>
              ref.read(offlineSyncControllerProvider.notifier).refresh(),
        ),
        data: (state) => _Body(state: state),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.state});

  final OfflineSyncState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(offlineSyncControllerProvider.notifier);
    final summary = state.summary;
    final active = state.active;

    if (state.loadFailed) {
      return _ErrorPanel(
        message: state.error ?? 'The encrypted queue could not be read.',
        onRetry: () =>
            ref.read(offlineSyncControllerProvider.notifier).refresh(),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Sync status',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    if (state.running)
                      const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _CountChip(
                      label: 'Pending',
                      value: summary.pending,
                      tone: PosColors.warning,
                      background: PosColors.warningSoft,
                    ),
                    _CountChip(
                      label: 'In flight',
                      value: summary.inFlight,
                      tone: PosColors.warning,
                      background: PosColors.warningSoft,
                    ),
                    _CountChip(
                      label: 'Synced',
                      value: summary.synced,
                      tone: PosColors.success,
                      background: PosColors.successSoft,
                    ),
                    _CountChip(
                      label: 'Unknown',
                      value: summary.uncertain,
                      tone: PosColors.warning,
                      background: PosColors.warningSoft,
                    ),
                    _CountChip(
                      label: 'Conflict',
                      value: summary.conflict,
                      tone: PosColors.danger,
                      background: PosColors.dangerSoft,
                    ),
                    _CountChip(
                      label: 'Failed',
                      value: summary.failed,
                      tone: PosColors.danger,
                      background: PosColors.dangerSoft,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  state.message ?? _idleMessage(summary),
                  style: const TextStyle(color: PosColors.muted),
                ),
                if (state.error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    state.error!,
                    style: const TextStyle(
                      color: PosColors.danger,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(48, 48),
                      ),
                      onPressed: state.running
                          ? null
                          : () => ref
                                .read(offlineSyncControllerProvider.notifier)
                                .syncAll(),
                      icon: const Icon(Icons.sync),
                      label: const Text('Sync now'),
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(48, 48),
                      ),
                      onPressed: state.running
                          ? null
                          : () => ref
                                .read(offlineSyncControllerProvider.notifier)
                                .reconcile(),
                      icon: const Icon(Icons.fact_check_outlined),
                      label: const Text('Reconcile sales'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        const _PolicyCard(),
        if (state.reconciliation != null) ...[
          const SizedBox(height: 12),
          _ReconciliationCard(report: state.reconciliation!),
        ],
        const SizedBox(height: 12),
        if (active.isEmpty)
          const _EmptyQueue()
        else ...[
          Text(
            'Offline sales needing attention',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          for (final record in active)
            _RecordCard(
              record: record,
              onRetry: state.running
                  ? null
                  : () => controller.retry(record.idempotencyKey),
              onDiscard: state.running
                  ? null
                  : () => _confirmDiscard(context, controller, record),
            ),
        ],
        if (summary.synced > 0) ...[
          const SizedBox(height: 16),
          Text(
            'Recent synced sales',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          for (final record
              in state.records
                  .where((record) => record.state == OfflineSaleState.synced)
                  .take(5))
            _SyncedTile(record: record),
        ],
      ],
    );
  }

  String _idleMessage(OfflineSyncSummary summary) {
    if (summary.total == 0) {
      return 'No sales are queued on this device.';
    }
    if (summary.isClear) {
      return 'All recorded sales are confirmed on the server.';
    }
    return 'Some sales still need a cashier decision.';
  }

  Future<void> _confirmDiscard(
    BuildContext context,
    OfflineSyncController controller,
    OfflineSaleRecord record,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Discard offline sale?'),
        content: const Text(
          'The local queue entry is retained as a failed record for audit, '
          'but it will no longer be submitted. Confirm only after checking '
          'the server sales ledger for the same key.',
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(48, 48)),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await controller.discard(record.idempotencyKey);
    }
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({
    required this.label,
    required this.value,
    required this.tone,
    required this.background,
  });

  final String label;
  final int value;
  final Color tone;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label $value',
        style: TextStyle(color: tone, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _PolicyCard extends StatelessWidget {
  const _PolicyCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stock and conflict policy',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 6),
            Text(
              'Stock is not reserved while a device is offline. The server '
              'allocates stock atomically at finalize. Two offline devices may '
              'both record the same low-stock item; the first accepted sale '
              'wins and the second is rejected as a conflict with no negative '
              'balance and no second sale.',
              style: TextStyle(color: PosColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReconciliationCard extends StatelessWidget {
  const _ReconciliationCard({required this.report});

  final OfflineReconciliation report;

  @override
  Widget build(BuildContext context) {
    final tone = report.matches ? PosColors.success : PosColors.warning;
    final background = report.matches
        ? PosColors.successSoft
        : PosColors.warningSoft;
    return Card(
      color: background,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  report.matches
                      ? Icons.verified_outlined
                      : Icons.warning_amber,
                  color: tone,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Server sales reconciliation',
                    style: TextStyle(color: tone, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(report.summary, style: const TextStyle(color: PosColors.text)),
            if (report.missingKeys.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Missing keys: ${report.missingKeys.join(', ')}',
                style: const TextStyle(color: PosColors.danger),
              ),
            ],
            const SizedBox(height: 6),
            Text(
              'Checked ${report.checkedAt.toLocal()} against server sales. '
              'Stock balances and daily reports are owner-scoped; the same '
              'server records are verified in the reconnect transcript in '
              'docs/offline-sync.md.',
              style: const TextStyle(color: PosColors.muted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({
    required this.record,
    required this.onRetry,
    required this.onDiscard,
  });

  final OfflineSaleRecord record;
  final VoidCallback? onRetry;
  final VoidCallback? onDiscard;

  @override
  Widget build(BuildContext context) {
    final payload = record.payload;
    final money = MoneyFormat(
      currency: payload.currency,
      currencyExponent: payload.currencyExponent,
    );
    final tone = _tone(record.state);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    money.format(payload.totalMinor),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _background(record.state),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    record.state.label,
                    style: TextStyle(color: tone, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${payload.lines.length} line(s), ${payload.tenderKind == TenderKind.cash ? 'Cash' : 'Manual external'}, '
              'key ${payload.idempotencyKey.substring(0, 8)}...',
              style: const TextStyle(color: PosColors.muted, fontSize: 12),
            ),
            if (record.saleReference != null) ...[
              const SizedBox(height: 4),
              Text(
                'Sale ${record.saleReference}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
            if (record.lastError != null) ...[
              const SizedBox(height: 8),
              Text(
                record.lastError!,
                style: TextStyle(color: tone, fontWeight: FontWeight.w600),
              ),
            ],
            if (record.state == OfflineSaleState.conflict) ...[
              const SizedBox(height: 6),
              const Text(
                'Cashier action: compare the paper receipt with this reason, '
                'then refund or collect the difference. Retry only after the '
                'server state allows the same recorded total.',
                style: TextStyle(color: PosColors.muted, fontSize: 12),
              ),
            ],
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(48, 48),
                  ),
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: Text(
                    record.state == OfflineSaleState.conflict
                        ? 'Retry after review'
                        : 'Retry',
                  ),
                ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(48, 48),
                  ),
                  onPressed: onDiscard,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Discard'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _tone(OfflineSaleState state) {
    return switch (state) {
      OfflineSaleState.synced => PosColors.success,
      OfflineSaleState.conflict || OfflineSaleState.failed => PosColors.danger,
      _ => PosColors.warning,
    };
  }

  Color _background(OfflineSaleState state) {
    return switch (state) {
      OfflineSaleState.synced => PosColors.successSoft,
      OfflineSaleState.conflict ||
      OfflineSaleState.failed => PosColors.dangerSoft,
      _ => PosColors.warningSoft,
    };
  }
}

class _SyncedTile extends StatelessWidget {
  const _SyncedTile({required this.record});

  final OfflineSaleRecord record;

  @override
  Widget build(BuildContext context) {
    final payload = record.payload;
    final money = MoneyFormat(
      currency: payload.currency,
      currencyExponent: payload.currencyExponent,
    );
    return Card(
      child: ListTile(
        leading: const Icon(
          Icons.check_circle_outline,
          color: PosColors.success,
        ),
        title: Text(money.format(payload.totalMinor)),
        subtitle: Text(
          record.saleReference ?? 'Confirmed on the server',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _EmptyQueue extends StatelessWidget {
  const _EmptyQueue();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(
              Icons.cloud_done_outlined,
              size: 44,
              color: PosColors.success,
            ),
            const SizedBox(height: 8),
            Text(
              'No offline sales queued',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            const Text(
              'Completed checkouts are confirmed on the server immediately. '
              'Offline captures appear here until they are reconciled.',
              textAlign: TextAlign.center,
              style: TextStyle(color: PosColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 48, color: PosColors.danger),
            const SizedBox(height: 12),
            const Text(
              'Encrypted queue unavailable',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: PosColors.muted),
            ),
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(48, 48)),
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
