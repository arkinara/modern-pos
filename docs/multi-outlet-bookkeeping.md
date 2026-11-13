# Multi-outlet bookkeeping and auditable exports

Status date: 2026-11-13. This document defines outlet scoping, consolidated
owner views, inventory costing, expense categories, the profit/margin
availability gate, and the calculation behind every export column.

## Outlet scoping rule

Every business record that belongs to one outlet is addressed through
`/v1/outlets/{outletId}/...` and is checked by the global outlet scope guard
before the controller runs.

- An owner receives every outlet in their own business in the session
  `outletIds` list and may switch between them.
- A cashier receives exactly their assigned outlet.
- A request for an outlet outside that list returns `404 NOT_FOUND`, including
  a request for another business' outlet. This avoids confirming that an outlet
  ID exists.
- Owner-only bookkeeping routes additionally return `403 FORBIDDEN` when an
  owner calls an owner view for an outlet that is in scope but the route itself
  is restricted. A cashier reaching the same route after the scope check is
  denied by the role guard.

New endpoints follow the same rule: bookkeeping configuration, costing method,
expense categories, expenses, profit, consolidated views, and all four CSV
exports. `GET /v1/outlets` is the only additive outlet route without an
`outletId`; it returns only the session's visible outlets, so a cashier sees
one row and an owner sees every business outlet.

Menus, prices, stock balances, staff shifts, attendance, operation audit rows,
sales, reversals, payments, purchasing, recipes, printing and existing reports
were already outlet-scoped. This ticket adds tests and a live cross-outlet
check rather than a second scope mechanism.

## Consolidated owner view

`GET /v1/outlets/{outletId}/bookkeeping/consolidated?from=YYYY-MM-DD&to=YYYY-MM-DD`
uses the anchor outlet only for the scope check. It then reads every outlet in
the owner session's `outletIds` and calls the same daily-report calculation used
by `/reports/daily` for each outlet. There is no second pricing, tax, reversal
or money engine.

Consolidated arithmetic:

```text
grossItemSalesMinor       = sum(perOutlet.grossItemSalesMinor)
reversalItemValueMinor    = sum(perOutlet.reversalItemValueMinor)
netItemSalesMinor         = sum(perOutlet.netItemSalesMinor)
refundMoneyMinor          = sum(perOutlet.refundMoneyMinor)
saleCount                 = sum(perOutlet.saleCount)
reversalCount             = sum(perOutlet.reversalCount)
averageBillMinor          = halfUp(consolidated gross / consolidated saleCount)
stockValueMinor           = sum(perOutlet.stockValueMinor) when every value is known
shiftsOpened              = count(shifts opened inside each outlet-local range)
shiftsClosed              = count(those shifts whose status is CLOSED)
attendanceClockIns        = count(attendance rows whose clock-in is in range)
```

Payment totals are summed by kind (`CASH`, `MANUAL_EXTERNAL`, `ONLINE`) from the
same per-outlet daily reports.

Edge rules:

- Zero outlets return `outletCount = 0` and zero totals. Average bill is `0`,
  never a divide-by-zero error or NaN.
- Per-outlet rows use each outlet's own timezone for its local date range.
- Outlets must share a currency and currency exponent for consolidated money to
  be meaningful. If they do not, `currencyConsistent` is false and the reason is
  exposed; per-outlet rows remain readable.
- If any positive stock balance lacks a receipt cost, per-outlet and consolidated
  stock value are `null` with an `INVENTORY_COST_UNDEFINED` reason instead of a
  fabricated number.

## Inventory costing

Costing is defined per outlet by `PUT /v1/outlets/{outletId}/bookkeeping/costing`.

### Receipt cost source

Only purchase-order receipts provide a cost basis:

- A receipt is a `stock_movements` row of type `RECEIPT` with a non-null
  `purchaseOrderId`.
- The receipt delta is in stock base units.
- The purchase-order line supplies `unitPrice` per supplier unit and
  `unitsPerSupplierUnit`.
