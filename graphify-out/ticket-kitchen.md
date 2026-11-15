## Problem and evidence
Station routing persists jobs and exposes state/retry endpoints, but no station-job API consumer or kitchen-ticket renderer was found in mobile application source. PrintQueueService processes sale receipts, not station queues. No server worker connects those jobs to printer transport either. API job records and a loopback receipt test do not complete a kitchen delivery flow. This is a source-traced integration gap, separate from physical hardware verification.

Audit date: 2026-11-15. Baseline revision: `d4b3ac178ef7fd03078caca70fafd32843abeaca`.
Related: #25.

- [apps/api/src/printing/station-routing.service.ts#L272](https://github.com/arkinara/modern-pos/blob/d4b3ac178ef7fd03078caca70fafd32843abeaca/apps/api/src/printing/station-routing.service.ts#L272)
- [apps/api/src/printing/station-routing.service.ts#L417](https://github.com/arkinara/modern-pos/blob/d4b3ac178ef7fd03078caca70fafd32843abeaca/apps/api/src/printing/station-routing.service.ts#L417)
- [apps/mobile/lib/features/printing/print_queue_service.dart](https://github.com/arkinara/modern-pos/blob/d4b3ac178ef7fd03078caca70fafd32843abeaca/apps/mobile/lib/features/printing/print_queue_service.dart)
- [docs/printer-hardware.md](https://github.com/arkinara/modern-pos/blob/d4b3ac178ef7fd03078caca70fafd32843abeaca/docs/printer-hardware.md)

## Scope
Connect order creation/amendment/cancellation to durable station events and implement Android station claiming, rendering, printer selection and delivery state handling.

## Acceptance criteria
- [ ] An app order routes its items to the configured stations and produces station-specific transport writes.
- [ ] AMEND and CANCEL tickets retain the same stable order reference and correct item changes.
- [ ] Two concurrent consumers cannot claim/send the same queued job.
- [ ] Interrupted delivery stays UNKNOWN and requires an explicit COPY decision; no automatic uncertain resend.
- [ ] Retry and COPY remain independent of sale finalization, payment and stock effects.
- [ ] Automated app-to-two-fake-transports tests cover routing, amendment, cancellation, disconnect and restart; document the physical acceptance recipe.

## Boundaries
Keep cashier/physical execution on Android. Do not move checkout into the web app or claim hardware acceptance from fake transports.

## Planning
Priority: P1. Source: Project 19 repository audit (2026-11-15).

## Dependencies
None. Can start independently.
