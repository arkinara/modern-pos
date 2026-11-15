## Problem and evidence
Usability documentation cites browser verification scripts such as qa29-verify.cjs that are absent from this checkout. Current CI has no browser step and the four web tests cover only navigation definitions/money formatting. Rendered role gating, printer metadata and reference search can drift unnoticed.

Audit date: 2026-11-15. Baseline revision: `d4b3ac178ef7fd03078caca70fafd32843abeaca`.
Related: #5, #18, #29, #56, #57, #58, #59, #60.

- [docs/usability-refinement.md](https://github.com/arkinara/modern-pos/blob/d4b3ac178ef7fd03078caca70fafd32843abeaca/docs/usability-refinement.md)
- [.github/workflows/ci.yml](https://github.com/arkinara/modern-pos/blob/d4b3ac178ef7fd03078caca70fafd32843abeaca/.github/workflows/ci.yml)
- [apps/web/lib/back-office-nav.test.mts](https://github.com/arkinara/modern-pos/blob/d4b3ac178ef7fd03078caca70fafd32843abeaca/apps/web/lib/back-office-nav.test.mts)

## Scope
Commit and run a small reproducible browser suite for the implemented back-office flows, using synthetic sessions/data and the supported application build.

## Acceptance criteria
- [ ] Owner sees all 15 grouped destinations; cashier sees only permitted routes; active route is accessible.
- [ ] Cashier direct /reports shows the owner-only state with zero report requests; owner report/CSV works.
- [ ] Populated/empty/error printer states display real non-secret metadata and never imply physical connectivity.
- [ ] Cashier has no guaranteed-403 stock-history action; owner history works and stock-read errors use correct copy.
- [ ] Reference search reaches the API and respects date range/outlet; clearing restores results.
- [ ] Critical flows and keyboard/overflow checks run at 320px and desktop in required CI; scripts/fixtures are committed.

## Boundaries
Do not weaken API guards or infer physical print success from browser metadata. Preserve web back-office ownership.

## Planning
Priority: P2. Source: Project 19 repository audit (2026-11-15).

## Dependencies
- [ ] #70 - [P2] fix(web): repair obsolete back-office shell verification
