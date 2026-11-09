import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';
import '../catalog/catalog_controller.dart';
import '../catalog/catalog_models.dart';
import '../checkout/checkout_controller.dart';
import '../checkout/checkout_models.dart';
import 'cart_controller.dart';
import 'cart_line.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartControllerProvider);
    final catalog = ref.watch(catalogControllerProvider);
    final checkout = ref.watch(checkoutControllerProvider);
    final snapshot = catalog.value;
    final pending = checkout.value?.pending;

    return cart.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) =>
          _CartError(onRetry: () => ref.invalidate(cartControllerProvider)),
      data: (state) {
        if (state.isEmpty) {
          return _EmptyCart(pending: pending);
        }
        return _CartBody(state: state, snapshot: snapshot, pending: pending);
      },
    );
  }
}

class _CartBody extends ConsumerWidget {
  const _CartBody({
    required this.state,
    required this.snapshot,
    required this.pending,
  });

  final CartState state;
  final CatalogSnapshot? snapshot;
  final PendingCheckout? pending;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final money = state.lines.first.money;
    final controller = ref.read(cartControllerProvider.notifier);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Text(
                '${state.lineCount} ${state.lineCount == 1 ? 'line' : 'lines'}'
                ' · ${state.itemCount} ${state.itemCount == 1 ? 'item' : 'items'}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              TextButton.icon(
                onPressed: () => _confirmClear(context, controller),
                icon: const Icon(Icons.delete_sweep_outlined),
                label: const Text('Clear cart'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            itemCount: state.lines.length,
            itemBuilder: (context, index) {
              final line = state.lines[index];
              final reason = cartLineUnavailableReason(
                snapshot,
                menuId: line.menuId,
                variantId: line.variantId,
              );
              return _CartLineCard(
                line: line,
                unavailableReason: reason,
                onIncrement: () =>
                    controller.increment(line.menuId, line.variantId),
                onDecrement: () =>
                    controller.decrement(line.menuId, line.variantId),
                onRemove: () => controller.remove(line.menuId, line.variantId),
              );
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: const BoxDecoration(
              color: PosColors.surfaceTint,
              border: Border(top: BorderSide(color: PosColors.border)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (pending != null) ...[
                  Semantics(
                    liveRegion: true,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: PosColors.warningSoft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'An earlier checkout has an unknown outcome. Resolve '
                        'it before starting a new sale.',
                        style: TextStyle(
                          color: PosColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
                Text('Total', style: Theme.of(context).textTheme.titleMedium),
                Align(
                  alignment: Alignment.centerRight,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      money.format(state.totalMinor),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'The server quote at checkout is authoritative.',
                  style: TextStyle(color: PosColors.muted, fontSize: 12),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => context.push('/checkout'),
                  icon: Icon(
                    pending != null
                        ? Icons.sync_problem
                        : Icons.point_of_sale_outlined,
                  ),
                  label: Text(
                    pending != null ? 'Resolve unfinished sale' : 'Checkout',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmClear(
    BuildContext context,
    CartController controller,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear cart?'),
        content: const Text('This removes every unsent line from this device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep cart'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear cart'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await controller.clear();
    }
  }
}

class _CartLineCard extends StatelessWidget {
  const _CartLineCard({
    required this.line,
    required this.unavailableReason,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  final CartLine line;
  final String? unavailableReason;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final atMax = line.quantity >= CartLine.maxQuantity;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 6, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        line.itemName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        line.variantName,
                        style: const TextStyle(color: PosColors.muted),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Remove ${line.itemName}',
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            if (unavailableReason != null) ...[
              const SizedBox(height: 4),
              Semantics(
                liveRegion: true,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: PosColors.dangerSoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$unavailableReason. Kept in cart until you remove it.',
                    style: const TextStyle(
                      color: PosColors.danger,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  line.money.format(line.unitPriceMinor),
                  style: const TextStyle(color: PosColors.muted),
                ),
                _QuantityStepper(
                  quantity: line.quantity,
                  canDecrement: line.quantity > 1,
                  canIncrement: !atMax,
                  itemName: line.itemName,
                  onIncrement: onIncrement,
                  onDecrement: onDecrement,
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  line.money.format(line.subtotalMinor),
                  style: Theme.of(context).textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            if (atMax) ...[
              const SizedBox(height: 4),
              const Text(
                'Maximum quantity reached.',
                style: TextStyle(color: PosColors.warning, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.canDecrement,
    required this.canIncrement,
    required this.itemName,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int quantity;
  final bool canDecrement;
  final bool canIncrement;
  final String itemName;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: PosColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Decrease quantity of $itemName',
            onPressed: canDecrement ? onDecrement : null,
            icon: const Icon(Icons.remove),
          ),
          Semantics(
            liveRegion: true,
            label: 'Quantity $quantity',
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 28),
              child: Text(
                '$quantity',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Increase quantity of $itemName',
            onPressed: canIncrement ? onIncrement : null,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart({this.pending});

  final PendingCheckout? pending;

  @override
  Widget build(BuildContext context) {
    if (pending != null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.sync_problem, size: 56, color: PosColors.warning),
            const SizedBox(height: 12),
            Text(
              'Unfinished sale',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            const Text(
              'An earlier checkout has an unknown outcome. Check the server '
              'before starting a new sale.',
              textAlign: TextAlign.center,
              style: TextStyle(color: PosColors.muted),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => context.push('/checkout'),
              icon: const Icon(Icons.sync),
              label: const Text('Resolve unfinished sale'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(
            Icons.shopping_cart_outlined,
            size: 56,
            color: PosColors.muted,
          ),
          const SizedBox(height: 12),
          Text('Cart is empty', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          const Text(
            'Browse the catalog and add an item to start a sale.',
            textAlign: TextAlign.center,
            style: TextStyle(color: PosColors.muted),
          ),
        ],
      ),
    );
  }
}

class _CartError extends StatelessWidget {
  const _CartError({required this.onRetry});

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
            'Could not open the cart',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'Saved lines are still on this device.',
            style: TextStyle(color: PosColors.muted),
          ),
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
