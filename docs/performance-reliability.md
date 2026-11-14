# Performance and operational reliability from measured evidence (#30)

Status: `IMPLEMENTED on a synthetic local database; real production traffic PENDING — requires real usage`.

Source ticket: #30. Depends on #28 (`docs/operator-feedback.md`). This document
records the targets, the measurements that produced them, the bottleneck found,
the code changes, the bounded load and failure tests, and the no-regression
proofs. No production traffic, customer data, payment credentials or real
operator was observed.

## Honesty boundary

All values below were measured on this VPS against the seeded synthetic database
`modern_pos_30`. They are not production service levels. Every target is derived
from a command and raw numbers in this document. The only value that remains
unknown is production p95 under real load, which is marked
`PENDING — requires real usage` with a collection recipe at the end.

Caps used because the VPS is shared and has about 7.7 GB free disk:

- 40 checkouts per load run, 6 concurrent cashier workers.
- 20 report requests at concurrency 4.
- 20 checkout-recovery requests at concurrency 4.
- 20 print-job enqueues at concurrency 4.
- One kill/restart failure run with 12 concurrent finalize requests.

## Environment

| Item | Value |
| --- | --- |
| OS | Ubuntu 24.04 arm64 |
| Node / pnpm | 22.23.1 / 9.12.3 |
| PostgreSQL | 17.6-alpine container `modern-pos-postgres` |
| Database | `modern_pos_30` (migrated and seeded from `apps/api/prisma`) |
| API | `apps/api/dist/main.js`, own port `4110`, detached |
| Data | Synthetic seed only: 2 businesses, 3 outlets, 3 stock items, 2 menu items |
| Date | 2026-11-14 |

Each phase starts from `prisma migrate reset --force --skip-generate`, so the
seed is identical. The baseline was taken on `main` (`e73a513`); the after run
and the failure run were taken on `feat/30`.

## Targets and measured results

Definitions:

- **Finalize p95**: wall-clock time for `POST /outlets/{id}/sales/finalize`
  under 6 concurrent cashier workers doing order, quote and finalize. Failed
  attempts are included; a 503 after retry exhaustion is a failure, not a fast
  success.
- **Report p95**: wall-clock time for
  `GET /outlets/{id}/reports/daily?from=2026-01-01&to=2026-12-31` at
  concurrency 4 over the loaded range.
- **Sync recovery p95**: wall-clock time for
  `GET /outlets/{id}/checkout-requests/{key}?deviceId=` at concurrency 4 after
  the load.
- **Print-job enqueue p95**: wall-clock time for `POST /outlets/{id}/print-jobs`
  at concurrency 4.

| Target | Baseline (main) | After (feat/30) | Chosen target | Rationale |
| --- | --- | --- | --- | --- |
| Sale finalize p95 at 6 concurrent | p95 529.2 ms; **7/40 = 17.5% retry-exhausted 503**; throughput 6.20 sales/s | p95 706.3 ms; **0/40 failures**; throughput 6.94 sales/s | p95 <= 750 ms and 0 retry-exhausted 503 | 706 ms is the observed p95 with zero failures. The target allows 6% headroom below 750 ms and forbids the reliability failure seen on main. |
| Daily report p95 at concurrency 4 | 93.7 ms | 89.1 ms | <= 120 ms | Observed after value with headroom on a shared VPS. The report query is index-backed and not the main bottleneck. |
| Checkout recovery p95 at concurrency 4 | 57.9 ms | 55.9 ms | <= 100 ms | Observed after value with headroom. No query change was required. |
| Print-job enqueue p95 at concurrency 4 | 78.1 ms | 69.8 ms | <= 120 ms | Observed after value. Enqueue had four sequential scoped reads before this change. |
| Checkout flow p95, order + quote + finalize | 1061.4 ms | 1022.1 ms | <= 1200 ms | Observed after value for the full three-request flow under the same load. |

The checkout failure rate is the decisive change: main rejected 7 of 40 valid
checkouts with `503 TRANSACTION_RETRY_EXHAUSTED` under six concurrent cashiers.
The branch completes 40 of 40.

## Bottleneck and profile evidence

### Serialization retries exhausted at three attempts

