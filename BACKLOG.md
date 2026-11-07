# Draft backlog

All tickets start unimplemented. Priorities: P0 = core dependency/release blocker; P1 = required within its phase; P2 = later refinement.

## M01 - Define architecture, domain model, and API contracts

## Outcome

Document and validate the selected Flutter/Dart Android app, Next.js/TypeScript web back office, NestJS REST/OpenAPI modular backend, and PostgreSQL/Prisma database. Record architecture decisions before scaffolding.

## Planning

- Draft ID: M01
- Phase: 1 - MVP
- Area: Foundation
- Priority: P0
- Depends on: None

## Acceptance criteria

- [ ] Model business, outlet, user, menu, variant, stock item, recipe, order, sale, payment record, stock movement, and print job.
- [ ] Define versioned API contracts, money in integer minor units, decimal quantities, outlet timezone, and sale state transitions.
- [ ] Document online-only MVP boundary, offline roadmap, deployment approach, and printer integration risks.
- [ ] Record the selected stack in TECH_STACK.md and define Flutter UI/repository boundaries, shared OpenAPI contracts, and authoritative backend business rules.

## Definition of done

- Acceptance criteria are verified with evidence appropriate to the change.
- Critical transactional changes include meaningful failure/retry/concurrency checks.
- User-facing changes follow the design system and include loading, empty, and failure states.
- Documentation reflects supported behavior and limitations.

Status: Draft specification; implementation has not started.

## M02 - Create minimalist design system and core flow prototypes

## Outcome

Establish a slick, modern visual foundation shared across web management and Android cashier.

## Planning

- Draft ID: M02
- Phase: 1 - MVP
- Area: Design
- Priority: P0
- Depends on: M01

## Acceptance criteria

- [ ] Define neutral surfaces, one accent color, typography, spacing, icons, and reusable component states.
- [ ] Prototype menu editing, stock adjustment, cashier cart, checkout, reports, and printer setup.
- [ ] Provide accessible contrast, keyboard support on web, large touch targets, loading/empty/error states, and compact/expanded layouts.

## Definition of done

- Acceptance criteria are verified with evidence appropriate to the change.
- Critical transactional changes include meaningful failure/retry/concurrency checks.
- User-facing changes follow the design system and include loading, empty, and failure states.
- Documentation reflects supported behavior and limitations.

Status: Draft specification; implementation has not started.

## M03 - Scaffold Next.js web, Flutter Android app, NestJS API, and PostgreSQL

## Outcome

Create the selected stack with pnpm workspaces for TypeScript apps, Flutter tooling for mobile, Prisma migrations, local Docker Compose, and synthetic demo data.

## Planning

- Draft ID: M03
- Phase: 1 - MVP
- Area: Foundation
- Priority: P0
- Depends on: M01

## Acceptance criteria

- [ ] Web, Android, and API run using documented commands with validated environment examples.
- [ ] Database migrations and a repeatable synthetic seed are included; no production credentials or data are committed.
- [ ] CI builds apps and checks formatting, types, and critical domain tests.
- [ ] Pin compatible stable dependencies; CI runs Next.js/NestJS checks and Flutter analyze/test/build. Generate or validate TypeScript and Dart contracts from OpenAPI.

## Definition of done

- Acceptance criteria are verified with evidence appropriate to the change.
- Critical transactional changes include meaningful failure/retry/concurrency checks.
- User-facing changes follow the design system and include loading, empty, and failure states.
- Documentation reflects supported behavior and limitations.

Status: Draft specification; implementation has not started.

## M04 - Implement authentication, owner/cashier roles, and outlet isolation

## Outcome

Provide minimum secure access for owner back office and cashier mobile app.

## Planning

- Draft ID: M04
- Phase: 1 - MVP
- Area: Security
- Priority: P0
- Depends on: M03

## Acceptance criteria

- [ ] Users can sign in and out; sessions expire and revoked access is rejected.
- [ ] Backend authorizes every request and isolates business/outlet records.
- [ ] Cashiers cannot edit stock, prices, permissions, or reports beyond their granted access; authentication is rate limited.

