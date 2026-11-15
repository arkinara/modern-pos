## Problem and evidence
The exact-revision successful CI runs fake-Prisma service tests, migrations/seed and a live health check, but does not continuously run real PostgreSQL transaction/concurrency regressions. Historical live QA exists, but later changes can regress stock/idempotency/refund boundaries without failing CI.

Audit date: 2026-11-15. Baseline revision: `d4b3ac178ef7fd03078caca70fafd32843abeaca`.
Related: #3, #10, #17, #18, #21, #22, #24, #30.

- [.github/workflows/ci.yml#L81](https://github.com/arkinara/modern-pos/blob/d4b3ac178ef7fd03078caca70fafd32843abeaca/.github/workflows/ci.yml#L81)
- [apps/api/src/sales/sales.service.test.ts](https://github.com/arkinara/modern-pos/blob/d4b3ac178ef7fd03078caca70fafd32843abeaca/apps/api/src/sales/sales.service.test.ts)
- [scripts/verify-mvp.sh](https://github.com/arkinara/modern-pos/blob/d4b3ac178ef7fd03078caca70fafd32843abeaca/scripts/verify-mvp.sh)

## Scope
Add a small committed deterministic database integration suite against the isolated CI PostgreSQL service after migrations/seed. Include the repaired refund orchestration.

## Acceptance criteria
- [ ] Concurrent distinct checkout keys cannot oversell and failed finalize transactions leave no partial sale/stock effects.
- [ ] Duplicate keys and timeout/restart recovery resolve to one sale and one stock effect.
- [ ] Online refund tests cover invalid payload, concurrent requests and provider-success/local-failure recovery using controlled provider I/O.
- [ ] Concurrent transfer receive/replay cannot duplicate stock movements.
- [ ] Suite runs as a required CI step against migrated isolated PostgreSQL; failures fail CI.
- [ ] Fixtures are synthetic, repeatable and bounded; test output includes useful operation/effect counts.

## Boundaries
Do not use production databases or substitute fake Prisma for the database assertions. Keep large performance/load runs separate from normal PR checks.

## Planning
Priority: P2. Source: Project 19 repository audit (2026-11-15).

## Dependencies
- [ ] #66 - [P1] fix(payments): validate durable refund intents before provider side effects