The database log during the baseline run shows PostgreSQL serialization
failures on the stock lock and on the sale insert, followed by the API turning
the third failure into `503 TRANSACTION_RETRY_EXHAUSTED`:

```text
ERROR:  could not serialize access due to read/write dependencies among transactions
DETAIL: Reason code: Canceled on identification as a pivot, during conflict out checking.
STATEMENT:
  SELECT "stockItemId", "quantity", "version"
  FROM "stock_balances"
  WHERE "outletId" = $1::uuid
    AND "stockItemId"::text IN ($2,$3,$4)
  ORDER BY "stockItemId"
  FOR UPDATE
```

```text
ERROR:  could not serialize access due to read/write dependencies among transactions
DETAIL: Reason code: Canceled on identification as a pivot, during write.
STATEMENT: INSERT INTO "public"."sales" (...)
```

Profiling method: the API writes normal access logs; PostgreSQL container logs
were read with `docker logs modern-pos-postgres`. The failures come from the
expected SSI conflicts between concurrent checkouts that read and write the same
three stock balance rows. The existing row locks plus balance-version CAS keep
stock correct, but a SERIALIZABLE transaction can still be aborted by SSI and
must be retried. The code retried only three times with a fixed 20 to 40 ms
sleep, which was shorter than the time competing transactions needed to finish.

Conclusion: the bottleneck was the retry policy, not a missing index or a slow
single query. The isolation level and the money/stock rules were not changed.

### Report query is index-backed

`EXPLAIN (ANALYZE, BUFFERS)` for the report's sale scan showed an index scan on
`sales_businessId_outletId_completedAt_idx` with 0.192 ms execution time on the
loaded synthetic database. The daily report was assembled from independent sale
and reversal reads. Those two reads were executed sequentially even though they
are independent.

### Print-job enqueue did independent reads sequentially

`createJob` performed the outlet check, sale lookup, printer lookup and
idempotency lookup one after another. The sale, printer and idempotency reads
are independent and are now issued together.

## Changes

| File | Change | Reason |
| --- | --- | --- |
| `apps/api/src/sales/sales.service.ts` | `MAX_TRANSACTION_ATTEMPTS` 3 -> 6; retry sleep is now bounded exponential backoff with jitter (20, 40, 80, 160, 250 ms caps plus 0-24 ms jitter). | Canonical SERIALIZABLE retry handling. Six attempts cover the measured contention window; jitter prevents retry cohorts from colliding again. No isolation, money or stock rule changed. |
| `apps/api/src/reports/reports.service.ts` | Sale and reversal reads in `loadPeriod` now run in `Promise.all`. | Independent read-only queries; removes one serial round trip from every report. |
| `apps/api/src/printing/printing.service.ts` | Sale, printer and idempotency reads in `createJob` now run in `Promise.all`; validation order is unchanged. | Independent scoped reads; removes two serial round trips from enqueue. |
| `apps/api/src/sales/sales.service.test.ts` | Test title "three attempts" -> "six attempts"; assertion `attempts === 3` -> `attempts === 6`. | Mechanical update to the changed retry bound. The same test still proves retry exhaustion produces the same retryable 503; no test was deleted or weakened. |
| `scripts/perf-load-30.mjs` | Bounded synthetic load and idempotent replay script. | Reproducible before/after measurement. |
| `scripts/perf-failure-30.mjs` | Kill mid-load, restart, recover and replay script. | Reproducible failure-recovery evidence. |

Web and mobile behaviour is untouched. No root document, OpenAPI file or
migration was changed. No database index was added because the report query is
already index-backed.

## Reproduction

Build and start a fresh test database:

```bash
DATABASE_URL='postgresql://pos:pos_local_dev@localhost:5432/modern_pos_30?schema=public' \
  pnpm --filter @modern-pos/api exec prisma migrate reset --force --skip-generate
pnpm --filter @modern-pos/api build
DATABASE_URL='postgresql://pos:pos_local_dev@localhost:5432/modern_pos_30?schema=public' \
  PORT=4110 WEB_ORIGIN='http://localhost:3102,http://localhost:3001' \
  node apps/api/dist/main.js
```

Load run (writes `/tmp/modern-pos-dev/load30-<label>.json`):

