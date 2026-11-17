# Browser regressions in CI

The web back-office browser suite lives in `apps/web/scripts/browser-regressions.cjs`
with synthetic fixtures in `apps/web/scripts/fixtures/browser-regressions.json`.
It runs on every push and pull request through `.github/workflows/ci.yml`.

## Coverage

The suite uses the seeded owner and cashier sessions from
`apps/api/prisma/seed.ts` and covers:

- Owner navigation exposes all 15 grouped destinations; cashier navigation
  exposes only the seven permitted routes; every route keeps an
  `aria-current="page"` active state.
- Cashier direct `/reports` renders the owner-only state with zero
  `/reports/daily` requests; owner report figures and CSV download work.
- Printer empty, populated and error states use explicit copy. Populated
  metadata is name, model, transport, paper width and encoding only; the suite
  asserts no physical-connectivity claim and that connection settings are not
  rendered.
- Cashier stock cards expose no movement-history action; owner history opens the
  append-only ledger; a forced stock-history 403 uses the read-action copy.
- Sale reference search sends `reference`, `from`, `to` and the outlet path to
  the API, shows the no-match state for an unknown reference, and clearing
  restores the date-filtered list.
- Keyboard focus, touch-target height, contrast and horizontal overflow are
  checked at 320 px and desktop.

## Local run

Start PostgreSQL, apply migrations and seed the synthetic data, build and start
the API and web app, then run the suite:

```bash
docker compose up -d postgres
pnpm install --frozen-lockfile
pnpm --filter @modern-pos/api prisma:generate
pnpm --filter @modern-pos/api exec prisma migrate deploy
pnpm --filter @modern-pos/api seed
pnpm --filter @modern-pos/api build
pnpm --filter @modern-pos/web build

(cd apps/api && node dist/main.js > /tmp/api.log 2>&1 &)
pnpm --filter @modern-pos/web exec next start -p 3001 > /tmp/web.log 2>&1 &

curl -fsS --retry 20 --retry-delay 1 --retry-connrefused http://localhost:4000/health
curl -fsS --retry 20 --retry-delay 1 --retry-connrefused http://localhost:3001/login
pnpm --filter @modern-pos/web test:browser
```

The suite defaults to `WEB_BASE_URL=http://localhost:3001` and
`API_BASE_URL=http://localhost:4000`. Override those variables when the app is
served elsewhere. `pnpm --filter @modern-pos/web test:browser:install` installs
the pinned Chromium build used locally and in CI.

The printer fixture is created through the authenticated API during the run, so
the suite works on a freshly seeded database and does not depend on `/tmp`
scripts or manual staging data. Reusing the same database is safe: the setup
checks for the fixture printer before creating it.
