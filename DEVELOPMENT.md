# Development guide

This repository now contains the Phase 1 scaffold alongside the M01/M02 design package.
The product and architecture documents remain the source of truth for later tickets.

## Repository layout

```text
apps/web/       Next.js App Router back office shell
apps/api/       NestJS API with Prisma and PostgreSQL
apps/mobile/    Flutter Android cashier shell
packages/api-client/       Generated TypeScript contract types + typed fetch wrapper
packages/api_client_dart/  Generated Dart client package
tools/          OpenAPI generator config and host setup helpers
```

`apps/api` and `apps/web` are pnpm workspace packages. Flutter uses its own pub tooling in
`apps/mobile` and consumes `packages/api_client_dart` through a path dependency.

## Toolchain versions

| Tool | Version used here |
| --- | --- |
| Node.js | 22.23.1 |
| pnpm | 9.12.3 |
| TypeScript | 5.9.3 |
| Next.js | 16.4.5 |
| React | 19.3.1 |
| NestJS | 12.4.0 |
| Prisma | 6.19.3 |
| PostgreSQL image | 17.6-alpine |
| Flutter | 3.47.0 |
| Dart | 3.13.0 |
| OpenJDK | 17 |
| OpenAPI Generator | 7.27.0 (pinned in `openapitools.json`) |

Environment overrides used for local Android commands:

```bash
export ANDROID_HOME=/home/ubuntu/android-sdk
export ANDROID_SDK_ROOT=/home/ubuntu/android-sdk
```

## Environment variables

| Variable | Where | Local default |
| --- | --- | --- |
| `DATABASE_URL` | `apps/api/.env` | `postgresql://pos:pos_local_dev@localhost:5432/modern_pos?schema=public` |
| `PORT` | API process | `4000` |
| `WEB_ORIGIN` | API CORS allowlist | `http://localhost:3000,http://localhost:3001` |
| `NEXT_PUBLIC_API_URL` | `apps/web/.env.local` | `http://localhost:4000` |
| `API_BASE_URL` | Flutter `--dart-define` | `http://10.0.2.2:4000` on the Android emulator |
| `JWT_SECRET` | API process | local-development placeholder in `.env.example` |
| `ACCESS_TOKEN_TTL_SECONDS` | API process | `600` |
| `REFRESH_TOKEN_TTL_SECONDS` | API process | `604800` (7 days, absolute) |
| `COOKIE_SECURE` | API process | `false` locally; must be `true` behind HTTPS |
| `SIGN_IN_MAX_ATTEMPTS` | API process | `5` failures per IP + email |
| `SIGN_IN_WINDOW_SECONDS` | API process | `900` |
| `SEED_PASSWORD` | API seed | synthetic demo password only |

Copy the examples before running locally:

```bash
cp apps/api/.env.example apps/api/.env
cp apps/web/.env.example apps/web/.env.local
```

`.env` and `.env.local` are git-ignored. The committed examples contain local-only values and
no real credentials.

Ports: web `3000` by default (`pnpm dev:web`, or `pnpm --filter @modern-pos/web dev:3001` when
`3000` is busy), API `4000`, PostgreSQL `5432`.

## Clean-clone quickstart

```bash
pnpm install --frozen-lockfile
docker compose up -d

cp apps/api/.env.example apps/api/.env
pnpm --filter @modern-pos/api prisma:generate
pnpm --filter @modern-pos/api exec prisma migrate deploy
pnpm --filter @modern-pos/api seed

pnpm dev:api
# in a second shell
pnpm dev:web
```

Verify the API and database:

```bash
curl -fsS http://localhost:4000/health
# {"status":"ok","service":"modern-pos-api","version":"0.1.0","database":"up"}
```

Stop local services with `docker compose down`. Add `-v` only when you intentionally want to
delete the database volume.

## Database workflow

Prisma schema: `apps/api/prisma/schema.prisma`. Ticket #4 adds credential fields, outlet
settings required by the contract, and the `Session` model. Domain tables arrive in #6-#10.

```bash
# Create/apply a development migration
pnpm --filter @modern-pos/api exec prisma migrate dev --name <name>

# Apply committed migrations (CI, clean clone)
pnpm --filter @modern-pos/api exec prisma migrate deploy

# Repeatable synthetic seed; safe to run multiple times
pnpm --filter @modern-pos/api seed
```

The seed uses fixed UUIDs and upserts. It creates two synthetic businesses, three outlets, and
one owner plus one cashier for every outlet (six users). It contains no production data. All
seeded users share `SEED_PASSWORD`, which defaults to a synthetic local value.

Seeded accounts:

| Email | Role | Outlet |
| --- | --- | --- |
| `owner@example.test` | OWNER | Main Outlet |
| `cashier@example.test` | CASHIER | Main Outlet |
| `owner.second@example.test` | OWNER | Second Outlet |
| `cashier.second@example.test` | CASHIER | Second Outlet |
| `owner.other@example.test` | OWNER | Other Tenant Outlet |
| `cashier.other@example.test` | CASHIER | Other Tenant Outlet |

Main Outlet and Second Outlet share a business; Other Tenant Outlet belongs to a second business
so cross-tenant isolation can be tested locally.

## Build, type and test commands

```bash
pnpm format:check
pnpm typecheck
pnpm test
pnpm --filter @modern-pos/api build
pnpm --filter @modern-pos/web build
```

Flutter:

```bash
cd apps/mobile
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
```

## OpenAPI contract workflow

The root `API.openapi.json` (v0.2.0) remains the contract. Generated clients are committed so a
clean clone builds without regenerating first.

```bash
pnpm openapi:validate              # swagger-cli meta validation
pnpm openapi:generate              # regenerate TypeScript types and the Dart client
pnpm openapi:check                 # validate + regenerate + fail on drift + analyze Dart
```

