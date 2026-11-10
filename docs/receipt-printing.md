# Receipt printing, queue, retry and reprints (#16)

Status: implemented and covered by host tests. Physical paper delivery is
`PENDING — requires printer model + Android device`; no test in this repository
claims that paper came out. Run, format and test commands: `DEVELOPMENT.md`.

## Receipt content

A completed sale builds an immutable receipt snapshot from the server `Sale`
payload. No device-side arithmetic changes a financial value:

- business name, outlet name and receipt address/header from outlet settings;
- sale reference and the completion time rendered in the outlet IANA timezone;
- line item name, variant, quantity, unit price and line total;
- subtotal, service and tax when non-zero, and the server total;
- tender kind and tendered amount, cash change, and manual-external reference;
- receipt footer text.

Money is integer minor units end to end. `ReceiptDocument` is a pure text
builder, so wrapping and content are unit tested without hardware. Long names
hard-wrap at the configured column count; amount columns are never truncated.
All receipt lines are bounded by the paper width.

## Durable queue and state machine

The Drift `print_queue_jobs` table stores: job id, sale id/reference, outlet,
device, printer snapshot, full receipt JSON, state, copy flag, attempts, last
error, timestamps and mirror flag. The row is written before any bytes are sent:
the queue entry exists before the first transport call.

```
QUEUED ──attempt──> SENDING ──transport accepted──> SENT
   │                    │
   │                    └──write error──> UNCERTAIN (delivery unknown)
   │
   └──connect/preflight failure──> FAILED (known not sent)
```

- `SENT` means the transport accepted the byte stream. It does **not** prove
  paper output. The UI says so.
- `FAILED` is known not sent (for example: printer not connected, permission
  denied, unsupported transport). Retrying is safe.
- `UNCERTAIN` means the write failed after the queue entered `SENDING`. Bytes may
  or may not have reached the printer. The UI shows this honestly and never
  retries it automatically.
- App restart changes any leftover `SENDING` row to `UNCERTAIN`. `QUEUED` rows
  are still durable and are offered to the cashier for resume/retry.
- A sale has at most one original job. `findOriginalForSale` returns the existing
  row instead of inserting a duplicate.

A print failure never calls the sales/finalize API. The finalize call count is
unchanged and no second sale is created.

## Retry policy

| Condition | Automatic | Manual |
| --- | --- | --- |
| `QUEUED` with a printer configured | resumed when the queue screen opens | Retry |
| `FAILED`, attempts < 3 | 5s, then 15s, then 60s | Retry |
| `FAILED`, attempts >= 3 | no | Retry until 5 total attempts |
| `UNCERTAIN` | never | `Retry as COPY` / `Reprint COPY` |
| `SENT` | no | `Reprint COPY` |
| no printer configured | no (stays `QUEUED`) | configure printer, then Retry |

Attempts increment when a send attempt starts. `last_error` stores the
classified, actionable message. The maximum is five total attempts; after that
the cashier must use a deliberate COPY reprint.

## Reprint and audit

A reprint creates a **new job** with a new id and `copy: true`. The receipt
output contains a bold `COPY` marker, `REPRINT - NOT AN ORIGINAL`, and a COPY
footer. The original job is never rewritten.

Every queue transition and reprint appends a local `print_queue_audits` row with
job id, sale id, action, actor id/email, copy flag, detail and timestamp. The UI
shows that reprints are marked and audited.

When the `printing_*` contract has a server printer-configuration id for the
device, job metadata is mirrored on a best-effort basis:

- `POST /v1/outlets/{outletId}/print-jobs` with the job id as `Idempotency-Key`;
- `PATCH /v1/outlets/{outletId}/print-jobs/{jobId}` for state/attempts/last error.

The API returns 404 when another device tries to update the job. Mirror failure
never blocks local printing, retry or reprint; the local queue is authoritative.

## Honest uncertainty and exactly-once limitation

There is no physical exactly-once guarantee. A Bluetooth/SPP write can fail after
the printer received part of the job, and the transport cannot read back paper
status. The product therefore:

1. never claims a physical print succeeded just because bytes were written;
2. shows `UNCERTAIN` plainly to the cashier;
3. requires a visible COPY reprint when paper may be missing;
4. never automatically resends an ambiguous job.

Physical verification of any of these states is `PENDING — requires printer
model + Android device`; follow `docs/printer-validation.md`.

## Deferred

- #17 reversal/restock integration with receipts and reprints.
- #18 end-to-end MVP verification with real hardware.
- #19/#20 Phase 2 transports (LAN/USB) and richer delivery confirmation.
- Cash drawer, barcode, QR and model-specific status queries.

## Tests

- `apps/mobile/test/receipt_document_test.dart`: content, outlet-local time,
  exact totals, long-name wrapping, COPY marker.
- `apps/mobile/test/print_queue_service_test.dart`: restart survival, one
  original job per sale, failed vs uncertain classification, no auto-resend,
  bounded retry policy, COPY plus audit.
- `apps/mobile/test/checkout_controller_test.dart`: print failure does not
  repeat finalize, no-printer queued job, manual COPY reprint.
- `apps/mobile/test/print_queue_screen_test.dart`: loading/empty/error and
  queued/sent/failed/uncertain UI states at 320 px width.
- `apps/api/src/printing/printing.service.test.ts`: device-owned configuration,
  optimistic revision, idempotent mirror, cross-device 404.
