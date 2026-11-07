# API (NestJS)

NestJS modular-monolith scaffold for Modern POS. The API is the only owner of business rules,
transactions and outlet-scoped authorization. Both clients consume the versioned contract in the
repository root.

## Endpoints in this ticket

| Method | Path | Notes |
| --- | --- | --- |
| `GET` | `/health` | Unversioned liveness/readiness probe. Returns `200` only when PostgreSQL responds. |
| `POST` | `/v1/auth/mobile/login` | Device sign-in; returns access + rotating refresh token. |
| `POST` | `/v1/auth/mobile/refresh` | Single-use refresh rotation bound to the device ID. |
| `POST` | `/v1/auth/web/login` | Web sign-in; sets HttpOnly refresh and readable CSRF cookies. |
| `POST` | `/v1/auth/web/refresh` | Cookie + `X-CSRF-Token` rotation. |
| `POST` | `/v1/auth/logout` | Revokes the current session and clears web cookies. |
| `GET` | `/v1/auth/me` | Returns the active user, role and outlet scope. |
| `GET` | `/v1/outlets/{outletId}` | Authorized outlet configuration. |
| `PATCH` | `/v1/outlets/{outletId}` | Owner-only settings update with optimistic version check. |
| `*` | `/v1/*` | Other OpenAPI v0.2.0 operations are implemented by later tickets. |

The global prefix `v1` is excluded for `/health` so container/orchestrator probes stay stable.

## Database boundary

`prisma/schema.prisma` contains identity/authorization plumbing plus the minimum outlet fields
required by the contract:

- `Business`, `Outlet`
- `User` (Argon2id hash, role, active flag)
- `Session` (hashed opaque refresh token, family, expiry, revocation)

Catalog, recipes, stock ledger, orders, sales, reports and printing models belong to tickets
#6-#10. Do not add transaction rules here until those tickets define them. Migrations are
committed under `prisma/migrations/`.

## Authorization model

Global Passport JWT, role and outlet-scope guards protect every route except `@Public()` health
and auth entry points. JWT claims are never trusted for role or outlet: the strategy reloads the
user and session from PostgreSQL on every request, so sign-out and rotation take effect
immediately. Out-of-scope outlet IDs return `404`. See `DEVELOPMENT.md` for the full behavior,
seeded identities and rate-limit configuration.

## Local commands

```bash
cp .env.example .env
pnpm --filter @modern-pos/api prisma:generate
pnpm --filter @modern-pos/api exec prisma migrate deploy
pnpm --filter @modern-pos/api seed
pnpm --filter @modern-pos/api dev
```

The API listens on `PORT` (default `4000`). `WEB_ORIGIN` is a comma-separated CORS allowlist.

## Verification

```bash
pnpm --filter @modern-pos/api typecheck
pnpm --filter @modern-pos/api test
pnpm --filter @modern-pos/api build
curl -fsS http://localhost:4000/health
```

The seed is deterministic and re-runnable. All seeded identities are synthetic
(`*.example.test`). No production credentials or data belong in this repository.
