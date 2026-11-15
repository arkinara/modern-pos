# Kitchen station delivery on Android (#67)

Status: **app consumer, exclusive claim, ticket rendering and fake-transport
tests implemented. Physical printer acceptance is PENDING.**

This document describes how a server station job becomes paper on the Android
cashier device. It is the missing consumer between the station routing queue
(`#25`) and the printer transports. Nothing here claims that a real printer
produced paper.

## Flow

1. Order or sale creation dispatches station jobs through
   `POST /v1/outlets/{outletId}/orders/{orderId}/station-jobs`.
   - Checkout dispatches `ORIGINAL` after the sale is committed.
   - Opening a table order dispatches `ORIGINAL`.
   - Cancelling a table order dispatches `CANCEL` with the same lines.
   - `AMEND` is accepted by the same endpoint and rendered the same way.
2. The server routes each line to its station, persists the job with the stable
   order reference and exposes the independent station queue.
3. The Android **Kitchen delivery** screen (`/settings/station-queue`) lists
   queued jobs for the selected station.
4. Pressing **Deliver queued** (or **All stations**) makes the app:
   1. load the configured printer transport (Bluetooth Classic, LAN or USB);
   2. compare-and-set claim the job `QUEUED -> SENDING` on the server;
   3. render the kitchen ticket (item, quantity, modifiers, station, stable
      order reference, `ORIGINAL` / `AMENDMENT` / `CANCELLATION`, `COPY`) and
      write the ESC/POS bytes through the existing `PrinterAdapter`;
   4. record `SENT`, or `UNKNOWN` if the write result is ambiguous.
5. The app never calls sales, payment or stock endpoints for this flow. Retry
   and COPY only change station-job rows.

## Exclusive claim (AC3)

`PATCH /v1/outlets/{outletId}/station-jobs/{jobId}` is a compare-and-set.

- A claim is sent as `state: SENDING`.
- The server only accepts `SENDING` when the job is still `QUEUED`.
- The update is `UPDATE ... WHERE id = ? AND state = 'QUEUED'`; exactly one
  consumer changes a row.
- The loser receives `409 JOB_ALREADY_CLAIMED` (or `409 JOB_STATE_CONFLICT` for
  a stale state snapshot) and must not send the ticket.
- A second `SENDING` claim for a job already claimed is rejected; the consumer
  refreshes the queue instead.

The automated proof is the API test that races two `updateJobState` calls and
the app test that races two delivery services sharing one fake server queue.

## Stable order reference (AC2)

Every job for an order reuses the first job's `orderReference`. If the original
ticket was created before checkout, that is `ORDER-<orderId>`. When the sale
exists, the reference is the sale reference. An `AMEND` or `CANCEL` created after
the sale therefore keeps the original paper reference instead of inventing a
second scheme.

## UNKNOWN and explicit COPY (AC4)

- `SENT` means the transport accepted the byte stream; it is not proof of paper.
- A disconnect or write failure after the claim becomes `UNKNOWN`.
- A `SENDING` row left by an app restart is promoted to `UNKNOWN` by
  `recoverInterrupted` on screen startup.
- `UNKNOWN` is never automatically resent. The operator checks the printer and
  chooses **COPY**, which calls the reprint endpoint, creates a new job marked
  `copy`, renders `COPY - NOT AN ORIGINAL`, and sends that new job.
- `FAILED` (known not sent, e.g. a refused connection) can be retried as the
  same job. `UNKNOWN` does not use that path in the Android UI.

## Sale, payment and stock independence (AC5)

Station delivery uses only the `station_jobs_*` endpoints. The app test fake
counts sale and stock writes and asserts they stay zero across routing,
amendment, cancellation, disconnect, restart, concurrency and COPY. Server-side
tests assert the same for create, retry and reprint.

## Automated coverage

```bash
cd apps/mobile
flutter test test/station_delivery_service_test.dart -r expanded
cd ../../apps/api
pnpm test -- station-routing.service.test.ts
```

The app tests use two fake transports and cover routing, amendment,
cancellation, disconnect to `UNKNOWN`, restart recovery, concurrent-claim
exclusivity, explicit COPY and dispatch lines.

## Physical acceptance recipe

State: `PENDING - requires Android device + ESC/POS printer`.

1. Install the debug APK (`docs/android-build.md`) and configure the printer in
   **Settings > Receipt printer**; run Test print and record the model, Android
   version, transport, code page, width and cut behaviour.
2. Create station routing in the back office (for example Kitchen and Bar).
3. Complete a sale containing one routed item for each station and open
   **Settings > Kitchen delivery**. Press **Deliver queued** for each station.
4. Confirm each station printer receives only its own item, with the stable
   order reference, quantity, variant and modifiers.
5. Amend one line and cancel another. Confirm both tickets show the same
   `Order:` reference as the original, with `AMENDMENT` / `CANCELLATION` and the
   changed quantity.
6. Disconnect the printer during a send. Confirm the app records `UNKNOWN`, does
   not resend automatically, and that **COPY** produces a ticket marked
   `COPY - NOT AN ORIGINAL`.
7. Kill and restart the app mid-send. Confirm the stale `SENDING` job becomes
   `UNKNOWN` and no paper is produced until the operator acts.
8. Reconcile the sale, payment and stock records: retry and COPY must not change
   any of them.
9. Attach dated logs and paper photos before marking any hardware combination
   supported. Until then every row in `docs/printer-hardware.md` stays
   `PENDING`.
