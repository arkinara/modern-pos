# API (NestJS)

NestJS modular-monolith scaffold for Modern POS. The API is the only owner of business rules,
transactions and outlet-scoped authorization. Both clients consume the versioned contract in the
repository root.

## Endpoints in this ticket

| Method | Path | Notes |
| --- | --- | --- |
| `GET` | `/health` | Unversioned liveness/readiness probe. Returns `200` only when PostgreSQL responds. |
| `*` | `/v1/*` | Reserved for the OpenAPI v0.1.0 operations implemented by later tickets. |

The global prefix `v1` is excluded for `/health` so container/orchestrator probes stay stable.

## Database boundary

`prisma/schema.prisma` intentionally contains only the plumbing needed for this foundation:

- `Business`
- `Outlet`
- `User`

Catalog, recipes, stock ledger, orders, sales, reports and printing models belong to tickets
#6-#10. Do not add transaction rules here until those tickets define them. Migrations are
committed under `prisma/migrations/`.

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
