import 'dart:async';

import 'package:modern_pos_api_client/api.dart';
import 'package:modern_pos_mobile/features/printing/station_job_gateway.dart';

Station testStation({
  required String id,
  required String name,
  StationKind kind = StationKind.KITCHEN,
}) {
  return Station(
    id: id,
    name: name,
    kind: kind,
    isDefault: false,
    printerConfigId: null,
    printerModel: null,
    sortOrder: 0,
    revision: 1,
    routeCount: 0,
  );
}

StationJob testStationJob({
  required String id,
  required String stationId,
  String stationName = 'Kitchen',
  String orderId = 'order-1',
  String? saleId = 'sale-1',
  String orderReference = 'SALE-ORDER-1',
  String variantId = 'variant-1',
  StationJobKind kind = StationJobKind.ORIGINAL,
  StationJobStateEnum state = StationJobStateEnum.QUEUED,
  bool copy = false,
  String? reprintOfId,
  String itemName = 'Chicken Rice',
  String variantName = 'Regular',
  int quantity = 1,
  List<StationJobModifier> modifiers = const [],
  int attempts = 0,
  String? lastError,
}) {
  final now = DateTime.utc(2026, 1, 1, 10);
  return StationJob(
    id: id,
    stationId: stationId,
    stationName: stationName,
    orderId: orderId,
    saleId: saleId,
    orderReference: orderReference,
    variantId: variantId,
    kind: kind,
    state: state,
    copy: copy,
    reprintOfId: reprintOfId,
    itemName: itemName,
    variantName: variantName,
    quantity: quantity,
    modifiers: modifiers,
    attempts: attempts,
    lastError: lastError,
    createdAt: now,
    updatedAt: now,
  );
}

class FakeStationJobGateway implements StationJobGateway {
  FakeStationJobGateway({List<Station>? stations, List<StationJob>? jobs})
    : stations = stations ?? [],
      jobs = jobs ?? [];

  List<Station> stations;
  List<StationJob> jobs;

  /// Optional barrier so two consumers can observe the same QUEUED row before
  /// either compare-and-set runs.
  Completer<void>? claimGate;

  int claimCalls = 0;
  int reprintCalls = 0;
  int retryCalls = 0;
  int listJobCalls = 0;
  int saleWrites = 0;
  int stockWrites = 0;
  final List<Map<String, Object?>> dispatched = [];

  @override
  Future<List<Station>> listStations(String outletId) async =>
      List<Station>.from(stations);

  @override
  Future<List<StationJob>> listJobs(
    String outletId,
    String stationId, {
    String? state,
    int limit = 100,
  }) async {
    listJobCalls++;
    return jobs
        .where(
          (job) =>
              job.stationId == stationId &&
              (state == null || job.state.toString() == state),
        )
        .take(limit)
        .toList(growable: false);
  }

  @override
  Future<StationJob> claim({
    required String outletId,
    required String jobId,
    required int attempts,
  }) async {
    claimCalls++;
    final gate = claimGate;
    if (gate != null) {
      await gate.future;
    }
    final index = _indexOf(jobId);
    final current = jobs[index];
    if (current.state != StationJobStateEnum.QUEUED) {
      throw const StationJobConflictException(
        'JOB_ALREADY_CLAIMED',
        'Another consumer already claimed this station job',
      );
    }
    final claimed = _copy(
      current,
      state: StationJobStateEnum.SENDING,
      attempts: attempts,
    );
    jobs[index] = claimed;
    return claimed;
  }

  @override
  Future<StationJob> markState({
    required String outletId,
    required String jobId,
    required StationJobStateEnum state,
    required int attempts,
    String? lastError,
  }) async {
    final index = _indexOf(jobId);
    final updated = _copy(
      jobs[index],
      state: state,
      attempts: attempts,
      lastError: lastError,
      clearLastError: lastError == null,
    );
    jobs[index] = updated;
    return updated;
  }

  @override
  Future<StationJob> retry({
    required String outletId,
    required String jobId,
  }) async {
    retryCalls++;
    final index = _indexOf(jobId);
    final current = jobs[index];
    if (current.state != StationJobStateEnum.FAILED &&
        current.state != StationJobStateEnum.UNKNOWN) {
      throw const StationJobConflictException(
        'JOB_NOT_RETRYABLE',
        'Only failed or uncertain jobs can be retried',
      );
    }
    final requeued = _copy(
      current,
      state: StationJobStateEnum.QUEUED,
      clearLastError: true,
    );
    jobs[index] = requeued;
    return requeued;
  }

  @override
  Future<StationJob> reprint({
    required String outletId,
    required String jobId,
    String? idempotencyKey,
  }) async {
    reprintCalls++;
    final original = jobs[_indexOf(jobId)];
    final copy = _copy(
      original,
      id: '${original.id}-copy-$reprintCalls',
      state: StationJobStateEnum.QUEUED,
      copy: true,
      reprintOfId: original.id,
      attempts: 0,
      clearLastError: true,
    );
    jobs.add(copy);
    return copy;
  }

  @override
  Future<List<StationJob>> dispatch({
    required String outletId,
    required String orderId,
    required String idempotencyKey,
    required StationJobKind kind,
    String? saleId,
    required List<StationJobLine> lines,
  }) async {
    dispatched.add({
      'outletId': outletId,
      'orderId': orderId,
      'idempotencyKey': idempotencyKey,
      'kind': kind.toString(),
      'saleId': saleId,
      'lines': lines.map((line) => line.toJson()).toList(growable: false),
    });
    return const [];
  }

  int _indexOf(String jobId) {
    final index = jobs.indexWhere((job) => job.id == jobId);
    if (index < 0) {
      throw StateError('Unknown station job $jobId');
    }
    return index;
  }

  StationJob _copy(
    StationJob job, {
    String? id,
    StationJobStateEnum? state,
    bool? copy,
    String? reprintOfId,
    int? attempts,
    String? lastError,
    bool clearLastError = false,
  }) {
    return StationJob(
      id: id ?? job.id,
      stationId: job.stationId,
      stationName: job.stationName,
      orderId: job.orderId,
      saleId: job.saleId,
      orderReference: job.orderReference,
      variantId: job.variantId,
      kind: job.kind,
      state: state ?? job.state,
      copy: copy ?? job.copy,
      reprintOfId: reprintOfId ?? job.reprintOfId,
      itemName: job.itemName,
      variantName: job.variantName,
      quantity: job.quantity,
      modifiers: job.modifiers,
      attempts: attempts ?? job.attempts,
      lastError: clearLastError ? null : (lastError ?? job.lastError),
      createdAt: job.createdAt,
      updatedAt: DateTime.utc(2026, 1, 1, 10, 1),
    );
  }
}