- Receipt value in micro-minor units is
  `round_half_up(receivedBaseQuantity × unitPrice × 1,000,000 ÷ unitsPerSupplierUnit)`.

Opening balances, manual receipts without a purchase order, adjustments, stock
counts, transfers and sale reversals do not invent a cost. A transfer-in has no
cost basis until a receipt cost exists for that outlet item. This is deliberate:
the alternative would silently copy a source-outlet value that this ticket does
not define.

### Methods

`MOVING_AVERAGE` (default choice for the live transcript):

```text
unitCostMicros = round_half_up(total receipt value micros × 1,000,000
                               ÷ total received base-quantity micros)
```

`LAST_PURCHASE`:

```text
unitCostMicros = round_half_up(newest receipt value micros × 1,000,000
                               ÷ newest received base-quantity micros)
```

Both methods use integers only. Quantities are converted to integer micro-units;
prices and received values use Prisma's decimal arithmetic for parsing and an
explicit half-up conversion to integer micros. No floating-point money
arithmetic is used. `MONEY_OUT_OF_RANGE` is returned rather than silently losing
precision beyond the JavaScript safe-integer range.

The selected method is evaluated as of the report end. Receipts at or after the
range end are not used. Changing the method changes COGS deterministically; the
unit test compares moving-average and last-purchase receipts.

### COGS and waste

- **COGS** is the cost of `SALE` stock movements in the outlet-local range at the
  selected unit cost.
- **Reversal restock credit** is the cost of `REVERSAL` stock movements in the
  range. Only stock actually restored by the explicit reversal path creates such
  a movement, so an un-restocked refund remains an inventory cost.
- **Net COGS** is sale cost minus reversal restock credit.
- **Waste expense** is the cost of `WASTE` stock movements in the range.
- Negative stock-count variances are not silently reclassified as waste or COGS.

If any stock item used by a sale, reversal or waste movement has no receipt cost
inside the report window, the whole COGS/waste calculation is marked unavailable.
Partial COGS is never presented as complete.

## Expense categories

Expense categories are business-wide, explicit records created through
`POST /v1/outlets/{outletId}/bookkeeping/expense-categories`. The seed provides
Payroll, Rent and utilities, Marketing, Cash adjustment, and Other operating
expense.

Manual operating expenses are recorded with:

- category ID,
- non-negative integer minor units,
- outlet-local calendar date (`incurredOn`),
- optional note,
- creator and creation timestamp.

Stock waste is a **derived** expense line valued at inventory cost. The database
does not store a second money amount for it, so changing the costing method
changes both COGS and the derived waste expense in a predictable way.

Inventory purchases are capitalised into the moving-average/last-purchase cost.
They are deliberately **not** also counted as an operating expense, which would
double-count them. Payroll, rent, marketing and cash adjustments are manual
entries because no payroll or ledger integration exists in this ticket.

## Profit and margin availability gate

`GET /v1/outlets/{outletId}/bookkeeping/profit` returns revenue from the daily
report and then reports profit only when all of these are true:

1. a costing method is defined for the outlet;
2. at least one active expense category exists;
3. every stock item consumed by a sale, reversal or waste in the range has a
   receipt cost as of the range end.

If any condition fails:

- `marginAvailable` is `false`;
- `unavailableReasons` contains one or more of
  `COSTING_METHOD_UNDEFINED`, `EXPENSE_CATEGORIES_UNDEFINED`,
  `INVENTORY_COST_UNDEFINED`;
- `cogs`, `grossProfitMinor`, `netProfitMinor` and `netMarginBps` are `null`;
- the UI shows an unavailable row and the reason. It never substitutes zero,
  last period's number, or an estimate.

Formulas when available:

```text
grossProfitMinor = netItemSalesMinor − netCogsMinor
totalExpenseMinor = manualExpenseMinor + wasteExpenseMinor
netProfitMinor = grossProfitMinor − totalExpenseMinor
netMarginBps = round_half_up(netProfitMinor × 10,000 ÷ netItemSalesMinor)
```

