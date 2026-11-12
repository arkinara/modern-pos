-- CreateEnum
CREATE TYPE "PurchaseOrderState" AS ENUM ('OPEN', 'PARTIALLY_RECEIVED', 'RECEIVED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "WasteReason" AS ENUM ('DAMAGE', 'EXPIRY', 'THEFT', 'SPOILAGE', 'OTHER');

-- CreateEnum
CREATE TYPE "TransferState" AS ENUM ('DRAFT', 'DISPATCHED', 'RECEIVED', 'CANCELLED');

-- AlterEnum
-- This migration adds more than one value to an enum.
-- With PostgreSQL versions 11 and earlier, this is not possible
-- in a single migration. This can be worked around by creating
-- multiple migrations, each migration adding only one value to
-- the enum.


ALTER TYPE "StockMovementType" ADD VALUE 'COUNT';
ALTER TYPE "StockMovementType" ADD VALUE 'WASTE';
ALTER TYPE "StockMovementType" ADD VALUE 'TRANSFER_OUT';
ALTER TYPE "StockMovementType" ADD VALUE 'TRANSFER_IN';
ALTER TYPE "StockMovementType" ADD VALUE 'TRANSFER_CANCEL';

-- AlterTable
ALTER TABLE "stock_movements" ADD COLUMN     "purchaseOrderId" UUID,
ADD COLUMN     "stockCountId" UUID,
ADD COLUMN     "stockWasteId" UUID,
ADD COLUMN     "supplierId" UUID,
ADD COLUMN     "transferId" UUID;

-- CreateTable
CREATE TABLE "suppliers" (
    "id" UUID NOT NULL,
    "businessId" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "reference" TEXT,
    "contact" TEXT,
    "archivedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "suppliers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "purchase_orders" (
    "id" UUID NOT NULL,
    "businessId" UUID NOT NULL,
    "outletId" UUID NOT NULL,
    "supplierId" UUID NOT NULL,
    "reference" TEXT NOT NULL,
    "state" "PurchaseOrderState" NOT NULL DEFAULT 'OPEN',
    "createdById" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "closedAt" TIMESTAMP(3),

    CONSTRAINT "purchase_orders_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "purchase_order_lines" (
    "id" UUID NOT NULL,
    "purchaseOrderId" UUID NOT NULL,
    "stockItemId" UUID NOT NULL,
    "supplierUnit" TEXT NOT NULL,
    "unitsPerSupplierUnit" DECIMAL(20,6) NOT NULL,
    "orderedSupplierQuantity" DECIMAL(20,6) NOT NULL,
    "receivedSupplierQuantity" DECIMAL(20,6) NOT NULL DEFAULT 0,
    "orderedBaseQuantity" DECIMAL(20,6) NOT NULL,
    "receivedBaseQuantity" DECIMAL(20,6) NOT NULL DEFAULT 0,
    "unitPrice" DECIMAL(20,6) NOT NULL,
    "version" INTEGER NOT NULL DEFAULT 1,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "purchase_order_lines_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "stock_counts" (
    "id" UUID NOT NULL,
    "businessId" UUID NOT NULL,
    "outletId" UUID NOT NULL,
    "reference" TEXT NOT NULL,
    "reason" TEXT NOT NULL,
    "actorId" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "stock_counts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "stock_count_lines" (
    "id" UUID NOT NULL,
    "stockCountId" UUID NOT NULL,
    "stockItemId" UUID NOT NULL,
    "systemQuantity" DECIMAL(20,6) NOT NULL,
    "countedQuantity" DECIMAL(20,6) NOT NULL,
    "variance" DECIMAL(20,6) NOT NULL,

    CONSTRAINT "stock_count_lines_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "stock_wastes" (
    "id" UUID NOT NULL,
    "businessId" UUID NOT NULL,
    "outletId" UUID NOT NULL,
    "stockItemId" UUID NOT NULL,
    "quantity" DECIMAL(20,6) NOT NULL,
    "reason" "WasteReason" NOT NULL,
    "note" TEXT,
    "actorId" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "stock_wastes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "outlet_transfers" (
    "id" UUID NOT NULL,
    "businessId" UUID NOT NULL,
    "sourceOutletId" UUID NOT NULL,
    "destinationOutletId" UUID NOT NULL,
    "reference" TEXT NOT NULL,
    "note" TEXT,
    "state" "TransferState" NOT NULL DEFAULT 'DRAFT',
    "createdById" UUID NOT NULL,
    "dispatchedById" UUID,
    "receivedById" UUID,
    "cancelledById" UUID,
    "version" INTEGER NOT NULL DEFAULT 1,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "dispatchedAt" TIMESTAMP(3),
    "receivedAt" TIMESTAMP(3),
    "cancelledAt" TIMESTAMP(3),

    CONSTRAINT "outlet_transfers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "outlet_transfer_lines" (
    "id" UUID NOT NULL,
    "transferId" UUID NOT NULL,
    "stockItemId" UUID NOT NULL,
    "dispatchedQuantity" DECIMAL(20,6) NOT NULL,
    "receivedQuantity" DECIMAL(20,6) NOT NULL DEFAULT 0,
    "version" INTEGER NOT NULL DEFAULT 1,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "outlet_transfer_lines_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "suppliers_businessId_archivedAt_idx" ON "suppliers"("businessId", "archivedAt");

-- CreateIndex
CREATE UNIQUE INDEX "suppliers_businessId_reference_key" ON "suppliers"("businessId", "reference");

-- CreateIndex
CREATE INDEX "purchase_orders_businessId_outletId_state_idx" ON "purchase_orders"("businessId", "outletId", "state");

-- CreateIndex
CREATE UNIQUE INDEX "purchase_orders_businessId_reference_key" ON "purchase_orders"("businessId", "reference");

-- CreateIndex
CREATE INDEX "purchase_order_lines_purchaseOrderId_idx" ON "purchase_order_lines"("purchaseOrderId");

-- CreateIndex
CREATE INDEX "purchase_order_lines_stockItemId_idx" ON "purchase_order_lines"("stockItemId");

-- CreateIndex
CREATE INDEX "stock_counts_outletId_createdAt_idx" ON "stock_counts"("outletId", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "stock_counts_businessId_reference_key" ON "stock_counts"("businessId", "reference");

-- CreateIndex
CREATE INDEX "stock_count_lines_stockItemId_idx" ON "stock_count_lines"("stockItemId");

-- CreateIndex
CREATE UNIQUE INDEX "stock_count_lines_stockCountId_stockItemId_key" ON "stock_count_lines"("stockCountId", "stockItemId");

-- CreateIndex
CREATE INDEX "stock_wastes_outletId_createdAt_idx" ON "stock_wastes"("outletId", "createdAt");

-- CreateIndex
CREATE INDEX "outlet_transfers_businessId_sourceOutletId_state_idx" ON "outlet_transfers"("businessId", "sourceOutletId", "state");

-- CreateIndex
CREATE INDEX "outlet_transfers_businessId_destinationOutletId_state_idx" ON "outlet_transfers"("businessId", "destinationOutletId", "state");

-- CreateIndex
CREATE UNIQUE INDEX "outlet_transfers_businessId_reference_key" ON "outlet_transfers"("businessId", "reference");

-- CreateIndex
CREATE INDEX "outlet_transfer_lines_stockItemId_idx" ON "outlet_transfer_lines"("stockItemId");

-- CreateIndex
CREATE UNIQUE INDEX "outlet_transfer_lines_transferId_stockItemId_key" ON "outlet_transfer_lines"("transferId", "stockItemId");

-- CreateIndex
CREATE INDEX "stock_movements_outletId_createdAt_idx" ON "stock_movements"("outletId", "createdAt");

-- CreateIndex
CREATE INDEX "stock_movements_supplierId_createdAt_idx" ON "stock_movements"("supplierId", "createdAt");

-- AddForeignKey
ALTER TABLE "stock_movements" ADD CONSTRAINT "stock_movements_supplierId_fkey" FOREIGN KEY ("supplierId") REFERENCES "suppliers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stock_movements" ADD CONSTRAINT "stock_movements_purchaseOrderId_fkey" FOREIGN KEY ("purchaseOrderId") REFERENCES "purchase_orders"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stock_movements" ADD CONSTRAINT "stock_movements_transferId_fkey" FOREIGN KEY ("transferId") REFERENCES "outlet_transfers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stock_movements" ADD CONSTRAINT "stock_movements_stockCountId_fkey" FOREIGN KEY ("stockCountId") REFERENCES "stock_counts"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stock_movements" ADD CONSTRAINT "stock_movements_stockWasteId_fkey" FOREIGN KEY ("stockWasteId") REFERENCES "stock_wastes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "suppliers" ADD CONSTRAINT "suppliers_businessId_fkey" FOREIGN KEY ("businessId") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "purchase_orders" ADD CONSTRAINT "purchase_orders_businessId_fkey" FOREIGN KEY ("businessId") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "purchase_orders" ADD CONSTRAINT "purchase_orders_outletId_fkey" FOREIGN KEY ("outletId") REFERENCES "outlets"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "purchase_orders" ADD CONSTRAINT "purchase_orders_supplierId_fkey" FOREIGN KEY ("supplierId") REFERENCES "suppliers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "purchase_orders" ADD CONSTRAINT "purchase_orders_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "purchase_order_lines" ADD CONSTRAINT "purchase_order_lines_purchaseOrderId_fkey" FOREIGN KEY ("purchaseOrderId") REFERENCES "purchase_orders"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "purchase_order_lines" ADD CONSTRAINT "purchase_order_lines_stockItemId_fkey" FOREIGN KEY ("stockItemId") REFERENCES "stock_items"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stock_counts" ADD CONSTRAINT "stock_counts_businessId_fkey" FOREIGN KEY ("businessId") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stock_counts" ADD CONSTRAINT "stock_counts_outletId_fkey" FOREIGN KEY ("outletId") REFERENCES "outlets"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stock_counts" ADD CONSTRAINT "stock_counts_actorId_fkey" FOREIGN KEY ("actorId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stock_count_lines" ADD CONSTRAINT "stock_count_lines_stockCountId_fkey" FOREIGN KEY ("stockCountId") REFERENCES "stock_counts"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stock_count_lines" ADD CONSTRAINT "stock_count_lines_stockItemId_fkey" FOREIGN KEY ("stockItemId") REFERENCES "stock_items"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stock_wastes" ADD CONSTRAINT "stock_wastes_businessId_fkey" FOREIGN KEY ("businessId") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stock_wastes" ADD CONSTRAINT "stock_wastes_outletId_fkey" FOREIGN KEY ("outletId") REFERENCES "outlets"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stock_wastes" ADD CONSTRAINT "stock_wastes_stockItemId_fkey" FOREIGN KEY ("stockItemId") REFERENCES "stock_items"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stock_wastes" ADD CONSTRAINT "stock_wastes_actorId_fkey" FOREIGN KEY ("actorId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "outlet_transfers" ADD CONSTRAINT "outlet_transfers_businessId_fkey" FOREIGN KEY ("businessId") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "outlet_transfers" ADD CONSTRAINT "outlet_transfers_sourceOutletId_fkey" FOREIGN KEY ("sourceOutletId") REFERENCES "outlets"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "outlet_transfers" ADD CONSTRAINT "outlet_transfers_destinationOutletId_fkey" FOREIGN KEY ("destinationOutletId") REFERENCES "outlets"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "outlet_transfers" ADD CONSTRAINT "outlet_transfers_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "outlet_transfers" ADD CONSTRAINT "outlet_transfers_dispatchedById_fkey" FOREIGN KEY ("dispatchedById") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "outlet_transfers" ADD CONSTRAINT "outlet_transfers_receivedById_fkey" FOREIGN KEY ("receivedById") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "outlet_transfers" ADD CONSTRAINT "outlet_transfers_cancelledById_fkey" FOREIGN KEY ("cancelledById") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "outlet_transfer_lines" ADD CONSTRAINT "outlet_transfer_lines_transferId_fkey" FOREIGN KEY ("transferId") REFERENCES "outlet_transfers"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "outlet_transfer_lines" ADD CONSTRAINT "outlet_transfer_lines_stockItemId_fkey" FOREIGN KEY ("stockItemId") REFERENCES "stock_items"("id") ON DELETE RESTRICT ON UPDATE CASCADE;


-- Domain invariants enforced at the database boundary as well as in services.
ALTER TABLE "purchase_order_lines"
    ADD CONSTRAINT "purchase_order_lines_conversion_check" CHECK (
        "unitsPerSupplierUnit" > 0
        AND "orderedSupplierQuantity" > 0
        AND "receivedSupplierQuantity" >= 0
        AND "receivedSupplierQuantity" <= "orderedSupplierQuantity"
        AND "orderedBaseQuantity" > 0
        AND "receivedBaseQuantity" >= 0
        AND "receivedBaseQuantity" <= "orderedBaseQuantity"
        AND "unitPrice" >= 0
        AND "version" >= 1
    );

ALTER TABLE "purchase_orders"
    ADD CONSTRAINT "purchase_orders_state_closed_check" CHECK (
        ("state" = 'RECEIVED' AND "closedAt" IS NOT NULL)
        OR ("state" = 'CANCELLED' AND "closedAt" IS NOT NULL)
        OR ("state" IN ('OPEN', 'PARTIALLY_RECEIVED') AND "closedAt" IS NULL)
    );

ALTER TABLE "stock_count_lines"
    ADD CONSTRAINT "stock_count_lines_quantity_check" CHECK (
        "systemQuantity" >= 0
        AND "countedQuantity" >= 0
        AND "variance" = "countedQuantity" - "systemQuantity"
    );

ALTER TABLE "stock_wastes"
    ADD CONSTRAINT "stock_wastes_quantity_check" CHECK ("quantity" > 0);

ALTER TABLE "outlet_transfers"
    ADD CONSTRAINT "outlet_transfers_distinct_outlets_check" CHECK (
        "sourceOutletId" <> "destinationOutletId"
    ),
    ADD CONSTRAINT "outlet_transfers_version_check" CHECK ("version" >= 1);

ALTER TABLE "outlet_transfer_lines"
    ADD CONSTRAINT "outlet_transfer_lines_quantity_check" CHECK (
        "dispatchedQuantity" > 0
        AND "receivedQuantity" >= 0
        AND "receivedQuantity" <= "dispatchedQuantity"
        AND "version" >= 1
    );
