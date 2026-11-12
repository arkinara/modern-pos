# Purchasing and stock control (#24)

Status date: 2026-11-12. This document describes suppliers, purchase orders,
stock counts, waste and outlet transfers added on top of the append-only stock
ledger. Every quantity in the ledger is stored in the stock item base unit as a
fixed-point `DECIMAL(20,6)`. Existing opening, receipt, adjustment, sale and
reversal behaviour is unchanged.

## Supplier records

Suppliers are business-wide records. The minimal fields are:

- `name` (required, up to 200 characters)
- `reference` (optional, unique per business when present)
- `contact` (optional free text)

Create and list suppliers through `/v1/outlets/{outletId}/suppliers`. The outlet
path is used for authorization scope only; supplier rows belong to the business.
Supplier management requires the `supplier.manage` permission, which only an
owner holds today.

## Purchase orders and partial receipt

A purchase order belongs to one receiving outlet and one supplier. Each line
has:

- a stock item reference
- a supplier unit label (for example `case`)
- `unitsPerSupplierUnit`, the exact base-unit factor for that unit
- an ordered quantity in supplier units
- a unit price stored as a fixed-point decimal

The server computes `orderedBaseQuantity = orderedSupplierQuantity x
unitsPerSupplierUnit` at creation with decimal arithmetic. It rejects the order
when that base quantity needs more decimals than the stock item `quantityScale`
allows. Nothing is rounded.

An order can be cancelled only before any receipt. A cancelled order rejects
further receipts with `409 PURCHASE_ORDER_CANCELLED`. An order with any receipt
cannot be cancelled (`409 PURCHASE_ORDER_HAS_RECEIPTS`).

Receipts are per line and may arrive in either unit:

```json
{ "lineId": "...", "quantity": "4", "unit": "SUPPLIER", "note": "First delivery" }
```

- `SUPPLIER`: base delta is `quantity x unitsPerSupplierUnit`.
- `BASE`: supplier delta is `quantity / unitsPerSupplierUnit`. The division must
  be exact at six supplier decimals; otherwise the request is rejected. This
  direction is what makes a wrong unit impossible to hide.

Each receipt:

1. Locks the purchase order row so concurrent receipts serialize.
2. Checks the line version with a conditional update. A concurrent receipt on the
   same line loses with `409 RECEIPT_CONFLICT`.
3. Rejects over-receipt with `422 OVER_RECEIPT` before writing any ledger row.
4. Rejects a receipt on a `RECEIVED` or `CANCELLED` order with
   `409 PURCHASE_ORDER_CLOSED` or `409 PURCHASE_ORDER_CANCELLED`.
5. Writes one `StockMovement` of type `RECEIPT` with the purchase order id,
   supplier id, actor, reason and base-unit delta.
6. Updates the order to `PARTIALLY_RECEIVED` or `RECEIVED`. A fully received order
   gets `closedAt`.

Unit-conversion examples:

| Supplier unit | Factor | Receipt | Base delta | Result |
| --- | --- | --- | --- | --- |
| case | 12 | 4 supplier | 48 | accepted |
| kilogram | 1000 | 1500 base | 1500 | accepted; supplier quantity 1.5 |
| case | 12 | 5 base | - | rejected, not an exact pack fraction |
| pack | 0.333333 | 1 supplier with item scale 2 | - | rejected, precision would round |

The ledger response exposes `supplierId`, `supplierName`, `supplierReference`,
`purchaseOrderId` and `purchaseOrderReference`. The movement list supports
`type`, `reason`, `supplierId` and `supplierReference` filters.

## Stock counts

A stock count takes one or more counted quantities and a mandatory reason
(3-500 characters). For each line the server snapshots the current system
quantity and computes `variance = countedQuantity - systemQuantity`.

- A zero variance writes no ledger row.
- A non-zero variance writes one `COUNT` movement with the reason and actor.
- The count record stores the snapshot, counted quantity and variance.
- The stock balance is adjusted by the ledger delta, never overwritten directly.

A count without a reason fails validation with `400`. The count is scoped to one
outlet and is available to owners and cashiers.

## Waste and loss

Waste removes a positive base quantity with a mandatory reason from the set
`DAMAGE`, `EXPIRY`, `THEFT`, `SPOILAGE` or `OTHER`, plus an optional note. Each
waste record writes one `WASTE` movement with a negative delta, the reason, the
note and the actor.

- A missing reason fails validation with `400`.
- A quantity that would make the balance negative is rejected with
  `422 INSUFFICIENT_STOCK`.
- Waste is available to owners and cashiers.

Counts and waste are distinguishable in the ledger by `type`, `reason` and
`actorId`.

## Outlet transfers

Transfers move stock between two outlets in the same business. A transfer record
has a source outlet, a destination outlet and positive base-unit line
quantities. The state machine is:

```text
DRAFT --dispatch--> DISPATCHED --receive(all)--> RECEIVED
  |                     |
  +-------cancel--------+--> CANCELLED
```

- `DRAFT`: no stock has moved.
- `dispatch`: writes one negative `TRANSFER_OUT` movement per line at the source
  and subtracts the source balances. The total leaves the source immediately.
- `DISPATCHED`: the un-received part is in transit. It is not in the source
  balance and it is not yet in the destination balance.
