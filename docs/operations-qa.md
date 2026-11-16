# Operations QA handoff for #77

Prepared on 2026-11-16 with Node 22.23.1 and PostgreSQL client/server 17.6.
The verified environment was an isolated Windows PostgreSQL cluster with
synthetic POS data. The deployment configuration below is a proposed Linux
staging topology. The deployment target, off-host destination, TLS domains,
secret store, alert receiver and named operators require owner input and QA
execution before operational acceptance.

## Proposed topology and objectives

Use a TLS reverse proxy in front of the API and Next.js host processes, with
PostgreSQL reachable on a private interface. Keep port 5432 private and bind
API/web listeners behind the proxy. `docker-compose.yml` supplies the existing
PostgreSQL development service. The API and web are built host processes.
Use an independent backup host reached by pinned-key SSH and an HTTPS incident
receiver. Select actual hostnames and certificate automation during staging QA.

The proposed defaults are an hourly logical backup, 14-day remote retention,
a 2-hour recovery point objective, and a 60-minute end-to-end recovery time
objective. The freshness monitor alerts after 2 hours without a verified remote
backup. These are reviewable starting values chosen for this handoff. QA must
measure the intended workload and owners must accept or revise the objectives.
A failed scheduled backup may breach the RPO. A local restore timing measures
only the synthetic database drill and cannot establish the deployment RTO.

## Installation worksheet

| Setting or responsibility | Required before staging acceptance |
| --- | --- |
| Release approval | Repository owner arkinara |
| Release operator and rollback decision contact | Named person pending |
| Database/backup operator and incident responder | Named people and escalation coverage pending |
| Provider reconciliation and credential custodian | Named people pending, coordinated with #75 |
| Actual deployment/DB topology and TLS domains | Pending owner selection |
| Secret store, SSH host-key fingerprint and encrypted backup storage | Pending infrastructure selection |
| Alert receiver and escalation routing | Pending actual notification test |
| RPO 2 hours, RTO 60 minutes, retention 14 days | Proposed defaults awaiting operational acceptance |

Provision a dedicated `pos-ops` service account and a remote backup account
restricted to its own backup directory. Verify the destination resolves to a
separate host/failure domain. Apply encrypted-at-rest storage and retention
access controls on that host. An administrator must validate directory ownership,
symlinks and the filesystem boundary before granting remote access. Pin the
verified host key in `/etc/modern-pos/backup_known_hosts` and install a dedicated
key readable by `pos-ops`. The scripts require batch SSH and strict host checking.

Create `/etc/modern-pos/backup.env` and `monitor.env` from `ops/*.env.example`,
using the secret store to supply credentials. Use root-owned files with mode 0640
and the `pos-ops` group. The alert receiver must accept the documented JSON event
and optional bearer token and route it to the assigned responder. Never include
raw exception payloads or credentials in notification bodies.

For the proposed Linux host, review and install `ops/systemd/*.service` and
`*.timer` after setting `/opt/modern-pos/current` to the pinned release path.
Units use `pos-ops`, a 0700 state directory, a restrictive umask, a read-only
system filesystem and separate secret environment files. Linux/systemd execution
is pending on the selected host. Enable the backup and monitor timers only after
the commands succeed manually in staging. Verify both timers after a reboot.

```bash
node ops/backup.mjs
node ops/monitor.mjs
systemctl enable --now modern-pos-backup.timer modern-pos-monitor.timer
systemctl list-timers modern-pos-backup.timer modern-pos-monitor.timer
```

The backup script creates a custom-format dump, uploads a `.partial` file over
SSH, compares SHA-256 on both hosts, renames the verified file and applies
retention to matching `modern-pos-*.dump` files in the dedicated directory.
The success marker advances after those operations succeed. Failed partial
uploads require operator cleanup and retry. The local transient dump is removed
on exit. Database credentials are passed in child environment variables.
Tool stderr is withheld from public logs because it may contain connection or
customer data. Investigate failures in a protected operator session.

The monitor checks the API/database health response and verified-backup age.
It sends incident and recovery events when state changes. A rejected alert is
retried on the next probe. Arrange independent monitoring of the host, timers,
monitor service and alert delivery so a stopped host can still trigger a page.
Configure the selected log collector to count structured `api_unhandled_error`
events. The proposed error threshold is 5 events in 5 minutes. Actual log
shipping, error-rate alert routing and dead-man monitoring remain staging QA
items. API production error logs contain a safe request UUID, event and status.
Unexpected exception messages/stacks and untrusted request header text are
excluded. Operations notification tests also verify response-body redaction.

## Database access and production configuration

Provision distinct migration, application runtime and read-only backup login
roles through the DBA and secret store. Fresh runtime/backup roles must have no
inherited owner/admin memberships. Apply `ops/database-grants.sql` as the database
owner with psql variables `database`, `migrator_role`, `runtime_role` and
`backup_role`. Migration-created objects must be owned by the specified migrator.
Runtime owns no schema objects and performs application DML. Backup has SELECT
access for dumps. Default privileges cover objects created by later migrations.
Limit role CONNECT and network access to the intended database through the DBA.

