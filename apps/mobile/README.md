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

## Scope

Authentication is implemented. Menu, stock and sale screens, offline reconciliation, printer
transport and the full cashier shell arrive in #6/#7/#11/#12/#15.

## arm64 Linux hosts

The installed Android SDK tools are x86-64 binaries. On an arm64 development host, run
`bash tools/setup-arm64-android-sdk.sh` once; CI uses an x86-64 runner and needs no setup.