If net item sales are zero, net profit may still be known but margin percent is
undefined. `netMarginBps` is then `null` with `marginBpsUnavailableReason =
ZERO_REVENUE`.

Revenue itself always comes from the existing daily report, so a profit row for
the same range reconciles to `/reports/daily` for gross sales, reversal value,
net sales, sale count and reversal count.

## Auditable exports

All exports are owner-only and outlet-scoped. They use UTF-8, RFC 4180 quoting
(comma separator, CRLF line endings, doubled quotes), a final CRLF, and
formula-trigger neutralisation (`=`, `+`, `-`, `@`, tab, carriage return get a
leading apostrophe). Empty ranges produce a header row only.

Every export includes the report range and `generatedAt`. Filenames contain the
outlet slug and range.

### `exports/sales.csv`

One row per sale line for completed sales in range, followed by one row per
reversed/refunded line. The existing `reports/sales.csv` column definitions are
unchanged; these columns are appended:

| Column | Definition |
| --- | --- |
| `reportFrom` | Inclusive outlet-local start date of this export. |
| `reportTo` | Inclusive outlet-local end date. |
| `generatedAt` | UTC ISO-8601 timestamp when the export was generated. |

Existing columns keep their documented daily-report meaning: `rowType` is
`SALE`, `REVERSAL` or `REFUND`; reversal rows carry negative item quantities and
money; `saleSubtotalMinor` is the immutable sale snapshot subtotal.

### `exports/reversals.csv`

One row per reversal in range, independent of whether the original sale falls in
the same range.

| Column | Definition |
| --- | --- |
| `reference` | Reversal row ID. |
| `saleReference` | Immutable sale reference being corrected. |
| `kind` | `FULL` or `PARTIAL`. |
| `createdAtUtc` | Reversal creation time in UTC. |
| `createdAtLocal` | Same instant rendered in the outlet timezone. |
| `timezone` | Outlet IANA timezone. |
| `reason` | Operator reason stored on the reversal. |
| `refundMoneyMinor` | Full reversal: original sale subtotal. Partial: the explicit refund amount. |
| `currency` / `currencyExponent` | Snapshot currency of the original sale. |
| `refundedItems` | For partial refunds, refunded sale lines and quantities. For full reversals, all original sale lines. |
| `restockJson` | Stored explicit restock selection (stock item IDs and quantities). |
| `actorEmail` | Account that recorded the reversal. |
| `reportFrom`, `reportTo`, `generatedAt` | Export metadata. |

Sum of `refundMoneyMinor` and row count reconcile to
`reversalCount`/`refundMoneyMinor` in the daily report for the same range.

### `exports/payments.csv`

One row per payment record attached to a completed sale in range.

| Column | Definition |
| --- | --- |
| `paymentId` | Payment record ID. |
| `saleReference` | Sale reference. |
| `kind` | `CASH`, `MANUAL_EXTERNAL` or `ONLINE`. |
| `status` | Recorded provider/local payment status. |
| `completedAtUtc` / `completedAtLocal` | Sale completion instant in UTC and outlet local time. |
| `timezone` | Outlet IANA timezone. |
| `currency` / `currencyExponent` | Sale currency snapshot. |
| `amountMinor` | Recorded payment amount, including unsettled online attempts. |
| `tenderedMinor` / `changeMinor` | Cash tendered and change when recorded; blank otherwise. |
| `paymentReference` | External/manual reference when present. |
| `saleTotalMinor` | Immutable sale total. |
| `countsAsReportedReceived` | `false` for an online attempt in `PENDING`, `FAILED` or another non-settled status; `true` otherwise. |
| `reportReceivedMinor` | `amountMinor` when `countsAsReportedReceived` is true, otherwise `0`. |
| `reportFrom`, `reportTo`, `generatedAt` | Export metadata. |

The daily report only counts settled online money. Reconcile by summing
`reportReceivedMinor` by `kind`; that sum equals the daily `paymentBreakdown`
for the same range. The full `amountMinor` column remains auditable for
unsettled attempts.

