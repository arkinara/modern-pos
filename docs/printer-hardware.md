# Printer transports and station routing hardware record (#25)

Status: **implemented per transport, physical hardware acceptance PENDING**. No
printer, Bluetooth adapter, USB device or Android device was available on this
host. Nothing below claims that paper was produced. LAN byte framing was
validated against a real local TCP listener; Bluetooth and USB framing and state
transitions were unit-tested with fakes/mocked platform channels.

Date: 2026-11-13.

## Supported hardware policy

Only evidence observed on real hardware may move a row out of `PENDING`. No
printer model is listed as supported by this project yet.

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

Tests cover:

- real local TCP listener receiving the ESC/POS stream;
- refused connection classified as `connectionLost`;
- write after local disconnect classified as `notConnected`;
- `host:port` parsing with raw TCP port 9100 default.

A physical LAN printer may still reject the stream, use another port/protocol or
lack a cutter. Those outcomes remain PENDING.

## Physical acceptance recipes

Do not replace `PENDING` with a result unless the exact model and device are
recorded.

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
