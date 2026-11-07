# Modern POS design system — M02

Status: proposed visual direction, ready for owner review. The reference implementation is [prototype.html](prototype.html); machine-readable primitives are [design-tokens.json](design-tokens.json). These artifacts specify appearance/interaction, not a production Flutter or Next.js implementation.

## Direction: quiet precision

Warm off-white canvas, white working surfaces, deep teal actions, charcoal text, restrained borders and generous whitespace. A POS should feel quick and legible. Use typography and alignment for hierarchy; reserve shadows for overlays and focused work. No gradients, decorative dashboards or excessive floating cards. Operational statuses use words and icons as well as color.

The name Modern POS is provisional. Prototype data is synthetic. Default copy is English with IDR sample money and Asia/Jakarta sample reporting timezone; actual business currency, timezone and language remain configurable.

## Tokens

| Token | Value | Use |
| --- | --- | --- |
| canvas | #F5F6F3 | App background |
| surface | #FFFFFF | Main work areas |
| surface-muted | #EEF1EC | Table header / secondary fill |
| text | #172B28 | Primary copy |
| text-muted | #536660 | Secondary copy; never disabled essential data |
| border | #D8E0DA | Boundaries |
| accent | #145C4F | Primary actions/active navigation |
| accent-hover | #0E493F | Hover/pressed |
| accent-soft | #E3F0E8 | Selected items |
| danger | #A63232 | Destructive text and errors |
| danger-soft | #FBEDEC | Error background |
| warning | #805711 | Low-stock text |
| warning-soft | #FFF3D6 | Low-stock background |
| focus | #145C4F | 3px outline + 3px offset |

Typography: system sans stack (`Inter` if bundled later, otherwise platform UI sans); no network font dependency in prototype. Web sizes: 12 caption, 14 table/body, 16 input, 20 section, 28 page heading, 36 key total. Flutter uses system font with matching semantic scale and platform text scaling. Body line-height 1.5; headings 1.15–1.3. Tabular numerals for prices, quantities and report totals.

Spacing: 4, 8, 12, 16, 24, 32, 48 px. Radius: 8 fields/buttons, 12 surfaces, 16 large panels, pill only for badges/chips. Border: 1px. Shadow: dialog only, 0 20px 70px rgba(23,43,40,.18). Touch controls minimum 48px height; web compact table actions at least 40px. Use 48px targets on coarse pointers.

## Layout and navigation

Desktop back office >=1100px: 224px side navigation, fluid workspace, 32px padding, tables aligned to the same grid. Tablet 720–1099px: horizontally wrapped navigation, 24px padding, two-column editor where it fits. Phone <720px: header/navigation wraps, 16px padding, single-column forms and stacked rows with all key facts/actions retained. Data tables can scroll only if column semantics require it; no document-level horizontal overflow.

Cashier expanded >=1100px: product grid + 360px order panel. Tablet 720–1099px: two-column product grid + 320px order panel. Phone <720px: products above order summary, checkout uses a nearly full-width dialog. Native Flutter implementation should translate the phone pattern into an accessible bottom cart sheet or full screen when useful; it must preserve these actions and calculation states. Android tablet target 1024×768 logical px; phone 390×844. Validate 320px width and 200% text scaling, not just a screenshot at one size.

Navigation in prototype includes Cashier as a review surface alongside Menu, Stock, Reports and Printers. Production web sidebar excludes Cashier; cashier flows belong to Flutter. Visible “Web back office” and “Flutter cashier” context labels prevent confusion.

## Components and states

