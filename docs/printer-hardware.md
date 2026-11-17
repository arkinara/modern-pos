# Printer transports and station routing hardware record (#25, #74)

Status: **implemented per transport, physical hardware acceptance PENDING**. No
printer, Bluetooth adapter, USB device or Android device was available on this
host. Nothing below claims that paper was produced. LAN byte framing was
validated against a real local TCP listener; Bluetooth and USB framing and state
transitions were unit-tested with fakes/mocked platform channels.

Date: 2026-11-13; updated 2026-11-16 for #74.

For #74, one combination is proposed but not verified:
Samsung Galaxy Tab A9 `SM-X110` (Android 14) with a Star Micronics TSP143IIIBI
over Bluetooth Classic SPP, 80 mm, CP437. See
`docs/hardware-selection.md` for the selection and reasoning and
`docs/hardware-acceptance.md` for the executable six-AC checklist. The
labels `SELECTED, NOT YET VERIFIED` and `PENDING` are not interchangeable with
supported.

## Supported hardware policy

Only evidence observed on real hardware may move a row out of `PENDING`. No
printer model is listed as supported by this project yet. A combination becomes
supported only after every AC in `docs/hardware-acceptance.md` passes on the
exact device, printer and firmware and dated logs plus paper photographs are
attached.

### Selected candidate for the first acceptance run (#74)

| Field | Candidate | State |
| --- | --- | --- |
| Device | Samsung Galaxy Tab A9 `SM-X110`, Android 14 | SELECTED, NOT YET VERIFIED |
| Printer | Star Micronics TSP143IIIBI, 80 mm, ESC/POS emulation | SELECTED, NOT YET VERIFIED |
| Firmware | Exact self-test string to be recorded at AC1 | NOT YET OBSERVED |
| Transport | Bluetooth Classic SPP (RFCOMM) | SELECTED, NOT YET VERIFIED |
| Paper / columns | 80 mm, 48 columns Font A | SELECTED, NOT YET VERIFIED |
| Code page | CP437 (printer code page 0; set with vendor utility) | SELECTED, NOT YET VERIFIED |
| Commands | `ESC @`, `ESC a`, `ESC E`, `LF`, `ESC d`, `GS V B 0` | Implemented; printer support PENDING |

The app does not send `ESC t`; the printer must already be configured to CP437.
Barcode, QR, partial cut, status back-channel and BLE are not implemented and are
not claimed. See `docs/hardware-selection.md` for why this combination was
chosen and which alternatives remain PENDING.

| Transport | Implementation | Host evidence | Physical state |
| --- | --- | --- | --- |
| Bluetooth Classic (RFCOMM/SPP) | `apps/mobile/lib/features/printing/android_printer_transport.dart` | Adapter, queue and byte builder unit/widget tested with fakes | `PENDING - requires selected Bluetooth ESC/POS printer + Android device` |
| LAN raw TCP | `apps/mobile/lib/features/printing/lan_printer_transport.dart` | Byte stream sent to a local `ServerSocket` listener and asserted; connection refusal classified | `PENDING - requires selected LAN ESC/POS printer model` |
| USB host | `apps/mobile/lib/features/printing/usb_printer_transport.dart` | State/framing tested with a mocked `modern_pos/printer_usb` platform channel | `PENDING - requires selected USB ESC/POS printer + Android device` |

Conventional candidate interfaces, not claims of verified support:

- ESC/POS text, 58 mm / 80 mm paper, raw TCP port 9100.
- Bluetooth Classic SPP serial-profile receipt printers.
- USB bulk-transfer receipt printers usable by Android USB host.

The exact command set, code page, column count, cutter, drawer pulse and
reconnect behaviour must be recorded from a real model before any row is marked
supported.

## LAN byte-level evidence

The following transcript was produced on this host by the LAN transport test
harness. A local `ServerSocket` accepted a connection and received the ESC/POS
test receipt built by the same `EscPosReceiptBuilder` used by the app.

```
received 592 bytes from 127.0.0.1:<ephemeral port>
1B 40 1B 61 01 1B 45 01 4D 6F 64 65 72 6E 20 50 4F 53 0A
1B 61 01 1B 45 00 ... 1B 61 00 1B 45 00
...
1B 61 00 1B 45 00 1B 64 02 1D 56 42 00
```

