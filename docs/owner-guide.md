# Owner guide (Phase 1 MVP)

This guide describes what the owner back office and the Android cashier app can do in
the Phase 1 MVP. It also states what is not available yet. The product is verified
with synthetic data on a single VPS; production use requires a separate go-live
decision.

## Roles

| Role | Web back office | Android cashier app |
| --- | --- | --- |
| `OWNER` | Settings, menu, stock, sales, reports, printers, reversal | Sale initiation and printing are owned by the Flutter app; the owner can sign in on a device too |
| `CASHIER` | No back-office access | Catalog, cart, checkout, receipt, print queue |

The API enforces roles. Hiding a button in the web UI is not the security boundary.
Only an owner can update settings, catalog, stock, printers or record a reversal.

## Day one: settings

1. Sign in at `/login` with an owner account.
2. Open **Settings**.
3. Set the business name, currency, IANA timezone, receipt header, receipt footer,
   receipt address, tax rate and service rate.
4. Save. The save increments the outlet settings version. Existing completed sales
   keep their original snapshot; new quotes use the new version.

The seed creates two outlets for the demo business. The active outlet is selected in
the back office navigation. Use the correct outlet before creating stock or menu data.

## Day one: users

The current MVP has no user-management screen or user-creation API. Seeded demo users
exist for local verification. Provisioning real owners and cashiers currently requires
a controlled database/seed change before production. In-app invitations, password
reset, deactivation and audit of user changes are not implemented. This is a known
limitation, not a supported workflow.

Never use the synthetic seed password in production.

## Day one: menu and recipes

1. Open **Menu**.
2. Create a category if the menu needs a new grouping.
3. Create a menu item, choose its category, and add one or more variants with a price
   and a stock policy:
   - `UNTRACKED`: no ingredient stock is deducted.
   - `TRACKED`: every sale requires a published recipe and deducts the recipe
     quantities from stock.
4. For a tracked variant, open its recipe and publish at least one line with a stock
   item and a quantity per sale unit.
5. Confirm the variant is enabled for the active outlet.
6. Use the catalog refresh action on the Android app so the cashier sees the change.

Archiving a menu item or changing a price does not rewrite a completed sale. Receipts
and reports keep the sale snapshot.

## Day one: stock opening balances

1. Open **Stock**.
2. Create each raw stock item with a base unit (`g`, `ml` or `each`), quantity
   precision and reorder threshold.
3. Use **Opening** on the item and record the counted quantity with a reason.
4. Opening balances are recorded once per item and outlet. Later changes use
   **Receipt**, **Adjustment** or a sale/reversal movement.
5. Check the stock list for **Below reorder** and **Out of stock** badges.

A sale that would consume more than the available tracked stock is rejected by the
API with `422 INSUFFICIENT_STOCK`. The sale is not partially committed.

## Daily operation: sale

1. The cashier signs in on the Android app.
2. Refresh the catalog, add items to the cart and open checkout.
3. Review the immutable quote. Cash requires tendered amount greater than or equal to
   the total and shows live change. Manual external payment must equal the total.
4. Submit once. The app persists the checkout key and exact payload before the network
   request. Repeated taps do not create a second sale.
5. The receipt preview is built from the server sale, not from device arithmetic.
6. If the response is lost, use **Check again** / recovery before starting a new sale.
   The app retains the pending key and asks the server for the recorded sale.

The API owns authorization, prices, rounding, totals, payment validation, stock
consumption and atomic persistence.

## Daily operation: back-office review

- **Sales**: choose the outlet-local date range, inspect sale rows, open **View
  receipt** for the immutable snapshot, service/tax, tendered amount and change.
- **Reports**: choose a date range, review gross item sales, reversal item value, net
  item sales, sale count, average bill, payment breakdown and menu quantities. Export
  CSV for reconciliation. Reversals appear as separate rows and do not change the
  original sale totals.
- **Stock**: review balances, movement history, low-stock badges and menu availability.
- **Printers**: owner-only configuration records. The Android app owns the local print
  queue and the physical printer connection.

## Corrections: reverse a sale

Policy for Phase 1:

1. A reversal is a separate, append-only correction. The original sale row is never
   edited or deleted.
2. Only an owner can record one. A cashier receives `403`.
3. A reason of 3-500 characters is required.
4. Restocking is explicit. Choosing an ingredient restores only that ingredient and
   only up to the amount the sale consumed. Empty restock is legal for a financial-only
   correction.
5. No payment provider is called. Every response states
   `externalRefundPerformed: false`.
6. Reusing the same idempotency key with the same payload replays the stored reversal.
   A second key against an already-reversed sale returns
   `409 SALE_ALREADY_REVERSED`.
7. Reports count the reversal separately: gross item sales and sale count stay
   unchanged, while reversal item value increases and net item sales decreases.

Out of scope: partial refunds, line-level refunds, cash drawer adjustments, voiding a
card payment through a provider, and editing a completed sale.

## Printing

The Android app is the only printing client. The back office can store printer
configuration metadata, but it cannot print and has no checkout or tender controls.

Supported candidate transport in the code: Bluetooth Classic (RFCOMM/SPP). LAN and USB
are shown as not implemented/not verified. The app does not claim that paper came out
just because bytes were sent. Print states are:

| State | Meaning |
| --- | --- |
| `QUEUED` | Durable local job, not sent yet |
| `SENDING` | Send attempt started |
| `SENT` | Transport accepted the bytes; paper output is not proven |
| `FAILED` | Known not sent; retry is safe |
| `UNCERTAIN` | Write failed after sending started; delivery unknown; manual COPY reprint only |

Physical printing and device behaviour are `PENDING - requires a real Android device
and printer`. Follow `docs/printer-validation.md` before claiming a hardware result.

## MVP limits

- No offline mode. Checkout is online-only; pending recovery blocks a new sale until
  the key is resolved.
- No user-management UI, invitations or password reset.
- No partial or line-level refunds and no payment-provider refunds.
- No LAN/USB printer transports and no hardware-verified Bluetooth result in this
  repository.
- No production deployment, TLS, off-host backup automation, monitoring or high
  availability in this ticket.
- No Phase 2 features (#19, #20).
- Reports and sales are read-only in the web back office.

See `docs/known-limitations.md` for the full pending list and reproduction recipes.
