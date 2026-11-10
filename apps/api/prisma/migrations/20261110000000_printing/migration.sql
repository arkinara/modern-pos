-- Printing metadata: device-owned printer configuration and diagnostic copy of
-- the local print queue. Bytes and delivery remain device-side facts.

CREATE TYPE "PrinterTransport" AS ENUM ('BLUETOOTH', 'LAN', 'USB');
CREATE TYPE "PrintJobState" AS ENUM ('QUEUED', 'SENDING', 'SENT', 'FAILED', 'UNKNOWN');

CREATE TABLE "printers" (
    "id" UUID NOT NULL,
    "businessId" UUID NOT NULL,
    "outletId" UUID NOT NULL,
    "deviceId" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "model" TEXT NOT NULL,
    "transport" "PrinterTransport" NOT NULL,
    "paperWidthMm" INTEGER NOT NULL,
    "encoding" TEXT NOT NULL,
    "connectionSettings" JSONB NOT NULL DEFAULT '{}',
    "revision" INTEGER NOT NULL DEFAULT 1,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "printers_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "print_jobs" (
    "id" UUID NOT NULL,
    "businessId" UUID NOT NULL,
    "outletId" UUID NOT NULL,
    "saleId" UUID NOT NULL,
    "deviceId" UUID NOT NULL,
    "printerConfigId" UUID NOT NULL,
    "idempotencyKey" UUID NOT NULL,
    "state" "PrintJobState" NOT NULL DEFAULT 'QUEUED',
    "copy" BOOLEAN NOT NULL DEFAULT false,
    "attempts" INTEGER NOT NULL DEFAULT 0,
    "lastError" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "print_jobs_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "printers_outletId_deviceId_name_key" ON "printers"("outletId", "deviceId", "name");
CREATE INDEX "printers_outletId_deviceId_idx" ON "printers"("outletId", "deviceId");
CREATE UNIQUE INDEX "print_jobs_outletId_deviceId_idempotencyKey_key" ON "print_jobs"("outletId", "deviceId", "idempotencyKey");
CREATE INDEX "print_jobs_saleId_idx" ON "print_jobs"("saleId");
CREATE INDEX "print_jobs_outletId_deviceId_idx" ON "print_jobs"("outletId", "deviceId");

ALTER TABLE "printers" ADD CONSTRAINT "printers_businessId_fkey" FOREIGN KEY ("businessId") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "printers" ADD CONSTRAINT "printers_outletId_fkey" FOREIGN KEY ("outletId") REFERENCES "outlets"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "print_jobs" ADD CONSTRAINT "print_jobs_businessId_fkey" FOREIGN KEY ("businessId") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "print_jobs" ADD CONSTRAINT "print_jobs_outletId_fkey" FOREIGN KEY ("outletId") REFERENCES "outlets"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "print_jobs" ADD CONSTRAINT "print_jobs_saleId_fkey" FOREIGN KEY ("saleId") REFERENCES "sales"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "print_jobs" ADD CONSTRAINT "print_jobs_printerConfigId_fkey" FOREIGN KEY ("printerConfigId") REFERENCES "printers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