The local drill used the committed grants template and proved runtime DML,
rejected runtime DDL, rejected backup writes, and verified backup role flags for
superuser/database creation/role creation/replication/RLS bypass were false.
The role proof applies to the isolated test database. Verify effective privileges,
memberships and restore credentials again in staging.

Use `NODE_ENV=production` when checking the intended production-like configuration.
The existing startup validator runs before the DB connection and listener.
Provide exact HTTPS origins, secure cookies, strong unique JWT/webhook secrets,
explicit QRIS provider/mode and actual credentials. Disable sandbox routes.
The API unit tests include the production configuration failure cases. Keep
real provider acceptance pending until #75 is completed. Store secrets outside
the release tree. Configure proxy access logs to omit authorization headers,
cookies, sensitive query strings and request/response bodies. Verify selected
proxy/provider/collector redaction with synthetic markers during staging QA.

## Isolated restore and reconciliation

The committed drill requires an explicitly named source ending in
`_transaction_test` and a fresh empty target ending in `_restore_test`. It rejects
production mode and an occupied target. It creates no databases and drops no data.
An administrator pre-creates both isolated databases and provisions access.
For provider/stock fixtures, migrate and seed the source, then run `test:db`.
Use PostgreSQL 17.6 clients and pause every source writer while the drill runs.

```powershell
$env:NODE_ENV = 'test'
$env:DRILL_DATABASE_URL = '<isolated synthetic source URL>'
$env:RESTORE_DATABASE_URL = '<fresh empty restore URL>'
$env:DRILL_DUMP_FILE = '<protected local dump path>'
node ops/restore-drill.mjs
```

Optional `PG_DUMP_BIN`, `PG_RESTORE_BIN` and `PSQL_BIN` select installed client
executables. The script compares row counts and content fingerprints for sales,
lines, payment records, online payments, reversals, refund lines/intents, stock
balances/movements and the mock provider ledger. It compares financial totals
and confirms the source stayed unchanged during the drill. Results contain
counts, hashes and totals. This fingerprint approach is intended for bounded
synthetic drills and materializes table aggregates in PostgreSQL. Large-database
recovery needs measured resource limits and a DBA-reviewed reconciliation plan.

The 2026-11-16 local drill restored 18 sales, 18 payment records, 10 reversals,
24 stock balances and 49 stock movements with matching fingerprints. Source and
target each contained sale/payment totals of 174000 minor units and local
refund/online-refunded totals of 11000. Restore took 0.622 seconds and complete
dump/restore/verification took 2.798 seconds. Raw evidence is in
`graphify-out/ticket-77-restore.txt`. A second restore into the occupied target
was rejected. These timings describe the local synthetic workload.

During staging QA, download an actual verified off-host backup into a protected
restore environment and compare its published SHA-256 before restoration.
Restore to a separate database/host, grant the runtime role, start a pinned API,
check health and owner authentication, and reconcile known sale/payment/refund,
stock and reporting records. Restore credentials and owners are applied through
the target administrator because the dump omits ownership and ACLs. Record total
outage recovery time, data age, restored release/migration revision and operator.

## Release and incident runbook

1. Pin the release and migration revisions and review green CI. Record the
   operational owners and rollback decision contact. Verify a fresh off-host
   backup and its isolated restore before scheduling the release.
2. Pause writers and drain requests on every old API instance. Refund writers
   require a coordinated cutover because old code does not honor durable intents.
   Apply additive Prisma migrations using the migrator role, generate Prisma,
   then start the pinned API with the runtime role. Validate production settings,
   health, owner login, sale/stock reports and provider reconciliation in staging.
3. For an uncertain payment/refund, preserve its provider reference and original
   request key. Follow `payments.md` and `payment-acceptance.md`. Reconcile the
   provider before retrying. Assign discrepancy ownership and escalate drift.
4. For an alert, confirm the incident and timestamp, inspect the protected API,
   database, backup and service status, and notify the assigned operator. Acknowledge
   the actual alert channel. Repair or roll back the failing component, then
   confirm recovery notification and financial integrity before resuming writers.
5. To restore data, stop all writers, preserve the failing database for investigation,
   select a verified backup, restore into a fresh isolated target and complete the
   reconciliation above. Repoint applications only after owner authorization.
   Record the actual RPO/RTO and any provider events that arrived after the backup.
6. For application rollback, pause writers, pin a compatible previous release and
   retain additive schema/audit data. Keep refund ingress disabled if that version
   cannot honor durable intents. Reconcile PENDING, UNKNOWN and SUCCEEDED intents
   using the fixed version and original keys. A database rollback requires a
   separately reviewed restore/data-loss decision. Resume after health, access,
   reconciliation and alerts have been revalidated.

## QA acceptance still pending

- Selected topology/TLS/secret-store deployment and named ownership.
- Actual off-host transfer/checksum/retention and restore from that remote copy.
- Selected-host systemd schedule, process supervision, restart and permission checks.
- Real alert-channel notification/recovery, dead-man monitoring and error-rate routing.
- Intended-size recovery timing and explicit owner acceptance of RPO/RTO/retention.
- External least-privilege, encrypted backup storage and proxy/provider log-redaction checks.

Keep #77 open while QA completes these fields. The local tooling and unit/restore
evidence are ready for review. Production deployment requires separate authorization.
