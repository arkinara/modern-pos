-- CreateTable
CREATE TABLE "sale_reversals" (
    "id" UUID NOT NULL,
    "businessId" UUID NOT NULL,
    "outletId" UUID NOT NULL,
    "saleId" UUID NOT NULL,
    "actorId" UUID NOT NULL,
    "reason" TEXT NOT NULL,
    "restock" JSONB NOT NULL,
    "externalRefundPerformed" BOOLEAN NOT NULL DEFAULT false,
    "idempotencyKey" UUID NOT NULL,
    "requestHash" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "sale_reversals_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "sale_reversals_saleId_key" ON "sale_reversals"("saleId");

-- CreateIndex
CREATE UNIQUE INDEX "sale_reversals_outletId_idempotencyKey_key" ON "sale_reversals"("outletId", "idempotencyKey");

-- CreateIndex
CREATE INDEX "sale_reversals_businessId_outletId_createdAt_idx" ON "sale_reversals"("businessId", "outletId", "createdAt");

-- AddForeignKey
ALTER TABLE "sale_reversals" ADD CONSTRAINT "sale_reversals_businessId_fkey" FOREIGN KEY ("businessId") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sale_reversals" ADD CONSTRAINT "sale_reversals_outletId_fkey" FOREIGN KEY ("outletId") REFERENCES "outlets"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sale_reversals" ADD CONSTRAINT "sale_reversals_saleId_fkey" FOREIGN KEY ("saleId") REFERENCES "sales"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sale_reversals" ADD CONSTRAINT "sale_reversals_actorId_fkey" FOREIGN KEY ("actorId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- Domain invariants enforced by the database as well as the service layer.
ALTER TABLE "sale_reversals"
    ADD CONSTRAINT "sale_reversals_reason_length_check"
    CHECK (char_length("reason") BETWEEN 3 AND 500);

ALTER TABLE "sale_reversals"
    ADD CONSTRAINT "sale_reversals_no_external_refund_check"
    CHECK ("externalRefundPerformed" = false);

-- Reversals are append-only records.
CREATE OR REPLACE FUNCTION modern_pos_sale_reversal_append_only()
RETURNS trigger AS $$
BEGIN
    RAISE EXCEPTION 'sale reversals are append-only';
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER sale_reversals_no_update
    BEFORE UPDATE ON "sale_reversals"
    FOR EACH ROW EXECUTE FUNCTION modern_pos_sale_reversal_append_only();

CREATE TRIGGER sale_reversals_no_delete
    BEFORE DELETE ON "sale_reversals"
    FOR EACH ROW EXECUTE FUNCTION modern_pos_sale_reversal_append_only();
