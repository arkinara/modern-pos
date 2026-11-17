# Configurable automatic cutter under #74

On 2026-11-17 the owner requested a user-selectable automatic cutter option with default No after reviewing a 58 mm Blueprint ECO58D printer.

## Delivered behavior

- Receipt printer settings include an Automatic cutter switch, initially off.
- The choice is saved in the existing device printer configuration and restored when settings reopen.
- New configurations and older saved configurations without the field default to off.
- Sale receipts, test prints and kitchen tickets emit the cutter command only when enabled through the saved configuration. Existing explicit builder overrides remain available.
- Durable queued receipt snapshots retain the choice through database serialization.

The implementation commit is `b1d22caa6b0ed1d4a56c6c6faf6d60156f5c62c6` on `codex/74-automatic-cutter`.

## Verification

The existing ESC/POS test established that the old default emitted a cut command. The revised regression requires feed-only output by default and a cut command when enabled. Additional tests cover configuration defaults, legacy JSON, both serialization values, copy/update behavior, actual Drift queue persistence, all three adapter print paths and the settings switch saving/reloading both choices.

Fifteen local pure-Dart smoke assertions passed for defaults, JSON round trips, copy/update, receipt/test/kitchen bytes and explicit override compatibility. [Local output](ticket-74-cutter-local.txt)

The local Flutter SDK uses Dart 3.12.2 while the repository requires Dart 3.13. Full Flutter unit/widget tests, analysis and Android build use the pinned Flutter 3.47.0 CI toolchain. The PR and #74 QA comment record the pipeline result before handoff.

The Impeccable mechanical check returned no findings for the changed settings screen. Existing Flutter theme and native switch behavior are reused.

## Physical acceptance

Real printer pairing, paper output, cutter behavior and disconnect recovery remain pending under #74. The generic setting does not establish Blueprint ECO58D hardware acceptance. The owner has deferred representative operator testing under #76.
