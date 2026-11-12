import assert from 'node:assert/strict';
import { test } from 'node:test';
import { HttpException } from '@nestjs/common';
import {
  ApprovalAction,
  OperationAuditAction,
  PaymentKind,
  PaymentStatus,
  Role,
  SaleState,
  ShiftCashMovementKind,
  ShiftStatus,
} from '@prisma/client';
import type { AuthenticatedUser } from '../auth/auth.types';
import type { PrismaService } from '../prisma/prisma.service';
import type { PromotionsService } from '../promotions/promotions.service';
import { ShiftsService } from './shifts.service';

const BUSINESS_ID = '00000000-0000-4000-8000-000000000001';
const OUTLET_ID = '00000000-0000-4000-8000-000000000002';
const OTHER_OUTLET_ID = '00000000-0000-4000-8000-000000000005';
const OWNER_ID = '00000000-0000-4000-8000-000000000003';
const CASHIER_ID = '00000000-0000-4000-8000-000000000004';
const OTHER_CASHIER_ID = '00000000-0000-4000-8000-000000000007';

interface ShiftRow {
  id: string;
  businessId: string;
  outletId: string;
  openedById: string;
  closedById: string | null;
  status: ShiftStatus;
  openingFloatMinor: bigint;
  cashSalesMinor: bigint;
  paidInMinor: bigint;
  paidOutMinor: bigint;
  expectedCashMinor: bigint;
  countedCashMinor: bigint | null;
  discrepancyMinor: bigint | null;
  closeNote: string | null;
  version: number;
  openedAt: Date;
  closedAt: Date | null;
  createdAt: Date;
  updatedAt: Date;
}

interface MovementRow {
  id: string;
  businessId: string;
  outletId: string;
  shiftId: string;
  actorId: string;
  kind: ShiftCashMovementKind;
  amountMinor: bigint;
  reason: string;
  createdAt: Date;
}

interface AuditRow {
  id: string;
  businessId: string;
  outletId: string;
  actorId: string;
  action: OperationAuditAction;
  entityType: string;
  entityId: string;
  metadata: Record<string, unknown>;
  createdAt: Date;
}

interface SaleRow {
  id: string;
  businessId: string;
  outletId: string;
  state: SaleState;
  totalMinor: bigint;
  completedAt: Date;
  payment: { kind: PaymentKind; status: PaymentStatus; amountMinor: bigint } | null;
}

interface RuleRow {
  outletId: string;
  businessId: string;
  action: ApprovalAction;
  thresholdMinor: bigint;
  active: boolean;
}

interface FakeState {
  shifts: ShiftRow[];
  movements: MovementRow[];
  audits: AuditRow[];
  sales: SaleRow[];
  rules: RuleRow[];
}

function user(role: Role, id = CASHIER_ID): AuthenticatedUser {
  return {
    id,
    businessId: BUSINESS_ID,
    email: `${id}@example.test`,
    role,
    outletId: OUTLET_ID,
    outletIds: [OUTLET_ID],
    sessionId: 'session-1',
  };
}

function matches(
  row: Record<string, unknown>,
  where: Record<string, unknown> | undefined,
): boolean {
  if (!where) {
    return true;
  }
  return Object.entries(where).every(([key, value]) => {
    if (value && typeof value === 'object' && 'lt' in (value as Record<string, unknown>)) {
      return (row[key] as Date) < (value as { lt: Date }).lt;
    }
    return row[key] === value;
  });
}

function applyData(row: Record<string, unknown>, data: Record<string, unknown>): void {
  for (const [key, value] of Object.entries(data)) {
    if (value && typeof value === 'object' && 'increment' in (value as Record<string, unknown>)) {
      row[key] = (row[key] as bigint) + (value as { increment: bigint }).increment;
    } else {
      row[key] = value;
    }
  }
}

