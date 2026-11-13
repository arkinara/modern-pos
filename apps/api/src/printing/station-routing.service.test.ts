import assert from 'node:assert/strict';
import { test } from 'node:test';
import { HttpException } from '@nestjs/common';
import { Role } from '@prisma/client';
import type { AuthenticatedUser } from '../auth/auth.types';
import type { PrismaService } from '../prisma/prisma.service';
import { StationRoutingService } from './station-routing.service';
import type { StationJobWriteDto } from './dto/station-job-write.dto';
import type { StationRoutingWriteDto } from './dto/station-routing-write.dto';
import type { StationWriteDto } from './dto/station-write.dto';

const BUSINESS_ID = '00000000-0000-4000-8000-000000000001';
const OUTLET_ID = '00000000-0000-4000-8000-000000000002';
const OTHER_OUTLET_ID = '00000000-0000-4000-8000-000000000003';
const ORDER_ID = '00000000-0000-4000-8000-000000000010';
const SALE_ID = '00000000-0000-4000-8000-000000000011';
const KITCHEN_ID = '00000000-0000-4000-8000-000000000020';
const BAR_ID = '00000000-0000-4000-8000-000000000021';
const MENU_FOOD_ID = '00000000-0000-4000-8000-000000000030';
const MENU_DRINK_ID = '00000000-0000-4000-8000-000000000031';
const VARIANT_FOOD_ID = '00000000-0000-4000-8000-000000000040';
const VARIANT_DRINK_ID = '00000000-0000-4000-8000-000000000041';
const KEY_ONE = '00000000-0000-4000-8000-000000000050';
const KEY_TWO = '00000000-0000-4000-8000-000000000051';
const PRINT_KEY = '00000000-0000-4000-8000-000000000052';

function owner(): AuthenticatedUser {
  return {
    id: 'user-1',
    businessId: BUSINESS_ID,
    email: 'owner@example.test',
    role: Role.OWNER,
    outletId: OUTLET_ID,
    outletIds: [OUTLET_ID],
    sessionId: 'session-1',
  };
}

function stationWrite(overrides: Partial<StationWriteDto> = {}): StationWriteDto {
  return {
    name: 'Kitchen',
    kind: 'KITCHEN',
    isDefault: false,
    sortOrder: 0,
    ...overrides,
  };
}

function jobWrite(overrides: Partial<StationJobWriteDto> = {}): StationJobWriteDto {
  return {
    kind: 'ORIGINAL',
    saleId: SALE_ID,
    lines: [
      { variantId: VARIANT_FOOD_ID, quantity: 2, modifiers: [{ name: 'Spicy', quantity: 1 }] },
    ],
    ...overrides,
  };
}

interface Row {
  [key: string]: unknown;
}

interface FakeState {
  outlet: { id: string; businessId: string } | null;
  printers: Row[];
  stations: Row[];
  routes: Row[];
  jobs: Row[];
  menuItems: Row[];
  variants: Row[];
  order: Row | null;
  sale: Row | null;
  saleWrites: number;
  stockWrites: number;
  clock: number;
}

function matches(row: Row, where: Record<string, unknown>): boolean {
  return Object.entries(where).every(([key, value]) => {
    const actual = row[key];
    if (value instanceof Date) {
      return actual instanceof Date && actual.getTime() === value.getTime();
    }
    if (typeof value === 'object' && value !== null && !Array.isArray(value)) {
      const filter = value as Record<string, unknown>;
      if ('in' in filter) {
        return (filter.in as unknown[]).includes(actual);
      }
      if ('not' in filter) {
        return actual !== filter.not;
      }
    }
    return actual === value;
  });
}

function sortRows(rows: Row[], orderBy: unknown): Row[] {
  const entries = Array.isArray(orderBy) ? orderBy : orderBy ? [orderBy] : [];
  if (entries.length === 0) {
    return rows;
  }
  return [...rows].sort((left, right) => {
    for (const entry of entries) {
      const [field, direction] = Object.entries(entry as Record<string, 'asc' | 'desc'>)[0] ?? [];
      if (!field) {
        continue;
      }
      const leftValue = left[field];
      const rightValue = right[field];
      const factor = direction === 'desc' ? -1 : 1;
      if (leftValue === rightValue) {
        continue;
      }
      if (leftValue instanceof Date && rightValue instanceof Date) {
        return (leftValue.getTime() - rightValue.getTime()) * factor;
      }
      return (String(leftValue) > String(rightValue) ? 1 : -1) * factor;
    }
    return 0;
  });
}

