import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modern_pos_api_client/api.dart';

import '../auth/auth_controller.dart';
import 'station_delivery_service.dart';
import 'station_job_gateway.dart';

class StationQueueState {
  const StationQueueState({
    this.stations = const [],
    this.selectedStationId,
    this.jobs = const [],
    this.results = const [],
    this.busy = false,
    this.message,
  });

  final List<Station> stations;
  final String? selectedStationId;
  final List<StationJob> jobs;
  final List<StationDeliveryResult> results;
  final bool busy;
  final String? message;

  Station? get selectedStation {
    for (final station in stations) {
      if (station.id == selectedStationId) {
        return station;
      }
    }
    return null;
  }

  StationQueueState copyWith({
    List<Station>? stations,
    String? selectedStationId,
    List<StationJob>? jobs,
    List<StationDeliveryResult>? results,
    bool? busy,
    String? message,
    bool clearMessage = false,
  }) {
    return StationQueueState(
      stations: stations ?? this.stations,
      selectedStationId: selectedStationId ?? this.selectedStationId,
      jobs: jobs ?? this.jobs,
      results: results ?? this.results,
      busy: busy ?? this.busy,
      message: clearMessage ? null : (message ?? this.message),
    );
  }
}

final stationQueueControllerProvider =
    AsyncNotifierProvider<StationQueueController, StationQueueState>(
      StationQueueController.new,
    );

class StationQueueController extends AsyncNotifier<StationQueueState> {
  StationJobGateway get _gateway => ref.read(stationJobGatewayProvider);

  StationDeliveryService get _delivery =>
      ref.read(stationDeliveryServiceProvider);

  @override
  Future<StationQueueState> build() async {
    final outletId = await _requireOutletId();
    final stations = await _gateway.listStations(outletId);
    final stationIds = stations.map((station) => station.id).toList();
    await _delivery.recoverInterrupted(outletId, stationIds: stationIds);
    final selected = stations.isEmpty ? null : stations.first.id;
    final jobs = selected == null
        ? const <StationJob>[]
        : await _gateway.listJobs(outletId, selected);
    return StationQueueState(
      stations: stations,
      selectedStationId: selected,
      jobs: jobs,
    );
  }

  Future<String> _requireOutletId() async {
    final session = await ref.read(authControllerProvider.future);
    final outletIds = session?.user.outletIds ?? const <String>[];
    if (outletIds.isEmpty) {
      throw const StationJobApiException(
        code: 'NO_OUTLET',
        message: 'This session has no authorized outlet.',
      );
    }
    return outletIds.first;
  }

  Future<void> select(String stationId) async {
    final outletId = await _requireOutletId();
    final current = state.value;
    if (current == null || current.busy) {
      return;
    }
    state = AsyncData(current.copyWith(busy: true, clearMessage: true));
    try {
      final jobs = await _gateway.listJobs(outletId, stationId);
      state = AsyncData(
        current.copyWith(
          selectedStationId: stationId,
          jobs: jobs,
          busy: false,
          clearMessage: true,
        ),
      );
    } catch (error) {
      state = AsyncData(current.copyWith(busy: false, message: '$error'));
    }
  }

  Future<void> refresh() async {
    final outletId = await _requireOutletId();
    final current = state.value;
    if (current == null) {
      return;
    }
    final selected = current.selectedStationId;
    state = AsyncData(current.copyWith(busy: true, clearMessage: true));
    try {
      final stations = await _gateway.listStations(outletId);
      final jobs = selected == null
          ? const <StationJob>[]
          : await _gateway.listJobs(outletId, selected);
      state = AsyncData(
        current.copyWith(
          stations: stations,
          jobs: jobs,
          busy: false,
          clearMessage: true,
        ),
      );
    } catch (error) {
      state = AsyncData(current.copyWith(busy: false, message: '$error'));
    }
  }

  Future<void> deliverSelected() async {
    final outletId = await _requireOutletId();
    final current = state.value;
    final stationId = current?.selectedStationId;
    if (current == null || stationId == null || current.busy) {
      return;
    }
    state = AsyncData(current.copyWith(busy: true, clearMessage: true));
    try {
      final results = await _delivery.deliverStation(outletId, stationId);
      await _reloadWithResults(outletId, stationId, results);
    } catch (error) {
      state = AsyncData(state.value!.copyWith(busy: false, message: '$error'));
    }
  }

  Future<void> deliverAll() async {
    final outletId = await _requireOutletId();
    final current = state.value;
    if (current == null || current.busy) {
      return;
    }
    state = AsyncData(current.copyWith(busy: true, clearMessage: true));
    try {
      final results = await _delivery.deliverPending(outletId);
      final stationId = current.selectedStationId;
      if (stationId == null) {
        state = AsyncData(current.copyWith(busy: false, results: results));
        return;
      }
      await _reloadWithResults(outletId, stationId, results);
    } catch (error) {
      state = AsyncData(state.value!.copyWith(busy: false, message: '$error'));
    }
  }

  Future<void> reprintCopy(String jobId) async {
    final outletId = await _requireOutletId();
    final current = state.value;
    if (current == null || current.busy) {
      return;
    }
    state = AsyncData(current.copyWith(busy: true, clearMessage: true));
    try {
      final result = await _delivery.copyJob(outletId: outletId, jobId: jobId);
      final stationId = current.selectedStationId;
      if (stationId == null) {
        state = AsyncData(current.copyWith(busy: false, results: [result]));
        return;
      }
      await _reloadWithResults(outletId, stationId, [result]);
    } catch (error) {
      state = AsyncData(state.value!.copyWith(busy: false, message: '$error'));
    }
  }

  Future<void> retry(String jobId) async {
    final outletId = await _requireOutletId();
    final current = state.value;
    if (current == null || current.busy) {
      return;
    }
    state = AsyncData(current.copyWith(busy: true, clearMessage: true));
    try {
      final result = await _delivery.retryFailed(
        outletId: outletId,
        jobId: jobId,
      );
      final stationId = current.selectedStationId;
      if (stationId == null) {
        state = AsyncData(current.copyWith(busy: false, results: [result]));
        return;
      }
      await _reloadWithResults(outletId, stationId, [result]);
    } catch (error) {
      state = AsyncData(state.value!.copyWith(busy: false, message: '$error'));
    }
  }

  Future<void> _reloadWithResults(
    String outletId,
    String stationId,
    List<StationDeliveryResult> results,
  ) async {
    final jobs = await _gateway.listJobs(outletId, stationId);
    state = AsyncData(
      state.value!.copyWith(
        jobs: jobs,
        results: results,
        busy: false,
        message: _summary(results),
      ),
    );
  }

  String? _summary(List<StationDeliveryResult> results) {
    if (results.isEmpty) {
      return 'No queued kitchen tickets for this station.';
    }
    final sent = results
        .where((result) => result.outcome == StationDeliveryOutcome.sent)
        .length;
    final uncertain = results
        .where((result) => result.outcome == StationDeliveryOutcome.uncertain)
        .length;
    final conflicts = results
        .where((result) => result.outcome == StationDeliveryOutcome.conflict)
        .length;
    final noPrinter = results
        .where((result) => result.outcome == StationDeliveryOutcome.noPrinter)
        .length;
    return '$sent sent, $uncertain unknown, $conflicts already claimed, '
        '$noPrinter without printer.';
  }
}
