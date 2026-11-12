import assert from 'node:assert/strict';
import { test } from 'node:test';
import { HttpException } from '@nestjs/common';
import { OperationAuditAction, Role } from '@prisma/client';
import type { AuthenticatedUser } from '../auth/auth.types';
import type { PrismaService } from '../prisma/prisma.service';
import { AttendanceService } from './attendance.service';

const BUSINESS_ID = '00000000-0000-4000-8000-000000000001';
const OUTLET_ID = '00000000-0000-4000-8000-000000000002';
const OTHER_OUTLET_ID = '00000000-0000-4000-8000-000000000005';
const OWNER_ID = '00000000-0000-4000-8000-000000000003';
const CASHIER_ID = '00000000-0000-4000-8000-000000000004';
const OTHER_CASHIER_ID = '00000000-0000-4000-8000-000000000007';
const NOW = new Date('2026-11-12T09:00:00.000Z');

interface AttendanceRow {
  id: string;
  businessId: string;
  outletId: string;
  userId: string;
  clockInAt: Date;
  clockOutAt: Date | null;
  clockInNote: string | null;
  clockOutNote: string | null;
  createdAt: Date;
  updatedAt: Date;
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

function setup(): {
  service: AttendanceService;
  records: AttendanceRow[];
  shiftWrites: string[];
  audits: OperationAuditAction[];
} {
  const records: AttendanceRow[] = [];
  const shiftWrites: string[] = [];
  const audits: OperationAuditAction[] = [];
  let sequence = 0;

  const prisma = {
    outlet: {
      findFirst: async ({ where }: { where: { id: string } }) =>
        where.id === OUTLET_ID ? { id: OUTLET_ID } : null,
    },
    attendanceRecord: {
      findFirst: async ({
        where,
      }: {
        where: { outletId: string; userId: string; clockOutAt: null };
      }) =>
        records.find(
          (row) =>
            row.outletId === where.outletId &&
            row.userId === where.userId &&
            row.clockOutAt === where.clockOutAt,
        ) ?? null,
      create: async ({ data }: { data: Record<string, unknown> }) => {
        sequence += 1;
        const row: AttendanceRow = {
          id: `attendance-${sequence}`,
          businessId: data.businessId as string,
          outletId: data.outletId as string,
          userId: data.userId as string,
          clockInAt: NOW,
          clockOutAt: null,
          clockInNote: (data.clockInNote ?? null) as string | null,
          clockOutNote: null,
          createdAt: NOW,
          updatedAt: NOW,
        };
        records.push(row);
        return row;
      },
      updateMany: async ({
        where,
        data,
      }: {
        where: { id: string };
        data: Record<string, unknown>;
      }) => {
        const row = records.find((record) => record.id === where.id && record.clockOutAt === null);
        if (!row) {
          return { count: 0 };
        }
        row.clockOutAt = data.clockOutAt as Date;
        row.clockOutNote = (data.clockOutNote ?? null) as string | null;
        return { count: 1 };
      },
      findUniqueOrThrow: async ({ where }: { where: { id: string } }) => {
        const row = records.find((record) => record.id === where.id);
        assert.ok(row);
        return row;
      },
      findMany: async ({ where }: { where: Record<string, unknown> }) => {
        const base = where as {
          outletId: string;
          userId?: string;
        };
        return records.filter(
          (row) => row.outletId === base.outletId && (!base.userId || row.userId === base.userId),
        );
      },
    },
    operationAudit: {
      create: async ({ data }: { data: { action: OperationAuditAction } }) => {
        audits.push(data.action);
        return data;
      },
    },
    shift: {
      create: async () => {
        shiftWrites.push('create');
        return {};
      },
      update: async () => {
        shiftWrites.push('update');
        return {};
      },
      updateMany: async () => {
        shiftWrites.push('updateMany');
        return { count: 0 };
      },
    },
    $transaction: async <T>(fn: (client: unknown) => Promise<T>): Promise<T> => fn(prisma),
  };

  return {
    service: new AttendanceService(prisma as unknown as PrismaService),
    records,
    shiftWrites,
    audits,
  };
}

function expectHttp(error: unknown, status: number, code?: string): boolean {
  return (
    error instanceof HttpException &&
    error.getStatus() === status &&
    (!code || (error.getResponse() as { code: string }).code === code)
  );
}

test('clock-in and clock-out record the actor without touching a shift', async () => {
  const { service, shiftWrites, audits } = setup();
  const clockedIn = await service.clockIn(OUTLET_ID, { note: 'Morning' }, user(Role.CASHIER));

  assert.equal(clockedIn.userId, CASHIER_ID);
  assert.equal(clockedIn.clockOutAt, null);
  assert.deepEqual(shiftWrites, [], 'attendance must not create or update a shift');

  const clockedOut = await service.clockOut(OUTLET_ID, { note: 'Done' }, user(Role.CASHIER));
  assert.ok(clockedOut.clockOutAt);
  assert.deepEqual(shiftWrites, [], 'clock-out must not close a shift');
  assert.deepEqual(audits, [
    OperationAuditAction.ATTENDANCE_CLOCK_IN,
    OperationAuditAction.ATTENDANCE_CLOCK_OUT,
  ]);
});

test('duplicate clock-in and clock-out without an open record return 409', async () => {
  const { service } = setup();
  await service.clockIn(OUTLET_ID, {}, user(Role.CASHIER));

  await assert.rejects(
    () => service.clockIn(OUTLET_ID, {}, user(Role.CASHIER)),
    (error: unknown) => expectHttp(error, 409, 'ATTENDANCE_ALREADY_OPEN'),
  );

  await service.clockOut(OUTLET_ID, {}, user(Role.CASHIER));
  await assert.rejects(
    () => service.clockOut(OUTLET_ID, {}, user(Role.CASHIER)),
    (error: unknown) => expectHttp(error, 409, 'ATTENDANCE_NOT_OPEN'),
  );
});

test('owners list every record while staff only see their own', async () => {
  const { service, records } = setup();
  records.push(
    {
      id: 'attendance-a',
      businessId: BUSINESS_ID,
      outletId: OUTLET_ID,
      userId: CASHIER_ID,
      clockInAt: NOW,
      clockOutAt: null,
      clockInNote: null,
      clockOutNote: null,
      createdAt: NOW,
      updatedAt: NOW,
    },
    {
      id: 'attendance-b',
      businessId: BUSINESS_ID,
      outletId: OUTLET_ID,
      userId: OTHER_CASHIER_ID,
      clockInAt: NOW,
      clockOutAt: null,
      clockInNote: null,
      clockOutNote: null,
      createdAt: NOW,
      updatedAt: NOW,
    },
  );

  const own = await service.listAttendance(OUTLET_ID, {}, user(Role.CASHIER));
  assert.equal(own.items.length, 1);
  assert.equal(own.items[0].userId, CASHIER_ID);

  const all = await service.listAttendance(OUTLET_ID, {}, user(Role.OWNER, OWNER_ID));
  assert.equal(all.items.length, 2);

  const other = await service
    .listAttendance(OTHER_OUTLET_ID, {}, user(Role.OWNER, OWNER_ID))
    .catch((error: unknown) => error);
  assert.ok(expectHttp(other, 404, 'NOT_FOUND'));
});
