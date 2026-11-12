-- CreateEnum
CREATE TYPE "SaleReversalKind" AS ENUM ('FULL', 'PARTIAL');

-- CreateEnum
CREATE TYPE "PromotionKind" AS ENUM ('PERCENTAGE', 'FIXED_AMOUNT');

-- CreateEnum
CREATE TYPE "PromotionStacking" AS ENUM ('EXCLUSIVE', 'STACKABLE');

-- CreateEnum
CREATE TYPE "ApprovalAction" AS ENUM ('DISCOUNT', 'REFUND');

-- AlterEnum
-- This migration adds more than one value to an enum.
-- With PostgreSQL versions 11 and earlier, this is not possible
-- in a single migration. This can be worked around by creating
-- multiple migrations, each migration adding only one value to
-- the enum.


ALTER TYPE "OrderAuditAction" ADD VALUE 'PROMOTION';
ALTER TYPE "OrderAuditAction" ADD VALUE 'APPROVAL';
ALTER TYPE "OrderAuditAction" ADD VALUE 'REFUND';

-- DropIndex
DROP INDEX "sale_reversals_saleId_key";

-- AlterTable
ALTER TABLE "order_lines" ADD COLUMN     "modifiers" JSONB NOT NULL DEFAULT '[]';

-- AlterTable
ALTER TABLE "quotes" ADD COLUMN     "customerEmail" TEXT,
ADD COLUMN     "discountMinor" BIGINT NOT NULL DEFAULT 0,
ADD COLUMN     "promotions" JSONB NOT NULL DEFAULT '[]';

-- AlterTable
ALTER TABLE "sale_lines" ADD COLUMN     "modifiers" JSONB NOT NULL DEFAULT '[]';

-- AlterTable
ALTER TABLE "sale_reversals" ADD COLUMN     "kind" "SaleReversalKind" NOT NULL DEFAULT 'FULL',
ADD COLUMN     "lines" JSONB NOT NULL DEFAULT '[]',
ADD COLUMN     "refundMinor" BIGINT NOT NULL DEFAULT 0;

-- AlterTable
ALTER TABLE "sales" ADD COLUMN     "discountMinor" BIGINT NOT NULL DEFAULT 0,
ADD COLUMN     "promotions" JSONB NOT NULL DEFAULT '[]';

-- CreateTable
CREATE TABLE "menu_item_modifiers" (
    "id" UUID NOT NULL,
    "businessId" UUID NOT NULL,
    "menuItemId" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "priceDeltaMinor" BIGINT NOT NULL DEFAULT 0,
    "stockItemId" UUID,
    "quantityPerSaleUnit" DECIMAL(20,6),
    "active" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "outletId" UUID,

    CONSTRAINT "menu_item_modifiers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "sale_refund_lines" (
    "id" UUID NOT NULL,
    "reversalId" UUID NOT NULL,
    "saleLineId" UUID NOT NULL,
    "quantity" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "sale_refund_lines_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "promotions" (
    "id" UUID NOT NULL,
    "businessId" UUID NOT NULL,
    "outletId" UUID,
    "name" TEXT NOT NULL,
    "kind" "PromotionKind" NOT NULL,
    "percentageBps" INTEGER,
    "amountMinor" BIGINT,
    "minBasketMinor" BIGINT NOT NULL DEFAULT 0,
    "startsAt" TIMESTAMP(3),
    "endsAt" TIMESTAMP(3),
    "active" BOOLEAN NOT NULL DEFAULT true,
    "stacking" "PromotionStacking" NOT NULL DEFAULT 'EXCLUSIVE',
    "priority" INTEGER NOT NULL DEFAULT 0,
    "eligibility" JSONB NOT NULL DEFAULT '{}',
    "revision" INTEGER NOT NULL DEFAULT 1,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "promotions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "approval_rules" (
    "id" UUID NOT NULL,
    "businessId" UUID NOT NULL,
    "outletId" UUID NOT NULL,
    "action" "ApprovalAction" NOT NULL,
    "thresholdMinor" BIGINT NOT NULL DEFAULT 0,
    "active" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "approval_rules_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "menu_item_modifiers_menuItemId_active_idx" ON "menu_item_modifiers"("menuItemId", "active");

-- CreateIndex
CREATE INDEX "menu_item_modifiers_businessId_idx" ON "menu_item_modifiers"("businessId");

-- CreateIndex
CREATE INDEX "sale_refund_lines_saleLineId_idx" ON "sale_refund_lines"("saleLineId");

-- CreateIndex
CREATE UNIQUE INDEX "sale_refund_lines_reversalId_saleLineId_key" ON "sale_refund_lines"("reversalId", "saleLineId");

-- CreateIndex
CREATE INDEX "promotions_businessId_outletId_active_idx" ON "promotions"("businessId", "outletId", "active");

-- CreateIndex
CREATE UNIQUE INDEX "approval_rules_outletId_action_key" ON "approval_rules"("outletId", "action");

-- CreateIndex
CREATE INDEX "sale_reversals_saleId_createdAt_idx" ON "sale_reversals"("saleId", "createdAt");

-- AddForeignKey
ALTER TABLE "menu_item_modifiers" ADD CONSTRAINT "menu_item_modifiers_businessId_fkey" FOREIGN KEY ("businessId") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "menu_item_modifiers" ADD CONSTRAINT "menu_item_modifiers_menuItemId_fkey" FOREIGN KEY ("menuItemId") REFERENCES "menu_items"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "menu_item_modifiers" ADD CONSTRAINT "menu_item_modifiers_stockItemId_fkey" FOREIGN KEY ("stockItemId") REFERENCES "stock_items"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "menu_item_modifiers" ADD CONSTRAINT "menu_item_modifiers_outletId_fkey" FOREIGN KEY ("outletId") REFERENCES "outlets"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sale_refund_lines" ADD CONSTRAINT "sale_refund_lines_reversalId_fkey" FOREIGN KEY ("reversalId") REFERENCES "sale_reversals"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sale_refund_lines" ADD CONSTRAINT "sale_refund_lines_saleLineId_fkey" FOREIGN KEY ("saleLineId") REFERENCES "sale_lines"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "promotions" ADD CONSTRAINT "promotions_businessId_fkey" FOREIGN KEY ("businessId") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "promotions" ADD CONSTRAINT "promotions_outletId_fkey" FOREIGN KEY ("outletId") REFERENCES "outlets"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "approval_rules" ADD CONSTRAINT "approval_rules_businessId_fkey" FOREIGN KEY ("businessId") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "approval_rules" ADD CONSTRAINT "approval_rules_outletId_fkey" FOREIGN KEY ("outletId") REFERENCES "outlets"("id") ON DELETE CASCADE ON UPDATE CASCADE;
