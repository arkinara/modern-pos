# Known limitations and pending verification

Status date: 2026-11-12. No device, printer, real payment-provider account or production infrastructure was available
for this ticket. Nothing below is reported as passed without a reproduction recipe.

## Pending with reproduction recipes

### Cash drawer and attendance hardware

Status: `PENDING - requires cash drawer hardware and an Android device`.

What was verified on this VPS: shift open, paid-in, paid-out, close with a
counted amount, signed discrepancy, duplicate-close `409`, owner shift report,
attendance clock in/out separation and owner audit search were exercised against
the live API and are covered by unit tests. No physical drawer, printer pulse,
barcode attendance device or employee card reader was available.

Reproduction:

1. Complete the verification transcript in this ticket on the staging database.
2. Attach a physical drawer pulse reader and confirm paid-in/paid-out and close
   do not send an unintended pulse.
3. Record a real counted close and compare the printed/recorded discrepancy with
   the report.
4. Import or export attendance from the intended HR system only after an explicit
   payroll integration ticket; C05 does not implement payroll export.

### Staff operations on a physical Android device

Status: `PENDING - requires Android device`.

What was verified on this VPS: the C05 screens are back-office web routes that
call the live API. The Flutter app was not given new shift or attendance screens
in this ticket, so there is no device UI claim to verify. The debug APK still
builds and the existing app tests remain green.


### Kitchen station tickets and LAN/Bluetooth/USB transports

Status: `PENDING - requires printer model + Android device or LAN printer`.

What was verified on this VPS: menu item station routing, original / amendment /
cancellation station jobs with the same order reference, independent station
queues, retry and reprint all ran against the live API. Station print operations
were asserted not to change `sales` or `stock_movements`. LAN raw TCP bytes were
accepted by a local listener; Bluetooth and USB adapters were exercised with
fakes and a mocked Android channel.

What was not verified: physical paper from any station printer, model-specific
command support, Bluetooth pairing on a device, USB host permission and bulk
transfer. See `docs/printer-hardware.md`.

Boundary: cancelling an item prints a `CANCEL` station job but does not reverse
the sale or restock ingredients. Money and stock reversal remain the explicit
sale-reversal path (`#17`).

### Multi-outlet bookkeeping and costed margin

Status: `IMPLEMENTED on the staging database; real payroll/accounting integration PENDING`.

What was verified on this VPS: two outlets with live sales, purchase receipts,
manual expenses, stock waste and one reversal were read through per-outlet
reports and the consolidated owner view. Consolidated totals were checked as the
arithmetic sum of per-outlet rows, including the combined average-bill division
and stock value. A cashier read against the other outlet returned `404` on every
new bookkeeping route, and the owner-only consolidated route returned `403`
after the cashier passed the scope check. Moving average and last purchase
produced different COGS from the same receipts. The margin gate returned null
profit and margin with `COSTING_METHOD_UNDEFINED` and
`EXPENSE_CATEGORIES_UNDEFINED`. Sales, reversals, payments and accounting CSVs
were parsed back and reconciled field-by-field to the same period's API report.

What was not verified: a real payroll, accounts-payable, tax or bank-ledger
integration; FIFO/LIFO/landed cost; production data volume; and a serializable
cross-query snapshot for the accounting summary while a sale commits between
reads. See `docs/multi-outlet-bookkeeping.md`.

Boundary: purchases are capitalised into inventory cost and are not also counted
as an operating expense. Stock waste is derived at cost. Opening balances,
manual receipts without a purchase order and transfer-ins do not invent a cost.

### Physical printed receipt

Status: `PENDING - requires printer model + Android device`.

What was verified on this VPS: the receipt text builder rendered a live finalize
payload with business identity, outlet, reference, outlet-local time, item, variant,
quantity, unit price, line total, subtotal, service, tax, total, cash tendered and
change. The API print-job mirror accepted `QUEUED -> FAILED` and `QUEUED -> UNKNOWN`.

