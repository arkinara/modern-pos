# Modern POS

A minimalist, modern POS foundation: Android cashier, responsive web back office, and a shared backend.

## Product direction

Fast, calm, touch-friendly sales screens. Clear typography, neutral surfaces, one accent color, generous spacing, and accessible controls. The back office prioritizes dense, readable business information without clutter.

## Roadmap

| Phase | Scope | Draft tickets |
| --- | --- | --- |
| 1 — MVP | Web back office, Android cashier, menu and variants, connected stock, checkout, basic reports, one verified printer connection | M01–M18 |
| 2 — Complementary | Offline synchronization, tables/split bills, promotions/refunds, payment integration, shifts, purchasing, kitchen printing, multiple outlets, online ordering | C01–C09 |
| 3 — Improvements | Observe real use, prioritize feedback, refine usability and reliability against measured baselines | I01–I03 |

This repository currently contains planning documents and draft specifications, not a working POS application. Follow the three numbered phases in the brief.

## Selected technology stack

- Mobile: **Flutter / Dart**, Android first, Riverpod state management, go_router navigation, Dio HTTP client, and secure token storage.
- Web: **Next.js App Router / React / TypeScript**, Tailwind CSS and shadcn/ui, TanStack Query for API state, React Hook Form and Zod for forms.
- Backend: **NestJS / TypeScript**, REST API with OpenAPI, modular monolith.
- Database: **PostgreSQL with Prisma** for schema, migrations, and data access.
- Operations: Docker Compose for local database/API services, GitHub Actions for CI, containerized API/web and managed PostgreSQL for hosting.
- Verification: Flutter tests and Android integration checks, API integration tests against PostgreSQL, Playwright for critical web flows.

See [TECH_STACK.md](TECH_STACK.md) for boundaries, rationale, and release considerations. M01 records and validates the implementation architecture using this chosen stack.

## MVP boundaries and integrity rules

- Web is the back office; Android is the cashier. One business/outlet is the initial operational scope, with outlet-aware data boundaries.
- Completed sales deduct stock atomically and exactly once. Unpaid carts do not deduct stock. A repeated network request cannot produce another sale or another deduction.
- Menu variants can consume finished goods directly or ingredients through recipes. Preserve recipe and price snapshots for historical accuracy.
- MVP checkout requires a server connection. Full offline sales and reconciliation are Phase 2; never imply an unsupported offline guarantee.
- MVP supports cash and manual recording of external payment. Manual recording does not charge a customer or verify provider settlement.
- Minimum sale reversal and controlled stock restoration are part of MVP. Broader partial refunds and approval rules follow in Phase 2.
- Printer jobs are separate from checkout. A print failure never repeats payment or stock deduction. Support one real, verified printer/model/transport initially.
- Existing POS access is a workflow reference. Do not commit third-party source, brand assets, production data, or credentials.

## Planning workflow

Project: [Modern POS Board](https://github.com/users/arkinara/projects/19)

Workflow follows the reference board: **Todo → In Progress → In QA → Done**. All initial tickets are specifications awaiting implementation. Each ticket includes an ID, phase, area, priority, dependencies, scope, and acceptance criteria.

`backlog.json` is the structured source; `BACKLOG.md` is the readable version and `BACKLOG.csv` is the planning export. Individual issue bodies are published as GitHub issues. Phase 1 dependencies define the implementation order. Phase 2 is a planned backlog to refine after MVP; Phase 3 is deliberately evidence-driven.

## Proposed source layout (to implement in M03)

```text
apps/web/       # back office
apps/mobile/    # Flutter cashier (Android first)
services/api/   # shared backend
packages/       # shared contracts and design tokens where appropriate
docs/           # architecture, product specifications, operational guides
```

## First steps

1. Complete M01 architecture and hardware constraints.
2. Prototype the core flows in M02 while scaffolding M03.
3. Deliver menu, stock ledger, recipe linking, and sale completion before mobile checkout wiring.
4. Verify real printer behavior and complete the M18 release gate before production use.

## Architecture and design review package

Start with [HANDOFF.md](HANDOFF.md), then [ARCHITECTURE.md](ARCHITECTURE.md) and the [OpenAPI contract](API.openapi.json). The proposed [design system](DESIGN_SYSTEM.md) and [tokens](design-tokens.json) accompany the interactive [prototype](prototype.html).

The prototype is a static browser design review using synthetic session-only data. It is not the Flutter implementation or a production POS. Issue #2 remains open for owner style review; issue #3 is the next implementation step.

