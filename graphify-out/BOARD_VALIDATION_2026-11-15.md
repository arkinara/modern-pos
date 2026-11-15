# Modern POS — Project 19 validation

Date: 2026-11-15. Repository revision: `d4b3ac178ef7fd03078caca70fafd32843abeaca`.
Board: https://github.com/users/arkinara/projects/19/views/1

## Assessment

Substantial implementation exists for the planned modules. All 35 project items are Done and all associated issues are closed. The current CI run passes at this exact revision. This supports implementation progress, but does not establish operational acceptance of every ticket. Physical printer output, Android field behaviour, actual QRIS-provider integration and representative operator feedback are explicitly pending.

This review used the live project item list, current issues, selected closure comments, CI job steps, repository source, existing verification documents and focused local reproductions. It did not modify product code or GitHub issues. Board snapshots include the whole project; the saved view's filters were not inspected.

## Findings and recommendations

### 1. P1 — Provider refunds occur before reversal validation and durable recording

Related: #17, #21, #22.

`apps/api/src/sales/sales.service.ts:1589` calls `refundForReversal` before entering the serializable transaction. `applyReversal` subsequently validates sale state, prior refunds, line membership, remaining quantities and restock eligibility, and only then inserts the reversal (`:1764`, `:1861`, `:1930`, `:1969`). The provider operation is outside database rollback.

Reproduced with the unchanged `reverse` and `applyReversal` source methods and mocked I/O: request a partial online refund using a validly shaped line ID that does not belong to the sale. Observed order: **provider refund accepted → database transaction → API rejects REFUND_LINE_NOT_FOUND**. No reversal is inserted. This proves the unsafe orchestration; no live money or database was involved. A crash or database rejection after provider success has the same missing-durable-record risk. Retrying the same key helps provider deduplication but does not repair a permanently invalid reversal request.

Recommendation: validate and durably reserve a refund intent, bound to the normalized request hash and remaining refundable amounts, before the provider operation. Use the durable intent's stable key for the provider call and reconcile ambiguous outcomes to completion. Do not hold a database transaction open across a network request as the sole fix. Add invalid-line, invalid-restock, provider-success/database-failure, restart and concurrent-refund regressions.

Reproduce: `node graphify-out/validate-refund-order.mjs`.

### 2. P1 — Kitchen station queues have no application delivery consumer

Related: #25.

Station routing, queue persistence and manual state endpoints exist (`apps/api/src/printing/station-routing.service.ts:272`, `:374`, `:417`). The web stations panel and shared client expose these APIs. However, searches of mobile application source found no station-job API calls, StationJob consumer, kitchen-ticket renderer or station dispatch flow. The mobile `PrintQueueService` processes sale receipts, not server station jobs. No server worker links station jobs to transport writes either.

This is a source-traced integration gap, separate from the acknowledged lack of real hardware. Creating API records and sending an unrelated test receipt to a loopback socket do not demonstrate delivery of a routed kitchen job. The documented physical amendment/cancellation recipe currently lacks the application path needed to execute it.

Recommendation: connect order creation/amendment/cancellation to durable station events; implement an Android station consumer, ticket rendering and printer selection; atomically claim each job so two consumers cannot send it together. Preserve UNKNOWN after an interrupted write and require an explicit COPY decision. The present retry endpoint accepts UNKNOWN and changes it to QUEUED, so define and test the uncertain-delivery policy before adding automatic consumers.

Acceptance: an actual app order routes to two fake transports, then AMEND/CANCEL tickets retain the order reference; disconnect/restart does not silently duplicate production tickets. Hardware acceptance follows separately.

### 3. P1 — Offline capture cannot be resumed from an offline cold start

Related: #19, #4, #12.

`apps/mobile/lib/features/auth/auth_controller.dart:36` restores a session exclusively through an online refresh. Any Dio network failure returns null (`:72-76`); `apps/mobile/lib/app.dart:32` then shows only SignInScreen. No persisted offline-authenticated profile or cached catalog was found; the catalog repository reads the API. Therefore restarting the app during an outage blocks access to the cashier and offline queue UI, even though queued payloads themselves are durable. This conclusion is source-traced, not an Android runtime reproduction.

The timed session refresh also schedules its next timer only on success; a transient non-401 network failure leaves no scheduled refresh retry. A later authenticated request can reach expiry and clear the session.

Recommendation: explicitly choose the supported offline session policy. If restart-capable offline sales are required, implement a bounded offline authorization lease, a persisted scoped catalog/settings snapshot and controlled queue access, plus reconnect refresh retries. Do not bypass authentication unconditionally. Otherwise narrow the product promise to offline capture within an already-running authenticated session. Add restart-with-network-down and refresh-outage/reconnect tests.

