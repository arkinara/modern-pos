# Operator feedback, measured baselines and ranked improvements (#28)

Status: discovery complete on a local synthetic database. No real operator or
customer is represented. Values below are either measured on the VPS with
synthetic seed data or marked `PENDING — requires real usage` with a collection
recipe. This ticket changes documentation and issue metadata only.

Source ticket: #28.
Verification date: 2026-11-14.
Synthetic database: `modern_pos_28` in the local PostgreSQL container.
API under test: `http://localhost:4100/v1` (own port).
Web under test: `http://localhost:3101` (own port).
Android app: not run because the VPS has no Android device. Cashier flows were
driven through the same HTTP endpoints the Flutter app calls.

## Method and privacy boundary

This is a structured walkthrough, not field research. It drives the back-office
web UI and the API through the same flows a cashier or owner uses, records
observations, and measures only what can be reproduced locally. It is not a
substitute for watching real staff work.

What was collected:

- HTTP status codes, response bodies, elapsed times and ledger counts from
  synthetic seed data.
- Text observations from the back-office UI while signed in as the synthetic
  `owner@example.test` and `cashier@example.test` users.
- Source locations for observed behaviour (`file:line` or endpoint).

What was NOT collected, and why:

- No customer records, customer names, phone numbers, email addresses or
  addresses. The seed data has no customers; no customer was created for this
  ticket and `customerEmail` was never sent to a quote.
- No payment-card data, provider credentials, tokens, cookies or secrets. Cash
  payments were recorded as synthetic amounts only.
- No screenshots, screen recordings, session replay, analytics or IP-address
  logs. Friction notes are textual and were taken during the walkthrough.
- No production data, production database, production backup or real operator
  identity. Synthetic identities only: `owner@example.test`,
  `cashier@example.test` and the seeded synthetic device UUID.

Data-minimization rule applied: an observation was kept only when it changed a
friction finding, a baseline value or a proposed fix. Customer-linked data was
not needed to answer any of the acceptance criteria and was therefore excluded.

## Workflows walked

| Workflow | Path used | Result |
| --- | --- | --- |
| Cashier sign-in | `POST /v1/auth/mobile/login` with synthetic cashier and seeded device UUID | 200, 600-second access token |
| Owner sign-in | `POST /v1/auth/mobile/login` and web `POST /v1/auth/web/login` | Mobile 200; web UI reached `/menu` in 2690 ms |
| Menu lookup | `GET /v1/outlets/{outletId}/menu`; web `/menu` search for `Chicken` | 2 menu items; UI search showed `Chicken Rice`; API response 30 ms or less per call |
| Sale | `POST /orders` -> `POST /orders/{orderId}/quotes` -> `POST /sales/finalize` | 10 measured checkouts, all 200 at finalize; one item per sale |
| Stock check | `GET /v1/outlets/{outletId}/stock`; web `/stock` search for `Coffee` | Three balances; search showed `Coffee Beans`; cashier history attempt returned 403 |
| Report | `GET /v1/outlets/{outletId}/reports/daily?from=2026-11-14&to=2026-11-14` and `sales.csv` | 11 completed sales, IDR 385000 payment total, 42 ms API call; CSV downloaded |
| Refund | `POST /v1/outlets/{outletId}/sales/{saleId}/reversals` | Full reversal with explicit restock; 201 in 75 ms; stock restored |
| Print | `POST /printers`, `POST /print-jobs`, `PATCH /print-jobs/{jobId}` | Printer 201; job 201 in 40 ms; `QUEUED` -> `SENT`; web Printers page still showed no printer |
| Back-office routes | Web `/menu`, `/stock`, `/sales`, `/reports`, `/printers`, `/settings`, `/promotions`, `/purchasing`, `/bookkeeping`, `/shifts`, `/attendance`, `/ordering`, `/customers`, `/audit`, `/permissions` | All returned HTTP 200; only six routes are in primary navigation |

The web route walk was performed at 1280 px width. Page load times observed in
development mode ranged from 1500 ms to 3486 ms; they are recorded as
environment observations, not as a production baseline.

