import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:modern_pos_api_client/api.dart' hide PrintJob;

import '../../theme/app_theme.dart';
import '../offline/offline_sync_controller.dart';
import '../printing/print_job_models.dart';
import 'checkout_controller.dart';
import 'checkout_models.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _referenceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(_bootstrap);
  }

  Future<void> _bootstrap() async {
    final controller = ref.read(checkoutControllerProvider.notifier);
    final current = await ref.read(checkoutControllerProvider.future);
    if (!mounted) {
      return;
    }
    if (current.pending != null) {
      await controller.recoverPending();
    } else if (current.phase == CheckoutPhase.idle) {
      await controller.start();
    }
  }

  @override
  void dispose() {
    _referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(checkoutControllerProvider);

    return async.when(
      loading: () => const _CheckoutScaffold(
        body: _CenteredProgress(label: 'Preparing checkout'),
      ),
      error: (error, _) => _CheckoutScaffold(
        body: _MessagePanel(
          icon: Icons.error_outline,
          title: 'Checkout unavailable',
          message: '$error',
          actionLabel: 'Retry',
          onAction: () => ref.read(checkoutControllerProvider.notifier).start(),
        ),
      ),
      data: (state) => _CheckoutScaffold(
        canPop: state.phase != CheckoutPhase.submitting,
        body: _body(context, state),
      ),
    );
  }

  Widget _body(BuildContext context, CheckoutState state) {
    return switch (state.phase) {
      CheckoutPhase.idle => _MessagePanel(
        icon: Icons.shopping_cart_checkout,
        title: 'Start a sale',
        message:
            state.message ??
            'Create a server draft and quote before taking payment.',
        actionLabel: 'Start checkout',
        onAction: () => ref.read(checkoutControllerProvider.notifier).start(),
      ),
      CheckoutPhase.preparing => const _CenteredProgress(
        label: 'Creating the draft order and server quote',
      ),
      CheckoutPhase.recovering => _CenteredProgress(
        label: state.message ?? 'Checking the server for an earlier checkout',
      ),
      CheckoutPhase.submitting => const _CenteredProgress(
        label: 'Completing the sale. Do not close the app.',
      ),
      CheckoutPhase.inFlight => _PendingPanel(
        state: state,
        title: 'Server still processing',
        actionLabel: 'Check again',
        onAction: () =>
            ref.read(checkoutControllerProvider.notifier).recoverPending(),
      ),
      CheckoutPhase.blocked => _PendingPanel(
        state: state,
        title: 'Outcome not confirmed',
        actionLabel: 'Check again',
        onAction: () =>
            ref.read(checkoutControllerProvider.notifier).recoverPending(),
        secondaryLabel: 'Retry same key',
        onSecondary: () =>
            ref.read(checkoutControllerProvider.notifier).retrySameKey(),
      ),
      CheckoutPhase.error => _MessagePanel(
        icon: state.message?.contains('connection') == true
            ? Icons.cloud_off
            : Icons.error_outline,
        title: 'Could not complete checkout',
        message:
            state.message ??
            'Check the connection and retry. The cart is still on this device.',
        actionLabel: 'Retry',
        onAction: () => ref.read(checkoutControllerProvider.notifier).start(),
        secondaryLabel: state.message?.contains('connection') == true
            ? 'Record offline sale'
            : null,
        onSecondary: state.message?.contains('connection') == true
            ? () => ref
                  .read(checkoutControllerProvider.notifier)
                  .queueOfflineSale()
            : null,
      ),
      CheckoutPhase.queuedOffline => _OfflineQueuedPanel(state: state),
      CheckoutPhase.quoteExpired => _QuoteExpiredPanel(state: state),
      CheckoutPhase.awaitingTender => _TenderBody(
        state: state,
        referenceController: _referenceController,
      ),
      CheckoutPhase.completed => _ReceiptBody(state: state),
    };
  }
}

