# Ticket #77 execution evidence

Executed on 2026-11-16 using Node 22.23.1 and PostgreSQL client/server 17.6 on
Windows. Branch `codex/77-operations-recovery` is stacked on #75 commit b2242da
and the combined review baseline for #66/#69/#71. Main retains its review state.

The root test command passed 313 API tests, 4 web tests and 6 operations tests.
API typecheck/build passed. Prettier passed with Windows line-ending
normalization. `ticket-77-unit.txt` contains the root test run, including the
production error-redaction regression. `ticket-77-ops-unit.txt` contains the
focused operations run.

Operations unit tests exercise backup target/retention validation, remote
checksum-before-publication/retention ordering with injected transport commands,
success-marker preservation on checksum failure, local dump cleanup, child
credential redaction, isolated restore naming guards, HTTPS monitor validation,
and loopback incident/recovery/stale-backup alerts with rejected-delivery retry.
The transport-ordering test uses simulated SSH commands. Actual off-host SSH
transfer and selected-host systemd execution remain external QA items.

The actual PostgreSQL drill first migrated and seeded a fresh isolated source
and ran all 17 transaction/payment regressions. A separate empty target was
created for a real custom-format `pg_dump`/`pg_restore`. Read-only backup and
runtime roles were provisioned in that isolated cluster. The committed SQL grants
template was applied and its future-object default grants were exercised.
Runtime DML succeeded, runtime DDL and backup writes were rejected, and all
privileged backup-role flags were false.

Ten source/target table fingerprints and counts matched, including 18 sales,
18 payments, 10 reversals, 24 stock balances and 49 stock movements. Sale/payment
totals matched at 174000 minor units. Refund/online-refunded totals matched at
11000. Source fingerprints remained stable. Restore took 0.622 seconds and the
full dump/restore/verification took 2.798 seconds. A repeated restore into the
occupied target was refused. See `ticket-77-restore.txt` for complete evidence.
The dump remains in ignored local test tooling and contains synthetic data.

The operations runbook proposes hourly off-host backups, 14-day retention,
2-hour RPO and 60-minute RTO, plus minute health/freshness probes. These defaults
need operational owner acceptance. No remote host, actual alert receiver,
TLS/secret store or named operators were supplied. Their verification, encrypted
backup storage, error-log aggregation and intended-size restore timing remain
pending on #77. A local synthetic drill cannot establish the end-to-end RTO.

Production unexpected-error logging now emits a static structured event,
safe UUID and status. Raw exceptions and untrusted request identifiers are
excluded from production error logs. The unit regression supplies synthetic
secret markers and verifies their absence. Proxy/provider/collector redaction
still needs selected-environment QA.

Graphify includes source/evidence relationships for these changes as an overlay
on its recorded historical AST baseline. Final remote CI is linked in the PR
checks and issue QA handoff at the tested commit.
