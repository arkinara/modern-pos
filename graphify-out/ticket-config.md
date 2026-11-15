## Problem and evidence
Auth config defaults to a committed development JWT secret and insecure cookies. Payment config defaults to MOCK; SandboxProviderController exposes public create/read/event routes whenever MOCK is selected, including signed mock events. No production environment gate was found. These are intended development behaviours but lack fail-closed production safeguards. This audit did not observe an exposed production instance or prove arbitrary JWT impersonation; database session validation remains present.

Audit date: 2026-11-15. Baseline revision: `d4b3ac178ef7fd03078caca70fafd32843abeaca`.
Related: #4, #18, #22.

- [apps/api/src/auth/auth.config.ts#L46](https://github.com/arkinara/modern-pos/blob/d4b3ac178ef7fd03078caca70fafd32843abeaca/apps/api/src/auth/auth.config.ts#L46)
- [apps/api/src/payments/payment-config.service.ts#L8](https://github.com/arkinara/modern-pos/blob/d4b3ac178ef7fd03078caca70fafd32843abeaca/apps/api/src/payments/payment-config.service.ts#L8)
- [apps/api/src/payments/sandbox-provider.controller.ts](https://github.com/arkinara/modern-pos/blob/d4b3ac178ef7fd03078caca70fafd32843abeaca/apps/api/src/payments/sandbox-provider.controller.ts)
- [apps/api/src/main.ts](https://github.com/arkinara/modern-pos/blob/d4b3ac178ef7fd03078caca70fafd32843abeaca/apps/api/src/main.ts)

## Scope
Validate production configuration at startup and make sandbox routes unavailable in production independently of provider selection.

## Acceptance criteria
- [ ] Production startup rejects missing/placeholder secrets, unsafe cookie settings and missing/invalid explicit allowed origins.
- [ ] Production has explicit payment-provider/mode configuration; implicit mock fallback is rejected.
- [ ] Sandbox provider routes return unavailable in production even if MOCK is mistakenly selected.
- [ ] Local/test sandbox use requires explicit documented opt-in; normal local development remains reproducible.
- [ ] Automated startup/controller checks cover safe and unsafe combinations; diagnostics do not reveal secrets.
- [ ] Update environment/deployment docs and retain session, CSRF and outlet authorization checks.

## Boundaries
Do not claim a deployed vulnerability was observed. Do not add real provider credentials or change financial calculations.

## Planning
Priority: P1. Source: Project 19 repository audit (2026-11-15).

## Dependencies
None. Can start independently.