function withRelations(state: FakeState, row: Row): Row {
  if (!row.printerConfigId) {
    return row;
  }
  const printer = state.printers.find((entry) => entry.id === row.printerConfigId);
  return { ...row, printer: printer ? { model: printer.model } : null };
}

function fakePrisma(): { prisma: PrismaService; state: FakeState } {
  const state: FakeState = {
    outlet: { id: OUTLET_ID, businessId: BUSINESS_ID },
    printers: [{ id: 'printer-1', businessId: BUSINESS_ID, outletId: OUTLET_ID, model: 'LAN-58' }],
    stations: [],
    routes: [],
    jobs: [],
    menuItems: [
      { id: MENU_FOOD_ID, businessId: BUSINESS_ID, name: 'Chicken Rice' },
      { id: MENU_DRINK_ID, businessId: BUSINESS_ID, name: 'Iced Coffee' },
    ],
    variants: [
      {
        id: VARIANT_FOOD_ID,
        name: 'Regular',
        menuItemId: MENU_FOOD_ID,
        menuItem: { id: MENU_FOOD_ID, name: 'Chicken Rice', businessId: BUSINESS_ID },
      },
      {
        id: VARIANT_DRINK_ID,
        name: 'Large',
        menuItemId: MENU_DRINK_ID,
        menuItem: { id: MENU_DRINK_ID, name: 'Iced Coffee', businessId: BUSINESS_ID },
      },
    ],
    order: { id: ORDER_ID, businessId: BUSINESS_ID, outletId: OUTLET_ID, state: 'COMPLETED' },
    sale: {
      id: SALE_ID,
      businessId: BUSINESS_ID,
      outletId: OUTLET_ID,
      orderId: ORDER_ID,
      reference: 'SALE-ORDER-1',
    },
    saleWrites: 0,
    stockWrites: 0,
    clock: 1000,
  };

  const prisma = {
    outlet: {
      findFirst: async (args: { where: Record<string, unknown> }) => {
        return state.outlet && matches(state.outlet, args.where) ? { id: state.outlet.id } : null;
      },
    },
    printer: {
      findFirst: async (args: { where: Record<string, unknown> }) =>
        state.printers.find((row) => matches(row, args.where)) ?? null,
    },
    station: {
      findMany: async (args: { where?: Record<string, unknown>; orderBy?: unknown }) => {
        const rows = state.stations.filter((row) => matches(row, args.where ?? {}));
        return sortRows(rows, args.orderBy).map((row) => ({
          ...withRelations(state, row),
          _count: { routes: state.routes.filter((route) => route.stationId === row.id).length },
        }));
      },
      findFirst: async (args: { where: Record<string, unknown> }) => {
        const row = state.stations.find((entry) => matches(entry, args.where));
        if (!row) {
          return null;
        }
        return {
          ...withRelations(state, row),
          _count: { routes: state.routes.filter((route) => route.stationId === row.id).length },
        };
      },
      create: async (args: { data: Row }) => {
        const row = {
          id: `station-${state.stations.length + 1}`,
          revision: 1,
          createdAt: new Date('2026-01-01T00:00:00Z'),
          updatedAt: new Date('2026-01-01T00:00:00Z'),
          ...args.data,
        };
        state.stations.push(row);
        return row;
      },
      updateMany: async (args: {
        where: Record<string, unknown>;
        data: Record<string, unknown>;
      }) => {
        let count = 0;
        for (const row of state.stations) {
          if (!matches(row, args.where)) {
            continue;
          }
          count += 1;
          const { revision, ...rest } = args.data;
          Object.assign(row, rest);
          if (typeof revision === 'object' && revision !== null && 'increment' in revision) {
            row.revision =
              Number(row.revision) + Number((revision as { increment: number }).increment);
          }
        }
        return { count };
      },
    },
    stationRoute: {
      findMany: async (args: { where?: Record<string, unknown> }) =>
        state.routes
          .filter((row) => matches(row, args.where ?? {}))
          .map((row) => ({
            ...row,
            station: (() => {
              const station = state.stations.find((entry) => entry.id === row.stationId);
              return { name: station?.name, kind: station?.kind };
            })(),
            menuItem: (() => {
              const menuItem = state.menuItems.find((entry) => entry.id === row.menuItemId);
              return { name: menuItem?.name };
            })(),
          })),
      deleteMany: async (args: { where: Record<string, unknown> }) => {
        const before = state.routes.length;
        state.routes = state.routes.filter((row) => !matches(row, args.where));
        return { count: before - state.routes.length };
      },
      createMany: async (args: { data: Row[] }) => {
        for (const data of args.data) {
          state.routes.push({
            id: `route-${state.routes.length + 1}`,
            createdAt: new Date('2026-01-01T00:00:00Z'),
            updatedAt: new Date('2026-01-01T00:00:00Z'),
            ...data,
          });
        }
        return { count: args.data.length };
      },
    },
    menuItem: {
      findMany: async (args: { where: Record<string, unknown> }) =>
        state.menuItems.filter((row) => matches(row, args.where)),
    },
    menuVariant: {
      findMany: async (args: { where: Record<string, unknown> }) =>
        state.variants.filter((row) => matches(row, args.where)),
    },
    order: {
      findFirst: async (args: { where: Record<string, unknown> }) => {
        if (!state.order || !matches(state.order, args.where)) {
          return null;
        }
        return {
          ...state.order,
          sale: state.sale ? { id: state.sale.id, reference: state.sale.reference } : null,
        };
      },
    },
    sale: {
      update: async () => {
        state.saleWrites += 1;
        return state.sale;
      },
    },
    stockMovement: {
      create: async () => {
        state.stockWrites += 1;
        return {};
      },
    },
    stockBalance: {
      update: async () => {
        state.stockWrites += 1;
        return {};
      },
    },
    stationJob: {
      findMany: async (args: {
        where?: Record<string, unknown>;
        orderBy?: unknown;
        take?: number;
      }) => {
        let rows = state.jobs.filter((row) => matches(row, args.where ?? {}));
        rows = sortRows(rows, args.orderBy);
        if (args.take) {
          rows = rows.slice(0, args.take);
        }
        return rows.map((row) => ({
          ...row,
          station: {
            name: state.stations.find((station) => station.id === row.stationId)?.name ?? 'Unknown',
          },
        }));
      },
      findFirst: async (args: { where: Record<string, unknown> }) => {
        const row = state.jobs.find((entry) => matches(entry, args.where));
        if (!row) {
          return null;
        }
        return {
          ...row,
          station: {
            name: state.stations.find((station) => station.id === row.stationId)?.name ?? 'Unknown',
          },
        };
      },
      createMany: async (args: { data: Row[] }) => {
        for (const data of args.data) {
          state.jobs.push({
            state: 'QUEUED',
            attempts: 0,
            lastError: null,
            copy: false,
            reprintOfId: null,
            createdAt: new Date('2026-01-01T00:00:00Z'),
            updatedAt: new Date('2026-01-01T00:00:00Z'),
            ...data,
          });
        }
        return { count: args.data.length };
      },
      create: async (args: { data: Row }) => {
        const row = {
          state: 'QUEUED',
          attempts: 0,
          lastError: null,
          copy: false,
          reprintOfId: null,
          createdAt: new Date('2026-01-01T00:00:00Z'),
          updatedAt: new Date('2026-01-01T00:00:00Z'),
          ...args.data,
        };
        state.jobs.push(row);
        return row;
      },
      update: async (args: { where: { id: string }; data: Row }) => {
        const row = state.jobs.find((entry) => entry.id === args.where.id);
        if (!row) {
          throw new Error('missing job');
        }
        Object.assign(row, args.data);
        return row;
      },
    },
    $transaction: async <T>(callback: (tx: unknown) => Promise<T>): Promise<T> => callback(prisma),
  };

  return { prisma: prisma as unknown as PrismaService, state };
}

