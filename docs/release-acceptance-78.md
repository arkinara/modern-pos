# Release candidate QA handoff for #78

## Subsequent owner decision for physical printer testing

On 2026-11-17 the owner accepted the merged printer software and chose to perform physical testing personally. #74 is now closed and Done under that scope decision. Physical results remain pending owner execution. The dated handoff below retains its original snapshot. [Owner decision](../graphify-out/ticket-74-owner-decision.md)

Prepared on 2026-11-17 against pulled `main` revision `aa052c733105525c3dc904c6ea3d7b7b25d64a65`. The software candidate includes the receipt-label correction in `08184e6c9842da52bcd59655cda12d7a3f8a6944`. Evidence-only commits and a merge with an identical tested tree retain this source candidate. The #78 handoff comment records the reviewed PR head and CI result.

## Acceptance decision

The repository and local/synthetic software phase is ready for QA after matching CI passes. Final release acceptance remains pending. Keep #78 open and In QA at handoff. Physical printer acceptance remains in #74. The owner will perform the #76 operator pilot later and has deferred #77 deployment acceptance until deployment preparation.

Current payments record cash and externally confirmed QRIS/non-cash transactions. The cashier confirms receipt through the merchant's bank app/static QR code and selects QRIS / Non-cash. Storage uses `MANUAL_EXTERNAL`, exact sale amount and an optional reference. `PAYMENT_PROVIDER=manual` requires no payment-provider credentials. Automated provider integration and provider sandbox acceptance remain deferred future scope.

## Pinned environment

| Item | Candidate configuration |
| --- | --- |
| Application source candidate | `08184e6c9842da52bcd59655cda12d7a3f8a6944` |
| Source change since audited main | Digital receipt display label and three API unit regressions |
| Node / pnpm | 22.23.1 / 9.12.3 |
| PostgreSQL server and client | 17.6 |
| Prisma migration history | 22 migrations, latest `20261115160000_durable_refund_intents` |
| Flutter CI | 3.47.0 with the repository-required Dart 3.13 toolchain |
| Local Flutter tooling limitation | Installed Dart 3.12.2. Full Flutter tests/build use pinned CI |
| Android application database | Drift schema version 6 |
| Runtime acceptance mode | `NODE_ENV=production`, manual payments, secure cookies, explicit HTTPS web origin, synthetic JWT and loopback API transport |
| Local database | Fresh isolated synthetic database ending `_release78_transaction_test` |
| Printer settings | Generic ESC/POS, 58/80 mm, configurable Automatic cutter default off |
| Physically accepted printer/device combinations | Pending under #74 |
| Intended deployment, domains and operational contacts | Pending under #77 |

The production-mode runtime check uses loopback HTTP. Deployed TLS, remote service delivery and actual Android radio/USB behavior require their own evidence.

## Prerequisite disposition

| Tickets | Verified delivery and remaining scope |
| --- | --- |
| #66 | Durable refund validation/reservation/recovery verified with controlled provider I/O and real PostgreSQL. Automatic provider execution is disabled in manual mode |
| #67 | Kitchen station queue delivery, claim/conflict handling and explicit COPY behavior pass software tests. Physical paper output remains in #74 |
| #68 | Bounded offline authorization, cache isolation and refresh retries pass Flutter tests. Physical device/offline reconnect remains in #74 |
| #69 | Production configuration, sandbox gating and manual-mode startup verified. Intended deployed configuration remains in #77 |
| #70/#72 | Structural shell verification and retained owner/cashier browser checks pass |
| #71 | Required PostgreSQL concurrency, rollback, recovery, refund and transfer suite passes |
| #73 | All 47 predecessor implementation/protocol commits are reachable. The dated 48-item board audit remains available |
| #74 | Open In QA. Permission/pairing, paper receipts and kitchen tickets, real disconnect/restart, encoding/cutter behavior and dated physical evidence pending |
| #75 | Manual recording verified. The receipt-label regression discovered during this gate is corrected and regression-tested in the candidate |
| #76 | Done under the explicit owner decision to accept preparation now and perform representative operator testing later |
| #77 | Open In QA. Tooling/local restore verified. Intended host, off-host backups/retention/restore, alerts, RPO/RTO and named owners deferred until deployment preparation |

## Tests and evidence

