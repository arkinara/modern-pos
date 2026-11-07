# Modern POS — counter collection

The `prototype.html` revamp uses the UI/UX Pro Max workflow, adapted to the project's M02 brief: neutral surfaces, a single action accent, readable business information, accessible controls, and compact/expanded layouts.

Developer handoff: [Design system](DESIGN_SYSTEM.md) · [Portable tokens](design-tokens.json).

## Visual direction

- Ink navigation (`#232E29`), warm ivory canvas (`#F5F3EF`), white surfaces, terracotta action accent (`#A74327`).
- Native sans-serif typography, tabular prices, clear heading hierarchy, and consistent inline SVG icons.
- Product illustrations in menu management and readable stock/report tables.
- Shared table, metric, form, dialog, receipt, and status styling across Menu, Stock, Reports, and Printers.
- Desktop side navigation, tablet top navigation, and mobile bottom navigation.
- Visible keyboard focus, touch controls, reduced-motion support, and the existing 200% text preview.
- No added runtime dependencies, remote fonts, or external image requests. Open the HTML file directly.

The skill's initial recommendation was too marketing-oriented for a POS. Its warm neutral palette and interaction guidance were adapted using its data-dense dashboard recommendations and the repository's explicit product requirements.

## Scope and source requirements

Reviewed [README](https://github.com/arkinara/modern-pos/blob/main/README.md) and [BACKLOG](https://github.com/arkinara/modern-pos/blob/main/BACKLOG.md), particularly M02 and the cashier, stock, report, and printer flows. All 30 items on [project 19](https://github.com/users/arkinara/projects/19) were reviewed via GitHub CLI on 7 November 2026. #1 is complete, #2 remains In QA, and #3 is the next implementation step.

This remains a synthetic, session-only design prototype. Reload resets edits. Reports use a synthetic mobile-sale fixture. Cashier/cart/checkout are absent from the web prototype and belong to Flutter. Printing controls remain simulations. The design package is prepared for publication to the repository; this does not implement or launch production POS services.

## Verification

Passed `node verify-foundation.cjs` and `node verify-backoffice.cjs`: script syntax, four back-office screens and states, invalid/legacy cashier route fallback, sample receipt/report, menu editing, stock adjustment and offline banner. Checkout handlers and order controls have been removed.

Measured primary color-pair contrast: body text 13.35:1, muted text 5.14:1, primary action 6.04:1, sidebar text 8.69:1.

Live browser visual and interaction verification remains outstanding: the browser access host was unavailable and the sandbox denied local HTTP server binding. The smoke check uses a DOM stub and does not verify browser layout, focus behavior, or accessibility-tree behavior. Responsive styles are implemented but have not been screenshot-verified.

## Action-label fix

Menu and Stock now use content-sized action columns, non-wrapping labels, 5.5 rem minimum button widths, and 48 px minimum heights. This replaces the fixed 90/100 px columns that squeezed labels after cell padding. Mobile action cells remain full-width stacked records. Static rule checks and the existing JavaScript smoke checks pass; browser layout confirmation remains outstanding.
