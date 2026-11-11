# Table orders, transfers, split bills and cancellation

Status date: 2026-11-11. This document defines the supported dine-in behaviour
added in ticket #20. It is authoritative for the server rules; the cashier app
mirrors the same wording.

## Reservation policy

A table order is a normal `DRAFT` order that references one `dining_table`.
Opening it **does not reserve or consume stock**. Stock is consumed exactly once
when a bill settles through `POST /outlets/{outletId}/sales/finalize`, using the
existing recipe and stock-ledger path.

Why: the existing sales contract treats drafts as unpriced intent. Reserving
stock at open time would require expiry, release and shortage handling for every
abandoned table, and would make two tables race for the same ingredient before
any money is taken. The server therefore stays authoritative at settlement, and
the cashier UI states that opening reserves nothing.

Consequences:

- A table can be opened even when stock is low; settlement still rejects the
  sale with `422 INSUFFICIENT_STOCK` and writes nothing.
- Cancelling an unpaid order releases nothing because nothing was held.

## Transfer policy

`POST /outlets/{outletId}/orders/{orderId}/transfer` moves a draft order to a
different active table in the same outlet.

- Owner only. A cashier receives `403 FORBIDDEN`.
- Requires the current `version`; a stale version returns `409 VERSION_CONFLICT`.
- The target table must belong to the outlet and be active, otherwise `404`.
- Moving to the current table returns `422 TABLE_UNCHANGED`.
- A completed, cancelled or split order returns `409 ORDER_NOT_DRAFT`.
- Every successful transfer writes an append-only `order_audits` row with actor,
  timestamp, `fromTableId`, `toTableId` and both table labels.

## Split bill policy

`POST /outlets/{outletId}/orders/{orderId}/splits` replaces one draft order with
two to twenty independent draft bills.

- Requires `Idempotency-Key`. Replaying the same key and payload returns the same
  child bills and creates no new rows; a different payload returns
  `409 IDEMPOTENCY_CONFLICT`.
- Requires the current `version`. Two cashiers splitting the same revision cannot
  both succeed; the loser gets `409 VERSION_CONFLICT` and no bills.
- Every original item quantity must be allocated exactly once across the bills.
  Overlapping, missing, unknown or non-positive quantities return
  `422 SPLIT_MISMATCH`. Fewer than two bills returns `400`.
- The parent order becomes `SPLIT` and can never settle. Each child is a normal
  `DRAFT` order with its own quote, finalize request and unique sale row.
- Therefore stock is consumed once per child quantity, payments are recorded per
  child sale, and the sum of child bill totals equals the original order total
  at the same outlet pricing snapshot.
- Settlement is independent. If bill 1 settles and bill 2 fails, bill 2 remains
  a resumable draft; there is no compensating stock movement because stock is
  only written inside a successful settlement transaction.
- Idempotent finalize replay of an already settled child returns the same sale.

The cashier app's "Split 2 ways" action divides every line evenly. Orders whose
total quantity is a single unit cannot produce two non-empty bills and the app
explains that instead of sending an invalid split.

## Cancellation policy

`POST /outlets/{outletId}/orders/{orderId}/cancel` cancels an unpaid draft.

- Requires the current `version`; stale versions return `409 VERSION_CONFLICT`.
- Only `DRAFT` orders can be cancelled. `SPLIT`, `COMPLETED` and already
  `CANCELLED` orders return `409 ORDER_NOT_DRAFT`.
- No stock movement is written. The order lines remain for history but are never
  settled.
- An append-only audit row records actor, order, table (if any) and
  `metadata.stockConsumed = false`.
- Attempting to settle a cancelled order returns `409 ORDER_NOT_DRAFT` before any
  payment or stock write.

## Permissions

| Operation | Owner | Cashier |
| --- | --- | --- |
| List active tables | yes | yes |
| Create a table | yes | `403` |
| List open draft orders | yes | yes, same outlet |
| Read one order | yes | yes, same outlet |
| Open a table order | yes | yes |
| Update/cancel/split own draft | yes | yes |
| Split another cashier's draft | yes | `404` |
| Transfer a table order | yes | `403` |
| Read the order audit trail | yes | `403` |
| Settle a draft or split bill | yes | yes |

Cross-outlet outlet IDs are rejected by the outlet-scope guard with `404`.
Cross-outlet order IDs are rejected by the service with `404`.

## Audit trail

`order_audits` is append-only. A database trigger rejects `UPDATE` and `DELETE`.
Rows are written for `OPEN`, `UPDATE`, `TRANSFER`, `SPLIT`, `CANCEL` and
`FINALIZE`, with actor, order, outlet, optional table transition and a JSON
metadata snapshot (for example child bill IDs or the settled sale ID).

Owners read the trail with `GET /outlets/{outletId}/orders/{orderId}/audit`.

## Limits

- One active open order per table is expected but not enforced; the cashier app
  shows the first open order per table. Multiple drafts at one table remain
  valid server-side and are all listed by `GET /outlets/{outletId}/orders`.
- Split quantity is per line and integer; partial unit splits are not supported.
- Table creation and editing are API-only in this ticket; there is no back-office
  table management screen.
- The web back office intentionally has no cashier, cart, checkout or tender
  routes. Dine-in actions belong to the Flutter cashier app.
