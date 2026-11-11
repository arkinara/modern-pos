-- CreateEnum
CREATE TYPE "OrderAuditAction" AS ENUM ('OPEN', 'UPDATE', 'TRANSFER', 'SPLIT', 'CANCEL', 'FINALIZE');

-- AlterEnum
ALTER TYPE "OrderState" ADD VALUE 'SPLIT';

-- AlterTable
ALTER TABLE "orders" ADD COLUMN     "parentOrderId" UUID,
ADD COLUMN     "splitGroupId" UUID,
ADD COLUMN     "tableId" UUID;

-- CreateTable
CREATE TABLE "dining_tables" (
    "id" UUID NOT NULL,
    "businessId" UUID NOT NULL,
    "outletId" UUID NOT NULL,
    "label" TEXT NOT NULL,
    "seatCount" INTEGER NOT NULL DEFAULT 0,
    "active" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "dining_tables_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "order_audits" (
    "id" UUID NOT NULL,
    "businessId" UUID NOT NULL,
    "outletId" UUID NOT NULL,
    "orderId" UUID NOT NULL,
    "actorId" UUID NOT NULL,
    "action" "OrderAuditAction" NOT NULL,
    "fromTableId" UUID,
    "toTableId" UUID,
    "metadata" JSONB NOT NULL DEFAULT '{}',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "order_audits_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "order_splits" (
    "id" UUID NOT NULL,
    "businessId" UUID NOT NULL,
    "outletId" UUID NOT NULL,
    "parentOrderId" UUID NOT NULL,
    "actorId" UUID NOT NULL,
    "idempotencyKey" UUID NOT NULL,
    "requestHash" TEXT NOT NULL,
    "splitGroupId" UUID NOT NULL,
    "billCount" INTEGER NOT NULL,
    "childOrderIds" JSONB NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "order_splits_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "dining_tables_outletId_active_idx" ON "dining_tables"("outletId", "active");

-- CreateIndex
CREATE UNIQUE INDEX "dining_tables_outletId_label_key" ON "dining_tables"("outletId", "label");

-- CreateIndex
CREATE INDEX "order_audits_orderId_createdAt_idx" ON "order_audits"("orderId", "createdAt");

-- CreateIndex
CREATE INDEX "order_audits_outletId_createdAt_idx" ON "order_audits"("outletId", "createdAt");

-- CreateIndex
CREATE INDEX "order_splits_parentOrderId_idx" ON "order_splits"("parentOrderId");

-- CreateIndex
CREATE INDEX "order_splits_splitGroupId_idx" ON "order_splits"("splitGroupId");

-- CreateIndex
CREATE UNIQUE INDEX "order_splits_outletId_idempotencyKey_key" ON "order_splits"("outletId", "idempotencyKey");

-- CreateIndex
CREATE INDEX "orders_tableId_idx" ON "orders"("tableId");

-- CreateIndex
CREATE INDEX "orders_parentOrderId_idx" ON "orders"("parentOrderId");

-- CreateIndex
CREATE INDEX "orders_splitGroupId_idx" ON "orders"("splitGroupId");

-- AddForeignKey
ALTER TABLE "dining_tables" ADD CONSTRAINT "dining_tables_businessId_fkey" FOREIGN KEY ("businessId") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "dining_tables" ADD CONSTRAINT "dining_tables_outletId_fkey" FOREIGN KEY ("outletId") REFERENCES "outlets"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "orders" ADD CONSTRAINT "orders_tableId_fkey" FOREIGN KEY ("tableId") REFERENCES "dining_tables"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "orders" ADD CONSTRAINT "orders_parentOrderId_fkey" FOREIGN KEY ("parentOrderId") REFERENCES "orders"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_audits" ADD CONSTRAINT "order_audits_businessId_fkey" FOREIGN KEY ("businessId") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_audits" ADD CONSTRAINT "order_audits_outletId_fkey" FOREIGN KEY ("outletId") REFERENCES "outlets"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_audits" ADD CONSTRAINT "order_audits_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES "orders"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_audits" ADD CONSTRAINT "order_audits_actorId_fkey" FOREIGN KEY ("actorId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_splits" ADD CONSTRAINT "order_splits_businessId_fkey" FOREIGN KEY ("businessId") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_splits" ADD CONSTRAINT "order_splits_outletId_fkey" FOREIGN KEY ("outletId") REFERENCES "outlets"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_splits" ADD CONSTRAINT "order_splits_parentOrderId_fkey" FOREIGN KEY ("parentOrderId") REFERENCES "orders"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_splits" ADD CONSTRAINT "order_splits_actorId_fkey" FOREIGN KEY ("actorId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- The audit trail is append-only: revisions or removals must never rewrite history.
CREATE OR REPLACE FUNCTION reject_order_audit_mutation() RETURNS trigger AS $$
BEGIN
  RAISE EXCEPTION 'order_audits is append-only';
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER order_audits_append_only
BEFORE UPDATE OR DELETE ON "order_audits"
FOR EACH ROW EXECUTE FUNCTION reject_order_audit_mutation();
