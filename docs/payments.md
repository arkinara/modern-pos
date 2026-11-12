# Online payments, webhooks and reconciliation

Status date: 2026-11-12. API version 0.9.0. Ticket #22.

## Provider selection status

The selected integration surface is a QRIS-style hosted payment adapter. Two
implementations exist:

| Provider | Selection | Verified on this VPS |
| --- | --- | --- |
| `MOCK` | Default for local development and tests | Yes, deterministic in-repo sandbox provider |
| `QRIS` | Real hosted QRIS provider selected by `PAYMENT_PROVIDER=qris` | `PENDING - requires provider credentials/commercial setup` |

The QRIS adapter is implemented (`createPayment`, `fetchPayment`,
`refundPayment`) and reads its configuration only from the environment. No real
QRIS account, sandbox key or commercial agreement exists on this VPS, so no live
provider call is claimed. The automated suite verifies the full lifecycle,
signature rules, idempotency and reconciliation against the local sandbox.

## Credentials and configuration

All provider configuration is read from process environment variables. Values
are never written to the database, API responses, logs or diagnostics.

| Variable | Required | Meaning |
| --- | --- | --- |
| `PAYMENT_PROVIDER` | No | `mock` (default) or `qris`. Any other value fails closed. |
| `PAYMENT_WEBHOOK_SECRET` | Yes for webhooks | HMAC-SHA256 secret used to verify provider webhook signatures. |
| `PAYMENT_WEBHOOK_REPLAY_SECONDS` | No | Replay window, default `300` seconds. |
| `PAYMENT_PROVIDER_BASE_URL` | QRIS only | Base URL of the provider sandbox or production API. |
| `PAYMENT_PROVIDER_API_KEY` | QRIS only | Provider API key. |

`PaymentConfigService.describe()` returns only names and booleans, for example:

```json
{
  "provider": "QRIS",
  "webhookSecretConfigured": true,
  "apiKeyConfigured": true,
  "baseUrlConfigured": true,
  "replayWindowSeconds": 300,
  "liveSandboxVerified": false
}
```

Never commit a real `.env`. Local values live in the ignored `apps/api/.env`.
The unit suite asserts that secret values are absent from configuration dumps.

## Lifecycle and state

Online payments are a path distinct from manual cash recording. A completed sale
with `payment.kind = ONLINE` creates one `online_payments` row; cash and
`MANUAL_EXTERNAL` sales never do.

```text
finalize with kind=ONLINE
        |
        v
  PENDING (local intent created, sale + stock committed once)
        |
        +-- provider create --> providerRef + QR payload
        |
        +-- signed payment.succeeded --> SUCCEEDED (settledAt)
        |
        +-- signed payment.failed ----> FAILED (failedAt)
                                   |
                                   +-- explicit retry --> PENDING
        |
        +-- refund through adapter --> PARTIALLY_REFUNDED / REFUNDED
```

Terminal rules:

- A captured (`SUCCEEDED`) payment wins over a late failure event.
- A failure cannot undo a capture.
- Refunds never move a payment back to `PENDING`.
- A failed intent can be retried by calling the create endpoint again. This
  resets the same local row and provider idempotency key; it never creates a
  second sale.

The sale's `payment_records` row mirrors the online state (`PENDING`,
`SUCCEEDED`, `FAILED`, `PARTIALLY_REFUNDED`, `REFUNDED`). Cash sales keep
`RECORDED`. Reports include `ONLINE` in `paymentBreakdown` only for settled
amounts, so a pending or failed provider payment is never reported as received
money.

Stock is deducted exactly once when the sale is finalized, before the provider
settles. Settlement, duplicate webhooks and reconciliation never create a stock
movement. A failed provider payment does not silently reverse stock; operators
must use the existing reversal path, which is audited.

## Idempotency

| Operation | Key | Guarantee |
| --- | --- | --- |
| Finalize | `Idempotency-Key` + `checkout_requests` | Same payload replays the same sale. |
| Payment intent | Unique `saleId` on `online_payments` | Repeated create calls return one payment and one provider reference. |
| Provider create | Online payment id passed as provider idempotency key | A lost client response cannot create a second provider payment. |
| Webhook | Unique `(provider, eventId)` on `payment_webhook_events` | Duplicate and parallel deliveries produce exactly one transition. |
| Refund | Reversal `Idempotency-Key` passed as provider refund idempotency key | A retried reversal does not refund twice. |

The webhook transaction locks the payment row (`SELECT ... FOR UPDATE`), inserts
the event id before transitioning, and retries serialization failures. The unique
event id decides the single winner when deliveries race.

## Webhook signature and replay rules

`POST /v1/payments/webhook` is public:

```text
X-Payment-Signature: t=<unix-seconds>,v1=<hex HMAC-SHA256(secret, t + "." + rawBody)>
```

Verification order:

1. Missing or malformed header: `401 WEBHOOK_SIGNATURE_INVALID`.
2. Timestamp outside the replay window: `401 WEBHOOK_TIMESTAMP_INVALID`.
3. HMAC mismatch, compared with `crypto.timingSafeEqual`: `401 WEBHOOK_SIGNATURE_INVALID`.
4. Invalid JSON or missing `id` / `type` / `data.providerRef`: `400 WEBHOOK_PAYLOAD_INVALID`.
5. Provider mismatch: `401 WEBHOOK_PROVIDER_MISMATCH`.
6. Amount mismatch: `422 WEBHOOK_AMOUNT_MISMATCH`.

A rejected delivery writes nothing. An accepted duplicate returns
`200 { "received": true, "duplicate": true, "eventId": "..." }` without a state
change. The raw body is required because the HMAC covers the exact bytes sent.

## Reconciliation procedure

The provider is the source of truth for a stuck `PENDING` record, but it is
queried read-only; reconciliation never creates a charge.

1. Operator calls `POST /v1/outlets/{outletId}/online-payments/reconcile`
   (owner only), or the client calls
   `POST /v1/outlets/{outletId}/sales/{saleId}/online-payment/refresh` after a
   lost connection.
2. For each local `PENDING` payment the API calls provider `fetchPayment`.
3. `SUCCEEDED` is applied locally without writing a stock movement.
4. `FAILED` is applied as a failed payment.
5. `PENDING` is left unchanged and counted as `unchanged`.
6. A provider error is reported per payment; no local state is guessed.

Live evidence in the ticket transcript forces a local `PENDING` record while the
sandbox provider reports `SUCCEEDED`, reconciles it once, and checks one sale,
one set of stock movements and no second provider payment.

Scheduled execution is intentionally not enabled in this ticket. Run the
endpoint from the operational job or an external scheduler once real provider
credentials exist.

## Refunds and settlement

An online refund uses the existing `POST .../reversals` correction path. The
service calls provider `refundPayment` before recording the reversal, then stores
`externalRefundPerformed = true` and `providerRefundRef` on the same reversal.
Cash and manual reversals keep `externalRefundPerformed = false`.

Rules:

- A refund of a `PENDING` or `FAILED` online payment is rejected with
  `409 PAYMENT_NOT_SETTLED`.
- A refund whose amount exceeds the captured `amountMinor - refundedMinor` is
  rejected with `409 REFUND_EXCEEDS_PAYMENT` (or the existing sale-level
  `REFUND_EXCEEDS_SALE`).
- A second full refund is a `409`. Reusing the same `Idempotency-Key` and payload
  returns the first reversal instead.
- Money return and restock remain independent, exactly as in
  `docs/promotions-refunds.md`.
- A provider refund failure is surfaced; no reversal row claims a refund that the
  provider rejected.

`GET /v1/outlets/{outletId}/online-payments/settlements?from=YYYY-MM-DD&to=YYYY-MM-DD`
returns daily and per-payment captured/refunded/net totals plus:
`onlineSaleTotalMinor`, `pendingMinor`, `failedMinor` and `driftMinor`.
`driftMinor = onlineSaleTotal - (captured + pending + failed)` and must be `0`
when every online sale has exactly one payment record.

## Real QRIS verification recipe (PENDING)

Status: `PENDING - requires provider credentials/commercial setup`.

1. Obtain a QRIS provider sandbox account and its API base URL, API key and
   webhook signing secret. Do not commit them.
2. Configure `PAYMENT_PROVIDER=qris`, `PAYMENT_PROVIDER_BASE_URL`,
   `PAYMENT_PROVIDER_API_KEY` and `PAYMENT_WEBHOOK_SECRET` in the API environment.
3. Point the provider sandbox webhook URL at
   `https://<api-host>/v1/payments/webhook`.
4. Finalize a sale with `payment.kind = ONLINE`, call the online-payment create
   endpoint, and scan the returned QR payload with the provider sandbox app.
5. Record the provider dashboard status and the local `GET .../online-payment`
   response. Send the provider's signed success webhook and confirm
   `SUCCEEDED`.
6. Replay the same event id and confirm `duplicate=true` with no second state
   change. Send an invalid signature and confirm a `401` with no state change.
7. Trigger a provider refund from the app, then confirm the provider dashboard
   and `GET .../online-payments/settlements` show the same captured and refunded
   amounts.
8. Attach the redacted provider dashboard evidence and the local responses to
   the release record. Until this is done, the QRIS adapter remains an
   unverified integration surface.

## Local sandbox

The in-repo sandbox is enabled only when `PAYMENT_PROVIDER=mock`:

| Endpoint | Purpose |
| --- | --- |
| `POST /v1/sandbox/provider/payments` | Create a deterministic provider payment. |
| `GET /v1/sandbox/provider/payments/{providerRef}` | Read the provider ledger. |
| `POST /v1/sandbox/provider/payments/{providerRef}/events` | Advance the provider and return a correctly signed event body. |

The event endpoint returns `{ event, timestamp, signature, rawBody }`. Deliver
that body to `/v1/payments/webhook` with
`X-Payment-Signature: t=<timestamp>,v1=<signature>`. Reuse the event id for
duplicate delivery, and send `payment.succeeded` before `payment.pending` to
exercise out-of-order handling.
