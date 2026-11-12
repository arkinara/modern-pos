# Sale reversal and stock restoration

## Purpose

A completed sale can be corrected by an owner through a full reversal or a partial refund. The
manual, non-cash correction path is described here; online sales additionally use the provider
refund flow in `docs/payments.md`.

The original sale row is immutable. A reversal is a separate append-only record linked to the sale.
`sales_get` returns the linked `reversal` object when one exists. The sale totals, sale lines and
payment record are never updated by a reversal.

## API operation

```
POST /outlets/{outletId}/sales/{saleId}/reversals
Idempotency-Key: <uuid>
Content-Type: application/json

{
  "reason": "Customer returned the order",
  "restock": [
    { "stockItemId": "<uuid>", "quantity": "3" }
  ]
}
```

`reason` is required and must contain 3 to 500 characters after trimming.

`restock` is required. It may be empty for a financial-only reversal. Every entry must reference a
stock item that this sale actually consumed, and the requested quantity must be positive, no more
precise than the stock item quantity scale, and no greater than the amount consumed by the sale.

A successful response is `201`:

```json
{
  "id": "<reversal uuid>",
  "saleId": "<sale uuid>",
  "reason": "Customer returned the order",
  "createdAt": "2026-11-10T08:00:00.000Z",
  "restock": [{ "stockItemId": "<uuid>", "quantity": "3" }],
  "externalRefundPerformed": false
}
```

Manual reversals and non-cash corrections keep `externalRefundPerformed` `false`; the example above
is that manual path and never claims a payment provider returned money. For an online sale the
response can contain `externalRefundPerformed: true` once the provider confirms the refund, with
`providerRefundRef` linking the reversal to the provider result. See `docs/payments.md`.

## Authorization and scoping

Only an `OWNER` can record a reversal. A cashier receives `403`. The route is also scoped to the
authenticated business and outlet. Unknown sales, sales from another outlet and sales from another
business return `404` rather than leaking their existence.

Only completed sales can be reversed. Reversing an already-reversed sale returns
`409 SALE_ALREADY_REVERSED`.

## Idempotency semantics

`Idempotency-Key` is required and must be a UUID. The key is scoped to the outlet.

- Repeating the same key with the same payload returns the stored reversal response and does not
  create another reversal, financial record or stock movement.
- Reusing the same key with a different sale, reason or restock selection returns
  `409 IDEMPOTENCY_CONFLICT`.
- Using a second key against a sale that already has a reversal returns
  `409 SALE_ALREADY_REVERSED`.
- Concurrent retries with the same key serialize on the sale row. Exactly one reversal and one set
  of restock movements commit; the other request replays the stored response.

The application asks clients to keep the same key while retrying the same form values.

## Restock policy

Restocking is explicit. The service never restores consumed ingredients automatically.

- Empty `restock` is legal and leaves all stock balances and movement counts unchanged.
- Each selected item creates one positive `StockMovement` of type `REVERSAL`, with
  `sourceId` set to the reversal id.
- Balances are locked in sorted `stockItemId` order before update. The write uses the same bounded
  retry and atomic balance path as other stock writes.
- Recipe-derived deductions are only restored when the caller lists that exact stock item.
- An item that the sale never consumed returns `422 RESTOCK_ITEM_NOT_SOLD`.
- A zero, over-precise or over-consumed quantity returns `422`.

The back-office form derives a suggested quantity from the current recipe, but the API validates
against the recipe version pinned on the original sale.

## Reports

`GET /outlets/{outletId}/reports/daily` reports:

- `grossItemSalesMinor`: completed sales in the period, unchanged by reversals.
- `reversalItemValueMinor`: item subtotal of reversals recorded in the period.
- `netItemSalesMinor`: gross minus reversal item value.
- `saleCount`: number of completed sales, unchanged by reversals.
- `reversalCount`: number of reversals recorded in the period.

Reversals are attributed to the date they were recorded. The CSV export includes a `rowType`
column with `SALE` or `REVERSAL`, a `reversalReason` column, and negative item amounts for reversal
rows so spreadsheets can reconcile totals directly.

## Out of scope

- Partial or line-level refunds.
- Payment-provider refunds, voids or settlement reversal.
- Cash drawer or tender adjustments.
- Reopening or editing the original sale.
- Mobile reversal entry.
- Production verification and Phase 2 refund workflows.
