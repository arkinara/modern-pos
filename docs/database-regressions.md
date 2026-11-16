# PostgreSQL transaction regressions

`pnpm --filter @modern-pos/api test:db` runs the committed checkout, refund and
transfer integration suites. Both suites use PostgreSQL through the application
services. Provider responses in refund tests use a controlled adapter.

The CI workflow provisions PostgreSQL 17.6, applies migrations and seeds synthetic
data twice. Its mandatory transaction-regression step runs next, with a three-minute
timeout. An unsuccessful suite fails the existing CI job. The step prints database
effect counts alongside its assertions.

## Local execution

Create a disposable database in the local PostgreSQL service, for example
`modern_pos_transaction_test`. With the repository Docker Compose service running,
the creation command is `docker compose exec postgres createdb -U pos modern_pos_transaction_test`.

Set both URLs to the same database before migrating, seeding and testing. A
PowerShell session can use the following commands.

```powershell
$env:DATABASE_URL = 'postgresql://pos:pos_local_dev@localhost:5432/modern_pos_transaction_test?schema=public'
$env:TRANSACTION_TEST_DATABASE_URL = $env:DATABASE_URL
$env:NODE_ENV = 'test'
$env:PAYMENT_PROVIDER = 'mock'
$env:PAYMENT_MODE = 'sandbox'
$env:PAYMENT_SANDBOX_ENABLED = 'true'
pnpm --filter @modern-pos/api prisma:generate
pnpm --filter @modern-pos/api migrate:deploy
pnpm --filter @modern-pos/api seed
pnpm --filter @modern-pos/api seed
pnpm --filter @modern-pos/api test:db
```

The test target must use PostgreSQL and a database name ending in
`_transaction_test` or `_refund_test`. The helper rejects production mode and
different migration/test URLs. The standalone `test:refund:integration` command
also accepts the existing `REFUND_TEST_DATABASE_URL` environment variable.

Each test creates a distinct catalog variant and ingredient with fixed quantities,
an opening movement and a matching stock balance. Tests use the synthetic seeded
owner and outlet records. Repeated runs create additional isolated fixtures and
exercise the same quantity invariants. Test fixture lifetime follows the disposable
database lifetime.

## Coverage

| Scenario | Database assertions |
| --- | --- |
| Distinct checkout keys contend for six ingredient units | One sale/payment/movement commits, stock reaches zero, and the competing checkout fails |
| A PostgreSQL trigger rejects the final audit write | Sale, payment, stock, order completion and checkout reservation roll back together, then same-key retry succeeds |
| Concurrent duplicate checkout keys | Four requests return one sale, one payment and one six-unit deduction |
| Checkout response times out after commit | A separate Node process recovers and replays the checkout through the application services with one durable sale and stock effect |
| Online refunds | Invalid requests have zero provider calls, concurrent requests honor reservations, and provider-success/local-failure recovery produces one reversal and restock set |
| Transfer receive and replay | Five attempts produce one outbound movement, one inbound movement and a conserved source/destination total |

The rollback test installs a generated, fixture-scoped trigger and removes it in a
`finally` block. This requires trigger/function privileges on the disposable test
database. CI's PostgreSQL test user has these privileges.

Individual checkout/transfer tests have 30-second limits. The recovery child
process has a 15-second limit. CI bounds the complete database step to three minutes.
Large load tests and actual provider acceptance have their own execution paths.