function setup(): { service: ShiftsService; state: FakeState } {
  const now = new Date('2026-11-12T10:00:00.000Z');
  const state: FakeState = { shifts: [], movements: [], audits: [], sales: [], rules: [] };
  let sequence = 0;

  const prisma = {
    outlet: {
      findFirst: async ({ where }: { where: Record<string, unknown> }) =>
        where.id === OUTLET_ID || where.id === OTHER_OUTLET_ID
          ? {
              id: where.id,
              businessId: BUSINESS_ID,
              currency: 'IDR',
              currencyExponent: 0,
            }
          : null,
    },
    shift: {
      findFirst: async ({ where }: { where: Record<string, unknown> }) => {
        const direct = state.shifts.find((shift) =>
          matches(shift as unknown as Record<string, unknown>, where),
        );
        return direct ?? null;
      },
      findMany: async ({ where }: { where: Record<string, unknown> }) => {
        const base = where as {
          businessId: string;
          outletId: string;
          status?: ShiftStatus;
          openedById?: string;
          OR?: Record<string, unknown>[];
        };
        let rows = state.shifts.filter(
          (shift) =>
            shift.businessId === base.businessId &&
            shift.outletId === base.outletId &&
            (!base.status || shift.status === base.status) &&
            (!base.openedById || shift.openedById === base.openedById),
        );
        if (base.OR) {
          rows = rows.filter((shift) =>
            base.OR?.some((clause) => {
              const value = clause.openedAt as { lt?: Date } | Date | undefined;
              const id = clause.id as { lt?: string } | undefined;
              if (value instanceof Date) {
                return (
                  shift.openedAt.getTime() === value.getTime() && (!id?.lt || shift.id < id.lt)
                );
              }
              return (
                (value?.lt ? shift.openedAt < value.lt : true) && (!id?.lt || shift.id < id.lt)
              );
            }),
          );
        }
        return [...rows].sort((a, b) => b.openedAt.getTime() - a.openedAt.getTime());
      },
      create: async ({ data }: { data: Record<string, unknown> }) => {
        sequence += 1;
        const row: ShiftRow = {
          id: `shift-${sequence}`,
          businessId: data.businessId as string,
          outletId: data.outletId as string,
          openedById: data.openedById as string,
          closedById: null,
          status: ShiftStatus.OPEN,
          openingFloatMinor: data.openingFloatMinor as bigint,
          cashSalesMinor: 0n,
          paidInMinor: 0n,
          paidOutMinor: 0n,
          expectedCashMinor: (data.expectedCashMinor ?? 0n) as bigint,
          countedCashMinor: null,
          discrepancyMinor: null,
          closeNote: null,
          version: 1,
          openedAt: now,
          closedAt: null,
          createdAt: now,
          updatedAt: now,
        };
        state.shifts.push(row);
        return row;
      },
      update: async ({ where, data }: { where: { id: string }; data: Record<string, unknown> }) => {
        const row = state.shifts.find((shift) => shift.id === where.id);
        assert.ok(row, 'shift exists');
        applyData(row as unknown as Record<string, unknown>, data);
        return row;
      },
      updateMany: async ({
        where,
        data,
      }: {
        where: { id: string; status?: ShiftStatus; version?: number };
        data: Record<string, unknown>;
      }) => {
        const row = state.shifts.find(
          (shift) =>
            shift.id === where.id &&
            (!where.status || shift.status === where.status) &&
            (where.version === undefined || shift.version === where.version),
        );
        if (!row) {
          return { count: 0 };
        }
        applyData(row as unknown as Record<string, unknown>, data);
        return { count: 1 };
      },
      findUniqueOrThrow: async ({ where }: { where: { id: string } }) => {
        const row = state.shifts.find((shift) => shift.id === where.id);
        assert.ok(row, 'shift exists');
        return row;
      },
    },
    shiftCashMovement: {
      create: async ({ data }: { data: Record<string, unknown> }) => {
        sequence += 1;
        const row: MovementRow = {
          id: `movement-${sequence}`,
          businessId: data.businessId as string,
          outletId: data.outletId as string,
          shiftId: data.shiftId as string,
          actorId: data.actorId as string,
          kind: data.kind as ShiftCashMovementKind,
          amountMinor: data.amountMinor as bigint,
          reason: data.reason as string,
          createdAt: now,
        };
        state.movements.push(row);
        return row;
      },
      groupBy: async ({ where }: { where: { shiftId: string } }) => {
        const rows = state.movements.filter((row) => row.shiftId === where.shiftId);
        return [ShiftCashMovementKind.PAID_IN, ShiftCashMovementKind.PAID_OUT].map((kind) => ({
          kind,
          _sum: {
            amountMinor: rows
              .filter((row) => row.kind === kind)
              .reduce((sum, row) => sum + row.amountMinor, 0n),
          },
        }));
      },
      findMany: async ({ where }: { where: { shiftId: string } }) =>
        state.movements.filter((row) => row.shiftId === where.shiftId),
    },
    sale: {
      findMany: async ({
        where,
      }: {
        where: {
          businessId: string;
          outletId: string;
          state: SaleState;
          completedAt: { gte: Date; lt: Date };
        };
      }) =>
        state.sales.filter(
          (sale) =>
            sale.businessId === where.businessId &&
            sale.outletId === where.outletId &&
            sale.state === where.state &&
            sale.completedAt >= where.completedAt.gte &&
            sale.completedAt < where.completedAt.lt,
        ),
    },
    operationAudit: {
      create: async ({ data }: { data: Record<string, unknown> }) => {
        sequence += 1;
        const row: AuditRow = {
          id: `audit-${sequence}`,
          businessId: data.businessId as string,
          outletId: data.outletId as string,
          actorId: data.actorId as string,
          action: data.action as OperationAuditAction,
          entityType: data.entityType as string,
          entityId: data.entityId as string,
          metadata: data.metadata as Record<string, unknown>,
          createdAt: now,
        };
        state.audits.push(row);
        return row;
      },
    },
    $transaction: async <T>(fn: (client: unknown) => Promise<T>): Promise<T> => fn(prisma),
  };

  const promotions = {
    findApprovalRule: async (
      _client: unknown,
      outletId: string,
      businessId: string,
      action: ApprovalAction,
    ) =>
      state.rules.find(
        (rule) =>
          rule.outletId === outletId && rule.businessId === businessId && rule.action === action,
      ) ?? null,
  } as unknown as PromotionsService;

  return {
    service: new ShiftsService(prisma as unknown as PrismaService, promotions),
    state,
  };
}