## Definition of done

- Acceptance criteria are verified with evidence appropriate to the change.
- Critical transactional changes include meaningful failure/retry/concurrency checks.
- User-facing changes follow the design system and include loading, empty, and failure states.
- Documentation reflects supported behavior and limitations.

Status: Draft specification; implementation has not started.

## M05 - Build responsive back-office shell and business settings

## Outcome

Implement navigation, account controls, and a single-outlet MVP configuration with extension points for more outlets.

## Planning

- Draft ID: M05
- Phase: 1 - MVP
- Area: Web
- Priority: P1
- Depends on: M02, M04

## Acceptance criteria

- [ ] Owner can navigate Menu, Stock, Sales, Reports, and Printers with clear selected states.
- [ ] Business name, receipt identity, currency, timezone, and configured tax/service rules are editable with validation.
- [ ] Pages work on desktop and smaller screens; failed requests offer safe retry.

## Definition of done

- Acceptance criteria are verified with evidence appropriate to the change.
- Critical transactional changes include meaningful failure/retry/concurrency checks.
- User-facing changes follow the design system and include loading, empty, and failure states.
- Documentation reflects supported behavior and limitations.

Status: Draft specification; implementation has not started.

## M06 - Implement menu categories, products, variants, and availability

## Outcome

Create shared catalog APIs and owner-facing menu management.

## Planning

- Draft ID: M06
- Phase: 1 - MVP
- Area: Menu
- Priority: P0
- Depends on: M03, M04

## Acceptance criteria

- [ ] Owner can create, edit, archive, search, and categorize products with prices and variants.
- [ ] Archived products remain readable on historical sales but cannot be newly sold.
- [ ] Every purchasable variant has a stable ID and explicit stock policy; changes appear after Android catalog refresh.

## Definition of done

- Acceptance criteria are verified with evidence appropriate to the change.
- Critical transactional changes include meaningful failure/retry/concurrency checks.
- User-facing changes follow the design system and include loading, empty, and failure states.
- Documentation reflects supported behavior and limitations.

Status: Draft specification; implementation has not started.

## M07 - Implement stock items, units, opening balances, and stock ledger

## Outcome

Track inventory using auditable movements rather than directly overwriting balances.

## Planning

- Draft ID: M07
- Phase: 1 - MVP
- Area: Stock
- Priority: P0
- Depends on: M03, M04

## Acceptance criteria

- [ ] Owner can define stock items, base units, precision, opening quantities, and reorder thresholds.
- [ ] Receipts and positive/negative adjustments require reason, actor, timestamp, outlet, and reference.
- [ ] Balance equals the movement sum; invalid quantities and incompatible units are rejected.

## Definition of done

- Acceptance criteria are verified with evidence appropriate to the change.
- Critical transactional changes include meaningful failure/retry/concurrency checks.
- User-facing changes follow the design system and include loading, empty, and failure states.
- Documentation reflects supported behavior and limitations.

Status: Draft specification; implementation has not started.

## M08 - Connect menu variants to stock through direct links and recipes

## Outcome

Allow finished goods to consume a stock item and prepared menu items to consume multiple ingredients.

## Planning

- Draft ID: M08
- Phase: 1 - MVP
- Area: Stock
- Priority: P0
- Depends on: M06, M07

## Acceptance criteria

- [ ] Owner can link a variant directly to stock or define ingredient quantities per sold unit.
- [ ] Unit conversion is explicit and validated; fractional ingredient consumption is supported.
- [ ] Sale stock calculations use a snapshot of the applicable recipe; later recipe edits never rewrite historical consumption.

## Definition of done

- Acceptance criteria are verified with evidence appropriate to the change.
- Critical transactional changes include meaningful failure/retry/concurrency checks.
- User-facing changes follow the design system and include loading, empty, and failure states.
- Documentation reflects supported behavior and limitations.

