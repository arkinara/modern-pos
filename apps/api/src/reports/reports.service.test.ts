import assert from 'node:assert/strict';
import { test } from 'node:test';
import { HttpException } from '@nestjs/common';
import { PaymentKind, Role, SaleState } from '@prisma/client';
import type { AuthenticatedUser } from '../auth/auth.types';
import type { PrismaService } from '../prisma/prisma.service';
import {
  ReportsService,
  assertReportRange,
  formatLocalTimestamp,
  halfUpAverage,
} from './reports.service';

const BUSINESS_ID = '00000000-0000-4000-8000-000000000001';
const OTHER_BUSINESS_ID = '00000000-0000-4000-8000-000000000010';
const OUTLET_ID = '00000000-0000-4000-8000-000000000002';
const OWNER_ID = '00000000-0000-4000-8000-000000000003';

function owner(): AuthenticatedUser {
  return {
    id: OWNER_ID,
    businessId: BUSINESS_ID,
    email: 'owner@example.test',
    role: Role.OWNER,
    outletId: OUTLET_ID,
    outletIds: [OUTLET_ID],
    sessionId: 'session-1',
  };
}

interface SaleFixture {
  id: string;
  businessId: string;
  outletId: string;
  reference: string;
  state: SaleState;
  currency: string;
  currencyExponent: number;
  timezone: string;
  completedAt: Date;
  subtotalMinor: bigint;
  serviceMinor: bigint;
  taxMinor: bigint;
  totalMinor: bigint;
  lines: {
    id: string;
    name: string;
    variantName: string;
    quantity: number;
    unitPriceMinor: bigint;
    lineSubtotalMinor: bigint;
  }[];
  payment: {
    kind: PaymentKind;
    status: string;
    amountMinor: bigint;
    tenderedMinor: bigint | null;
    changeMinor: bigint | null;
    reference: string | null;
  } | null;
}

function sale(overrides: Partial<SaleFixture> = {}): SaleFixture {
  const subtotalMinor = overrides.subtotalMinor ?? 18000n;
  return {
    id: '00000000-0000-4000-8000-000000000200',
    businessId: BUSINESS_ID,
    outletId: OUTLET_ID,
    reference: 'SALE-SEED-A',
    state: SaleState.COMPLETED,
    currency: 'IDR',
    currencyExponent: 0,
    timezone: 'Asia/Jakarta',
    completedAt: new Date('2026-01-02T03:00:00.000Z'),
    subtotalMinor,
    serviceMinor: 0n,
    taxMinor: 0n,
    totalMinor: subtotalMinor,
    lines: [
      {
        id: '00000000-0000-4000-8000-000000000201',
        name: 'Iced Coffee',
        variantName: 'Regular',
        quantity: 1,
        unitPriceMinor: subtotalMinor,
        lineSubtotalMinor: subtotalMinor,
      },
    ],
    payment: {
      kind: PaymentKind.CASH,
      status: 'RECORDED',
      amountMinor: subtotalMinor,
      tenderedMinor: subtotalMinor + 2000n,
      changeMinor: 2000n,
      reference: null,
    },
    ...overrides,
  };
}

function createFakePrisma(sales: SaleFixture[]): PrismaService {
  return {
    outlet: {
      findFirst: async (args: { where: { id: string; businessId: string } }) =>
        args.where.id === OUTLET_ID && args.where.businessId === BUSINESS_ID
          ? {
              id: OUTLET_ID,
              name: 'Main Outlet',
              businessId: BUSINESS_ID,
              timezone: 'Asia/Jakarta',
              currency: 'IDR',
              currencyExponent: 0,
            }
          : null,
    },
    sale: {
      findMany: async (args: {
        where: {
          businessId: string;
          outletId: string;
          state: SaleState;
          completedAt: { gte: Date; lt: Date };
        };
      }) => {
        return sales
          .filter(
            (row) =>
              row.businessId === args.where.businessId &&
              row.outletId === args.where.outletId &&
              row.state === args.where.state &&
              row.completedAt.getTime() >= args.where.completedAt.gte.getTime() &&
              row.completedAt.getTime() < args.where.completedAt.lt.getTime(),
          )
          .sort((a, b) => b.completedAt.getTime() - a.completedAt.getTime())
          .map((row) => structuredClone(row));
      },
    },
  } as unknown as PrismaService;
}

function parseCsv(input: string): string[][] {
  const rows: string[][] = [];
  let row: string[] = [];
  let cell = '';
  let quoted = false;

  for (let index = 0; index < input.length; index += 1) {
    const char = input[index]!;

    if (quoted) {
      if (char === '"') {
        if (input[index + 1] === '"') {
          cell += '"';
          index += 1;
        } else {
          quoted = false;
        }
      } else {
        cell += char;
      }
      continue;
    }

    if (char === '"') {
      quoted = true;
    } else if (char === ',') {
      row.push(cell);
      cell = '';
    } else if (char === '\r' && input[index + 1] === '\n') {
      row.push(cell);
      rows.push(row);
      row = [];
      cell = '';
      index += 1;
    } else {
      cell += char;
    }
  }

  return rows;
}

