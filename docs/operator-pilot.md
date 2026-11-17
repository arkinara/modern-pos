# Operator pilot protocol and measurement definitions (#76)

Status: **PROTOCOL READY; REAL OPERATOR AND OWNER OBSERVATION PENDING.**
Operator acceptance is **not established**. The runnable evidence in this
document is synthetic or developer-driven. It does not replace watching a
representative cashier and owner use the system.

Source ticket: #76. Dependencies merged: #67 `9cc95cd`, #68 `2485f8c`,
#70 `c82c32b`, #72 `d68daca`, plus #74 `ae68fe5`. Baseline for this document:
`ae68fe5` (2026-11-16).

Related records:

- `docs/operator-feedback.md` (#28): friction log and synthetic baselines.
- `docs/usability-refinement.md` (#29): before/after synthetic checks.
- `docs/performance-reliability.md` (#30): synthetic latency targets.
- `docs/browser-regressions.md` (#72): committed owner/cashier browser suite.
- `docs/hardware-acceptance.md` (#74): physical printing acceptance remains a
  separate release prerequisite and is not folded into operator acceptance.

## Honesty boundary

No representative cashier or owner was available on this VPS. Nothing in this
document invents participant feedback, support incidents, real usage numbers or
an acceptance decision.

- What this ticket delivers: a bounded pilot protocol, empty evidence slots,
  exact measurement definitions, a real accessibility sweep, a labelled
  **SYNTHETIC** walkthrough and a ranked follow-up list.
- What remains blocked: AC1, AC2, the real values behind AC3 and the actual
  AC6 decision. Each is marked `PENDING — requires participants` with the
  protocol step that fills it.
- Do not treat any synthetic timing, error rate or stock result below as a
  production service level.

## Protocol steps

1. Record participant role, consent and pseudonymous ID.
2. Record device, OS, build, browser, viewport and observation date.
3. Run S1-S5 with the script in the task-scenario section.
4. Record completion, checkout time, mistakes, stock discrepancies and support
   friction using the measurement definitions.
5. Repeat the accessibility sweep on the observed surfaces.
6. Compare observations with the #28 synthetic baseline and keep the synthetic
   label separate.
7. Rank follow-ups by impact and effort.
8. Record the owner/cashier `ACCEPT` or `DEFER` decision with evidence.

Any step not run stays `PENDING — requires participants`.

## Participant roles and consent

Minimum viable pilot: one cashier and one owner who normally perform these
tasks. A participant may stop at any time without giving a reason.

| Role | Participant ID | Tasks | Evidence slot |
| --- | --- | --- | --- |
| Cashier | `P-CASHIER-01` | S1, S2, S3, S4 | `evidence/76/<date>/P-CASHIER-01/` |
| Owner | `P-OWNER-01` | S5, plus observe S1-S4 if available | `evidence/76/<date>/P-OWNER-01/` |
| Facilitator | `F-01` | Consent, timing, notes, abort | `evidence/76/<date>/facilitator-notes.md` |

Role was represented: `[ ] cashier [ ] owner`
Observation date: `[ ] YYYY-MM-DD`
Start and end time (local, with timezone): `[ ]`
Facilitator ID: `[ ]`
Device and build recorded at S1: `[ ]`
Consent version accepted: `[ ]`

### Consent statement (read aloud before any task)

> This is a usability pilot for the Modern POS cashier and back-office flows. I
> will observe you doing normal tasks and take short written notes and timings.
> I will not record customer data, payment-card data or your personal contact
> details in the evidence. You may skip any task, stop the session or ask me to
> delete a note at any time. Your name and signature stay on a separate consent
> form outside this repository. Do you agree to take part?

Consent recorded: `[ ] yes [ ] no`  Signature stored separately: `[ ] yes`

### Data minimisation: collect and do not collect

Collect only:

- Participant role, pseudonymous ID and consent status.
- Task completion state, elapsed time, mistake count and stock-count variance.
- Device model, OS version, app build, viewport and browser version.
- Short text observations tied to a task ID.
- Unprompted help requests and their duration.

Do **not** collect in the pilot evidence:

- Customer names, phone numbers, email addresses, addresses or order history.
- Payment-card numbers, provider credentials, tokens or cookies.
- Participant names, signatures or contact details in the repository.
- Screenshots or recordings that show customer data.
- Production data, real sales exports or production database backups.

If a task needs a customer, use the seeded synthetic identity only. If a real
receipt is needed, redact every customer field before attaching it.

Rule applied: an observation is kept only when it changes a finding, a
measurement or a ranked follow-up. Everything else is discarded at the end of
the session.

## Devices, viewports and observation dates

Supported surfaces for this pilot:

| Surface | Device / viewport | Why it is supported | Evidence slot |
| --- | --- | --- | --- |
| Cashier app | Samsung Galaxy Tab A9 `SM-X110`, Android 14, selected in #74 | Selected release tablet | `[ ] model / OS / build` |
| Cashier app fallback | Participant's own Android phone, if used | Records real variance without claiming support | `[ ] model / OS / viewport` |
| Web back office | Desktop browser at 1440 px | Owner reporting and back-office work | `[ ] browser / version / width` |
| Web back office | 1024 px, 768 px and 320 px | Supported responsive widths in #72/#29 | `[ ] pass / fail per width` |

Observation dates:

- Pilot session 1: `[ ] YYYY-MM-DD`
- Pilot session 2 (repeat or second participant): `[ ] YYYY-MM-DD`
- Follow-up review date: `[ ] YYYY-MM-DD`

A different device, OS or viewport is recorded as an observed variant. It does
not extend the supported-hardware claim in `docs/hardware-acceptance.md`.

## Task scenarios

Run the tasks in order. Read the task, then stop talking. Prompt only when the
participant is blocked for more than 60 seconds or asks for help. Record
unprompted help requests separately.

### S1 — Catalog, cart and cash checkout (cashier)

Setup: signed in as cashier, catalog loaded, one table free, no pending intent.

Task: "Add one Chicken Rice and two Iced Coffee Regular to the cart. Check the
total, take cash, and complete the sale. Show me the receipt reference."

Stop when the sale confirmation or receipt reference is visible, or the
participant stops.

| Field | Evidence slot |
| --- | --- |
| Completed unaided / assisted / failed | `[ ]` |
| First item tap to confirmation (seconds) | `[ ]` |
| Wrong item, wrong quantity or voided-line actions | `[ ]` |
| Unprompted help requests / minutes lost | `[ ]` |
| Sale reference visible | `[ ]` |
| Notes | `[ ]` |

### S2 — Uncertain checkout outcome and recovery (cashier)

Setup: use a test device and the seeded synthetic catalog. Put the device in
airplane mode immediately after the cashier submits a cash sale, then restore
the network. Do not induce this on a real sale.

Task: "The till did not show a result. Use the app to find out whether the sale
was saved. Do not create a second sale for the same order."

Stop when the app shows either the recovered sale or a definitive retry path.

| Field | Evidence slot |
| --- | --- |
| Completed unaided / assisted / failed | `[ ]` |
| Time from network restore to clear state (seconds) | `[ ]` |
| Duplicate sale created (yes/no) | `[ ]` |
| Recovery screen understood (1-5, participant rating) | `[ ]` |
| Notes | `[ ]` |

### S3 — Offline capture, reconnect and sync (cashier)

Setup: airplane mode on. The catalog snapshot must already be available.

Task: "While offline, record a sale for one Chicken Rice. Reconnect and sync it.
Tell me whether the sale is pending, synced or conflicted."

Stop when the queue shows a terminal state or the participant stops.

| Field | Evidence slot |
| --- | --- |
| Completed unaided / assisted / failed | `[ ]` |
| Offline capture to queue-visible (seconds) | `[ ]` |
| Reconnect to terminal state (seconds) | `[ ]` |
| Conflict shown, if any (yes/no) | `[ ]` |
| Duplicate sale after sync (yes/no) | `[ ]` |
| Notes | `[ ]` |

### S4 — Table order, transfer and split bill (cashier, owner observes)

Setup: seeded tables T1 and T2, stock available, signed in as cashier.

Task: "Open table T1 with two Chicken Rice. Split the bill into two equal bills.
Settle the first bill with cash. Tell me what remains open."

Owner variant: repeat the transfer from T1 to T2 and confirm the audit entry.

Stop when both child bills are either settled or clearly left open.

| Field | Evidence slot |
| --- | --- |
| Completed unaided / assisted / failed | `[ ]` |
| Open table to split visible (seconds) | `[ ]` |
| First child settled (seconds) | `[ ]` |
| Second child remains open and labelled | `[ ]` |
| Transfer audit entry found by owner | `[ ]` |
| Notes | `[ ]` |

### S5 — Owner stock, sales search and daily report (owner)

Setup: signed in as owner in the back office at the participant's normal width.

Task: "Find the sale reference from S1. Record the current Coffee Beans balance,
post a stock count with the quantity you see, and export yesterday's daily
sales report as CSV."

Stop when the CSV download completes or the participant stops.

| Field | Evidence slot |
| --- | --- |
| Completed unaided / assisted / failed | `[ ]` |
| Sale found by reference (seconds) | `[ ]` |
| Stock count posted (seconds) | `[ ]` |
| Report and CSV downloaded (seconds) | `[ ]` |
| Wrong figures or wrong date observed (yes/no) | `[ ]` |
| Notes | `[ ]` |

## Measurement definitions

Every metric has one definition, one method and one evidence location. Use the
same definition in every session. Do not silently change a definition between
participants.

| Metric | Exact definition | How to measure | Where the number goes |
| --- | --- | --- | --- |
| Task completion | Per scenario, one of `UNAIDED`, `ASSISTED` or `FAILED`. `ASSISTED` means the facilitator gave any task-level hint after the 60-second block. Completion rate is `UNAIDED / attempted`. | Facilitator sheet, one row per scenario. | `S<n>.completion` |
| Operator checkout time | Wall-clock seconds from the cashier's first product tap to the sale confirmation or receipt reference becoming visible. Excludes sign-in and catalog loading. | Stopwatch or device screen recording with a visible clock. Record to 0.1 s. | `S1.checkout_seconds` |
| API checkout subset | Milliseconds for `POST /orders`, `POST /orders/{id}/quotes` and `POST /sales/finalize` in one run, as in #28. This is not the operator time. | See the synthetic script command below. | `synthetic.checkout.elapsedMs` |
| Mistakes | Count of erroneous actions the participant self-corrected or the facilitator corrected: wrong item, wrong quantity, wrong tender, duplicate submit or wrong table. Navigating back is not a mistake unless it follows an error. | Tally on the observation sheet. Do not count facilitator-induced errors from S2. | `S<n>.mistakes` |
| Stock discrepancies | Non-zero `COUNT` ledger movements written by one completed stock-count session, plus a balance-derivation check after sales. A zero variance writes no ledger row. | Run the SQL check below after S5. Expected sale deductions are recipe quantity times sold units. | `S5.stock_discrepancies` |
| Support friction | Count of unprompted help requests during a scenario and the minutes lost. A production support incident is a separate 30-day inbound-contact metric, not this pilot count. | Tally on the observation sheet. Production incidents use the #28 recipe. | `S<n>.help_requests`, `support_incidents` |

### Checkout and API definitions

Operator checkout time is the primary operator metric. The #28 baseline is an
API-only subset: order creation, quote creation and finalize for one Chicken
Rice with cash tender, measured on the VPS. Do not compare operator seconds
directly with the #28 API milliseconds. Report both and label the API subset
`SYNTHETIC`.

The reproducible synthetic script is:

```bash
docker exec modern-pos-postgres psql -U pos -d postgres \
  -c "DROP DATABASE IF EXISTS modern_pos_76" -c "CREATE DATABASE modern_pos_76"
DATABASE_URL='postgresql://pos:pos_local_dev@localhost:5432/modern_pos_76?schema=public' \
  pnpm --filter @modern-pos/api exec prisma migrate deploy
DATABASE_URL='postgresql://pos:pos_local_dev@localhost:5432/modern_pos_76?schema=public' \
  pnpm --filter @modern-pos/api seed
pnpm --filter @modern-pos/api build
(cd apps/api && DATABASE_URL='postgresql://pos:pos_local_dev@localhost:5432/modern_pos_76?schema=public' \
  PORT=4176 node dist/main.js)
node scripts/operator-pilot-synthetic.mjs
```

The script uses seeded synthetic identities only. It creates a sale, recovers it
by idempotency key, splits a two-item table order, posts an exact stock count
and reads sales and the daily report.

### Stock discrepancy check

After the participant posts the count:

```bash
docker exec modern-pos-postgres psql -U pos -d modern_pos_76 -tAc \
  "select count(*) from stock_movements where type='COUNT' and delta<>0;"

docker exec modern-pos-postgres psql -U pos -d modern_pos_76 -tAc \
  "select type, count(*) from stock_movements group by type order by type;"
```

Expected: zero non-zero `COUNT` movements when the participant enters the
quantity they see. A non-zero count is a discrepancy and must be explained from
the ledger, not assumed to be operator error.

### Support-incident definition

Production support incidents remain the #28 definition: inbound
operator-reported contacts in a rolling 30-day window, deduplicated by root
cause, excluding expected validation errors. This VPS has no support inbox, so
the value remains `PENDING — requires real usage`. The pilot's unprompted help
requests are a different, session-scoped measure and must not be reported as
production incidents.

## Facilitator procedure

### Before the session

1. Confirm the participant role and read the consent statement. Store the signed
   form outside the repository.
2. Create `evidence/76/<date>/P-<ROLE>-01/` and copy the observation template.
3. Record device model, OS, app build, browser and viewport.
4. Start from a clean seeded database/session. Confirm no other cashier is
   writing to the same outlet.
5. Read the task text exactly. Do not demonstrate the flow.

### During the session

1. Start the stopwatch at the defined start event, not when the participant
   starts reading.
2. Note mistakes and unprompted help requests on the same row as the task.
3. If the participant is blocked for 60 seconds, give one task-level hint and
   mark the task `ASSISTED`.
4. Stop a task on any safety risk, a real payment prompt or a customer-data
   screen. Record `ABORTED` and the reason.
5. Do not coach, complete fields or explain missing controls.

### After the session

1. Fill every evidence slot that was observed. Leave unobserved slots as
   `PENDING — requires participants`; do not estimate.
2. Run the stock SQL check and save the raw output.
3. Remove unneeded notes and all customer data. Keep only the minimum evidence.
4. Fill the accept/defer template with the participant and owner present.
5. Mark only observed rows. Anything not run stays `PENDING`.

### Abort criteria

Stop the task if a real customer enters the scene, a real payment is requested,
the participant asks to stop, or any customer data becomes visible. Record the
abort; do not reconstruct the result later.

## Runnable evidence executed on this host

These results are real command output from this repository on 2026-11-16. They
prove the software checks listed, not operator acceptance.

### Accessibility sweep

Committed browser suite (`apps/web/scripts/browser-regressions.cjs`), run against
the production web build and a migrated/seeded synthetic database:

```text
PASS owner navigation exposes all 15 grouped destinations
PASS all 15 navigation links expose one accessible link role and name
PASS Menu (/menu) @ 320px: accessible active route with no horizontal overflow
...
PASS navigation @ 320px: all 15 targets are at least 44px tall
PASS navigation @ 320px: keyboard focus reaches a link with a 3px visible outline
PASS contrast @ 320px: active nav 10.35:1, inactive nav 8.69:1, body 13.35:1
...
PASS navigation @ 1024px: all 15 targets are at least 44px tall
PASS navigation @ 1024px: keyboard focus reaches a link with a 3px visible outline
PASS owner /reports shows the populated daily report and definitions
PASS printer empty state is explicit and never presented as a connection failure
PASS printer populated state shows real non-secret metadata with no physical-connectivity claim
PASS printer error state shows the failure and an explicit retry action
PASS owner stock page opens the movement ledger (3 history actions)
PASS stock-history 403 copy names the read action, not an outlet settings change
PASS reference search reaches the API with outlet, date range and reference scope
PASS unknown reference shows the explicit no-match state
PASS clearing the reference restores the date-filtered sale list
PASS cashier navigation shows only the seven permitted destinations
PASS cashier direct /reports shows the owner-only state with zero report requests
PASS cashier stock page has no guaranteed-403 movement-history action
PASS cashier can still open the permitted menu route
TOTAL CHECKS 53
ALL BROWSER REGRESSION CHECKS PASSED
```

The full committed suite is described in `docs/browser-regressions.md`. It
covers keyboard reachability, 44 px navigation targets, contrast at 320 px,
accessible active routes and accessible loading/empty/error states at 320 px and
1024 px. It also checks every route at both widths for horizontal overflow.

A separate host QA sweep repeated `/menu`, `/stock`, `/sales`, `/reports`,
`/printers` and `/settings` at 320, 768, 1024 and 1440 px against seeded
synthetic data. It passed 37 checks, including no horizontal overflow, active
navigation state, local-date sale filtering, receipt detail, report figures and
CSV download. That script is a host artifact, not part of the committed suite;
the committed suite remains the reproducible baseline.

Mobile widget tests (`apps/mobile`):

```text
$ dart format --output=none --set-exit-if-changed lib test
Formatted 103 files (0 changed) in 0.92 seconds.
$ flutter analyze
No issues found! (ran in 13.3s)
$ flutter test
...
cashier_flow_test.dart: catalog fits 320px without overflow
cashier_flow_test.dart: supports 200% text at 320px without overflow
...
01:32 +150 ~3: All tests passed!
```

The 3 skips are the guarded live/device tests. The 200% text test exercises the
cashier catalog and cart at 320 px without overflow. Touch-target and contrast
checks are currently asserted for the web navigation only; a screen-by-screen
mobile target audit is a ranked follow-up below, not a claim of full coverage.

### Synthetic walkthrough transcript

Command: `node scripts/operator-pilot-synthetic.mjs` against a fresh
`modern_pos_76` database on port 4176.

```json
{"scenario":"login","synthetic":true,"cashier":200,"owner":200,"tokenType":"bearer"}
{"scenario":"catalog-search","synthetic":true,"requests":5,"menuItems":2,"elapsedMs":{"n":5,"min":26.9,"median":33.5,"mean":33.4,"p95":39.9,"max":39.9}}
{"scenario":"checkout","synthetic":true,"runs":10,"unexpectedErrors":0,"elapsedMs":{"n":10,"min":80.9,"median":86.6,"mean":106.1,"p95":256,"max":256},"definition":"create order + quote + finalize, one Chicken Rice, cash tender"}
{"scenario":"uncertain-recovery","synthetic":true,"recoverStatus":200,"recoveredReference":"SALE-ce7ba62d-d110-424f-8dfc-e36f5d0ecc67","replayStatus":200,"replayReference":"SALE-ce7ba62d-d110-424f-8dfc-e36f5d0ecc67","replaySameSale":true,"recoverElapsedMs":13,"replayElapsedMs":12.3}
{"scenario":"table-split","synthetic":true,"tableOrderId":"eeab5d6a-5c67-4832-a2c8-3d4c5369ee12","splitStatus":201,"splitElapsedMs":161.1,"originalTotalMinor":70000,"childTotalsMinor":[35000,35000],"childTotalSumMinor":70000,"childSales":2}
{"scenario":"owner-stock","synthetic":true,"stockStatus":200,"countStatus":201,"countedLines":3,"countVariance":0,"elapsedMs":{"n":2,"min":16.3,"median":16.3,"mean":19.8,"p95":23.2,"max":23.2},"movementStatus":200}
{"scenario":"owner-sales-report","synthetic":true,"salesStatus":200,"salesRows":25,"reportStatus":200,"reportSaleCount":27,"reportGrossItemSalesMinor":981000,"salesElapsedMs":26.6,"reportElapsedMs":21.8}
{"scenario":"observation-limits","synthetic":true,"humanMistakes":null,"supportFriction":null,"note":"Scripted API walkthrough has no human participant; no mistake or support-friction value is observed."}
```

This transcript is **SYNTHETIC**. It has no participant, no physical device, no
network impairment and no human mistake count. The null mistake and support
values are deliberate, not zero-valued observations.

### Comparison with the #28 synthetic baseline

| Baseline | #28 synthetic value | #76 synthetic value | Comparable? |
| --- | --- | --- | --- |
| Checkout, order + quote + finalize | n=10; min 123 ms; median 137.5 ms; mean 145.9 ms; p95 171 ms; max 221 ms | n=10; min 80.9 ms; median 86.6 ms; mean 106.1 ms; p95 256 ms; max 256 ms | Same API definition, different seeded database and run. `SYNTHETIC`, not production. |
| Unexpected checkout errors | 0/10 | 0/10 | Same definition. |
| Stock discrepancies | 0 non-zero variance from 1 session / 3 lines | 0 non-zero variance from 1 session / 3 lines | Same definition. |
| Support incidents | `0 observed / PENDING — requires real usage` | `PENDING — requires participants`; no support channel exists | Not comparable to a session help count. |

The #76 p95 is higher because one of the ten runs included a cold-path spike.
The median is lower. Neither value is a production service level. Repeat the
script and report the raw distribution, not a single best run.

## Ranked follow-ups and accept/defer decision

Ranking uses the #28 scale: Impact 1-5, Effort 1-5, score `Impact x (6 - Effort)`.
Items below come from the synthetic pass and its verification gaps, not from
participant feedback, because no participant was observed. Running the pilot is
an execution prerequisite, not a ranked follow-up.

Execution prerequisite: run the pilot with a representative cashier and owner
and fill every evidence slot. Until that happens, operator acceptance remains
`PENDING — requires participants`.

| Rank | Follow-up | Impact | Effort | Score | Source |
| --- | --- | --- | --- | --- | --- |
| 1 | Extend automated touch-target and contrast assertions from web navigation to every cashier and owner screen | 4 | 2 | 16 | Accessibility sweep covers navigation only; mobile 200% test covers one screen |
| 2 | Add a device-level S2/S3 drill with a real network toggle to the release checklist | 4 | 2 | 16 | Synthetic recovery is API-only; no device network toggle was observed |
| 3 | Add a screen-reader pass on the three highest-traffic screens (catalog, cart, reports) | 4 | 3 | 12 | No assistive-technology session was run |
| 4 | Add read-only print-job history for owner diagnosis (F6 from #28) | 2 | 2 | 8 | #28 deferred item; unchanged by this ticket |

Tie-break: higher impact first. The actual ranking may change after real
observation; do not treat this order as final.

### Accept/defer template

Fill one row per follow-up after the pilot. `ACCEPT` requires an owner decision
and an evidence path. `DEFER` requires a reason and a review date. Until then the
decision is `PENDING — requires participants`.

| Follow-up | Decision (`ACCEPT` / `DEFER` / `PENDING`) | Decided by (participant ID / role) | Date | Evidence path | Rationale |
| --- | --- | --- | --- | --- | --- |
| Pilot execution | `PENDING — requires participants` | `[ ]` | `[ ]` | `[ ]` | Operator acceptance is not established yet. |
| 1. Full touch-target sweep | `[ ]` | `[ ]` | `[ ]` | `[ ]` | `[ ]` |
| 2. Device offline drill | `[ ]` | `[ ]` | `[ ]` | `[ ]` | `[ ]` |
| 3. Screen-reader pass | `[ ]` | `[ ]` | `[ ]` | `[ ]` | `[ ]` |
| 4. Print-job history | `[ ]` | `[ ]` | `[ ]` | `[ ]` | `[ ]` |

Final operator acceptance decision: `PENDING — requires participants`.

Sign-off statement to complete after the pilot:

> We observed `[ ]` cashier and `[ ]` owner sessions on `[ ]` dates using the
> protocol in this document. The evidence is stored at `[ ]`. Based on that
> evidence we `[ ] ACCEPT / [ ] DEFER` operator acceptance. This decision does
> not cover physical printing, which remains `PENDING` under #74.

## What establishes operator acceptance

Operator acceptance is established only when all of the following exist:

1. At least one representative cashier and one representative owner complete the
   consent process and the task scenarios on the supported surfaces.
2. Every AC1/AC2 field is filled from observation, not inference.
3. Checkout time, mistakes, stock discrepancies and support friction use the
   definitions above and have raw evidence attached.
4. The accessibility sweep is repeated on the observed device and browser.
5. The owner and cashier record `ACCEPT` or `DEFER` with a date and evidence.

Until then:

- Real observations: `PENDING — requires participants`.
- Real checkout, mistake, stock and support numbers: `PENDING — requires
  participants`.
- Operator acceptance: **not established**.
- Physical printing acceptance: still `PENDING` under #74.
