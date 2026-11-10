import assert from 'node:assert/strict';
import { test } from 'node:test';
import { HttpException } from '@nestjs/common';
import { OrderState, PaymentKind, Prisma, Role, SaleState, StockPolicy } from '@prisma/client';
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
  stockPolicy: StockPolicy;
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

interface ReversalRow {
  id: string;
  businessId: string;
  outletId: string;
  saleId: string;
  actorId: string;
  reason: string;
  restock: unknown;
  externalRefundPerformed: boolean;
  idempotencyKey: string;
  requestHash: string;
  createdAt: Date;
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

interface RecipeRow {
  id: string;
  variantId: string;
  outletId: string;
  businessId: string;
  version: number;
}

interface RecipeLineRow {
  id: string;
  recipeVersionId: string;
  stockItemId: string;
  quantityPerSaleUnit: string;
}

interface StockItemRow {
  id: string;
  businessId: string;
  name: string;
  quantityScale: number;
}

interface BalanceRow {
  id: string;
  outletId: string;
  stockItemId: string;
  quantity: string;
  version: number;
}

interface MovementRow {
  id: string;
  outletId: string;
  stockItemId: string;
  delta: string;
  type: string;
  actorId: string;
  reason: string;
  sourceId: string;
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
  recipes: RecipeRow[];
  recipeLines: RecipeLineRow[];
  stockItems: StockItemRow[];
  balances: BalanceRow[];
  movements: MovementRow[];
  orders: OrderRow[];
  quotes: QuoteRow[];
  sales: SaleRow[];
  checkouts: CheckoutRow[];
  reversals: ReversalRow[];
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
        stockPolicy: StockPolicy.UNTRACKED,
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
        stockPolicy: StockPolicy.UNTRACKED,
        menuItem: {
          name: 'Chicken Rice',
          archivedAt: null,
          category: { archivedAt: null },
        },
        outletMenus: [{ outletId: OUTLET_ID, enabled: true }],
      },
    ],
    recipes: [],
    recipeLines: [],
    stockItems: [],
    balances: [],
    movements: [],
    orders: [],
    quotes: [],
    sales: [],
    checkouts: [],
    reversals: [],
  };

  let sequence = 0;
  const nextId = (): string =>
    `00000000-0000-4000-8000-${String(500 + sequence++).padStart(12, '0')}`;
  const now = new Date('2026-01-01T00:00:00.000Z');

  const withLines = (order: OrderRow) => ({
    ...clone(order),
    lines: clone(order.lines).sort((a, b) => a.createdAt.getTime() - b.createdAt.getTime()),
  });

  const withReceipt = (sale: SaleRow) => {
    const reversal = state.reversals.find((row) => row.saleId === sale.id);
    return {
      ...clone(sale),
      lines: clone(sale.lines),
      payment: sale.payment ? clone(sale.payment) : null,
      reversal: reversal ? clone(reversal) : null,
    };
  };

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
          menuItem?: { businessId: string };
          outletMenus?: { some: { outletId: string } };
        };
      }) => {
        const outletId = args.where.outletMenus?.some.outletId;
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
              (menu) => outletId === undefined || menu.outletId === outletId,
            ),
          }));
      },
    },
    recipeVersion: {
      findMany: async (args: {
        where: {
          outletId: string;
          businessId?: string;
          variantId?: { in: string[] };
          OR?: { variantId: string; version: number }[];
        };
        include?: { lines: unknown };
      }) => {
        return state.recipes
          .filter(
            (recipe) =>
              recipe.outletId === args.where.outletId &&
              (args.where.businessId === undefined ||
                recipe.businessId === args.where.businessId) &&
              (args.where.variantId === undefined ||
                args.where.variantId.in.includes(recipe.variantId)) &&
              (args.where.OR === undefined ||
                args.where.OR.some(
                  (pin) => pin.variantId === recipe.variantId && pin.version === recipe.version,
                )),
          )
          .sort((a, b) => a.version - b.version)
          .map((recipe) => ({
            id: recipe.id,
            variantId: recipe.variantId,
            version: recipe.version,
            lines: state.recipeLines
              .filter((line) => line.recipeVersionId === recipe.id)
              .map((line) => ({
                stockItemId: line.stockItemId,
                quantityPerSaleUnit: new Prisma.Decimal(line.quantityPerSaleUnit),
              })),
          }));
      },
    },
    stockItem: {
      findMany: async (args: { where: { id: { in: string[] } } }) => {
        return state.stockItems
          .filter((item) => args.where.id.in.includes(item.id))
          .map((item) => ({ id: item.id, name: item.name, quantityScale: item.quantityScale }));
      },
    },
    stockBalance: {
      findMany: async (args: { where: { outletId: string; stockItemId: { in: string[] } } }) => {
        return state.balances
          .filter(
            (balance) =>
              balance.outletId === args.where.outletId &&
              args.where.stockItemId.in.includes(balance.stockItemId),
          )
          .map((balance) => ({
            stockItemId: balance.stockItemId,
            quantity: new Prisma.Decimal(balance.quantity),
          }));
      },
      updateMany: async (args: {
        where: {
          outletId: string;
          stockItemId: string;
          version?: number;
          quantity?: { gte: Prisma.Decimal };
        };
        data: {
          quantity: Prisma.Decimal | { increment: Prisma.Decimal };
          version: { increment: number };
        };
      }) => {
        const row = state.balances.find(
          (balance) =>
            balance.outletId === args.where.outletId &&
            balance.stockItemId === args.where.stockItemId,
        );

        if (!row) return { count: 0 };
        if (args.where.version !== undefined && row.version !== args.where.version) {
          return { count: 0 };
        }
        if (
          args.where.quantity &&
          new Prisma.Decimal(row.quantity).lessThan(args.where.quantity.gte)
        ) {
          return { count: 0 };
        }

        const next =
          args.data.quantity instanceof Prisma.Decimal
            ? args.data.quantity
            : new Prisma.Decimal(row.quantity).plus(args.data.quantity.increment);
        row.quantity = next.toString();
        row.version += args.data.version.increment;
        return { count: 1 };
      },
      create: async (args: {
        data: {
          outletId: string;
          stockItemId: string;
          quantity: Prisma.Decimal;
          version: number;
        };
      }) => {
        const row = {
          id: `balance-${state.balances.length + 1}`,
          outletId: args.data.outletId,
          stockItemId: args.data.stockItemId,
          quantity: args.data.quantity.toString(),
          version: args.data.version,
        };
        state.balances.push(row);
        return clone(row);
      },
    },
    stockMovement: {
      createMany: async (args: {
        data: {
          outletId: string;
          stockItemId: string;
          delta: Prisma.Decimal;
          type: string;
          actorId: string;
          reason: string;
          sourceId: string;
        }[];
      }) => {
        for (const movement of args.data) {
          state.movements.push({
            id: nextId(),
            outletId: movement.outletId,
            stockItemId: movement.stockItemId,
            delta: movement.delta.toString(),
            type: movement.type,
            actorId: movement.actorId,
            reason: movement.reason,
            sourceId: movement.sourceId,
            createdAt: now,
          });
        }
        return { count: args.data.length };
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
    saleReversal: {
      findUnique: async (args: {
        where:
          | { saleId: string }
          | {
              outletId_idempotencyKey: {
                outletId: string;
                idempotencyKey: string;
              };
            };
      }) => {
        const where = args.where as {
          saleId?: string;
          outletId_idempotencyKey?: { outletId: string; idempotencyKey: string };
        };
        const row = where.saleId
          ? state.reversals.find((reversal) => reversal.saleId === where.saleId)
          : state.reversals.find(
              (reversal) =>
                reversal.outletId === where.outletId_idempotencyKey?.outletId &&
                reversal.idempotencyKey === where.outletId_idempotencyKey?.idempotencyKey,
            );
        return row ? clone(row) : null;
      },
      create: async (args: {
        data: Omit<ReversalRow, 'id' | 'createdAt' | 'externalRefundPerformed'> & {
          externalRefundPerformed?: boolean;
        };
      }) => {
        if (state.reversals.some((reversal) => reversal.saleId === args.data.saleId)) {
          throw new Prisma.PrismaClientKnownRequestError('duplicate sale reversal', {
            code: 'P2002',
            clientVersion: '6.19.3',
          });
        }

        if (
          state.reversals.some(
            (reversal) =>
              reversal.outletId === args.data.outletId &&
              reversal.idempotencyKey === args.data.idempotencyKey,
          )
        ) {
          throw new Prisma.PrismaClientKnownRequestError('duplicate reversal key', {
            code: 'P2002',
            clientVersion: '6.19.3',
          });
        }

        const row: ReversalRow = {
          ...clone(args.data),
          externalRefundPerformed: args.data.externalRefundPerformed ?? false,
          id: nextId(),
          createdAt: now,
        };
        state.reversals.push(row);
        return clone(row);
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

  const queryRaw = async (strings: TemplateStringsArray, ...values: unknown[]) => {
    const sql = strings.join('?');

    if (sql.includes('"orders"')) {
      const id = String(values[0]);
      return state.orders.filter((order) => order.id === id).map((order) => ({ id: order.id }));
    }

    if (sql.includes('"sales"')) {
      const id = String(values[0]);
      return state.sales.filter((sale) => sale.id === id).map((sale) => ({ id: sale.id }));
    }

    if (sql.includes('"stock_balances"')) {
      const outletId = String(values[0]);
      return state.balances
        .filter((balance) => balance.outletId === outletId)
        .sort((a, b) => a.stockItemId.localeCompare(b.stockItemId))
        .map((balance) => ({
          stockItemId: balance.stockItemId,
          quantity: new Prisma.Decimal(balance.quantity),
          version: balance.version,
        }));
    }

    return [];
  };

  const prisma = {
    ...client,
    $queryRaw: queryRaw,
    $transaction: async <T>(
      operation: (tx: typeof client) => Promise<T>,
      _options?: unknown,
    ): Promise<T> => {
      const snapshot = clone(state);
      try {
        return await operation({ ...client, $queryRaw: queryRaw } as typeof client);
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

test('finalize pins the recipe version at sale time; later versions never rewrite it', async () => {
  const { prisma, state } = createFakePrisma();
  const service = new SalesService(prisma);
  const actor = user();

  state.recipes.push({
    id: '00000000-0000-4000-8000-0000000000d0',
    variantId: VARIANT_A,
    outletId: OUTLET_ID,
    businessId: BUSINESS_ID,
    version: 1,
  });

  const order = await service.createOrder(
    OUTLET_ID,
    KEY_ONE,
    { deviceId: DEVICE_ID, lines: [{ variantId: VARIANT_A, quantity: 2 }] },
    actor,
  );
  const quote = await service.createQuote(OUTLET_ID, order.id, { orderVersion: 1 }, actor);

  assert.equal(quote.lines[0]?.recipeVersion, 1);

  state.recipes.push({
    id: '00000000-0000-4000-8000-0000000000d1',
    variantId: VARIANT_A,
    outletId: OUTLET_ID,
    businessId: BUSINESS_ID,
    version: 2,
  });

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

  assert.equal(state.sales[0]?.lines[0]?.recipeVersion, 2);

  state.recipes.push({
    id: '00000000-0000-4000-8000-0000000000d2',
    variantId: VARIANT_A,
    outletId: OUTLET_ID,
    businessId: BUSINESS_ID,
    version: 3,
  });

  const reread = await service.getSale(OUTLET_ID, finalized.sale.id, actor);
  assert.equal(reread.id, finalized.sale.id);
  assert.equal(state.sales[0]?.lines[0]?.recipeVersion, 2);
  assert.deepEqual(
    state.recipes.map((recipe) => recipe.version),
    [1, 2, 3],
  );
});

test('finalize pins each variant recipe version independently by variantId', async () => {
  const { prisma, state } = createFakePrisma();
  const service = new SalesService(prisma);
  const actor = user();

  state.recipes.push(
    {
      id: '00000000-0000-4000-8000-0000000000e0',
      variantId: VARIANT_A,
      outletId: OUTLET_ID,
      businessId: BUSINESS_ID,
      version: 1,
    },
    {
      id: '00000000-0000-4000-8000-0000000000e1',
      variantId: VARIANT_B,
      outletId: OUTLET_ID,
      businessId: BUSINESS_ID,
      version: 1,
    },
  );

  const order = await service.createOrder(
    OUTLET_ID,
    KEY_ONE,
    {
      deviceId: DEVICE_ID,
      lines: [
        { variantId: VARIANT_A, quantity: 1 },
        { variantId: VARIANT_B, quantity: 1 },
      ],
    },
    actor,
  );
  const quote = await service.createQuote(OUTLET_ID, order.id, { orderVersion: 1 }, actor);

  state.recipes.push({
    id: '00000000-0000-4000-8000-0000000000e2',
    variantId: VARIANT_A,
    outletId: OUTLET_ID,
    businessId: BUSINESS_ID,
    version: 2,
  });

  await service.finalize(
    OUTLET_ID,
    KEY_TWO,
    {
      deviceId: DEVICE_ID,
      orderId: order.id,
      quoteId: quote.id,
      payment: {
        kind: PaymentKind.CASH,
        amountMinor: quote.totals.totalMinor,
        tenderedMinor: quote.totals.totalMinor,
      },
    },
    actor,
  );

  const pinned = new Map(state.sales[0]?.lines.map((line) => [line.variantId, line.recipeVersion]));
  assert.equal(pinned.get(VARIANT_A), 2);
  assert.equal(pinned.get(VARIANT_B), 1);
});

test('quote line matching is order-independent by variantId', async () => {
  const { prisma, state } = createFakePrisma();
  const service = new SalesService(prisma);
  const actor = user();

  state.recipes.push(
    {
      id: '00000000-0000-4000-8000-0000000000f0',
      variantId: VARIANT_A,
      outletId: OUTLET_ID,
      businessId: BUSINESS_ID,
      version: 1,
    },
    {
      id: '00000000-0000-4000-8000-0000000000f1',
      variantId: VARIANT_B,
      outletId: OUTLET_ID,
      businessId: BUSINESS_ID,
      version: 1,
    },
  );

  const order = await service.createOrder(
    OUTLET_ID,
    KEY_ONE,
    {
      deviceId: DEVICE_ID,
      lines: [
        { variantId: VARIANT_A, quantity: 1 },
        { variantId: VARIANT_B, quantity: 2 },
      ],
    },
    actor,
  );
  const quote = await service.createQuote(OUTLET_ID, order.id, { orderVersion: 1 }, actor);

  const stored = state.quotes[0];
  assert.ok(stored);
  stored.lines = [...(stored.lines as unknown[])].reverse();

  await service.finalize(
    OUTLET_ID,
    KEY_TWO,
    {
      deviceId: DEVICE_ID,
      orderId: order.id,
      quoteId: quote.id,
      payment: {
        kind: PaymentKind.CASH,
        amountMinor: quote.totals.totalMinor,
        tenderedMinor: quote.totals.totalMinor,
      },
    },
    actor,
  );

  assert.equal(state.sales.length, 1);
  const pinned = new Map(state.sales[0]?.lines.map((line) => [line.variantId, line.recipeVersion]));
  assert.equal(pinned.get(VARIANT_A), 1);
  assert.equal(pinned.get(VARIANT_B), 1);
});

test('tracked variants without a published recipe are rejected at sale time', async () => {
  const { prisma, state } = createFakePrisma();
  const service = new SalesService(prisma);
  const actor = user();

  const tracked = state.variants.find((row) => row.id === VARIANT_A);
  assert.ok(tracked);
  tracked.stockPolicy = StockPolicy.TRACKED;

  const order = await service.createOrder(
    OUTLET_ID,
    KEY_ONE,
    { deviceId: DEVICE_ID, lines: [{ variantId: VARIANT_A, quantity: 1 }] },
    actor,
  );

  await assert.rejects(
    () => service.createQuote(OUTLET_ID, order.id, { orderVersion: 1 }, actor),
    (error: unknown) => statusOf(error) === 422 && codeOf(error) === 'RECIPE_REQUIRED',
  );
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

const STOCK_SHARED_ID = '00000000-0000-4000-8000-000000000050';
const STOCK_SECOND_ID = '00000000-0000-4000-8000-000000000051';
const RECIPE_A_ID = '00000000-0000-4000-8000-0000000000c0';
const RECIPE_B_ID = '00000000-0000-4000-8000-0000000000c1';

function addStockItem(state: FakeState, id: string, name: string, quantityScale = 0): void {
  if (!state.stockItems.some((item) => item.id === id)) {
    state.stockItems.push({ id, businessId: BUSINESS_ID, name, quantityScale });
  }
}

function setBalance(state: FakeState, stockItemId: string, quantity: string): void {
  const existing = state.balances.find(
    (balance) => balance.outletId === OUTLET_ID && balance.stockItemId === stockItemId,
  );

  if (existing) {
    existing.quantity = quantity;
    return;
  }

  state.balances.push({
    id: `balance-${state.balances.length + 1}`,
    outletId: OUTLET_ID,
    stockItemId,
    quantity,
    version: 1,
  });
}

function trackVariant(
  state: FakeState,
  variantId: string,
  recipeId: string,
  lines: { stockItemId: string; quantityPerSaleUnit: string }[],
  version = 1,
): void {
  const variant = state.variants.find((row) => row.id === variantId);
  assert.ok(variant);
  variant.stockPolicy = StockPolicy.TRACKED;

  state.recipes.push({
    id: recipeId,
    variantId,
    outletId: OUTLET_ID,
    businessId: BUSINESS_ID,
    version,
  });

  for (const [index, line] of lines.entries()) {
    state.recipeLines.push({
      id: `${recipeId}-line-${index}`,
      recipeVersionId: recipeId,
      stockItemId: line.stockItemId,
      quantityPerSaleUnit: line.quantityPerSaleUnit,
    });
  }
}

async function prepareOrder(
  service: SalesService,
  key: string,
  lines: { variantId: string; quantity: number }[],
) {
  const actor = user();
  const order = await service.createOrder(OUTLET_ID, key, { deviceId: DEVICE_ID, lines }, actor);
  const quote = await service.createQuote(OUTLET_ID, order.id, { orderVersion: 1 }, actor);
  return { actor, order, quote };
}

function finalizePayment(amountMinor: number) {
  return { kind: PaymentKind.CASH, amountMinor, tenderedMinor: amountMinor };
}

test('selling two tracked products consuming three units each deducts exactly six once', async () => {
  const { prisma, state } = createFakePrisma();
  const service = new SalesService(prisma);
  addStockItem(state, STOCK_SHARED_ID, 'Coffee Beans');
  setBalance(state, STOCK_SHARED_ID, '10');
  trackVariant(state, VARIANT_A, RECIPE_A_ID, [
    { stockItemId: STOCK_SHARED_ID, quantityPerSaleUnit: '3' },
  ]);
  trackVariant(state, VARIANT_B, RECIPE_B_ID, [
    { stockItemId: STOCK_SHARED_ID, quantityPerSaleUnit: '3' },
  ]);

  const { actor, order, quote } = await prepareOrder(service, KEY_ONE, [
    { variantId: VARIANT_A, quantity: 1 },
    { variantId: VARIANT_B, quantity: 1 },
  ]);

  const finalized = await service.finalize(
    OUTLET_ID,
    KEY_TWO,
    {
      deviceId: DEVICE_ID,
      orderId: order.id,
      quoteId: quote.id,
      payment: finalizePayment(53000),
    },
    actor,
  );

  const balance = state.balances.find((row) => row.stockItemId === STOCK_SHARED_ID);
  assert.equal(balance?.quantity, '4');
  assert.equal(state.movements.length, 1);
  assert.equal(state.movements[0]?.delta, '-6');
  assert.equal(state.movements[0]?.type, 'SALE');
  assert.equal(state.movements[0]?.sourceId, finalized.sale.id);
  assert.equal(
    state.movements.reduce((sum, movement) => sum + Number(movement.delta), 0),
    -6,
  );

  const replay = await service.finalize(
    OUTLET_ID,
    KEY_TWO,
    {
      deviceId: DEVICE_ID,
      orderId: order.id,
      quoteId: quote.id,
      payment: finalizePayment(53000),
    },
    actor,
  );

  assert.equal(replay.replayed, true);
  assert.equal(replay.sale.id, finalized.sale.id);
  assert.equal(state.movements.length, 1);
  assert.equal(balance?.quantity, '4');
});

test('a shared ingredient across two sale lines consumes the sum, not one line', async () => {
  const { prisma, state } = createFakePrisma();
  const service = new SalesService(prisma);
  addStockItem(state, STOCK_SHARED_ID, 'Fresh Milk');
  setBalance(state, STOCK_SHARED_ID, '10');
  trackVariant(state, VARIANT_A, RECIPE_A_ID, [
    { stockItemId: STOCK_SHARED_ID, quantityPerSaleUnit: '2' },
  ]);
  trackVariant(state, VARIANT_B, RECIPE_B_ID, [
    { stockItemId: STOCK_SHARED_ID, quantityPerSaleUnit: '1' },
  ]);

  const { actor, order, quote } = await prepareOrder(service, KEY_ONE, [
    { variantId: VARIANT_A, quantity: 2 },
    { variantId: VARIANT_B, quantity: 1 },
  ]);

  await service.finalize(
    OUTLET_ID,
    KEY_TWO,
    {
      deviceId: DEVICE_ID,
      orderId: order.id,
      quoteId: quote.id,
      payment: finalizePayment(71000),
    },
    actor,
  );

  const balance = state.balances.find((row) => row.stockItemId === STOCK_SHARED_ID);
  assert.equal(balance?.quantity, '5');
  assert.equal(state.movements.length, 1);
  assert.equal(state.movements[0]?.delta, '-5');
});

test('insufficient stock rejects the sale with item-specific shortages and no writes', async () => {
  const { prisma, state } = createFakePrisma();
  const service = new SalesService(prisma);
  addStockItem(state, STOCK_SHARED_ID, 'Coffee Beans');
  addStockItem(state, STOCK_SECOND_ID, 'Fresh Milk');
  setBalance(state, STOCK_SHARED_ID, '5');
  setBalance(state, STOCK_SECOND_ID, '100');
  trackVariant(state, VARIANT_A, RECIPE_A_ID, [
    { stockItemId: STOCK_SHARED_ID, quantityPerSaleUnit: '3' },
  ]);
  trackVariant(state, VARIANT_B, RECIPE_B_ID, [
    { stockItemId: STOCK_SECOND_ID, quantityPerSaleUnit: '3' },
  ]);

  const { actor, order, quote } = await prepareOrder(service, KEY_ONE, [
    { variantId: VARIANT_A, quantity: 2 },
    { variantId: VARIANT_B, quantity: 1 },
  ]);

  await assert.rejects(
    () =>
      service.finalize(
        OUTLET_ID,
        KEY_TWO,
        {
          deviceId: DEVICE_ID,
          orderId: order.id,
          quoteId: quote.id,
          payment: finalizePayment(71000),
        },
        actor,
      ),
    (error: unknown) => {
      assert.ok(error instanceof HttpException);
      assert.equal(error.getStatus(), 422);
      const response = error.getResponse() as {
        code: string;
        details: {
          shortages: {
            stockItemId: string;
            name: string;
            required: string;
            available: string;
            shortage: string;
          }[];
        };
      };
      assert.equal(response.code, 'INSUFFICIENT_STOCK');
      assert.deepEqual(response.details.shortages, [
        {
          stockItemId: STOCK_SHARED_ID,
          name: 'Coffee Beans',
          required: '6',
          available: '5',
          shortage: '1',
        },
      ]);
      return true;
    },
  );

  assert.equal(state.sales.length, 0);
  assert.equal(state.movements.length, 0);
  assert.equal(state.checkouts.length, 0);
  assert.equal(state.balances.find((row) => row.stockItemId === STOCK_SHARED_ID)?.quantity, '5');
  assert.equal(state.orders.find((row) => row.id === order.id)?.state, OrderState.DRAFT);
});

test('cancelled orders never deduct stock when finalization is attempted', async () => {
  const { prisma, state } = createFakePrisma();
  const service = new SalesService(prisma);
  addStockItem(state, STOCK_SHARED_ID, 'Coffee Beans');
  setBalance(state, STOCK_SHARED_ID, '10');
  trackVariant(state, VARIANT_A, RECIPE_A_ID, [
    { stockItemId: STOCK_SHARED_ID, quantityPerSaleUnit: '3' },
  ]);

  const { actor, order, quote } = await prepareOrder(service, KEY_ONE, [
    { variantId: VARIANT_A, quantity: 1 },
  ]);
  await service.cancelOrder(OUTLET_ID, order.id, { version: 1 }, actor);

  await assert.rejects(
    () =>
      service.finalize(
        OUTLET_ID,
        KEY_TWO,
        {
          deviceId: DEVICE_ID,
          orderId: order.id,
          quoteId: quote.id,
          payment: finalizePayment(18000),
        },
        actor,
      ),
    (error: unknown) =>
      error instanceof HttpException &&
      error.getStatus() === 409 &&
      (error.getResponse() as { code: string }).code === 'ORDER_NOT_DRAFT',
  );

  assert.equal(state.movements.length, 0);
  assert.equal(state.sales.length, 0);
  assert.equal(state.balances.find((row) => row.stockItemId === STOCK_SHARED_ID)?.quantity, '10');
});

test('simultaneous finalizations cannot oversell; only one sale and movement commit', async () => {
  const { prisma, state } = createFakePrisma();
  const service = new SalesService(prisma);
  addStockItem(state, STOCK_SHARED_ID, 'Coffee Beans');
  setBalance(state, STOCK_SHARED_ID, '6');
  trackVariant(state, VARIANT_A, RECIPE_A_ID, [
    { stockItemId: STOCK_SHARED_ID, quantityPerSaleUnit: '3' },
  ]);

  const first = await prepareOrder(service, KEY_ONE, [{ variantId: VARIANT_A, quantity: 2 }]);
  const second = await prepareOrder(service, KEY_TWO, [{ variantId: VARIANT_A, quantity: 2 }]);

  let tail = Promise.resolve();
  const original = prisma.$transaction.bind(prisma) as unknown as (
    operation: (tx: unknown) => Promise<unknown>,
    options?: unknown,
  ) => Promise<unknown>;
  (prisma as unknown as { $transaction: typeof original }).$transaction = async (
    operation: (tx: unknown) => Promise<unknown>,
    options?: unknown,
  ) => {
    const previous = tail;
    let release: () => void = () => undefined;
    tail = new Promise<void>((resolve) => {
      release = resolve;
    });
    await previous;

    try {
      return await original(operation, options);
    } finally {
      release();
    }
  };

  const results = await Promise.allSettled([
    service.finalize(
      OUTLET_ID,
      KEY_THREE,
      {
        deviceId: DEVICE_ID,
        orderId: first.order.id,
        quoteId: first.quote.id,
        payment: finalizePayment(36000),
      },
      first.actor,
    ),
    service.finalize(
      OUTLET_ID,
      KEY_THREE,
      {
        deviceId: DEVICE_ID,
        orderId: second.order.id,
        quoteId: second.quote.id,
        payment: finalizePayment(36000),
      },
      second.actor,
    ),
  ]);

  const fulfilled = results.filter((result) => result.status === 'fulfilled');
  const rejected = results.filter((result) => result.status === 'rejected');
  assert.equal(fulfilled.length, 1);
  assert.equal(rejected.length, 1);

  const failure = (rejected[0] as PromiseRejectedResult).reason;
  assert.ok(failure instanceof HttpException);
  assert.equal(failure.getStatus(), 422);
  assert.equal((failure.getResponse() as { code: string }).code, 'INSUFFICIENT_STOCK');

  const balance = state.balances.find((row) => row.stockItemId === STOCK_SHARED_ID);
  assert.equal(balance?.quantity, '0');
  assert.ok(Number(balance?.quantity) >= 0);
  assert.equal(state.sales.length, 1);
  assert.equal(state.movements.length, 1);
  assert.equal(state.movements[0]?.delta, '-6');
  assert.equal(state.movements[0]?.sourceId, state.sales[0]?.id);
});

test('owner reversal validates reason, keeps the sale immutable, and links the reversal', async () => {
  const { prisma, state } = createFakePrisma();
  const service = new SalesService(prisma);
  addStockItem(state, STOCK_SHARED_ID, 'Coffee Beans');
  setBalance(state, STOCK_SHARED_ID, '10');
  trackVariant(state, VARIANT_A, RECIPE_A_ID, [
    { stockItemId: STOCK_SHARED_ID, quantityPerSaleUnit: '3' },
  ]);

  const { actor: cashier, order, quote } = await prepareOrder(service, KEY_ONE, [
    { variantId: VARIANT_A, quantity: 2 },
  ]);
  const finalized = await service.finalize(
    OUTLET_ID,
    KEY_TWO,
    {
      deviceId: DEVICE_ID,
      orderId: order.id,
      quoteId: quote.id,
      payment: finalizePayment(36000),
    },
    cashier,
  );
  const owner = user(Role.OWNER, OWNER_ID);
  const saleBefore = structuredClone(state.sales[0]!);
  const movementsBefore = state.movements.length;

  await assert.rejects(
    () =>
      service.reverse(
        OUTLET_ID,
        finalized.sale.id,
        KEY_THREE,
        { reason: 'no', restock: [] },
        owner,
      ),
    (error: unknown) => statusOf(error) === 400 && codeOf(error) === 'VALIDATION_ERROR',
  );

  await assert.rejects(
    () =>
      service.reverse(
        OUTLET_ID,
        finalized.sale.id,
        KEY_THREE,
        { reason: 'Customer changed mind', restock: [] },
        cashier,
      ),
    (error: unknown) => statusOf(error) === 403 && codeOf(error) === 'FORBIDDEN',
  );

  const reversal = await service.reverse(
    OUTLET_ID,
    finalized.sale.id,
    KEY_THREE,
    { reason: '  Customer changed mind  ', restock: [] },
    owner,
  );

  assert.equal(reversal.saleId, finalized.sale.id);
  assert.equal(reversal.reason, 'Customer changed mind');
  assert.equal(reversal.externalRefundPerformed, false);
  assert.deepEqual(reversal.restock, []);
  assert.equal(state.reversals.length, 1);
  assert.equal(state.movements.length, movementsBefore);
  assert.equal(state.sales[0]?.state, 'COMPLETED');
  assert.deepEqual(
    {
      totals: state.sales[0]?.totalMinor,
      subtotal: state.sales[0]?.subtotalMinor,
      state: state.sales[0]?.state,
      lines: state.sales[0]?.lines,
    },
    {
      totals: saleBefore.totalMinor,
      subtotal: saleBefore.subtotalMinor,
      state: saleBefore.state,
      lines: saleBefore.lines,
    },
  );

  const reread = await service.getSale(OUTLET_ID, finalized.sale.id, owner);
  assert.equal(reread.state, 'COMPLETED');
  assert.equal(reread.totals.totalMinor, 36000);
  assert.equal(reread.reversal?.id, reversal.id);
  assert.equal(reread.reversal?.externalRefundPerformed, false);

  await assert.rejects(
    () =>
      service.reverse(
        OUTLET_ID,
        '00000000-0000-4000-8000-0000000000ff',
        KEY_ONE,
        { reason: 'Unknown sale', restock: [] },
        owner,
      ),
    (error: unknown) => statusOf(error) === 404 && codeOf(error) === 'NOT_FOUND',
  );
});

test('a sale that is not completed cannot be reversed', async () => {
  const { prisma, state } = createFakePrisma();
  const service = new SalesService(prisma);
  const { actor: cashier, order, quote } = await prepareOrder(service, KEY_ONE, [
    { variantId: VARIANT_A, quantity: 1 },
  ]);
  const finalized = await service.finalize(
    OUTLET_ID,
    KEY_TWO,
    {
      deviceId: DEVICE_ID,
      orderId: order.id,
      quoteId: quote.id,
      payment: finalizePayment(18000),
    },
    cashier,
  );
  state.sales[0]!.state = SaleState.REVERSED;

  await assert.rejects(
    () =>
      service.reverse(
        OUTLET_ID,
        finalized.sale.id,
        KEY_THREE,
        { reason: 'Legacy reversed sale', restock: [] },
        user(Role.OWNER, OWNER_ID),
      ),
    (error: unknown) => statusOf(error) === 409 && codeOf(error) === 'SALE_NOT_COMPLETED',
  );
});

test('reversal restocks only explicitly selected sold items and rejects invalid selections', async () => {
  const { prisma, state } = createFakePrisma();
  const service = new SalesService(prisma);
  const untouchedStockId = '00000000-0000-4000-8000-000000000052';
  addStockItem(state, STOCK_SHARED_ID, 'Coffee Beans');
  addStockItem(state, STOCK_SECOND_ID, 'Fresh Milk');
  addStockItem(state, untouchedStockId, 'Paper Cups');
  setBalance(state, STOCK_SHARED_ID, '10');
  setBalance(state, STOCK_SECOND_ID, '20');
  setBalance(state, untouchedStockId, '50');
  trackVariant(state, VARIANT_A, RECIPE_A_ID, [
    { stockItemId: STOCK_SHARED_ID, quantityPerSaleUnit: '3' },
    { stockItemId: STOCK_SECOND_ID, quantityPerSaleUnit: '2' },
  ]);

  const { actor: cashier, order, quote } = await prepareOrder(service, KEY_ONE, [
    { variantId: VARIANT_A, quantity: 2 },
  ]);
  const finalized = await service.finalize(
    OUTLET_ID,
    KEY_TWO,
    {
      deviceId: DEVICE_ID,
      orderId: order.id,
      quoteId: quote.id,
      payment: finalizePayment(36000),
    },
    cashier,
  );
  const owner = user(Role.OWNER, OWNER_ID);
  const movementsBefore = state.movements.length;

  await assert.rejects(
    () =>
      service.reverse(
        OUTLET_ID,
        finalized.sale.id,
        KEY_THREE,
        {
          reason: 'Returned beans only',
          restock: [{ stockItemId: untouchedStockId, quantity: '1' }],
        },
        owner,
      ),
    (error: unknown) => statusOf(error) === 422 && codeOf(error) === 'RESTOCK_ITEM_NOT_SOLD',
  );

  await assert.rejects(
    () =>
      service.reverse(
        OUTLET_ID,
        finalized.sale.id,
        KEY_THREE,
        { reason: 'Returned beans only', restock: [{ stockItemId: STOCK_SHARED_ID, quantity: '0' }] },
        owner,
      ),
    (error: unknown) => statusOf(error) === 422 && codeOf(error) === 'INVALID_RESTOCK_QUANTITY',
  );

  await assert.rejects(
    () =>
      service.reverse(
        OUTLET_ID,
        finalized.sale.id,
        KEY_THREE,
        {
          reason: 'Returned too many beans',
          restock: [{ stockItemId: STOCK_SHARED_ID, quantity: '7' }],
        },
        owner,
      ),
    (error: unknown) => statusOf(error) === 422 && codeOf(error) === 'RESTOCK_EXCEEDS_SOLD',
  );

  const reversal = await service.reverse(
    OUTLET_ID,
    finalized.sale.id,
    KEY_THREE,
    {
      reason: 'Returned beans only',
      restock: [{ stockItemId: STOCK_SHARED_ID, quantity: '4' }],
    },
    owner,
  );

  assert.deepEqual(reversal.restock, [{ stockItemId: STOCK_SHARED_ID, quantity: '4' }]);
  assert.equal(state.movements.length, movementsBefore + 1);
  const movement = state.movements.at(-1);
  assert.equal(movement?.type, 'REVERSAL');
  assert.equal(movement?.delta, '4');
  assert.equal(movement?.sourceId, reversal.id);
  assert.equal(
    state.balances.find((row) => row.stockItemId === STOCK_SHARED_ID)?.quantity,
    '8',
  );
  assert.equal(
    state.balances.find((row) => row.stockItemId === STOCK_SECOND_ID)?.quantity,
    '16',
  );
  assert.equal(
    state.balances.find((row) => row.stockItemId === untouchedStockId)?.quantity,
    '50',
  );
});

test('reversal idempotency replays the same response and rejects a second key', async () => {
  const { prisma, state } = createFakePrisma();
  const service = new SalesService(prisma);
  addStockItem(state, STOCK_SHARED_ID, 'Coffee Beans');
  setBalance(state, STOCK_SHARED_ID, '10');
  trackVariant(state, VARIANT_A, RECIPE_A_ID, [
    { stockItemId: STOCK_SHARED_ID, quantityPerSaleUnit: '3' },
  ]);

  const { actor: cashier, order, quote } = await prepareOrder(service, KEY_ONE, [
    { variantId: VARIANT_A, quantity: 1 },
  ]);
  const finalized = await service.finalize(
    OUTLET_ID,
    KEY_TWO,
    {
      deviceId: DEVICE_ID,
      orderId: order.id,
      quoteId: quote.id,
      payment: finalizePayment(18000),
    },
    cashier,
  );
  const owner = user(Role.OWNER, OWNER_ID);
  const payload = {
    reason: 'Returned item',
    restock: [{ stockItemId: STOCK_SHARED_ID, quantity: '3' }],
  };

  const first = await service.reverse(OUTLET_ID, finalized.sale.id, KEY_THREE, payload, owner);
  const movementsAfterFirst = state.movements.length;
  const replay = await service.reverse(OUTLET_ID, finalized.sale.id, KEY_THREE, payload, owner);

  assert.deepEqual(replay, first);
  assert.equal(state.reversals.length, 1);
  assert.equal(state.movements.length, movementsAfterFirst);

  await assert.rejects(
    () =>
      service.reverse(
        OUTLET_ID,
        finalized.sale.id,
        KEY_ONE,
        { reason: 'Different key', restock: [] },
        owner,
      ),
    (error: unknown) => statusOf(error) === 409 && codeOf(error) === 'SALE_ALREADY_REVERSED',
  );

  await assert.rejects(
    () =>
      service.reverse(
        OUTLET_ID,
        finalized.sale.id,
        KEY_THREE,
        { reason: 'Changed payload', restock: [] },
        owner,
      ),
    (error: unknown) => statusOf(error) === 409 && codeOf(error) === 'IDEMPOTENCY_CONFLICT',
  );
});

test('concurrent reversal with the same key creates one reversal and one stock movement set', async () => {
  const { prisma, state } = createFakePrisma();
  const service = new SalesService(prisma);
  addStockItem(state, STOCK_SHARED_ID, 'Coffee Beans');
  setBalance(state, STOCK_SHARED_ID, '10');
  trackVariant(state, VARIANT_A, RECIPE_A_ID, [
    { stockItemId: STOCK_SHARED_ID, quantityPerSaleUnit: '3' },
  ]);

  const { actor: cashier, order, quote } = await prepareOrder(service, KEY_ONE, [
    { variantId: VARIANT_A, quantity: 1 },
  ]);
  const finalized = await service.finalize(
    OUTLET_ID,
    KEY_TWO,
    {
      deviceId: DEVICE_ID,
      orderId: order.id,
      quoteId: quote.id,
      payment: finalizePayment(18000),
    },
    cashier,
  );
  const owner = user(Role.OWNER, OWNER_ID);
  const payload = {
    reason: 'Concurrent retry',
    restock: [{ stockItemId: STOCK_SHARED_ID, quantity: '3' }],
  };

  let tail = Promise.resolve();
  const original = prisma.$transaction.bind(prisma) as unknown as (
    operation: (tx: unknown) => Promise<unknown>,
    options?: unknown,
  ) => Promise<unknown>;
  (prisma as unknown as { $transaction: typeof original }).$transaction = async (
    operation: (tx: unknown) => Promise<unknown>,
    options?: unknown,
  ) => {
    const previous = tail;
    let release: () => void = () => undefined;
    tail = new Promise<void>((resolve) => {
      release = resolve;
    });
    await previous;

    try {
      return await original(operation, options);
    } finally {
      release();
    }
  };

  const responses = await Promise.all([
    service.reverse(OUTLET_ID, finalized.sale.id, KEY_THREE, payload, owner),
    service.reverse(OUTLET_ID, finalized.sale.id, KEY_THREE, payload, owner),
  ]);

  assert.equal(responses[0]?.id, responses[1]?.id);
  assert.equal(state.reversals.length, 1);
  assert.equal(state.movements.filter((movement) => movement.type === 'REVERSAL').length, 1);
  assert.equal(
    state.balances.find((row) => row.stockItemId === STOCK_SHARED_ID)?.quantity,
    '10',
  );
});

test('serialization and deadlock retries are bounded at three attempts before a retryable 503', async () => {
  const failures: { code: string; meta?: { code: string } }[] = [
    { code: 'P2034' },
    { code: '40001' },
    { code: '40P01' },
    { code: 'P2010', meta: { code: '40001' } },
    { code: 'P2010', meta: { code: '40P01' } },
  ];

  for (const failure of failures) {
    const { prisma } = createFakePrisma();
    const service = new SalesService(prisma);
    let attempts = 0;
    const serializationFailure = new Prisma.PrismaClientKnownRequestError(
      'concurrent transaction failure',
      { code: failure.code, clientVersion: '6.19.3', meta: failure.meta },
    );

    (prisma as unknown as { $transaction: () => Promise<never> }).$transaction = async () => {
      attempts += 1;
      throw serializationFailure;
    };

    await assert.rejects(
      () =>
        service.finalize(
          OUTLET_ID,
          KEY_TWO,
          {
            deviceId: DEVICE_ID,
            orderId: '00000000-0000-4000-8000-0000000000ff',
            quoteId: '00000000-0000-4000-8000-0000000000fe',
            payment: finalizePayment(18000),
          },
          user(),
        ),
      (error: unknown) => {
        assert.ok(error instanceof HttpException);
        assert.equal(error.getStatus(), 503);
        const response = error.getResponse() as { code: string; retryable: boolean };
        assert.equal(response.code, 'TRANSACTION_RETRY_EXHAUSTED');
        assert.equal(response.retryable, true);
        return true;
      },
    );

    assert.equal(attempts, 3);
  }
});