test('daily report aggregates completed sales, payment kinds and menu quantities', async () => {
  const service = new ReportsService(
    createFakePrisma([
      sale({
        id: '00000000-0000-4000-8000-000000000210',
        reference: 'SALE-A',
        subtotalMinor: 18000n,
        lines: [
          {
            id: '00000000-0000-4000-8000-000000000211',
            name: 'Iced Coffee',
            variantName: 'Regular',
            quantity: 2,
            unitPriceMinor: 9000n,
            lineSubtotalMinor: 18000n,
          },
        ],
        payment: {
          kind: PaymentKind.CASH,
          status: 'RECORDED',
          amountMinor: 18000n,
          tenderedMinor: 20000n,
          changeMinor: 2000n,
          reference: null,
        },
      }),
      sale({
        id: '00000000-0000-4000-8000-000000000220',
        reference: 'SALE-B',
        subtotalMinor: 35000n,
        lines: [
          {
            id: '00000000-0000-4000-8000-000000000221',
            name: 'Chicken Rice',
            variantName: 'Default',
            quantity: 1,
            unitPriceMinor: 35000n,
            lineSubtotalMinor: 35000n,
          },
          {
            id: '00000000-0000-4000-8000-000000000222',
            name: 'Iced Coffee',
            variantName: 'Large',
            quantity: 1,
            unitPriceMinor: 0n,
            lineSubtotalMinor: 0n,
          },
        ],
        payment: {
          kind: PaymentKind.MANUAL_EXTERNAL,
          status: 'RECORDED',
          amountMinor: 35000n,
          tenderedMinor: null,
          changeMinor: null,
          reference: 'BANK-1',
        },
      }),
    ]),
  );

  const report = await service.dailyReport(
    OUTLET_ID,
    { from: '2026-01-02', to: '2026-01-02' },
    owner(),
  );

  assert.equal(report.timezone, 'Asia/Jakarta');
  assert.equal(report.currency, 'IDR');
  assert.equal(report.currencyExponent, 0);
  assert.equal(report.grossItemSalesMinor, 53000);
  assert.equal(report.reversalItemValueMinor, 0);
  assert.equal(report.netItemSalesMinor, 53000);
  assert.equal(report.saleCount, 2);
  assert.equal(report.reversalCount, 0);
  assert.equal(report.averageBillMinor, 26500);
  assert.deepEqual(report.paymentBreakdown, [
    { kind: PaymentKind.CASH, receivedMinor: 18000 },
    { kind: PaymentKind.MANUAL_EXTERNAL, receivedMinor: 35000 },
  ]);
  assert.deepEqual(report.topItems, [
    { name: 'Iced Coffee', quantity: 3 },
    { name: 'Chicken Rice', quantity: 1 },
  ]);
  assert.ok(!Number.isNaN(Date.parse(report.generatedAt)));
});

test('empty range returns a zeroed report instead of an error', async () => {
  const service = new ReportsService(createFakePrisma([]));
  const report = await service.dailyReport(
    OUTLET_ID,
    { from: '2026-02-01', to: '2026-02-28' },
    owner(),
  );

  assert.equal(report.grossItemSalesMinor, 0);
  assert.equal(report.netItemSalesMinor, 0);
  assert.equal(report.saleCount, 0);
  assert.equal(report.averageBillMinor, 0);
  assert.deepEqual(report.topItems, []);
  assert.deepEqual(report.paymentBreakdown, [
    { kind: PaymentKind.CASH, receivedMinor: 0 },
    { kind: PaymentKind.MANUAL_EXTERNAL, receivedMinor: 0 },
  ]);
});

test('reversed sales are excluded by the explicit completed-state filter', async () => {
  const service = new ReportsService(
    createFakePrisma([
      sale({ id: '00000000-0000-4000-8000-000000000230', subtotalMinor: 10000n }),
      sale({
        id: '00000000-0000-4000-8000-000000000231',
        reference: 'SALE-REVERSED',
        subtotalMinor: 99000n,
        state: SaleState.REVERSED,
      }),
    ]),
  );

  const report = await service.dailyReport(
    OUTLET_ID,
    { from: '2026-01-02', to: '2026-01-02' },
    owner(),
  );

  assert.equal(report.saleCount, 1);
  assert.equal(report.grossItemSalesMinor, 10000);
});

