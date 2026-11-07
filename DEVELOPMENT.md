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

Prisma schema: `apps/api/prisma/schema.prisma`. Ticket #3 keeps only the plumbing models
(`Business`, `Outlet`, `User`); domain tables arrive in #6-#10.

```bash
# Create/apply a development migration
pnpm --filter @modern-pos/api exec prisma migrate dev --name <name>

# Apply committed migrations (CI, clean clone)
pnpm --filter @modern-pos/api exec prisma migrate deploy

# Repeatable synthetic seed; safe to run multiple times
pnpm --filter @modern-pos/api seed
```

The seed uses fixed UUIDs and upserts. It creates one synthetic business, one outlet, one owner
and one cashier. It contains no production data.

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

The root `API.openapi.json` (v0.1.0) remains the contract. Generated clients are committed so a
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

`.github/workflows/ci.yml` runs formatting, TypeScript checks, the NestJS build and health test,
Prisma migrations and the seed twice, the Next.js production build, OpenAPI validation,
client generation and drift comparison, Dart analyze, Flutter analyze/test, and an Android debug
APK build. Every command is also listed above for local reproduction.

## Scope boundaries

- No authentication is implemented yet; #4 adds JWT/session behavior and outlet isolation.
- Web is the owner back office. It has no sale, tender or cart routes; the Android app owns
  cashier flows.
- Catalog, recipe, stock-ledger and sale transaction rules are server-owned and arrive in
  #6-#10.
- Printer discovery and physical Android printing remain with #15/#16.
- All data in this scaffold is synthetic.
