# Shifts, cash reconciliation, attendance, permissions and audit

Status date: 2026-11-12. Contract version 0.10.0. This document covers the
additive C05 surface: drawer shifts, paid-in/paid-out cash, reconciled close,
attendance, the permission matrix, approval limits, shift reports and owner
audit search.

## Shift and cash lifecycle

A shift belongs to one staff member (`openedById`) and one outlet. The lifecycle
is:

1. **Open** with an opening float in integer minor units. A partial unique index
   allows at most one `OPEN` shift per staff member and outlet. Opening writes
   `SHIFT_OPENED` to the operational audit trail.
2. **Paid-in / paid-out** rows are append-only. Each row stores the amount, the
   reason and the actor (`actorId`). A paid-out above the active `CASH_OUT`
   approval limit is owner-only and returns `403 APPROVAL_REQUIRED`.
3. **Expected cash** is computed at close from recorded tender rows, not from a
   client-supplied number.
4. **Close** with a counted cash total. The server stores opening float, cash
   sales, paid-ins, paid-outs, expected cash, counted cash, signed discrepancy,
   closing actor and timestamp.

Only the staff member who opened the shift can close it. An owner may record a
cash movement on any open shift in the outlet. Closing someone else's open shift
returns `409 SHIFT_NOT_YOURS`. Closing an already-closed shift returns
`409 SHIFT_ALREADY_CLOSED`. A concurrent close uses a status/version
compare-and-set; exactly one close wins and the loser receives
`409 SHIFT_CLOSE_CONFLICT`.

## Expected-cash formula

```
expectedCashMinor =
    openingFloatMinor
  + cashSalesMinor
  + paidInMinor
  - paidOutMinor

discrepancyMinor = countedCashMinor - expectedCashMinor
```

`cashSalesMinor` is the sum of `payment_records.amountMinor` for completed sales
in the shift window where `payment.kind = CASH` and `status = RECORDED`. The
window is `[openedAt, closedAt)` (or `now` while open). The server also sums the
matching `sales.totalMinor` rows and rejects the close with
`500 CASH_SALES_MISMATCH` if the two independently derived totals differ. The
unit tests repeat the same arithmetic by hand and compare it with the service
result.

All amounts are integer minor units. The response echoes the outlet `currency`
and `currencyExponent`; the demo outlet is IDR with exponent 0.

Reversal/refund cash is not folded into expected cash in this ticket. Sale
reversal semantics are out of scope for C05 and remain documented in
`docs/sale-reversal.md`; this is deliberately conservative rather than silently
netting a refund into a drawer count.

## Discrepancy policy

`discrepancyMinor` is signed:

- positive: drawer is **over** by that amount;
- negative: drawer is **short** by that amount;
- zero: counted cash matched expected cash.

The closing actor, timestamp, note, expected, counted and discrepancy are shown
in the shift report and recorded in the operational audit metadata. There is no
automatic adjustment or write-off in this ticket.

## Attendance versus shifts

Attendance is a separate record with its own clock-in and clock-out timestamps,
actor and optional notes. Attendance never opens, changes or closes a shift, and
a shift never creates or closes attendance. A partial unique index allows one
open attendance row per staff member and outlet; duplicate clock-in or clock-out
returns `409 ATTENDANCE_ALREADY_OPEN` / `409 ATTENDANCE_NOT_OPEN`.

A staff member may therefore be clocked in without an open drawer, or have an
open drawer without an attendance row. Both are intentional and tested.

## Permission matrix

The single source is `apps/api/src/auth/permissions.ts`. Controllers use
`@RequirePermission(...)` and the global `PermissionsGuard`; role strings are not
duplicated in controllers.

| Operation | Owner | Cashier |
| --- | --- | --- |
| `shift.read` | yes | own only |
| `shift.open` | yes | yes |
| `shift.cash_in` | yes | yes |
| `shift.cash_out` | yes | yes, subject to approval limit |
| `shift.close` | yes, own shift | yes, own shift |
| `shift.report.read` | yes | no |
| `attendance.clock` | yes | yes |
| `attendance.read` | all outlet records | own only |
| `audit.search` | yes | no |
| `permission.read` | yes | no |

The owner permission view at `/permissions` reads `GET
/outlets/{outletId}/permissions`, which returns this matrix from the server.

## Approval limits

C05 reuses the existing `approval_rules` table and extends `ApprovalAction` with
`CASH_OUT`. There is no second approval system. Configure a limit with the
existing `PUT /outlets/{outletId}/approval-rules/CASH_OUT` endpoint.

- owner: always allowed;
- cashier: paid-out allowed only when an active rule exists and the amount is at
  or below `thresholdMinor`;
- otherwise: `403 APPROVAL_REQUIRED` with `details.amountMinor` and
  `details.thresholdMinor` (null when no active rule exists).

The seed configures a 100000 minor-unit `CASH_OUT` limit for the demo outlets.

## Shift reports

`GET /outlets/{outletId}/shifts/{shiftId}/report` is owner-only. It returns:

- the shift summary (opening, cash sales, paid-in, paid-out, expected, counted,
  discrepancy, close note, currency and exponent);
- every cash movement with actor, reason and timestamp;
- settled sales by payment method (`CASH`, `MANUAL_EXTERNAL`, `ONLINE`), count
  and minor-unit amount.

## Audit search

`GET /outlets/{outletId}/audit` is owner-only and searches the append-only
`operation_audits` table, which mirrors the `order_audits` shape
(`businessId`, `outletId`, `actorId`, `action`, `metadata`, `createdAt`) but is
not order-scoped.

Query fields:

- `actorId` (UUID);
- `from` and `to` (ISO-8601 timestamps, inclusive);
- `action` (`SHIFT_OPENED`, `SHIFT_CLOSED`, `CASH_PAID_IN`, `CASH_PAID_OUT`,
  `ATTENDANCE_CLOCK_IN`, `ATTENDANCE_CLOCK_OUT`);
- `cursor` (opaque base64url key over `createdAt` + `id`);
- `limit` (1–100, default 25).

Invalid cursor returns `400 INVALID_CURSOR`; `from > to` returns
`400 VALIDATION_ERROR`; a cross-outlet ID returns `404 NOT_FOUND`. Ordering is
`createdAt DESC, id DESC`, so pagination is stable across equal timestamps.

The operational surface is separate from the existing per-order audit endpoint
`GET /outlets/{outletId}/orders/{orderId}/audit`; order audits still live in
`order_audits` and are not duplicated.

## Limits and non-goals

- No payroll or HR export.
- No cash-drawer hardware pulse or automatic denomination counting.
- No cash refund netting in expected cash (see above).
- No force-close by an owner; closing someone else's shift is always `409`.
- One open shift and one open attendance row per staff member and outlet.
- Sales, stock and payment semantics are unchanged.
- The Android app does not receive new screens for these operations in C05; the
  back office owns them.