```bash
SALES_TOTAL=40 SALES_CONCURRENCY=6 \
REPORT_REQUESTS=20 REPORT_CONCURRENCY=4 \
RECOVERY_REQUESTS=20 RECOVERY_CONCURRENCY=4 \
PRINT_REQUESTS=20 PRINT_CONCURRENCY=4 \
node scripts/perf-load-30.mjs after
```

Baseline command is identical, run against `main` before the change. Reset the
database before each phase.

Failure recovery:

```bash
DATABASE_URL='postgresql://pos:pos_local_dev@localhost:5432/modern_pos_30?schema=public' \
  API_PID=$(cat /tmp/modern-pos-dev/api30.pid) API_PORT=4110 \
  FAILURE_REQUESTS=12 FAILURE_CONCURRENCY=12 \
  node scripts/perf-failure-30.mjs
```

## Before and after load results

Baseline (`main`, fresh database):

```text
sales: completed 33/40, throughput 6.20/s, wall 5320.3 ms
  finalize: n=40 errorCount=7 p50=380.5 ms p95=529.2 ms max=612.6 ms
  failures: 7 x 503 TRANSACTION_RETRY_EXHAUSTED
  checkoutFlow: p50=623.0 ms p95=1061.4 ms
reports: n=20 errorCount=0 p50=68.3 ms p95=93.7 ms
recovery: n=20 errorCount=0 p50=48.8 ms p95=57.9 ms
printEnqueue: n=20 errorCount=0 p50=55.4 ms p95=78.1 ms
```

After (`feat/30`, fresh database, same configuration):

```text
sales: completed 40/40, throughput 6.94/s, wall 5759.6 ms
  finalize: n=40 errorCount=0 p50=320.1 ms p95=706.3 ms max=728.0 ms
  failures: none
  checkoutFlow: p50=585.4 ms p95=1022.1 ms
reports: n=20 errorCount=0 p50=64.6 ms p95=89.1 ms
recovery: n=20 errorCount=0 p50=41.4 ms p95=55.9 ms
printEnqueue: n=20 errorCount=0 p50=51.1 ms p95=69.8 ms
replay: 10 requests, 0 errors, uniqueSaleIds=10, p95=68.2 ms
```

The after p95 for finalize is higher than the baseline p95 because the baseline
mixed 7 fast 503 failures into the sample. The after run has no failures and
higher throughput. The target is stated as p95 and zero failures together so a
fast rejection cannot be mistaken for a good result.

A second after run on a freshly reset database produced finalize p95 627.3 ms,
max 933.0 ms, throughput 6.81 sales/s and 0/40 failures. This confirms the
0-failure result is reproducible and that the 706.3 ms p95 is within normal
shared-VPS variance, not a one-off.

## Failure-recovery transcript

Real process kill and restart, not a simulation claim. The script starts 12
finalizes, sends `SIGKILL` to the API 200 ms later, waits for the process to
disappear, starts `node apps/api/dist/main.js` again, waits for `/health`, then
resolves every key through `GET checkout-requests/{key}` before retrying.

```text
killedAt: 2026-11-14T15:39:33.789Z
healthyAfterRestart: true
requests: 12
in-flight outcomes: 1 x HTTP 200, 11 x network error
committedBeforeRestart: 1
notCommittedRetried: 11
finalFailures: 0
changedSaleOnReplay: 0
```

Interpretation:

- The one sale that committed before the kill is found by recovery and its
  finalize replay returns the same sale (`replayed: true`).
- The 11 keys without a committed sale return `404` from recovery; resubmitting
  the same key and payload succeeds exactly once each.
- No key produced a different sale id on replay.
- After restart the database has no torn checkout reservation:

```sql
SELECT count(*) FROM checkout_requests WHERE "saleId" IS NULL;
-- 0
```

Print-job state is not a server worker queue. The API mirrors device-owned jobs;
the load created 20 jobs in the default `QUEUED` state and no job was left in
`SENDING` or `FAILED`:

```sql
SELECT count(*) FROM print_jobs WHERE state IN ('SENDING','FAILED');
-- 0
```

## No-regression proofs

All queries ran after the final load run and the kill/restart run.

### 1. Stock integrity

Balances equal the sum of movements per outlet and stock item, and no balance is
negative:

