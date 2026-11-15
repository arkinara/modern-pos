## Problem and evidence
README still describes a planning-only repository. Many closed issue bodies say implementation has not started and retain unchecked criteria although closure comments contain implementation evidence and explicit deferrals. known-limitations.md says LAN/USB are not implemented despite existing adapters, and assigns production rollout to #20, which is tables/split bills. All 35 board items are Done without open acceptance owners.

Audit date: 2026-11-15. Baseline revision: `d4b3ac178ef7fd03078caca70fafd32843abeaca`.
Related: #1, #2, #3, #15, #18, #22, #25, #28, #29, #30.

- [README.md](https://github.com/arkinara/modern-pos/blob/d4b3ac178ef7fd03078caca70fafd32843abeaca/README.md)
- [docs/known-limitations.md](https://github.com/arkinara/modern-pos/blob/d4b3ac178ef7fd03078caca70fafd32843abeaca/docs/known-limitations.md)
- [docs/printer-validation.md](https://github.com/arkinara/modern-pos/blob/d4b3ac178ef7fd03078caca70fafd32843abeaca/docs/printer-validation.md)
- [docs/printer-hardware.md](https://github.com/arkinara/modern-pos/blob/d4b3ac178ef7fd03078caca70fafd32843abeaca/docs/printer-hardware.md)

## Scope
Refresh current status documents and reconcile closed-ticket evidence without erasing historical implementation or pending external acceptance.

## Acceptance criteria
- [ ] README accurately describes implemented apps, current commands and staging-versus-production state.
- [ ] Reconcile contradictory transport, refund, rollout and source-layout claims across relevant docs.
- [ ] Link affected closed tickets to exact PR/commit/check evidence and explicitly separate implemented, verified, deferred and unsupported criteria.
- [ ] Deferred criteria link to open acceptance tickets with prerequisites and required evidence.
- [ ] Do not mark pending hardware/provider/operator criteria passed or replace historical evidence with unverified claims.

## Boundaries
Documentation/evidence maintenance only. Preserve useful closure history and keep production authorization separate from acceptance evidence.

## Planning
Priority: P2. Source: Project 19 repository audit (2026-11-15).

## Dependencies
None. Can start independently.
