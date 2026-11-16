# Payment QA handoff for #75

The repository owner chose mock-first execution on 2026-11-16. This developer
handoff uses the existing PostgreSQL-backed `MockPaymentProviderService` with
IDR, currency exponent 0, and synthetic funds. Provider selection and genuine
provider sandbox acceptance remain pending on #75.

## Repeatable developer checks

Use Node 22.23.1 and PostgreSQL 17.6. Create an isolated disposable database whose
name ends in `_transaction_test`. Set `DATABASE_URL` and
`TRANSACTION_TEST_DATABASE_URL` to that same database. Set `NODE_ENV=test`,
`PAYMENT_PROVIDER=mock`, `PAYMENT_MODE=sandbox` and
`PAYMENT_SANDBOX_ENABLED=true`. Run from the repository root.

```powershell
pnpm --filter @modern-pos/api prisma:generate
pnpm --filter @modern-pos/api migrate:deploy
pnpm --filter @modern-pos/api seed
pnpm --filter @modern-pos/api test
pnpm --filter @modern-pos/api test:db
```

The required CI database gate includes `payments/lifecycle.integration.ts`.
The suite exercises real PostgreSQL writes and the existing provider ledger.
Signed events are delivered over loopback HTTP through the actual raw-body
webhook controller and exception filter. Checkout/refund orchestration is called
through its application services using a seeded owner and isolated catalog/stock.

| Scenario | Required developer result |
| --- | --- |
| Repeated payment creation | One provider reference and ledger row |
| Tampered raw body and stale signed request | HTTP 401, zero stored events |
| Concurrent duplicate webhook deliveries | Three HTTP 200 responses, one event transition |
| Success followed by pending/failed events | Successful payment preserved |
| Lost webhook and fresh service instances | Refresh recovers persisted provider success |
| Failed payment and explicit retry | New provider reference, old event replay harmless |
| Refund accepted before local failure | Durable intent and provider refund survive, local effects roll back |
| Lost refund response and fresh service instances | Original provider key replayed, one provider refund |
| Partial then full refund with restock | Local payment, reversal totals and provider ledger agree, opening stock restored |

The database suite also covers separate-process checkout recovery, SQL-triggered
transaction failure and concurrent refund/transfer requests. Fresh service
instances in the payment suite exercise persisted recovery state within one
test process. The mock provider has no remote network, settlement fees or bank
payouts. Its ledger comparison records captured/refunded amounts and zero
unexplained drift per synthetic refund sale.

## Provider-specific QA worksheet

Keep these fields pending until the selected provider and secure sandbox access
are available. Record actual results and evidence URLs on #75.

| Field | Current value |
| --- | --- |
| Selected provider, API version, official contract URL | Pending owner selection |
| Methods, currency, sandbox account/commercial requirements | Pending provider contract |
| Signing algorithm, raw-body format, timestamp/replay policy | Pending provider contract |
| Payment and refund idempotency scope/expiry | Pending provider contract |
| Timeout, retry and status-query semantics | Pending provider contract |
| Partial/full refund support, cumulative versus per-request amounts | Pending provider contract |
| Settlement timezone, fees, rounding and payout totals | Pending provider contract |
| Credential custodian and reconciliation operator | Pending named owners |
| Redacted genuine transaction/webhook/refund IDs and dates | Pending real sandbox execution |

The generic QRIS adapter expects the contract in `payments.md`. Confirm and adapt
that contract against official provider documentation before supplying genuine
credentials. Exercise creation, genuine webhook delivery, invalid signatures,
duplicates, out-of-order events, reconnect, partial/full refunds and refund
response loss. Compare provider settlement exports with local online-payment and
reversal totals, explaining fees and timing differences individually.

## Recovery and credential procedure

Keep API keys and signing secrets in the deployment secret store. Store only
redacted identifiers in evidence. Rotate sandbox credentials first and validate
the provider's webhook-secret overlap procedure before rotating live credentials.
The current application accepts one webhook secret. Coordinate the cutover and
provider redelivery window accordingly.

For an uncertain refund, preserve the original idempotency key and payload.
Reconcile the provider's status and replay that same request using the durable
intent workflow. Assign an operator and escalation contact before external QA.
See `payments.md` for durable intent states and rollback procedures. Provider
timeouts, rate limits and reconciliation cadence must follow the selected
contract. Production access and production charges require separate authorization.
