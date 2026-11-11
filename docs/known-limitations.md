# Known limitations and pending verification

Status date: 2026-11-11. No device, printer or production infrastructure was available
for this ticket. Nothing below is reported as passed without a reproduction recipe.

## Pending with reproduction recipes

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
| Partial or line-level refunds | Not implemented | One full reversal per completed sale |
| Payment-provider refunds/voids | Not implemented | Reversal never calls a provider |
| LAN and USB printer transports | Not implemented | Bluetooth Classic SPP is the only candidate |
| Hardware-verified Bluetooth result | PENDING | See `docs/printer-validation.md` |
| Automated off-host backups and retention | Not implemented | Procedure and dry run exist in `docs/backup-restore.md` |
| Point-in-time recovery | Not implemented | Logical dump only |
| Monitoring, alerting, log shipping | Not implemented | Health endpoint exists |
| High availability / multiple API instances | Not implemented | Single VPS |
| Production TLS and secret manager | Not implemented | Staging uses local env placeholders |
| Tax/service policy beyond fixed basis points | Not implemented | Settings support integer bps only |
| Discounts, promotions, loyalty | Not implemented | Not in Phase 1 scope |
| Multi-currency per sale | Not implemented | One currency/exponent per outlet |
| User activity audit beyond sale/stock/reversal/order records | Not implemented | Order open/transfer/split/cancel/finalize transitions are append-only audited; admin/user changes are not |

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