function addCashSale(state: FakeState, amountMinor: bigint, totalMinor = amountMinor): void {
  state.sales.push({
    id: `sale-${state.sales.length + 1}`,
    businessId: BUSINESS_ID,
    outletId: OUTLET_ID,
    state: SaleState.COMPLETED,
    totalMinor,
    completedAt: new Date('2026-11-12T10:05:00.000Z'),
    payment: { kind: PaymentKind.CASH, status: PaymentStatus.RECORDED, amountMinor },
  });
}

function expectHttp(error: unknown, status: number, code?: string): boolean {
  return (
    error instanceof HttpException &&
    error.getStatus() === status &&
    (!code || (error.getResponse() as { code: string }).code === code)
  );
}

test('opening a shift stores the float and writes an actor audit event', async () => {
  const { service, state } = setup();
  const shift = await service.openShift(
    OUTLET_ID,
    { openingFloatMinor: 100_000 },
    user(Role.CASHIER),
  );

  assert.equal(shift.status, ShiftStatus.OPEN);
  assert.equal(shift.openingFloatMinor, 100_000);
  assert.equal(shift.expectedCashMinor, 100_000);
  assert.equal(state.audits.length, 1);
  assert.equal(state.audits[0].action, OperationAuditAction.SHIFT_OPENED);
  assert.equal(state.audits[0].actorId, CASHIER_ID);
});

test('a second open shift for the same staff member returns 409', async () => {
  const { service } = setup();
  await service.openShift(OUTLET_ID, { openingFloatMinor: 100_000 }, user(Role.CASHIER));

  await assert.rejects(
    () => service.openShift(OUTLET_ID, { openingFloatMinor: 50_000 }, user(Role.CASHIER)),
    (error: unknown) => expectHttp(error, 409, 'SHIFT_ALREADY_OPEN'),
  );
});

