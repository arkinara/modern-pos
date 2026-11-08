-- CreateEnum
CREATE TYPE "StockBaseUnit" AS ENUM ('g', 'ml', 'each');

-- CreateEnum
CREATE TYPE "StockMovementType" AS ENUM ('OPENING', 'RECEIPT', 'ADJUSTMENT', 'SALE', 'REVERSAL');

-- CreateTable
CREATE TABLE "stock_items" (
    "id" UUID NOT NULL,
    "businessId" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "baseUnit" "StockBaseUnit" NOT NULL,
    "quantityScale" INTEGER NOT NULL,
    "reorderThreshold" DECIMAL(20,6) NOT NULL,
    "archivedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "stock_items_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "stock_balances" (
    "id" UUID NOT NULL,
    "outletId" UUID NOT NULL,
    "stockItemId" UUID NOT NULL,
    "quantity" DECIMAL(20,6) NOT NULL DEFAULT 0,
    "version" INTEGER NOT NULL DEFAULT 1,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "stock_balances_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "stock_movements" (
    "id" UUID NOT NULL,
    "outletId" UUID NOT NULL,
    "stockItemId" UUID NOT NULL,
    "delta" DECIMAL(20,6) NOT NULL,
    "type" "StockMovementType" NOT NULL,
    "actorId" UUID NOT NULL,
    "reason" TEXT NOT NULL,
    "sourceId" UUID NOT NULL,
    "sourceLineId" UUID,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "stock_movements_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "stock_idempotency" (
    "id" UUID NOT NULL,
    "outletId" UUID NOT NULL,
    "key" UUID NOT NULL,
    "operation" TEXT NOT NULL,
    "requestHash" TEXT NOT NULL,
    "movementId" UUID,
    "responseBody" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "stock_idempotency_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "stock_items_businessId_archivedAt_idx" ON "stock_items"("businessId", "archivedAt");

-- CreateIndex
CREATE UNIQUE INDEX "stock_items_id_businessId_key" ON "stock_items"("id", "businessId");

-- CreateIndex
CREATE INDEX "stock_balances_stockItemId_idx" ON "stock_balances"("stockItemId");

-- CreateIndex
CREATE UNIQUE INDEX "stock_balances_outletId_stockItemId_key" ON "stock_balances"("outletId", "stockItemId");

-- CreateIndex
CREATE INDEX "stock_movements_outletId_stockItemId_createdAt_idx" ON "stock_movements"("outletId", "stockItemId", "createdAt");

-- CreateIndex
CREATE INDEX "stock_movements_stockItemId_idx" ON "stock_movements"("stockItemId");

-- CreateIndex
CREATE INDEX "stock_idempotency_createdAt_idx" ON "stock_idempotency"("createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "stock_idempotency_outletId_key_key" ON "stock_idempotency"("outletId", "key");

-- AddForeignKey
ALTER TABLE "stock_items" ADD CONSTRAINT "stock_items_businessId_fkey" FOREIGN KEY ("businessId") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stock_balances" ADD CONSTRAINT "stock_balances_outletId_fkey" FOREIGN KEY ("outletId") REFERENCES "outlets"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stock_balances" ADD CONSTRAINT "stock_balances_stockItemId_fkey" FOREIGN KEY ("stockItemId") REFERENCES "stock_items"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stock_movements" ADD CONSTRAINT "stock_movements_outletId_fkey" FOREIGN KEY ("outletId") REFERENCES "outlets"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stock_movements" ADD CONSTRAINT "stock_movements_stockItemId_fkey" FOREIGN KEY ("stockItemId") REFERENCES "stock_items"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stock_movements" ADD CONSTRAINT "stock_movements_actorId_fkey" FOREIGN KEY ("actorId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- Domain invariants enforced by the database as well as the service layer.
ALTER TABLE "stock_items"
    ADD CONSTRAINT "stock_items_quantityScale_check" CHECK ("quantityScale" >= 0 AND "quantityScale" <= 6),
    ADD CONSTRAINT "stock_items_reorderThreshold_check" CHECK ("reorderThreshold" >= 0);

ALTER TABLE "stock_balances"
    ADD CONSTRAINT "stock_balances_quantity_check" CHECK ("quantity" >= 0),
    ADD CONSTRAINT "stock_balances_version_check" CHECK ("version" >= 1);

-- Append-only ledger: rows may be inserted but never changed or removed.
CREATE OR REPLACE FUNCTION modern_pos_stock_movement_append_only()
RETURNS trigger AS $$
BEGIN
    RAISE EXCEPTION 'stock_movements is append-only';
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER stock_movements_no_update
    BEFORE UPDATE ON "stock_movements"
    FOR EACH ROW EXECUTE FUNCTION modern_pos_stock_movement_append_only();

CREATE TRIGGER stock_movements_no_delete
    BEFORE DELETE ON "stock_movements"
    FOR EACH ROW EXECUTE FUNCTION modern_pos_stock_movement_append_only();
