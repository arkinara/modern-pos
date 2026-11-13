# Receipt printer validation record (#15)

Status: **candidate implementation, hardware acceptance PENDING**. No printer model and no Android
test device were supplied for this ticket. LAN raw TCP was added in #25 and validated against a
local TCP listener; Bluetooth/LAN/USB physical output remains PENDING. Nothing in this document claims a transport, code page,
command or print result was verified on hardware. Every hardware-dependent item is marked
`PENDING — requires <X>` with a reproduction recipe.

## Implemented in this ticket

| Area | State | Evidence |
| --- | --- | --- |
| ESC/POS receipt byte builder | Implemented and unit tested on this host | `apps/mobile/test/esc_pos_receipt_test.dart` |
| CP437 / UTF-8 text encoding | Implemented and unit tested | `apps/mobile/test/printer_encoding_test.dart` |
| Column wrapping, truncation and money formatting | Implemented and unit tested | `apps/mobile/test/receipt_layout_test.dart`, `esc_pos_receipt_test.dart` |
| Printer adapter (`connect`, `testPrint`, `printReceipt`, `disconnect`) | Implemented; transport calls are PENDING on hardware | `apps/mobile/lib/features/printing/printer_adapter.dart` |
| Android Bluetooth Classic (RFCOMM/SPP) transport | Implemented as the single candidate transport; **unverified** | `android_printer_transport.dart`, `MainActivity.kt` |
| Android runtime permission request/re-request | Implemented; on-device behaviour PENDING | `printer_permissions.dart`, `MainActivity.kt`, `AndroidManifest.xml` |
| Cashier configuration, connect, test print and failure states | Implemented and widget tested | `apps/mobile/lib/features/printing/printer_screen.dart`, `apps/mobile/test/printer_screen_test.dart` |
| LAN raw TCP transport (#25) | Implemented and validated against a local TCP listener; physical output PENDING | `lan_printer_transport.dart`, `test/lan_printer_transport_test.dart`, `docs/printer-hardware.md` |
| USB host transport (#25) | Dart transport plus Android `UsbPrinterChannel` bulk-transfer host; framing/state tested with a mocked channel; physical output PENDING | `usb_printer_transport.dart`, `test/usb_printer_transport_test.dart` |
| Print queue, retry, reprint and receipt layout policy | Implemented and unit/widget tested on this host | `docs/receipt-printing.md`, `apps/mobile/test/print_queue_service_test.dart`, `receipt_document_test.dart` |

The cashier app never reports a physical print success. A "Test print bytes sent" message only
means the byte stream was accepted by the transport socket.

## Hardware record

Fill each row when a real printer and Android device are available. Do not replace `PENDING` with a
result until the acceptance checklist below has actually been run.

| Field | Value | Source or status |
| --- | --- | --- |
| Printer model | `PENDING — requires selected printer model` | No model supplied. Record the exact vendor model and firmware. |
| Transport | Bluetooth Classic (RFCOMM/SPP) candidate | Implemented because SPP is the conventional receipt-printer serial profile. **Transport not verified on this project.** |
| Paper width | 58 mm (32 columns) or 80 mm (48 columns), selected in app | ESC/POS Font A convention. `PENDING — requires printer model datasheet` to confirm the model's column count. |
| Encoding | CP437 (implemented) or UTF-8 (implemented) | CP437 table implemented from the published IBM code page. `PENDING — requires printer model manual` to confirm the active code page and the code-page select command. |
| ESC/POS text | Implemented: `ESC @`, `ESC a`, `ESC E`, line feed, `ESC d` | Common ESC/POS subset. `PENDING — requires printer model command manual` before claiming support. |
| ESC/POS cut | Implemented: `GS V B 0` full cut with feed | `PENDING — requires printer model command manual`; not every printer has a cutter. |
| Cash drawer pulse | Implemented: `ESC p 0 25 250` (disabled by default; not wired to UI) | `PENDING — requires printer model + drawer hardware`; cable, pinout and pulse must be tested. |
| Barcode | Not implemented | `PENDING — requires printer model command manual and a documented barcode requirement`. |
| QR code | Not implemented | `PENDING — requires printer model command manual`. |
| Android version | `PENDING — requires Android test device` | App targets API 36, minimum from the Flutter toolchain. Record the exact device model and Android release. |
| Runtime permissions | `BLUETOOTH_CONNECT` + `BLUETOOTH_SCAN` on API 31+; `BLUETOOTH`/`BLUETOOTH_ADMIN` install-time and `ACCESS_FINE_LOCATION` for discovery on API 23–30 | Documented source: Android Bluetooth permissions guidance. Manifest comments tie each permission to the printer feature. On-device prompts and denial paths are `PENDING — requires Android device`. |

### Transports implemented but not physically verified on this project

- Bluetooth Classic (SPP) — adapter exists, **not physically verified**.
- Bluetooth Low Energy — not implemented.
- Network / LAN (raw TCP 9100) — adapter exists and accepted bytes on a local listener, **not physically verified**.
- USB host / USB OTG — adapter and mocked platform channel exist, **not physically verified**.

All three selectable transports keep the same honest success wording: bytes were accepted by the
transport, not proof of paper. The detailed per-transport record and recipes are in
`docs/printer-hardware.md`.

## Physical acceptance checklist

Run this only with a real printer and Android device. Record the actual model, device and Android
version next to each step; do not report results otherwise.

1. **Prepare the printer**
   - Power the printer and load paper matching the selected width.
   - Put the printer into discoverable/pairing mode using its vendor instructions.
2. **Pair in Android**
   - Open Android Settings → Bluetooth, pair the printer, and confirm it shows as paired.
   - Pass: the printer appears in the paired-device list.
   - Fail: note the exact error; record printer and Android versions.
3. **Grant permissions in the app**
   - Open Settings → Receipt printer → Grant Bluetooth permission.
   - Pass: Android shows the Bluetooth scan/connect prompt (API 31+) or location prompt
     (API 23–30) and the app shows "Bluetooth permission granted".
   - Deny once, then tap Grant again. Pass: the app shows the permission-needed state and
     re-requests without crashing. Record whether Android permanently denied the permission.
4. **Configure**
   - Enter the printer's Bluetooth address (or scan paired devices and select it).
   - Choose paper width and encoding that match the printer manual. Save.
   - Pass: the status changes to Disconnected and the summary matches the selection.
5. **Connect**
   - Tap Connect.
   - Pass: status changes to Connected.
   - Fail: record the classified message (device not found, Bluetooth off, permission denied,
     connection lost) and the printer LED state.
6. **Test print**
   - Tap Test print.
   - Pass: the paper shows the "PRINTER TEST" receipt, Indonesian/Latin characters render as
     configured, amounts are grouped correctly, and the cut (if the model has a cutter) fires.
   - Fail: record whether any bytes reached the printer (paper movement), the exact visible output
     or error, and the app's message. A connection loss mid-job must leave the app Disconnected with
     a retry path; reconnect and run Test print again.
7. **Encoding and width checks**
   - Print item names with accented characters and a long name.
   - Pass: no replacement `?` for characters the selected code page supports; no line exceeds the
     paper width; totals remain aligned.
   - If the printer's code page differs, repeat with the other encoding option and record which
     one the model actually uses.
8. **Reconnect**
   - Turn the printer off and on, then reconnect and test print.
   - Pass: reconnect works or the app shows a clear failure with a retry action.
9. **Record the result**
   - Fill the hardware table above with the model, Android version, actual column count, active
     code page and observed command support. Attach a photo of the test receipt if allowed.

## How to verify the software-only parts

From the repository root:

```bash
cd apps/mobile
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test test/printer_encoding_test.dart test/receipt_layout_test.dart \
  test/esc_pos_receipt_test.dart test/printer_adapter_test.dart \
  test/printer_controller_test.dart test/printer_screen_test.dart -r expanded
```

These tests prove command construction, encoding, wrapping, money formatting and UI states on this
host. They do not prove printer behaviour.

## Known limitations

- No hardware result exists yet; everything physical is PENDING.
- The adapter sends bytes and assumes the printer accepts them. It does not read status back
  (paper out, cover open, buffer full); that requires a model-specific status query.
- Cut and cash-drawer commands are built but their support is model dependent.
- Physical queue delivery remains unverified until the hardware checklist is run. Software-only queue states, restart recovery, retry policy, COPY reprints and audit are covered by #16 tests.
- LAN and USB transports are Phase 2.
- The app does not create or manage `printing_*` server records for this adapter; the OpenAPI
  contract was not changed by this ticket.
