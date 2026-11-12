-- Cash accountability, attendance and operational audit. Shift money is stored
-- in integer minor units. A partial unique index enforces one open shift and one
-- open attendance row per staff member while keeping closed history unlimited.

ALTER TYPE "ApprovalAction" ADD VALUE 'CASH_OUT';

CREATE TYPE "ShiftStatus" AS ENUM ('OPEN', 'CLOSED');

CREATE TYPE "ShiftCashMovementKind" AS ENUM ('PAID_IN', 'PAID_OUT');

CREATE TYPE "OperationAuditAction" AS ENUM ('SHIFT_OPENED', 'SHIFT_CLOSED', 'CASH_PAID_IN', 'CASH_PAID_OUT', 'ATTENDANCE_CLOCK_IN', 'ATTENDANCE_CLOCK_OUT');

CREATE TABLE "shifts" (
    "id" UUID NOT NULL,
    "businessId" UUID NOT NULL,
    "outletId" UUID NOT NULL,
    "openedById" UUID NOT NULL,
    "closedById" UUID,
    "status" "ShiftStatus" NOT NULL DEFAULT 'OPEN',
    "openingFloatMinor" BIGINT NOT NULL,
    "cashSalesMinor" BIGINT NOT NULL DEFAULT 0,
    "paidInMinor" BIGINT NOT NULL DEFAULT 0,
    "paidOutMinor" BIGINT NOT NULL DEFAULT 0,
    "expectedCashMinor" BIGINT NOT NULL DEFAULT 0,
    "countedCashMinor" BIGINT,
    "discrepancyMinor" BIGINT,
    "closeNote" TEXT,
    "version" INTEGER NOT NULL DEFAULT 1,
    "openedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "closedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "shifts_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "shift_cash_movements" (
    "id" UUID NOT NULL,
    "businessId" UUID NOT NULL,
    "outletId" UUID NOT NULL,
    "shiftId" UUID NOT NULL,
    "actorId" UUID NOT NULL,
    "kind" "ShiftCashMovementKind" NOT NULL,
    "amountMinor" BIGINT NOT NULL,
    "reason" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "shift_cash_movements_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "attendance_records" (
    "id" UUID NOT NULL,
    "businessId" UUID NOT NULL,
    "outletId" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "clockInAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "clockOutAt" TIMESTAMP(3),
    "clockInNote" TEXT,
    "clockOutNote" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "attendance_records_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "operation_audits" (
    "id" UUID NOT NULL,
    "businessId" UUID NOT NULL,
    "outletId" UUID NOT NULL,
    "actorId" UUID NOT NULL,
    "action" "OperationAuditAction" NOT NULL,
    "entityType" TEXT NOT NULL,
    "entityId" UUID NOT NULL,
    "metadata" JSONB NOT NULL DEFAULT '{}',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "operation_audits_pkey" PRIMARY KEY ("id")
);

CREATE INDEX "shifts_outletId_status_openedAt_idx" ON "shifts"("outletId", "status", "openedAt");

CREATE INDEX "shifts_openedById_status_idx" ON "shifts"("openedById", "status");

CREATE UNIQUE INDEX "shifts_one_open_per_user" ON "shifts"("outletId", "openedById") WHERE "status" = 'OPEN';

CREATE INDEX "shift_cash_movements_shiftId_createdAt_idx" ON "shift_cash_movements"("shiftId", "createdAt");

CREATE INDEX "shift_cash_movements_outletId_createdAt_idx" ON "shift_cash_movements"("outletId", "createdAt");

CREATE INDEX "attendance_records_outletId_userId_clockInAt_idx" ON "attendance_records"("outletId", "userId", "clockInAt");

CREATE INDEX "attendance_records_outletId_clockInAt_idx" ON "attendance_records"("outletId", "clockInAt");

CREATE UNIQUE INDEX "attendance_one_open_per_user" ON "attendance_records"("outletId", "userId") WHERE "clockOutAt" IS NULL;

CREATE INDEX "operation_audits_outletId_createdAt_id_idx" ON "operation_audits"("outletId", "createdAt", "id");

CREATE INDEX "operation_audits_outletId_actorId_createdAt_idx" ON "operation_audits"("outletId", "actorId", "createdAt");

CREATE INDEX "operation_audits_outletId_action_createdAt_idx" ON "operation_audits"("outletId", "action", "createdAt");

ALTER TABLE "shifts" ADD CONSTRAINT "shifts_businessId_fkey" FOREIGN KEY ("businessId") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "shifts" ADD CONSTRAINT "shifts_outletId_fkey" FOREIGN KEY ("outletId") REFERENCES "outlets"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "shifts" ADD CONSTRAINT "shifts_openedById_fkey" FOREIGN KEY ("openedById") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "shifts" ADD CONSTRAINT "shifts_closedById_fkey" FOREIGN KEY ("closedById") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "shift_cash_movements" ADD CONSTRAINT "shift_cash_movements_businessId_fkey" FOREIGN KEY ("businessId") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "shift_cash_movements" ADD CONSTRAINT "shift_cash_movements_outletId_fkey" FOREIGN KEY ("outletId") REFERENCES "outlets"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "shift_cash_movements" ADD CONSTRAINT "shift_cash_movements_shiftId_fkey" FOREIGN KEY ("shiftId") REFERENCES "shifts"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "shift_cash_movements" ADD CONSTRAINT "shift_cash_movements_actorId_fkey" FOREIGN KEY ("actorId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "attendance_records" ADD CONSTRAINT "attendance_records_businessId_fkey" FOREIGN KEY ("businessId") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "attendance_records" ADD CONSTRAINT "attendance_records_outletId_fkey" FOREIGN KEY ("outletId") REFERENCES "outlets"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "attendance_records" ADD CONSTRAINT "attendance_records_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "operation_audits" ADD CONSTRAINT "operation_audits_businessId_fkey" FOREIGN KEY ("businessId") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "operation_audits" ADD CONSTRAINT "operation_audits_outletId_fkey" FOREIGN KEY ("outletId") REFERENCES "outlets"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "operation_audits" ADD CONSTRAINT "operation_audits_actorId_fkey" FOREIGN KEY ("actorId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- Operational audit is append-only, matching the order audit guarantee.
CREATE OR REPLACE FUNCTION reject_operation_audit_mutation() RETURNS trigger AS $$
BEGIN
    RAISE EXCEPTION 'operation_audits is append-only';
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER operation_audits_append_only
BEFORE UPDATE OR DELETE ON "operation_audits"
FOR EACH ROW EXECUTE FUNCTION reject_operation_audit_mutation();