### `exports/accounting.csv`

One summary row per outlet and range. Columns:

| Column | Definition |
| --- | --- |
| `outletId`, `outletName` | Outlet identity snapshot. |
| `reportFrom`, `reportTo`, `timezone` | Range and outlet-local timezone. |
| `currency`, `currencyExponent` | Outlet currency. |
| `generatedAt` | Export timestamp. |
| `costingMethod` | `MOVING_AVERAGE`, `LAST_PURCHASE`, or blank if undefined. |
| `marginAvailable` | `true` or `false`; false means profit columns are blank, never zero. |
| `unavailableReasons` | Pipe-separated gate reasons. |
| `grossItemSalesMinor` | Daily-report gross item sales. |
| `reversalItemValueMinor` | Daily-report reversal item value. |
| `netItemSalesMinor` | Gross minus reversal item value. |
| `saleCount`, `reversalCount` | Daily-report counts. |
| `saleCostMinor` | Cost of `SALE` stock movements at the selected unit cost. |
| `reversalRestockCreditMinor` | Cost of `REVERSAL` restock movements. |
| `netCogsMinor` | Sale cost minus restock credit. |
| `wasteCostMinor` | Cost of `WASTE` movements. |
| `manualExpenseMinor` | Manual operating expenses in range. |
| `wasteExpenseMinor` | Same value as `wasteCostMinor`, exposed as an expense line. |
| `totalExpenseMinor` | Manual plus waste expense. |
| `grossProfitMinor` | Net item sales minus net COGS. |
| `netProfitMinor` | Gross profit minus total expenses. |
| `netMarginBps` | Net profit basis points of net item sales; blank when undefined. |

The accounting CSV is generated from the same service response as
`GET /bookkeeping/profit`, so every field reconciles field-by-field. The live
verification transcript checks all 15 numeric fields and the three formulas.

## Reconciliation method

For a range:

1. Read `/reports/daily` for the outlet.
2. Export `sales.csv`; group rows by sale reference and reversal event. Distinct
   sale references and gross subtotals must equal `saleCount` and
   `grossItemSalesMinor`; distinct reversal subtotals must equal
   `reversalItemValueMinor`; their net must equal `netItemSalesMinor`.
3. Export `reversals.csv`; row count and refund sum must equal `reversalCount`
   and `refundMoneyMinor`.
4. Export `payments.csv`; sum `reportReceivedMinor` by kind and compare with
   `paymentBreakdown`.
5. Export `accounting.csv`; compare every field with the profit response and
   check `net revenue − net COGS − total expenses = net profit`.

## Snapshot and concurrency behaviour

- Sales, reversals and payments exports each execute one PostgreSQL `findMany`
  statement at the default read-committed isolation. A sale committed before the
  statement's snapshot appears in full; a sale committed after it does not
  appear at all. No half-sale or half-payment row can be produced by a single
  statement.
- The accounting summary and profit report combine the daily report and cost
  reads. A sale can commit between those reads. The response exposes
  `generatedAt` and the exact range; repeat the export for a new snapshot if a
  concurrent sale is not acceptable. This is a documented limitation, not a
  claim of a serializable cross-query snapshot.
- Exports never write to sales, payments, reversals, stock or costing records.

## Limits

- Only moving average and last purchase are implemented. FIFO, LIFO, standard
  cost and landed-cost allocation are not implemented.
- Receipt cost does not include freight, duties, discounts or supplier invoices.
- Transfer-in stock has no automatic cost carry from the source outlet.
- Opening balances and manual receipts without a purchase order have no invented
  cost.
- Expense categories are business-wide; a category cannot be scoped to only one
  outlet.
- There is no payroll, accounts-payable, tax or bank-ledger integration. Manual
  expense entries are the only non-waste operating costs.
- Consolidated money requires one shared currency and exponent.
- Negative stock-count variances are excluded from COGS and waste; they remain
  visible only in the stock ledger.
- A zero-revenue period has a known profit amount but an undefined margin
  percentage.
