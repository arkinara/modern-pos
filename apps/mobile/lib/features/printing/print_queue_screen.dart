import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_theme.dart';
import 'print_job_models.dart';
import 'print_queue_controller.dart';

/// Cashier-facing view of the durable print queue. Delivery is presented
/// honestly: SENT means the transport accepted bytes, UNCERTAIN means paper
/// output is unknown and the job was not retried automatically.
class PrintQueueScreen extends ConsumerStatefulWidget {
  const PrintQueueScreen({super.key});

  @override
  ConsumerState<PrintQueueScreen> createState() => _PrintQueueScreenState();
}

class _PrintQueueScreenState extends ConsumerState<PrintQueueScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        unawaited(ref.read(printQueueControllerProvider.notifier).resume());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(printQueueControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Print queue')),
      body: async.when(
        loading: () => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('Loading print jobs'),
            ],
          ),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: PosColors.danger,
                ),
                const SizedBox(height: 12),
                const Text('Could not load the print queue'),
                const SizedBox(height: 8),
                Text(
                  '$error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: PosColors.muted),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => ref.invalidate(printQueueControllerProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (jobs) => RefreshIndicator(
          onRefresh: () =>
              ref.read(printQueueControllerProvider.notifier).refresh(),
          child: jobs.isEmpty
              ? ListView(
                  padding: const EdgeInsets.all(24),
                  children: const [
                    SizedBox(height: 80),
                    Icon(
                      Icons.print_disabled_outlined,
                      size: 56,
                      color: PosColors.muted,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No print jobs yet',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Completed sales create a durable receipt job here, even '
                      'when no printer is configured.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: PosColors.muted),
                    ),
                  ],
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: jobs.length + 1,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return const _QueueNotice();
                    }
                    final job = jobs[index - 1];
                    return _JobCard(
                      job: job,
                      onRetry: () => ref
                          .read(printQueueControllerProvider.notifier)
                          .retry(job.id),
                      onReprint: () => ref
                          .read(printQueueControllerProvider.notifier)
                          .reprint(job.id),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _QueueNotice extends StatelessWidget {
  const _QueueNotice();

  @override
  Widget build(BuildContext context) {
    return const Card(
      color: PosColors.warningSoft,
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Text(
          'Printing is best effort. SENT means the printer accepted the bytes; '
          'it is not a guarantee that paper came out. Jobs survive app '
          'restarts. UNCERTAIN jobs are never resent automatically.',
          style: TextStyle(color: PosColors.warning),
        ),
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({
    required this.job,
    required this.onRetry,
    required this.onReprint,
  });

  final PrintJob job;
  final Future<PrintJob?> Function() onRetry;
  final Future<PrintJob?> Function() onReprint;

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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              job.saleReference,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (job.copy)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: PosColors.accentSoft,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'COPY',
                      style: TextStyle(
                        color: PosColors.accent,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
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
                    style: TextStyle(color: color, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              _description(job.state),
              style: TextStyle(color: color, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              'Attempts ${job.attempts} · ${_formatTime(job.createdAt)}',
              style: const TextStyle(color: PosColors.muted, fontSize: 12),
            ),
            if (job.lastError != null && job.lastError!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                job.lastError!,
                style: const TextStyle(color: PosColors.muted, fontSize: 12),
              ),
            ],
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (job.state == PrintJobState.failed ||
                    job.state == PrintJobState.queued)
                  FilledButton.tonalIcon(
                    onPressed: () => onRetry(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                if (job.state == PrintJobState.uncertain)
                  FilledButton.tonalIcon(
                    onPressed: () => onRetry(),
                    icon: const Icon(Icons.copy_all_outlined),
                    label: const Text('Retry as COPY'),
                  ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(48, 48),
                  ),
                  onPressed: () => onReprint(),
                  icon: const Icon(Icons.print_outlined),
                  label: const Text('Reprint COPY'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _description(PrintJobState state) {
    return switch (state) {
      PrintJobState.sent =>
        'Sent. Paper delivery is not verified by the transport.',
      PrintJobState.sending => 'Sending to the printer.',
      PrintJobState.failed =>
        'Failed before sending. Delivery is known not sent.',
      PrintJobState.uncertain =>
        'Delivery unknown. Paper may or may not have printed. Not retried '
            'automatically.',
      PrintJobState.queued =>
        'Queued and stored on this device. It survives app restarts.',
    };
  }

  String _formatTime(DateTime value) {
    final local = value.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.year}-$month-$day $hour:$minute';
  }
}