function statusOf(error: unknown): number | undefined {
  return error instanceof HttpException ? error.getStatus() : undefined;
}

test('stations are owner-managed, isolated by outlet and keep one default', async () => {
  const { prisma, state } = fakePrisma();
  const service = new StationRoutingService(prisma);

  const kitchen = await service.createStation(
    OUTLET_ID,
    stationWrite({ isDefault: true }),
    owner(),
  );
  const bar = await service.createStation(
    OUTLET_ID,
    stationWrite({ name: 'Bar', kind: 'BAR', isDefault: false, sortOrder: 1 }),
    owner(),
  );
  assert.equal(kitchen.name, 'Kitchen');
  assert.equal(bar.name, 'Bar');
  assert.equal(state.stations.filter((row) => row.isDefault).length, 1);
  assert.equal(state.stations.find((row) => row.isDefault)?.id, kitchen.id);

  const otherBar = await service.createStation(
    OUTLET_ID,
    stationWrite({
      name: 'Bar 2',
      kind: 'BAR',
      isDefault: true,
      sortOrder: 2,
    }),
    owner(),
  );
  assert.equal(state.stations.filter((row) => row.isDefault).length, 1);
  assert.equal(state.stations.find((row) => row.isDefault)?.id, otherBar.id);

  state.stations.push({
    id: 'foreign',
    businessId: BUSINESS_ID,
    outletId: OTHER_OUTLET_ID,
    name: 'Other outlet',
    kind: 'KITCHEN',
    isDefault: false,
    sortOrder: 0,
    revision: 1,
  });
  const stations = await service.listStations(OUTLET_ID, owner());
  assert.equal(stations.length, 3);
  assert.ok(stations.every((station) => station.name !== 'Other outlet'));
});

