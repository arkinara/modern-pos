# Technology decision: Flutter + Next.js + NestJS + PostgreSQL

Status: Selected foundation, 7 November 2026. Dependency versions will be pinned to mutually compatible stable releases during scaffolding; this document is not a generated compatibility lockfile.

## Mobile

Flutter and Dart, Android first. Riverpod for state and dependency management, go_router for navigation, Dio for the REST client, and platform secure storage for session credentials. Organize by feature with UI/view-model and repository/service boundaries.

Generate or validate Dart API models against the shared OpenAPI contract; do not attempt to share TypeScript source directly with Dart. Use Flutter platform adapters for printers, choosing packages only after testing the actual model and Android permission requirements.

Persist print jobs and checkout recovery references locally. Durable local storage is needed in MVP even though completing sales is online-only. Use SQLite through Drift for that small durable queue; Phase 2 expands local storage and introduces explicit offline conflict handling. Never put secrets in plain local tables.

## Web

Next.js App Router, React and TypeScript. Tailwind CSS plus shadcn/ui for a restrained and accessible interface; TanStack Query for browser API caching and mutations; React Hook Form plus Zod for validated forms. Keep financial and stock rules in the backend. Server-rendered pages may provide initial data, but authenticated mutations call the same API used by Flutter.

## Backend and data

NestJS as a single modular application: identity, business/outlets, catalog, inventory, sales, reporting, and printing metadata. Publish REST/OpenAPI contracts for both clients. PostgreSQL is the source of truth; Prisma manages schema, migrations and data access.

Sale finalization and inventory movements run in one database transaction with a unique idempotency key and database-enforced concurrency policy. Use serializable transactions or explicit guarded updates/locking where needed, with bounded retry of serialization conflicts. Application code must not implement stock deduction as independent read-then-write requests. Use decimal quantities and integer minor-unit money with documented rounding.

Start with one database and one API deployment. Redis, event buses, microservices and independent analytics warehouses are not MVP dependencies. Critical stock movements remain synchronous within sale completion; printer delivery runs independently.

## Authentication and deployment

Owner and cashier identities are authorized server-side with business/outlet boundaries. Use Nest Passport JWT strategies, Argon2id password hashes and server-tracked rotating opaque refresh sessions as specified in ARCHITECTURE.md; implement and verify these in M04. Web sessions use secure HTTP-only cookies where applicable; Flutter credentials use platform secure storage. Do not build custom cryptography or duplicate competing identity stores.

Use pnpm workspaces for TypeScript projects; Flutter uses its own pub tooling in the same repository. Docker Compose supplies local PostgreSQL and optionally the API/web. CI runs TypeScript checks, Flutter checks, builds, and meaningful domain/integration tests. Hosting uses containerized web/API services and managed PostgreSQL; select the provider when staging requirements and budget are known.

## Why this foundation

Flutter meets the requested mobile direction and supports native printer integration. Next.js offers a modern React UI foundation for the back office. TypeScript across web/API reduces context switching, while a separate API gives both clients one authoritative place for business rules. PostgreSQL transactions fit the need for consistent sales and stock; Prisma provides a maintainable schema and migration workflow.

## References

- [Flutter architecture guidance](https://docs.flutter.dev/app-architecture/guide)
- [Next.js documentation](https://nextjs.org/docs)
- [NestJS documentation](https://docs.nestjs.com/)
- [Prisma transactions](https://www.prisma.io/docs/orm/fundamentals/transactions)

## Pending validation, not undecided stack

Printer model/transport, detailed authentication configuration, hosting provider, and exact pinned dependency versions require implementation-time validation. Frameworks and database are selected. iOS support and full offline sales are outside Phase 1.

