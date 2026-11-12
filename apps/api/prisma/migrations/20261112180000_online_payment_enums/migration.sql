-- Online payment lifecycle values. Kept in a separate migration so the new
-- enum values are committed before tables use them as defaults.
ALTER TYPE "PaymentKind" ADD VALUE IF NOT EXISTS 'ONLINE';

ALTER TYPE "PaymentStatus" ADD VALUE IF NOT EXISTS 'PENDING';
ALTER TYPE "PaymentStatus" ADD VALUE IF NOT EXISTS 'SUCCEEDED';
ALTER TYPE "PaymentStatus" ADD VALUE IF NOT EXISTS 'FAILED';
ALTER TYPE "PaymentStatus" ADD VALUE IF NOT EXISTS 'REFUNDED';
ALTER TYPE "PaymentStatus" ADD VALUE IF NOT EXISTS 'PARTIALLY_REFUNDED';

CREATE TYPE "PaymentProvider" AS ENUM ('MOCK', 'QRIS');

-- Online refunds are performed by the provider adapter, so the historical
-- "never external" database invariant no longer applies. Cash and manual
-- records still write false.
ALTER TABLE "sale_reversals" DROP CONSTRAINT IF EXISTS "sale_reversals_no_external_refund_check";
