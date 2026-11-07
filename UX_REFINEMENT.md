# UI/UX Pro Max refinement — 0.2

Scope: refine the existing review prototype and design guidance under #2. Stack remains Flutter + Next.js + NestJS/PostgreSQL; this HTML demo is a static design artifact. The architecture and API contract are unchanged.

## Skill evidence and choices

Used the installed `ui-ux-pro-max` skill, its critical accessibility/touch/performance checklist, and the native app pro-rules. Relevant local searches:

| Search | Relevant result | Applied decision |
| --- | --- | --- |
| `restaurant POS dashboard minimal --design-system --variance 2 --density 6` | Minimalism & Swiss Style, enterprise/dashboard suitability | Keep restrained surfaces, high contrast and a predictable grid. Reject the returned marketing hero/CTA layout and restaurant display serif for an operational checkout tool. |
| `point of sale terminal --domain product` | Digital Signage / Kiosk, touchscreen emphasis | Large touch targets and clear sale controls; do not adopt unrelated fullscreen/landing suggestions. |
| `dashboard readable sans --domain typography` | Dashboard Data and Corporate Trust | Readable system sans and tabular figures; no new network fonts or code-style headings. |
| `mobile bottom navigation --domain ux` | Predictable back behavior and fixed navigation clearance | Preserve navigation history/cart; reserve space for fixed controls. |
| `keyboard focus modal --domain ux` | Visible focus and focus not obscured | Keep native modal handling, restore action focus and offset mobile overlays. |
| `adaptive layout accessibility --stack flutter` | LayoutBuilder, Semantics, screen-reader testing | Document these requirements for the eventual Flutter implementation; don't claim the browser demo proves them. |

The broad design-system output contained marketing recommendations that did not fit the POS task. The narrower product query was the one retry used to verify the touchscreen direction. No generated marketing MASTER was persisted over the existing design system.

## What changed

Official Lucide vectors replace the font-dependent navigation/search/action symbols and product monograms. They are embedded locally with their license. The cashier grid has clearer item names, prices and stock labels. The order panel has a stronger total hierarchy and less repetitive remove-button text. Working typography is larger and uses rem units.

Phone navigation is a labeled bottom bar. The order total stays reachable above it, with an explicit Review order button. Safe-area and content insets keep the two bars from covering the last content. At 200% text, fixed navigation becomes normal flow and the product list becomes one column. Preview controls move into a native disclosure. Browser Back preserves the current demo cart; keyboard focus is restored after quantity changes. Press feedback and reduced-motion handling share tokens.

The new dark-mode requirement is deliberately not claimed: this review candidate is explicitly light-only. Native Dynamic Type/TalkBack/device safe-area checks remain #11. This is a proposed refinement awaiting owner approval, not an implemented Flutter app.

## Verification

Structural/script and contrast checks run through `node verify-foundation.cjs`. Seven core text pairs pass 4.5:1; input/control borders measure 3.62:1 against white. No API/backend behavior changed, and no backend concurrency test is claimed by this UI pass.

Browser verification on the deployed refinement:

- All five screens at 320×812, 375×812, 812×375 landscape, 1024×768 and 1440×1000: no document-level horizontal overflow (25 screen/viewport checks).
- Phone cashier at 200% text: single-column product grid, normal-flow navigation and no horizontal overflow. Native Flutter Dynamic Type/TalkBack remain untested implementation work.
- Increase Flat white quantity: keyboard focus remains on the increase control after rendering.
- Cashier → Menu → Stock → browser Back returns to Menu and preserves the in-memory cart.
- Sale with 2 Flat whites and 1 Almond croissant totals Rp80,000; Rp100,000 cash yields Rp20,000 change; Reports shows the completed amount.
- Phone Review order action focuses the current order and provides an alternative to scrolling through the product list.
- Desktop and phone layouts visually inspected. Final small refinements fix heading levels, singular item labels, large-text logo clearance and disclosure focus dismissal.

Reduced-motion behavior is specified by the CSS media query (no spatial animation; transitions disabled when requested). Runtime OS-level preference switching, native screen readers, a full accessibility audit and dark-mode design are outside this static review pass. The review is explicitly light-only.

## Sources

Skill: https://github.com/nextlevelbuilder/ui-ux-pro-max-skill (installed snapshot b7d5353e0130feb8c5574ef1251f8a1db1873ccb). Icons: https://github.com/lucide-icons/lucide; redistribution notice in [ICONS-LICENSE.txt](ICONS-LICENSE.txt).
