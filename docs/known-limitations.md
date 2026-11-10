# Known limitations and pending verification

Status date: 2026-11-10. No device, printer or production infrastructure was available
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
| Offline checkout and conflict resolution | Deferred to #19 | Checkout is online-only in Phase 1 |
| Phase 2 features | Deferred to #20 | Not started in this ticket |
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
| User activity audit beyond sale/stock/reversal records | Not implemented | Reversal and movement actors are recorded |

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
