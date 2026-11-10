# Android build instructions

Status: commands verified for the debug build on this Linux host. A physical Android
device and printer were not available for this ticket. Device and paper results remain
`PENDING` with reproduction recipes in `docs/printer-validation.md`.

## Toolchain

| Tool | Required/verified version |
| --- | --- |
| Flutter | 3.47.0 stable |
| Dart | 3.13.0 |
| Java | OpenJDK 17 |
| Android SDK | compile/target API 36 |
| Android build tools | 36.0.0 |
| Android NDK | 28.2.13676358 |
| `ANDROID_HOME` | `/home/ubuntu/android-sdk` on this VPS |

The CI workflow installs the same API, build-tools and NDK versions. See
`.github/workflows/ci.yml`.

## Dependency and test commands

```bash
cd apps/mobile
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Expected on the current tree: analyze reports no issues and the host test suite
passes. Physical printing is not exercised by these tests.

## Debug APK

```bash
cd apps/mobile
flutter build apk --debug
ls -lh build/app/outputs/flutter-apk/app-debug.apk
```

Install on a connected device:

```bash
adb devices
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

The debug APK uses the debug signing key. It is for device verification, not a
production release.

## API address

The app reads the API base URL at compile time:

```bash
flutter build apk --debug \
  --dart-define=API_BASE_URL=http://10.0.2.2:4000
```

| Target | Typical value |
| --- | --- |
| Android emulator on the same host | `http://10.0.2.2:4000` |
| Physical device on the same LAN | `http://<staging-host-lan-ip>:4000` |
| HTTPS staging | `https://api.example.test` |

The default is `http://10.0.2.2:4000`. A physical device cannot reach the host through
`10.0.2.2`; use a reachable LAN address or a TLS reverse proxy.

## Release APK

The current Gradle configuration still signs release builds with the debug key
(`apps/mobile/android/app/build.gradle.kts`). Do not distribute that output as a
production release.

A real release requires a private keystore kept outside the repository. Placeholder
steps only:

```bash
# Do not run with real passwords in shell history on a shared host.
keytool -genkeypair -v \
  -keystore <path-outside-repository>/modern-pos-release.jks \
  -alias modern-pos \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -storepass '<keystore-password>' \
  -keypass '<key-password>'

# apps/mobile/android/key.properties (git-ignored; placeholders only)
storePassword=<keystore-password>
keyPassword=<key-password>
keyAlias=modern-pos
storeFile=<absolute-path-outside-repository>/modern-pos-release.jks
```

Then wire `signingConfigs.release` in `android/app/build.gradle.kts`, set
`signingConfig = signingConfigs.getByName("release")`, and build:

```bash
cd apps/mobile
flutter build apk --release --dart-define=API_BASE_URL=https://api.example.test
```

The repository does not currently contain release signing configuration. Treat the
release command as a checklist, not a completed production build.

## Device verification checklist

Run every step on the actual device and record the model and Android version. Do not
mark a step passed from a host test.

1. Install the APK with `adb install -r <apk>`.
2. Launch Modern POS and confirm the sign-in screen renders without overflow.
3. Sign in with a synthetic cashier account against the staging API.
4. Confirm the API health indicator is reachable over the chosen API address.
5. Open the catalog refresh action and confirm menu data loads.
6. Add an item to the cart, open checkout, enter cash and verify live change.
7. Submit once and confirm one server reference is returned.
8. Kill the app after submission, reopen it and confirm checkout recovery finds the
   same reference instead of creating another sale.
9. Open the completed sale receipt and verify the printed preview values against the
   owner web sales list.
10. Pair a real Bluetooth printer, grant permissions, run Test print and then print the
    completed sale. Record whether paper came out. Follow
    `docs/printer-validation.md` for every hardware result.
11. Turn the printer off during a print and confirm the cashier UI reports `FAILED` or
    `UNCERTAIN` honestly. Confirm the sale reference and amount did not change.
12. Refresh the owner web stock, sales and reports screens and reconcile the same
    reference, quantities and total.

Steps 1-9 are `PENDING - requires Android device` on this VPS. Steps 10-11 are
`PENDING - requires Android device and printer`. Step 12 was verified with the same
API endpoint the app calls, but not from the app UI; see the PR evidence for ticket
#18.

## Troubleshooting

| Symptom | Check |
| --- | --- |
| App cannot reach API | `API_BASE_URL` must be reachable from the device, not the host loopback |
| `flutter pub get` fails | Check network access to pub.dev and the repository lockfile |
| Gradle download fails | Retry; CI has bounded retry logic for transient download failures |
| Bluetooth printer not found | Pair in Android settings first; grant Bluetooth permissions; see `docs/printer-validation.md` |
| Release APK rejected by store | Release signing has not been configured in this repository |
