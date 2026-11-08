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
| `GET` | `/v1/outlets/{outletId}/settings` | Business and outlet settings; cashier-readable. |
| `PATCH` | `/v1/outlets/{outletId}/settings` | Owner-only settings update with `version` conflict check. |
| `GET` | `/v1/outlets/{outletId}/categories` | Business categories; cashier-readable. |
| `POST` | `/v1/outlets/{outletId}/categories` | Owner-only category creation. |
| `GET` | `/v1/outlets/{outletId}/menu` | Cursor/search catalog listing; cashier-readable. |
| `POST` | `/v1/outlets/{outletId}/menu` | Owner-only menu creation with 1–50 variants. |
| `PATCH` | `/v1/outlets/{outletId}/menu/{menuId}` | Owner-only menu update with `revision` conflict check. |
| `POST` | `/v1/outlets/{outletId}/menu/{menuId}/archive` | Owner-only soft archive with `revision` conflict check. |
| `PATCH` | `/v1/outlets/{outletId}/variants/{variantId}` | Owner-only price, policy and enabled update with `revision`. |
| `*` | `/v1/*` | Other OpenAPI v0.2.0 operations are implemented by later tickets. |

The global prefix `v1` is excluded for `/health` so container/orchestrator probes stay stable.

## Database boundary

`prisma/schema.prisma` contains identity/authorization plumbing, outlet settings and the
catalog:

- `Business`, `Outlet`
- `User` (Argon2id hash, role, active flag)
- `Session` (hashed opaque refresh token, family, expiry, revocation)
- `Category`, `MenuItem`, `MenuVariant`, `OutletMenu` (business-owned catalog plus per-outlet
  visibility and enabled flags)

Recipes, stock ledger, orders, sales, reports and printing models belong to tickets #7-#10. Do
not add transaction rules here until those tickets define them. Migrations are committed under
`prisma/migrations/`.

Catalog prices are PostgreSQL `BIGINT` minor units and are serialized as JSON safe integers.
Category identities are business-owned; a menu item and its variants become visible in an outlet
through `OutletMenu` rows. Archive is soft (`archived_at`) so menu item names, variant IDs and
future sale snapshots remain readable. No catalog deletion endpoint exists.

## Authorization model

Global Passport JWT, role and outlet-scope guards protect every route except `@Public()` health
and auth entry points. JWT claims are never trusted for role or outlet: the strategy reloads the
user and session from PostgreSQL on every request, so sign-out and rotation take effect
immediately. Out-of-scope outlet IDs return `404`. See `DEVELOPMENT.md` for the full behavior,
seeded identities and rate-limit configuration.

## Catalog behavior (#6)

- Reads (`GET categories`, `GET menu`) accept both owner and cashier sessions. All writes are
  owner-only; a cashier write returns `403`, a missing session returns `401`, and an outlet the
  session cannot access returns `404`.
- Every query is constrained by the authenticated business and the outlet link. Menu IDs and
  variant IDs from another outlet or tenant return `404`.
- Menu updates and variant updates use revision-based optimistic concurrency. A stale revision
  returns `409 VERSION_CONFLICT` and writes nothing.
- `availableUnits` is always `null` in this ticket. For `UNTRACKED` variants it is explicitly
  null by definition; for `TRACKED` variants the authoritative source is the stock ledger in #7.
  The API does not fabricate a quantity before that ledger exists.
- Archive is a soft update to `menu_items.archived_at`; rows, variant IDs and future sale
  snapshots stay intact. Owner menu reads include archived records with `archived: true`.
  Cashier menu reads exclude archived items, archived categories and disabled variants, so the
  Android saleable catalog never includes archived products.

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