- `receive`: writes one positive `TRANSFER_IN` movement per received line at the
  destination. Partial receives are allowed. The transfer stays `DISPATCHED`
  until every line is fully received, then becomes `RECEIVED`.
- `cancel`: allowed for `DRAFT` and fully un-received `DISPATCHED` transfers. A
  dispatched cancel writes `TRANSFER_CANCEL` movements that restore the source
  exactly. A partially or fully received transfer cannot be cancelled
  (`409 TRANSFER_PARTIALLY_RECEIVED` or `409 TRANSFER_ALREADY_RECEIVED`).

Negative conditions:

- Receive on a non-dispatched transfer: `409 TRANSFER_NOT_DISPATCHED`.
- Double receive after full receipt: `409 TRANSFER_ALREADY_RECEIVED`.
- Receive more than the outstanding dispatched quantity: `422
  RECEIVE_EXCEEDS_DISPATCHED`.
- Dispatch without enough source stock: `422 INSUFFICIENT_STOCK`, with no
  partial ledger write.
- Concurrent receive: the transfer row is locked and the line version is checked.
  One request wins; the other gets `409 RECEIVE_CONFLICT` or
  `409 TRANSFER_CONFLICT`.

### No-double-counting invariant

For each transferred quantity:

```text
source delta + destination delta + in-transit quantity = 0
```

After dispatch and before receive, in-transit equals the dispatched quantity.
After full receive, in-transit is zero and the destination balance has increased
by exactly the source decrease. The API reports `inTransitQuantity` per line and
per transfer. In-transit stock is deliberately absent from both outlet balances.

### Cross-outlet permission rule

All transfer operations require the `stock.transfer` permission, which only an
owner holds. The existing outlet scope guard also limits a cashier to its own
outlet. Therefore a cashier of outlet A cannot receive into outlet B. Owners can
operate on any outlet in their business. Counts and waste remain available to
cashiers for their own outlet only.

## Permissions summary

| Operation | Owner | Cashier |
| --- | --- | --- |
| Supplier create/list | yes | no |
| Purchase order create/list/receive | yes | no |
| Stock count create/list | yes | yes, own outlet |
| Waste create/list | yes | yes, own outlet |
| Transfer create/dispatch/receive/cancel | yes | no |
| Stock item list | yes | yes, own outlet |
| Stock item create and manual opening/adjustment | yes | no |

## Concurrency, retries and limits

- Purchase receipts lock the purchase order row and use a line version check.
- Transfers lock the transfer row; dispatch and receive use conditional version
  updates on the transfer and line rows.
- Stock counts lock each counted stock item row for the transaction.
- The ledger remains append-only. Every write also checks that
  `SUM(delta) = balance` for the affected outlet and item.
- Quantity inputs are limited to 13 integer digits and 6 decimal places.
  Conversion factors are limited to 1,000,000. Base quantities above
  100,000,000,000,000 are rejected with `422 CONVERSION_OVERFLOW`.
- There is no supplier invoice, payment, tax or landed-cost calculation in this
  ticket.

## Error codes added by this ticket

| Code | Status | Meaning |
| --- | --- | --- |
| `SUPPLIER_REFERENCE_CONFLICT` | 409 | Supplier reference already used in this business |
| `PURCHASE_ORDER_REFERENCE_CONFLICT` | 409 | Purchase order reference already used |
| `PURCHASE_ORDER_CLOSED` | 409 | Order is fully received |
| `PURCHASE_ORDER_CANCELLED` | 409 | Order was cancelled |
| `PURCHASE_ORDER_HAS_RECEIPTS` | 409 | An order with receipts cannot be cancelled |
| `OVER_RECEIPT` | 422 | Receipt would exceed the ordered quantity |
| `CONVERSION_NOT_EXACT` | 422 | Unit conversion would need rounding |
| `CONVERSION_OVERFLOW` | 422 | Converted quantity is too large |
| `QUANTITY_PRECISION_EXCEEDED` | 422 | Quantity exceeds the item quantity scale |
| `RECEIPT_CONFLICT` | 409 | Concurrent receipt changed the line |
| `STOCK_COUNT_REFERENCE_CONFLICT` | 409 | Count reference already used |
| `TRANSFER_REFERENCE_CONFLICT` | 409 | Transfer reference already used |
| `TRANSFER_NOT_DRAFT` | 409 | Only a draft can be dispatched |
| `TRANSFER_NOT_DISPATCHED` | 409 | Receive requires a dispatched transfer |
| `TRANSFER_ALREADY_RECEIVED` | 409 | Transfer is already fully received |
| `TRANSFER_CANCELLED` | 409 | Transfer is already cancelled |
| `TRANSFER_PARTIALLY_RECEIVED` | 409 | Partially received transfer cannot be cancelled |
| `RECEIVE_EXCEEDS_DISPATCHED` | 422 | Receive exceeds the outstanding quantity |
| `RECEIVE_CONFLICT` | 409 | Concurrent receive changed the line |
| `TRANSFER_CONFLICT` | 409 | Concurrent state change |

## Verification limits

The live transcript for #24 runs against the local PostgreSQL container and the
API on port 4000. It covers partial receipts, conversion in both directions,
over-receipt rejection, count variance, waste, dispatch/receive totals,
in-transit exclusion and double receive. No physical Android device or supplier
portal is involved. The web UI is exercised with Playwright at 320 px and
1440 px on synthetic data.