class _CheckoutScaffold extends ConsumerWidget {
  const _CheckoutScaffold({required this.body, this.canPop = true});

  final Widget body;
  final bool canPop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offlineActive =
        ref.watch(offlineSyncControllerProvider).value?.summary.active ?? 0;
    return PopScope(
      canPop: canPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: PosColors.ink,
          foregroundColor: PosColors.surface,
          title: const Text('Checkout'),
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
          ],
        ),
        body: SafeArea(child: body),
      ),
    );
  }
}

class _CenteredProgress extends StatelessWidget {
  const _CenteredProgress({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Semantics(
              liveRegion: true,
              child: Text(label, textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessagePanel extends StatelessWidget {
  const _MessagePanel({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    this.secondaryLabel,
    this.onSecondary,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(icon, size: 52, color: PosColors.muted),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: PosColors.muted),
          ),
          const SizedBox(height: 20),
          FilledButton(onPressed: onAction, child: Text(actionLabel)),
          if (secondaryLabel != null && onSecondary != null) ...[
            const SizedBox(height: 8),
            OutlinedButton(
              style: OutlinedButton.styleFrom(minimumSize: const Size(48, 48)),
              onPressed: onSecondary,
              child: Text(secondaryLabel!),
            ),
          ],
          if (secondaryLabel != null) ...[
            const SizedBox(height: 8),
            const Text(
              'An offline sale is stored encrypted on this device and synced '
              'later. Stock is not reserved; the server may reject it as a '
              'conflict. Do not ring the same cart twice.',
              textAlign: TextAlign.center,
              style: TextStyle(color: PosColors.warning, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

class _OfflineQueuedPanel extends ConsumerWidget {
  const _OfflineQueuedPanel({required this.state});

  final CheckoutState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final money = state.money;
    final total = state.offlineTotalMinor ?? 0;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Card(
          color: PosColors.warningSoft,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Icon(
                  Icons.cloud_upload_outlined,
                  size: 44,
                  color: PosColors.warning,
                ),
                const SizedBox(height: 8),
                Text(
                  'Offline sale recorded',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  money.format(total),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Key ${state.offlineKey ?? ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: PosColors.muted, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  state.message ?? 'The sale is queued for encrypted sync.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: PosColors.muted),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'The cart was cleared because this sale is now a pending record. '
              'Do not ring it again. Open Offline sync to retry or resolve a '
              'server conflict caused by stock or a changed total.',
              style: TextStyle(color: PosColors.muted),
            ),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          style: FilledButton.styleFrom(minimumSize: const Size(48, 48)),
          onPressed: () => context.push('/settings/offline-sync'),
          icon: const Icon(Icons.sync),
          label: const Text('Open offline sync'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          style: OutlinedButton.styleFrom(minimumSize: const Size(48, 48)),
          onPressed: () {
            ref.read(checkoutControllerProvider.notifier).acknowledge();
            context.go('/catalog');
          },
          child: const Text('New sale'),
        ),
      ],
    );
  }
}

class _PendingPanel extends StatelessWidget {
  const _PendingPanel({
    required this.state,
    required this.title,
    required this.actionLabel,
    required this.onAction,
    this.secondaryLabel,
    this.onSecondary,
  });

  final CheckoutState state;
  final String title;
  final String actionLabel;
  final VoidCallback onAction;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.sync_problem, size: 52, color: PosColors.warning),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            state.message ??
                'A previous checkout must be resolved before a new sale.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: PosColors.muted),
          ),
          if (state.pending != null) ...[
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.key_outlined),
                title: const Text('Checkout key retained'),
                subtitle: Text(
                  state.pending!.idempotencyKey,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton(onPressed: onAction, child: Text(actionLabel)),
          if (secondaryLabel != null && onSecondary != null) ...[
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: onSecondary,
              child: Text(secondaryLabel!),
            ),
          ],
          const SizedBox(height: 8),
          const Text(
            'A new sale is blocked until this outcome is known.',
            textAlign: TextAlign.center,
            style: TextStyle(color: PosColors.warning, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _QuoteExpiredPanel extends ConsumerWidget {
  const _QuoteExpiredPanel({required this.state});

  final CheckoutState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.schedule, size: 52, color: PosColors.warning),
          const SizedBox(height: 12),
          Text(
            'Quote needs a refresh',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            state.message ??
                'The server rejected the quote. Request a fresh quote and '
                    'review the amount before submitting.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: PosColors.muted),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () =>
                ref.read(checkoutControllerProvider.notifier).refreshQuote(),
            child: const Text('Get new quote'),
          ),
          const SizedBox(height: 8),
          const Text(
            'Nothing is re-priced or re-submitted automatically.',
            style: TextStyle(color: PosColors.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _TenderBody extends ConsumerWidget {
  const _TenderBody({required this.state, required this.referenceController});

  final CheckoutState state;
  final TextEditingController referenceController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(checkoutControllerProvider.notifier);
    final money = state.money;
    final isCash = state.tenderKind == TenderKind.cash;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _TotalsCard(state: state),
        const SizedBox(height: 16),
        SegmentedButton<TenderKind>(
          segments: const [
            ButtonSegment(
              value: TenderKind.cash,
              label: Text('Cash'),
              icon: Icon(Icons.payments_outlined),
            ),
            ButtonSegment(
              value: TenderKind.manualExternal,
              label: Text('Manual external'),
              icon: Icon(Icons.receipt_long_outlined),
            ),
          ],
          selected: {state.tenderKind},
          onSelectionChanged: (selection) =>
              controller.setTenderKind(selection.first),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCash ? 'Cash tendered' : 'Amount received',
                  style: const TextStyle(color: PosColors.muted),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    money.format(state.enteredMinor),
                    style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 12),
                if (isCash) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Change'),
                      Text(
                        money.format(state.changeMinor),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: PosColors.success,
                        ),
                      ),
                    ],
                  ),
                  if (state.shortfallMinor > 0) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Short by ${money.format(state.shortfallMinor)}',
                      style: const TextStyle(
                        color: PosColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ] else ...[
                  const Text(
                    'The manual external amount must equal the amount due. '
                    'No provider charge is made.',
                    style: TextStyle(color: PosColors.muted, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: referenceController,
                    onChanged: controller.setReference,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Reference (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            TextButton(
              onPressed: controller.clearEntered,
              child: const Text('Clear'),
            ),
            const Spacer(),
            TextButton(
              onPressed: controller.useExactAmount,
              child: const Text('Exact amount'),
            ),
          ],
        ),
        _NumericPad(
          onDigit: controller.appendDigit,
          onDoubleZero: () {
            controller.appendDigit('0');
            controller.appendDigit('0');
          },
          onBackspace: controller.backspace,
        ),
        if (state.message != null) ...[
          const SizedBox(height: 12),
          _InlineNotice(message: state.message!, tone: PosColors.warning),
        ],
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: state.canSubmit ? controller.submit : null,
          icon: const Icon(Icons.check_circle_outline),
          label: Text(
            state.phase == CheckoutPhase.submitting
                ? 'Completing sale'
                : 'Complete sale',
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'One request is sent. If the response is lost, the same checkout '
          'key is checked before any retry.',
          textAlign: TextAlign.center,
          style: TextStyle(color: PosColors.muted, fontSize: 12),
        ),
      ],
    );
  }
}

class _TotalsCard extends StatelessWidget {
  const _TotalsCard({required this.state});

  final CheckoutState state;

  @override
  Widget build(BuildContext context) {
    final money = state.money;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Amount due', style: Theme.of(context).textTheme.titleMedium),
            Align(
              alignment: Alignment.centerRight,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  money.format(state.dueMinor),
                  style: Theme.of(context).textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const Divider(height: 20),
            _AmountRow(
              label: 'Subtotal',
              value: money.format(state.subtotalMinor),
            ),
            if (state.serviceMinor != 0)
              _AmountRow(
                label: 'Service',
                value: money.format(state.serviceMinor),
              ),
            if (state.taxMinor != 0)
              _AmountRow(label: 'Tax', value: money.format(state.taxMinor)),
          ],
        ),
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: PosColors.muted)),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(value),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumericPad extends StatelessWidget {
  const _NumericPad({
    required this.onDigit,
    required this.onDoubleZero,
    required this.onBackspace,
  });

  final void Function(String digit) onDigit;
  final VoidCallback onDoubleZero;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    final rows = <List<_PadKey>>[
      const [_PadKey('1'), _PadKey('2'), _PadKey('3')],
      const [_PadKey('4'), _PadKey('5'), _PadKey('6')],
      const [_PadKey('7'), _PadKey('8'), _PadKey('9')],
      const [_PadKey('00'), _PadKey('0'), _PadKey('back')],
    ];

    return Column(
      children: [
        for (final row in rows)
          Row(
            children: [
              for (final key in row)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: switch (key.value) {
                          '00' => onDoubleZero,
                          'back' => onBackspace,
                          final digit => () => onDigit(digit),
                        },
                        child: key.value == 'back'
                            ? const Icon(Icons.backspace_outlined)
                            : Text(
                                key.value,
                                style: const TextStyle(fontSize: 20),
                              ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _PadKey {
  const _PadKey(this.value);

  final String value;
}

class _PrintStatusCard extends StatelessWidget {
  const _PrintStatusCard({
    required this.job,
    required this.onRetry,
    required this.onReprint,
  });

  final PrintJob job;
  final VoidCallback onRetry;
  final VoidCallback onReprint;

  @override
  Widget build(BuildContext context) {
    final color = switch (job.state) {
      PrintJobState.sent => PosColors.success,
      PrintJobState.failed => PosColors.danger,
      PrintJobState.uncertain => PosColors.warning,
      PrintJobState.queued => PosColors.warning,
      PrintJobState.sending => PosColors.warning,
    };
    final background = switch (job.state) {
      PrintJobState.sent => PosColors.successSoft,
      PrintJobState.failed => PosColors.dangerSoft,
      PrintJobState.uncertain => PosColors.warningSoft,
      PrintJobState.queued => PosColors.warningSoft,
      PrintJobState.sending => PosColors.warningSoft,
    };

    return Semantics(
      liveRegion: true,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      job.copy ? 'Receipt COPY' : 'Receipt print',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: background,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      job.state.label,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _description(job),
                style: TextStyle(color: color, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'Attempts: ${job.attempts}. '
                '${job.copy ? 'Marked COPY on paper.' : 'Original receipt job.'}',
                style: const TextStyle(color: PosColors.muted, fontSize: 12),
              ),
              if (job.lastError != null && job.lastError!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  job.lastError!,
                  style: const TextStyle(color: PosColors.muted, fontSize: 12),
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (job.state == PrintJobState.failed ||
                      job.state == PrintJobState.queued)
                    FilledButton.tonalIcon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry print'),
                    ),
                  if (job.state == PrintJobState.uncertain)
                    FilledButton.tonalIcon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.copy_all_outlined),
                      label: const Text('Retry as COPY'),
                    ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(48, 48),
                    ),
                    onPressed: onReprint,
                    icon: const Icon(Icons.print_outlined),
                    label: const Text('Reprint COPY'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Reprints are marked COPY and recorded in the local print '
                'audit. Physical delivery is never claimed as exactly-once.',
                style: TextStyle(color: PosColors.muted, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _description(PrintJob job) {
    return switch (job.state) {
      PrintJobState.sent => 'Sent to printer. Paper delivery is not verified.',
      PrintJobState.sending => 'Sending to the printer.',
      PrintJobState.failed =>
        'Failed. Delivery is known not sent; retry is safe.',
      PrintJobState.uncertain =>
        'Delivery unknown. The paper may or may not have printed; this job is '
            'not retried automatically.',
      PrintJobState.queued =>
        'Queued. It survives app restarts and will not repeat the sale.',
    };
  }
}

class _InlineNotice extends StatelessWidget {
  const _InlineNotice({required this.message, required this.tone});

  final String message;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: tone == PosColors.danger
              ? PosColors.dangerSoft
              : PosColors.warningSoft,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          message,
          style: TextStyle(color: tone, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _ReceiptBody extends ConsumerWidget {
  const _ReceiptBody({required this.state});

  final CheckoutState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sale = state.sale!;
    final money = state.money;
    final payment = sale.payment;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Card(
          color: PosColors.successSoft,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: PosColors.success,
                  size: 44,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sale completed',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SelectableText(
                    sale.reference,
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                if (state.replayed) ...[
                  const SizedBox(height: 4),
                  const Text(
                    'Recovered from the existing checkout key',
                    style: TextStyle(color: PosColors.muted, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Receipt', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                for (final line in sale.lines)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(line.name),
                              if (line.variantName.isNotEmpty)
                                Text(
                                  line.variantName,
                                  style: const TextStyle(
                                    color: PosColors.muted,
                                    fontSize: 12,
                                  ),
                                ),
                              Text(
                                '${line.quantity} x '
                                '${money.format(line.unitPriceMinor)}',
                                style: const TextStyle(
                                  color: PosColors.muted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(money.format(line.lineSubtotalMinor)),
                      ],
                    ),
                  ),
                const Divider(height: 20),
                _AmountRow(
                  label: 'Subtotal',
                  value: money.format(sale.totals.subtotalMinor),
                ),
                if (sale.totals.serviceMinor != 0)
                  _AmountRow(
                    label: 'Service',
                    value: money.format(sale.totals.serviceMinor),
                  ),
                if (sale.totals.taxMinor != 0)
                  _AmountRow(
                    label: 'Tax',
                    value: money.format(sale.totals.taxMinor),
                  ),
                _AmountRow(
                  label: 'Total',
                  value: money.format(sale.totals.totalMinor),
                ),
                const Divider(height: 20),
                _AmountRow(
                  label: payment.kind == PaymentKindEnum.CASH
                      ? 'Cash tendered'
                      : 'Manual external',
                  value: money.format(
                    payment.tenderedMinor ?? payment.amountMinor,
                  ),
                ),
                if (payment.changeMinor != null)
                  _AmountRow(
                    label: 'Change',
                    value: money.format(payment.changeMinor!),
                  ),
                if (payment.reference != null && payment.reference!.isNotEmpty)
                  _AmountRow(label: 'Reference', value: payment.reference!),
              ],
            ),
          ),
        ),
        if (state.printMessage != null) ...[
          const SizedBox(height: 12),
          _InlineNotice(message: state.printMessage!, tone: PosColors.warning),
        ],
        if (state.printJob != null) ...[
          const SizedBox(height: 12),
          _PrintStatusCard(
            job: state.printJob!,
            onRetry: () =>
                ref.read(checkoutControllerProvider.notifier).retryPrint(),
            onReprint: () =>
                ref.read(checkoutControllerProvider.notifier).reprintCopy(),
          ),
        ],
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () {
            ref.read(checkoutControllerProvider.notifier).acknowledge();
            context.go('/catalog');
          },
          child: const Text('New sale'),
        ),
        const SizedBox(height: 8),
        const Text(
          'Receipt printing is best effort. A print failure never repeats '
          'this checkout.',
          textAlign: TextAlign.center,
          style: TextStyle(color: PosColors.muted, fontSize: 12),
        ),
      ],
    );
  }
}