### 4. P1 before production — Development defaults do not fail closed

Related: #4, #18, #22.

`auth.config.ts:46-50` defaults to a committed development JWT secret and non-secure cookies. `payment-config.service.ts:8` defaults to MOCK. `SandboxProviderController` registers public create/read/event endpoints and only checks whether MOCK is selected; no production environment gate was found. Its event endpoint returns a correctly signed mock webhook for a chosen payment reference. These behaviours are useful in local testing but dangerous if the same configuration reaches a public deployment. This is a deployment safeguard gap, not evidence that a production instance is currently exposed. JWT validation also checks database sessions, so this review does not claim arbitrary impersonation from the default secret alone.

Recommendation: add production startup validation for secrets, cookie security and explicit origins/provider selection. Disable sandbox controllers in production independently of the selected provider; require explicit local/test opt-in. Verify production startup rejects missing/placeholder configuration. Real QRIS-provider selection and certification remain separate pending work; the current generic adapter plus mock lifecycle are not that proof.

### 5. P2 — A documented shell verification command is broken

Related: #5, #56, #29.

`node apps/web/scripts/verify-shell.cjs` fails at line 21 with `navigation labels and order changed`. It parses inline labels from SidebarNav and expects the obsolete six labels. Navigation definitions now live in `apps/web/lib/back-office-nav.ts` and correctly contain 15 owner destinations. Restore the check against the current grouped/role-aware behaviour; do not revert the new navigation to satisfy it. Review the rest of this legacy script for assertions against page wrappers that now delegate to screen components.

The four current web unit tests pass, but they cover navigation definitions and money formatting, not rendered Reports/printer/history behaviour. This is not evidence that the new navigation itself is broken.

### 6. P2 — Database and browser regression evidence is not continuously enforced

Related: #3, #10, #18, #21-#30, #56-#60.

The successful current workflow runs service unit tests with fake Prisma boundaries, migration/seed checks and a live health check. It does not run `scripts/verify-mvp.sh`, real PostgreSQL transaction/concurrency regressions, browser tests or the shell check. Test documents reference scripts such as `qa29-verify.cjs` that are not committed in this checkout. Historical PR evidence remains useful, but cannot catch later drift automatically. The refund finding demonstrates a boundary that isolated payment and sales tests do not cover together.

Recommendation: commit a small deterministic PostgreSQL integration suite covering concurrent finalize/stock contention, idempotency, refunds and transfers; run it after migrations against an isolated CI database. Retain and run a small browser suite for owner/cashier access, outlet switching and the #56-#60 fixes. Keep large performance/failure runs separate from normal PR latency as appropriate.

### 7. P2 — Board completion obscures unresolved acceptance work and stale documentation

