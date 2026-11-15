## Problem and evidence
Payment lifecycle was verified against the in-repo mock sandbox. The generic QRIS adapter has not been certified against a selected provider's actual contract, credentials, webhook delivery or refund/reconciliation semantics. Closure evidence explicitly marks real-provider verification pending.

Audit date: 2026-11-15. Baseline revision: `d4b3ac178ef7fd03078caca70fafd32843abeaca`.
Related: #22, #18.

- [docs/payments.md](https://github.com/arkinara/modern-pos/blob/d4b3ac178ef7fd03078caca70fafd32843abeaca/docs/payments.md)
- [apps/api/src/payments/qris-payment-provider.service.ts](https://github.com/arkinara/modern-pos/blob/d4b3ac178ef7fd03078caca70fafd32843abeaca/apps/api/src/payments/qris-payment-provider.service.ts)
- [docs/known-limitations.md](https://github.com/arkinara/modern-pos/blob/d4b3ac178ef7fd03078caca70fafd32843abeaca/docs/known-limitations.md)

## Scope
Select a provider, confirm its current official API/signature/idempotency contract, adapt the integration as necessary and run the actual provider sandbox lifecycle.

## Acceptance criteria
- [ ] Record provider/API version, supported methods/currency and required commercial/sandbox prerequisites without exposing secrets.
- [ ] Verify payment creation, genuine signed webhook delivery, duplicate/out-of-order/replay rejection and reconnect recovery.
- [ ] Verify provider-success/local-failure refund recovery, same-key deduplication and partial/full refund semantics after the refund fix.
- [ ] Reconcile provider settlement totals against local payment/reversal records with explained zero unexplained drift.
- [ ] Document credential rotation, timeouts, retry/reconciliation ownership and unsupported cases.
- [ ] Attach redacted provider transaction/webhook/refund IDs and dated results; unresolved external prerequisites remain pending.

## Boundaries
Use sandbox credentials/funds only for acceptance. Do not authorize production charges or infer real-provider success from the mock service.

## Planning
Priority: P1. Source: Project 19 repository audit (2026-11-15).

## Dependencies
- [ ] #66 - [P1] fix(payments): validate durable refund intents before provider side effects
- [ ] #69 - [P1] fix(api): reject unsafe production config and disable mock payment endpoints
- [ ] #71 - [P2] test(api): enforce PostgreSQL transaction and recovery regressions in CI
