# Online ordering, customers and digital receipts

Status date: 2026-11-13. API version 0.14.0. Ticket #27.

This document defines the supported ordering channels, the channel-order state
machine, payment and stock ownership, deduplication, opt-in customer records,
retention and access rules, and the digital receipt lifecycle. It also states
exactly what is not implemented on this deployment.

## Supported channels

| Channel | Direction | Implemented here | Availability |
| --- | --- | --- | --- |
| `MANUAL` | Staff entry through the back office | Yes | `AVAILABLE` |
| `PHONE` | Staff entry through the back office | Yes | `AVAILABLE` |
| `WEB` | Signed inbound webhook | Yes | `AVAILABLE` when `CHANNEL_WEBHOOK_SECRET` is set |
| `GRABFOOD` | Third-party adapter | Adapter contract only | `PENDING — requires channel account credentials` |
| `SHOPEEFOOD` | Third-party adapter | Adapter contract only | `PENDING — requires channel account credentials` |

`GET /v1/outlets/{outletId}/channels` returns the channel list with its current
availability and reason. The two third-party rows never claim a live connection.
Adding a real channel means implementing the same `ChannelAdapter` contract and
mapping its delivery into the shared `ChannelOrderInput` contract; order, stock,
payment and receipt behaviour stays in one service and does not fork.

### Inbound webhook

`POST /v1/channels/web/orders` accepts a signed order. The raw JSON body is used
for signature verification:

```text
X-Channel-Signature: t=<unix-seconds>,v1=<hex HMAC-SHA256(secret, t + "." + rawBody)>
```

Configuration:

| Variable | Default | Meaning |
| --- | --- | --- |
| `CHANNEL_WEBHOOK_SECRET` | none | Shared HMAC secret. Without it the web channel returns `503 CHANNEL_NOT_CONFIGURED`. |
| `CHANNEL_WEBHOOK_REPLAY_SECONDS` | `300` | Replay window in seconds. |

Verification order is fixed: missing/malformed header → `401
CHANNEL_SIGNATURE_INVALID`; timestamp outside the window → `401
CHANNEL_TIMESTAMP_INVALID`; HMAC mismatch → `401 CHANNEL_SIGNATURE_INVALID`. No
order, stock movement, payment or customer row is written before verification
succeeds. The timestamp and body are both covered by the signature.

## Order state machine

```text
             signed inbound delivery / staff entry
                              |
                              v
                         RECEIVED  -------------------- cancel (no stock effect)
                              |                                  |
                       accept | (stock taken once)               v
                              v                              CANCELLED
                         ACCEPTED  -------------------- cancel (stock restored)
                              |
                    collect + | fulfil (cash on pickup)
                              v
                         FULFILLED
```

| Transition | Endpoint | Stock effect | Payment effect |
| --- | --- | --- | --- |
| Receive | `POST /v1/channels/{channel}/orders` or `POST /v1/outlets/{outletId}/channel-orders` | None | None |
| Accept | `POST .../channel-orders/{orderId}/accept` | Consume pinned recipe quantities exactly once | None |
| Fulfil | `POST .../channel-orders/{orderId}/fulfill` | None | Record exactly one cash payment equal to the order total |
| Cancel from `RECEIVED` | `POST .../channel-orders/{orderId}/cancel` | None | None |
| Cancel from `ACCEPTED` | `POST .../channel-orders/{orderId}/cancel` | Restore the exact accepted quantities once | None |

Any other transition returns `409 ORDER_STATE_INVALID`. A fulfilled order cannot
be cancelled; it must use the existing sale/reversal path if a return is needed.
A cancelled or fulfilled order cannot be accepted again.

## Payment rules

The only enforced order payment mode is `CASH_ON_PICKUP`.

- Receiving and accepting an order never records money.
- Fulfilment requires `collectedMinor` to equal the snapshot total exactly;
  otherwise `422 PAYMENT_AMOUNT_MISMATCH`.
- A successful fulfilment creates one `channel_order_payments` row and moves
  the order to `paymentStatus = PAID`. `channel_order_payments.orderId` is
  unique, so a second fulfilment cannot record a second payment.
- Cancelling an unpaid order creates no payment row.
- `PREPAID_PROVIDER` is accepted by the contract so the future mode is explicit,
  but the service rejects it with `422 PAYMENT_MODE_UNAVAILABLE`. Provider-paid
  orders remain `PENDING — requires provider credentials`; see the reproduction
  recipe below.

This ticket does not create or modify sale, stock or payment semantics. An
online channel order is not silently turned into a completed POS sale.

## Stock ownership

**Decision: stock is taken on acceptance, not on receipt and not on POS
settlement.**

Reasons:

- The channel order becomes operationally committed only when staff accepts it.
  Receiving a webhook must not let an unverified or unwanted delivery take
  inventory.
- The existing POS/offline policy consumes stock when a sale is committed
  (`CHANNEL_ORDER` reuses the same recipe snapshot and balance-lock rules). An
  order that has been accepted is the online equivalent of a committed sale.
- Reserving stock before acceptance would require a second reservation ledger
  and would diverge from the offline policy.

Rules enforced in one serializable transaction:

1. The order row is locked with `SELECT ... FOR UPDATE`.
2. The pinned recipe version from the order line snapshot is used, exactly like
   a finalized sale.
3. Balances are locked and checked for shortages. A shortage returns `422
   INSUFFICIENT_STOCK` and leaves the order in `RECEIVED`.
4. One negative `CHANNEL_ORDER_ACCEPT` movement per stock item is posted.
5. Accepted cancellation posts positive `CHANNEL_ORDER_CANCEL` movements with
   the exact quantities from the acceptance movements and restores balances.