Status: Draft specification; implementation has not started.

## M09 - Implement sale calculation and payment recording API

## Outcome

Record completed sales with cash or manually recorded external payment; integrated payment processing belongs in Phase 2.

## Planning

- Draft ID: M09
- Phase: 1 - MVP
- Area: Sales
- Priority: P0
- Depends on: M04, M06

## Acceptance criteria

- [ ] Server calculates item totals, configured tax/service charges, rounding, amount due, tender, and change.
- [ ] Sale lines preserve product names, variant, price, and calculation rules as historical snapshots.
- [ ] Insufficient cash, invalid totals, duplicate checkout keys with changed payloads, and unauthorized requests are rejected.

## Definition of done

- Acceptance criteria are verified with evidence appropriate to the change.
- Critical transactional changes include meaningful failure/retry/concurrency checks.
- User-facing changes follow the design system and include loading, empty, and failure states.
- Documentation reflects supported behavior and limitations.

Status: Draft specification; implementation has not started.

## M10 - Deduct stock atomically and exactly once when a sale completes

## Outcome

Make sale completion and its stock ledger entries a single database transaction.

## Planning

- Draft ID: M10
- Phase: 1 - MVP
- Area: Stock
- Priority: P0
- Depends on: M08, M09

## Acceptance criteria

- [ ] Selling 2 products consuming 3 units each reduces the stock balance by exactly 6.
- [ ] Retries with the same checkout key return the original result and never duplicate sales or stock movements.
- [ ] Concurrent sales cannot oversell when negative stock is blocked; failed transactions change neither sale nor stock.
- [ ] Draft/cancelled carts do not deduct stock; menu availability reflects the limiting ingredient after refresh.

## Definition of done

- Acceptance criteria are verified with evidence appropriate to the change.
- Critical transactional changes include meaningful failure/retry/concurrency checks.
- User-facing changes follow the design system and include loading, empty, and failure states.
- Documentation reflects supported behavior and limitations.

Status: Draft specification; implementation has not started.

## M11 - Build cashier app shell, catalog browsing, and cart

## Outcome

Create a touch-friendly Android cashier UI for phone and tablet.

## Planning

- Draft ID: M11
- Phase: 1 - MVP
- Area: Android
- Priority: P0
- Depends on: M02, M04, M06

## Acceptance criteria

- [ ] Cashier can browse categories, search items, select variants, change quantity, and remove cart lines.
- [ ] Unavailable items are visibly disabled and totals remain clear while editing.
- [ ] Catalog refresh and expired-session handling preserve or explicitly resolve unsent cart work.

## Definition of done

- Acceptance criteria are verified with evidence appropriate to the change.
- Critical transactional changes include meaningful failure/retry/concurrency checks.
- User-facing changes follow the design system and include loading, empty, and failure states.
- Documentation reflects supported behavior and limitations.

Status: Draft specification; implementation has not started.

## M12 - Connect checkout, completion receipt, and uncertain-outcome recovery

## Outcome

Complete real API-backed cashier sales using cash or manual non-cash recording.

## Planning

- Draft ID: M12
- Phase: 1 - MVP
- Area: Android
- Priority: P0
- Depends on: M10, M11

## Acceptance criteria

- [ ] Cashier can enter tender, view change, submit once, and see a sale reference and receipt.
- [ ] Timeout recovery checks the existing checkout key before permitting a retry or new attempt.
- [ ] Online-only MVP clearly blocks completion without a confirmed server connection; print failure never repeats checkout.

## Definition of done

- Acceptance criteria are verified with evidence appropriate to the change.
- Critical transactional changes include meaningful failure/retry/concurrency checks.
- User-facing changes follow the design system and include loading, empty, and failure states.
- Documentation reflects supported behavior and limitations.

Status: Draft specification; implementation has not started.

## M13 - Build stock overview, receiving, adjustments, and low-stock states

## Outcome

Expose connected stock and menu availability clearly in the back office.

## Planning

