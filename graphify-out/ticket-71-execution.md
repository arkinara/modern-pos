# Ticket #71 execution evidence and QA context

Issue https://github.com/arkinara/modern-pos/issues/71

Work began on 2026-11-16. Branch `test/71-postgres-ci` starts from
`589e5aa4e21f923ec373eb17d7a0e1a83926a0e4`, the tested #66 refund fix.

## Dependency and status

#66 remains In QA in PR #79. This branch is stacked on its feature branch so
the integration tests exercise durable refund intents. The PR targets
`fix/66-durable-refund-intents` for focused review. After #66 merges, retarget
this PR to main and review the resulting CI run. #69 is a separate open PR.

Project 19 moved #71 from Todo to In Progress before implementation. The handoff
target is In QA with independent acceptance pending.

## Implementation

The existing CI PostgreSQL service now uses `modern_pos_ci_transaction_test`.
`DATABASE_URL` and `TRANSACTION_TEST_DATABASE_URL` point to that same target.
The mandatory database regression step runs after migrations and repeat seeding,
with a three-minute timeout. A test failure fails the existing CI job.

The checkout suite exercises concurrent distinct and duplicate keys, a late
PostgreSQL failure after sale/payment/stock writes, a lost checkout response with
recovery in a separate Node process, and concurrent transfer receipt/replay.
Assertions count committed sales, payments, reservations and stock movements and
compare balances with the ledger.

The #66 refund suite gains isolated catalog/stock fixtures and invalid-payload
database checks. Existing concurrency, refund-capacity and recovery checks run
through the same `test:db` command. Controlled provider I/O retains a stable
idempotency ledger while local sale/payment/restock effects use PostgreSQL.

The new target helper has unit tests for explicit opt-in, test database naming,
production rejection, target mismatch and redacted error messages. Standalone
refund execution retains its existing environment-variable entry point.

## Verification

Final counts and results are recorded in `ticket-71-context.json`.

- `ticket-71-api-unit.txt` contains the full API unit run on Node 22.23.1.
- `ticket-71-postgres.txt` contains migrations, repeat seeding and two complete
  integration runs against the same isolated PostgreSQL 17.6 database.
- Typecheck passes for the test support, recovery worker and integration suites.
- Final local results include 290 passing unit tests and 12 passing PostgreSQL
  regressions on each of two runs against the same database. API build and
  formatting checks also pass on Node 22.23.1. The full API formatting check uses
  `--end-of-line auto` for the Windows checkout.

The initial real-database run passed all 12 tests twice. The recovery test was
then extended to launch a separate Node process, and final verification covers
that version. Fixtures use fixed six-unit consumption and transfer quantities,
with unique IDs to keep repeated executions isolated.

## QA reproduction

Follow `docs/database-regressions.md` to create a disposable test target, migrate,
seed and run the suite. Check the reported effect counts for oversell prevention,
full transaction rollback, same-key deduplication, separate-process recovery,
refund recovery and one-time transfer receipt. Run the suite again against the
same database and compare the invariant counts.

The rollback proof creates a fixture-scoped PostgreSQL trigger that rejects the
finalize audit insertion after financial and stock writes. The trigger/function
are removed in a `finally` block. The worker recovery proof simulates a lost
response after commit and starts a new process to recover/replay that checkout.

Provider responses are controlled test I/O. Actual provider verification remains
#75. The CI database is an ephemeral synthetic target and the existing API check
fails on a database regression. Remote CI evidence will be linked in the QA
handoff after the PR run completes.
