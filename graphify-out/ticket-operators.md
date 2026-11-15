## Problem and evidence
Feedback, usability and performance records explicitly use developer walkthroughs and synthetic data. No representative cashier/owner field observations or production baselines exist, so completed implementation tickets do not establish operator acceptance.

Audit date: 2026-11-15. Baseline revision: `d4b3ac178ef7fd03078caca70fafd32843abeaca`.
Related: #2, #11, #12, #18, #28, #29, #30.

- [docs/operator-feedback.md](https://github.com/arkinara/modern-pos/blob/d4b3ac178ef7fd03078caca70fafd32843abeaca/docs/operator-feedback.md)
- [docs/usability-refinement.md](https://github.com/arkinara/modern-pos/blob/d4b3ac178ef7fd03078caca70fafd32843abeaca/docs/usability-refinement.md)
- [docs/performance-reliability.md](https://github.com/arkinara/modern-pos/blob/d4b3ac178ef7fd03078caca70fafd32843abeaca/docs/performance-reliability.md)

## Scope
Run a bounded consented pilot with representative cashier and owner roles; collect usability and reliability evidence on the intended device/screen sizes.

## Acceptance criteria
- [ ] Record participant roles, task scenarios, devices/viewports and observation dates without unnecessary personal/customer data.
- [ ] Observe catalog/cart/checkout, uncertain recovery, offline/reconnect, table/split and owner stock/sales/report tasks.
- [ ] Measure task completion, checkout time, mistakes, stock discrepancies and support friction using stated definitions.
- [ ] Check keyboard, touch targets, large text and accessible states on supported screens.
- [ ] Compare observations to the synthetic baseline without labelling synthetic measurements as production service levels.
- [ ] Rank follow-up work by impact/effort and obtain a clear acceptance/defer decision with evidence.

## Boundaries
No feature expansion before observation. Do not fabricate support incidents, real usage or participant feedback. Physical printing acceptance remains a separate prerequisite for release.

## Planning
Priority: P2. Source: Project 19 repository audit (2026-11-15).

## Dependencies
- [ ] #67 - [P1] fix(printing): connect kitchen station queues to Android delivery
- [ ] #68 - [P1] fix(mobile): support bounded offline session recovery and refresh retries
- [ ] #70 - [P2] fix(web): repair obsolete back-office shell verification
- [ ] #72 - [P2] test(web): retain and run owner and cashier browser regressions in CI