test('a 23:30 local sale belongs to its local day, not the following UTC day', async () => {
  const lateLocal = sale({
    id: '00000000-0000-4000-8000-000000000240',
    reference: 'SALE-LATE',
    completedAt: new Date('2026-01-02T16:30:00.000Z'),
    subtotalMinor: 11000n,
  });
  const afterMidnight = sale({
    id: '00000000-0000-4000-8000-000000000241',
    reference: 'SALE-EARLY',
    completedAt: new Date('2026-01-02T17:30:00.000Z'),
    subtotalMinor: 22000n,
  });
  const service = new ReportsService(createFakePrisma([lateLocal, afterMidnight]));

  const firstDay = await service.dailyReport(
    OUTLET_ID,
    { from: '2026-01-02', to: '2026-01-02' },
    owner(),
  );
  const secondDay = await service.dailyReport(
    OUTLET_ID,
    { from: '2026-01-03', to: '2026-01-03' },
    owner(),
  );

  assert.equal(firstDay.saleCount, 1);
  assert.equal(firstDay.grossItemSalesMinor, 11000);
  assert.equal(secondDay.saleCount, 1);
  assert.equal(secondDay.grossItemSalesMinor, 22000);
});

test('average bill uses half-up integer division', () => {
  assert.equal(halfUpAverage(100n, 3n), 33n);
  assert.equal(halfUpAverage(101n, 3n), 34n);
  assert.equal(halfUpAverage(1n, 2n), 1n);
  assert.equal(halfUpAverage(0n, 0n), 0n);
});

test('local timestamp is labelled in the outlet timezone', () => {
  assert.equal(
    formatLocalTimestamp(new Date('2026-01-02T16:30:00.000Z'), 'Asia/Jakarta'),
    '2026-01-02 23:30:00',
  );
});

test('csv export preserves commas, quotes and newlines in item names', async () => {
  const trickyName = 'Rice, "special"\nwith note';
  const service = new ReportsService(
    createFakePrisma([
      sale({
        id: '00000000-0000-4000-8000-000000000250',
        reference: 'SALE,CSV',
        subtotalMinor: 42000n,
        lines: [
          {
            id: '00000000-0000-4000-8000-000000000251',
            name: trickyName,
            variantName: 'Large, "extra"',
            quantity: 2,
            unitPriceMinor: 21000n,
            lineSubtotalMinor: 42000n,
          },
        ],
      }),
    ]),
  );

  const exported = await service.exportCsv(
    OUTLET_ID,
    { from: '2026-01-02', to: '2026-01-02' },
    owner(),
  );
  const table = parseCsv(exported.csv);

  assert.equal(exported.filename, 'sales-main-outlet-2026-01-02-to-2026-01-02.csv');
  assert.equal(table[0]?.[0], 'reference');
  assert.equal(table.length, 2);
  assert.equal(table[1]?.[0], 'SALE,CSV');
  assert.equal(table[1]?.[7], trickyName);
  assert.equal(table[1]?.[8], 'Large, "extra"');
  assert.equal(table[1]?.[9], '2');
  assert.equal(table[1]?.[10], '21000');
  assert.equal(table[1]?.[11], '42000');
  assert.equal(table[1]?.[15], '42000');
  assert.equal(table[1]?.[18], '42000');
  assert.equal(table[1]?.[19], '44000');
});

test('csv text that starts like a spreadsheet formula is neutralised', async () => {
  const service = new ReportsService(
    createFakePrisma([
      sale({
        id: '00000000-0000-4000-8000-000000000260',
        reference: '=HYPERLINK("x")',
        subtotalMinor: 1000n,
        lines: [
          {
            id: '00000000-0000-4000-8000-000000000261',
            name: '@item',
            variantName: '-variant',
            quantity: 1,
            unitPriceMinor: 1000n,
            lineSubtotalMinor: 1000n,
          },
        ],
      }),
    ]),
  );

  const exported = await service.exportCsv(
    OUTLET_ID,
    { from: '2026-01-02', to: '2026-01-02' },
    owner(),
  );
  const table = parseCsv(exported.csv);

  assert.equal(table[1]?.[0], `'=HYPERLINK("x")`);
  assert.equal(table[1]?.[7], "'@item");
  assert.equal(table[1]?.[8], "'-variant");
});

test('cross-business outlet IDs return 404 and oversized ranges return 400', async () => {
  const service = new ReportsService(createFakePrisma([]));

  await assert.rejects(
    service.dailyReport(
      OUTLET_ID,
      { from: '2026-01-01', to: '2026-01-01' },
      {
        ...owner(),
        businessId: OTHER_BUSINESS_ID,
      },
    ),
    (error: unknown) => error instanceof HttpException && error.getStatus() === 404,
  );

  assert.throws(
    () => assertReportRange('2024-01-01', '2026-01-01'),
    (error: unknown) => error instanceof HttpException && error.getStatus() === 400,
  );
  assert.doesNotThrow(() => assertReportRange('2025-01-01', '2026-01-01'));
});