## Friction log

Severity scale: High means the operator can be blocked or misled; Medium means
extra work or a confusing dead-end; Low means diagnostic or paper-cut friction.
Evidence is either an observed UI/API result or a source location.

| ID | What happened | Where | Why it hurts | Severity | Evidence type |
| --- | --- | --- | --- | --- | --- |
| F1 | Owner sees only Menu, Stock, Sales, Reports, Printers and Settings in the primary sidebar. Promotions, Purchasing, Bookkeeping, Shifts, Attendance, Online ordering, Customers, Audit search and Permissions exist but are only reachable from secondary links or a known URL. | `apps/web/components/sidebar-nav.tsx:15`; secondary links `apps/web/components/operations-links.tsx:3`, `apps/web/components/reports-screen.tsx:168`, `apps/web/components/stock-screen.tsx:546`, `apps/web/components/sales-screen.tsx:938` | An owner may never discover half the back office. Onboarding and support depend on someone knowing the route map. | High | Observed UI and code |
| F2 | Cashier sees Reports in primary navigation. Opening it issued four `GET /reports/daily` calls, each 403, and stayed in a loading state for about four seconds before showing the owner-only error. | `apps/web/components/reports-screen.tsx:116`; API guard `apps/api/src/reports/reports.controller.ts:14` | A cashier is sent into a guaranteed failure with no immediate explanation; repeated retries waste time and hide the real cause. | Medium | Observed UI and network |
| F3 | After an owner created a printer through the API, the Printers page still showed `No printer registered`. The status card is hard-coded and the page never lists printers. | `apps/web/components/printers-screen.tsx:136`; existing API `GET /v1/outlets/{outletId}/printers` | An owner cannot verify which printer, model or transport is configured. A support call can start with a false status. | High | Observed UI and API |
| F4 | Cashier sees a History button on every stock card. Clicking it called the owner-only movements endpoint and received 403. The screen then said `This account is not allowed to change outlet settings`, which names the wrong action and implies a write. | `apps/web/components/stock-screen.tsx:879`; API guard `apps/api/src/stock/stock.controller.ts:43`; wrong copy `apps/web/lib/api-errors.ts:12` | Cashiers doing stock counts hit a dead-end and receive misleading guidance. | Medium | Observed UI and network |
| F5 | Sales can only be filtered by outlet-local dates and 25-row pages. There is no reference search, so finding one receipt from a support call requires widening the dates and paging. | `apps/web/components/sales-screen.tsx:953`; `apps/api/src/sales/dto/sales-list-query.dto.ts` | Refund and support investigation slow down as sale volume grows. | Medium | Observed UI and code |
| F6 | The print-job API accepts create and state update but has no read/list endpoint, and the job response omits `printerConfigId`. An owner cannot inspect print history from the back office or API. | `apps/api/src/printing/printing.controller.ts:59`; `apps/api/src/printing/printing.service.ts:280` | Printer diagnosis depends on the Android device or database access; support cannot answer "was this receipt queued or sent?" | Low | Observed API and code |

## Baselines

All rows are synthetic. Real usage baselines are not invented; each missing value
has a collection recipe below.

