# Modern POS design system

Version: Counter collection 0.3. Scope: the local `prototype.html` design candidate, not an approved production component library. Start here when extending this design. See [DESIGN_REVIEW.md](DESIGN_REVIEW.md) for source requirements and verification limitations.

## 1. Product principles

A calm, fast workspace for everyday sales. Keep menu records scannable and stock/report information readable. Cashier cart and checkout belong exclusively to the Flutter mobile app. Back-office pages prioritize readable records and clear status over decoration.

Use warm neutral surfaces, ink navigation, and terracotta for primary actions. Semantic success, warning, and danger colors communicate status with text. Keep promotional copy out of error messages and financial actions. Use direct labels: “Edit”, “Adjust”, “Save settings”, “Continue to payment”.

## 2. Source of truth and file map

| Source | Responsibility |
| --- | --- |
| `prototype.html`, `<style id="warm-counter-design">` | Current visual overrides, palette, layouts, and action-column fix |
| Earlier inline style blocks | Shared foundations, accessibility, mobile table layout, and 200% text behavior still used by the prototype |
| `iconSet`, `icon()`, `productIcon()` | Inline SVG icons; no remote asset dependency |
| `heading()`, `badge()`, `footer()` | Shared markup |
| `menuScreen()`, `stockScreen()`, `reportsScreen()`, `printerScreen()` | Screen renderers |
| `render()`, document event handlers | Navigation, state rendering, and demo interactions |
| `design-tokens.json` | Portable handoff values and aliases; not loaded by the HTML |

The CSS currently has multiple historical layers. Do not copy only the last style block into a new app: it depends on earlier rules. For production extraction, capture computed component styles, consolidate them, and verify each screen before removing the old layers. Avoid adding another override block for every change; edit the responsible rule in the current design block.

## 3. Color tokens

Values below are the current semantic CSS variables. Prefer these variables over new hardcoded colors.

| Token | Value | Purpose |
| --- | --- | --- |
| `--canvas` | `#F5F3EF` | Page background |
| `--surface` | `#FFFFFF` | Cards, forms, dialogs |
| `--surface-muted` | `#ECE9E3` | Neutral status and tracks |
| `--surface-tint` | `#FAF9F6` | Table headers and order totals |
| `--text` | `#242925` | Primary text |
| `--muted` | `#64685F` | Secondary text on light surfaces |
| `--border` | `#DDDCD4` | Subtle separators and containers |
| `--control-border` | `#8A8C80` | Input boundaries |
| `--accent` | `#A74327` | Primary action, focus, selected control |
| `--accent-hover` | `#87341D` | Primary hover/pressed state |
| `--soft` | `#F7E8DE` | Accent-tinted selection surface |
| `--ink` | `#232E29` | Navigation and lead report metric |
| `--ink-muted` | `#B7C1B9` | Secondary navigation text |
| `--danger` / `--danger-soft` | `#A12D32` / `#FAE9E8` | Errors, unavailable stock |
| `--warning` / `--warning-soft` | `#805510` / `#FBF0D9` | Low-stock warning |
| Success text / background | `#386044` / `#EAF0E7` | Positive badges; currently literal values |
| Selected navigation background / text | `#F4D9B9` / `#302B22` | Current navigation item; currently literal values |

Measured contrast: text on canvas 13.35:1; muted on canvas 5.14:1; white on accent 6.04:1; sidebar text `#C4CEC6` on ink 8.69:1. These are individual pair checks, not a complete accessibility audit. Subtle container borders are not suitable replacements for control borders. This is a light theme with dark navigation, not a full dark-mode implementation.

### Token architecture for implementation

Use three layers: primitive values → semantic roles → component aliases. `design-tokens.json` illustrates this with ordinary brace references such as `{semantic.color.accent}`. It is a project handoff format, not a generator-specific package. Resolve aliases when exporting to CSS, TypeScript, or Dart. Keep the existing HTML names mapped to the same semantic values.

```css
/* Example extraction; not an additional stylesheet required by the prototype. */
--color-terracotta-700: #A74327;
--accent: var(--color-terracotta-700);
--button-primary-background: var(--accent);
```