What was not verified: bytes reaching a printer, paper output, code page, cut, drawer
pulse, reconnect behaviour.

Reproduction:

1. Build and install the debug APK with `docs/android-build.md`.
2. Pair a real Bluetooth receipt printer in Android settings.
3. In the app, grant Bluetooth permission, enter the printer address, choose width and
   encoding, connect and run Test print.
4. Print a completed sale and attach a photo of the paper.
5. Complete the hardware record in `docs/printer-validation.md`.

### Android app sale and device restart

Status: `PENDING - requires Android device`.

What was verified on this VPS: the same `POST /outlets/{outletId}/sales/finalize`
endpoint the app calls completed a sale, deducted stock, appeared in reports and
reconciled with the owner web sales/stock/reports screens. Recovery by retained
checkout key returned the same sale after a simulated client timeout.

What was not verified: Flutter UI on a device, device secure storage, process kill and
restart on Android, real network loss.

Reproduction:

1. Install the debug APK and sign in as a cashier.
2. Complete one sale through the app UI.
3. Kill the app immediately after submission, reopen it and use recovery.
4. Confirm the owner web sales list shows exactly one reference with the same quantity
   and total.
5. Refresh owner stock and reports for the same local day.

### Offline queue on a real Android device

Status: `PENDING - requires Android device`.

What was verified on this VPS: unit and widget tests prove AES-256-GCM
round-trip, restart persistence through a real SQLite file, tamper and
missing-key failures, no plaintext/key in raw rows, single-flight replay,
`UNCERTAIN` recovery with `sales_recover`, conflict reasons from the server and
reconciliation against the sales ledger. A two-device race against the real API
left the last stock item at `0`, accepted exactly one sale and rejected the
other with `422 INSUFFICIENT_STOCK`; the transcript is in `docs/offline-sync.md`.

What was not verified: Android Keystore behaviour after process death, real
airplane mode, and a second physical device. The VPS has no Android device.

Reproduction:

1. Install the debug APK on two Android devices and sign in as cashiers.
2. Load the catalog, add the same low-stock item on both devices and enable
   airplane mode.
3. Use Checkout > Record offline sale on both devices. Confirm the pending key
   and that the cart is cleared.
4. Kill and reopen the app; confirm the pending item is still present and the
   screen never shows plaintext SQLite data.
5. Disable airplane mode on one device, open Settings > Offline sales & sync and
   tap Sync now. Record the state and reference.
6. Repeat on the second device. Confirm one sale, one conflict with the server
   shortage reason, no negative stock and no duplicate sale.

### Dine-in table order flow on a physical Android device

Status: `PENDING - requires Android device`.

What was verified on this VPS: the live API transcript opened a table order,
transferred it with an owner-only audit row, split it into two independently
settled bills, proved exactly one stock movement per sold ingredient, replayed
the split and finalize idempotently, cancelled an unpaid order without stock,
and rejected stale versions. Flutter widget tests cover the Tables screen at
320/768/1024/1440 px for loading, empty, error, open, transfer, split and cancel
states.

What was not verified: tapping the flow on real Android hardware, secure device
identity across process restart, and real network loss during split or settle.

Reproduction:

1. Install the debug APK and sign in as `cashier.second@example.test`.
2. Add items to the cart, open Tables, and tap Open order on T1.
3. Sign in as `owner.second@example.test` and transfer the order to T2.
4. As the cashier, split the order into two bills and settle each separately.
5. Confirm the owner sales list shows two references whose totals sum to the
   original quote, and stock movements show each ingredient deducted once.

### Printer disconnect on real hardware

Status: `PENDING - requires printer + Android device`.

What was verified on this VPS: the server print-job mirror created a job, transitioned
it to `FAILED` with a disconnect error, and transitioned a COPY job to `UNKNOWN`; the
sale remained intact and a finalize replay created no second sale. Mobile unit tests
cover `FAILED` versus `UNCERTAIN` and no automatic resend.

What was not verified: a physical Bluetooth disconnect during a write.

