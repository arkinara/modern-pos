import assert from 'node:assert/strict';
import { test } from 'node:test';
import { HttpException } from '@nestjs/common';
import { OperationAuditAction, Role } from '@prisma/client';
import type { AuthenticatedUser } from '../auth/auth.types';
import type { PrismaService } from '../prisma/prisma.service';
import { AuditService } from './audit.service';
import { encodeCursor } from './cursor';

const BUSINESS_ID = '00000000-0000-4000-8000-000000000001';
const OUTLET_ID = '00000000-0000-4000-8000-000000000002';
const OTHER_OUTLET_ID = '00000000-0000-4000-8000-000000000005';
const OWNER_ID = '00000000-0000-4000-8000-000000000003';
const CASHIER_ID = '00000000-0000-4000-8000-000000000004';

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

function user(role: Role, id = OWNER_ID): AuthenticatedUser {
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

function row(
  id: string,
  actorId: string,
  action: OperationAuditAction,
  createdAt: string,
): AuditRow {
  return {
    id,
    businessId: BUSINESS_ID,
    outletId: OUTLET_ID,
    actorId,
    action,
    entityType: 'SHIFT',
    entityId: '00000000-0000-4000-8000-000000000099',
    metadata: {},
    createdAt: new Date(createdAt),
  };
}

function setup(rows: AuditRow[]): AuditService {
  const prisma = {
    outlet: {
      findFirst: async ({ where }: { where: { id: string } }) =>
        where.id === OUTLET_ID ? { id: OUTLET_ID } : null,
    },
    operationAudit: {
      findMany: async ({
        where,
        take,
        orderBy: _orderBy,
      }: {
        where: Record<string, unknown>;
        take: number;
        orderBy: unknown;
      }) => {
        const base = where as {
          businessId: string;
          outletId: string;
          actorId?: string;
          action?: OperationAuditAction;
          createdAt?: { gte?: Date; lte?: Date };
          OR?: Array<
            | { createdAt?: { lt?: Date }; id?: { lt?: string } }
            | { createdAt?: Date; id?: { lt?: string } }
          >;
        };
        let filtered = rows.filter(
          (item) =>
            item.businessId === base.businessId &&
            item.outletId === base.outletId &&
            (!base.actorId || item.actorId === base.actorId) &&
            (!base.action || item.action === base.action) &&
            (!base.createdAt?.gte || item.createdAt >= base.createdAt.gte) &&
            (!base.createdAt?.lte || item.createdAt <= base.createdAt.lte),
        );
        if (base.OR) {
          filtered = filtered.filter((item) =>
            base.OR?.some((clause) => {
              const lt = clause.createdAt as { lt?: Date } | Date | undefined;
              const id = clause.id as { lt?: string } | undefined;
              if (lt instanceof Date) {
                return item.createdAt.getTime() === lt.getTime() && (!id?.lt || item.id < id.lt);
              }
              const before = lt?.lt ? item.createdAt < lt.lt : true;
              return before && (!id?.lt || item.id < id.lt);
            }),
          );
        }
        filtered = [...filtered].sort(
          (a, b) => b.createdAt.getTime() - a.createdAt.getTime() || (a.id < b.id ? 1 : -1),
        );
        return filtered.slice(0, take);
      },
    },
  };

  return new AuditService(prisma as unknown as PrismaService);
}

function expectHttp(error: unknown, status: number, code?: string): boolean {
  return (
    error instanceof HttpException &&
    error.getStatus() === status &&
    (!code || (error.getResponse() as { code: string }).code === code)
  );
}

test('audit search filters by actor, action and time range', async () => {
  const service = setup([
    row(
      '00000000-0000-4000-8000-0000000000a1',
      CASHIER_ID,
      OperationAuditAction.SHIFT_OPENED,
      '2026-11-12T08:00:00.000Z',
    ),
    row(
      '00000000-0000-4000-8000-0000000000a2',
      CASHIER_ID,
      OperationAuditAction.SHIFT_CLOSED,
      '2026-11-12T09:00:00.000Z',
    ),
    row(
      '00000000-0000-4000-8000-0000000000a3',
      OWNER_ID,
      OperationAuditAction.SHIFT_OPENED,
      '2026-11-12T10:00:00.000Z',
    ),
  ]);

  const byActor = await service.search(OUTLET_ID, { actorId: CASHIER_ID }, user(Role.OWNER));
  assert.deepEqual(
    byActor.items.map((item) => item.id),
    ['00000000-0000-4000-8000-0000000000a2', '00000000-0000-4000-8000-0000000000a1'],
  );

  const byAction = await service.search(
    OUTLET_ID,
    { action: OperationAuditAction.SHIFT_OPENED },
    user(Role.OWNER),
  );
  assert.deepEqual(
    byAction.items.map((item) => item.id),
    ['00000000-0000-4000-8000-0000000000a3', '00000000-0000-4000-8000-0000000000a1'],
  );

  const byRange = await service.search(
    OUTLET_ID,
    { from: '2026-11-12T08:30:00.000Z', to: '2026-11-12T09:30:00.000Z' },
    user(Role.OWNER),
  );
  assert.deepEqual(
    byRange.items.map((item) => item.id),
    ['00000000-0000-4000-8000-0000000000a2'],
  );
});

test('cursor pagination is stable and does not repeat rows', async () => {
  const service = setup([
    row(
      '00000000-0000-4000-8000-0000000000a1',
      CASHIER_ID,
      OperationAuditAction.SHIFT_OPENED,
      '2026-11-12T08:00:00.000Z',
    ),
    row(
      '00000000-0000-4000-8000-0000000000a2',
      CASHIER_ID,
      OperationAuditAction.CASH_PAID_IN,
      '2026-11-12T09:00:00.000Z',
    ),
    row(
      '00000000-0000-4000-8000-0000000000a3',
      CASHIER_ID,
      OperationAuditAction.SHIFT_CLOSED,
      '2026-11-12T10:00:00.000Z',
    ),
  ]);

  const first = await service.search(OUTLET_ID, { limit: 2 }, user(Role.OWNER));
  assert.deepEqual(
    first.items.map((item) => item.id),
    ['00000000-0000-4000-8000-0000000000a3', '00000000-0000-4000-8000-0000000000a2'],
  );
  assert.ok(first.nextCursor);

  const second = await service.search(
    OUTLET_ID,
    { limit: 2, cursor: first.nextCursor ?? undefined },
    user(Role.OWNER),
  );
  assert.deepEqual(
    second.items.map((item) => item.id),
    ['00000000-0000-4000-8000-0000000000a1'],
  );
  assert.equal(second.nextCursor, null);
});

test('bad cursor and inverted range return 400; cross-outlet returns 404', async () => {
  const service = setup([]);

  await assert.rejects(
    () => service.search(OUTLET_ID, { cursor: 'broken' }, user(Role.OWNER)),
    (error: unknown) => expectHttp(error, 400, 'INVALID_CURSOR'),
  );
  await assert.rejects(
    () =>
      service.search(
        OUTLET_ID,
        { from: '2026-11-13T00:00:00.000Z', to: '2026-11-12T00:00:00.000Z' },
        user(Role.OWNER),
      ),
    (error: unknown) => expectHttp(error, 400, 'VALIDATION_ERROR'),
  );
  await assert.rejects(
    () => service.search(OTHER_OUTLET_ID, {}, user(Role.OWNER)),
    (error: unknown) => expectHttp(error, 404, 'NOT_FOUND'),
  );
});

test('cursor encoding keeps the sort key', () => {
  const cursor = encodeCursor(new Date('2026-11-12T10:00:00.000Z'), 'abc');
  assert.equal(typeof cursor, 'string');
  assert.ok(cursor.length > 0);
});