test('cross-outlet station update and printer reference are rejected with 404', async () => {
  const { prisma, state } = fakePrisma();
  const service = new StationRoutingService(prisma);
  const kitchen = await service.createStation(OUTLET_ID, stationWrite(), owner());
  state.stations.push({
    id: 'foreign-station',
    businessId: BUSINESS_ID,
    outletId: OTHER_OUTLET_ID,
    name: 'Foreign',
    kind: 'KITCHEN',
    isDefault: false,
    sortOrder: 0,
    revision: 1,
  });

  await assert.rejects(
    service.updateStation(
      OUTLET_ID,
      'foreign-station',
      { ...stationWrite(), revision: 1 },
      owner(),
    ),
    (error: unknown) => statusOf(error) === 404,
  );
  await assert.rejects(
    service.createStation(
      OUTLET_ID,
      { ...stationWrite({ name: 'No printer' }), printerConfigId: 'missing-printer' },
      owner(),
    ),
    (error: unknown) => statusOf(error) === 404,
  );
  assert.equal(kitchen.revision, 1);
});

test('routing is owner-managed and rejects stations from another outlet', async () => {
  const { prisma, state } = fakePrisma();
  const service = new StationRoutingService(prisma);
  const kitchen = await service.createStation(
    OUTLET_ID,
    stationWrite({ isDefault: true }),
    owner(),
  );
  const bar = await service.createStation(
    OUTLET_ID,
    stationWrite({ name: 'Bar', kind: 'BAR' }),
    owner(),
  );

  const routes = await service.replaceRoutes(
    OUTLET_ID,
    {
      routes: [{ menuItemId: MENU_FOOD_ID, stationId: kitchen.id }],
    },
    owner(),
  );
  assert.equal(routes.length, 1);
  assert.equal(routes[0]?.menuItemName, 'Chicken Rice');
  assert.equal(routes[0]?.stationName, 'Kitchen');

  const replaced = await service.replaceRoutes(
    OUTLET_ID,
    {
      routes: [
        { menuItemId: MENU_FOOD_ID, stationId: bar.id },
        { menuItemId: MENU_DRINK_ID, stationId: bar.id },
      ],
    },
    owner(),
  );
  assert.equal(replaced.length, 2);
  assert.ok(replaced.every((route) => route.stationId === bar.id));

  state.stations.push({
    id: 'foreign-station',
    businessId: BUSINESS_ID,
    outletId: OTHER_OUTLET_ID,
    name: 'Foreign',
    kind: 'KITCHEN',
    isDefault: false,
    sortOrder: 0,
    revision: 1,
  });
  await assert.rejects(
    service.replaceRoutes(
      OUTLET_ID,
      { routes: [{ menuItemId: MENU_FOOD_ID, stationId: 'foreign-station' }] },
      owner(),
    ),
    (error: unknown) => statusOf(error) === 404,
  );
});

