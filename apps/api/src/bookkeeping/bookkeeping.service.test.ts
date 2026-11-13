import assert from 'node:assert/strict';
import { test } from 'node:test';
import { HttpException } from '@nestjs/common';
import { CostingMethod, Prisma, Role } from '@prisma/client';
import type { AuthenticatedUser } from '../auth/auth.types';
import type { PrismaService } from '../prisma/prisma.service';
import type { ReportsService } from '../reports/reports.service';
import { BookkeepingService } from './bookkeeping.service';
import { buildCsv } from './csv';

const BUSINESS_ID = '00000000-0000-4000-8000-000000000001';
const OUTLET_A = '00000000-0000-4000-8000-000000000002';
const OUTLET_B = '00000000-0000-4000-8000-000000000005';
const OWNER_ID = '00000000-0000-4000-8000-000000000003';
const CATEGORY_ID = '00000000-0000-4000-8000-0000000000d1';
const ITEM_ID = '00000000-0000-4000-8000-000000000050';

function owner(outletIds = [OUTLET_A]): AuthenticatedUser {
  return {
    id: OWNER_ID,
    businessId: BUSINESS_ID,
    email: 'owner@example.test',
    role: Role.OWNER,
    outletId: OUTLET_A,
    outletIds,
    sessionId: 'session-1',
  };
}

function outlet(id = OUTLET_A, name = 'Main Outlet') {
  return {
    id,
    name,
    businessId: BUSINESS_ID,
    timezone: 'Asia/Jakarta',
    currency: 'IDR',
    currencyExponent: 0,
  };
}

function reportFor(value: number, saleCount = 1) {
  return {
    from: '2026-01-02',
    to: '2026-01-02',
    timezone: 'Asia/Jakarta',
    currency: 'IDR',
    currencyExponent: 0,
    grossItemSalesMinor: value,
    reversalItemValueMinor: 0,
    refundMoneyMinor: 0,
    netItemSalesMinor: value,
    saleCount,
    reversalCount: 0,
    averageBillMinor: saleCount === 0 ? 0 : value,
    paymentBreakdown: [
      { kind: 'CASH', receivedMinor: value },
      { kind: 'MANUAL_EXTERNAL', receivedMinor: 0 },
      { kind: 'ONLINE', receivedMinor: 0 },
    ],
    topItems: [],
    generatedAt: '2026-01-02T12:00:00.000Z',
  };
}

function fakeReports(value = 1000, byOutlet?: Record<string, number>): ReportsService {
  return {
    dailyReport: async (outletId: string) => reportFor(byOutlet?.[outletId] ?? value),
    exportCsv: async () => ({ filename: 'sales.csv', csv: 'reference\r\n' }),
  } as unknown as ReportsService;
}

interface FakeOptions {
  setting?: { costingMethod: CostingMethod } | null;
  categories?: { id: string; name: string; active: boolean; createdAt: Date }[];
  expenses?: {
    id: string;
    categoryId: string;
    category: { id: string; name: string };
    amountMinor: bigint;
    incurredOn: Date;
    note: string;
    createdAt: Date;
  }[];
  outlets?: ReturnType<typeof outlet>[];
  movements?: { stockItemId: string; delta: Prisma.Decimal; type: string; createdAt: Date }[];
  receipts?: {
    stockItemId: string;
    delta: Prisma.Decimal;
    sourceId: string;
    createdAt: Date;
  }[];
  balances?: { stockItemId: string; quantity: Prisma.Decimal }[];
  shifts?: { status: string }[];
  attendance?: number;
}

