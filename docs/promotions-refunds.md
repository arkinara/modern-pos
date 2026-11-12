# Promotions, modifiers, partial refunds and approval rules

Status date: 2026-11-12. API version 0.8.0. This document describes the behaviour
implemented by ticket #21. All prices and discounts are integer currency minor
units (IDR exponent 0 in the demo). The server is the only pricing authority; the
web and mobile clients never compute a final price.

## Promotions

### Eligibility

A promotion is eligible only when every rule below passes. Failing any rule
rejects the request with `422 PROMOTION_NOT_ELIGIBLE`, never a silent discount.

| Rule | Behaviour |
| --- | --- |
| Active | `active` must be true. |
| Outlet | The promotion row stores one `outletId`; only that outlet can apply it. |
| Date window | `startsAt <= now <= endsAt` in server time. Both bounds are inclusive. Missing bounds are unbounded. |
| Customer | If `eligibility.customerEmails` is non-empty, the quote `customerEmail` must match one entry case-insensitively. Without a quote email the promotion cannot apply. |
| Items | If `eligibility.variantIds` or `eligibility.menuItemIds` is non-empty, only matching order lines count. Both lists combine as an OR. |
| Minimum basket | `minBasketMinor` is compared with the eligible line subtotal (unit price after modifiers, before discount). |

An empty eligibility object means all variants, menu items and customers at the
promotion's outlet.

### Kinds and rounding

- `PERCENTAGE` uses `percentageBps` (1000 = 10%, maximum 10000 = 100%).
- `FIXED_AMOUNT` uses `amountMinor` off the eligible subtotal.

Each promotion's discount is computed once on its eligible subtotal and rounded
half-up to a whole minor unit. For example, a 5% discount on a 10 minor-unit
basket is `0.5` and rounds to `1` minor unit. Service and tax are then charged on
the discounted subtotal (`subtotal - discount`), not on the gross subtotal.
There are no fractional minor units and no accumulated rounding drift because
every step uses integer arithmetic.

A fixed discount larger than the remaining basket is capped at the remaining
subtotal. A percentage discount is also capped by the remaining subtotal. The
total can never become negative. `totals.discountMinor` reports the applied
amount and `totals.subtotalMinor` remains the gross item subtotal.

### Stacking

`stacking` is either `EXCLUSIVE` or `STACKABLE`.

- One `EXCLUSIVE` promotion may be applied alone.
- Any combination containing an `EXCLUSIVE` promotion plus another promotion is
  rejected with `422 PROMOTION_STACK_NOT_ALLOWED`.
- Any number of `STACKABLE` promotions may combine. They are applied by
  descending `priority`, then by promotion id for a deterministic order.
- A repeated promotion id in `promotionIds` is de-duplicated before pricing. The
  request still succeeds with `201`, the promotion is applied once, and it
  contributes one promotion entry and one `discountMinor`.
- Unknown promotion ids return `404 NOT_FOUND` with `details.promotionIds`
  listing the missing ids.

The same rules are evaluated again at finalize. If a promotion, its window, its
eligibility or the catalog price changed after the quote, finalize returns
`409 QUOTE_STALE` and writes no sale.

### Sale snapshot

A completed sale stores the immutable promotion breakdown in `sale.promotions`
and the total in `sale.discountMinor`. Later edits to a promotion never rewrite a
completed sale. Quote and sale responses expose:

```json
"promotions": [
  { "promotionId": "…", "name": "Lunch 10%", "kind": "PERCENTAGE", "discountMinor": 1800 }
]
```

## Item modifiers

`POST /outlets/{outletId}/modifiers` creates an owner-managed modifier for one
menu item:

| Field | Meaning |
| --- | --- |
| `priceDeltaMinor` | Added to the base unit price per selected modifier quantity. May be negative, but a line unit price may not become negative. |
| `stockItemId` | Optional stock item consumed directly by the modifier. |
| `quantityPerSaleUnit` | Base-unit quantity consumed per selected modifier quantity and per sold unit. Required together with `stockItemId`. |

Order lines accept an optional `modifiers: [{ modifierId, quantity }]`. The
server validates that each modifier belongs to the line's menu item and is
active. The quote line `unitPriceMinor` includes modifier deltas, and each
resolved modifier is snapshotted onto the sale line in `line.modifiers` with its
name, quantity, unit delta, line delta and stock item. Receipts and reports read
the snapshot, not the live catalog.

Stock effects: recipe consumption and modifier consumption are summed at
finalize. Reversal restock validation uses the same combined consumed amount.

## Partial refunds

Refunds extend the existing reversal machinery. There is no second correction
model: `POST /outlets/{outletId}/sales/{saleId}/reversals` records either a full
reversal or a partial refund. The original sale row and its lines are never
updated.

A partial refund request names the refunded sale lines and states money and
restock independently:

```json
{
  "reason": "Customer returned one cup",
  "refundMinor": 9000,
  "lines": [{ "saleLineId": "…", "quantity": 1 }],
  "restock": [{ "stockItemId": "…", "quantity": "3" }]
}
```

