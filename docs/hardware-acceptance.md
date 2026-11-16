# Hardware acceptance checklist (#74)

Status: **SELECTED, NOT YET VERIFIED. Physical acceptance PENDING.**
Selection: `docs/hardware-selection.md` (Samsung Galaxy Tab A9 `SM-X110`,
Android 14; Star Micronics TSP143IIIBI; Bluetooth Classic SPP; 80 mm; CP437).

No Android device, printer, paper or camera was available on this host. The
host evidence in this document proves software and API behaviour only. It does
not prove pairing, paper output, code-page rendering, disconnection recovery or
stock effects on a device. Do not mark any physical AC PASS from a host test.

Date: 2026-11-16.
Baseline: `d68daca` (#72 merge), with #67 `9cc95cd` and #68 `2485f8c` merged.

## How to use this checklist

- Run the ACs in order on the exact selected hardware.
- Each AC lists exact commands, expected results and an evidence slot.
- Record the actual device build, printer firmware and configured code page at
  AC1. If they differ from the selection, stop and amend the selection; do not
  claim support for the unobserved values.
- Keep every command's output. Prefix log files with the AC number and date.
- Attach dated text logs, screenshots and paper photographs to the PR/issue.
  Do not commit credentials, customer data or unredacted logs.
- Mark only this exact combination supported. Every other device, printer,
  firmware, transport, code page and width remains PENDING.

Suggested evidence paths (create only when the run happens):

```
evidence/74/2026-11-16/AC1-device-props.txt
evidence/74/2026-11-16/AC1-printer-self-test.jpg
evidence/74/2026-11-16/AC1-app-config.png
evidence/74/2026-11-16/AC2-permission-denial.txt
evidence/74/2026-11-16/AC2-test-receipt.jpg
evidence/74/2026-11-16/AC2-reconnect.jpg
evidence/74/2026-11-16/AC3-original.jpg
evidence/74/2026-11-16/AC3-amend.jpg
evidence/74/2026-11-16/AC3-cancel.jpg
evidence/74/2026-11-16/AC4-unknown.png
evidence/74/2026-11-16/AC4-copy.jpg
evidence/74/2026-11-16/AC4-restart.txt
evidence/74/2026-11-16/AC5-offline.png
evidence/74/2026-11-16/AC5-reconcile.txt
evidence/74/2026-11-16/AC6-signoff.md
```

## Precondition evidence on this host

These results are reproducible on the VPS. They are preconditions, not physical
acceptance. Commands were run from `/home/ubuntu/modern-pos` on 2026-11-16.

### Mobile formatting, analysis and tests

```
$ cd apps/mobile
$ dart format --output=none --set-exit-if-changed lib test
Formatted 103 files (0 changed) in 0.82 seconds.

$ flutter analyze
Analyzing mobile...
No issues found! (ran in 12.7s)

$ flutter test -r expanded
...
01:26 +150 ~3: All tests passed!
```

The 3 skips are the guarded live/device tests that require an external URL or
device. The focused printer, station-delivery, offline and checkout suites were
also run separately:

```
$ flutter test -r expanded \
    test/lan_printer_transport_test.dart \
    test/usb_printer_transport_test.dart \
    test/printer_adapter_test.dart \
    test/printer_encoding_test.dart \
    test/esc_pos_receipt_test.dart \
    test/receipt_layout_test.dart \
    test/printer_controller_test.dart \
    test/printer_screen_test.dart \
    test/station_delivery_service_test.dart \
    test/offline_session_test.dart \
    test/catalog_snapshot_test.dart \
    test/offline_sale_repository_test.dart \
    test/offline_sync_controller_test.dart \
    test/offline_refresh_transcript_test.dart \
    test/offline_crypto_test.dart \
    test/checkout_controller_test.dart \
    test/checkout_screen_test.dart \
    test/checkout_live_api_test.dart
...
00:47 +102 ~1: All tests passed!
```

The single skip is `checkout_live_api_test.dart` without
`CHECKOUT_API_BASE_URL`; the live reconciliation below covers that path against
the running API.

### Debug APK

```
$ cd apps/mobile
$ ANDROID_HOME=/home/ubuntu/android-sdk flutter build apk --debug
Running Gradle task 'assembleDebug'... 231.2s
Built build/app/outputs/flutter-apk/app-debug.apk
(the Flutter CLI prints a check-mark prefix on the Built line)

$ ls -lh build/app/outputs/flutter-apk/app-debug.apk
-rw-r--r-- 1 ubuntu ubuntu 207M Nov 16 14:55 build/app/outputs/flutter-apk/app-debug.apk
```

The APK is debug-signed and is for device verification only. Build a physical
device APK with a reachable API address; `10.0.2.2` is emulator-only:

```
ANDROID_HOME=/home/ubuntu/android-sdk flutter build apk --debug \
  --dart-define=API_BASE_URL=http://<staging-host-lan-ip>:4000
```

### Loopback/LAN byte evidence

```
$ cd apps/mobile
$ flutter test test/lan_printer_transport_test.dart -r expanded
00:00 +4: All tests passed!
```

The test binds a real loopback `ServerSocket`, sends the ESC/POS test receipt
through `LanPrinterTransport`, and asserts that bytes arrived, the first byte is
`0x1B`, and the received length equals the sent length. This proves byte
transport on this host. It does not prove paper.

A one-off probe in the same package (not committed) measured the exact stream
lengths used by the committed tests:

```
PROBE 58 mm 32cols test_receipt_bytes=592 kitchen_ticket_bytes=249 first=1b cut_tail=64 02 1d 56 42 00
PROBE 80 mm 48cols test_receipt_bytes=746 kitchen_ticket_bytes=297 first=1b cut_tail=64 02 1d 56 42 00
```

The tail bytes are `ESC d 02` (feed two lines) followed by `GS V B 0` (full cut
with feed). The 80 mm values apply to the selected combination; the selected
printer's command support is still PENDING.

### Node, formatting, typecheck and API contract

```
$ pnpm format:check
All matched files use Prettier code style!

$ pnpm typecheck
... web typecheck: Types generated successfully ... (exit 0)

$ pnpm test
# API: # pass 282, # fail 0
# web: # pass 4, # fail 0
```

Total Node tests: 286 passed, 0 failed. No tests were deleted.

```
$ pnpm openapi:check        # run twice
(exit 0 both times)
$ git status -s packages/
(empty)
```

### Live sale, payment and stock reconciliation

A manual API reconciliation ran against `http://localhost:4000` because the
checked-in live test sends a null `customerEmail` (see the out-of-scope note
below). It used a non-null email and a tracked recipe item:

```
PASS login owner
PASS order=34432ee5-d75d-4a63-b198-1ec9ab2b925f version=1
PASS quote=5c3bcf41-8998-4035-a5d6-59eadcb114a3 subtotal=35000 total=35000
PASS finalize sale=14bbb9d6-40bc-4615-b62e-573f8bc42729 \
  ref=SALE-34432ee5-d75d-4a63-b198-1ec9ab2b925f replayed=false total=35000 change=5000
PASS replay replayed=true sale=14bbb9d6-40bc-4615-b62e-573f8bc42729
PASS recover sale=14bbb9d6-40bc-4615-b62e-573f8bc42729 replayed=true
PASS ledger sales_before=61 sales_after=62 delta=1 sale_rows=1
PASS ledger payment_before=61 payment_after=62 payment_rows_for_sale=1
CASH|RECORDED|35000|40000|5000
PASS ledger stock_movements_before=355 after=358 sale_movement_rows=3 distinct_items=3
SALE|00000000-0000-4000-8000-000000000050|-150.000000|Sale 14bbb9d6-...
SALE|00000000-0000-4000-8000-000000000051|-200.000000|Sale 14bbb9d6-...
SALE|00000000-0000-4000-8000-000000000052|-1.000000|Sale 14bbb9d6-...
PASS reconciliation one sale, one payment, three unique SALE stock movements
```

Interpretation: one finalize created exactly one sale, one payment record and
three `SALE` stock movements, one per recipe ingredient. Replaying the same key
and recovering the checkout request returned the same sale and created no
additional sale, payment or stock movement. This is server-side evidence; the
device-side AC5 steps below remain PENDING.

Out-of-scope host observation: the checked-in
`test/checkout_live_api_test.dart` sends no `customerEmail`, and the current API
fails a quote with `TypeError: Cannot read properties of null (reading 'trim')`
at `apps/api/src/sales/sales.service.ts:3292`. The manual reconciliation sends a
non-null email and completes. This docs-only ticket does not change product
code. The defect is recorded here for the follow-up owner.

### Web regression gate

```
$ cd /tmp/qa5-pw
$ node qa5-verify.cjs
...
TOTAL CHECKS 37
ALL PLAYWRIGHT CHECKS PASSED
```

The owner sign-in, navigation, sales filters, report CSV, printer registry and
responsive layouts passed against the current web build. This does not exercise
the Android printer.

## AC1 - Record the exact device, Android version, printer model, firmware, transport, code page, width and supported commands

Goal: replace every `SELECTED, NOT YET VERIFIED` value with an observed value.

Status: **PARTIAL**. The selection is recorded in
`docs/hardware-selection.md`; the exact device build, printer firmware, active
code page and observed command support are **PENDING - requires Samsung Galaxy
Tab A9 `SM-X110` (Android 14) + Star Micronics TSP143IIIBI**.

Steps:

1. On the device, enable Developer options and USB debugging, connect USB, then
   run:

   ```bash
   adb devices
   adb shell getprop ro.product.manufacturer
   adb shell getprop ro.product.model
   adb shell getprop ro.build.version.release
   adb shell getprop ro.build.version.sdk
   adb shell getprop ro.build.version.security_patch
   adb shell getprop ro.build.fingerprint
   ```

   Expected: `ro.product.model` is `SM-X110`, release starts with `14`, and the
   build strings are recorded verbatim. Save the output as
   `AC1-device-props.txt`.

2. Print the printer self-test using the vendor procedure in the TSP143IIIBI
   manual. Photograph it. Record the exact firmware version, serial number,
   configured code page, column count and cutter type. Set the printer's default
   code page to CP437 with the vendor utility; the app does not send `ESC t`.
   Expected: firmware string and CP437 are visible on the self-test or vendor
   tool. If CP437 is unavailable, stop; this combination is not supported.

3. Install the APK and open **Settings > Receipt printer**. Select **Bluetooth
   Classic (SPP)**, enter the printer name and paired MAC, select **80 mm** and
   **CP437**, then **Save configuration**. Screenshot the saved summary.
   Expected: the summary shows Bluetooth Classic, 80 mm (48 cols), CP437 and the
   paired address.

4. Fill the record table in `docs/hardware-selection.md` with the observed
   values and change the status to verified only after AC2-AC6 also pass.

Evidence: `AC1-device-props.txt`, `AC1-printer-self-test.jpg`,
`AC1-app-config.png`.

## AC2 - Verify permission denial/regrant, pairing/connect, test output, receipt totals/layout/encoding and reconnection on real hardware

Status: **PENDING - requires Samsung Galaxy Tab A9 `SM-X110` (Android 14) +
Star Micronics TSP143IIIBI + 80 mm paper**.

Preconditions: APK installed, printer powered with paper, Bluetooth on, API
reachable from the device.

Steps:

1. Pair the printer in Android **Settings > Bluetooth**. Record the MAC address.
   Expected: the printer appears as paired.

   ```bash
   adb logcat -c
   adb logcat -v threadtime > evidence/74/2026-11-16/AC2-logcat.txt
   ```

2. In the app, open **Settings > Receipt printer** and tap **Grant Bluetooth
   permission** when the runtime prompt appears. Tap **Deny** the first time.
   Expected: the app shows the permission-needed state and does not crash.
   Tap **Grant Bluetooth permission** again and allow this time.
   Expected: "Bluetooth permission granted".

3. Force the permanently-denied path and recover it:

   ```bash
   adb shell pm revoke com.modernpos.modern_pos_mobile android.permission.BLUETOOTH_CONNECT
   adb shell pm revoke com.modernpos.modern_pos_mobile android.permission.BLUETOOTH_SCAN
   adb shell pm grant com.modernpos.modern_pos_mobile android.permission.BLUETOOTH_CONNECT
   adb shell pm grant com.modernpos.modern_pos_mobile android.permission.BLUETOOTH_SCAN
   ```

   Expected: revoking a runtime permission may stop the app; relaunch it. With
   the permission revoked, Connect/Scan shows the permission message and a retry
   path; after regrant, scan and Connect work. Record the exact messages.

4. Tap **Scan paired devices**, select the printer, tap **Use**, **Save
   configuration**, then **Connect**.
   Expected: status becomes **Connected**. Record the printer LED state.

5. Tap **Test print**.
   Expected paper: a receipt titled `PRINTER TEST`, `Ref: TEST-80MM`, one sample
   item, subtotal/total/tendered/change in the configured currency, and the
   configured cut. No line exceeds 48 columns. Photograph the paper.
   Fail: record the app message and whether the paper moved at all.

6. Print a completed sale receipt and compare the printed values with the owner
   web sale detail. Verify subtotal, service, tax, total, tender, change and
   reference. Print an item name with accented characters (for example `Café`,
   `Jalapeño`) and a long name. Expected: CP437-supported characters render;
   unsupported characters become `?`; totals stay aligned; long names wrap.
   Record any substitution.

7. Reconnection: turn the printer off and on, then tap **Connect** and **Test
   print**. Also turn Bluetooth off/on in Android and reconnect.
   Expected: reconnect succeeds, or the app shows a classified failure with a
   retry action. Record the exact classifier text.

Evidence: `AC2-permission-denial.txt`, `AC2-logcat.txt`,
`AC2-test-receipt.jpg`, `AC2-sale-receipt.jpg`, `AC2-reconnect.jpg`, app
screenshots.

## AC3 - Observe physical kitchen ORIGINAL, AMEND and CANCEL tickets with stable references

Status: **PENDING - requires Samsung Galaxy Tab A9 `SM-X110` (Android 14) +
Star Micronics TSP143IIIBI + station printers/paper**.

Preconditions: owner access to the back office, two stations configured, printer
connected, a sale with one routed item per station.

Steps:

1. In the owner web app, create two stations (for example Kitchen and Bar) and
   route one menu item to each. Record the station names and item names.

2. On the device, sign in as cashier and complete a cash sale with one routed
   item for each station. Record the sale reference.

3. Open **Settings > Kitchen delivery**, select the first station and tap
   **Deliver queued**. Photograph the ticket. Repeat for the second station.
   Expected: each printer receives only its station's item, with quantity,
   variant, modifiers, station name, `ORIGINAL`, and the stable `Order:` line.

4. Create an AMEND and a CANCEL for the same order/sale. The app has no AMEND
   dispatch UI, so use the owner API to create the jobs, then deliver them from
   the Android **Kitchen delivery** screen:

   ```bash
   API=http://<staging-host-lan-ip>:4000/v1
   OUTLET=<outlet-id>
   ORDER=<order-id>
   SALE=<sale-id>
   VARIANT=<variant-id>
   TOKEN=$(curl -fsS -X POST "$API/auth/mobile/login" \
     -H 'content-type: application/json' \
     -d '{"email":"owner@example.test","password":"<seed-password>","deviceId":"<device-id>"}' \
     | jq -r .accessToken)
   AUTH="authorization: Bearer $TOKEN"

   curl -fsS -X POST "$API/outlets/$OUTLET/orders/$ORDER/station-jobs" \
     -H "$AUTH" -H 'content-type: application/json' \
     -H "Idempotency-Key: $(cat /proc/sys/kernel/random/uuid)" \
     -d "{\"kind\":\"AMEND\",\"saleId\":\"$SALE\",\"lines\":[{\"variantId\":\"$VARIANT\",\"quantity\":1}]}"

   curl -fsS -X POST "$API/outlets/$OUTLET/orders/$ORDER/station-jobs" \
     -H "$AUTH" -H 'content-type: application/json' \
     -H "Idempotency-Key: $(cat /proc/sys/kernel/random/uuid)" \
     -d "{\"kind\":\"CANCEL\",\"saleId\":\"$SALE\",\"lines\":[{\"variantId\":\"$VARIANT\",\"quantity\":1}]}"
   ```

   Refresh **Kitchen delivery** and **Deliver queued** for the affected station.
   Use the seed password configured for the staging API; never paste it into the
   evidence files or the PR.

5. Photograph the AMEND and CANCEL tickets. Verify:
   - all three tickets show the same `Order:` reference as the original;
   - the AMEND ticket says `AMENDMENT` and shows the changed quantity;
   - the CANCEL ticket says `CANCELLATION` / `ITEM CANCELLED`;
   - a `COPY` ticket (from AC4) says `COPY - NOT AN ORIGINAL`.

6. Confirm no sale, payment or stock change was caused by any station ticket.
   Reconcile the sale reference before and after the three prints.

Evidence: `AC3-original.jpg`, `AC3-amend.jpg`, `AC3-cancel.jpg`, station job
JSON or screenshots, `AC3-reconcile.txt`.

## AC4 - Exercise mid-write disconnect and process restart; UNKNOWN must never silently resend and COPY must be visibly marked

Status: **PENDING - requires Samsung Galaxy Tab A9 `SM-X110` (Android 14) +
Star Micronics TSP143IIIBI + paper**.

Steps:

1. Queue at least two kitchen tickets. Open **Settings > Kitchen delivery** and
   tap **Deliver queued**.

2. During the write, turn the printer off (or move it out of Bluetooth range).
   Expected: the app records `UNKNOWN`, shows the uncertain message, and does
   not produce a second copy after 60 seconds. The server job state must be
   `UNKNOWN`. Record a screenshot and the queue JSON.

3. Do not retry the uncertain job. Tap **COPY**.
   Expected: a new job is created with `copy: true`; paper shows
   `COPY - NOT AN ORIGINAL` and `Copy of job: <id>`; the original job remains
   `UNKNOWN`. Photograph the COPY paper.

4. Restart path: queue another ticket and tap **Deliver queued**. While the job
   is `SENDING`, force-stop the app:

   ```bash
   adb shell am force-stop com.modernpos.modern_pos_mobile
   ```

   Relaunch, sign in if needed, open **Kitchen delivery**. Expected: the stale
   `SENDING` job is promoted to `UNKNOWN` by the restart recovery, no paper is
   produced automatically, and **COPY** is the only action for the uncertain
   job. Save the logcat and a screenshot.

5. Verify no automatic resend by waiting at least 60 seconds and refreshing the
   queue. Expected: the original job stays `UNKNOWN`; only an explicit COPY
   creates a new job.

Evidence: `AC4-unknown.png`, `AC4-copy.jpg`, `AC4-restart.txt`, `AC4-logcat.txt`,
queue JSON before/after.

## AC5 - Exercise app restart/offline recovery and checkout reconnect; reconcile one sale/payment and exact stock effects

Status: **PENDING - requires Samsung Galaxy Tab A9 `SM-X110` (Android 14) +
staging API + printer for the physical receipt**.
Host-side sale/payment/stock reconciliation is already evidenced above; the
device restart, offline session and reconnect steps remain PENDING.

Steps:

1. Sign in online and load the catalog. Record the authorization time. Complete
   one online cash sale with a tracked recipe item. Record the sale reference,
   total and payment.

2. Enable airplane mode, force-stop the app, relaunch:

   ```bash
   adb shell cmd connectivity airplane-mode enable
   adb shell am force-stop com.modernpos.modern_pos_mobile
   # launch the app, then:
   adb shell cmd connectivity airplane-mode disable
   ```

   If the `cmd connectivity airplane-mode` command is unavailable on the device
   build, toggle Airplane mode from Quick Settings and record that instead.

   Expected: within the documented 12-hour allowance, the app shows the cashier
   shell, an **Offline mode** banner, the last authorization time, the saved
   catalog snapshot with its age, and the local queue. It must not show the
   sign-in screen. Screenshot.

3. Record one offline capture. Expected: the encrypted queue shows the capture;
   the app does not claim server acceptance or stock reservation.

4. Reconnect (disable airplane mode, wait for the banner's **Reconnect**
   action). Expected: the session becomes online, the offline banner clears,
   and the queue's Sync/Reconcile actions become available. Do not replay a
   revoked session; a `401` must return to sign-in.

5. Checkout restart: start a sale, submit once, then force-stop the app before
   the response. Relaunch and open checkout. Expected: recovery finds the same
   sale reference and does not create a second sale.

6. Reconcile the online sale with the owner web **Sales**, **Reports** and
   **Stock** screens. Verify exactly one sale, one payment record, and one
   `SALE` stock movement per consumed ingredient. Compare the stock balance
   before and after. The host proof above used three ingredients; the actual
   recipe may differ, so record the expected ingredient count from the recipe.

   API/DB checks (substitute the actual ids):

   ```bash
   docker exec modern-pos-postgres psql -U pos -d modern_pos -tAc \
     "select count(*) from sales where id='<sale-id>';"
   docker exec modern-pos-postgres psql -U pos -d modern_pos -tAc \
     "select count(*) from payment_records where \"saleId\"='<sale-id>';"
   docker exec modern-pos-postgres psql -U pos -d modern_pos -tAc \
     "select count(*) from stock_movements where \"sourceId\"='<sale-id>' and type='SALE';"
   ```

   Expected: `1`, `1`, and the exact ingredient count; no duplicate movement.

7. Print the sale receipt. Verify the paper totals match the server sale and the
   owner web detail. Photograph it.

Evidence: `AC5-offline.png`, `AC5-reconnect.png`, `AC5-reconcile.txt`,
`AC5-sale-receipt.jpg`, `AC5-logcat.txt`.

## AC6 - Attach dated logs and paper/photo evidence; mark only the tested combination supported

Status: **PENDING - requires the AC1-AC5 hardware run**.

Steps:

1. Collect every evidence file under the dated directory. Redact secrets,
   tokens, customer data and phone numbers from logs. Do not commit the debug
   keystore or any credentials.

2. Attach the files to the PR/issue. If a file cannot be attached, record the
   external storage location and its SHA-256 in the sign-off table.

3. Fill the sign-off table below. Mark PASS only for the exact observed device,
   printer and firmware. Mark every other combination PENDING.

4. Update `docs/printer-validation.md` and `docs/printer-hardware.md` with the
   observed values. Change `SELECTED, NOT YET VERIFIED` to supported only when
   all six ACs pass.

5. Re-check the honesty boundary: no claim of paper, pairing, device result or
   supported combination may appear unless the corresponding dated evidence is
   attached.

## Sign-off table

Fill this table only after the hardware run. Do not pre-fill PASS.

| AC | Result | Date | Evidence | Device/printer observed |
| --- | --- | --- | --- | --- |
| AC1 record exact hardware/firmware | PENDING | - | `AC1-*` | SELECTED, NOT YET VERIFIED |
| AC2 permissions, pairing, test print, encoding, reconnect | PENDING | - | `AC2-*` | SELECTED, NOT YET VERIFIED |
| AC3 kitchen ORIGINAL/AMEND/CANCEL | PENDING | - | `AC3-*` | SELECTED, NOT YET VERIFIED |
| AC4 UNKNOWN and COPY after disconnect/restart | PENDING | - | `AC4-*` | SELECTED, NOT YET VERIFIED |
| AC5 offline/reconnect and sale/payment/stock reconciliation | PENDING | - | `AC5-*` | SELECTED, NOT YET VERIFIED |
| AC6 dated evidence and supported-combination record | PENDING | - | `AC6-*` | SELECTED, NOT YET VERIFIED |

## Definition of supported

A hardware combination is supported only when:

1. All six ACs above pass on the exact device, printer and firmware.
2. Dated logs, screenshots and paper photographs are attached.
3. The actual Android build, firmware, code page, column count and command
   support are recorded in the hardware record.
4. The record explicitly names the only supported combination and leaves every
   other device, printer, firmware, transport, code page and width PENDING.

Until then, this repository has no hardware-supported printer combination.