```sql
SELECT count(*) FROM (
  SELECT b."outletId", b."stockItemId", b.quantity, COALESCE(SUM(m.delta),0) AS ledger
  FROM stock_balances b
  LEFT JOIN stock_movements m
    ON m."outletId" = b."outletId" AND m."stockItemId" = b."stockItemId"
  GROUP BY 1,2,3
  HAVING b.quantity <> COALESCE(SUM(m.delta),0)
) d;
-- 0

SELECT count(*) FROM stock_balances WHERE quantity < 0;
-- 0
```

Per stock item on the main outlet:

```text
StockItem ...050  quantity 2200.000000  ledger 2200.000000  diff 0.000000
StockItem ...051  quantity 1600.000000  ledger 1600.000000  diff 0.000000
StockItem ...052  quantity  448.000000  ledger  448.000000  diff 0.000000
```

Mismatch count: **0**.

### 2. Sale idempotency

Every checkout key maps to exactly one sale, every order has at most one sale,
and there are no duplicate checkout keys:

```sql
SELECT count(*) FROM (
  SELECT "orderId" FROM sales GROUP BY 1 HAVING count(*) > 1
) d;
-- 0

SELECT count(*) FROM (
  SELECT "outletId","deviceId","idempotencyKey"
  FROM checkout_requests GROUP BY 1,2,3 HAVING count(*) > 1
) d;
-- 0

SELECT count(*) AS checkout_rows,
       count(DISTINCT "saleId") AS mapped_sales,
       count(DISTINCT ("outletId","deviceId","idempotencyKey")) AS distinct_keys
FROM checkout_requests WHERE "saleId" IS NOT NULL;
-- 54 | 54 | 54
```

Idempotent replay inside the load: 10 completed finalize requests were repeated
with the same key and payload; all 10 returned `200` with `replayed: true`, 0
errors, and `uniqueSaleIds = 10`. No replay created a second sale.

### 3. Historical report reconciliation

Hand-computed total from sale rows in the loaded range:

```sql
SELECT count(*) AS sales,
       COALESCE(SUM("subtotalMinor"),0) AS gross_subtotal,
       COALESCE(SUM("totalMinor"),0) AS gross_total
FROM sales
WHERE "businessId"='00000000-0000-4000-8000-000000000001'
  AND "outletId"='00000000-0000-4000-8000-000000000002'
  AND state='COMPLETED'
  AND "completedAt" >= '2025-12-31 17:00:00+00'
  AND "completedAt" <  '2026-12-31 17:00:00+00';
-- 53 | 1891000 | 1891000
```

API report for `2026-01-01` through `2026-12-31`:

```text
status 200
saleCount 53
reversalCount 0
grossItemSalesMinor 1891000
netItemSalesMinor 1891000
averageBillMinor 35679
paymentBreakdown: CASH 1891000, MANUAL_EXTERNAL 0, ONLINE 0
```

The API `saleCount` equals the SQL row count (53), `grossItemSalesMinor` equals
the SQL subtotal sum (1,891,000), and the average bill is
`half_up(1891000 / 53) = 35679`. There are no reversals in this run, so net
equals gross.

## Real usage targets — not set here

Production p95 under real concurrent cashier and report traffic, and the real
checkout failure rate, are `PENDING — requires real usage`. The synthetic run on
one VPS cannot substitute for a real device, network and multi-outlet load.

Collection recipe:

1. Instrument the API with request duration and error-code metrics per route:
   `POST /sales/finalize`, `GET /reports/daily`, `GET /checkout-requests/{key}`
   and `POST /print-jobs`.
2. Record p50, p95 and p99 plus the count of 503 `TRANSACTION_RETRY_EXHAUSTED`
   and other 5xx responses in a rolling 7-day window per outlet.
3. Record real concurrent cashier count and the top stock items by checkout
   volume, because same-item checkouts are the measured contention source.
4. Compare the production p95 against the local targets above. Do not replace
   these local targets with invented production numbers.

## Limits

- The seed has one checkout recipe and three stock items. Contention on many
  distinct stock items and larger catalogs is not measured.
- One API process and one local PostgreSQL container are used. Multi-instance
  deployment and network latency are not measured.
- Failure recovery kills the API process. PostgreSQL itself stays up; database
  failover is out of scope for this ticket.
- Web and Android UI were not changed or re-timed; the measured endpoints are the
  same ones they call.
