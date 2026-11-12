-- A failed provider intent can be retried on the same local payment row. The
-- attempt number scopes the provider idempotency key so a lost-connection retry
-- still reuses one charge while an explicit retry after a terminal failure can
-- ask the provider for a fresh payment.
ALTER TABLE "online_payments" ADD COLUMN "attempt" INTEGER NOT NULL DEFAULT 1;