## 4. Typography, spacing, and shape

Font stack: `Inter, ui-sans-serif, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif`. Inter is not downloaded; the system fallback is expected. Keep prices and quantities tabular with `.num`. Use `rem` for text and scalable minimum button widths. Root size is 16 px multiplied by the review text-scale setting.

| Role | Current sizing at standard text scale |
| --- | --- |
| Page heading | 2.375 rem desktop; 2 rem tablet/mobile; weight 650 |
| Dialog heading | 1.5 rem |
| Section heading | 1–1.125 rem |
| Main body | .9375 rem, line height 1.5 |
| Product title | .9375 rem desktop; .875 rem mobile |
| Table text | .875 rem |
| Table action | .8125 rem; mobile table actions .875 rem |
| Form input | 1 rem |
| Supporting labels | .6875–.8125 rem |
| Eyebrow / category | .625–.6875 rem, uppercase with increased tracking |

Reserve the smallest text for nonessential metadata. Never shrink a button label to fit a narrow column. Longer or translated labels must drive layout changes.

Use a 4 px spacing rhythm for new work: 4, 8, 12, 16, 20, 24, 28, 32, 36, 40. Existing optical exceptions include 7 px product padding and 22 px order padding; preserve them until intentionally normalized. Standard screen padding is 32 × 36 px desktop, 28 × 24 px tablet, 24 × 16 px mobile.

Radii: 5 px badges, 9–10 px small controls, 12 px search/workspace, 14 px cards and panels, 16 px cart, 18 px dialogs. Elevation stays subtle; reserve the strongest shadow and scrim for dialogs.

## 5. Components and states

### Buttons and table actions

| Variant | Default | Hover / pressed | Disabled |
| --- | --- | --- | --- |
| Primary | White text, accent background/border | Accent-hover background | Disabled attribute, reduced opacity, no pointer action |
| Secondary | Text on white, neutral border | Muted surface; pressed accent tint | Same disabled behavior |
| Quiet | Transparent background | Visible hover feedback | Same disabled behavior |
| Table action | Secondary styling, centered label, 48 px minimum height, 5.5 rem minimum width | Same secondary behavior | Same disabled behavior |

Keyboard focus uses a 3 px accent outline offset 3 px. Sidebar focus uses the pale selected-navigation color. Icon-only controls need an accessible name. Minimum actionable target is 44 × 44 px; use 48 px for touch-focused actions. Product-card plus icons are decorative inside the full-card button, not separate targets.

**Table sizing rule — preserve this fix:**

```css
.data-table { table-layout: auto; }
.data-table .action-column {
  width: 1%; /* Request only needed space; automatic table layout honors content. */
  white-space: nowrap;
  overflow-wrap: normal;
}
.table-action {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-inline-size: 5.5rem;
  flex-shrink: 0;
  white-space: nowrap;
  overflow-wrap: normal;
  word-break: normal;
}
@media (max-width: 719px) {
  .data-table .action-column { width: 100%; }
}
```

Apply `action-column` to both the action header and its cells. The old fixed 90/100 px columns left only 42/52 px after horizontal padding and inherited `overflow-wrap:anywhere`, breaking labels. Do not restore those widths, clip labels, or use ellipsis. Table content may wrap; action labels may not. For future multi-action or translated content, allow the column to grow or switch to a stacked row layout.

### Platform ownership

Web navigation contains Menu, Stock, Reports and Printers. Menu uses editable management rows; reports use synthetic mobile-sale fixtures. Legacy cashier links fall back to Menu. No cart, tender, checkout or new-sale control belongs in this web prototype.

Flutter owns catalog browsing, variants, cart, payment entry and completion. Its separate mobile design remains tracked under #2/#11/#12. Shared tokens may support those components without exposing them in the web app.

### Tables, metrics, and status

Use `.panel` with `.panel-head`, semantic table headers, readable item names, and right-aligned action cells. Mobile rows become stacked records; preserve `data-label` text on numeric/detail cells. Status always includes a text label. Do not infer trends or percentages from absent data. Report values come from synthetic mobile-sale fixtures; empty reports explain that mobile sales appear after refresh.

