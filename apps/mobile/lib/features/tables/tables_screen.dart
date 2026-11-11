import 'package:flutter/material.dart' hide Table;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modern_pos_api_client/api.dart';

import '../../theme/app_theme.dart';
import 'table_orders_controller.dart';
import 'table_orders_gateway.dart';

class TablesScreen extends ConsumerWidget {
  const TablesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tableOrdersControllerProvider);

    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _TablesError(
        message: _messageFor(error),
        onRetry: () => ref.invalidate(tableOrdersControllerProvider),
      ),
      data: (data) {
        if (data.tables.isEmpty) {
          return const _EmptyTables();
        }
        return RefreshIndicator(
          onRefresh: () =>
              ref.read(tableOrdersControllerProvider.notifier).refresh(),
          child: _TablesBody(state: data),
        );
      },
    );
  }
}

class _TablesBody extends ConsumerWidget {
  const _TablesBody({required this.state});

  final TableOrdersState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1024
            ? 3
            : constraints.maxWidth >= 768
            ? 2
            : 1;
        const gap = 12.0;
        final width =
            (constraints.maxWidth - 32 - gap * (columns - 1)) / columns;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Tables', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text(
              '${state.occupiedCount} of ${state.tables.length} tables open',
              style: const TextStyle(color: PosColors.muted),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: PosColors.surfaceTint,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: PosColors.border),
              ),
              child: const Text(
                'Opening a table order reserves no stock. Stock is consumed '
                'only when a bill is settled, and cancelling before payment '
                'consumes nothing.',
                style: TextStyle(color: PosColors.muted),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: gap,
              runSpacing: gap,
              children: state.rows
                  .map(
                    (row) => SizedBox(
                      width: width,
                      child: _TableCard(row: row, state: state),
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
        );
      },
    );
  }
}

class _TableCard extends ConsumerWidget {
  const _TableCard({required this.row, required this.state});

  final TableOrderRow row;
  final TableOrdersState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(tableOrdersControllerProvider.notifier);
    final order = row.order;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    row.table.label,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                _StatusBadge(occupied: row.isOccupied),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              row.table.seatCount > 0
                  ? '${row.table.seatCount} seats'
                  : 'Table',
              style: const TextStyle(color: PosColors.muted),
            ),
            const SizedBox(height: 10),
            if (order == null)
              const Text(
                'Available. Open an order from the current cart.',
                style: TextStyle(color: PosColors.muted),
              )
            else ...[
              Text(
                'Order ${_shortId(order.id)} · v${order.version}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                '${order.lines.length} lines · '
                '${order.lines.fold<int>(0, (sum, line) => sum + line.quantity)} items',
                style: const TextStyle(color: PosColors.muted),
              ),
              const SizedBox(height: 4),
              const Text(
                'Split parents settle as separate bills; each bill charges once.',
                style: TextStyle(color: PosColors.muted, fontSize: 12),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (order == null)
                  FilledButton.icon(
                    onPressed: () => _run(
                      context,
                      () => controller.open(row.table),
                      success: 'Table ${row.table.label} opened.',
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Open order'),
                  )
                else ...[
                  OutlinedButton.icon(
                    onPressed: () => _transfer(context, ref, order),
                    icon: const Icon(Icons.swap_horiz),
                    label: const Text('Transfer'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _split(context, controller, order),
                    icon: const Icon(Icons.call_split),
                    label: const Text('Split 2 ways'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _cancel(context, controller, order),
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('Cancel'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _transfer(
    BuildContext context,
    WidgetRef ref,
    Order order,
  ) async {
    final targets = state.tables
        .where((table) => table.id != order.tableId)
        .toList();
    final selected = await showDialog<Table>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Transfer order'),
        children: targets.isEmpty
            ? const [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No other active table is available.'),
                ),
              ]
            : targets
                  .map(
                    (table) => SimpleDialogOption(
                      onPressed: () => Navigator.of(context).pop(table),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text('Move to ${table.label}'),
                      ),
                    ),
                  )
                  .toList(growable: false),
      ),
    );
    if (selected == null || !context.mounted) {
      return;
    }
    await _run(
      context,
      () => ref
          .read(tableOrdersControllerProvider.notifier)
          .transfer(order, selected),
      success: 'Order moved to ${selected.label}.',
    );
  }

  Future<void> _split(
    BuildContext context,
    TableOrdersController controller,
    Order order,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Split into two bills?'),
        content: const Text(
          'Every line is divided across two bills. Each bill is settled and '
          'charged separately; the original order cannot be settled again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep as one bill'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Split'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) {
      return;
    }
    await _run(
      context,
      () => controller.splitTwoWays(order),
      success: 'Order split into two bills.',
    );
  }

  Future<void> _cancel(
    BuildContext context,
    TableOrdersController controller,
    Order order,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel this order?'),
        content: const Text(
          'The unpaid order is cancelled. No stock is consumed and the audit '
          'trail records who cancelled it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep order'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cancel order'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) {
      return;
    }
    await _run(
      context,
      () => controller.cancel(order),
      success: 'Order cancelled; no stock was consumed.',
    );
  }

  Future<void> _run<T>(
    BuildContext context,
    Future<T> Function() action, {
    required String success,
  }) async {
    try {
      await action();
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(success)));
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(_messageFor(error))));
      }
    }
  }

  String _shortId(String id) => id.length <= 8 ? id : id.substring(0, 8);
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.occupied});

  final bool occupied;

  @override
  Widget build(BuildContext context) {
    final color = occupied ? PosColors.warning : PosColors.success;
    final background = occupied ? PosColors.warningSoft : PosColors.successSoft;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        occupied ? 'Open' : 'Free',
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _EmptyTables extends StatelessWidget {
  const _EmptyTables();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(
            Icons.table_restaurant_outlined,
            size: 56,
            color: PosColors.muted,
          ),
          const SizedBox(height: 12),
          Text('No tables yet', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          const Text(
            'An owner can create tables in the back office. Table orders stay '
            'available once a table exists.',
            textAlign: TextAlign.center,
            style: TextStyle(color: PosColors.muted),
          ),
        ],
      ),
    );
  }
}

class _TablesError extends StatelessWidget {
  const _TablesError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 48, color: PosColors.danger),
          const SizedBox(height: 12),
          Text(
            'Could not load tables',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

String _messageFor(Object error) {
  if (error is TableOrdersException) {
    if (error.statusCode == 403) {
      return 'Owner permission is required for this action.';
    }
    return error.message;
  }
  return 'The change did not complete. The server kept the previous state.';
}