test('paid-in and owner paid-out update shift totals and audit actors', async () => {
  const { service, state } = setup();
  const opened = await service.openShift(
    OUTLET_ID,
    { openingFloatMinor: 100_000 },
    user(Role.CASHIER),
  );

  await service.recordCashMovement(
    OUTLET_ID,
    opened.id,
    { kind: ShiftCashMovementKind.PAID_IN, amountMinor: 20_000, reason: 'Float top-up' },
    user(Role.CASHIER),
  );
  const afterOut = await service.recordCashMovement(
    OUTLET_ID,
    opened.id,
    { kind: ShiftCashMovementKind.PAID_OUT, amountMinor: 15_000, reason: 'Courier' },
    user(Role.OWNER, OWNER_ID),
  );

  assert.equal(afterOut.paidInMinor, 20_000);
  assert.equal(afterOut.paidOutMinor, 15_000);
  assert.equal(state.movements.length, 2);
  assert.equal(
    state.audits.filter((row) => row.action === OperationAuditAction.CASH_PAID_IN).length,
    1,
  );
  assert.equal(
    state.audits.filter((row) => row.action === OperationAuditAction.CASH_PAID_OUT).length,
    1,
  );
});

test('cashier paid-out above the approval threshold is denied with APPROVAL_REQUIRED', async () => {
  const { service, state } = setup();
  const opened = await service.openShift(
    OUTLET_ID,
    { openingFloatMinor: 100_000 },
    user(Role.CASHIER),
  );
  state.rules.push({
    outletId: OUTLET_ID,
    businessId: BUSINESS_ID,
    action: ApprovalAction.CASH_OUT,
    thresholdMinor: 50_000n,
    active: true,
  });

  await assert.rejects(
    () =>
      service.recordCashMovement(
        OUTLET_ID,
        opened.id,
        { kind: ShiftCashMovementKind.PAID_OUT, amountMinor: 80_000, reason: 'Supplies' },
        user(Role.CASHIER),
      ),
    (error: unknown) => expectHttp(error, 403, 'APPROVAL_REQUIRED'),
  );

  const updated = await service.recordCashMovement(
    OUTLET_ID,
    opened.id,
    { kind: ShiftCashMovementKind.PAID_OUT, amountMinor: 50_000, reason: 'Supplies' },
    user(Role.CASHIER),
  );
  assert.equal(updated.paidOutMinor, 50_000);
});

test('another staff member cannot change or close the shift', async () => {
  const { service } = setup();
  const opened = await service.openShift(
    OUTLET_ID,
    { openingFloatMinor: 100_000 },
    user(Role.CASHIER),
  );

  await assert.rejects(
    () =>
      service.recordCashMovement(
        OUTLET_ID,
        opened.id,
        { kind: ShiftCashMovementKind.PAID_IN, amountMinor: 10_000, reason: 'Float' },
        user(Role.CASHIER, OTHER_CASHIER_ID),
      ),
    (error: unknown) => expectHttp(error, 409, 'SHIFT_NOT_YOURS'),
  );

  await assert.rejects(
    () =>
      service.closeShift(
        OUTLET_ID,
        opened.id,
        { countedCashMinor: 100_000 },
        user(Role.OWNER, OWNER_ID),
      ),
    (error: unknown) => expectHttp(error, 409, 'SHIFT_NOT_YOURS'),
  );
});