Decoded frames:

- `1B 40` - initialize printer.
- `1B 61 01` / `1B 61 00` - center / left alignment.
- `1B 45 01` / `1B 45 00` - bold on / off.
- `1B 64 02` - feed two lines.
- `1D 56 42 00` - full cut with feed (model support PENDING).

Re-run:

```bash
cd apps/mobile
flutter test test/lan_printer_transport_test.dart
```

#74 re-ran the same loopback test on 2026-11-16: 4 tests passed. The committed
test receipt is 592 bytes at 58 mm. A one-off probe in the same package (not
committed) measured 746 bytes for the 80 mm test receipt and 297 bytes for an
80 mm kitchen ticket, both ending in `1B 64 02 1D 56 42 00` (feed two lines,
full cut). This is byte transport evidence only; the selected printer's command
support and paper output remain PENDING.

Tests cover:

- real local TCP listener receiving the ESC/POS stream;
- refused connection classified as `connectionLost`;
- write after local disconnect classified as `notConnected`;
- `host:port` parsing with raw TCP port 9100 default.

A physical LAN printer may still reject the stream, use another port/protocol or
lack a cutter. Those outcomes remain PENDING.

## Physical acceptance recipes

The authoritative six-AC runbook for #74 is `docs/hardware-acceptance.md`. The
per-transport recipes below remain for future LAN, USB and alternate Bluetooth
models. Do not replace `PENDING` with a result unless the exact model and device
are recorded and every AC in the runbook passes.

### Bluetooth Classic

1. Install the debug APK on an Android device (`docs/android-build.md`).
2. Pair the printer in Android Bluetooth settings.
3. Open the printer screen, select Bluetooth Classic, enter the printer MAC,
   grant Bluetooth permission, save, connect and run Test print.
4. Record the model, Android version, active code page, column count, visible
   output and cut behaviour.
5. Print a completed sale, then amend or cancel one station line and photograph
   both station tickets with the order reference.

State: `PENDING - requires printer model + Android device`.

### LAN raw TCP

1. Put the printer on the same network and confirm its IP and raw port (usually
   9100) in the vendor manual.
2. Select Network (LAN), enter `host:port`, save, connect and run Test print.
3. Record the model, firmware, port, visible output and cut behaviour.
4. Disconnect the network cable during a job and record whether the job becomes
   `FAILED` or `UNKNOWN`. Sales and stock must remain unchanged.

State: `PENDING - requires LAN printer model`.

### USB host

1. Connect the printer by USB OTG, grant the Android USB permission prompt.
2. Select USB, scan devices or enter the device id, save, connect and run Test
   print.
3. Record the model, Android version, endpoint/bulk transfer evidence, visible
   output and cut behaviour.

State: `PENDING - requires USB printer + Android device`.

## Station routing boundary

- Menu items route to one station per outlet. Unrouted items use the default
  station, or the first station by sort order when no default exists.
- Each station has its own queue and job states (`QUEUED`, `SENDING`, `SENT`,
  `FAILED`, `UNKNOWN`). A failed bar ticket does not block the kitchen queue.
- Station jobs carry the sale reference when the order is finalized, otherwise
  `ORDER-<orderId>`. `ORIGINAL`, `AMEND` and `CANCEL` are distinct job kinds.
- Reprint creates a new station job copy. Retry requeues the same job.
- Station print, retry, reprint, amendment and cancellation never update
  `sales`, `sale_lines` or `stock_movements`. Reversing money/stock remains the
  separate sale-reversal path (`#17`).
- Android claims one station job with a compare-and-set `QUEUED -> SENDING`
  before writing. The flow, UNKNOWN/COPY policy and physical acceptance recipe
  are in `docs/kitchen-delivery.md`.
- The physical station ORIGINAL/AMEND/CANCEL observation remains `PENDING -
  requires Android device + ESC/POS printer`; fake transports cannot replace
  paper evidence. AC3 of `docs/hardware-acceptance.md` is the executable recipe,
  including the AMEND/CANCEL job creation command because the app has no AMEND
  dispatch UI.
- The selected #74 combination is still `SELECTED, NOT YET VERIFIED`. No row in
  this document is supported until AC1-AC6 pass on that exact hardware.