| Component | Specification |
| --- | --- |
| Primary button | Deep teal, white text, verb label; one main action per local task; pending label and disabled during request |
| Secondary button | White surface, border, dark text; no competing accent |
| Destructive action | Danger text, explicit object in label, reason/confirmation when consequential |
| Field | Visible label, optional hint, 48px input, inline error and aria-invalid; never placeholder-only |
| Badge | Text label: Available, Low stock, Out of stock, Queued, Failed, Unknown; color adds meaning |
| Product tile | Category/name/variant/price/stock visible; focusable action, unavailable disabled with reason |
| Table/list | Quiet headers, separators, right-aligned quantities/money; row actions labeled |
| Metric | Label, value, period/definition; financial terms match architecture definitions |
| Dialog | Native modal semantics, focus inside, Escape cancel unless submitting, return focus to opener; no irreversible action on dismiss |
| Notification | role=status for success; role=alert for errors; don't remove data or move focus unexpectedly |
| Empty state | What is empty + next relevant action; distinguish no data from failed load |
| Loading | Short text/skeleton preserves layout; disable repeat mutation, don't show fake zero balances |
| Error | Human cause, safe next action, retry where supported; no API internals in product copy |
| Offline | Persistent labeled state; browsing demo may continue but checkout is blocked; preserve cart |

All core screens support loading, empty and error previews through prototype “Screen state”. That control is review-only and must not appear in the production UI. “Connection” is a prototype network simulator. Print test and failure controls are explicitly simulated; no physical device is contacted.

## Accessibility and input

Use semantic headings, navigation landmarks, native buttons/inputs/dialogs, a skip link, visible focus and labels. Each field error is associated with its input. Selected navigation uses aria-current. Cashier buttons include item and action names; quantity controls include the item name. Status is never color-only. Prototype uses polite live feedback and error alerts. Web keyboard: Tab/Shift+Tab traverse; Enter submits focused form; Escape closes dialog; Ctrl/Cmd+K focuses menu search only on screens with search. Preserve standard browser shortcuts elsewhere.

Contrast target is WCAG AA (4.5:1 normal text, 3:1 large text); focus and important control boundaries are explicitly visible. Verify foreground/background pairs programmatically and inspect focus and resizing. Minimum targets here intentionally exceed [WCAG 2.2 minimum target guidance](https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum.html). No animations are required; respect reduced-motion if added later.

## Core flow specifications

1. **Menu editor**: Menu → Edit item → name/category/variant/price/stock policy → validate → Save. Preserve unsaved values on validation failure. Tracked items show linked ingredients; recipe authoring is #8. Blank name, negative/invalid price or unsupported stock configuration block save. Editing an item's price doesn't change historical sales.
2. **Stock adjustment**: Stock → Adjust → item/current balance/base unit → increase/decrease quantity → reason → preview new balance → Apply. Nonzero quantity and reason required; no negative resulting balance. Display adjustment and linked menu availability immediately in demo. Production refreshes authoritative balances.
3. **Cashier cart**: choose category/search → select product → choose variant if applicable → add → change/remove quantity. Cart shows real item amounts and clear total. Out-of-stock item cannot be added. Re-evaluate whole-cart shared ingredient demand; displayed availability is advisory.
4. **Checkout**: Review total → cash/manual external method → tender/reference → confirm recorded sale → receipt. Connection loss blocks new completion. Pending or unknown result preserves key/cart and offers recovery; don't create a new sale. Prototype simulates success only and does not implement real idempotency or authorization.
5. **Reports**: select local date period → view sales/net item sales/reversals/payment breakdown/top items → CSV. Prototype report is current-session synthetic data; date scope is shown and export matches it. Empty report is distinct from load error. No margin/profit metric without costing rules.
6. **Printer setup**: name/model/transport/paper width → save → test → ready/failure. Print committed receipt separately; failed/unknown delivery offers explicit COPY reprint. Prototype supports simulated connection/test/reprint only; release depends on #15 real hardware verification.

## Review and developer handoff

Owner should assess palette, density, typography, desktop navigation, phone stacking, product tiles and checkout clarity. #2 remains open/in QA pending that review; visual style is proposed, not approved. Backend work under #3/#4/#6/#7 can proceed from #1. Don't implement extra features from the prototype control panel.

Implementation traceability: #5 web shell, #6 menu editor, #8 recipe UI, #11/#12 Flutter cashier/checkout, #13 stock, #14 reports, #15/#16 printer setup/queue. Implement these using tokens, not a direct copy of the prototype's plain-JS rendering. See [HANDOFF.md](HANDOFF.md) for the next steps and evidence.