test('routed lines target their station, unrouted lines use the default fallback', async () => {
  const { prisma } = fakePrisma();
  const service = new StationRoutingService(prisma);
  const kitchen = await service.createStation(OUTLET_ID, stationWrite(), owner());
  const bar = await service.createStation(
    OUTLET_ID,
    stationWrite({ name: 'Bar', kind: 'BAR', isDefault: true, sortOrder: 1 }),
    owner(),
  );
  await service.replaceRoutes(
    OUTLET_ID,
    { routes: [{ menuItemId: MENU_FOOD_ID, stationId: kitchen.id }] },
    owner(),
  );

  const jobs = await service.createJobs(
    OUTLET_ID,
    ORDER_ID,
    KEY_ONE,
    {
      kind: 'ORIGINAL',
      saleId: SALE_ID,
      lines: [
        { variantId: VARIANT_FOOD_ID, quantity: 2, modifiers: [{ name: 'Spicy', quantity: 1 }] },
        { variantId: VARIANT_DRINK_ID, quantity: 1 },
      ],
    },
    owner(),
  );

  assert.equal(jobs.length, 2);
  const food = jobs.find((job) => job.variantId === VARIANT_FOOD_ID);
  const drink = jobs.find((job) => job.variantId === VARIANT_DRINK_ID);
  assert.equal(food?.stationId, kitchen.id);
  assert.equal(food?.itemName, 'Chicken Rice');
  assert.equal(food?.orderReference, 'SALE-ORDER-1');
  assert.deepEqual(food?.modifiers, [{ name: 'Spicy', quantity: 1 }]);
  assert.equal(drink?.stationId, bar.id);
});

test('unknown order references and variants create no station job', async () => {
  const { prisma, state } = fakePrisma();
  const service = new StationRoutingService(prisma);
  await service.createStation(OUTLET_ID, stationWrite({ isDefault: true }), owner());

  await assert.rejects(
    service.createJobs(
      OUTLET_ID,
      '00000000-0000-4000-8000-000000000099',
      KEY_ONE,
      jobWrite(),
      owner(),
    ),
    (error: unknown) => statusOf(error) === 404,
  );
  await assert.rejects(
    service.createJobs(
      OUTLET_ID,
      ORDER_ID,
      KEY_TWO,
      jobWrite({ lines: [{ variantId: '00000000-0000-4000-8000-000000000098', quantity: 1 }] }),
      owner(),
    ),
    (error: unknown) => statusOf(error) === 404,
  );
  assert.equal(state.jobs.length, 0);
});

test('batch creation is idempotent and rejects a conflicting replay', async () => {
  const { prisma, state } = fakePrisma();
  const service = new StationRoutingService(prisma);
  await service.createStation(OUTLET_ID, stationWrite({ isDefault: true }), owner());

  const first = await service.createJobs(OUTLET_ID, ORDER_ID, KEY_ONE, jobWrite(), owner());
  const replay = await service.createJobs(OUTLET_ID, ORDER_ID, KEY_ONE, jobWrite(), owner());
  assert.deepEqual(
    replay.map((job) => job.id),
    first.map((job) => job.id),
  );
  assert.equal(state.jobs.length, 1);

  await assert.rejects(
    service.createJobs(
      OUTLET_ID,
      ORDER_ID,
      KEY_ONE,
      jobWrite({ lines: [{ variantId: VARIANT_FOOD_ID, quantity: 5 }] }),
      owner(),
    ),
    (error: unknown) => statusOf(error) === 409,
  );
});

test('amend and cancel jobs keep the original order reference and never touch sales or stock', async () => {
  const { prisma, state } = fakePrisma();
  const service = new StationRoutingService(prisma);
  await service.createStation(OUTLET_ID, stationWrite({ isDefault: true }), owner());

  const original = await service.createJobs(OUTLET_ID, ORDER_ID, KEY_ONE, jobWrite(), owner());
  const amend = await service.createJobs(
    OUTLET_ID,
    ORDER_ID,
    KEY_TWO,
    jobWrite({ kind: 'AMEND', lines: [{ variantId: VARIANT_FOOD_ID, quantity: 3 }] }),
    owner(),
  );
  const cancel = await service.createJobs(
    OUTLET_ID,
    ORDER_ID,
    PRINT_KEY,
    jobWrite({ kind: 'CANCEL', lines: [{ variantId: VARIANT_FOOD_ID, quantity: 1 }] }),
    owner(),
  );

  assert.equal(original[0]?.kind, 'ORIGINAL');
  assert.equal(amend[0]?.kind, 'AMEND');
  assert.equal(cancel[0]?.kind, 'CANCEL');
  assert.equal(amend[0]?.orderReference, original[0]?.orderReference);
  assert.equal(cancel[0]?.orderReference, original[0]?.orderReference);
  assert.equal(state.saleWrites, 0);
  assert.equal(state.stockWrites, 0);
  assert.equal(state.sale?.state, undefined);
});

