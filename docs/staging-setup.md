# Staging setup

Status: single-VPS staging procedure verified on 2026-11-10 with synthetic data.
This is not a production deployment procedure.

## What "staging" means here

"Staging" in this repository means one Linux VPS running:

- PostgreSQL 17.6 in Docker from `docker-compose.yml`;
- the NestJS API as a host process on port 4000;
- the Next.js back office as a host process on port 3001.

`docker-compose.yml` currently defines only PostgreSQL. The API and web app are not
container images in this repository. A production deployment still requires at least:

- managed or backed-up PostgreSQL outside the application host;
- a TLS-terminating reverse proxy and DNS;
- a secret manager instead of a checked-in `.env`;
- process supervision, log shipping, metrics and alerting;
- automated off-host backups with tested restore;
- a release process, rollback plan and separate explicit production go-live decision.

Do not describe this single-VPS setup as production-ready.

## Requirements

| Requirement | Verified value on this VPS |
| --- | --- |
| OS | Ubuntu 24.04, Linux arm64 |
| Node.js | 22.23.1 |
| pnpm | 9.12.3 |
| Docker | 29.1.3 |
| Docker Compose | v2.40.3 |
| Free disk | at least 3 GB (build cache and Docker volume) |
| Ports | 5432 PostgreSQL, 4000 API, 3001 web |

Android builds additionally need the toolchain in `docs/android-build.md`.

## First bring-up

From the repository root:

```bash
docker compose up -d postgres
pnpm install --frozen-lockfile
cp apps/api/.env.example apps/api/.env
# Edit apps/api/.env with local-only placeholder values. Never commit the file.
pnpm --filter @modern-pos/api prisma:generate
pnpm --filter @modern-pos/api migrate:deploy
pnpm --filter @modern-pos/api seed
pnpm --filter @modern-pos/api seed   # idempotent; proves the seed can run twice
```

Build and start the API:

```bash
pnpm --filter @modern-pos/api build
cd apps/api
node dist/main.js
```

Build and start the web app in a second shell:

```bash
pnpm --filter @modern-pos/web build
cd apps/web
pnpm exec next start -p 3001
```

The web app reads `NEXT_PUBLIC_API_URL` at build time. Set it before `pnpm build:web`
when the API is not on `http://localhost:4000`.

## Environment variables

Use placeholders in documentation and a secret manager in production. Do not commit
real values.

| Name | Purpose | Example placeholder |
| --- | --- | --- |
| `DATABASE_URL` | Prisma PostgreSQL connection string | `postgresql://pos:<db-password>@localhost:5432/modern_pos?schema=public` |
| `PORT` | NestJS API port | `4000` |
| `WEB_ORIGIN` | Comma-separated CORS origins | `http://localhost:3001` |
| `JWT_SECRET` | HMAC secret for access tokens | `<random-32-byte-secret>` |
| `JWT_ISSUER` | JWT issuer claim | `modern-pos-api` |
| `ACCESS_TOKEN_TTL_SECONDS` | Access-token lifetime | `600` |
| `REFRESH_TOKEN_TTL_SECONDS` | Refresh-token lifetime | `604800` |
| `COOKIE_SECURE` | Send web refresh cookie only over HTTPS | `true` behind TLS; `false` for local HTTP |
| `SIGN_IN_MAX_ATTEMPTS` | Failed sign-in threshold | `5` |
| `SIGN_IN_WINDOW_SECONDS` | Rate-limit window | `900` |
| `SEED_PASSWORD` | Synthetic demo-user password; never use in production | `<synthetic-demo-password>` |
| `NEXT_PUBLIC_API_URL` | API base URL baked into the Next.js build | `https://api.example.test` |

## Health checks

```bash
curl -fsS http://localhost:4000/health
# {"status":"ok", ...}

curl -fsS -o /dev/null -w '%{http_code}\n' http://localhost:3001/login
# 200
```

The PostgreSQL container health check is declared in `docker-compose.yml`; inspect it
with:

```bash
docker compose ps
docker inspect --format '{{.State.Health.Status}}' modern-pos-postgres
```

## Start, stop and logs

```bash
# PostgreSQL
docker compose up -d postgres
docker compose stop postgres
docker compose logs -f postgres

# API and web are host processes. Use a supervisor in any shared environment.
pkill -f 'node dist/main.js' || true
pkill -f 'next start -p 3001' || true
```

The commands above stop only processes matching those exact patterns. Confirm with
`ss -ltnp` that ports 4000 and 3001 are free before restarting.

## Reset to synthetic data

This is destructive and only appropriate for the staging/demo database.

```bash
# Stop API and web first.
pkill -f 'node dist/main.js' || true
pkill -f 'next start -p 3001' || true

# Delete the Docker volume, then recreate and reseed.
docker compose down -v
docker compose up -d postgres
pnpm --filter @modern-pos/api migrate:deploy
pnpm --filter @modern-pos/api seed
pnpm --filter @modern-pos/api seed
```

Seeded synthetic logins:

| Role | Email |
| --- | --- |
| Owner, Main Outlet | `owner@example.test` |
| Cashier, Main Outlet | `cashier@example.test` |
| Owner, Second Outlet | `owner.second@example.test` |
| Cashier, Second Outlet | `cashier.second@example.test` |

The password is the value of `SEED_PASSWORD`; the local example is a synthetic demo
password and must never be used outside local/staging verification.

## Smoke check

```bash
set -euo pipefail
curl -fsS http://localhost:4000/health >/dev/null
CODE=$(curl -s -o /dev/null -w '%{http_code}' -X POST http://localhost:4000/v1/auth/mobile/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"owner@example.test","password":"<synthetic-demo-password>","deviceId":"00000000-0000-4000-8000-000000000099"}')
test "$CODE" = "200"
echo "staging smoke: health ok, owner login ok"
```

Replace the device id with a fresh UUID for a real device. The seed password in the
example must be replaced with the value configured for that environment.

## Ownership boundary

- Flutter (`apps/mobile`) owns sale initiation, tender entry and physical printing.
  - `apps/mobile/lib/features/checkout/checkout_controller.dart:288` is the single
    finalize path; `:546` is pending-key recovery before a new sale.
  - `apps/mobile/lib/features/printing/esc_pos_receipt.dart:383` builds receipt bytes;
    `apps/mobile/lib/features/printing/print_queue_service.dart:306` sends them.
- NestJS (`apps/api`) owns authorization, price and tax calculation, idempotency and
  atomic persistence.
  - `apps/api/src/sales/sales.controller.ts:75` requires an owner/cashier role for
    `sales/finalize`; `:118` restricts reversal to an owner.
  - `apps/api/src/sales/money.ts:89` computes totals; `:117` validates payment.
  - `apps/api/src/sales/sales.service.ts:555` wraps finalize in a serializable
    transaction; `:1847` performs stock consumption with `FOR UPDATE` locks.
- Next.js (`apps/web`) is a read/administration surface only. Its route tree is
  `apps/web/app/(backoffice)/{menu,stock,sales,reports,printers,settings}`. It has no
  checkout, cart or tender route. `tendered` appears only in read-only receipt detail.

See `ARCHITECTURE.md`, `docs/owner-guide.md` and `docs/known-limitations.md`.

## Repeatable smoke verification

With the API running and the synthetic database seeded:

```bash
timeout 90 bash scripts/verify-mvp.sh
```

The script creates a synthetic category, stock item, tracked menu item and recipe,
then proves finalize, duplicate replay, retained-key recovery, one SALE stock
movement, a daily report, and an idempotent explicit reversal. It does not print
paper and does not replace the device checklist.