| Baseline | Definition | Measurement method | Current value |
| --- | --- | --- | --- |
| Checkout time | Elapsed wall-clock time from immediately before `POST /v1/outlets/{outletId}/orders` (cart submit) until `POST /v1/outlets/{outletId}/sales/finalize` returns HTTP 200. Includes order creation, quote creation and finalize. Excludes sign-in, menu browsing and cashier tender entry. One seeded `Chicken Rice` item, cash payment, no tax or service. | 10 sequential runs on the local API and `modern_pos_28`. Timestamps taken with `date +%s%N` around the three requests; per-run total recorded in `/tmp/modern-pos-dev/checkouts.csv`. Values in milliseconds: 221, 138, 137, 124, 134, 126, 171, 146, 139, 123. | n=10; min 123 ms; median 137.5 ms; mean 145.9 ms; p95 171 ms; max 221 ms. `SYNTHETIC — local VPS, development API, no real device or network.` |
| Error rate | Unexpected non-2xx responses divided by valid scripted checkout attempts in one contiguous 10-run window. A deliberately induced validation or conflict probe is reported separately and is not counted as an unexpected error. | Same 10 runs as checkout time. Count of statuses other than 200 at finalize; `checkouts.csv` also stores order and quote statuses and the returned error code. | 0 unexpected errors / 10 attempts = 0.0%. Expected negative controls also passed: 422 `PAYMENT_INVALID`, 422 `INSUFFICIENT_STOCK`, 409 `ORDER_ALREADY_COMPLETED`; no 5xx observed. `SYNTHETIC.` |
| Stock discrepancies | Non-zero `COUNT` ledger movements created by one completed stock-count session, plus a balance-derivation check after sales. A zero variance is not written to the ledger. | Stock count posted with the current system quantities for Coffee Beans (8500 g), Fresh Milk (10000 ml) and Paper Cups (490 each); response returned three zero-variance lines and zero movements. SQL check: `SELECT count(*) FROM stock_movements WHERE type='COUNT' AND delta<>0;`. Before the count, 10 one-item sales reduced stock by exactly 1500 g, 2000 ml and 10 each, which matches 10 x the seeded recipe. | 0 non-zero variance events from 1 count session / 3 counted lines. Balance derivation matched the recipe exactly and stayed non-negative. `SYNTHETIC.` |
| Support incidents | Inbound operator-reported incidents in a rolling 30-day window, deduplicated by root cause. Excludes expected validation errors and developer-only test failures. | No support channel, CRM, help desk or `support` label exists on this VPS or repository. `gh label list` has no support label; `gh issue list --search 'support incident'` returns only this discovery ticket. | `0 observed / PENDING — requires real usage.` Collection recipe: when a real support inbox exists, export 30 days of operator contacts, tag each as incident or question, deduplicate by root cause, record severity, affected workflow and resolution time. Until then this row must not be filled with invented numbers. |

### Reproduction commands

The synthetic setup was created without changing the repository:

```bash
docker exec modern-pos-postgres psql -U pos -d postgres -c "CREATE DATABASE modern_pos_28"
DATABASE_URL='postgresql://pos:pos_local_dev@localhost:5432/modern_pos_28?schema=public' \
  pnpm --filter @modern-pos/api exec prisma migrate deploy
DATABASE_URL='postgresql://pos:pos_local_dev@localhost:5432/modern_pos_28?schema=public' \
  pnpm --filter @modern-pos/api seed
pnpm --filter @modern-pos/api build
DATABASE_URL='postgresql://pos:pos_local_dev@localhost:5432/modern_pos_28?schema=public' \
  PORT=4100 WEB_ORIGIN='http://localhost:3101,http://localhost:3001' \
  node apps/api/dist/main.js
```

Checkout and error-rate measurement used the login token from:

```bash
curl -sS -X POST http://localhost:4100/v1/auth/mobile/login \
  -H 'content-type: application/json' \
  -d '{"email":"cashier@example.test","password":"modern-pos-demo-password","deviceId":"00000000-0000-4000-8000-000000000091"}'
```

Each run then called, in order, `POST /orders` with the seeded Chicken Rice
variant and a fresh `Idempotency-Key`, `POST /orders/{orderId}/quotes` with
`{"orderVersion":1}`, and `POST /sales/finalize` with a fresh key and
`{"kind":"CASH","amountMinor":35000,"tenderedMinor":50000}`. The exact loop is
reproducible from the four commands above and the raw `checkouts.csv` values in
the table.

Stock discrepancy check:

