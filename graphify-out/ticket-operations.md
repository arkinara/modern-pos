## Problem and evidence
The existing staging dry run does not establish production operations. Known limitations include absent automated off-host backup/retention, monitoring/alerting and production TLS/secret management. Logical restore documentation is useful historical evidence, not a current recovery objective.

Audit date: 2026-11-15. Baseline revision: `d4b3ac178ef7fd03078caca70fafd32843abeaca`.
Related: #18, #30.

- [docs/staging-setup.md](https://github.com/arkinara/modern-pos/blob/d4b3ac178ef7fd03078caca70fafd32843abeaca/docs/staging-setup.md)
- [docs/backup-restore.md](https://github.com/arkinara/modern-pos/blob/d4b3ac178ef7fd03078caca70fafd32843abeaca/docs/backup-restore.md)
- [docs/known-limitations.md](https://github.com/arkinara/modern-pos/blob/d4b3ac178ef7fd03078caca70fafd32843abeaca/docs/known-limitations.md)

## Scope
Prepare and verify the intended deployment configuration and operational runbook using staging/isolated restore targets before any production authorization.

## Acceptance criteria
- [ ] Document deployment topology, TLS, secrets, migration/rollback approach and named operational ownership.
- [ ] Set explicit recovery objectives, schedule off-host backups with retention, and prove an isolated restore with sale/stock/payment reconciliation.
- [ ] Configure health/error monitoring and actionable alerts; exercise a controlled failure and record the notification/recovery.
- [ ] Verify least-privilege access and redacted logs, and enforce production config checks.
- [ ] Runbook covers provider reconciliation and failure recovery, backup restore and release rollback.
- [ ] Attach dated environment/version, restore timing and integrity evidence; leave unresolved infrastructure requirements open.

## Boundaries
Do not deploy to production, move production data or change external infrastructure without the applicable authorization. This ticket prepares and verifies a reviewable release configuration.

## Planning
Priority: P1. Source: Project 19 repository audit (2026-11-15).

## Dependencies
- [ ] #69 - [P1] fix(api): reject unsafe production config and disable mock payment endpoints
- [ ] #71 - [P2] test(api): enforce PostgreSQL transaction and recovery regressions in CI
