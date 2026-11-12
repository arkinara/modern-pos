-- CreateTable
CREATE TABLE "online_payments" (
    "id" UUID NOT NULL,
    "businessId" UUID NOT NULL,
    "outletId" UUID NOT NULL,
    "saleId" UUID NOT NULL,
    "provider" "PaymentProvider" NOT NULL,
    "providerRef" TEXT,
    "status" "PaymentStatus" NOT NULL DEFAULT 'PENDING',
    "amountMinor" BIGINT NOT NULL,
    "refundedMinor" BIGINT NOT NULL DEFAULT 0,
    "currency" VARCHAR(3) NOT NULL,
    "currencyExponent" INTEGER NOT NULL,
    "qrPayload" TEXT,
    "providerCreatedAt" TIMESTAMP(3),
    "settledAt" TIMESTAMP(3),
    "failedAt" TIMESTAMP(3),
    "lastError" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "online_payments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "payment_webhook_events" (
    "id" UUID NOT NULL,
    "provider" "PaymentProvider" NOT NULL,
    "eventId" TEXT NOT NULL,
    "eventType" TEXT NOT NULL,
    "onlinePaymentId" UUID,
    "payload" JSONB NOT NULL,
    "receivedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "processedAt" TIMESTAMP(3),

    CONSTRAINT "payment_webhook_events_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "sandbox_provider_payments" (
    "id" UUID NOT NULL,
    "providerRef" TEXT NOT NULL,
    "idempotencyKey" TEXT NOT NULL,
    "amountMinor" BIGINT NOT NULL,
    "refundedMinor" BIGINT NOT NULL DEFAULT 0,
    "currency" VARCHAR(3) NOT NULL,
    "status" "PaymentStatus" NOT NULL DEFAULT 'PENDING',
    "refundKeys" JSONB NOT NULL DEFAULT '[]',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "sandbox_provider_payments_pkey" PRIMARY KEY ("id")
);

-- AlterTable
ALTER TABLE "sale_reversals" ADD COLUMN "providerRefundRef" TEXT;

-- CreateIndex
CREATE UNIQUE INDEX "online_payments_saleId_key" ON "online_payments"("saleId");

-- CreateIndex
CREATE UNIQUE INDEX "online_payments_providerRef_key" ON "online_payments"("providerRef");

-- CreateIndex
CREATE INDEX "online_payments_businessId_outletId_status_idx" ON "online_payments"("businessId", "outletId", "status");

-- CreateIndex
CREATE INDEX "online_payments_provider_status_idx" ON "online_payments"("provider", "status");

-- CreateIndex
CREATE UNIQUE INDEX "payment_webhook_events_provider_eventId_key" ON "payment_webhook_events"("provider", "eventId");

-- CreateIndex
CREATE INDEX "payment_webhook_events_onlinePaymentId_idx" ON "payment_webhook_events"("onlinePaymentId");

-- CreateIndex
CREATE UNIQUE INDEX "sandbox_provider_payments_providerRef_key" ON "sandbox_provider_payments"("providerRef");

-- CreateIndex
CREATE UNIQUE INDEX "sandbox_provider_payments_idempotencyKey_key" ON "sandbox_provider_payments"("idempotencyKey");

-- AddForeignKey
ALTER TABLE "online_payments" ADD CONSTRAINT "online_payments_businessId_fkey" FOREIGN KEY ("businessId") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "online_payments" ADD CONSTRAINT "online_payments_outletId_fkey" FOREIGN KEY ("outletId") REFERENCES "outlets"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "online_payments" ADD CONSTRAINT "online_payments_saleId_fkey" FOREIGN KEY ("saleId") REFERENCES "sales"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payment_webhook_events" ADD CONSTRAINT "payment_webhook_events_onlinePaymentId_fkey" FOREIGN KEY ("onlinePaymentId") REFERENCES "online_payments"("id") ON DELETE SET NULL ON UPDATE CASCADE;
