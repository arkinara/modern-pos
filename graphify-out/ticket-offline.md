## Problem and evidence
AuthController.build restores sessions only through online refresh; any Dio network failure returns null, and ModernPosApp then shows SignInScreen. An outage plus app restart blocks cashier and queue UI even though encrypted queued records survive. No persisted authorized offline profile/catalog was found. Timed refresh also schedules another timer only on success, so a transient non-401 refresh failure loses automatic retries. These findings are source-traced, not physical Android reproductions.

Audit date: 2026-11-15. Baseline revision: `d4b3ac178ef7fd03078caca70fafd32843abeaca`.
Related: #4, #12, #19.

- [apps/mobile/lib/features/auth/auth_controller.dart#L36](https://github.com/arkinara/modern-pos/blob/d4b3ac178ef7fd03078caca70fafd32843abeaca/apps/mobile/lib/features/auth/auth_controller.dart#L36)
- [apps/mobile/lib/features/auth/auth_controller.dart#L118](https://github.com/arkinara/modern-pos/blob/d4b3ac178ef7fd03078caca70fafd32843abeaca/apps/mobile/lib/features/auth/auth_controller.dart#L118)
- [apps/mobile/lib/app.dart#L32](https://github.com/arkinara/modern-pos/blob/d4b3ac178ef7fd03078caca70fafd32843abeaca/apps/mobile/lib/app.dart#L32)
- [apps/mobile/lib/features/catalog/catalog_repository.dart](https://github.com/arkinara/modern-pos/blob/d4b3ac178ef7fd03078caca70fafd32843abeaca/apps/mobile/lib/features/catalog/catalog_repository.dart)

## Scope
Define the supported offline session lifetime and revocation/reconnect policy, then implement bounded authorized offline restart, scoped catalog/settings snapshots and resilient refresh retries.

## Acceptance criteria
- [ ] A previously authorized session within the documented offline allowance can restart without network and access its scoped cashier/queue UI.
- [ ] Persist scoped catalog/settings needed for offline capture; display snapshot age and offline limitations.
- [ ] Expired/missing offline authorization requires sign-in; a new unauthenticated install cannot sell offline.
- [ ] Transient refresh failure schedules bounded retries/reconnect recovery; 401/revocation follows the explicit policy.
- [ ] Sign-out or account/outlet changes do not expose another user's/outlet's cached data or replay its queue without authorization.
- [ ] Tests cover restart while offline, expired authorization, transient refresh outage/reconnect and durable queue preservation.

## Boundaries
Do not bypass authentication unconditionally or promise server acceptance/stock reservation while offline. If product policy excludes restart-capable sales, record the explicit decision and narrow UI/docs instead of reporting full offline acceptance.

## Planning
Priority: P1. Source: Project 19 repository audit (2026-11-15).

## Dependencies
None. Can start independently.
