# Online payments, webhooks and reconciliation

## Current transaction-recording scope

Scope clarified by the owner on 2026-11-17. Customers pay using the merchant's
static QRIS code or another external non-cash method. The cashier checks receipt
in the bank merchant app, selects **QRIS / Non-cash**, and records the exact sale
amount with an optional merchant transaction reference. The existing wire/storage
kind is `MANUAL_EXTERNAL`. QRIS and other externally confirmed non-cash payments
share this recording category.

Set `PAYMENT_PROVIDER=manual` for this scope. Cash and manual non-cash checkout,
receipts, reports, stock effects and reversal recording use the existing sale
workflow. Provider API credentials, automatic QR creation, webhook confirmation
and provider sandbox acceptance are deferred until an automated integration is
requested. Manual reversals record a POS correction after the merchant handles
any bank refund externally.

Production manual mode requires the existing strong JWT secret, secure cookies
and explicit HTTPS origins. Set `PAYMENT_SANDBOX_ENABLED=false`. Provider keys,
webhook secrets and `PAYMENT_MODE` are optional in manual mode. Automatic online
payments and provider webhooks are disabled in that mode. The provider workflow
below is retained as the deferred integration reference.

Status date: 2026-11-12. API version 0.9.0. Ticket #22.

## Provider selection status

The selected integration surface is a QRIS-style hosted payment adapter. Two
implementations exist:

| Provider | Selection | Verified on this VPS |
| --- | --- | --- |
| `MOCK` | Explicit local/test sandbox opt-in | Yes, deterministic in-repo sandbox provider |
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
| `PAYMENT_PROVIDER` | Explicit in production | `manual` for current recording scope, `mock` locally with opt-in, or `qris` for an automated integration. Production rejects MOCK and implicit fallback. |
| `PAYMENT_MODE` | Automated production integration | `sandbox` or `live`. Optional in manual mode. Credentials/base URL must match an automated provider environment. |
| `PAYMENT_SANDBOX_ENABLED` | Local MOCK only | `true` explicitly enables local/test mock payments; production always rejects enabled mock access. |
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

Production startup requires secure cookies, exact HTTPS web origins and a
non-placeholder JWT secret of at least 32 characters. Automated QRIS mode also
requires the payment-webhook secret, provider key and HTTPS provider base URL.
See the [production configuration gate](staging-setup.md#production-configuration-gate-69).
Passing these checks does not verify a provider's actual sandbox contract (#75).

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
  resets the same local row; the provider idempotency key is scoped to the
  retry attempt so the retry can obtain a fresh provider payment without ever
  creating a second sale.

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
| Provider create | Online payment id (plus attempt for an explicit failed retry) | A lost client response cannot create a second provider payment; a failed retry gets a fresh, still-deduped key. |
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
service validates sale state, approval, remaining money/lines and explicit
restock eligibility in a serializable transaction, then commits a `refund_intents`
reservation before provider `refundPayment`. It stores `externalRefundPerformed =
true` and `providerRefundRef` on the completed reversal.
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

### Durable refund recovery (#66)

One unresolved refund reserves the entire sale against competing reversal
requests. This deliberately serializes refunds per sale, including zero-money
corrections. A different key receives `409 REFUND_IN_PROGRESS` until the existing
intent is resolved. Completed partial refunds release the reservation, and the
next refund is checked against the remaining money, line and restock capacity.

The intent binds the normalized request hash, original actor, provider identity,
payment reference, amount and a stable provider key containing outlet and request
IDs. A changed payload under the same key receives `409 IDEMPOTENCY_CONFLICT`.
No database transaction stays open during provider network I/O.

| Intent state | Meaning and recovery |
| --- | --- |
| PENDING | Validated reservation committed; provider may not yet have been called. Retry the original request/key. |
| UNKNOWN | Provider outcome is ambiguous, or recording its success failed. Keep the reservation and retry the original request/key against the provider's idempotency ledger. |
| SUCCEEDED | Provider success is durable; retry completes the saved plan without another provider call or a fresh approval/recipe decision. |
| FAILED | Explicit provider refusal is durable; same-key replay returns `REFUND_FAILED`. Review before submitting a new key. |
| COMPLETED | Reversal, line quantities, payment totals, explicit restock movements and intent completion committed atomically. Replay returns the original reversal. |

Recovery is request-driven through the existing reversal endpoint; there is no
background refund reconciliation worker in this change. Operators must retain the
original payload/key and replay it after reconnect or API restart. Do not clear
UNKNOWN reservations or issue a new key to work around ambiguity. A pending or
unrecognized provider response is not a successful refund. Provider timeout/error
responses retain the reservation unless the adapter reports an explicit refund
refusal. Actual provider idempotency and reconciliation semantics still require
the selected provider's sandbox acceptance under #75.

### Migration and rollout

The additive migration `20261115160000_durable_refund_intents` adds a table,
enum, sale foreign key and unique indexes, including one active intent per sale.
It does not rewrite historical sales, reversals, payments or stock movements.
Cash/manual and online zero-money corrections keep their existing atomic path.

1. Pause refund ingress and drain in-flight refunds on **all** old API instances.
2. Apply migrations and generate the Prisma client before starting the new API.
3. Replace all refund writers with the fixed version, then resume ingress. Do
   not allow mixed old/new refund writers: old code ignores intent reservations.
4. Verify the focused unit suite and the isolated PostgreSQL suite below before
   deployment acceptance. No production deployment is authorized by this record.

Rollback: pause refund ingress first. Reconcile and complete PENDING, UNKNOWN
and SUCCEEDED intents using this version and the original keys. Preserve all
intent rows as audit evidence; do not drop the table/enum to downgrade. A
previous version with the provider-before-validation defect is not a safe refund
writer. If the API must be rolled back, keep refund ingress disabled until a
version that honors durable intents is restored. There is no automatic down
migration or destructive cleanup.

### Developer regression commands

Run unit checks with `pnpm --filter @modern-pos/api test` and API type/build
checks with `pnpm --filter @modern-pos/api typecheck` and
`pnpm --filter @modern-pos/api build`.

For database proof, provision an **isolated disposable PostgreSQL 17.6 database**
whose name ends in `_refund_test`. Set both `DATABASE_URL` and
`REFUND_TEST_DATABASE_URL` to that same target, run the API `migrate:deploy` and
`seed` commands, then run `pnpm --filter @modern-pos/api test:refund:integration`.
The suite uses synthetic seeded owner/outlet/catalog data and creates test
sales; it does not truncate arbitrary databases. It covers distinct/same-key
concurrency, remaining refund limits, full refunds, local-failure rollback and
ambiguous-outcome recovery with controlled provider I/O. Required CI integration
and broader checkout/transfer coverage remain #71.

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

The in-repo sandbox requires `NODE_ENV=development` or `test`,
`PAYMENT_PROVIDER=mock`, `PAYMENT_MODE=sandbox` and explicit
`PAYMENT_SANDBOX_ENABLED=true`. The committed API environment example supplies
these local values. All three public routes below return 404 in production even
if MOCK and the opt-in flag are mistakenly selected; direct mock-provider calls
are gated too.

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