function fakePrisma(options: FakeOptions = {}): PrismaService {
  const setting = options.setting === undefined ? null : options.setting;
  const categories = options.categories ?? [
    { id: CATEGORY_ID, name: 'Payroll', active: true, createdAt: new Date() },
  ];
  const expenses = options.expenses ?? [];
  const outlets = options.outlets ?? [outlet()];
  const movements = options.movements ?? [];
  const receipts = options.receipts ?? [];
  const balances = options.balances ?? [];
  const shifts = options.shifts ?? [];
  const attendance = options.attendance ?? 0;

  return {
    outlet: {
      findFirst: async (args: { where: { id: string; businessId: string } }) =>
        outlets.find(
          (row) => row.id === args.where.id && row.businessId === args.where.businessId,
        ) ?? null,
      findMany: async (args: { where: { id: { in: string[] }; businessId: string } }) =>
        outlets.filter(
          (row) => args.where.id.in.includes(row.id) && row.businessId === args.where.businessId,
        ),
    },
    bookkeepingSetting: {
      findUnique: async () =>
        setting === null
          ? null
          : {
              id: 'setting-1',
              businessId: BUSINESS_ID,
              outletId: OUTLET_A,
              costingMethod: setting.costingMethod,
              version: 1,
            },
      findMany: async () =>
        setting === null ? [] : [{ outletId: OUTLET_A, costingMethod: setting.costingMethod }],
      upsert: async (args: { create: { costingMethod: CostingMethod } }) => ({
        id: 'setting-1',
        businessId: BUSINESS_ID,
        outletId: OUTLET_A,
        costingMethod: args.create.costingMethod,
        version: 1,
      }),
    },
    expenseCategory: {
      findMany: async () => categories,
      create: async (args: { data: { name: string } }) => ({
        id: 'category-new',
        businessId: BUSINESS_ID,
        name: args.data.name,
        active: true,
        createdAt: new Date(),
      }),
    },
    expense: {
      findMany: async () => expenses,
      create: async (args: { data: Record<string, unknown> }) => ({
        id: 'expense-1',
        outletId: OUTLET_A,
        categoryId: CATEGORY_ID,
        amountMinor: args.data.amountMinor as bigint,
        incurredOn: args.data.incurredOn as Date,
        note: String(args.data.note ?? ''),
        createdById: OWNER_ID,
        createdAt: new Date(),
      }),
    },
    stockMovement: {
      findMany: async (args: {
        where: {
          type?: { in: string[] } | string;
          createdAt?: { lt?: Date; gte?: Date; ltInclusive?: Date };
        };
      }) => {
        const type = args.where.type;
        if (type === 'RECEIPT') {
          return receipts.filter(
            (row) => !args.where.createdAt?.lt || row.createdAt < args.where.createdAt.lt,
          );
        }
        if (type && typeof type === 'object' && 'in' in type) {
          return movements.filter((row) => type.in.includes(row.type));
        }
        return [];
      },
    },
    purchaseOrderLine: {
      findMany: async () => [
        {
          id: 'line-1',
          stockItemId: ITEM_ID,
          unitPrice: new Prisma.Decimal('100'),
          unitsPerSupplierUnit: new Prisma.Decimal('1'),
        },
        {
          id: 'line-2',
          stockItemId: ITEM_ID,
          unitPrice: new Prisma.Decimal('200'),
          unitsPerSupplierUnit: new Prisma.Decimal('1'),
        },
      ],
    },
    stockBalance: {
      findMany: async () => balances,
    },
    shift: {
      findMany: async () => shifts,
    },
    attendanceRecord: {
      count: async () => attendance,
    },
  } as unknown as PrismaService;
}

function movement(type: string, quantity: string, createdAt = new Date('2026-01-02T03:00:00Z')) {
  return {
    stockItemId: ITEM_ID,
    delta: new Prisma.Decimal(quantity),
    type,
    createdAt,
  };
}

function receipt(delta: string, sourceId: string) {
  return {
    stockItemId: ITEM_ID,
    delta: new Prisma.Decimal(delta),
    sourceId,
    createdAt: new Date('2026-01-01T03:00:00Z'),
  };
}

test('profit stays unavailable until costing and expense categories are defined', async () => {
  const service = new BookkeepingService(fakePrisma({ setting: null }), fakeReports());
  const profit = await service.getProfitReport(
    OUTLET_A,
    { from: '2026-01-02', to: '2026-01-02' },
    owner(),
  );

  assert.equal(profit.marginAvailable, false);
  assert.deepEqual(profit.unavailableReasons, ['COSTING_METHOD_UNDEFINED']);
  assert.equal(profit.cogs, null);
  assert.equal(profit.netProfitMinor, null);
  assert.equal(profit.netMarginBps, null);
});