test('retry and reprint change only station jobs and keep station queues independent', async () => {
  const { prisma, state } = fakePrisma();
  const service = new StationRoutingService(prisma);
  const kitchen = await service.createStation(
    OUTLET_ID,
    stationWrite({ isDefault: true }),
    owner(),
  );
  const bar = await service.createStation(
    OUTLET_ID,
    stationWrite({ name: 'Bar', kind: 'BAR', sortOrder: 1 }),
    owner(),
  );
  await service.replaceRoutes(
    OUTLET_ID,
    {
      routes: [
        { menuItemId: MENU_FOOD_ID, stationId: kitchen.id },
        { menuItemId: MENU_DRINK_ID, stationId: bar.id },
      ],
    },
    owner(),
  );

  const jobs = await service.createJobs(
    OUTLET_ID,
    ORDER_ID,
    KEY_ONE,
    {
      kind: 'ORIGINAL',
      lines: [
        { variantId: VARIANT_FOOD_ID, quantity: 1 },
        { variantId: VARIANT_DRINK_ID, quantity: 1 },
      ],
    },
    owner(),
  );
  const kitchenJob = jobs.find((job) => job.stationId === kitchen.id);
  const barJob = jobs.find((job) => job.stationId === bar.id);
  assert.ok(kitchenJob);
  assert.ok(barJob);

  await service.updateJobState(
    OUTLET_ID,
    kitchenJob.id,
    { state: 'FAILED', attempts: 2, lastError: 'paper out' },
    owner(),
  );
  const kitchenQueue = await service.listJobs(OUTLET_ID, kitchen.id, {}, owner());
  const barQueue = await service.listJobs(OUTLET_ID, bar.id, {}, owner());
  assert.equal(kitchenQueue.items[0]?.state, 'FAILED');
  assert.equal(barQueue.items[0]?.state, 'QUEUED');

  const retried = await service.retryJob(OUTLET_ID, kitchenJob.id, owner());
  assert.equal(retried.state, 'QUEUED');
  assert.equal(retried.lastError, null);

  const copy = await service.reprintJob(OUTLET_ID, barJob.id, KEY_TWO, owner());
  assert.equal(copy.copy, true);
  assert.equal(copy.reprintOfId, barJob.id);
  assert.equal(copy.orderReference, barJob.orderReference);
  const replay = await service.reprintJob(OUTLET_ID, barJob.id, KEY_TWO, owner());
  assert.equal(replay.id, copy.id);
  assert.equal(state.jobs.length, 3);
  assert.equal(state.saleWrites, 0);
  assert.equal(state.stockWrites, 0);
});

test('retry refuses a job that is not failed or uncertain', async () => {
  const { prisma } = fakePrisma();
  const service = new StationRoutingService(prisma);
  await service.createStation(OUTLET_ID, stationWrite({ isDefault: true }), owner());
  const jobs = await service.createJobs(OUTLET_ID, ORDER_ID, KEY_ONE, jobWrite(), owner());

  await assert.rejects(
    service.retryJob(OUTLET_ID, jobs[0]!.id, owner()),
    (error: unknown) => statusOf(error) === 409,
  );
});

test('unknown station jobs are rejected without creating a reprint', async () => {
  const { prisma, state } = fakePrisma();
  const service = new StationRoutingService(prisma);
  await service.createStation(OUTLET_ID, stationWrite({ isDefault: true }), owner());

  await assert.rejects(
    service.reprintJob(OUTLET_ID, '00000000-0000-4000-8000-000000000077', KEY_ONE, owner()),
    (error: unknown) => statusOf(error) === 404,
  );
  assert.equal(state.jobs.length, 0);
});