- Draft ID: M13
- Phase: 1 - MVP
- Area: Web
- Priority: P1
- Depends on: M07, M08, M10

## Acceptance criteria

- [ ] Owner can filter stock by status and inspect the full movement history with sale references.
- [ ] Receiving and adjustments update balances and availability with reason capture and validation.
- [ ] A completed mobile sale is reflected in the web stock view after refresh; raw stock and estimated sellable menu quantities are distinguished.

## Definition of done

- Acceptance criteria are verified with evidence appropriate to the change.
- Critical transactional changes include meaningful failure/retry/concurrency checks.
- User-facing changes follow the design system and include loading, empty, and failure states.
- Documentation reflects supported behavior and limitations.

Status: Draft specification; implementation has not started.

## M14 - Build sales history, receipt detail, and basic daily reporting

## Outcome

Provide owner reports from persisted sales, not client-side counters.

## Planning

- Draft ID: M14
- Phase: 1 - MVP
- Area: Reporting
- Priority: P1
- Depends on: M09, M10, M12

## Acceptance criteria

- [ ] Filter sales by outlet-local date and inspect line items, tender, tax/service, and sale reference.
- [ ] Show gross sales, net sales, sale count, average bill, menu quantities, and payment-method totals with definitions.
- [ ] CSV export matches filtered results and report totals reconcile to completed sales and stock movement references.

## Definition of done

- Acceptance criteria are verified with evidence appropriate to the change.
- Critical transactional changes include meaningful failure/retry/concurrency checks.
- User-facing changes follow the design system and include loading, empty, and failure states.
- Documentation reflects supported behavior and limitations.

Status: Draft specification; implementation has not started.

## M15 - Validate printer hardware and implement Android receipt connection

## Outcome

Choose and verify one actual printer model and transport for MVP; prefer a documented thermal receipt protocol where supported.

## Planning

- Draft ID: M15
- Phase: 1 - MVP
- Area: Printing
- Priority: P0
- Depends on: M01, M03

## Acceptance criteria

- [ ] Record model, paper width, encoding, command support, Android version, and required permissions.
- [ ] Cashier can discover/configure the supported connection, connect, test print, and see actionable failure states.
- [ ] Verify on real hardware; Bluetooth/LAN/USB are not all claimed supported unless individually tested. Additional transports belong in Phase 2.
- [ ] Implement a Flutter printer adapter with Android runtime permissions and documented real-device verification.

## Definition of done

- Acceptance criteria are verified with evidence appropriate to the change.
- Critical transactional changes include meaningful failure/retry/concurrency checks.
- User-facing changes follow the design system and include loading, empty, and failure states.
- Documentation reflects supported behavior and limitations.

Status: Draft specification; implementation has not started.

## M16 - Implement receipt layout, print queue, retry, and reprints

## Outcome

Print persisted sale receipts with durable job state independent of checkout.

## Planning

- Draft ID: M16
- Phase: 1 - MVP
- Area: Printing
- Priority: P0
- Depends on: M12, M15

## Acceptance criteria

- [ ] Receipt shows identity, reference, local date, items, quantity, prices, tax/service, total, tender, and change.
- [ ] Jobs survive app restart and expose queued/sent/failed or uncertain states; a disconnect does not lose the sale.
- [ ] Manual reprint is marked COPY and audited; uncertain physical delivery is shown to the cashier rather than claiming guaranteed exactly-once paper output.

## Definition of done

- Acceptance criteria are verified with evidence appropriate to the change.
- Critical transactional changes include meaningful failure/retry/concurrency checks.
- User-facing changes follow the design system and include loading, empty, and failure states.
- Documentation reflects supported behavior and limitations.

Status: Draft specification; implementation has not started.

## M17 - Implement controlled sale reversal and stock restoration

## Outcome

Provide owner-only full sale reversal as the minimum safe correction path; complex refunds are deferred.

## Planning

- Draft ID: M17
- Phase: 1 - MVP
- Area: Operations
- Priority: P0
- Depends on: M10, M14

