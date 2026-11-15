# Two-developer work plan: remaining audit tickets

Planning date: 2026-11-15.

Project: [Modern POS — Project 19](https://github.com/users/arkinara/projects/19/views/1).

This plan divides the 13 remaining audit tickets (#66–#78) into two work tracks. Developer A is Codex working with the repository owner. Developer B is the other developer. These are proposed work ownership assignments; this document does not change GitHub assignees or ticket status. Ticket acceptance criteria remain authoritative. Recheck current issue status before starting.

## Goal

Keep backend/payment work in Track A and Android/printing/web verification in Track B so Developer B can complete their prerequisite chain without waiting for Track A's fixes. This is a dependency split, not an equal-effort estimate. Final release acceptance requires both tracks.

## Track A — Developer A / Codex

| Ticket | Scope | Prerequisites | Start |
| --- | --- | --- | --- |
| [#66](https://github.com/arkinara/modern-pos/issues/66) | Durable refund intents, validation before provider effects, deduplication and recovery | None | Immediately |
| [#69](https://github.com/arkinara/modern-pos/issues/69) | Reject unsafe production configuration and disable mock payment endpoints | None | Immediately |
| [#71](https://github.com/arkinara/modern-pos/issues/71) | Required PostgreSQL transaction/concurrency/recovery regressions in CI | #66 | After refund fix |
| [#75](https://github.com/arkinara/modern-pos/issues/75) | Integrate and verify a selected real payment-provider sandbox | #66, #69, #71 | Prepare provider access early; finish after prerequisites |
| [#77](https://github.com/arkinara/modern-pos/issues/77) | Validate deployment recovery, off-host backups, monitoring and operational ownership | #69, #71 | Prepare environment early; finish after prerequisites |
| [#73](https://github.com/arkinara/modern-pos/issues/73) | Reconcile implementation status, historical evidence and deferred acceptance in documentation | None | Immediately; maintain as evidence arrives |

Suggested sequence: #66 and #69, then #71, then #75 and #77. Keep #73 current throughout.

Primary ownership: API refund/payment orchestration, production configuration, database integration tests, deployment/recovery configuration, and overall status documentation.

## Track B — Developer B

| Ticket | Scope | Prerequisites | Start |
| --- | --- | --- | --- |
| [#67](https://github.com/arkinara/modern-pos/issues/67) | Connect kitchen station queues to Android claiming, rendering and delivery | None | Immediately |
| [#68](https://github.com/arkinara/modern-pos/issues/68) | Bounded offline session recovery, scoped snapshots and refresh retries | None | Immediately |
| [#70](https://github.com/arkinara/modern-pos/issues/70) | Repair obsolete back-office shell verification | None | Immediately |
| [#72](https://github.com/arkinara/modern-pos/issues/72) | Commit and run owner/cashier browser regressions in CI | #70 | After shell verification fix |
| [#74](https://github.com/arkinara/modern-pos/issues/74) | Verify one real Android/printer/kitchen configuration | #67, #68 | Arrange hardware early; finish after fixes |
| [#76](https://github.com/arkinara/modern-pos/issues/76) | Validate cashier and owner workflows with representative operators | #67, #68, #70, #72 | Arrange participants early; finish after prerequisites |

Suggested sequence: #67 and #68 as one coordinated Android workstream; #70 then #72 as the web workstream; finish with #74 and #76. All declared prerequisites for these six tickets are inside Track B.

Primary ownership: Android auth/session recovery, offline snapshots and queue access, kitchen station delivery, related station API changes, web verification/browser tests, and device/operator evidence.

Keep #67 and #68 under one developer because authentication, queue access and restart recovery intersect. Changes to station APIs belong to Track B even though those files live in the API app.

## Joint final gate — #78

[#78: Close audit prerequisites and verify final POS acceptance](https://github.com/arkinara/modern-pos/issues/78) depends on #66–#77. Developer A coordinates the final gate; Developer B supplies Android, printer, browser and operator acceptance evidence.

- Run final acceptance on one pinned release candidate after prerequisites have passing evidence or an explicit documented release-scope decision.
- Match CI, database, browser, hardware and provider evidence to that candidate, or document and rerun checks affected by later changes.
- Reconcile sale, payment, refund, stock, reports and receipt effects across retries, restarts and disconnects.
- Preserve supported configurations, unresolved limitations and operational ownership in the handoff.
- Production go-live requires separate explicit authorization.

Neither developer can independently close #78 before the other track is ready.

## Parallel-work rules

1. Use separate branches and separate worktrees/checkouts. Do not share a working directory for concurrent edits.
2. Keep prerequisite fixes and their follow-up acceptance tickets in the same track. Merge prerequisite PRs before closing downstream tickets.
3. Coordinate CI changes: #71 and #72 both need workflow integration. Prefer separate workflow files for database and browser checks where practical; agree before editing the same workflow.
4. Coordinate shared contracts: Track B owns station API changes for #67. Announce OpenAPI changes before regenerating TypeScript/Dart clients. Keep generated clients aligned with the merged API contract and avoid simultaneous regeneration edits.
5. Coordinate Prisma migrations if #66 and #67 both require schema changes. Each track owns its migration; check the combined migration sequence before merge. Neither track should rewrite the other's migration.
6. Each developer maintains feature-specific documentation and dated verification evidence. Developer A maintains the overall status/evidence reconciliation under #73; coordinate edits to shared status documents such as `docs/known-limitations.md`.
7. Keep web functionality within the back-office boundary. Cashier checkout and physical printer execution remain on Android. Web cashier-role browser checks do not introduce web checkout.
8. Preserve uncertain-delivery behavior: UNKNOWN printer jobs must not silently resend; explicit COPY decisions remain independent of sale/payment/stock effects.
9. Do not close acceptance tickets using mocks as substitutes for required physical hardware, actual provider sandbox or representative operator evidence.

## External prerequisites

| Track | Access or decision needed |
| --- | --- |
| A / #75 | Selected payment provider, actual sandbox credentials/access, and its official integration contract |
| A / #77 | Intended staging/deployment target, backup destination, monitoring access and named operational owners |
| B / #68 | Explicit bounded offline lifetime and revocation/reconnect policy; document any scope decision |
| B / #74 | Exact Android device/version and printer model/firmware/transport, with access for paper and disconnect/restart tests |
| B / #76 | Representative cashier and owner participants, intended devices/viewports and consented observation time |

Arrange these prerequisites early. Independence between tracks does not remove external access or product-policy requirements. Use synthetic data, isolated restore targets and provider sandbox funds for acceptance; do not deploy to production or change external infrastructure without the applicable authorization.

## Handoff for each completed ticket

- Link the PR and tested commit.
- Record checks run, results and relevant environment/device/provider versions.
- Attach the evidence required by the ticket, including dated physical/provider/operator results where applicable.
- State remaining limitations explicitly and link follow-up work.
- Notify the other developer of contract, migration, environment or shared-workflow changes that affect their track.
