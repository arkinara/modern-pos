import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modern_pos_api_client/api.dart';

import '../../theme/app_theme.dart';
import 'station_queue_controller.dart';

/// Android kitchen delivery screen. It shows the server station queue, claims
/// queued tickets exclusively and keeps uncertain jobs for an explicit COPY.
class StationQueueScreen extends ConsumerStatefulWidget {
  const StationQueueScreen({super.key});

  @override
  ConsumerState<StationQueueScreen> createState() => _StationQueueScreenState();
}

class _StationQueueScreenState extends ConsumerState<StationQueueScreen> {
  @override
  Widget build(BuildContext context) {
    final async = ref.watch(stationQueueControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kitchen delivery'),
        actions: [
          IconButton(
            tooltip: 'Refresh station queue',
            onPressed: () =>
                ref.read(stationQueueControllerProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('Loading station queues'),
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
                const Text('Could not load station queues'),
                const SizedBox(height: 8),
                Text(
                  '$error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: PosColors.muted),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () =>
                      ref.invalidate(stationQueueControllerProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (state) => _Body(state: state),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.state});

  final StationQueueState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(stationQueueControllerProvider.notifier);
    if (state.stations.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'No stations are configured for this outlet. Ask an owner to create '
          'station routing first.',
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        DropdownButtonFormField<String>(
          initialValue: state.selectedStationId,
          decoration: const InputDecoration(labelText: 'Station'),
          items: state.stations
              .map(
                (station) => DropdownMenuItem(
                  value: station.id,
                  child: Text(station.name),
                ),
              )
              .toList(growable: false),
          onChanged: state.busy
              ? null
              : (value) {
                  if (value != null) {
                    controller.select(value);
                  }
                },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: state.busy || state.selectedStationId == null
                    ? null
                    : controller.deliverSelected,
                icon: const Icon(Icons.print),
                label: const Text('Deliver queued'),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: state.busy ? null : controller.deliverAll,
              child: const Text('All stations'),
            ),
          ],
        ),
        if (state.message != null) ...[
          const SizedBox(height: 12),
          Text(state.message!),
        ],
        const SizedBox(height: 12),
        const Text(
          'SENT means the printer transport accepted the bytes. UNKNOWN means '
          'paper may or may not have printed. The app never resends UNKNOWN '
          'tickets automatically; use COPY only after checking the paper.',
          style: TextStyle(color: PosColors.muted),
        ),
        const SizedBox(height: 16),
        if (state.jobs.isEmpty)
          const Text('This station has no tickets in the latest page.')
        else
          ...state.jobs.map(
            (job) => _JobCard(
              job: job,
              busy: state.busy,
              onRetry: () => controller.retry(job.id),
              onCopy: () => controller.reprintCopy(job.id),
            ),
          ),
      ],
    );
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({
    required this.job,
    required this.busy,
    required this.onRetry,
    required this.onCopy,
  });

  final StationJob job;
  final bool busy;
  final VoidCallback onRetry;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final unknown = job.state == StationJobStateEnum.UNKNOWN;
    final failed = job.state == StationJobStateEnum.FAILED;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${job.quantity} x ${job.itemName}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            if (job.variantName.isNotEmpty) Text(job.variantName),
            for (final modifier in job.modifiers)
              if ((modifier.name ?? '').isNotEmpty) Text('+ ${modifier.name}'),
            const SizedBox(height: 6),
            Text('Order ${job.orderReference} · ${job.kind} · ${job.state}'),
            if (job.copy) const Text('COPY'),
            if (job.lastError != null)
              Text(
                job.lastError!,
                style: const TextStyle(color: PosColors.danger),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (failed)
                  OutlinedButton(
                    onPressed: busy ? null : onRetry,
                    child: const Text('Retry'),
                  ),
                if (unknown)
                  FilledButton(
                    onPressed: busy ? null : onCopy,
                    child: const Text('COPY'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
