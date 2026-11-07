# Web back office (Next.js)

Next.js App Router shell for the owner back office. Navigation placeholders are Menu, Stock,
Reports and Printers. This app does not own sale, tender, cart or receipt flows; the Flutter
Android app is the cashier surface.

## Design contract

`app/globals.css` maps the root `design-tokens.json` palette, radii, focus ring, spacing tokens
and motion preferences into CSS variables and Tailwind theme tokens. Components use semantic
utilities such as `bg-surface`, `text-muted` and `border-border`; raw palette values stay in the
token definition block. Loading, error and empty states are present in the API status badge and
page placeholders.

Owner visual approval (#2) is still pending. Do not treat this shell as final visual approval.

## API access

`lib/api.ts` builds the typed client from `@modern-pos/api-client`, which is generated from the
root OpenAPI document. `NEXT_PUBLIC_API_URL` defaults to `http://localhost:4000`.

## Commands

```bash
cp .env.example .env.local   # only when overriding the default
pnpm --filter @modern-pos/web typecheck
pnpm --filter @modern-pos/web build
pnpm --filter @modern-pos/web dev        # port 3000
pnpm --filter @modern-pos/web dev:3001   # port 3001 when 3000 is busy
```

The `dev:3001` and `PORT` overrides keep local smoke tests working on hosts where `3000` is taken.
