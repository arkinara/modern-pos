CREATE TYPE "RefundIntentState" AS ENUM ('PENDING', 'UNKNOWN', 'SUCCEEDED', 'FAILED', 'COMPLETED');

CREATE TABLE "refund_intents" (
    "id" UUID NOT NULL,
    "businessId" UUID NOT NULL,
    "outletId" UUID NOT NULL,
    "saleId" UUID NOT NULL,
    "actorId" UUID NOT NULL,
    "idempotencyKey" UUID NOT NULL,
    "requestHash" TEXT NOT NULL,
    "providerKey" TEXT NOT NULL,
    "provider" "PaymentProvider" NOT NULL,
    "providerPaymentRef" TEXT NOT NULL,
    "refundMinor" BIGINT NOT NULL CHECK ("refundMinor" >= 0),
    "reason" TEXT NOT NULL,
    "lines" JSONB NOT NULL,
    "restock" JSONB NOT NULL,
    "state" "RefundIntentState" NOT NULL DEFAULT 'PENDING',
    "providerRefundRef" TEXT,
    "lastErrorCode" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    CONSTRAINT "refund_intents_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "refund_intents_saleId_fkey" FOREIGN KEY ("saleId") REFERENCES "sales"("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE UNIQUE INDEX "refund_intents_outletId_idempotencyKey_key" ON "refund_intents"("outletId", "idempotencyKey");
CREATE UNIQUE INDEX "refund_intents_providerKey_key" ON "refund_intents"("providerKey");
CREATE INDEX "refund_intents_saleId_state_idx" ON "refund_intents"("saleId", "state");
-- Defense in depth: even non-serializable callers cannot reserve a second
-- unresolved refund for the same sale.
CREATE UNIQUE INDEX "refund_intents_one_active_sale" ON "refund_intents"("saleId")
WHERE "state" IN ('PENDING', 'UNKNOWN', 'SUCCEEDED');