### Forms and dialogs

Visible labels above fields, 48 px minimum input height, and 1 rem input text. Validation errors belong near the form and should focus the invalid field with `aria-invalid` and an associated error message. Dialogs use native `<dialog>`, a named heading, a close control, cancel/back action, and focus restoration. Keep confirmation actions last in reading order. Never remove escape routes.

### Feedback and motion

Use 160 ms for control feedback and 200 ms for standard transitions. Honor `prefers-reduced-motion`; no decorative blocking animations. Toasts dismiss after 4.5 seconds and use a polite live region. Keep important errors visible in the form or persistent status region instead of relying solely on a toast. Loading, empty, error, offline, and disabled states must be designed alongside the normal state.

## 6. Responsive layout

| Width | Behavior |
| --- | --- |
| Up to 719 px | Bottom navigation, single-column catalog/order, two product columns, stacked table records, mobile order shortcut |
| 720–1099 px | Top navigation, two product columns, 320 px order panel |
| 1100–1270 px | 190 px sidebar, two product columns, 310 px order panel |
| 1271–1599 px | 218 px sidebar, three product columns, 346 px order panel |
| 1600 px and wider | 218 px sidebar, three product columns, 380 px order panel; content max width 1600 px |

The order panel sticks on desktop and follows document flow below 1100 px. Mobile navigation and the order shortcut reserve bottom content space and safe-area insets. At 200% text, the prototype simplifies mobile navigation, uses one product column, and hides the floating order shortcut. Verify real browser zoom as well as this simulated text setting. Never introduce page-level horizontal overflow to preserve a desktop composition.

## 7. Implementation boundaries

The target repository describes Next.js/React/TypeScript with Tailwind and shadcn/ui for the web back office, and Flutter/Dart for Android cashier. Map these tokens and states into those platforms; do not migrate the static HTML to a framework as part of a styling fix.

Suggested component boundaries: app shell, navigation item, page heading, status badge, action button, data table, product card, order line, order summary, labeled field, dialog, and receipt. Use semantic roles rather than product-specific colors in those components. Preserve one action implementation for Menu and Stock to prevent sizing divergence.

The demo stores everything in memory and resets on reload. It does not implement authorization, persistence, real payment processing, printer transport, or offline sales. Production sale calculation and stock deduction must remain server-authoritative and atomic. A print failure must not repeat sale recording. Manual external payment means recorded only, not provider-verified. Keep synthetic/demo messaging until real integrations exist.

## 8. Acceptance checklist for future changes

- Inspect Cashier, Menu, Stock, Reports, and Printers at 375, 768, 1024, and 1440 px; include 200% text and browser zoom.
- Confirm “Edit”, “Adjust”, and longer action labels stay readable, centered, and unbroken; inspect row boundaries for overlap.
- Navigate by keyboard, open/cancel dialogs, verify focus return, and inspect disabled controls.
- Exercise menu editing, stock adjustment, sample receipt, report/date filtering, and simulated printer failure.
- Check loading/empty/error/offline states and legacy cashier-link fallback to Menu.
- Check contrast, reduced motion, touch targets, long names, and localized labels.
- Keep design changes separate from financial behavior; run relevant regression checks after logic changes.

Browser visual verification is still outstanding in this environment. Existing Node VM smoke checks use a DOM stub and cannot prove layout or accessibility-tree behavior. Do not report screenshot or browser verification until performed.

### Repository compatibility

The token file retains top-level `color`, `font`, `spacing`, `radius`, `control`, `layout`, `motion`, and `icons` fields for existing consumers, including `verify-foundation.cjs`. The new primitive/semantic/component groups coexist with that compatibility view. Update both views together when changing shared values. Lucide attribution remains in [ICONS-LICENSE.txt](ICONS-LICENSE.txt). Production web navigation excludes the cashier review surface; cashier functionality belongs to Flutter. Preview controls are development-only.
