import 'package:modern_pos_api_client/api.dart';

import 'station_job_gateway.dart';

/// Station-job dispatch is best effort: the order or sale is authoritative and
/// must not fail because a kitchen printer queue could not be written.
Future<void> dispatchSaleStationJobs({
  required StationJobGateway gateway,
  required String outletId,
  required String idempotencyKey,
  required Sale sale,
}) async {
  try {
    await gateway.dispatch(
      outletId: outletId,
      orderId: sale.orderId,
      idempotencyKey: idempotencyKey,
      kind: StationJobKind.ORIGINAL,
      saleId: sale.id,
      lines: sale.lines
          .map(
            (line) => StationJobLine(
              variantId: line.variantId,
              quantity: line.quantity,
              saleLineId: line.id,
              modifiers: line.modifiers
                  .map(
                    (modifier) => StationJobModifier(
                      modifierId: modifier.modifierId,
                      name: modifier.name,
                      quantity: modifier.quantity,
                    ),
                  )
                  .toList(growable: false),
            ),
          )
          .toList(growable: false),
    );
  } catch (_) {
    // The sale is already committed. A missing station job is retried by the
    // station queue, not by repeating checkout.
  }
}

Future<void> dispatchOrderStationJobs({
  required StationJobGateway gateway,
  required String outletId,
  required String idempotencyKey,
  required Order order,
  required StationJobKind kind,
}) async {
  try {
    await gateway.dispatch(
      outletId: outletId,
      orderId: order.id,
      idempotencyKey: idempotencyKey,
      kind: kind,
      lines: order.lines
          .map(
            (line) => StationJobLine(
              variantId: line.variantId,
              quantity: line.quantity,
              modifiers: line.modifiers
                  .map(
                    (modifier) => StationJobModifier(
                      modifierId: modifier.modifierId,
                      quantity: modifier.quantity,
                    ),
                  )
                  .toList(growable: false),
            ),
          )
          .toList(growable: false),
    );
  } catch (_) {
    // See dispatchSaleStationJobs.
  }
}
