# Initial printer and Android hardware selection (#74)

Status: **SELECTED, NOT YET VERIFIED**. No Android device, receipt printer,
paper or camera was available on this host. This document records the one
combination proposed for the first hardware acceptance run. It is not a claim
that the combination works. Every field below stays unverified until the
checklist in `docs/hardware-acceptance.md` is executed on the exact hardware and
dated logs plus paper photographs are attached.

Date: 2026-11-16.
Baseline: `d68daca` (#72 merge) with #67 (`9cc95cd`) and #68 (`2485f8c`) merged.

## Selected combination

| Field | Selection | Status |
| --- | --- | --- |
| Android device | Samsung Galaxy Tab A9, model `SM-X110` (Wi-Fi) | SELECTED, NOT YET VERIFIED |
| Android version | Android 14 (One UI 6.x) | SELECTED, NOT YET VERIFIED. Exact build number and security patch must be recorded at AC1. |
| Printer | Star Micronics TSP143IIIBI (80 mm Bluetooth receipt printer) | SELECTED, NOT YET VERIFIED |
| Printer firmware | Star Micronics TSP143IIIBI firmware, latest vendor release at the time of the run, with ESC/POS emulation enabled. Exact version string must be printed from the printer self-test at AC1. | NOT YET OBSERVED. No firmware version number is asserted here. |
| Transport | Bluetooth Classic SPP (RFCOMM) | SELECTED, NOT YET VERIFIED |
| Connection address | Android Bluetooth MAC address of the paired printer | SELECTED, NOT YET VERIFIED |
| Paper | 80 mm thermal roll, 48 columns in Font A | SELECTED, NOT YET VERIFIED. Confirm the printer's configured column count at AC1. |
| Code page | CP437 (printer code page 0) | SELECTED, NOT YET VERIFIED. The app encodes CP437 bytes but does not send an `ESC t` code-page select command; the printer must be configured to CP437 with the vendor utility before the run. |
| Cut | Full cut with feed, `GS V B 0` | SELECTED, NOT YET VERIFIED. The model has an auto-cutter; the exact command support must be observed. |
| Cash drawer | Not part of this acceptance | `ESC p` is implemented but disabled by default and not wired to the UI. |

Mobile app package: `com.modernpos.modern_pos_mobile`.

## Why this combination

The first supported configuration should exercise the permission, pairing and
reconnection paths that the Android app already implements, with the least
custom vendor code.

- **Bluetooth Classic SPP** is the transport implemented by
  `apps/mobile/lib/features/printing/android_printer_transport.dart`. It calls
  the `modern_pos/printer` method channel in
  `apps/mobile/android/app/src/main/kotlin/com/modernpos/modern_pos_mobile/MainActivity.kt`.
  Selecting it makes AC2 (permission denial/regrant and pairing) directly
  applicable instead of not applicable.
- **Android 14** is the runtime-permission boundary the app targets:
  `BLUETOOTH_CONNECT` and `BLUETOOTH_SCAN` are runtime permissions on API 31+.
  `apps/mobile/lib/features/printing/printer_permissions.dart` and the manifest
  implement that split. A device on Android 14 exercises the modern path.
- **Star TSP143IIIBI** is a widely deployed 80 mm receipt printer with Bluetooth
  SPP, ESC/POS emulation, an auto-cutter and a cash-drawer port. It is a
  commodity model that a shop can buy without a custom integration.
- **80 mm / 48 columns** matches `PaperWidth.mm80` in
  `apps/mobile/lib/features/printing/printer_models.dart`.
- **CP437** matches the app's default `PrinterEncoding.cp437` and the pure-Dart
  encoder in `apps/mobile/lib/features/printing/printer_encoding.dart`.
- The commands the app emits are the common ESC/POS subset implemented in
  `apps/mobile/lib/features/printing/esc_pos_receipt.dart`; see the command list
  below.

The **Samsung Galaxy Tab A9 `SM-X110`** is a current, widely available Android
tablet with Bluetooth Classic, Wi-Fi and USB-C OTG. A tablet form factor is
appropriate for a cashier station. It leaves LAN and USB available as later
candidates without changing the selected Bluetooth run.

## Commands the app emits

The byte builder uses this subset. The acceptance run must confirm that the
selected printer honours each command; support is not assumed.

| Purpose | Bytes | Builder method |
| --- | --- | --- |
| Initialise printer | `1B 40` (`ESC @`) | `initialise()` |
| Alignment | `1B 61 00` left, `1B 61 01` centre (`ESC a n`) | `alignment()` |
| Bold | `1B 45 01` on, `1B 45 00` off (`ESC E n`) | `bold()` |
| Line feed | `0A` (`LF`) | `newline()` / `line()` |
| Feed lines | `1B 64 02` (`ESC d n`) | `feed()` |
| Full cut with feed | `1D 56 42 00` (`GS V B 0`) | `cut()` |
| Cash drawer pulse | `1B 70 00 19 FA` (`ESC p 0 25 250`) | `cashDrawer()`, not used by default |

Not implemented and therefore not claimed for this combination: barcode, QR
code, partial cut, status back-channel (paper out, cover open, buffer full),
Bluetooth Low Energy, code-page select (`ESC t`). A real model that needs any of
these requires a separate ticket.

## Why the other transports are not the first selection

| Candidate | Why not selected for the first run | Current state |
| --- | --- | --- |
| LAN raw TCP | Strongest host-side byte evidence from #25 (a local `ServerSocket` received the exact stream), but it does not exercise the Bluetooth permission/pairing ACs in #74. | Implemented, physical output PENDING. Candidate for a later LAN model. |
| USB host | Requires device-specific USB permission prompts and bulk-endpoint behaviour; no USB printer vendor path has been exercised. | Implemented with a mocked platform channel, physical output PENDING. |
| Bluetooth Low Energy | No BLE transport exists. | Not implemented. |
| iOS | Out of Android scope. | Not applicable. |

## Adapter stack that must carry this combination

1. `apps/mobile/lib/features/printing/printer_screen.dart` saves the transport,
   address, paper width and encoding.
2. `apps/mobile/lib/features/printing/printer_transport_factory.dart` creates
   `AndroidBluetoothPrinterTransport` for `bluetoothClassic`.
3. `apps/mobile/lib/features/printing/android_printer_transport.dart` calls the
   `modern_pos/printer` channel for paired-device discovery, connect, write and
   disconnect.
4. `MainActivity.kt` owns the Android Bluetooth socket and permission results.
5. `apps/mobile/lib/features/printing/printer_adapter.dart` builds sale receipts
   and kitchen tickets and writes the bytes.
6. `apps/mobile/lib/features/printing/station_delivery_service.dart` claims
   station jobs and writes kitchen tickets through the same adapter.

## What would make this combination supported

Only the executed checklist moves this table out of `SELECTED, NOT YET VERIFIED`:

1. Every AC in `docs/hardware-acceptance.md` passes on the exact device, printer
   and firmware above.
2. Dated logs, screenshots and paper photographs are attached to the ticket/PR.
3. AC1 records the actual Android build string, printer firmware, configured
   code page and column count.
4. The result tables in `docs/printer-validation.md` and
   `docs/printer-hardware.md` are updated with observed values.

Until then this is a proposal, not a supported configuration. All other
combinations remain PENDING.
