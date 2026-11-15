## Problem and evidence
Printer adapters and synthetic/loopback checks exist, but printer-validation.md and printer-hardware.md list no hardware-supported model. Android checkout recovery, printer disconnect and physical paper output remain pending; implementation closure did not complete this acceptance.

Audit date: 2026-11-15. Baseline revision: `d4b3ac178ef7fd03078caca70fafd32843abeaca`.
Related: #12, #15, #16, #18, #20, #25.

- [docs/printer-validation.md](https://github.com/arkinara/modern-pos/blob/d4b3ac178ef7fd03078caca70fafd32843abeaca/docs/printer-validation.md)
- [docs/printer-hardware.md](https://github.com/arkinara/modern-pos/blob/d4b3ac178ef7fd03078caca70fafd32843abeaca/docs/printer-hardware.md)
- [docs/android-build.md](https://github.com/arkinara/modern-pos/blob/d4b3ac178ef7fd03078caca70fafd32843abeaca/docs/android-build.md)

## Scope
Select one exact Android device/version and printer model/firmware/transport for the initial supported configuration and execute the physical acceptance checklist.

## Acceptance criteria
- [ ] Record device, Android version, printer model/firmware, transport, code page, width and supported commands.
- [ ] Verify permission denial/regrant, pairing/connect, test output, receipt totals/layout/encoding and reconnection on real hardware.
- [ ] Observe physical kitchen ORIGINAL/AMEND/CANCEL tickets with stable references after the station integration fix.
- [ ] Exercise mid-write disconnect/process restart; UNKNOWN never silently resends and COPY is visibly marked.
- [ ] Exercise app restart/offline recovery and checkout reconnect; reconcile one sale/payment and exact stock effects.
- [ ] Attach dated logs and paper/photo evidence; mark only the tested combination supported and leave other combinations pending.

## Boundaries
Requires access to selected hardware. Mock channels, APK builds and TCP listeners cannot substitute for paper evidence; do not claim all transports verified.

## Planning
Priority: P1. Source: Project 19 repository audit (2026-11-15).

## Dependencies
- [ ] #67 - [P1] fix(printing): connect kitchen station queues to Android delivery
- [ ] #68 - [P1] fix(mobile): support bounded offline session recovery and refresh retries
