# Ticket #66 execution evidence and context

Issue: https://github.com/arkinara/modern-pos/issues/66

Track: A / Developer A (Codex). Branch: `fix/66-durable-refund-intents`.

## Status

- Started from `ee5f696` on 2026-11-15.
- Project 19 moved from Todo to In Progress before implementation.
- Stop at In QA after implementation and developer verification; do not close the issue or start #69 until instructed.

## Mechanism and scope

The original sales reversal called the external provider before sale-state, line and restock validation. The repair commits a validated, request-hash-bound refund intent before provider I/O, keeps one unresolved reservation per sale, snapshots provider identity/reference/key, and completes reversal/payment/restock effects atomically after confirmed provider success.

UNKNOWN retains the reservation. Same-key replay recovers using the original provider key. Confirmed SUCCEEDED intent recovery skips another provider call and consumes the validated plan without re-evaluating mutable approval/recipe rules. Explicit provider rejection records FAILED. Cash/manual and zero-money restock corrections retain their existing transaction path.

## Source and test context

- `apps/api/src/sales/sales.service.ts`: reservation, validation, provider orchestration and atomic completion.
- `apps/api/src/payments/payments.service.ts`: payment prevalidation and immutable provider execution.
- `apps/api/src/payments/mock-payment-provider.service.ts`: settled/refunded provider status mapping.
- `apps/api/prisma/schema.prisma` and `20261115160000_durable_refund_intents/migration.sql`: durable state and unique active-sale reservation.
- `apps/api/src/sales/sales.service.test.ts`: invalid payload/no provider call, replay/conflict, unknown/restart and local-failure recovery, rejection and zero-money preservation.
- `apps/api/src/payments/payments.service.test.ts`: provider preparation and payment correction regressions.

## Developer verification

- API typecheck: PASS.
- Full API unit suite: **287 passed, 0 failed**, on pinned Node 22.23.1. Output: `graphify-out/ticket-66-api-unit.txt`.
- PostgreSQL integration suite: **6 passed, 0 failed**, against isolated PostgreSQL 17.6 with controlled provider I/O. Output: `graphify-out/ticket-66-postgres.txt`.
- All 22 migrations applied and synthetic seed completed on fresh disposable databases.
- API build and changed-source Prettier check: PASS.
- Full API Prettier check with `--end-of-line auto`: PASS. The default whole-API check on this Windows checkout reported CRLF differences in untouched baseline files; source formatting was not changed outside #66 to resolve checkout-only line endings.
- Final verification environment: Windows, Node 22.23.1, pnpm 9.12.3, Prisma 6.19.3, PostgreSQL 17.6. Earlier development checks also used host Node 24.15.0; final evidence uses the repository pin.

The PostgreSQL suite covers competing distinct keys, concurrent same-key replays, the database-level active-reservation unique index, rollback after provider success/local failure, ambiguous-response recovery, remaining money/line/restock limits, and full online refunds. Unit regressions additionally cover invalid requests making zero provider calls, failed success persistence, another cashier attempting recovery, explicit provider rejection and online zero-money corrections. Existing cash/manual reversal tests remain green.

Initial database fixture checks failed because the seeded coffee variant is untracked. The fixture was corrected to use the seeded tracked chicken variant; the final six-test run above passed. Typecheck also caught test-only JSON-null/generic-mock typing errors during development; these were corrected before the final passing type/build checks.

## Graph context injection

`graphify-out/execution-context.json` records ticket #66's branch, baseline, source/test paths, verification and limitations. `node graphify-out/inject-execution-context.mjs` injects the ticket and 12 evidence links into `graph.json` and the interactive `graph.html`. The original AST baseline remains identified by `built_at_commit`; the overlay does not claim a full AST rebuild. Reapply the overlay after regenerating Graphify output.

Validation: graph JSON parses; node IDs are unique; all 12 evidence links resolve to nodes; the HTML evidence overlay compiles as JavaScript.

## QA handoff

Developer verification is complete; target status is **In QA**, with independent QA acceptance still pending. The GitHub issue and project board are authoritative for the final handoff status. Keep #66 open and do not start #69 in this execution.

QA should review the migration/rollout instructions in `docs/payments.md`, then reproduce the following with synthetic data:

1. Invalid sale state/line/quantity/restock: zero provider calls and no intent/reversal/stock effects.
2. Same key and payload: one refund and reversal; changed payload: conflict without provider effects.
3. Distinct keys during unresolved provider I/O: `REFUND_IN_PROGRESS`; capacity remains reserved for UNKNOWN/SUCCEEDED.
4. Provider success followed by local database failure: no partial local effects; restart/replay completes one reversal and restock set without another provider call when SUCCEEDED is durable.
5. Lost provider response or success-recording failure: replay the original key against provider deduplication and reconcile one local correction.
6. Full/partial online refunds and unchanged cash/manual/zero-money behavior; another cashier cannot resume an owner's pending intent.

Migration is additive; no historical financial/stock data is rewritten. Pause/drain old refund writers before rollout and retain intent data on rollback. Never downgrade to the legacy refund writer while ingress is active. Independent production upgrade/rollback acceptance is not claimed by local tests.

## Remaining boundaries

- Real-provider sandbox acceptance remains #75. Provider idempotency is exercised with controlled adapters here.
- Recovery is request-driven using the original payload/key; no background worker was added.
- Broader required PostgreSQL CI coverage remains #71; this ticket adds its focused executable integration suite without taking over that ticket.
- Recovery tests reconstruct the service over durable database state and inject response/local failures; they do not claim a physical device test or an OS process-kill campaign.
- No production deployment, physical printing or independent QA acceptance was performed.

This is execution context, not independent QA acceptance or real-provider sandbox verification (#75).