## Acceptance criteria

- [ ] Owner must supply a reason; original sale remains immutable and linked to its reversal.
- [ ] Stock is restored only for returned/restockable goods selected under an explicit policy; consumed ingredients are not blindly replenished.
- [ ] Repeated reversal requests do not repeat financial or stock movements; reports show reversals separately.
- [ ] Manual non-cash reversal records do not claim money was returned by a payment provider.

## Definition of done

- Acceptance criteria are verified with evidence appropriate to the change.
- Critical transactional changes include meaningful failure/retry/concurrency checks.
- User-facing changes follow the design system and include loading, empty, and failure states.
- Documentation reflects supported behavior and limitations.

Status: Draft specification; implementation has not started.

## M18 - Verify MVP end-to-end, deploy staging, and document ownership

## Outcome

Prove the core sales, stock, reports, and printing loop before production use.

## Planning

- Draft ID: M18
- Phase: 1 - MVP
- Area: Release
- Priority: P0
- Depends on: M05, M13, M14, M16, M17

## Acceptance criteria

- [ ] Verify catalog setup to Android sale to stock deduction to report to real printed receipt.
- [ ] Test concurrent stock contention, duplicate requests, checkout timeout, app restart, printer disconnect, and reversal.
- [ ] Provide staging setup, Android build instructions, migration/backup/restore procedure, owner guide, and known limitations.
- [ ] Use synthetic data; a production launch is a separate explicit release decision.

## Definition of done

- Acceptance criteria are verified with evidence appropriate to the change.
- Critical transactional changes include meaningful failure/retry/concurrency checks.
- User-facing changes follow the design system and include loading, empty, and failure states.
- Documentation reflects supported behavior and limitations.

Status: Draft specification; implementation has not started.

## C01 - Add offline sales and reliable synchronization

## Outcome

Design and implement explicit multi-device offline stock and conflict policy.

## Planning

- Draft ID: C01
- Phase: 2 - Complementary
- Area: Android
- Priority: P1
- Depends on: M18

## Acceptance criteria

- [ ] Encrypted local storage persists pending orders and sales across restart.
- [ ] Synchronization is idempotent, shows pending/conflict states, and reconciles reports and stock.
- [ ] Document whether stock is reserved, allocated per device, or can oversell offline; verify reconnect and concurrent edits.

## Definition of done

- Acceptance criteria are verified with evidence appropriate to the change.
- Critical transactional changes include meaningful failure/retry/concurrency checks.
- User-facing changes follow the design system and include loading, empty, and failure states.
- Documentation reflects supported behavior and limitations.

Status: Draft specification; implementation has not started.

## C02 - Add tables, open orders, item transfers, and split bills

## Outcome

Extend counter sales to full dine-in workflows.

## Planning

- Draft ID: C02
- Phase: 2 - Complementary
- Area: Sales
- Priority: P1
- Depends on: M18

## Acceptance criteria

- [ ] Open and transfer table orders with permissions and an audit trail.
- [ ] Split items/quantities across bills without duplicating payment or stock consumption.
- [ ] Define reservation and cancellation behavior before final payment.

## Definition of done

- Acceptance criteria are verified with evidence appropriate to the change.
- Critical transactional changes include meaningful failure/retry/concurrency checks.
- User-facing changes follow the design system and include loading, empty, and failure states.
- Documentation reflects supported behavior and limitations.

Status: Draft specification; implementation has not started.

## C03 - Add promotions, advanced modifiers, partial refunds, and approval rules

## Outcome

Extend pricing and corrections with controlled rules.

## Planning

- Draft ID: C03
- Phase: 2 - Complementary
- Area: Sales
- Priority: P1
- Depends on: M18

## Acceptance criteria

- [ ] Support percentage/fixed promotions and explicit eligibility, stacking, and rounding rules.
- [ ] Support partial item refunds with separate money-return and restock decisions.
- [ ] Require elevated approval where configured and retain original sale snapshots and audit history.

## Definition of done