test('moving average COGS and margin reconcile to the documented formula', async () => {
  const service = new BookkeepingService(
    fakePrisma({
      setting: { costingMethod: CostingMethod.MOVING_AVERAGE },
      movements: [movement('SALE', '-2'), movement('WASTE', '-1')],
      receipts: [receipt('1000', 'line-1'), receipt('3000', 'line-2')],
      expenses: [
        {
          id: 'expense-1',
          categoryId: CATEGORY_ID,
          category: { id: CATEGORY_ID, name: 'Payroll' },
          amountMinor: 100n,
          incurredOn: new Date('2026-01-02T00:00:00Z'),
          note: '',
          createdAt: new Date(),
        },
      ],
    }),
    fakeReports(1000),
  );

  const profit = await service.getProfitReport(
    OUTLET_A,
    { from: '2026-01-02', to: '2026-01-02' },
    owner(),
  );

  assert.equal(profit.marginAvailable, true);
  assert.equal(profit.cogs?.saleCostMinor, 350);
  assert.equal(profit.waste?.costMinor, 175);
  assert.equal(profit.expenses.manualMinor, 100);
  assert.equal(profit.expenses.totalMinor, 275);
  assert.equal(profit.grossProfitMinor, 650);
  assert.equal(profit.netProfitMinor, 375);
  assert.equal(profit.netMarginBps, 3750);
});

test('changing the costing method changes COGS predictably', async () => {
  const options = {
    movements: [movement('SALE', '-2')],
    receipts: [receipt('1000', 'line-1'), receipt('3000', 'line-2')],
  };
  const moving = new BookkeepingService(
    fakePrisma({ ...options, setting: { costingMethod: CostingMethod.MOVING_AVERAGE } }),
    fakeReports(1000),
  );
  const last = new BookkeepingService(
    fakePrisma({ ...options, setting: { costingMethod: CostingMethod.LAST_PURCHASE } }),
    fakeReports(1000),
  );

  const movingProfit = await moving.getProfitReport(
    OUTLET_A,
    { from: '2026-01-02', to: '2026-01-02' },
    owner(),
  );
  const lastProfit = await last.getProfitReport(
    OUTLET_A,
    { from: '2026-01-02', to: '2026-01-02' },
    owner(),
  );

  assert.equal(movingProfit.cogs?.saleCostMinor, 350);
  assert.equal(lastProfit.cogs?.saleCostMinor, 400);
  assert.equal(movingProfit.netProfitMinor! - lastProfit.netProfitMinor!, 50);
});

test('consolidated totals equal the sum of per-outlet reports', async () => {
  const service = new BookkeepingService(
    fakePrisma({
      outlets: [outlet(OUTLET_A, 'Main'), outlet(OUTLET_B, 'Second')],
      shifts: [{ status: 'CLOSED' }],
      attendance: 2,
    }),
    fakeReports(0, { [OUTLET_A]: 1000, [OUTLET_B]: 2500 }),
  );

  const consolidated = await service.getConsolidated(
    OUTLET_A,
    { from: '2026-01-02', to: '2026-01-02' },
    owner([OUTLET_A, OUTLET_B]),
  );

  assert.equal(consolidated.outletCount, 2);
  assert.equal(consolidated.perOutlet[0]?.grossItemSalesMinor, 1000);
  assert.equal(consolidated.perOutlet[1]?.grossItemSalesMinor, 2500);
  assert.equal(consolidated.consolidated.grossItemSalesMinor, 3500);
  assert.equal(consolidated.consolidated.saleCount, 2);
  assert.equal(consolidated.consolidated.shiftsOpened, 2);
  assert.equal(consolidated.consolidated.attendanceClockIns, 4);
});

test('consolidated with no outlets returns zeroes instead of dividing by zero', async () => {
  const service = new BookkeepingService(fakePrisma({ outlets: [outlet()] }), fakeReports());
  const consolidated = await service.getConsolidated(
    OUTLET_A,
    { from: '2026-01-02', to: '2026-01-02' },
    { ...owner([]), outletId: null },
  );

  assert.equal(consolidated.outletCount, 0);
  assert.equal(consolidated.consolidated.grossItemSalesMinor, 0);
  assert.equal(consolidated.consolidated.averageBillMinor, 0);
  assert.equal(consolidated.consolidated.stockValueMinor, 0);
});

test('a cashier-scoped outlet lookup is rejected before reading bookkeeping rows', async () => {
  const service = new BookkeepingService(fakePrisma({ outlets: [] }), fakeReports());

  await assert.rejects(
    () => service.getConfiguration(OUTLET_B, owner([OUTLET_A])),
    (error: unknown) =>
      error instanceof HttpException &&
      error.getStatus() === 404 &&
      (error.getResponse() as { code: string }).code === 'NOT_FOUND',
  );
});

test('CSV builder quotes commas, quotes, newlines and formula prefixes', () => {
  const csv = buildCsv(['name', 'value'], [['Rice, "special"\nnote', '=1+1']]);
  assert.equal(csv, 'name,value\r\n"Rice, ""special""\nnote",\'=1+1\r\n');
});
