## Problem and evidence
Online refunds call the provider before validating sale-state, line membership/remaining quantity and restock eligibility. Using unchanged reverse/applyReversal source methods with mocked I/O, a partial refund naming a UUID-shaped line absent from the sale produced: provider refund accepted → database transaction → 422 REFUND_LINE_NOT_FOUND; no reversal inserted. This is a control-flow reproduction, not a live money or PostgreSQL test. Provider success followed by local failure can leave an unrecorded external refund.

Audit date: 2026-11-15. Baseline revision: `d4b3ac178ef7fd03078caca70fafd32843abeaca`.
Related: #17, #21, #22.

- [apps/api/src/sales/sales.service.ts#L1589](https://github.com/arkinara/modern-pos/blob/d4b3ac178ef7fd03078caca70fafd32843abeaca/apps/api/src/sales/sales.service.ts#L1589)
- [apps/api/src/sales/sales.service.ts#L1764](https://github.com/arkinara/modern-pos/blob/d4b3ac178ef7fd03078caca70fafd32843abeaca/apps/api/src/sales/sales.service.ts#L1764)
- [apps/api/src/payments/payments.service.ts#L605](https://github.com/arkinara/modern-pos/blob/d4b3ac178ef7fd03078caca70fafd32843abeaca/apps/api/src/payments/payments.service.ts#L605)

## Scope
Validate and durably reserve a refund intent, bound to normalized request/hash and refundable limits, before provider I/O. Use a stable provider key and recover/reconcile ambiguous outcomes.

## Acceptance criteria
- [ ] Invalid sale state, line, quantity and restock requests make zero provider refund calls.
- [ ] Persist an auditable intent before provider effects; record success, failure and unknown outcomes.
- [ ] Same-key replay cannot refund twice; a changed payload with the same key is rejected.
- [ ] Concurrent distinct-key requests cannot exceed remaining money, line or restock limits.
- [ ] Provider success followed by database failure/process restart recovers to exactly one consistent reversal.
- [ ] Add regressions for all above, including real PostgreSQL concurrency; preserve cash/manual reversal behaviour.

## Boundaries
Do not hold a database transaction open across network I/O as the sole fix. Do not claim real-provider verification from mocked tests.

## Planning
Priority: P1. Source: Project 19 repository audit (2026-11-15).

## Dependencies
None. Can start independently.
