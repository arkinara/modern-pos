## Problem and evidence
All original project items were Done while acknowledged external acceptance remained pending. A final closing gate must follow the integrity fixes and explicit device/provider/operator/operations acceptance rather than treating historical green CI as complete operational proof.

Audit date: 2026-11-15. Baseline revision: `d4b3ac178ef7fd03078caca70fafd32843abeaca`.
Related: #18 and the 2026-11-15 repository audit.

- [docs/known-limitations.md](https://github.com/arkinara/modern-pos/blob/d4b3ac178ef7fd03078caca70fafd32843abeaca/docs/known-limitations.md)
- [.github/workflows/ci.yml](https://github.com/arkinara/modern-pos/blob/d4b3ac178ef7fd03078caca70fafd32843abeaca/.github/workflows/ci.yml)
- [docs/owner-guide.md](https://github.com/arkinara/modern-pos/blob/d4b3ac178ef7fd03078caca70fafd32843abeaca/docs/owner-guide.md)

## Scope
Run final acceptance on one pinned release candidate only after the linked prerequisites are closed with evidence. Track any explicit scope exclusions and preserve them in the owner handoff.

## Acceptance criteria
- [ ] Every dependency has passing evidence or an explicit documented release-scope decision; no silent waiver of required hardware/payment support.
- [ ] Pin candidate commit, environment, schema/toolchain versions and supported device/printer/provider configuration.
- [ ] CI, PostgreSQL integration, browser and physical/provider acceptance results match the candidate or include a justified delta rerun.
- [ ] End-to-end sale/payment/stock/report/receipt reconciliation and refund recovery pass across retry, restart and disconnect scenarios.
- [ ] Deployment/restore runbooks, limitations and operational ownership are current and reviewable.
- [ ] Record final acceptance decision and unresolved risks; production go-live remains a separate explicit authorization.

## Boundaries
Do not close this gate merely because implementation or CI passes. Do not expand features here; reopen/link actionable failures to prerequisite tickets.

## Planning
Priority: P1. Source: Project 19 repository audit (2026-11-15).

## Dependencies
- [ ] #66 - [P1] fix(payments): validate durable refund intents before provider side effects
- [ ] #67 - [P1] fix(printing): connect kitchen station queues to Android delivery
- [ ] #68 - [P1] fix(mobile): support bounded offline session recovery and refresh retries
- [ ] #69 - [P1] fix(api): reject unsafe production config and disable mock payment endpoints
- [ ] #70 - [P2] fix(web): repair obsolete back-office shell verification
- [ ] #71 - [P2] test(api): enforce PostgreSQL transaction and recovery regressions in CI
- [ ] #72 - [P2] test(web): retain and run owner and cashier browser regressions in CI
- [ ] #73 - [P2] docs: reconcile implementation status and deferred acceptance evidence
- [ ] #74 - [P1] qa(android): verify one real printer and kitchen delivery configuration
- [ ] #75 - [P1] qa(payments): integrate and verify a selected real provider sandbox
- [ ] #76 - [P2] qa(product): validate cashier and owner workflows with representative operators
- [ ] #77 - [P1] ops: validate deployment recovery, off-host backups and operational ownership
