# Web back office (Next.js)

Next.js App Router shell for the owner back office. The delivered navigation is Menu, Stock,
Sales, Reports, Printers and Settings. This app does not own cashier, cart, tender or sale
completion flows; the Flutter Android app is the cashier surface.

## Delivered in ticket #5

- Responsive back-office shell with a selected navigation state, keyboard-accessible links and
  a document that does not scroll horizontally from 320 px to 1440 px.
- Default landing redirects `/` to `/menu`. Unknown direct URLs show a not-found page that links
  back to Menu.
- Sales is a read-only scaffold for mobile-originated records. Reports is a read-only empty state
  for mobile-originated reconciliation. Neither screen offers a web sale action.
- Printers shows receipt identity and a read-only printer status. Device discovery, pairing,
  runtime permissions and physical printing remain on Android (#15/#16).
- Settings edits business name, receipt header/footer/address, currency, IANA timezone and
  tax/service rates. The form uses React Hook Form + Zod for field feedback and lets the API
  reject invalid values. The server owns the authoritative record, minor-unit exponent and every
  financial rule.
- Loading, empty and failure states are present on every screen. Failed settings or printer
  requests keep the current form values and offer an explicit retry; version conflicts offer a
  reload action instead of silently overwriting another edit.

## Deferred

- Menu catalog and variants CRUD (#6), stock ledger (#7).
- Sales history/reporting depth, filters and CSV export (#14).
- Multi-outlet management UI, roles/permissions UI and owner visual approval (#2).
- Android printer discovery, pairing and physical printing (#15/#16).

## Authentication (#4)

`/login` is the only public page. Protected routes live in the `app/(backoffice)` route group and
are wrapped by `AuthGate`, which restores the session, redirects unauthenticated visitors to
`/login`, and holds the access token in memory only. The API owns the HttpOnly `pos_refresh`
cookie and the readable `pos_csrf` double-submit cookie; Next.js never stores or decodes the
refresh token. Sign-out revokes server-side, clears the shell and rotates once if the access
token has already expired so the cookie cannot restore the session. All authorization and
financial rules remain server-side.

## Settings API

The web client calls `GET /v1/outlets/:outletId/settings` and
`PATCH /v1/outlets/:outletId/settings`. Reads use the authenticated outlet scope. Mutations are
owner-only on the server and accept a `version` for optimistic concurrency. A stale version
returns `409 VERSION_CONFLICT`; the form keeps the user's edits visible and offers a reload.

The single-outlet MVP uses the first outlet ID from the authenticated session. The outlet ID is
carried explicitly through the API and hooks so a later outlet switcher can replace
`lib/use-active-outlet.ts` without moving financial logic into the browser.

## Design contract

`app/globals.css` maps the root `design-tokens.json` palette, radii, focus ring, spacing tokens
and motion preferences into CSS variables and Tailwind theme tokens. Components use semantic
utilities such as `bg-surface`, `text-muted` and `border-border`; raw palette values stay in the
token definition block. Loading, error and empty states are present in the API status badge,
settings screen, printers screen and page placeholders.

Owner visual approval (#2) is still pending. Do not treat this shell as final visual approval.

## Known limitations

- No outlet switcher; the MVP uses the first outlet in the session.
- Sales and reports do not call a data API yet because the read endpoints land in #14.
- Prisma migration `20261107190000_business_settings` adds receipt header/footer fields. The
  business name lives on the business record and is updated in the same settings transaction.
- The sample seed restores synthetic settings values on every run.

## API access

`lib/api.ts` builds the typed client from `@modern-pos/api-client`, which is generated from the
root OpenAPI document. `NEXT_PUBLIC_API_URL` defaults to `http://localhost:4000`.

## Commands

```bash
cp .env.example .env.local   # only when overriding the default
pnpm --filter @modern-pos/web typecheck
pnpm --filter @modern-pos/web build
pnpm --filter @modern-pos/web verify:shell
pnpm --filter @modern-pos/web dev        # port 3000
pnpm --filter @modern-pos/web dev:3001   # port 3001 when 3000 is busy
```

`verify:shell` is a source-level check for landing behavior, route presence, selected navigation
state, internal overflow containers, retry states and the cashier-flow text boundary. It is not a
browser layout engine, so it does not replace a screenshot or real-browser overflow pass; no
screenshot was captured in this environment.

The `dev:3001` and `PORT` overrides keep local smoke tests working on hosts where `3000` is taken.
