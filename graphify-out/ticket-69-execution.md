# Ticket #69 execution evidence and QA context

Issue: https://github.com/arkinara/modern-pos/issues/69

Branch: `fix/69-production-config`. Base: `2485f8c1d836d741ab62f11d8e60bdbb26d59937`.
Execution date: 2026-11-16. Track A / Developer A (Codex).

## Status and scope

Project 19 moved from Todo to In Progress before implementation. This ticket stops
at In QA after developer tests and a reviewable PR; it does not close #69 or start
#71. #66 remains a separate open PR (#79) and is not a prerequisite of this change.

The baseline allowed a development JWT secret, insecure cookies, permissive CORS
fallback and implicit MOCK payments without a production startup gate. Public
sandbox methods checked only provider selection. This is a source-traced safeguard
gap, not evidence of an exposed production deployment.

## Changes and evidence relationships

- `apps/api/src/config/runtime-config.ts`: reject unsafe production configuration
  before Nest/database/listener creation; emit variable names only.
- `apps/api/src/main.ts`: invoke the startup gate and preserve validation, cookies,
  exception handling and exact credentialed CORS origins.
- `apps/api/src/auth/auth.config.ts`: guard production auth config even outside
  normal startup; keep secure-cookie parsing consistent.
- `apps/api/src/payments/payment-config.service.ts`: explicit local/test sandbox
  opt-in and no production MOCK fallback.
- `apps/api/src/payments/sandbox-provider.controller.ts` and `payments.module.ts`:
  pre-validation guard returns 404 before invalid bodies can reach DTO validation.
  Method-level checks remain for direct calls.
- `apps/api/src/payments/mock-payment-provider.service.ts`: direct mock create,
  read, refund and event calls cannot bypass the production gate.
- New runtime and sandbox unit tests plus updated payment config/service tests;
  API test command includes the new config suite.
- `.env.example`, CI environment and development/payment/staging instructions
  explicitly opt local/test execution into MOCK and describe production settings.

## Verification

Final results are recorded in `ticket-69-context.json` and the raw output files:

- `ticket-69-api-unit.txt`: **302 unit tests passed, zero failures**, on Node 22.23.1 / pnpm 9.12.3.
- `ticket-69-http.txt`: compiled unsafe-startup rejection and real localhost HTTP
  routing with a synthetic provider; five scenarios, 20 endpoint assertions.
- API typecheck and build passed on the pinned Node runtime.
- Full API formatting passes with `--end-of-line auto` for the Windows checkout;
  changed source files also pass the default LF check.
- No database schema, migration or financial calculation changes are included.

HTTP checks include production with MOCK/opt-in forced on, production QRIS,
local execution without opt-in, and an explicitly enabled local sandbox. Disabled
routes return 404 for valid and invalid payloads and make zero provider calls.
Enabled local routes retain 201/200/201 responses; invalid payloads still fail
validation. A compiled unsafe startup exits 1 without reaching the database or
listener and omits submitted secret values from diagnostics.

The first focused unit run passed 34/35 checks; its test-only assertion incorrectly
treated an empty string as a leaked value. The assertion was corrected before the
final suite. Existing authentication, sessions, CSRF, role/outlet guards, payments,
webhook/replay and financial unit regressions remain in the full suite.

## Reproduction

1. Install pinned workspace dependencies and generate the Prisma client as usual.
2. Run `pnpm --filter @modern-pos/api test`, `typecheck` and `build`.
3. Run `node graphify-out/verify-ticket-69-http.cjs` after the build. It needs only
   loopback access and synthetic provider I/O, not a database or actual provider.
4. Check the committed local environment example passes runtime validation.
5. For deployment configuration, follow `docs/staging-setup.md` and use
   `NODE_ENV=production` with an explicit QRIS mode, strong secrets, secure cookies
   and exact HTTPS web origins. Keep the mock flag disabled.

## Graphify context injection

`ticket-69-context.json` is the source record. Run
`node graphify-out/inject-ticket-context.mjs` to add/update execution evidence in
`graph.json` and the interactive `graph.html`. The historical AST baseline stays
identified by `built_at_commit`; evidence overlays are not a full AST rebuild.
The injector preserves other tickets' evidence nodes and links.

Validation passed: graph JSON parses, node IDs are unique, all 20 ticket #69
evidence links resolve, and the interactive HTML overlay compiles as JavaScript.

## QA handoff and boundaries

Independent QA should review the startup rejection matrix, redacted diagnostics,
forced-MOCK route blocking (including malformed bodies), explicit local opt-in,
and existing auth/CSRF/outlet behavior. Keep the issue open and stop at In QA.

No live deployment, TLS termination, actual provider certification, credentials,
payments or external infrastructure were changed. Passing configuration validation
does not establish actual provider sandbox acceptance (#75) or operations readiness
(#77). Payment mode declares the intended provider environment; credentials/base
URL must match it. Secret validation rejects missing/common placeholders and
low-diversity values; it does not prove randomness or provision keys.

Rollout has no database migration. Supply valid production configuration before
replacing instances and check health before switching traffic. If rollback removes
the safeguard, keep that instance private with public sandbox access blocked until
the fixed version is restored. Do not bypass the gate by using development mode
for a shared production environment.
