-- CreateEnum
CREATE TYPE "OrderChannel" AS ENUM ('MANUAL', 'PHONE', 'WEB', 'GRABFOOD', 'SHOPEEFOOD');

-- CreateEnum
CREATE TYPE "ChannelOrderState" AS ENUM ('RECEIVED', 'ACCEPTED', 'FULFILLED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "ChannelPaymentMode" AS ENUM ('CASH_ON_PICKUP', 'PREPAID_PROVIDER');

-- CreateEnum
CREATE TYPE "ChannelPaymentStatus" AS ENUM ('UNPAID', 'PAID');

-- CreateEnum
CREATE TYPE "CustomerConsentSource" AS ENUM ('WEB_CHECKOUT', 'STAFF_ENTRY', 'IMPORT');

-- CreateEnum
CREATE TYPE "CustomerContactType" AS ENUM ('EMAIL', 'PHONE');

-- AlterEnum
-- This migration adds more than one value to an enum.
-- With PostgreSQL versions 11 and earlier, this is not possible
-- in a single migration. This can be worked around by creating
-- multiple migrations, each migration adding only one value to
-- the enum.


ALTER TYPE "StockMovementType" ADD VALUE 'CHANNEL_ORDER_ACCEPT';
ALTER TYPE "StockMovementType" ADD VALUE 'CHANNEL_ORDER_CANCEL';

-- CreateTable
CREATE TABLE "customers" (
    "id" UUID NOT NULL,
    "businessId" UUID NOT NULL,
    "outletId" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "contactType" "CustomerContactType" NOT NULL,
    "contactNormalized" TEXT NOT NULL,
    "email" TEXT,
    "phone" TEXT,
    "consentAt" TIMESTAMP(3) NOT NULL,
    "consentSource" "CustomerConsentSource" NOT NULL,
    "anonymizedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "customers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "customer_retention_policies" (
    "id" UUID NOT NULL,
    "businessId" UUID NOT NULL,
    "outletId" UUID NOT NULL,
    "customerRetentionDays" INTEGER NOT NULL DEFAULT 365,
    "receiptRetentionDays" INTEGER NOT NULL DEFAULT 90,
    "receiptLinkTtlMinutes" INTEGER NOT NULL DEFAULT 1440,
    "version" INTEGER NOT NULL DEFAULT 1,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "customer_retention_policies_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "channel_orders" (
    "id" UUID NOT NULL,
    "businessId" UUID NOT NULL,
    "outletId" UUID NOT NULL,
    "channel" "OrderChannel" NOT NULL,
    "channelReference" TEXT NOT NULL,
    "requestHash" TEXT NOT NULL,
    "state" "ChannelOrderState" NOT NULL DEFAULT 'RECEIVED',
    "paymentMode" "ChannelPaymentMode" NOT NULL DEFAULT 'CASH_ON_PICKUP',
    "paymentStatus" "ChannelPaymentStatus" NOT NULL DEFAULT 'UNPAID',
    "currency" VARCHAR(3) NOT NULL,
    "currencyExponent" INTEGER NOT NULL,
    "subtotalMinor" BIGINT NOT NULL,
    "serviceMinor" BIGINT NOT NULL DEFAULT 0,
    "taxMinor" BIGINT NOT NULL DEFAULT 0,
    "totalMinor" BIGINT NOT NULL,
    "note" TEXT NOT NULL DEFAULT '',
    "customerId" UUID,
    "acceptedAt" TIMESTAMP(3),
    "fulfilledAt" TIMESTAMP(3),
    "cancelledAt" TIMESTAMP(3),
    "cancellationReason" TEXT,
    "version" INTEGER NOT NULL DEFAULT 1,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "channel_orders_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "channel_order_lines" (
    "id" UUID NOT NULL,
    "orderId" UUID NOT NULL,
    "variantId" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "variantName" TEXT NOT NULL,
    "quantity" INTEGER NOT NULL,
    "unitPriceMinor" BIGINT NOT NULL,
    "lineSubtotalMinor" BIGINT NOT NULL,
    "recipeVersion" INTEGER,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "channel_order_lines_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "channel_order_payments" (
    "id" UUID NOT NULL,
    "orderId" UUID NOT NULL,
    "amountMinor" BIGINT NOT NULL,
    "status" "ChannelPaymentStatus" NOT NULL DEFAULT 'PAID',
    "method" "ChannelPaymentMode" NOT NULL,
    "reference" TEXT,
    "recordedById" UUID,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "channel_order_payments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "channel_order_events" (
    "id" UUID NOT NULL,
    "orderId" UUID NOT NULL,
    "fromState" "ChannelOrderState" NOT NULL,
    "toState" "ChannelOrderState" NOT NULL,
    "actorId" UUID,
    "reason" TEXT NOT NULL DEFAULT '',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "channel_order_events_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "digital_receipts" (
    "id" UUID NOT NULL,
    "businessId" UUID NOT NULL,
    "outletId" UUID NOT NULL,
    "saleId" UUID,
    "channelOrderId" UUID,
    "customerId" UUID,
    "receiptNumber" TEXT NOT NULL,
    "tokenHash" TEXT NOT NULL,
    "contentHtml" TEXT NOT NULL,
    "contentText" TEXT NOT NULL,
    "issuedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "purgedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "digital_receipts_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "customers_businessId_outletId_createdAt_idx" ON "customers"("businessId", "outletId", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "customers_outletId_contactNormalized_key" ON "customers"("outletId", "contactNormalized");

-- CreateIndex
CREATE UNIQUE INDEX "customer_retention_policies_outletId_key" ON "customer_retention_policies"("outletId");

-- CreateIndex
CREATE INDEX "customer_retention_policies_businessId_idx" ON "customer_retention_policies"("businessId");

-- CreateIndex
CREATE INDEX "channel_orders_outletId_state_createdAt_idx" ON "channel_orders"("outletId", "state", "createdAt");

-- CreateIndex
CREATE INDEX "channel_orders_outletId_channel_createdAt_idx" ON "channel_orders"("outletId", "channel", "createdAt");

-- CreateIndex
CREATE INDEX "channel_orders_customerId_idx" ON "channel_orders"("customerId");

-- CreateIndex
CREATE UNIQUE INDEX "channel_orders_businessId_channel_channelReference_key" ON "channel_orders"("businessId", "channel", "channelReference");

-- CreateIndex
CREATE INDEX "channel_order_lines_orderId_idx" ON "channel_order_lines"("orderId");

-- CreateIndex
CREATE UNIQUE INDEX "channel_order_payments_orderId_key" ON "channel_order_payments"("orderId");

-- CreateIndex
CREATE INDEX "channel_order_events_orderId_createdAt_idx" ON "channel_order_events"("orderId", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "digital_receipts_tokenHash_key" ON "digital_receipts"("tokenHash");

-- CreateIndex
CREATE INDEX "digital_receipts_outletId_createdAt_idx" ON "digital_receipts"("outletId", "createdAt");

-- CreateIndex
CREATE INDEX "digital_receipts_outletId_expiresAt_idx" ON "digital_receipts"("outletId", "expiresAt");

-- CreateIndex
CREATE INDEX "digital_receipts_saleId_idx" ON "digital_receipts"("saleId");

-- CreateIndex
CREATE UNIQUE INDEX "digital_receipts_businessId_receiptNumber_key" ON "digital_receipts"("businessId", "receiptNumber");

-- AddForeignKey
ALTER TABLE "customers" ADD CONSTRAINT "customers_businessId_fkey" FOREIGN KEY ("businessId") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "customers" ADD CONSTRAINT "customers_outletId_fkey" FOREIGN KEY ("outletId") REFERENCES "outlets"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "customer_retention_policies" ADD CONSTRAINT "customer_retention_policies_businessId_fkey" FOREIGN KEY ("businessId") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "customer_retention_policies" ADD CONSTRAINT "customer_retention_policies_outletId_fkey" FOREIGN KEY ("outletId") REFERENCES "outlets"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "channel_orders" ADD CONSTRAINT "channel_orders_businessId_fkey" FOREIGN KEY ("businessId") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "channel_orders" ADD CONSTRAINT "channel_orders_outletId_fkey" FOREIGN KEY ("outletId") REFERENCES "outlets"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "channel_orders" ADD CONSTRAINT "channel_orders_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES "customers"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "channel_order_lines" ADD CONSTRAINT "channel_order_lines_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES "channel_orders"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "channel_order_payments" ADD CONSTRAINT "channel_order_payments_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES "channel_orders"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "channel_order_events" ADD CONSTRAINT "channel_order_events_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES "channel_orders"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "digital_receipts" ADD CONSTRAINT "digital_receipts_businessId_fkey" FOREIGN KEY ("businessId") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "digital_receipts" ADD CONSTRAINT "digital_receipts_outletId_fkey" FOREIGN KEY ("outletId") REFERENCES "outlets"("id") ON DELETE CASCADE ON UPDATE CASCADE;