- Acceptance criteria are verified with evidence appropriate to the change.
- Critical transactional changes include meaningful failure/retry/concurrency checks.
- User-facing changes follow the design system and include loading, empty, and failure states.
- Documentation reflects supported behavior and limitations.

Status: Draft specification; implementation has not started.

## C04 - Integrate QRIS or selected payment provider and reconciliation

## Outcome

Choose a provider and implement actual online payment lifecycle separately from manual recording.

## Planning

- Draft ID: C04
- Phase: 2 - Complementary
- Area: Payments
- Priority: P1
- Depends on: M18

## Acceptance criteria

- [ ] Use provider sandbox, verified webhooks, idempotency, and explicit pending/succeeded/failed states.
- [ ] Handle payment success with lost client connection and reconciliation without charging twice.
- [ ] Validate refunds, settlement reporting, and credential storage; provider selection and commercial setup remain prerequisites.

## Definition of done

- Acceptance criteria are verified with evidence appropriate to the change.
- Critical transactional changes include meaningful failure/retry/concurrency checks.
- User-facing changes follow the design system and include loading, empty, and failure states.
- Documentation reflects supported behavior and limitations.

Status: Draft specification; implementation has not started.

## C05 - Add shifts, cash reconciliation, attendance, and granular roles

## Outcome

Support daily staff operation and cash accountability.

## Planning

- Draft ID: C05
- Phase: 2 - Complementary
- Area: Operations
- Priority: P1
- Depends on: M18

## Acceptance criteria

- [ ] Track opening float, cash in/out, expected cash, closing count, and discrepancies.
- [ ] Separate attendance from cashier shifts and record accountable actors.
- [ ] Add permission matrix, approval limits, shift reports, and audit search.

## Definition of done

- Acceptance criteria are verified with evidence appropriate to the change.
- Critical transactional changes include meaningful failure/retry/concurrency checks.
- User-facing changes follow the design system and include loading, empty, and failure states.
- Documentation reflects supported behavior and limitations.

Status: Draft specification; implementation has not started.

## C06 - Add suppliers, purchase orders, stock counts, waste, and transfers

## Outcome

Expand inventory purchasing and control beyond manual receiving.

## Planning

- Draft ID: C06
- Phase: 2 - Complementary
- Area: Stock
- Priority: P1
- Depends on: M18

## Acceptance criteria

- [ ] Support purchase order to partial receipt with unit conversion and supplier reference.
- [ ] Stock count variance and waste generate ledger entries with reasons.
- [ ] Outlet transfers preserve quantities through dispatched/received states without double counting.

## Definition of done

- Acceptance criteria are verified with evidence appropriate to the change.
- Critical transactional changes include meaningful failure/retry/concurrency checks.
- User-facing changes follow the design system and include loading, empty, and failure states.
- Documentation reflects supported behavior and limitations.

Status: Draft specification; implementation has not started.

## C07 - Add kitchen routing and additional printer transports

## Outcome

Extend the verified MVP receipt connection to kitchen stations and other tested hardware.

## Planning

- Draft ID: C07
- Phase: 2 - Complementary
- Area: Printing
- Priority: P1
- Depends on: M16, M18

## Acceptance criteria

- [ ] Route menu items to stations and print amendments/cancellations with order references.
- [ ] Validate each added Bluetooth/LAN/USB transport against documented supported hardware.
- [ ] Queue and reprint station jobs independently without duplicating sales or stock deductions.

## Definition of done

- Acceptance criteria are verified with evidence appropriate to the change.
- Critical transactional changes include meaningful failure/retry/concurrency checks.
- User-facing changes follow the design system and include loading, empty, and failure states.
- Documentation reflects supported behavior and limitations.

Status: Draft specification; implementation has not started.

## C08 - Add multi-outlet management, bookkeeping, and advanced reporting

## Outcome

Extend the single-outlet foundation with consolidated management.

## Planning

- Draft ID: C08
- Phase: 2 - Complementary
- Area: Back office
- Priority: P1
- Depends on: M18

