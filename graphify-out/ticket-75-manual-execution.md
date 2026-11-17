# Ticket #75 manual recording scope

The owner clarified on 2026-11-17 that current payment functionality records
transactions confirmed externally through a bank merchant app and static QRIS
code. Automated provider integration and provider sandbox acceptance are deferred.
This work starts from main `2c84ee3` on `codex/75-manual-noncash-recording`.

The existing `MANUAL_EXTERNAL` contract remains the storage/wire representation.
Cashier checkout, receipt labels, offline recovery and back-office sales/reports
now display **QRIS / Non-cash**. QRIS and other externally confirmed non-cash
methods share this recording category. The cashier confirms receipt in the bank
merchant app before recording the exact sale amount and optional reference.
Manual reversals are POS records after the merchant arranges any bank refund.

`PAYMENT_PROVIDER=manual` permits production startup without a provider API key,
base URL, payment webhook secret or PAYMENT_MODE. JWT secret, secure cookies,
explicit HTTPS origins and production sandbox denial remain enforced. Automatic
provider selection, webhook verification and provider refund preparation reject
manual mode. Existing automatic MOCK/QRIS opt-in modes retain their regression
coverage. The local environment example now selects manual recording by default.

All 316 API, 4 web and 6 operations unit tests passed. The complete PostgreSQL
suite passed 18 tests twice against the same isolated synthetic database. The new
case records and replays a manual QRIS/non-cash sale and reversal, retains the
merchant reference, observes no online payment/refund intent, counts zero provider
calls, and verifies an attempted ONLINE checkout rolls back in manual mode.

A compiled production-mode API was started against real local PostgreSQL with
all provider credentials and PAYMENT_MODE absent. Database-backed health returned
200, sandbox routes returned 404, and an online webhook returned 503 with
ONLINE_PAYMENTS_DISABLED. The expanded compiled HTTP suite also passed 6 scenarios
and 25 endpoint assertions. Raw evidence is linked in the context record.

API/web/client typechecks and formatting were checked. The installed local Dart
SDK is 3.12.2, below this project's required 3.13.0, so focused local Flutter tests
could not resolve packages. The pinned CI Flutter 3.47.0 toolchain must pass before
the PR is merged, including the label/wire-contract test, existing cashier flows,
browser regressions and Android build. Final CI evidence is recorded on the PR
and issue handoff.

PR #91 passed the pinned client pipeline and was merged. A subsequent guard
review reproduced a legacy FAILED online payment becoming PENDING before manual
mode rejected its retry. Early guards now reject automatic creation, refresh,
reconciliation and provider refund execution before accessing payment storage
or provider adapters. The regression preserves legacy FAILED status and asserts
zero database/provider accesses for all four operations. See
`ticket-75-manual-guard-before.txt` for the failing reproduction and
`ticket-75-manual-unit.txt` for the passing full suite. The real PostgreSQL suite
was repeated twice after this guard fix. Final main CI is linked on #75.

Ticket #75 and release gate #78 preserve the previous provider scope as deferred
history and record the explicit recording-only scope decision. Operator UAT of
actual merchant-app confirmation and deployment acceptance remain in the release
gate. Provider sandbox access is unnecessary for the current recording scope.