Reproduction: follow steps 10-11 of the device checklist in `docs/android-build.md`
and record the visible state and paper result.

## Deferred product scope

| Item | Status | Notes |
| --- | --- | --- |
| Offline checkout and conflict resolution | Implemented client-side in #19 | Encrypted queue + idempotent replay; no server sync API |
| Production deployment and field rollout | Deferred to #20 | Not started in this ticket |
| Stock reservation while offline | Not implemented | Server remains authoritative; rejected sales become conflicts |
| Table order stock reservation | Not implemented by design | Opening/cancelling a draft reserves or consumes nothing; stock moves only at settlement (see `docs/table-orders.md`) |
| Table management in the web back office | Not implemented | Tables are created through the API; the cashier app lists and uses them |
| Multiple simultaneous open orders per table | Not blocked | The cashier app shows the first open order per table; the API lists all drafts |
| Server-side sync API or queue | Not implemented | Contract unchanged; client replays existing idempotent endpoints |
| Cold offline tax/service/rounding | Not guaranteed | A server total change becomes a cashier conflict |
| Production deployment | Separate explicit decision | Single-VPS staging is not production |
| User management UI and password reset | Not implemented | Users are seeded/provisioned outside the app |
| Partial or line-level refunds | Implemented (#21) | Partial item refunds with independent money-return and restock. Online refunds now call the configured provider adapter (#22); cash and manual reversals keep `externalRefundPerformed = false`. |
| Payment-provider refunds/voids | Sandbox-verified, real provider PENDING | Online refunds use the same reversal path and the provider adapter; live QRIS verification requires provider credentials/commercial setup. |
| LAN and USB printer transports | Not implemented | Bluetooth Classic SPP is the only candidate |
| Hardware-verified Bluetooth result | PENDING | See `docs/printer-validation.md` |
| Automated off-host backups and retention | Not implemented | Procedure and dry run exist in `docs/backup-restore.md` |
| Point-in-time recovery | Not implemented | Logical dump only |
| Monitoring, alerting, log shipping | Not implemented | Health endpoint exists |
| High availability / multiple API instances | Not implemented | Single VPS |
| Production TLS and secret manager | Not implemented | Staging uses local env placeholders |
| Tax/service policy beyond fixed basis points | Not implemented | Settings support integer bps only |
| Discounts and promotions | Partially implemented | Percentage/fixed promotions with explicit eligibility, stacking and half-up rounding are enforced server-side (#21). Loyalty is not implemented. |
| External payment refunds | Partially implemented (#22) | Mock provider refunds are linked to reversals; real QRIS refunds are `PENDING - requires provider credentials/commercial setup`. |
| Multi-currency per sale | Not implemented | One currency/exponent per outlet |
| User activity audit beyond sale/stock/reversal/order records | Partially implemented | Promotion, refund and approval decisions are append-only audited in `order_audits`; modifier catalog changes and admin/user changes are not audited |
| Supplier invoices, payments and tax | Not implemented | Purchase orders capture price only; no invoice, payable or landed-cost ledger |
| Supplier portal or EDI integration | Not implemented | Suppliers are created manually through the API |
| Barcode receiving and count scanning | Not implemented | Quantities are entered manually |
| Transfer approval workflow | Not implemented | Cross-outlet transfer is owner-only; no second approver step |


## Online payments and reconciliation (#22)

What was verified on this VPS: finalize with `payment.kind = ONLINE` writes a
pending online payment separate from cash recording; a signed sandbox
`payment.succeeded` webhook settles it; duplicate and parallel duplicate
deliveries produce one transition; invalid signatures and stale timestamps are
rejected with no state change; an out-of-order success followed by pending keeps
the final state `SUCCEEDED`; a lost client connection resolves through server
refresh; a forced local `PENDING` drift reconciles to one settlement without a
second stock movement or provider charge; an online refund goes through the
sandbox provider and is linked to the existing reversal; unsettled and double
refunds are rejected; the settlement report has zero drift. The live transcript
and exact counts are in the pull request.

What was not verified: any real QRIS provider call, real webhook delivery from a
provider, production credential rotation, scheduled reconciliation and
multi-instance deployment. Provider selection and commercial setup remain
prerequisites. The step-by-step recipe is in `docs/payments.md`.

## Promotions, modifiers, partial refunds and approvals (#21)

What was verified on this VPS: promotion eligibility, stacking rejection, half-up
rounding, fixed-discount capping, modifier pricing and stock consumption, partial
refunds with independent money/restock decisions, repeated-line rejection,
idempotent concurrent refunds, approval thresholds for cashier and owner, and
append-only approval/refund/promotion audit rows. Details and the limit list are
in `docs/promotions-refunds.md`.

What was not verified: any real payment-provider refund. No money moves through
this API; `externalRefundPerformed` is always `false` and settlement remains a
manual operational step. This is deferred to the payment-integration ticket.

## Purchasing and stock control (#24)

What was verified on this VPS: suppliers, purchase orders with repeated partial
receipts, supplier-to-base and base-to-supplier conversion, exact-fraction and
overflow rejection, over-receipt rejection, stock-count variance with reason and
actor, waste with a mandatory reason, transfer dispatch/receive in-transit
exclusion, cancel restoration, double-receive rejection and concurrent receive
behaviour. The live transcript and movement counts are in the pull request.

What was not verified: supplier invoices, supplier payments, landed cost, real
supplier EDI or portal integration, and barcode scanning hardware. These are not
part of ticket #24. Transfer reconciliation across a real multi-device warehouse
operation also needs a later field test.

## Verification limits of this ticket

- The VPS has no Android device and no receipt printer.
- The API sale was driven directly through the same endpoint the Flutter app calls.
  This is not a substitute for an app UI result.
- The owner web reconciliation was run with Playwright at 320 px and 1440 px against
  synthetic data.
- The backup/restore dry run used a scratch PostgreSQL database. It proves the logical
  dump/restore procedure, not production recovery objectives.
- Crash recovery of the API process itself, network partitions and timezone edge cases
  beyond `Asia/Jakarta` were not exhaustively tested.

## Reproduction environment

| Item | Value |
| --- | --- |
| OS | Ubuntu 24.04 arm64 |
| Node | 22.23.1 |
| pnpm | 9.12.3 |
| Flutter/Dart | 3.47.0 / 3.13.0 |
| Java | OpenJDK 17 |
| Docker / Compose | 29.1.3 / v2.40.3 |
| PostgreSQL | 17.6-alpine |
| Web port | 3001 |
| API port | 4000 |

All data used for this verification is synthetic. Production go-live remains a
separate, explicit release decision.


## Online ordering, customers and digital receipts (#27)

What was verified on this VPS: signed web channel orders, sequential and
concurrent duplicate delivery producing exactly one local order and one stock
effect, invalid signature and stale timestamp rejected with no state change,
acceptance consuming the pinned recipe quantity once, accepted cancellation
restoring the exact quantity, cash-on-pickup fulfilment recording exactly one
payment, opt-in customer creation, rejection without consent, retention purge of
a backdated customer and receipt, public receipt rendering, and expired/foreign
receipt tokens returning 404. The live transcript and counts are in the pull
request.

What was not verified or implemented:

- No GrabFood, ShopeeFood or other third-party ordering account exists on this
  VPS. Those channels return `PENDING_CREDENTIALS`; the reproduction recipe is in
  `docs/online-ordering.md`.
- No email or SMS provider exists on this VPS. Receipt artifacts, links, expiry
  and retention are real; dispatch is `PENDING — requires provider credentials`
  with a recipe in the same document.
- Prepaid provider capture for channel orders is not implemented. Only
  `CASH_ON_PICKUP` is enforced.
- Channel order lines do not apply modifiers or promotions.
- Stock is not reserved while an order is in `RECEIVED`; it is taken on
  acceptance.
- The retention purge is owner-triggered. Scheduling it on the host is a
  deployment concern, not a bundled worker.

