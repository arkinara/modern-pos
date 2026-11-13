-- CreateEnum
CREATE TYPE "StationKind" AS ENUM ('KITCHEN', 'BAR', 'COLD', 'HOT', 'OTHER');

-- CreateEnum
CREATE TYPE "StationJobKind" AS ENUM ('ORIGINAL', 'AMEND', 'CANCEL');

-- CreateTable
CREATE TABLE "stations" (
    "id" UUID NOT NULL,
    "businessId" UUID NOT NULL,
    "outletId" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "kind" "StationKind" NOT NULL DEFAULT 'KITCHEN',
    "isDefault" BOOLEAN NOT NULL DEFAULT false,
    "printerConfigId" UUID,
    "sortOrder" INTEGER NOT NULL DEFAULT 0,
    "revision" INTEGER NOT NULL DEFAULT 1,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "stations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "station_routes" (
    "id" UUID NOT NULL,
    "businessId" UUID NOT NULL,
    "outletId" UUID NOT NULL,
    "stationId" UUID NOT NULL,
    "menuItemId" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "station_routes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "station_jobs" (
    "id" UUID NOT NULL,
    "businessId" UUID NOT NULL,
    "outletId" UUID NOT NULL,
    "stationId" UUID NOT NULL,
    "orderId" UUID NOT NULL,
    "saleId" UUID,
    "variantId" UUID NOT NULL,
    "orderReference" TEXT NOT NULL,
    "kind" "StationJobKind" NOT NULL DEFAULT 'ORIGINAL',
    "state" "PrintJobState" NOT NULL DEFAULT 'QUEUED',
    "copy" BOOLEAN NOT NULL DEFAULT false,
    "reprintOfId" UUID,
    "itemName" TEXT NOT NULL,
    "variantName" TEXT NOT NULL,
    "quantity" INTEGER NOT NULL,
    "modifiers" JSONB NOT NULL DEFAULT '[]',
    "attempts" INTEGER NOT NULL DEFAULT 0,
    "lastError" TEXT,
    "printerConfigId" UUID,
    "idempotencyKey" UUID NOT NULL,
    "lineIndex" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "station_jobs_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "stations_outletId_isDefault_idx" ON "stations"("outletId", "isDefault");

-- CreateIndex
CREATE UNIQUE INDEX "stations_outletId_name_key" ON "stations"("outletId", "name");

-- CreateIndex
CREATE INDEX "station_routes_stationId_idx" ON "station_routes"("stationId");

-- CreateIndex
CREATE UNIQUE INDEX "station_routes_outletId_menuItemId_key" ON "station_routes"("outletId", "menuItemId");

-- CreateIndex
CREATE INDEX "station_jobs_stationId_state_createdAt_idx" ON "station_jobs"("stationId", "state", "createdAt");

-- CreateIndex
CREATE INDEX "station_jobs_orderId_idx" ON "station_jobs"("orderId");

-- CreateIndex
CREATE INDEX "station_jobs_saleId_idx" ON "station_jobs"("saleId");

-- CreateIndex
CREATE UNIQUE INDEX "station_jobs_outletId_idempotencyKey_lineIndex_key" ON "station_jobs"("outletId", "idempotencyKey", "lineIndex");

-- AddForeignKey
ALTER TABLE "stations" ADD CONSTRAINT "stations_businessId_fkey" FOREIGN KEY ("businessId") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stations" ADD CONSTRAINT "stations_outletId_fkey" FOREIGN KEY ("outletId") REFERENCES "outlets"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stations" ADD CONSTRAINT "stations_printerConfigId_fkey" FOREIGN KEY ("printerConfigId") REFERENCES "printers"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "station_routes" ADD CONSTRAINT "station_routes_businessId_fkey" FOREIGN KEY ("businessId") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "station_routes" ADD CONSTRAINT "station_routes_outletId_fkey" FOREIGN KEY ("outletId") REFERENCES "outlets"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "station_routes" ADD CONSTRAINT "station_routes_stationId_fkey" FOREIGN KEY ("stationId") REFERENCES "stations"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "station_routes" ADD CONSTRAINT "station_routes_menuItemId_fkey" FOREIGN KEY ("menuItemId") REFERENCES "menu_items"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "station_jobs" ADD CONSTRAINT "station_jobs_businessId_fkey" FOREIGN KEY ("businessId") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "station_jobs" ADD CONSTRAINT "station_jobs_outletId_fkey" FOREIGN KEY ("outletId") REFERENCES "outlets"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "station_jobs" ADD CONSTRAINT "station_jobs_stationId_fkey" FOREIGN KEY ("stationId") REFERENCES "stations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "station_jobs" ADD CONSTRAINT "station_jobs_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES "orders"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "station_jobs" ADD CONSTRAINT "station_jobs_saleId_fkey" FOREIGN KEY ("saleId") REFERENCES "sales"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "station_jobs" ADD CONSTRAINT "station_jobs_variantId_fkey" FOREIGN KEY ("variantId") REFERENCES "menu_variants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "station_jobs" ADD CONSTRAINT "station_jobs_printerConfigId_fkey" FOREIGN KEY ("printerConfigId") REFERENCES "printers"("id") ON DELETE SET NULL ON UPDATE CASCADE;