## Acceptance criteria

- [ ] Scope menus, prices, stock, staff, and reporting by outlet with consolidated owner views.
- [ ] Define inventory costing and expense categories before presenting profit/margin figures.
- [ ] Export auditable sales, reversal, payment, and accounting summaries with clear calculation definitions.

## Definition of done

- Acceptance criteria are verified with evidence appropriate to the change.
- Critical transactional changes include meaningful failure/retry/concurrency checks.
- User-facing changes follow the design system and include loading, empty, and failure states.
- Documentation reflects supported behavior and limitations.

Status: Draft specification; implementation has not started.

## C09 - Add online ordering, customer records, and digital receipts

## Outcome

Plan complementary ordering and customer-facing connections after the operational core.

## Planning

- Draft ID: C09
- Phase: 2 - Complementary
- Area: Integrations
- Priority: P2
- Depends on: M18

## Acceptance criteria

- [ ] Select supported channels and define order acceptance, cancellation, payment, and stock ownership.
- [ ] Deduplicate incoming orders and preserve channel references.
- [ ] Add opt-in customer records and digital receipts with configurable retention and access controls.

## Definition of done

- Acceptance criteria are verified with evidence appropriate to the change.
- Critical transactional changes include meaningful failure/retry/concurrency checks.
- User-facing changes follow the design system and include loading, empty, and failure states.
- Documentation reflects supported behavior and limitations.

Status: Draft specification; implementation has not started.

## I01 - Collect operator feedback and prioritize measured improvements

## Outcome

Keep improvement scope open until real usage evidence exists.

## Planning

- Draft ID: I01
- Phase: 3 - Improvements
- Area: Discovery
- Priority: P1
- Depends on: M18

## Acceptance criteria

- [ ] Observe cashier and owner workflows and record friction without collecting unnecessary customer data.
- [ ] Define baselines for checkout time, errors, stock discrepancies, and support incidents.
- [ ] Rank opportunities by user impact and effort; create approved implementation tickets before building.

## Definition of done

- Acceptance criteria are verified with evidence appropriate to the change.
- Critical transactional changes include meaningful failure/retry/concurrency checks.
- User-facing changes follow the design system and include loading, empty, and failure states.
- Documentation reflects supported behavior and limitations.

Status: Draft specification; implementation has not started.

## I02 - Refine cashier speed and back-office usability from feedback

## Outcome

Placeholder for validated UI improvements rather than predetermined feature promises.

## Planning

- Draft ID: I02
- Phase: 3 - Improvements
- Area: Design
- Priority: P2
- Depends on: I01

## Acceptance criteria

- [ ] Choose improvements from the measured backlog and define success criteria.
- [ ] Prototype and test with representative cashiers/owners across supported screen sizes.
- [ ] Verify accessibility and demonstrate improvement against the selected baseline.

## Definition of done

- Acceptance criteria are verified with evidence appropriate to the change.
- Critical transactional changes include meaningful failure/retry/concurrency checks.
- User-facing changes follow the design system and include loading, empty, and failure states.
- Documentation reflects supported behavior and limitations.

Status: Draft specification; implementation has not started.

## I03 - Improve performance and operational reliability from production evidence

## Outcome

Address measured bottlenecks in synchronization, checkout, reports, or printing.

## Planning

- Draft ID: I03
- Phase: 3 - Improvements
- Area: Reliability
- Priority: P2
- Depends on: I01

## Acceptance criteria

- [ ] Choose specific latency/failure targets from observed usage.
- [ ] Implement changes with realistic load and failure recovery checks.
- [ ] Verify no regression in stock integrity, sale idempotency, or historical report reconciliation.

## Definition of done

- Acceptance criteria are verified with evidence appropriate to the change.
- Critical transactional changes include meaningful failure/retry/concurrency checks.
- User-facing changes follow the design system and include loading, empty, and failure states.
- Documentation reflects supported behavior and limitations.

Status: Draft specification; implementation has not started.