Omit `lines` and `refundMinor` for the original full-reversal behaviour. The
server derives the full refund amount from the immutable sale total.

### Money versus restock matrix

| Intent | `refundMinor` | `lines` | `restock` | Result |
| --- | --- | --- | --- | --- |
| Money only | `> 0` | subset | `[]` | Money correction only; no stock movement. |
| Restock only | `0` | subset | explicit items | Stock returned; no money correction. |
| Both | `> 0` | subset | explicit items | One refund record with both effects. |
| Full reversal | omitted | omitted | explicit items | Existing full-reversal semantics. |

Rules enforced by the API:

- A refund line must belong to the sale. Unknown lines return
  `422 REFUND_LINE_NOT_FOUND`.
- A line already fully refunded returns `409 REFUND_ALREADY_COMPLETED` with no
  money or stock movement.
- A quantity beyond the line's remaining quantity returns
  `422 REFUND_EXCEEDS_LINE`.
- Cumulative `refundMinor` across all refunds cannot exceed the sale total;
  otherwise `422 REFUND_EXCEEDS_SALE`.
- A second full reversal returns `409 SALE_ALREADY_REVERSED`. A full reversal is
  also refused when partial refunds already exist.
- Restock is limited to stock items actually consumed by the sale and to the
  remaining consumed quantity across earlier refunds. A non-stock-tracked or
  recipe-less item has nothing to restock and returns `422 RESTOCK_ITEM_NOT_SOLD`.
- Same `Idempotency-Key` and payload replays the same refund with no repeated
  money or stock movement. The same key with a different payload returns
  `409 IDEMPOTENCY_CONFLICT`.

Manual reversals and other non-cash corrections keep `externalRefundPerformed`
`false`; they never claim that money was moved externally. Online sales use the
provider refund path described in `docs/payments.md`: `externalRefundPerformed`
is `true` only after the provider confirms the refund, and the stored
`providerRefundRef` links the reversal to that provider result. Cash, card or
wallet settlement outside that provider flow remains an operational step.

Reports show each refund as a linked record separate from the sale. Full
reversals keep the existing CSV reversal rows; partial refunds add `REFUND` rows
whose amount is the recorded `refundMinor`.

## Approval rules

`PUT /outlets/{outletId}/approval-rules/{action}` configures `DISCOUNT` or
`REFUND`. `action` is one of `DISCOUNT` and `REFUND`; one rule exists per outlet
and action. `thresholdMinor` is inclusive.

- Owner callers always pass (owner is the elevated role).
- A non-owner caller passes when an active rule exists and the amount is at or
  below `thresholdMinor`.
- A non-owner caller above the threshold receives `403 APPROVAL_REQUIRED` with
  `details.action`, `details.amountMinor` and `details.thresholdMinor`.
- With no `REFUND` rule, the pre-existing owner-only refund behaviour is kept.
- With no `DISCOUNT` rule, no discount threshold is applied.

Approval is enforced in the service layer before money or stock changes commit.
It is never a UI-only check. Cross-outlet sale or outlet ids return `404` before
approval is considered.

## Audit history

The existing append-only `order_audits` trail is reused; there is no second audit
system. New actions are:

| Action | Written when | Metadata |
| --- | --- | --- |
| `PROMOTION` | A sale finalizes with one or more promotions. | `saleId`, `discountMinor`, promotion snapshot. |
| `REFUND` | A full reversal or partial refund commits. | `saleId`, `reversalId`, `kind`, `refundMinor`, refunded lines, restock, reason, `externalRefundPerformed` (`false` for manual corrections, `true` only for provider-confirmed refunds). |
| `APPROVAL` | An approval threshold is evaluated. | `operation`, `action`, `allowed`, `elevated`, `reason`, `amountMinor`, `thresholdMinor`. |

`GET /outlets/{outletId}/orders/{orderId}/audit` remains owner-only and returns
who (actor), when (`createdAt`), what (action/metadata) and why (reason or
decision). A rejected over-threshold request still writes an `APPROVAL` row with
`allowed: false`.

## Limits

- Maximum 20 promotion ids per quote, 100 order lines, 20 modifiers per line and
  100 refund lines or restock entries per refund.
- Percentage promotions are capped at 10000 bps.
- Money values must fit the JavaScript safe-integer range and are serialized as
  integer minor units.
- Promotion deletion is not supported; deactivate a promotion instead so the
  historical snapshot remains meaningful.
- No external payment-provider refund, no automatic restock, and no multiple
  concurrent full reversals are supported.

## Verification notes

Unit tests cover eligibility on/off, date-window boundaries, stacking rejection,
half-up rounding at exactly 0.5 minor units, fixed discounts larger than the
basket, modifier price snapshots and stock consumption, money-only/restock-only/
both refunds, repeated-line refund rejection, identical-key concurrency, and
approval below/above threshold for cashier and owner. See
`apps/api/src/promotions/pricing.test.ts` and
`apps/api/src/sales/sales.service.test.ts`.
