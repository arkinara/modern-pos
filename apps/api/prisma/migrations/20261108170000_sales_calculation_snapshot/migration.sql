-- Persist the calculation rules used to price a quote and a completed sale so
-- later outlet settings changes cannot rewrite historical receipts.

-- AlterTable
ALTER TABLE "quotes" ADD COLUMN "taxBps" INTEGER NOT NULL DEFAULT 0;
ALTER TABLE "quotes" ADD COLUMN "serviceBps" INTEGER NOT NULL DEFAULT 0;
ALTER TABLE "quotes" ADD COLUMN "pricingMode" TEXT NOT NULL DEFAULT 'EXCLUSIVE';
ALTER TABLE "quotes" ADD COLUMN "rounding" TEXT NOT NULL DEFAULT 'HALF_UP';

-- AlterTable
ALTER TABLE "sales" ADD COLUMN "taxBps" INTEGER NOT NULL DEFAULT 0;
ALTER TABLE "sales" ADD COLUMN "serviceBps" INTEGER NOT NULL DEFAULT 0;
ALTER TABLE "sales" ADD COLUMN "pricingMode" TEXT NOT NULL DEFAULT 'EXCLUSIVE';
ALTER TABLE "sales" ADD COLUMN "rounding" TEXT NOT NULL DEFAULT 'HALF_UP';