The pulled main candidate passed [complete CI](https://github.com/arkinara/modern-pos/actions/runs/44065621422) with 316 API, four web, six operations, 18 PostgreSQL and 160 Flutter tests, plus 53 browser checks and Android build. Three opt-in Flutter live tests were skipped. The receipt correction adds three API regressions. The final candidate's full matching CI result is attached to #78 before handoff.

| Fresh check | Result | Evidence |
| --- | --- | --- |
| Root unit entry point `pnpm test` | 319 API, four web and six operations tests pass, zero failures | [Unit log](../graphify-out/ticket-78-unit.txt) |
| Receipt regression before correction | Five focused tests run, one fails for manual payment display and four pass | [Failing unit log](../graphify-out/ticket-78-receipt-regression-before.txt) |
| Fresh PostgreSQL suite | All 18 tests pass against migrated/seeded real PostgreSQL | [Restore/test log](../graphify-out/ticket-78-restore.txt) |
| Local backup/restore | Ten fingerprints and financial totals match, 19 sales, 19 payment records, 11 reversals and 51 stock movements restored | Same restore/test log |
| Runtime/backup privileges | Runtime DML accepted, runtime DDL/migration writes and backup writes rejected. Backup privileged role flags false. Occupied restore target rejected | Same restore/test log |
| Synthetic production-manual HTTP workflow | Exact recording, ledger, report, receipt and actual API process-restart checks pass | [Runtime log](../graphify-out/ticket-78-runtime.txt) |
| Original implementation ledger | 35 records, reachable commits and 24 documentation links pass | `node scripts/verify-implementation-evidence.cjs` |
| Shell verification | 15 owner and seven cashier destinations, role isolation and wrappers pass | `node apps/web/scripts/verify-shell.cjs` |

Restore-only time was approximately 0.66 seconds, with 3.17 seconds for dump/restore/verification on the small synthetic local workload. Restored sale/payment totals both matched 176000 minor units, local refunds 13000 and controlled-provider refunds 11000. The local timing does not establish intended deployment RTO.

The opt-in tests skipped by the ordinary Flutter suite are `catalog_refresh_proof_test.dart`, `checkout_live_api_test.dart` and `t18_live_receipt_test.dart`. Current live HTTP acceptance and mandatory PostgreSQL recovery tests provide additional evidence. Execution of those three Dart-client entry points remains unverified for this candidate.

## Live recording and recovery results

The final runtime fixture starts a freshly built API in production-manual mode with a new seeded PostgreSQL database and no provider credentials.

- Cashier access to owner reports is rejected with 403. Access to a seeded foreign outlet is rejected with the documented 404 response.
- Underpayment is rejected with 422 and creates no sale effects.
- A 35000-minor-unit QRIS/non-cash sale records exactly one sale, one payment and three ingredient movements. The stored optional reference matches, balances equal movement deltas, and online payment/refund intent counts are zero.
- Terminating and restarting the actual Node API process preserves the mobile session and checkout recovery. Same-key finalize returns the original sale. Changed payload returns 409 and adds no effects.
- Cash plus non-cash completion adds two sales and 70000 minor units of gross item sales. Both payment breakdown deltas match their captured totals.
- The owner records one 35000-minor-unit local reversal after the synthetic bank refund. Restocking produces one opposite movement per ingredient. Another actual API restart and same-key replay preserve one reversal. Report refund/net-sales deltas reconcile. External refund execution is false and provider refund intents remain zero.
- Automatic online creation and webhook handling return 503, and sandbox creation returns 404.
- Newly generated customer digital receipt HTML/text and public retrieval preserve the sale reference and amount and display QRIS / Non-cash.

The before-correction live result is retained in [the reproduction log](../graphify-out/ticket-78-runtime-before.txt). It passes the ledger/restart/report/reversal checks and fails at the digital payment display-label assertion.

## Correction found by #78

The digital receipt renderer exposed `MANUAL_EXTERNAL` in customer-facing HTML/text. The correction belongs to #75 and uses the QRIS / Non-cash display label for newly issued manual-payment receipts. Three focused regressions cover manual, cash and online labels and retain reference/amount checks. The correction changes presentation in the receipt renderer.

## QA completion steps

1. Confirm the #78 handoff's candidate/CI SHA and checkout that revision for testing. Run the normal gates with the pinned toolchain and an isolated synthetic PostgreSQL database. Build the Android debug APK with `pnpm mobile:build`.
2. Execute [physical hardware acceptance](hardware-acceptance.md) on the actual device/printer combination. Record firmware, width, code page and whether Automatic cutter is enabled. Attach paper photographs and permission, pairing, disconnect/restart, UNKNOWN/COPY and kitchen ticket evidence to #74.
3. When the owner performs operator testing, use [the operator pilot](operator-pilot.md), including actual merchant-app confirmation and externally handled refund recording. Record the dated observations and accept/defer decision under the owner’s #76 deferral.
4. During deployment preparation, execute [operations QA](operations-qa.md) on the intended hosts. Supply TLS/secrets, effective privileges, actual off-host backup/restore and retention, genuine alert/recovery notifications, workload-sized recovery objectives and named operational contacts in #77.
5. Reconcile any candidate delta, repeat affected checks, and record the final #78 decision with evidence and unresolved risks. Production go-live requires the owner's separate authorization.

This round uses real local PostgreSQL with synthetic data, mock/controlled provider lifecycle tests and loopback infrastructure. Another round using the actual supported hardware, merchant workflow and intended services remains pending. Automatic payment-provider sandbox testing applies when that integration enters scope.
