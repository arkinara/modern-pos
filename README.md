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

The repository contains implemented Flutter cashier, Next.js back-office and NestJS API applications, PostgreSQL migrations, generated clients and automated checks. The original phase tickets have merged implementation history. Hardware, actual payment-provider, operator and deployment acceptance are tracked in the audit follow-up tickets. The evidence ledger records the current source and each remaining acceptance owner. [Implementation evidence](docs/implementation-evidence.md)

## Selected technology stack

- Mobile: **Flutter / Dart**, Android first, Riverpod state management, go_router navigation, Dio HTTP client, and secure token storage.
- Web: **Next.js App Router / React / TypeScript**, Tailwind CSS and shadcn/ui, TanStack Query for API state, React Hook Form and Zod for forms.
- Backend: **NestJS / TypeScript**, REST API with OpenAPI, modular monolith.
- Database: **PostgreSQL with Prisma** for schema, migrations, and data access.
- Operations: Docker Compose supplies local PostgreSQL, and GitHub Actions checks the apps and contracts. The staging procedure describes host API/web processes. Deployment topology and operational acceptance are tracked in #77.
- Verification: CI runs JavaScript tests/builds, contract checks, migrations/seed, Flutter checks and an Android debug build. The dedicated PostgreSQL suite is delivered in PR #84 under #71. Browser regressions are tracked in #72.

See [TECH_STACK.md](TECH_STACK.md) for boundaries, rationale, and release considerations. M01 records the original architecture baseline using this chosen stack.

## MVP boundaries and integrity rules

- Web is the back office; Android is the cashier. One business/outlet is the initial operational scope, with outlet-aware data boundaries.
- Completed sales deduct stock atomically and exactly once. Unpaid carts do not deduct stock. A repeated network request cannot produce another sale or another deduction.
- Menu variants can consume finished goods directly or ingredients through recipes. Preserve recipe and price snapshots for historical accuracy.
- Checkout is server-authoritative. The Flutter client has an encrypted offline queue and bounded offline session recovery from #19/#68. Device and reconnect acceptance are tracked in #74/#76.
- MVP supports cash and manual recording of external payment. Manual recording does not charge a customer or verify provider settlement.
- Sale reversals, partial refunds and approval rules are implemented. Durable online refund intent/recovery work is in QA under #66, and actual provider acceptance is tracked in #75.
- Printer jobs are separate from checkout. A print failure never repeats payment or stock deduction. Support one real, verified printer/model/transport initially.
- Existing POS access is a workflow reference. Do not commit third-party source, brand assets, production data, or credentials.

## Planning workflow

Project: [Modern POS Board](https://github.com/users/arkinara/projects/19)

Workflow follows the reference board with **Todo → In Progress → In QA → Done**. Original issue bodies retain their planning criteria and closure history. The evidence ledger links merged code, historical verification and outstanding acceptance work.

`backlog.json`, `BACKLOG.md` and `BACKLOG.csv` preserve the original planning baseline. Current execution status comes from the board and evidence ledger. Phase 1–3 modules have implementation history, with follow-up integrity and operational acceptance tickets still active.

## Source layout

```text
apps/web/       # back office
apps/mobile/    # Flutter cashier (Android first)
apps/api/       # NestJS backend and Prisma migrations
packages/       # shared contracts and design tokens where appropriate
docs/           # architecture, product specifications, operational guides
```

## Local development

Install the pinned toolchain and copy the API/web environment examples as described in the development guide. Start PostgreSQL, apply migrations and seed synthetic data, then start the API and back office.

```text
pnpm install --frozen-lockfile
docker compose up -d postgres
pnpm --filter @modern-pos/api prisma:generate
pnpm --filter @modern-pos/api migrate:deploy
pnpm --filter @modern-pos/api seed
pnpm dev:api
pnpm dev:web
```

Run the API and web development commands in separate terminals. Flutter setup and Android build commands are documented alongside the pinned versions. [Development guide](DEVELOPMENT.md)

## Acceptance work

| Area | Current work |
| --- | --- |
| Refund integrity, production configuration, database CI | #66, #69 and #71 are in QA in PRs #79, #83 and #84 |
| Physical Android/printer support | #74 records the exact tested device/model/transport |
| Actual payment-provider sandbox | #75 owns provider selection, webhook/refund evidence and reconciliation |
| Representative operator workflows | #76 owns field observations and acceptance |
| Backups, restore, monitoring and operational ownership | #77 owns deployment acceptance |
| Final release candidate | #78 follows prerequisite evidence and the release decision |

The status snapshot is dated 2026-11-16. Current board states and exact historical references are indexed in the ledger. [Implementation evidence](docs/implementation-evidence.md)

## Architecture and design review package

Start with [HANDOFF.md](HANDOFF.md), then [ARCHITECTURE.md](ARCHITECTURE.md) and the [OpenAPI contract](API.openapi.json). The proposed [design system](DESIGN_SYSTEM.md) and [tokens](design-tokens.json) accompany the interactive [prototype](prototype.html).

The prototype preserves the static browser design review and its synthetic session-only interactions. Issue #2 is closed in the board snapshot, and native/operator acceptance continues under #74/#76. Application source lives under `apps/`.

**[Open the interactive design review](https://arkinara.github.io/modern-pos/prototype.html)** — switch between Menu, Stock, Reports and Printers. Cashier/cart/checkout belong exclusively to the Flutter mobile app. The review-only controls expose loading, empty, error and offline states. All demo changes reset on reload.