All 35 items are Done. Selected issue closure comments explicitly acknowledge hardware/provider deferrals (#15, #18, #22, #25) and synthetic-only feedback (#28, #30). These are acknowledged limits, not evidence of fabricated hardware verification. Nevertheless, there are no open board items that own these remaining gates.

Recommendation: retain completed implementation history, but create linked acceptance tickets for (a) one exact Android/printer/transport combination and disconnect/restart paper checks; (b) selected real payment-provider sandbox lifecycle and reconciliation; (c) representative cashier/owner field validation; (d) production configuration, off-host backup/restore and deployment operations. Make a final release acceptance ticket depend on these and the P1 fixes. Use separate implementation and acceptance evidence fields/statuses.

README still describes a planning-only repository. Many issue bodies still say implementation has not started and retain unchecked acceptance criteria despite completion comments. `docs/known-limitations.md` still says LAN/USB are not implemented even though their adapters exist; another row assigns production rollout to #20, which is actually tables/split bills. Update these statements and link each closed ticket to its exact evidence and explicit exclusions. These documentation errors should not be treated as proof that all underlying implementations are missing.

## Board-to-source coverage

This is a coverage map, not a claim that every acceptance criterion was independently executed today.

| Board items | Implementation/evidence inspected | Assessment |
| --- | --- | --- |
| #1-#3 architecture/design/scaffold | Architecture, OpenAPI, workspace packages, CI, design and handoff documents | Implementation present; refresh stale status and preserve visual/hardware limits |
| #4-#5 auth/settings/back-office | Guards, session/JWT handling, settings and navigation | Present; production defaults and offline session behaviour need work |
| #6-#8 catalog/stock/recipes | Catalog, stock and recipe modules, models and tests | Present; no new independent live database acceptance in this review |
| #9-#10 sale/atomic stock | Sales transaction, serializable retry and stock consumption paths; CI and #30 evidence | Present; continuous PostgreSQL regression coverage recommended |
| #11-#12 cashier/checkout | Flutter catalog/cart/checkout, persistent intent and recovery paths | Present; offline session limits and device testing remain |
| #13-#14 stock/sales/reports web | Screen components, service/query paths and #29 evidence | Present; preserve browser checks |
| #15-#16 receipt connection/queue | Transport adapters, queue service, hardware validation records | Candidate implementation; zero hardware-supported models documented |
| #17 reversals | Sales reversal source and reproduction | Provider ordering defect affects online reversals added in #22 |
| #18 MVP/staging gate | CI, smoke script, staging/limitations documents and closure comment | Historical synthetic staging evidence; hardware and production gates outstanding |
| #19 offline | Encrypted store, sync state machine, auth startup and catalog paths | Queue persists; app cold start still needs network authentication |
| #20 tables/split bills | Sales/table APIs, Flutter table gateway/controller, tests and limits | Implemented; physical multi-device field evidence pending |
| #21 promotions/refunds | Pricing/approval/refund modules and tests | Present; online refund orchestration needs repair |
| #22 payments | Provider config/adapters, webhook/refund service, tests and closure | Mock lifecycle verified historically; actual provider acceptance pending |
| #23 shifts/attendance/roles | Operations modules, permission matrix and known limitations | Present; physical device and real operating validation pending |
| #24 purchasing/transfers | Purchasing service/logic/tests and documented limits | Present; preserve PostgreSQL concurrency proofs |
| #25 kitchen/transports | Station API and client, mobile source, transport records | API queue/adapters present; station execution integration missing |
| #26 multi-outlet/bookkeeping | Outlet/bookkeeping modules, web screens and reporting documents | Source coverage present; independent live reconciliation not rerun |
| #27 ordering/customers/receipts | Ordering, customer and receipt modules, retention and limitations | Present; third-party credentials, email/SMS delivery and purge scheduling pending |
| #28-#30 feedback/usability/reliability | Measured synthetic documents, source, load/failure scripts and closure evidence | Useful synthetic evidence; real operator and production observations remain pending |
| #56-#60 navigation/access/printer metadata/stock copy/reference search | Navigation definitions, Reports gating, printer listing, stock copy and server reference filter | Changes present; 4 pure web tests pass, legacy shell check fails, browser evidence not in CI |

## Verification performed

| Check | Result |
| --- | --- |
| Live board snapshot | 35/35 Done; associated issues closed |
| Revision identity | Local HEAD matches successful CI revision d4b3ac178ef7fd03078caca70fafd32843abeaca |
| CI run 43616735176 | PASS: formatting, typecheck, JS tests/builds, migration/seed, health, contract generation/drift, Flutter analyze/tests and Android debug build |
| `node --test apps/web/lib/*.test.mts` | PASS: 4 tests |
| `node graphify-out/validate-refund-order.mjs` | Unsafe provider-before-validation order REPRODUCED with unchanged source methods and mocked I/O |
| `node apps/web/scripts/verify-shell.cjs` | FAIL: obsolete navigation assertion |
| `node verify-foundation.cjs` | PASS: structural contract checks, 106 paths / 132 operations / 179 schemas; static prototype syntax/contrast. Its generated VALIDATION.json change was reverted to avoid changing tracked files |
| `node verify-backoffice.cjs` | PASS: static prototype behaviour with mocked DOM; not a browser or production UI test |
| Full local JS/Flutter build and database integration | NOT RERUN: checkout has no node_modules or running provisioned database; existing exact-revision CI reused |
| Android/printer/provider/production runtime | NOT VERIFIED in this review |

Local focused commands used Node 24.15.0; the repository pins 22.23.1 and the matching remote CI used that pin. The Node source-method probe uses the built-in experimental TypeScript stripping API and needs a recent Node version. Its mocked boundaries do not establish a database or real provider result.

CI evidence: https://github.com/arkinara/modern-pos/actions/runs/43616735176

Saved evidence: `project-19-snapshot.json`, `issues-snapshot.json`, `audit-remote-evidence.json`, `validate-refund-order.mjs` in this directory.

## Suggested order

1. Repair provider-refund orchestration and add the cross-boundary regression.
2. Finish station execution; define offline restart/session policy and enforce production configuration.
3. Repair the shell check and put small real-database/browser regressions into CI.
4. Close explicit Android/printer, provider and operator acceptance tickets.
5. Run a final release gate after prerequisites pass, with current deployment, recovery and reconciliation evidence.

No product changes or GitHub mutations were made. Do not add new Phase 2 breadth before closing these integrity and operational acceptance gaps.
