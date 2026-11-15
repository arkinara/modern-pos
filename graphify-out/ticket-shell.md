## Problem and evidence
node apps/web/scripts/verify-shell.cjs fails at line 21: navigation labels and order changed. The script parses inline SidebarNav labels and expects the old six destinations; navigation now lives in back-office-nav.ts and contains 15 owner destinations. Four current pure web tests pass. The stale assertion is not evidence that the new navigation is broken.

Audit date: 2026-11-15. Baseline revision: `d4b3ac178ef7fd03078caca70fafd32843abeaca`.
Related: #5, #29, #56.

- [apps/web/scripts/verify-shell.cjs#L19](https://github.com/arkinara/modern-pos/blob/d4b3ac178ef7fd03078caca70fafd32843abeaca/apps/web/scripts/verify-shell.cjs#L19)
- [apps/web/lib/back-office-nav.ts](https://github.com/arkinara/modern-pos/blob/d4b3ac178ef7fd03078caca70fafd32843abeaca/apps/web/lib/back-office-nav.ts)
- [apps/web/components/sidebar-nav.tsx](https://github.com/arkinara/modern-pos/blob/d4b3ac178ef7fd03078caca70fafd32843abeaca/apps/web/components/sidebar-nav.tsx)

## Scope
Update the documented shell check to verify the current grouped, role-aware shell; audit remaining checks against page wrappers that now delegate to screen components.

## Acceptance criteria
- [ ] The documented verify:shell command passes against current routes and grouped navigation.
- [ ] Check all 15 owner destinations exactly once, cashier-permitted destinations and no cashier-enabled owner-only routes.
- [ ] Preserve active-route accessibility, responsive navigation and the web back-office/cashier boundary.
- [ ] Remove assumptions about obsolete file locations/inline labels without weakening meaningful checks.
- [ ] A deliberate forbidden route or missing destination causes verification failure; existing web tests remain green.

## Boundaries
Do not revert or remove new navigation to satisfy a stale test. Do not introduce product behaviour unrelated to shell verification.

## Planning
Priority: P2. Source: Project 19 repository audit (2026-11-15).

## Dependencies
None. Can start independently.