6. State changes use the order version and state in the `WHERE` clause, so a
   concurrent accept/cancel/fulfil cannot apply twice.

The order response and the event log expose every transition actor and reason.

## Deduplication and channel references

Dedupe key: **`(businessId, channel, channelReference)`**.

- `channelReference` is stored on the order and returned by every read endpoint.
- `GET .../channel-orders?search=...` searches the reference (and the note).
- Sequential duplicate delivery with the same canonical payload returns `200`
  with `duplicate: true` and the same order id.
- Concurrent duplicate delivery is resolved by the unique constraint. Losers
  resolve to the same existing order after the unique violation.
- The same reference with a different payload returns `409
  CHANNEL_REFERENCE_CONFLICT` and changes nothing.
- Invalid signature or a stale timestamp is rejected before the dedupe lookup
  and writes no row.

## Opt-in customer records

Customers are per outlet and never created without explicit consent.

| Field | Rule |
| --- | --- |
| Consent | `consent: true` is required. `false` returns `422 CUSTOMER_CONSENT_REQUIRED`. |
| Consent source | `WEB_CHECKOUT`, `STAFF_ENTRY` or `IMPORT` is stored with `consentAt`. |
| Contact | Exactly one normalised email or phone is stored (`contactNormalized` unique per outlet). |
| Minimum data | A display name and one contact channel. Nothing else is required. |
| Anonymisation | Retained after expiry as an anonymised row so order history keeps its foreign key, with name replaced, email/phone removed and `anonymizedAt` set. |

Access rules:

- `GET/POST /v1/outlets/{outletId}/customers...` is owner-only. A cashier gets
  `403 FORBIDDEN`. Cashier access to customer data is not needed by the cashier
  mobile flow and is therefore denied rather than partially exposed.
- Every customer read is constrained by both `outletId` and `businessId`, on top
  of the global outlet-scope guard. A cross-outlet or cross-tenant request
  returns `403`/`404` without revealing whether the record exists.
- An anonymised customer cannot receive a new receipt; the endpoint returns
  `422 CUSTOMER_RETENTION_EXPIRED`.

## Retention

`GET/PUT /v1/outlets/{outletId}/customers/retention-policy` stores the policy per
outlet. Defaults apply until the policy is first saved:

| Setting | Default | Bounds |
| --- | --- | --- |
| Customer retention | 365 days | 1–3650 |
| Receipt artifact retention | 90 days | 1–3650 |
| Receipt link lifetime | 1440 minutes (24 hours) | 1–10080 |

`POST /v1/outlets/{outletId}/customers/purge` is the documented on-demand purge
(owner-only) and returns counts plus the active policy:

- customers older than the customer window that are not yet anonymised are
  anonymised in place;
- receipt artifacts older than the receipt window, or whose link has expired,
  are deleted.

The same purge is safe to run repeatedly (idempotent for already-anonymised
customers). A scheduled deployment job is a host concern: run the same endpoint
from cron with an owner service session, or call the service method directly.

## Digital receipts

`POST /v1/outlets/{outletId}/sales/{saleId}/receipt` (owner-only) renders an
immutable HTML and plain-text artifact for an existing sale and stores it in
`digital_receipts`.

- The returned `token` is a 32-byte random value, shown once. Only its SHA-256
  hash is stored.
- The link is `GET /v1/receipts/{token}` (JSON with `html` and `text`) or
  `GET /v1/receipts/{token}/html` (HTML response).
- Links are unguessable and expire at `expiresAt`. Expired, purged and foreign
  tokens all return `404 NOT_FOUND`. No customer id, email or phone is required
  in the URL.
- Receipts can optionally link to an opt-in customer. The customer must belong
  to the same outlet and must not be anonymised.
- Retention follows the receipt retention window. Purging removes the artifact;
  an already-issued URL stops resolving.

Actual email or SMS delivery is **not implemented on this VPS**: `PENDING —
requires provider credentials`. The artifact, links, expiry and retention are
real and testable; only dispatch is out of scope.

### Reproduction recipe for dispatch (future)

1. Add an email/SMS provider account and credentials to the ignored
   `apps/api/.env` (for example `EMAIL_PROVIDER_API_KEY`, `EMAIL_FROM`).
2. Add a provider adapter next to the receipt service that accepts the stored
   `contentHtml`/`contentText` and the customer contact.
3. Send only after `createForSale` commits; retries must reuse the receipt id as
   the provider idempotency key.
4. Add a delivery state table so a failed dispatch can be retried without
   creating a second receipt.
5. Verify with a real provider sandbox before claiming delivery.

## Third-party channel reproduction recipe

1. Obtain the channel partner/sandbox account and credentials.
2. Store the credentials in the ignored API environment; never in the database,
   logs or API responses.
3. Implement a `ChannelAdapter` that maps the provider payload into
   `ChannelOrderInput` and verifies the provider's own signature before calling
   the shared intake service.
4. Keep the provider reference as `channelReference`. The existing unique key
   gives sequential and concurrent dedupe for free.
5. Run the same acceptance, cancellation, stock, payment and receipt tests used
   for the `WEB` channel, then update the availability row from
   `PENDING_CREDENTIALS` to `AVAILABLE`.

## Limits

- Third-party channel accounts are not connected.
- Email/SMS dispatch is not connected.
- Provider prepaid order capture is not implemented.
- Stock is not reserved before acceptance; an order waiting in `RECEIVED` does
  not hold inventory.
- Modifiers and promotions are not applied to channel order lines in this
  release. Lines are priced from the current outlet menu snapshot.
- The on-demand purge is manual; no scheduler is bundled in the application.
