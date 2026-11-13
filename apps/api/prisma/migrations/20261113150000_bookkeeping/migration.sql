-- CreateEnum
CREATE TYPE "CostingMethod" AS ENUM ('MOVING_AVERAGE', 'LAST_PURCHASE');

-- CreateTable
CREATE TABLE "bookkeeping_settings" (
    "id" UUID NOT NULL,
    "businessId" UUID NOT NULL,
    "outletId" UUID NOT NULL,
    "costingMethod" "CostingMethod" NOT NULL,
    "version" INTEGER NOT NULL DEFAULT 1,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "bookkeeping_settings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "expense_categories" (
    "id" UUID NOT NULL,
    "businessId" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "active" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "expense_categories_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "expenses" (
    "id" UUID NOT NULL,
    "businessId" UUID NOT NULL,
    "outletId" UUID NOT NULL,
    "categoryId" UUID NOT NULL,
    "amountMinor" BIGINT NOT NULL,
    "incurredOn" DATE NOT NULL,
    "note" TEXT NOT NULL DEFAULT '',
    "createdById" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "expenses_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "bookkeeping_settings_outletId_key" ON "bookkeeping_settings"("outletId");

-- CreateIndex
CREATE INDEX "bookkeeping_settings_businessId_idx" ON "bookkeeping_settings"("businessId");

-- CreateIndex
CREATE UNIQUE INDEX "expense_categories_businessId_name_key" ON "expense_categories"("businessId", "name");

-- CreateIndex
CREATE INDEX "expense_categories_businessId_active_idx" ON "expense_categories"("businessId", "active");

-- CreateIndex
CREATE INDEX "expenses_outletId_incurredOn_idx" ON "expenses"("outletId", "incurredOn");

-- CreateIndex
CREATE INDEX "expenses_businessId_outletId_incurredOn_idx" ON "expenses"("businessId", "outletId", "incurredOn");

-- AddForeignKey
ALTER TABLE "bookkeeping_settings" ADD CONSTRAINT "bookkeeping_settings_businessId_fkey" FOREIGN KEY ("businessId") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "bookkeeping_settings" ADD CONSTRAINT "bookkeeping_settings_outletId_fkey" FOREIGN KEY ("outletId") REFERENCES "outlets"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "expense_categories" ADD CONSTRAINT "expense_categories_businessId_fkey" FOREIGN KEY ("businessId") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "expenses" ADD CONSTRAINT "expenses_businessId_fkey" FOREIGN KEY ("businessId") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "expenses" ADD CONSTRAINT "expenses_outletId_fkey" FOREIGN KEY ("outletId") REFERENCES "outlets"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "expenses" ADD CONSTRAINT "expenses_categoryId_fkey" FOREIGN KEY ("categoryId") REFERENCES "expense_categories"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "expenses" ADD CONSTRAINT "expenses_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