test('closing reconciles expected cash from tenders and records a signed discrepancy', async () => {
  const { service, state } = setup();
  const opened = await service.openShift(
    OUTLET_ID,
    { openingFloatMinor: 100_000 },
    user(Role.CASHIER),
  );
  addCashSale(state, 45_000n);
  await service.recordCashMovement(
    OUTLET_ID,
    opened.id,
    { kind: ShiftCashMovementKind.PAID_IN, amountMinor: 20_000, reason: 'Float top-up' },
    user(Role.CASHIER),
  );
  await service.recordCashMovement(
    OUTLET_ID,
    opened.id,
    { kind: ShiftCashMovementKind.PAID_OUT, amountMinor: 15_000, reason: 'Courier' },
    user(Role.OWNER, OWNER_ID),
  );

  const closed = await service.closeShift(
    OUTLET_ID,
    opened.id,
    { countedCashMinor: 149_000, note: 'One note missing' },
    user(Role.CASHIER),
  );

  const handExpected = 100_000n + 45_000n + 20_000n - 15_000n;
  assert.equal(handExpected, 150_000n);
  assert.equal(closed.cashSalesMinor, 45_000);
  assert.equal(closed.expectedCashMinor, Number(handExpected));
  assert.equal(closed.countedCashMinor, 149_000);
  assert.equal(closed.discrepancyMinor, -1_000);
  assert.equal(closed.status, ShiftStatus.CLOSED);
  assert.equal(closed.closeNote, 'One note missing');

  const audit = state.audits.find((row) => row.action === OperationAuditAction.SHIFT_CLOSED);
  assert.ok(audit);
  assert.equal(audit.metadata.expectedCashMinor, 150_000);
  assert.equal(audit.metadata.discrepancyMinor, -1_000);
});

test('closing twice returns 409 and concurrent closes produce one winner', async () => {
  const { service } = setup();
  const opened = await service.openShift(
    OUTLET_ID,
    { openingFloatMinor: 100_000 },
    user(Role.CASHIER),
  );

  const results = await Promise.allSettled([
    service.closeShift(OUTLET_ID, opened.id, { countedCashMinor: 100_000 }, user(Role.CASHIER)),
    service.closeShift(OUTLET_ID, opened.id, { countedCashMinor: 100_000 }, user(Role.CASHIER)),
  ]);

  assert.equal(results.filter((result) => result.status === 'fulfilled').length, 1);
  const rejected = results.find((result) => result.status === 'rejected');
  assert.ok(rejected && rejected.status === 'rejected');
  assert.ok(expectHttp(rejected.reason, 409));

  await assert.rejects(
    () =>
      service.closeShift(OUTLET_ID, opened.id, { countedCashMinor: 100_000 }, user(Role.CASHIER)),
    (error: unknown) => expectHttp(error, 409),
  );
});

test('cross-outlet reads return 404', async () => {
  const { service } = setup();
  const opened = await service.openShift(
    OUTLET_ID,
    { openingFloatMinor: 100_000 },
    user(Role.CASHIER),
  );

  await assert.rejects(
    () => service.getShift(OTHER_OUTLET_ID, opened.id, user(Role.OWNER, OWNER_ID)),
    (error: unknown) => expectHttp(error, 404, 'NOT_FOUND'),
  );
});

test('shift report is owner-only and lists every payment kind', async () => {
  const { service, state } = setup();
  const opened = await service.openShift(
    OUTLET_ID,
    { openingFloatMinor: 100_000 },
    user(Role.CASHIER),
  );
  addCashSale(state, 45_000n);
  state.sales.push({
    id: 'online-sale',
    businessId: BUSINESS_ID,
    outletId: OUTLET_ID,
    state: SaleState.COMPLETED,
    totalMinor: 70_000n,
    completedAt: new Date('2026-11-12T10:06:00.000Z'),
    payment: { kind: PaymentKind.ONLINE, status: PaymentStatus.SUCCEEDED, amountMinor: 70_000n },
  });

  await assert.rejects(
    () => service.shiftReport(OUTLET_ID, opened.id, user(Role.CASHIER)),
    (error: unknown) => expectHttp(error, 403, 'FORBIDDEN'),
  );

  const report = await service.shiftReport(OUTLET_ID, opened.id, user(Role.OWNER, OWNER_ID));
  assert.equal(
    report.salesByTender.find((row) => row.kind === PaymentKind.CASH)?.amountMinor,
    45_000,
  );
  assert.equal(
    report.salesByTender.find((row) => row.kind === PaymentKind.ONLINE)?.amountMinor,
    70_000,
  );
  assert.equal(
    report.salesByTender.find((row) => row.kind === PaymentKind.MANUAL_EXTERNAL)?.count,
    0,
  );
});
