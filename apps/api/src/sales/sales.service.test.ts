import assert from 'node:assert/strict';
import { test } from 'node:test';
import { HttpException } from '@nestjs/common';
import { OrderState, PaymentKind, Role, SaleState } from '@prisma/client';
import type { AuthenticatedUser } from '../auth/auth.types';
import type { PrismaService } from '../prisma/prisma.service';
import { SalesService } from './sales.service';
import { calculateTotals } from './money';

const BUSINESS_ID = '00000000-0000-4000-8000-000000000001';
const OUTLET_ID = '00000000-0000-4000-8000-000000000002';
const CASHIER_ID = '00000000-0000-4000-8000-000000000004';
const OTHER_CASHIER_ID = '00000000-0000-4000-8000-000000000014';
const OWNER_ID = '00000000-0000-4000-8000-000000000003';
const VARIANT_A = '00000000-0000-4000-8000-000000000040';
const VARIANT_B = '00000000-0000-4000-8000-000000000042';
const DEVICE_ID = '00000000-0000-4000-8000-000000000090';
const KEY_ONE = '11111111-1111-4111-8111-111111111111';
const KEY_TWO = '22222222-2222-4222-8222-222222222222';
const KEY_THREE = '33333333-3333-4333-8333-333333333333';

function user(role: Role = Role.CASHIER, id = CASHIER_ID): AuthenticatedUser {
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

interface VariantRow {
  id: string;
  menuItemId: string;
  name: string;
  priceMinor: bigint;
  active: boolean;
  menuItem: {
    name: string;
    archivedAt: Date | null;
    category: { archivedAt: Date | null };
  };
  outletMenus: { outletId: string; enabled: boolean }[];
}

interface OrderLineRow {
  id: string;
  orderId: string;
  variantId: string;
  quantity: number;
  createdAt: Date;
}

interface OrderRow {
  id: string;
  businessId: string;
  outletId: string;
  cashierId: string;
  deviceId: string;
  state: OrderState;
  version: number;
  idempotencyKey: string;
  requestHash: string;
  createdAt: Date;
  updatedAt: Date;
  lines: OrderLineRow[];
}

interface QuoteRow {
  id: string;
  businessId: string;
  outletId: string;
  orderId: string;
  orderVersion: number;
  settingsVersion: number;
  currency: string;
  currencyExponent: number;
  taxBps: number;
  serviceBps: number;
  pricingMode: string;
  rounding: string;
  expiresAt: Date;
  subtotalMinor: bigint;
  serviceMinor: bigint;
  taxMinor: bigint;
  totalMinor: bigint;
  lines: unknown;
  createdAt: Date;
}

interface SaleLineRow {
  id: string;
  saleId: string;
  variantId: string;
  name: string;
  variantName: string;
  quantity: number;
  unitPriceMinor: bigint;
  lineSubtotalMinor: bigint;
  recipeVersion: number | null;
}

interface PaymentRow {
  id: string;
  saleId: string;
  kind: PaymentKind;
  status: 'RECORDED';
  amountMinor: bigint;
  tenderedMinor: bigint | null;
  changeMinor: bigint | null;
  reference: string | null;
  createdAt: Date;
}

interface SaleRow {
  id: string;
  businessId: string;
  outletId: string;
  orderId: string;
  cashierId: string;
  deviceId: string;
  reference: string;
  state: SaleState;
  currency: string;
  currencyExponent: number;
  taxBps: number;
  serviceBps: number;
  pricingMode: string;
  rounding: string;
  timezone: string;
  subtotalMinor: bigint;
  serviceMinor: bigint;
  taxMinor: bigint;
  totalMinor: bigint;
  completedAt: Date;
  createdAt: Date;
  lines: SaleLineRow[];
  payment: PaymentRow | null;
}

interface CheckoutRow {
  id: string;
  businessId: string;
  outletId: string;
  deviceId: string;
  idempotencyKey: string;
  requestHash: string;
  saleId: string | null;
  retainedAt: Date;
  createdAt: Date;
}

interface OutletRow {
  id: string;
  businessId: string;
  timezone: string;
  currency: string;
  currencyExponent: number;
  taxBps: number;
  serviceBps: number;
  pricingMode: string;
  version: number;
}

interface FakeState {
  outlet: OutletRow;
  variants: VariantRow[];
  orders: OrderRow[];
  quotes: QuoteRow[];
  sales: SaleRow[];
  checkouts: CheckoutRow[];
}

function clone<T>(value: T): T {
  return structuredClone(value);
}

function createFakePrisma(options: { serviceBps?: number; taxBps?: number } = {}): {
  prisma: PrismaService;
  state: FakeState;
} {
  let state: FakeState = {
    outlet: {
      id: OUTLET_ID,
      businessId: BUSINESS_ID,
      timezone: 'Asia/Jakarta',
      currency: 'IDR',
      currencyExponent: 0,
      taxBps: options.taxBps ?? 0,
      serviceBps: options.serviceBps ?? 0,
      pricingMode: 'EXCLUSIVE',
      version: 1,
    },
    variants: [
      {
        id: VARIANT_A,
        menuItemId: '00000000-0000-4000-8000-000000000030',
        name: 'Regular',
        priceMinor: 18000n,
        active: true,
        menuItem: {
          name: 'Iced Coffee',
          archivedAt: null,
          category: { archivedAt: null },
        },
        outletMenus: [{ outletId: OUTLET_ID, enabled: true }],
      },
      {
        id: VARIANT_B,
        menuItemId: '00000000-0000-4000-8000-000000000031',
        name: 'Default',
        priceMinor: 35000n,
        active: true,
        menuItem: {
          name: 'Chicken Rice',
          archivedAt: null,
          category: { archivedAt: null },
        },
        outletMenus: [{ outletId: OUTLET_ID, enabled: true }],
      },
    ],
    orders: [],
    quotes: [],
    sales: [],
    checkouts: [],
  };

  let sequence = 0;
  const nextId = (): string =>
    `00000000-0000-4000-8000-${String(500 + sequence++).padStart(12, '0')}`;
  const now = new Date('2026-01-01T00:00:00.000Z');

  const withLines = (order: OrderRow) => ({
    ...clone(order),
    lines: clone(order.lines).sort((a, b) => a.createdAt.getTime() - b.createdAt.getTime()),
  });

  const withReceipt = (sale: SaleRow) => ({
    ...clone(sale),
    lines: clone(sale.lines),
    payment: sale.payment ? clone(sale.payment) : null,
  });

  const matchesOrder = (
    order: OrderRow,
    where: Partial<Record<keyof OrderRow, unknown>>,
  ): boolean => {
    if (where.id !== undefined && order.id !== where.id) return false;
    if (where.outletId !== undefined && order.outletId !== where.outletId) return false;
    if (where.businessId !== undefined && order.businessId !== where.businessId) return false;
    if (where.state !== undefined && order.state !== where.state) return false;
    if (where.version !== undefined && order.version !== where.version) return false;
    return true;
  };

  const client = {
    outlet: {
      findFirst: async (args: { where: { id: string; businessId: string } }) => {
        return state.outlet.id === args.where.id &&
          state.outlet.businessId === args.where.businessId
          ? clone(state.outlet)
          : null;
      },
    },
    menuVariant: {
      findMany: async (args: {
        where: {
          id: { in: string[] };
          menuItem: { businessId: string };
          outletMenus: { some: { outletId: string } };
        };
      }) => {
        return state.variants
          .filter(
            (variant) =>
              args.where.id.in.includes(variant.id) &&
              variant.menuItem.archivedAt === null &&
              variant.menuItem.category.archivedAt === null,
          )
          .map((variant) => ({
            ...clone(variant),
            menuItem: clone(variant.menuItem),
            outletMenus: clone(variant.outletMenus).filter(
              (menu) => menu.outletId === args.where.outletMenus.some.outletId,
            ),
          }));
      },
    },
    order: {
      findUnique: async (args: {
        where:
          | { id: string }
          | {
              outletId_deviceId_idempotencyKey: {
                outletId: string;
                deviceId: string;
                idempotencyKey: string;
              };
            };
      }) => {
        const where = args.where as {
          id?: string;
          outletId_deviceId_idempotencyKey?: {
            outletId: string;
            deviceId: string;
            idempotencyKey: string;
          };
        };

        if (where.id) {
          const order = state.orders.find((row) => row.id === where.id);
          return order ? withLines(order) : null;
        }

        const key = where.outletId_deviceId_idempotencyKey!;
        const order = state.orders.find(
          (row) =>
            row.outletId === key.outletId &&
            row.deviceId === key.deviceId &&
            row.idempotencyKey === key.idempotencyKey,
        );
        return order ? withLines(order) : null;
      },
      findFirst: async (args: { where: Record<string, unknown> }) => {
        const order = state.orders.find((row) => matchesOrder(row, args.where));
        return order ? withLines(order) : null;
      },
      create: async (args: {
        data: {
          businessId: string;
          outletId: string;
          cashierId: string;
          deviceId: string;
          idempotencyKey: string;
          requestHash: string;
          lines: { create: { variantId: string; quantity: number }[] };
        };
      }) => {
        const order: OrderRow = {
          id: nextId(),
          businessId: args.data.businessId,
          outletId: args.data.outletId,
          cashierId: args.data.cashierId,
          deviceId: args.data.deviceId,
          state: OrderState.DRAFT,
          version: 1,
          idempotencyKey: args.data.idempotencyKey,
          requestHash: args.data.requestHash,
          createdAt: now,
          updatedAt: now,
          lines: args.data.lines.create.map((line) => ({
            id: nextId(),
            orderId: '',
            variantId: line.variantId,
            quantity: line.quantity,
            createdAt: now,
          })),
        };
        for (const line of order.lines) line.orderId = order.id;
        state.orders.push(order);
        return withLines(order);
      },
      updateMany: async (args: {
        where: Record<string, unknown>;
        data: {
          state?: OrderState;
          version?: { increment: number };
        };
      }) => {
        const order = state.orders.find((row) => matchesOrder(row, args.where));
        if (!order) return { count: 0 };
        if (args.data.state !== undefined) order.state = args.data.state;
        if (args.data.version) order.version += args.data.version.increment;
        order.updatedAt = now;
        return { count: 1 };
      },
    },
    orderLine: {
      deleteMany: async (args: { where: { orderId: string } }) => {
        for (const order of state.orders) {
          if (order.id === args.where.orderId) {
            order.lines = [];
          }
        }
        return { count: 0 };
      },
      createMany: async (args: {
        data: { orderId: string; variantId: string; quantity: number }[];
      }) => {
        for (const line of args.data) {
          const order = state.orders.find((row) => row.id === line.orderId);
          if (!order) continue;
          order.lines.push({
            id: nextId(),
            orderId: line.orderId,
            variantId: line.variantId,
            quantity: line.quantity,
            createdAt: now,
          });
        }
        return { count: args.data.length };
      },
    },
    quote: {
      create: async (args: { data: Omit<QuoteRow, 'id' | 'createdAt'> }) => {
        const quote: QuoteRow = { ...clone(args.data), id: nextId(), createdAt: now };
        state.quotes.push(quote);
        return clone(quote);
      },
      findFirst: async (args: { where: Record<string, unknown> }) => {
        const quote = state.quotes.find((row) =>
          Object.entries(args.where).every(
            ([key, value]) => (row as unknown as Record<string, unknown>)[key] === value,
          ),
        );
        return quote ? clone(quote) : null;
      },
    },
    sale: {
      create: async (args: {
        data: Omit<SaleRow, 'id' | 'createdAt' | 'lines' | 'payment'> & {
          lines: {
            create: {
              variantId: string;
              name: string;
              variantName: string;
              quantity: number;
              unitPriceMinor: bigint;
              lineSubtotalMinor: bigint;
              recipeVersion: number | null;
            }[];
          };
          payment: {
            create: {
              kind: PaymentKind;
              status: 'RECORDED';
              amountMinor: bigint;
              tenderedMinor: bigint | null;
              changeMinor: bigint | null;
              reference: string | null;
            };
          };
        };
      }) => {
        const saleId = nextId();
        const sale: SaleRow = {
          ...clone({
            id: saleId,
            businessId: args.data.businessId,
            outletId: args.data.outletId,
            orderId: args.data.orderId,
            cashierId: args.data.cashierId,
            deviceId: args.data.deviceId,
            reference: args.data.reference,
            state: args.data.state,
            currency: args.data.currency,
            currencyExponent: args.data.currencyExponent,
            taxBps: args.data.taxBps,
            serviceBps: args.data.serviceBps,
            pricingMode: args.data.pricingMode,
            rounding: args.data.rounding,
            timezone: args.data.timezone,
            subtotalMinor: args.data.subtotalMinor,
            serviceMinor: args.data.serviceMinor,
            taxMinor: args.data.taxMinor,
            totalMinor: args.data.totalMinor,
            completedAt: args.data.completedAt,
            createdAt: now,
          }),
          lines: args.data.lines.create.map((line) => ({
            id: nextId(),
            saleId,
            variantId: line.variantId,
            name: line.name,
            variantName: line.variantName,
            quantity: line.quantity,
            unitPriceMinor: line.unitPriceMinor,
            lineSubtotalMinor: line.lineSubtotalMinor,
            recipeVersion: line.recipeVersion,
          })),
          payment: {
            ...clone(args.data.payment.create),
            id: nextId(),
            saleId,
            createdAt: now,
          },
        };
        state.sales.push(sale);
        return withReceipt(sale);
      },
      findUnique: async (args: { where: { orderId: string } }) => {
        const sale = state.sales.find((row) => row.orderId === args.where.orderId);
        return sale ? clone(sale) : null;
      },
      findFirst: async (args: { where: Record<string, unknown> }) => {
        const sale = state.sales.find((row) =>
          Object.entries(args.where).every(
            ([key, value]) => (row as unknown as Record<string, unknown>)[key] === value,
          ),
        );
        return sale ? withReceipt(sale) : null;
      },
      findMany: async (args: {
        where: Record<string, unknown>;
        take: number;
        cursor?: { id: string };
      }) => {
        let rows = state.sales.filter((row) =>
          Object.entries(args.where).every(
            ([key, value]) => (row as unknown as Record<string, unknown>)[key] === value,
          ),
        );
        rows = [...rows].sort((a, b) => b.completedAt.getTime() - a.completedAt.getTime());
        if (args.cursor) {
          const index = rows.findIndex((row) => row.id === args.cursor?.id);
          rows = index === -1 ? [] : rows.slice(index + 1);
        }
        return rows.slice(0, args.take).map(withReceipt);
      },
    },
    checkoutRequest: {
      findUnique: async (args: {
        where: {
          outletId_deviceId_idempotencyKey: {
            outletId: string;
            deviceId: string;
            idempotencyKey: string;
          };
        };
      }) => {
        const key = args.where.outletId_deviceId_idempotencyKey;
        const row = state.checkouts.find(
          (checkout) =>
            checkout.outletId === key.outletId &&
            checkout.deviceId === key.deviceId &&
            checkout.idempotencyKey === key.idempotencyKey,
        );
        return row ? clone(row) : null;
      },
      create: async (args: {
        data: Omit<CheckoutRow, 'id' | 'saleId' | 'retainedAt' | 'createdAt'>;
      }) => {
        const row: CheckoutRow = {
          ...clone(args.data),
          id: nextId(),
          saleId: null,
          retainedAt: now,
          createdAt: now,
        };
        state.checkouts.push(row);
        return clone(row);
      },
      update: async (args: { where: { id: string }; data: { saleId: string } }) => {
        const row = state.checkouts.find((checkout) => checkout.id === args.where.id);
        if (!row) throw new Error('checkout missing');
        row.saleId = args.data.saleId;
        return clone(row);
      },
    },
  };

  const prisma = {
    ...client,
    $transaction: async <T>(
      operation: (tx: typeof client) => Promise<T>,
      _options?: unknown,
    ): Promise<T> => {
      const snapshot = clone(state);
      try {
        return await operation(client);
      } catch (error) {
        for (const key of Object.keys(snapshot) as (keyof FakeState)[]) {
          Object.assign(state, { [key]: snapshot[key] });
        }
        throw error;
      }
    },
  };

  return { prisma: prisma as unknown as PrismaService, state };
}

function statusOf(error: unknown): number | undefined {
  return error instanceof HttpException ? error.getStatus() : undefined;
}

function codeOf(error: unknown): string | undefined {
  return error instanceof HttpException
    ? (error.getResponse() as { code: string }).code
    : undefined;
}

test('order creation is idempotent and rejects a changed payload', async () => {
  const { prisma, state } = createFakePrisma();
  const service = new SalesService(prisma);
  const actor = user();

  const created = await service.createOrder(
    OUTLET_ID,
    KEY_ONE,
    {
      deviceId: DEVICE_ID,
      lines: [
        { variantId: VARIANT_A, quantity: 2 },
        { variantId: VARIANT_B, quantity: 1 },
      ],
    },
    actor,
  );

  const replay = await service.createOrder(
    OUTLET_ID,
    KEY_ONE,
    {
      deviceId: DEVICE_ID,
      lines: [
        { variantId: VARIANT_A, quantity: 2 },
        { variantId: VARIANT_B, quantity: 1 },
      ],
    },
    actor,
  );

  assert.equal(replay.id, created.id);
  assert.equal(state.orders.length, 1);

  await assert.rejects(
    () =>
      service.createOrder(
        OUTLET_ID,
        KEY_ONE,
        { deviceId: DEVICE_ID, lines: [{ variantId: VARIANT_A, quantity: 1 }] },
        actor,
      ),
    (error: unknown) => statusOf(error) === 409 && codeOf(error) === 'IDEMPOTENCY_CONFLICT',
  );
});

test('quote uses shared settings, snapshots names and expires in 60 seconds', async () => {
  const { prisma } = createFakePrisma({ serviceBps: 500, taxBps: 1100 });
  const service = new SalesService(prisma);
  const actor = user();

  const order = await service.createOrder(
    OUTLET_ID,
    KEY_ONE,
    {
      deviceId: DEVICE_ID,
      lines: [
        { variantId: VARIANT_A, quantity: 2 },
        { variantId: VARIANT_B, quantity: 1 },
      ],
    },
    actor,
  );
  const before = Date.now();
  const quote = await service.createQuote(OUTLET_ID, order.id, { orderVersion: 1 }, actor);

  assert.equal(quote.totals.subtotalMinor, 71000);
  assert.equal(quote.totals.serviceMinor, 3550);
  assert.equal(quote.totals.taxMinor, 8201);
  assert.equal(quote.totals.totalMinor, 82751);
  assert.equal(quote.lines[0]?.name, 'Iced Coffee');
  assert.equal(quote.lines[0]?.variantName, 'Regular');
  assert.equal(quote.lines[0]?.unitPriceMinor, 18000);
  assert.equal(quote.lines[0]?.lineSubtotalMinor, 36000);
  assert.equal(quote.lines[0]?.recipeVersion, null);
  assert.deepEqual(quote.calculation, {
    taxBps: 1100,
    serviceBps: 500,
    pricingMode: 'EXCLUSIVE',
    currencyExponent: 0,
    rounding: 'HALF_UP',
  });
  assert.ok(new Date(quote.expiresAt).getTime() >= before + 59_000);
  assert.ok(new Date(quote.expiresAt).getTime() <= before + 61_000);
});

test('cash finalize records totals, payment and change; replay returns the same sale', async () => {
  const { prisma, state } = createFakePrisma({ serviceBps: 500, taxBps: 1100 });
  const service = new SalesService(prisma);
  const actor = user();

  const order = await service.createOrder(
    OUTLET_ID,
    KEY_ONE,
    {
      deviceId: DEVICE_ID,
      lines: [
        { variantId: VARIANT_A, quantity: 2 },
        { variantId: VARIANT_B, quantity: 1 },
      ],
    },
    actor,
  );
  const quote = await service.createQuote(OUTLET_ID, order.id, { orderVersion: 1 }, actor);
  const first = await service.finalize(
    OUTLET_ID,
    KEY_TWO,
    {
      deviceId: DEVICE_ID,
      orderId: order.id,
      quoteId: quote.id,
      payment: {
        kind: PaymentKind.CASH,
        amountMinor: quote.totals.totalMinor,
        tenderedMinor: 100000,
      },
    },
    actor,
  );

  assert.equal(first.replayed, false);
  assert.equal(first.sale.totals.subtotalMinor, 71000);
  assert.equal(first.sale.totals.serviceMinor, 3550);
  assert.equal(first.sale.totals.taxMinor, 8201);
  assert.equal(first.sale.totals.totalMinor, 82751);
  assert.equal(first.sale.payment.kind, PaymentKind.CASH);
  assert.equal(first.sale.payment.tenderedMinor, 100000);
  assert.equal(first.sale.payment.changeMinor, 17249);
  assert.equal(first.sale.timezone, 'Asia/Jakarta');
  assert.equal(first.sale.currency, 'IDR');
  assert.equal(first.sale.currencyExponent, 0);

  const replay = await service.finalize(
    OUTLET_ID,
    KEY_TWO,
    {
      deviceId: DEVICE_ID,
      orderId: order.id,
      quoteId: quote.id,
      payment: {
        kind: PaymentKind.CASH,
        amountMinor: quote.totals.totalMinor,
        tenderedMinor: 100000,
      },
    },
    actor,
  );

  assert.equal(replay.replayed, true);
  assert.equal(replay.sale.id, first.sale.id);
  assert.equal(state.sales.length, 1);
  assert.equal(state.orders[0]?.state, OrderState.COMPLETED);

  const recovered = await service.recoverCheckout(
    OUTLET_ID,
    KEY_TWO,
    { deviceId: DEVICE_ID },
    actor,
  );
  assert.equal(recovered.sale.id, first.sale.id);
});

test('sale lines preserve the historical price after a catalog price change', async () => {
  const { prisma, state } = createFakePrisma();
  const service = new SalesService(prisma);
  const actor = user();

  const order = await service.createOrder(
    OUTLET_ID,
    KEY_ONE,
    { deviceId: DEVICE_ID, lines: [{ variantId: VARIANT_A, quantity: 2 }] },
    actor,
  );
  const quote = await service.createQuote(OUTLET_ID, order.id, { orderVersion: 1 }, actor);
  const finalized = await service.finalize(
    OUTLET_ID,
    KEY_TWO,
    {
      deviceId: DEVICE_ID,
      orderId: order.id,
      quoteId: quote.id,
      payment: { kind: PaymentKind.CASH, amountMinor: 36000, tenderedMinor: 40000 },
    },
    actor,
  );

  const variant = state.variants.find((row) => row.id === VARIANT_A);
  assert.ok(variant);
  variant.priceMinor = 20000n;

  const reread = await service.getSale(OUTLET_ID, finalized.sale.id, actor);
  assert.equal(reread.lines[0]?.unitPriceMinor, 18000);
  assert.equal(reread.lines[0]?.lineSubtotalMinor, 36000);
  assert.equal(reread.totals.totalMinor, 36000);
});

test('completed sale snapshots calculation rules after a settings change', async () => {
  const { prisma, state } = createFakePrisma({ serviceBps: 500, taxBps: 1100 });
  const service = new SalesService(prisma);
  const actor = user();

  const order = await service.createOrder(
    OUTLET_ID,
    KEY_ONE,
    {
      deviceId: DEVICE_ID,
      lines: [
        { variantId: VARIANT_A, quantity: 2 },
        { variantId: VARIANT_B, quantity: 1 },
      ],
    },
    actor,
  );
  const quote = await service.createQuote(OUTLET_ID, order.id, { orderVersion: 1 }, actor);
  const finalized = await service.finalize(
    OUTLET_ID,
    KEY_TWO,
    {
      deviceId: DEVICE_ID,
      orderId: order.id,
      quoteId: quote.id,
      payment: {
        kind: PaymentKind.CASH,
        amountMinor: quote.totals.totalMinor,
        tenderedMinor: 100000,
      },
    },
    actor,
  );

  assert.deepEqual(finalized.sale.calculation, {
    taxBps: 1100,
    serviceBps: 500,
    pricingMode: 'EXCLUSIVE',
    currencyExponent: 0,
    rounding: 'HALF_UP',
  });

  state.outlet.serviceBps = 1000;
  state.outlet.taxBps = 2000;
  state.outlet.version = 2;

  const reread = await service.getSale(OUTLET_ID, finalized.sale.id, actor);

  assert.deepEqual(reread.calculation, {
    taxBps: 1100,
    serviceBps: 500,
    pricingMode: 'EXCLUSIVE',
    currencyExponent: 0,
    rounding: 'HALF_UP',
  });
  assert.equal(reread.totals.subtotalMinor, 71000);
  assert.equal(reread.totals.serviceMinor, 3550);
  assert.equal(reread.totals.taxMinor, 8201);
  assert.equal(reread.totals.totalMinor, 82751);

  const recomputed = calculateTotals(
    reread.lines.map((line) => ({
      unitPriceMinor: BigInt(line.unitPriceMinor),
      quantity: line.quantity,
    })),
    reread.calculation.serviceBps,
    reread.calculation.taxBps,
  );

  assert.equal(Number(recomputed.subtotalMinor), reread.totals.subtotalMinor);
  assert.equal(Number(recomputed.serviceMinor), reread.totals.serviceMinor);
  assert.equal(Number(recomputed.taxMinor), reread.totals.taxMinor);
  assert.equal(Number(recomputed.totalMinor), reread.totals.totalMinor);

  const page = await service.listSales(OUTLET_ID, {}, actor);
  assert.deepEqual(page.items[0]?.calculation, reread.calculation);
});

test('a cashier cannot access another cashier draft order', async () => {
  const { prisma } = createFakePrisma();
  const service = new SalesService(prisma);
  const ownerCashier = user();
  const otherCashier = user(Role.CASHIER, OTHER_CASHIER_ID);

  const order = await service.createOrder(
    OUTLET_ID,
    KEY_ONE,
    { deviceId: DEVICE_ID, lines: [{ variantId: VARIANT_A, quantity: 1 }] },
    ownerCashier,
  );

  await assert.rejects(
    () =>
      service.updateOrder(
        OUTLET_ID,
        order.id,
        { version: 1, lines: [{ variantId: VARIANT_B, quantity: 1 }] },
        otherCashier,
      ),
    (error: unknown) => statusOf(error) === 404 && codeOf(error) === 'NOT_FOUND',
  );

  await assert.rejects(
    () => service.createQuote(OUTLET_ID, order.id, { orderVersion: 1 }, otherCashier),
    (error: unknown) => statusOf(error) === 404 && codeOf(error) === 'NOT_FOUND',
  );

  await assert.rejects(
    () => service.cancelOrder(OUTLET_ID, order.id, { version: 1 }, otherCashier),
    (error: unknown) => statusOf(error) === 404 && codeOf(error) === 'NOT_FOUND',
  );
});

test('a changed order or settings version makes the quote stale without creating a sale', async () => {
  const { prisma, state } = createFakePrisma();
  const service = new SalesService(prisma);
  const actor = user();

  const order = await service.createOrder(
    OUTLET_ID,
    KEY_ONE,
    { deviceId: DEVICE_ID, lines: [{ variantId: VARIANT_A, quantity: 1 }] },
    actor,
  );
  const quote = await service.createQuote(OUTLET_ID, order.id, { orderVersion: 1 }, actor);
  await service.updateOrder(
    OUTLET_ID,
    order.id,
    { version: 1, lines: [{ variantId: VARIANT_A, quantity: 2 }] },
    actor,
  );

  await assert.rejects(
    () =>
      service.finalize(
        OUTLET_ID,
        KEY_TWO,
        {
          deviceId: DEVICE_ID,
          orderId: order.id,
          quoteId: quote.id,
          payment: { kind: PaymentKind.CASH, amountMinor: 18000, tenderedMinor: 20000 },
        },
        actor,
      ),
    (error: unknown) => statusOf(error) === 409 && codeOf(error) === 'QUOTE_STALE',
  );

  assert.equal(state.sales.length, 0);
  assert.equal(state.checkouts.length, 0);
});

test('expired quotes are rejected before any payment is recorded', async () => {
  const { prisma, state } = createFakePrisma();
  const service = new SalesService(prisma);
  const actor = user();

  const order = await service.createOrder(
    OUTLET_ID,
    KEY_ONE,
    { deviceId: DEVICE_ID, lines: [{ variantId: VARIANT_A, quantity: 1 }] },
    actor,
  );
  const quote = await service.createQuote(OUTLET_ID, order.id, { orderVersion: 1 }, actor);
  const stored = state.quotes.find((row) => row.id === quote.id);
  assert.ok(stored);
  stored.expiresAt = new Date(Date.now() - 1000);

  await assert.rejects(
    () =>
      service.finalize(
        OUTLET_ID,
        KEY_TWO,
        {
          deviceId: DEVICE_ID,
          orderId: order.id,
          quoteId: quote.id,
          payment: { kind: PaymentKind.CASH, amountMinor: 18000, tenderedMinor: 20000 },
        },
        actor,
      ),
    (error: unknown) => statusOf(error) === 409 && codeOf(error) === 'QUOTE_EXPIRED',
  );

  assert.equal(state.sales.length, 0);
});

test('insufficient cash and manual external tender are rejected with nothing written', async () => {
  const { prisma, state } = createFakePrisma();
  const service = new SalesService(prisma);
  const actor = user();

  const order = await service.createOrder(
    OUTLET_ID,
    KEY_ONE,
    { deviceId: DEVICE_ID, lines: [{ variantId: VARIANT_A, quantity: 1 }] },
    actor,
  );
  const quote = await service.createQuote(OUTLET_ID, order.id, { orderVersion: 1 }, actor);
  const payload = {
    deviceId: DEVICE_ID,
    orderId: order.id,
    quoteId: quote.id,
  };

  await assert.rejects(
    () =>
      service.finalize(
        OUTLET_ID,
        KEY_TWO,
        {
          ...payload,
          payment: { kind: PaymentKind.CASH, amountMinor: 18000, tenderedMinor: 17999 },
        },
        actor,
      ),
    (error: unknown) => statusOf(error) === 422 && codeOf(error) === 'PAYMENT_INVALID',
  );

  await assert.rejects(
    () =>
      service.finalize(
        OUTLET_ID,
        KEY_THREE,
        {
          ...payload,
          payment: { kind: PaymentKind.MANUAL_EXTERNAL, amountMinor: 18000, tenderedMinor: 20000 },
        },
        actor,
      ),
    (error: unknown) => statusOf(error) === 422 && codeOf(error) === 'PAYMENT_INVALID',
  );

  assert.equal(state.sales.length, 0);
  assert.equal(state.orders[0]?.state, OrderState.DRAFT);
  assert.equal(state.checkouts.length, 0);
});

test('a different key for a completed order returns ORDER_ALREADY_COMPLETED with the sale id', async () => {
  const { prisma } = createFakePrisma();
  const service = new SalesService(prisma);
  const actor = user();

  const order = await service.createOrder(
    OUTLET_ID,
    KEY_ONE,
    { deviceId: DEVICE_ID, lines: [{ variantId: VARIANT_A, quantity: 1 }] },
    actor,
  );
  const quote = await service.createQuote(OUTLET_ID, order.id, { orderVersion: 1 }, actor);
  const finalized = await service.finalize(
    OUTLET_ID,
    KEY_TWO,
    {
      deviceId: DEVICE_ID,
      orderId: order.id,
      quoteId: quote.id,
      payment: { kind: PaymentKind.CASH, amountMinor: 18000, tenderedMinor: 20000 },
    },
    actor,
  );

  await assert.rejects(
    () =>
      service.finalize(
        OUTLET_ID,
        KEY_THREE,
        {
          deviceId: DEVICE_ID,
          orderId: order.id,
          quoteId: quote.id,
          payment: { kind: PaymentKind.CASH, amountMinor: 18000, tenderedMinor: 20000 },
        },
        actor,
      ),
    (error: unknown) =>
      statusOf(error) === 409 &&
      codeOf(error) === 'ORDER_ALREADY_COMPLETED' &&
      (error instanceof HttpException
        ? (error.getResponse() as { details?: { saleId?: string } }).details?.saleId
        : undefined) === finalized.sale.id,
  );
});

test('stale order versions and cancelling a completed order are rejected', async () => {
  const { prisma } = createFakePrisma();
  const service = new SalesService(prisma);
  const actor = user();

  const order = await service.createOrder(
    OUTLET_ID,
    KEY_ONE,
    { deviceId: DEVICE_ID, lines: [{ variantId: VARIANT_A, quantity: 1 }] },
    actor,
  );

  await assert.rejects(
    () =>
      service.updateOrder(
        OUTLET_ID,
        order.id,
        { version: 99, lines: [{ variantId: VARIANT_B, quantity: 1 }] },
        actor,
      ),
    (error: unknown) => statusOf(error) === 409 && codeOf(error) === 'VERSION_CONFLICT',
  );

  const quote = await service.createQuote(OUTLET_ID, order.id, { orderVersion: 1 }, actor);
  await service.finalize(
    OUTLET_ID,
    KEY_TWO,
    {
      deviceId: DEVICE_ID,
      orderId: order.id,
      quoteId: quote.id,
      payment: { kind: PaymentKind.CASH, amountMinor: 18000, tenderedMinor: 20000 },
    },
    actor,
  );

  await assert.rejects(
    () => service.cancelOrder(OUTLET_ID, order.id, { version: 2 }, actor),
    (error: unknown) => statusOf(error) === 409 && codeOf(error) === 'ORDER_NOT_DRAFT',
  );
});

test('sales list filters to the cashier own sales while owners see the outlet', async () => {
  const { prisma } = createFakePrisma();
  const service = new SalesService(prisma);
  const cashier = user();

  const order = await service.createOrder(
    OUTLET_ID,
    KEY_ONE,
    { deviceId: DEVICE_ID, lines: [{ variantId: VARIANT_A, quantity: 1 }] },
    cashier,
  );
  const quote = await service.createQuote(OUTLET_ID, order.id, { orderVersion: 1 }, cashier);
  await service.finalize(
    OUTLET_ID,
    KEY_TWO,
    {
      deviceId: DEVICE_ID,
      orderId: order.id,
      quoteId: quote.id,
      payment: { kind: PaymentKind.CASH, amountMinor: 18000, tenderedMinor: 20000 },
    },
    cashier,
  );

  const own = await service.listSales(OUTLET_ID, {}, cashier);
  assert.equal(own.items.length, 1);
  assert.equal(own.items[0]?.state, SaleState.COMPLETED);

  const other = await service.listSales(OUTLET_ID, {}, user(Role.CASHIER, OTHER_CASHIER_ID));
  assert.equal(other.items.length, 0);

  const owner = await service.listSales(OUTLET_ID, {}, user(Role.OWNER, OWNER_ID));
  assert.equal(owner.items.length, 1);
});

test('manual external payment records the equal amount with no tender or change', async () => {
  const { prisma } = createFakePrisma();
  const service = new SalesService(prisma);
  const actor = user();

  const order = await service.createOrder(
    OUTLET_ID,
    KEY_ONE,
    { deviceId: DEVICE_ID, lines: [{ variantId: VARIANT_A, quantity: 1 }] },
    actor,
  );
  const quote = await service.createQuote(OUTLET_ID, order.id, { orderVersion: 1 }, actor);
  const finalized = await service.finalize(
    OUTLET_ID,
    KEY_TWO,
    {
      deviceId: DEVICE_ID,
      orderId: order.id,
      quoteId: quote.id,
      payment: {
        kind: PaymentKind.MANUAL_EXTERNAL,
        amountMinor: quote.totals.totalMinor,
        reference: 'BANK-TRX-1',
      },
    },
    actor,
  );

  assert.equal(finalized.sale.payment.kind, PaymentKind.MANUAL_EXTERNAL);
  assert.equal(finalized.sale.payment.amountMinor, 18000);
  assert.equal(finalized.sale.payment.tenderedMinor, undefined);
  assert.equal(finalized.sale.payment.changeMinor, undefined);
  assert.equal(finalized.sale.payment.reference, 'BANK-TRX-1');
});

test('an outlet settings change after the quote makes it stale', async () => {
  const { prisma, state } = createFakePrisma();
  const service = new SalesService(prisma);
  const actor = user();

  const order = await service.createOrder(
    OUTLET_ID,
    KEY_ONE,
    { deviceId: DEVICE_ID, lines: [{ variantId: VARIANT_A, quantity: 1 }] },
    actor,
  );
  const quote = await service.createQuote(OUTLET_ID, order.id, { orderVersion: 1 }, actor);
  state.outlet.serviceBps = 500;
  state.outlet.version = 2;

  await assert.rejects(
    () =>
      service.finalize(
        OUTLET_ID,
        KEY_TWO,
        {
          deviceId: DEVICE_ID,
          orderId: order.id,
          quoteId: quote.id,
          payment: { kind: PaymentKind.CASH, amountMinor: 18000, tenderedMinor: 20000 },
        },
        actor,
      ),
    (error: unknown) => statusOf(error) === 409 && codeOf(error) === 'QUOTE_STALE',
  );

  assert.equal(state.sales.length, 0);
});
