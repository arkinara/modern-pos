# Developer handoff — M01 and M02

Architecture baseline and design review package. No production backend, Flutter app, database or physical printer integration is delivered here.

## Read in this order

1. [TECH_STACK.md](TECH_STACK.md): selected Flutter, Next.js, NestJS, PostgreSQL/Prisma foundation.
2. [ARCHITECTURE.md](ARCHITECTURE.md): domain, transaction rules, authorization, recovery, deployment and implementation sequence.
3. [API.openapi.json](API.openapi.json): 40 API operations and 47 schemas, contract version 0.1.0.
4. [DESIGN_SYSTEM.md](DESIGN_SYSTEM.md) and [design-tokens.json](design-tokens.json): proposed visual/interaction rules.
5. [prototype.html](prototype.html): interactive browser prototype; open directly as a local file or serve statically. It needs no package installation, backend, build, or external assets.
6. [VALIDATION.json](VALIDATION.json): structural/API/script/contrast checks and their limits.

## Start the implementation

- Pick up **#3** first: scaffold the selected stack, local database, migration/seed tooling, OpenAPI clients and CI. Keep business rules in NestJS, not Next.js/Flutter.
- Then **#4**, **#6**, **#7**: auth/outlet isolation, catalog, append-only stock ledger. UI work under **#5/#11** should wait for the owner's style feedback on **#2**; backend scaffolding can proceed.
- Implement **#8/#9/#10** as one coherent path: recipe snapshots, server quotes, atomic stock/sale writes. Do not turn a timeout into a second sale or key.
- **#12/#16**: durable mobile checkout recovery and independent print queue. The static prototype is a design reference, not transaction/authorization code to reuse in production.
- **#15** requires an actual printer model/transport/device and physical verification. Demo print controls prove interaction wording only.
- **#18** owns API/database concurrency tests, device builds, deployment, backup restore and production readiness. This design pass does not mark those checks complete.

## Visual review walkthrough

Open the prototype on Menu. Edit a name or price, then adjust stock with a reason. Reports contains a synthetic mobile sale for receipt detail and CSV export; selecting another date shows the empty state. Printers retains simulated configuration/test controls. Use Screen state and Connection controls, and resize to phone/tablet/desktop widths.

The web prototype has no cashier, cart, tender or checkout. These belong exclusively to Flutter under #11/#12. The separate mobile design and remaining web Sales/settings flows are tracked in #2. The warm neutral/terracotta design remains In QA for owner review; #3 scaffolding can proceed independently.

## Prototype boundaries

All data is synthetic and held in browser memory. Reload resets edits and printer state. The sample mobile sale is a fixed fixture, not a sale recorded by the web app. Printer controls simulate feedback only; Android owns discovery, permissions and physical printing under #15/#16. No production services or real payments are connected.

## Outstanding operational inputs

Printer model, transport, Android device/version, business-specific receipt/tax rules, hosting budget/region and dependency version pins must be validated under their implementation tickets. The stack itself is already selected.

## Verification record

Structural contract/reference checks, JavaScript parse and seven core text-contrast pairs pass; details are in VALIDATION.json. These structural checks do not constitute a full OpenAPI meta-schema validation or a production accessibility audit.

Reproduce these dependency-free checks with `node verify-foundation.cjs` from the repository root. It refreshes VALIDATION.json and exits nonzero on structural, script syntax or contrast failures.

Historical verification of the earlier mixed-platform prototype (superseded by the back-office-only revision; these results do not verify the current UI):

- Cashier: Rp52,000 sale from Rp60,000 cash produces Rp8,000 change; insufficient cash is rejected.
- Stock: sale changes coffee 450→432g, milk 1,200→1,020ml, and almond croissant 8→7. A 500ml adjustment succeeds; an adjustment below zero is rejected with a visible error and preserved form.
- Menu: blank name is rejected; editing Flat white to House flat white and price 28,000→29,000 updates the catalog. The prior receipt still shows its original name/price.
- Reports: one sale reconciles to Rp52,000; selecting another date shows an empty result; CSV export downloads successfully.
- Printers: failure leaves the sale intact; simulated connection/test succeeds; the old receipt can be reopened from Reports and printed/reprinted independently.
- Connectivity/error: offline mode disables new checkout; error state offers safe retry.
- Keyboard: Ctrl+K focuses search; Escape closes the variant dialog and restores focus to its product button.
- Layouts: all five screens checked at 320, 1024 and 1440px with no document-level horizontal overflow. Phone layout also inspected at 390px. Screenshots accompany the review package.

Review URL: [Open the interactive prototype](https://arkinara.github.io/modern-pos/prototype.html). GitHub Pages serves the static public repository from main; changes to the prototype publish through its Pages deployment. There are no live business services behind this site.

Still required: owner visual approval (#2), native Flutter behavior/large text verification (#11), full accessibility audit, generated-client/OpenAPI validation in CI (#3), and every production verification listed in #18. The final touch-target refinement is included in the follow-up main commit.

## UI/UX Pro Max refinement 0.2

The live prototype and design tokens now include consistent locally embedded Lucide icons, larger rem-based typography, a less cluttered review header, mobile bottom navigation/order access, keyboard focus retention, browser history and reduced-motion rules. Read [UX_REFINEMENT.md](UX_REFINEMENT.md) for applied skill recommendations and bounded verification evidence. The refinement preserves the existing palette, architecture, demo business rules and pending owner approval. Use the refined [DESIGN_SYSTEM.md](DESIGN_SYSTEM.md) when picking up #5/#11 after that approval.

## Back-office scope verification

Run `node verify-backoffice.cjs` for route/history fallback, all four screen renderers and preview states, sample receipt/report, menu edit, stock adjustment and offline banner regression checks. These use a DOM stub. `node verify-foundation.cjs` checks syntax/contracts/contrast. Current live browser checks remain outstanding because the browser access host was unavailable.