```bash
TOKEN=$(curl -sS -X POST http://localhost:4100/v1/auth/mobile/login \
  -H 'content-type: application/json' \
  -d '{"email":"owner@example.test","password":"modern-pos-demo-password","deviceId":"00000000-0000-4000-8000-000000000091"}' \
  | jq -r .accessToken)
curl -sS -X POST http://localhost:4100/v1/outlets/00000000-0000-4000-8000-000000000002/stock-counts \
  -H "authorization: Bearer $TOKEN" -H 'content-type: application/json' \
  -d '{"reason":"synthetic exact count baseline","lines":[{"stockItemId":"00000000-0000-4000-8000-000000000050","countedQuantity":"8500"},{"stockItemId":"00000000-0000-4000-8000-000000000051","countedQuantity":"10000"},{"stockItemId":"00000000-0000-4000-8000-000000000052","countedQuantity":"490"}]}'
docker exec modern-pos-postgres psql -U pos -d modern_pos_28 -tAc \
  "select count(*) from stock_movements where type='COUNT' and delta<>0;"
```

Support-incident check:

```bash
gh label list --repo arkinara/modern-pos | grep -i support || echo "no support label"
gh issue list --repo arkinara/modern-pos --state all --search 'support incident'
```

## Ranked opportunities

Scale:
- Impact 1 = cosmetic, 2 = minor extra work, 3 = repeated friction, 4 = blocks or misleads an operator, 5 = stops a core workflow.
- Effort 1 = under half a day, 2 = half to one day, 3 = two to three days, 4 = about a week, 5 = larger than a week.
- Priority score = Impact x (6 - Effort). Higher first. Ties break toward the higher impact.

| Rank | ID | Opportunity | Impact | Effort | Score | One-line rationale |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | F3 | Show real printer configuration on the Printers page | 4 | 2 | 16 | A false "no printer" status directly misleads an owner during setup and support. |
| 2 | F1 | Expose all implemented modules in primary navigation | 4 | 2 | 16 | A whole phase of owner features is effectively undiscoverable without route knowledge. |
| 3 | F2 | Make Reports role-aware and stop retrying a 403 | 3 | 1 | 15 | A small client change removes a guaranteed four-request dead-end for every cashier. |
| 4 | F4 | Remove the cashier stock-history dead-end and fix 403 copy | 3 | 1 | 15 | The button is always visible but never works for a cashier, and the message names the wrong action. |
| 5 | F5 | Add sale-reference search to the Sales filter | 3 | 2 | 12 | Support and refund lookup become faster as sale volume grows beyond one page. |
| 6 | F6 | Add read-only print-job history for owner diagnosis | 2 | 2 | 8 | Useful for printer support, but the Android local queue already owns print execution. |

Every friction entry above appears in this ranking. No ranked item is derived
from data outside the friction log.

## Approved implementation tickets

These were created before any implementation work. They reference #28 as the
source and are not added to the project board by this ticket; the orchestrator
owns board placement.

| Issue | Friction | Title | Priority |
| --- | --- | --- | --- |
| [#56](https://github.com/arkinara/modern-pos/issues/56) | F1 | feat(web): expose every implemented back-office module in primary navigation | P2 |
| [#57](https://github.com/arkinara/modern-pos/issues/57) | F2 | fix(web): hide owner-only Reports from cashiers and fail fast on 403 | P2 |
| [#58](https://github.com/arkinara/modern-pos/issues/58) | F3 | fix(web): show real printer configuration instead of hard-coded "No printer registered" | P2 |
| [#59](https://github.com/arkinara/modern-pos/issues/59) | F4 | fix(web): remove cashier dead-end on stock movement history and correct 403 copy | P2 |
| [#60](https://github.com/arkinara/modern-pos/issues/60) | F5 | feat(web): find a sale by reference within a date range | P3 |

F6 remains a ranked, un-ticketed candidate. It is low impact relative to its
effort and the Android queue already owns print execution; it can be picked up
after the five approved tickets if printer support evidence justifies it.

## Limits of this discovery

- No real operator was observed. All friction is a developer walkthrough of the
  current UI and API.
- Checkout time is a development-mode API measurement, not a device-to-server
  measurement. It excludes the cashier's physical interaction with the Android
  app.
- The seed database has one item recipe and one small catalog. Behaviour at
  production menu size, offline conditions and multi-device contention is not
  measured here.
- The support-incident baseline is intentionally empty. It must stay
  `PENDING — requires real usage` until a real support channel produces data.
