# Ticket #75 execution evidence

Execution date 2026-11-16. Node 22.23.1, PostgreSQL 17.6, Prisma 6.19.3.
The repository owner selected mock-first work. The existing mock provider and
its PostgreSQL ledger were used with synthetic data and IDR exponent 0.

The dedicated QA baseline `codex/track-a-qa` combines current main c82c32b with
PRs #79, #83 and #84. Its merge commit is fc327cf. Ticket #75 is stacked on that
review baseline. Main and the prerequisite PRs retain their independent review
state.

All 312 unit tests passed. The complete database suite passed 17 tests per run,
twice against the same isolated database. Raw outputs are in
`ticket-75-api-unit.txt` and `ticket-75-postgres.txt`. New lifecycle coverage uses
real persisted mock payment/refund records. HTTP webhook tests run the actual
raw-body controller and exception filter over loopback. Sales and refunds use
the application services. No genuine provider webhook or remote settlement was
observed.

Tests cover duplicate payment creation, signed concurrent webhook delivery,
tampering and timestamp rejection, terminal out-of-order delivery, lost webhook
refresh, failed payment retry, provider-success/local-failure recovery,
lost-refund-response replay, partial/full refunds and stock restoration.
Synthetic provider transaction and event IDs are present in the database log.
The full refund scenario reconciles provider captured/refunded amounts with
local online-payment and reversal totals with zero unexplained drift.

`docs/payment-acceptance.md` provides repeatable commands and a provider-specific
worksheet, credential/reconciliation procedure and explicit pending fields.
Actual provider/API version, official contract, sandbox credentials, genuine
webhook/refund IDs, settlement fees and named provider operations owners remain
pending external acceptance on #75. This handoff advances developer preparation
to QA and preserves those ticket criteria.

Graphify includes this evidence and its test/source relationships as an overlay
on the recorded historical AST baseline. CI results are linked from the PR and
issue handoff at the tested head.