- TypeScript: `packages/api-client/src/schema.d.ts` generated with `openapi-typescript`.
  `src/index.ts` is a small typed fetch wrapper; web imports it through `@modern-pos/api-client`.
- Dart: `packages/api_client_dart` generated with OpenAPI Generator `dart`
  (config in `tools/openapi-dart-config.json`). The mobile app depends on it by path.
- Drift gate: CI regenerates both clients and runs `git diff --exit-code` over them. Commit any
  intentional regeneration together with the contract change.

## Android build note for arm64 hosts

Google's Linux Android SDK binaries are x86-64. This development host is arm64, so the SDK
tools need user-mode emulation. CI uses an x86-64 runner and does not need this setup.
On an arm64 host, run the helper once before the first Android build:

```bash
bash tools/setup-arm64-android-sdk.sh
```

The script is a no-op on x86-64. It installs `qemu-user` plus x86-64 cross libraries and wires
the minimal library paths and `zlib` needed by `aapt2`, `cmake` and the NDK. It requires sudo
and changes only the host, not the repository.

## Continuous integration

`.github/workflows/ci.yml` runs formatting, TypeScript checks, health and authentication unit
tests, the NestJS build, Prisma migrations and the seed twice, a live API health check, the
Next.js production build, OpenAPI validation, client generation and drift comparison, Dart
analyze, Flutter analyze/test, and an Android debug APK build. Every command is also listed
above for local reproduction.

## Authentication and authorization (#4)

Implementation lives in `apps/api/src/auth` and `apps/api/src/common/guards`.

- Password hashes use Argon2id. Unknown accounts still perform a dummy Argon2id verification so
  sign-in timing does not reveal whether an email exists.
- Access tokens are Passport JWTs valid for 10 minutes (configurable). Every protected request
  reloads the session and user from PostgreSQL, so sign-out, refresh rotation, password changes
  and role changes revoke access immediately rather than waiting for JWT expiry.
- Refresh tokens are opaque random values stored only as SHA-256 hashes. Rotation is atomic and
  single-use. Replaying a rotated or revoked token revokes the whole session family.
- Session lifetime is absolute: rotated sessions inherit the original seven-day expiry.
- Web login sets `pos_refresh` as an HttpOnly, SameSite=Lax cookie (path `/v1/auth`) and
  `pos_csrf` as a readable double-submit cookie. Web refresh requires `X-CSRF-Token` to match both
  the CSRF cookie and the session record. The access token is kept in browser memory.
- Flutter keeps the refresh token in platform secure storage and the access token in memory.
  Refresh rotates the stored token; a 401 clears local credentials and returns to sign-in.
- Sign-in is rate limited in-process per client IP + normalized email. After
  `SIGN_IN_MAX_ATTEMPTS` failures in `SIGN_IN_WINDOW_SECONDS`, the API returns `429 RATE_LIMITED`
  with a retry hint. A successful sign-in resets the counter. This limiter is deliberately
  bounded to 10,000 keys and resets on restart; a shared store is required before running
  multiple API replicas.
- Every request is authorized server-side by global guards. Missing/invalid sessions return 401,
  insufficient roles return 403, and out-of-scope outlet IDs return **404** so another tenant
  cannot probe for record existence. Owner identities are limited to their business's outlets;
  cashiers are limited to their assigned outlet.
- `GET /v1/outlets/:outletId`, `PATCH /v1/outlets/:outletId` (owner-only), and the six auth
  endpoints are implemented. Other operations in the OpenAPI contract remain later-ticket work.

Auth endpoints: `POST /v1/auth/mobile/login`, `POST /v1/auth/mobile/refresh`,
`POST /v1/auth/web/login`, `POST /v1/auth/web/refresh`, `POST /v1/auth/logout`,
`GET /v1/auth/me`.

## Business settings and back-office shell (#5)

Implementation lives in `apps/api/src/settings` and the web back-office route group.

- `GET /v1/outlets/:outletId/settings` reads the business name plus outlet receipt identity,
  currency, timezone and tax/service basis points under the authenticated outlet scope.
- `PATCH /v1/outlets/:outletId/settings` is owner-only. It validates the payload, checks the
  supplied `version`, updates the outlet and business name in one transaction, and returns the
  authoritative record. A stale version returns `409 VERSION_CONFLICT`.
- The server validates timezones as IANA identifiers and owns the minor-unit exponent for the
  selected currency. The web form never calculates sale totals or tax amounts.
- Migration `20261107190000_business_settings` adds receipt header/footer text to outlets. The
  seed sets synthetic defaults and remains re-runnable.
- Web navigation is Menu, Stock, Sales, Reports, Printers and Settings. Sales/Reports are
  read-only scaffolds for mobile-originated records; catalog, stock and reporting depth remain
  deferred to #6, #7 and #14. Printer discovery and physical printing remain deferred to
  #15/#16. Unknown URLs show a not-found page that links back to Menu.

Known M04 limits: no registration/self-signup, OAuth/SSO, MFA, password-reset email, or
multi-outlet UI. There is no public password or role mutation endpoint; when administrative
password/role changes are added, they must call `AuthService.revokeAllSessionsForUser` (or
`SessionService.revokeAllForUser`) in the same operation. Error payloads follow
`{code,message,requestId,retryable}`; request IDs are echoed in `X-Request-Id`.

## Scope boundaries

- Web is the owner back office. It has no sale, tender or cart routes; the Android app owns
  cashier flows.
- Catalog, recipe, stock-ledger and sale transaction rules are server-owned and arrive in
  #6-#10.
- Printer discovery and physical Android printing remain with #15/#16.
- All data in this scaffold is synthetic.
