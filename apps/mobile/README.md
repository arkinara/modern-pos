# Mobile cashier (Flutter, Android first)

Flutter scaffold for the Android cashier. Riverpod handles state and dependency wiring,
go_router owns navigation, Dio speaks to the API, Drift provides the small durable local recovery
queue, and the generated Dart package `modern_pos_api_client` is the contract client.

## Commands

```bash
export ANDROID_HOME=/home/ubuntu/android-sdk
export ANDROID_SDK_ROOT=/home/ubuntu/android-sdk

flutter pub get
dart run build_runner build          # regenerate Drift code after schema edits
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
```

The API base URL defaults to `http://10.0.2.2:4000` (Android emulator loopback alias). Override it
at build time:

```bash
flutter build apk --debug --dart-define=API_BASE_URL=http://192.168.1.10:4000
```

No emulator or physical device is required for the ticket gate; the debug APK build is the
Android check.

## Generated API client

`packages/api_client_dart` is generated from the root `API.openapi.json`. Regenerate from the
repository root with `pnpm openapi:generate`. Do not hand-edit the generated package.

## Authentication (#4)

The app starts with a cashier sign-in screen. The refresh token and a generated device UUID live in
`flutter_secure_storage`; the access token stays in memory. Refresh rotates the stored token before
the 10-minute access token expires. A 401 on any protected request clears local credentials and
returns to sign-in. The sign-out action revokes the server session and clears secure storage.

## Cashier shell (#11)

Bottom navigation exposes Catalog, Cart, Settings and Status (the existing dashboard health
screen). Catalog is the initial destination. The cart badge shows the number of unsent lines.

- Categories render as a horizontally scrolling chip row with an All option.
- Search is debounced by 300 ms and matches item name, description and variant name locally over
  the refreshed catalog.
- A single-variant item is added directly. Multi-variant items open a required variant sheet.
- Prices are integer minor units. The outlet currency and exponent come from
  `GET /outlets/{id}/settings`; IDR exponent 0 renders as `Rp28.000` without float math.
- Cart totals are display-only derived values. The server quote in #12 remains authoritative.
- `availableUnits` from `GET /outlets/{id}/menu` is advisory. `null` means UNTRACKED and is
  available. Zero units, disabled variants and archived items stay visible but cannot be added.

### Unavailable cart lines (explicit policy)

If a catalog refresh removes an item/variant or marks it unavailable, the unsent line is **kept and
marked** with the reason. It is not silently deleted. The cashier can remove it from the cart. This
policy is covered by `cashier_flow_test.dart` and `cart_controller_test.dart`.

### Durability (AC3)

The cart is persisted in Drift (`cart_entries`, schema version 2). Every add, quantity change,
removal and clear writes to SQLite before publishing state. A catalog refresh does not touch the
cart. A 401 still clears the mobile session and returns to sign-in, but the persisted unsent cart
survives and reloads after re-authentication.

## Receipt printer (#15)

Settings -> Receipt printer provides the cashier-facing configuration, connection and test-print
surface.

- Bluetooth Classic (RFCOMM/SPP) is the only implemented transport candidate. Network (LAN) and
  USB are shown as **not verified on this project** and keep Connect/Test print disabled.
- The app requests Bluetooth runtime permissions on Android 12+ (`BLUETOOTH_CONNECT`,
  `BLUETOOTH_SCAN`) and uses location/discovery permissions on older versions. A denial is visible
  and the request can be retried. Manifest comments map each permission to the printer feature.
- `EscPosPrinterAdapter` renders ESC/POS bytes from receipt data (CP437 or UTF-8, 58/80 mm column
  widths, optional cut and drawer pulse) and writes them to the transport.
- A test-print success means bytes were accepted by the transport socket. **Physical output is not
  verified on this project**; no printer model or Android device was supplied. The full record and
  acceptance recipe live in [docs/printer-validation.md](../../docs/printer-validation.md).
- No print queue, retry or reprint action (#16). No `printing_*` contract change.

## Scope

Implemented: authentication (#4), catalog browsing, variants, availability advisory, and the
durable cart shell (#11). Deferred:

- #12 checkout, quote/finalization, receipt and recovery UX. The app does **not** call
  `order_quote` or `sales_finalize` in this ticket.
- #13 stock UI, #14 sales history, #16 print queue/retry/reprint. Printer transport candidate and hardware record are in #15 (unverified until a real device is tested).
- Offline sale reconciliation/sync (#19). Catalog reads require the API; the cart stays local.
- Final mobile visual sign-off: `PENDING — requires owner review (#2)`.
- Physical device/emulator verification: `PENDING — requires device/emulator`.

## arm64 Linux hosts

The installed Android SDK tools are x86-64 binaries. On an arm64 development host, run
`bash tools/setup-arm64-android-sdk.sh` once; CI uses an x86-64 runner and needs no setup.
