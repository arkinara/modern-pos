import assert from 'node:assert/strict';
import { afterEach, test } from 'node:test';
import { HttpException } from '@nestjs/common';
import {
  ChannelOrderState,
  ChannelPaymentMode,
  ChannelPaymentStatus,
  CustomerContactType,
  OrderChannel,
  Prisma,
  Role,
  StockMovementType,
  StockPolicy,
} from '@prisma/client';
import type { AuthenticatedUser } from '../auth/auth.types';
import type { PrismaService } from '../prisma/prisma.service';
import { signWebhookPayload } from '../payments/webhook-signature';
import { ChannelConfigService } from './channel-config.service';
import { ChannelRegistryService } from './channel-registry.service';
import { OrderingService } from './ordering.service';
import type {
  ChannelOrderCancelDto,
  ChannelOrderFulfillDto,
  ChannelOrderListQueryDto,
  ChannelOrderManualDto,
  ChannelOrderWebhookDto,
  ChannelCustomerDto,
} from './dto/channel-order.dto';

const BUSINESS_ID = '00000000-0000-4000-8000-000000000001';
const OUTLET_ID = '00000000-0000-4000-8000-000000000002';
const OWNER_ID = '00000000-0000-4000-8000-000000000003';
const VARIANT_ID = '00000000-0000-4000-8000-000000000010';
const UNTRACKED_VARIANT_ID = '00000000-0000-4000-8000-000000000011';
const MENU_ITEM_ID = '00000000-0000-4000-8000-000000000020';
const COFFEE_ID = '00000000-0000-4000-8000-000000000030';
const MILK_ID = '00000000-0000-4000-8000-000000000031';
const CUSTOMER_ID = '00000000-0000-4000-8000-000000000040';

const PRICE_MINOR = 10_000n;
const ORDER_TOTAL_MINOR = 20_000n;

const savedEnv = new Map<string, string | undefined>();

function setEnv(values: Record<string, string | undefined>): void {
  for (const [key, value] of Object.entries(values)) {
    if (!savedEnv.has(key)) {
      savedEnv.set(key, process.env[key]);
    }
    if (value === undefined) {
      delete process.env[key];
    } else {
      process.env[key] = value;
    }
  }
}

afterEach(() => {
  for (const [key, value] of savedEnv) {
    if (value === undefined) {
      delete process.env[key];
    } else {
      process.env[key] = value;
    }
  }
  savedEnv.clear();
});

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

interface VariantRow {
  id: string;
  businessId: string;
  name: string;
  priceMinor: bigint;
  active: boolean;
  stockPolicy: StockPolicy;
  menuItem: { name: string; archivedAt: Date | null; category: { archivedAt: Date | null } };
  outletMenus: { outletId: string; enabled: boolean }[];
}

interface RecipeRow {
  id: string;
  businessId: string;
  outletId: string;
  variantId: string;
  version: number;
  effectiveAt: Date;
  createdAt: Date;
  lines: { stockItemId: string; quantityPerSaleUnit: Prisma.Decimal }[];
}

interface StockItemRow {
  id: string;
  businessId: string;
  name: string;
  baseUnit: 'g' | 'ml' | 'each';
  quantityScale: number;
  archivedAt: Date | null;
}

interface BalanceRow {
  id: string;
  outletId: string;
  stockItemId: string;
  quantity: Prisma.Decimal;
  version: number;
}

interface MovementRow {
  id: string;
  outletId: string;
  stockItemId: string;
  delta: Prisma.Decimal;
  type: StockMovementType;
  actorId: string;
  reason: string;
  sourceId: string;
  createdAt: Date;
}

interface CustomerRow {
  id: string;
  businessId: string;
  outletId: string;
  name: string;
  contactType: CustomerContactType;
  contactNormalized: string;
  email: string | null;
  phone: string | null;
  consentAt: Date;
  consentSource: string;
  anonymizedAt: Date | null;
  createdAt: Date;
  updatedAt: Date;
}

interface LineRow {
  id: string;
  orderId: string;
  variantId: string;
  name: string;
  variantName: string;
  quantity: number;
  unitPriceMinor: bigint;
  lineSubtotalMinor: bigint;
  recipeVersion: number | null;
  createdAt: Date;
}

interface PaymentRow {
  id: string;
  orderId: string;
  amountMinor: bigint;
  status: ChannelPaymentStatus;
  method: ChannelPaymentMode;
  reference: string | null;
  recordedById: string | null;
  createdAt: Date;
}

interface EventRow {
  id: string;
  orderId: string;
  fromState: ChannelOrderState;
  toState: ChannelOrderState;
  actorId: string | null;
  reason: string;
  createdAt: Date;
}

interface OrderRow {
  id: string;
  businessId: string;
  outletId: string;
  channel: OrderChannel;
  channelReference: string;
  requestHash: string;
  state: ChannelOrderState;
  paymentMode: ChannelPaymentMode;
  paymentStatus: ChannelPaymentStatus;
  currency: string;
  currencyExponent: number;
  subtotalMinor: bigint;
  serviceMinor: bigint;
  taxMinor: bigint;
  totalMinor: bigint;
  note: string;
  customerId: string | null;
  acceptedAt: Date | null;
  fulfilledAt: Date | null;
  cancelledAt: Date | null;
  cancellationReason: string | null;
  version: number;
  createdAt: Date;
  updatedAt: Date;
  lines: LineRow[];
  payments: PaymentRow[];
  events: EventRow[];
}

interface FakeState {
  variants: VariantRow[];
  recipes: RecipeRow[];
  stockItems: StockItemRow[];
  balances: BalanceRow[];
  movements: MovementRow[];
  customers: CustomerRow[];
  orders: OrderRow[];
}

interface FakeOptions {
  serializationFailures?: number;
}

function uniqueError(): Prisma.PrismaClientKnownRequestError {
  return new Prisma.PrismaClientKnownRequestError('Unique constraint failed', {
    code: 'P2002',
    clientVersion: '6.19.3',
  });
}

function serializationError(): Prisma.PrismaClientKnownRequestError {
  return new Prisma.PrismaClientKnownRequestError('Could not serialize access', {
    code: 'P2034',
    clientVersion: '6.19.3',
  });
}

function cloneState(state: FakeState): FakeState {
  return {
    variants: state.variants.map((variant) => ({ ...variant })),
    recipes: state.recipes.map((recipe) => ({ ...recipe, lines: [...recipe.lines] })),
    stockItems: state.stockItems.map((item) => ({ ...item })),
    balances: state.balances.map((balance) => ({ ...balance })),
    movements: state.movements.map((movement) => ({ ...movement })),
    customers: state.customers.map((customer) => ({ ...customer })),
    orders: state.orders.map((order) => ({
      ...order,
      lines: order.lines.map((line) => ({ ...line })),
      payments: order.payments.map((payment) => ({ ...payment })),
      events: order.events.map((event) => ({ ...event })),
    })),
  };
}

function restoreState(target: FakeState, snapshot: FakeState): void {
  target.variants = snapshot.variants;
  target.recipes = snapshot.recipes;
  target.stockItems = snapshot.stockItems;
  target.balances = snapshot.balances;
  target.movements = snapshot.movements;
  target.customers = snapshot.customers;
  target.orders = snapshot.orders;
}

function fakePrisma(options: FakeOptions = {}): {
  prisma: PrismaService;
  state: FakeState;
} {
  const state: FakeState = {
    variants: [
      {
        id: VARIANT_ID,
        businessId: BUSINESS_ID,
        name: 'Large',
        priceMinor: PRICE_MINOR,
        active: true,
        stockPolicy: StockPolicy.TRACKED,
        menuItem: { name: 'Latte', archivedAt: null, category: { archivedAt: null } },
        outletMenus: [{ outletId: OUTLET_ID, enabled: true }],
      },
      {
        id: UNTRACKED_VARIANT_ID,
        businessId: BUSINESS_ID,
        name: 'Regular',
        priceMinor: PRICE_MINOR,
        active: true,
        stockPolicy: StockPolicy.UNTRACKED,
        menuItem: { name: 'Americano', archivedAt: null, category: { archivedAt: null } },
        outletMenus: [{ outletId: OUTLET_ID, enabled: true }],
      },
    ],
    recipes: [
      {
        id: 'recipe-1',
        businessId: BUSINESS_ID,
        outletId: OUTLET_ID,
        variantId: VARIANT_ID,
        version: 3,
        effectiveAt: new Date('2026-01-01T00:00:00Z'),
        createdAt: new Date('2026-01-01T00:00:00Z'),
        lines: [
          { stockItemId: COFFEE_ID, quantityPerSaleUnit: new Prisma.Decimal('2') },
          { stockItemId: MILK_ID, quantityPerSaleUnit: new Prisma.Decimal('100') },
        ],
      },
    ],
    stockItems: [
      {
        id: COFFEE_ID,
        businessId: BUSINESS_ID,
        name: 'Coffee Beans',
        baseUnit: 'g',
        quantityScale: 2,
        archivedAt: null,
      },
      {
        id: MILK_ID,
        businessId: BUSINESS_ID,
        name: 'Fresh Milk',
        baseUnit: 'ml',
        quantityScale: 0,
        archivedAt: null,
      },
    ],
    balances: [
      {
        id: 'balance-coffee',
        outletId: OUTLET_ID,
        stockItemId: COFFEE_ID,
        quantity: new Prisma.Decimal('1000'),
        version: 1,
      },
      {
        id: 'balance-milk',
        outletId: OUTLET_ID,
        stockItemId: MILK_ID,
        quantity: new Prisma.Decimal('5000'),
        version: 1,
      },
    ],
    movements: [],
    customers: [],
    orders: [],
  };

  let sequence = 0;
  let serializationFailures = options.serializationFailures ?? 0;
  const nextId = (): string =>
    `00000000-0000-4000-8000-${String(500 + sequence++).padStart(12, '0')}`;

  const orderInclude = (order: OrderRow): OrderRow => ({
    ...order,
    lines: order.lines.map((line) => ({ ...line })),
    payments: order.payments.map((payment) => ({ ...payment })),
    events: order.events.map((event) => ({ ...event })),
  });

  const matchingOrders = (where: {
    id?: string;
    outletId?: string;
    businessId?: string;
    state?: ChannelOrderState;
    channel?: OrderChannel;
    OR?: { channelReference?: { contains: string }; note?: { contains: string } }[];
  }): OrderRow[] => {
    const search = where.OR?.[0]?.channelReference?.contains.toLowerCase();
    return state.orders.filter(
      (order) =>
        (where.id === undefined || order.id === where.id) &&
        (where.outletId === undefined || order.outletId === where.outletId) &&
        (where.businessId === undefined || order.businessId === where.businessId) &&
        (where.state === undefined || order.state === where.state) &&
        (where.channel === undefined || order.channel === where.channel) &&
        (search === undefined ||
          order.channelReference.toLowerCase().includes(search) ||
          order.note.toLowerCase().includes(search)),
    );
  };

  const client = {
    outlet: {
      findFirst: async (args: { where: { id: string; businessId: string } }) =>
        args.where.id === OUTLET_ID && args.where.businessId === BUSINESS_ID
          ? {
              id: OUTLET_ID,
              businessId: BUSINESS_ID,
              currency: 'IDR',
              currencyExponent: 0,
              serviceBps: 0,
              taxBps: 0,
            }
          : null,
      findUnique: async (args: { where: { id: string } }) =>
        args.where.id === OUTLET_ID
          ? {
              id: OUTLET_ID,
              businessId: BUSINESS_ID,
              currency: 'IDR',
              currencyExponent: 0,
              serviceBps: 0,
              taxBps: 0,
            }
          : null,
    },
    menuVariant: {
      findMany: async (args: {
        where: {
          id: { in: string[] };
          menuItem: { businessId: string };
          outletMenus?: { some: { outletId: string } };
        };
        include?: { outletMenus?: { where: { outletId: string } } };
        select?: { id: true; stockPolicy: true };
      }) => {
        const rows = state.variants.filter(
          (variant) =>
            args.where.id.in.includes(variant.id) &&
            variant.businessId === args.where.menuItem.businessId &&
            (args.where.outletMenus === undefined ||
              variant.outletMenus.some(
                (menu) => menu.outletId === args.where.outletMenus?.some.outletId,
              )),
        );
        if (args.select) {
          return rows.map((variant) => ({ id: variant.id, stockPolicy: variant.stockPolicy }));
        }
        return rows.map((variant) => ({
          ...variant,
          outletMenus: args.include?.outletMenus
            ? variant.outletMenus.filter(
                (menu) => menu.outletId === args.include?.outletMenus?.where.outletId,
              )
            : variant.outletMenus,
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
        orderBy?: { version: 'asc' };
        select?: {
          variantId: true;
          version: true;
          lines?: { select: { stockItemId: true; quantityPerSaleUnit: true } };
        };
      }) => {
        const rows = state.recipes.filter(
          (recipe) =>
            recipe.outletId === args.where.outletId &&
            (args.where.businessId === undefined || recipe.businessId === args.where.businessId) &&
            (args.where.variantId === undefined ||
              args.where.variantId.in.includes(recipe.variantId)) &&
            (args.where.OR === undefined ||
              args.where.OR.some(
                (pin) => pin.variantId === recipe.variantId && pin.version === recipe.version,
              )),
        );
        if (args.select?.lines) {
          return rows.map((recipe) => ({
            variantId: recipe.variantId,
            version: recipe.version,
            lines: recipe.lines.map((line) => ({ ...line })),
          }));
        }
        return rows
          .sort((a, b) => a.version - b.version)
          .map((recipe) => ({ variantId: recipe.variantId, version: recipe.version }));
      },
    },
    stockItem: {
      findMany: async (args: { where: { id: { in: string[] } } }) =>
        state.stockItems
          .filter((item) => args.where.id.in.includes(item.id))
          .map((item) => ({
            id: item.id,
            name: item.name,
            quantityScale: item.quantityScale,
          })),
    },
    stockBalance: {
      updateMany: async (args: {
        where: {
          outletId: string;
          stockItemId: string;
          version?: number;
          quantity?: { gte: Prisma.Decimal };
        };
        data: { quantity: Prisma.Decimal; version: { increment: number } };
      }) => {
        const balance = state.balances.find(
          (row) =>
            row.outletId === args.where.outletId &&
            row.stockItemId === args.where.stockItemId &&
            (args.where.version === undefined || row.version === args.where.version) &&
            (args.where.quantity === undefined ||
              row.quantity.greaterThanOrEqualTo(args.where.quantity.gte)),
        );
        if (!balance) {
          return { count: 0 };
        }
        balance.quantity = new Prisma.Decimal(args.data.quantity);
        balance.version += args.data.version.increment;
        return { count: 1 };
      },
    },
    stockMovement: {
      createMany: async (args: {
        data: {
          outletId: string;
          stockItemId: string;
          delta: Prisma.Decimal;
          type: StockMovementType;
          actorId: string;
          reason: string;
          sourceId: string;
        }[];
      }) => {
        for (const row of args.data) {
          state.movements.push({
            id: nextId(),
            outletId: row.outletId,
            stockItemId: row.stockItemId,
            delta: new Prisma.Decimal(row.delta),
            type: row.type,
            actorId: row.actorId,
            reason: row.reason,
            sourceId: row.sourceId,
            createdAt: new Date(),
          });
        }
        return { count: args.data.length };
      },
      findMany: async (args: { where: { sourceId: string; type: StockMovementType } }) =>
        state.movements
          .filter(
            (movement) =>
              movement.sourceId === args.where.sourceId && movement.type === args.where.type,
          )
          .map((movement) => ({
            stockItemId: movement.stockItemId,
            delta: movement.delta,
          })),
    },
    customer: {
      findUnique: async (args: {
        where: { outletId_contactNormalized: { outletId: string; contactNormalized: string } };
      }) => {
        const lookup = args.where.outletId_contactNormalized;
        return (
          state.customers.find(
            (customer) =>
              customer.outletId === lookup.outletId &&
              customer.contactNormalized === lookup.contactNormalized,
          ) ?? null
        );
      },
      create: async (args: {
        data: {
          businessId: string;
          outletId: string;
          name: string;
          contactType: CustomerContactType;
          contactNormalized: string;
          email: string | null;
          phone: string | null;
          consentAt: Date;
          consentSource: string;
        };
      }) => {
        const customer: CustomerRow = {
          id: nextId(),
          ...args.data,
          anonymizedAt: null,
          createdAt: new Date(),
          updatedAt: new Date(),
        };
        state.customers.push(customer);
        return customer;
      },
      update: async (args: { where: { id: string }; data: Record<string, unknown> }) => {
        const customer = state.customers.find((row) => row.id === args.where.id);
        if (!customer) {
          throw new Error('customer missing');
        }
        Object.assign(customer, args.data, { updatedAt: new Date() });
        return customer;
      },
    },
    channelOrder: {
      findUnique: async (args: {
        where:
          | { id: string }
          | {
              businessId_channel_channelReference: {
                businessId: string;
                channel: OrderChannel;
                channelReference: string;
              };
            };
      }) => {
        if ('id' in args.where) {
          const id = args.where.id;
          return state.orders.find((order) => order.id === id) ?? null;
        }
        const lookup = args.where.businessId_channel_channelReference;
        const order = state.orders.find(
          (row) =>
            row.businessId === lookup.businessId &&
            row.channel === lookup.channel &&
            row.channelReference === lookup.channelReference,
        );
        return order ? orderInclude(order) : null;
      },
      findUniqueOrThrow: async (args: { where: { id: string } }) => {
        const order = state.orders.find((row) => row.id === args.where.id);
        if (!order) {
          throw new Error('order missing');
        }
        return orderInclude(order);
      },
      findFirst: async (args: { where: { id: string; outletId: string; businessId: string } }) => {
        const order = state.orders.find(
          (row) =>
            row.id === args.where.id &&
            row.outletId === args.where.outletId &&
            row.businessId === args.where.businessId,
        );
        return order ? orderInclude(order) : null;
      },
      findMany: async (args: {
        where: {
          outletId: string;
          businessId: string;
          state?: ChannelOrderState;
          channel?: OrderChannel;
          OR?: { channelReference?: { contains: string }; note?: { contains: string } }[];
        };
        take: number;
      }) => {
        const rows = matchingOrders(args.where).sort(
          (a, b) => b.createdAt.getTime() - a.createdAt.getTime() || b.id.localeCompare(a.id),
        );
        return rows.slice(0, args.take).map((order) => orderInclude(order));
      },
      create: async (args: {
        data: {
          businessId: string;
          outletId: string;
          channel: OrderChannel;
          channelReference: string;
          requestHash: string;
          state: ChannelOrderState;
          paymentMode: ChannelPaymentMode;
          paymentStatus: ChannelPaymentStatus;
          currency: string;
          currencyExponent: number;
          subtotalMinor: bigint;
          serviceMinor: bigint;
          taxMinor: bigint;
          totalMinor: bigint;
          note: string;
          customerId: string | null;
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
          events: {
            create: {
              fromState: ChannelOrderState;
              toState: ChannelOrderState;
              actorId: string | null;
              reason: string;
            };
          };
        };
      }) => {
        if (
          state.orders.some(
            (order) =>
              order.businessId === args.data.businessId &&
              order.channel === args.data.channel &&
              order.channelReference === args.data.channelReference,
          )
        ) {
          throw uniqueError();
        }
        const now = new Date();
        const id = nextId();
        const order: OrderRow = {
          id,
          businessId: args.data.businessId,
          outletId: args.data.outletId,
          channel: args.data.channel,
          channelReference: args.data.channelReference,
          requestHash: args.data.requestHash,
          state: args.data.state,
          paymentMode: args.data.paymentMode,
          paymentStatus: args.data.paymentStatus,
          currency: args.data.currency,
          currencyExponent: args.data.currencyExponent,
          subtotalMinor: args.data.subtotalMinor,
          serviceMinor: args.data.serviceMinor,
          taxMinor: args.data.taxMinor,
          totalMinor: args.data.totalMinor,
          note: args.data.note,
          customerId: args.data.customerId,
          acceptedAt: null,
          fulfilledAt: null,
          cancelledAt: null,
          cancellationReason: null,
          version: 1,
          createdAt: now,
          updatedAt: now,
          lines: args.data.lines.create.map((line) => ({
            id: nextId(),
            orderId: id,
            ...line,
            createdAt: now,
          })),
          payments: [],
          events: [
            {
              id: nextId(),
              orderId: id,
              ...args.data.events.create,
              createdAt: now,
            },
          ],
        };
        state.orders.push(order);
        return orderInclude(order);
      },
      updateMany: async (args: {
        where: { id: string; state?: ChannelOrderState; version?: number };
        data: {
          state?: ChannelOrderState;
          paymentStatus?: ChannelPaymentStatus;
          acceptedAt?: Date;
          fulfilledAt?: Date;
          cancelledAt?: Date;
          cancellationReason?: string;
          version: { increment: number };
        };
      }) => {
        const order = state.orders.find(
          (row) =>
            row.id === args.where.id &&
            (args.where.state === undefined || row.state === args.where.state) &&
            (args.where.version === undefined || row.version === args.where.version),
        );
        if (!order) {
          return { count: 0 };
        }
        if (args.data.state !== undefined) {
          order.state = args.data.state;
        }
        if (args.data.paymentStatus !== undefined) {
          order.paymentStatus = args.data.paymentStatus;
        }
        if (args.data.acceptedAt !== undefined) {
          order.acceptedAt = args.data.acceptedAt;
        }
        if (args.data.fulfilledAt !== undefined) {
          order.fulfilledAt = args.data.fulfilledAt;
        }
        if (args.data.cancelledAt !== undefined) {
          order.cancelledAt = args.data.cancelledAt;
        }
        if (args.data.cancellationReason !== undefined) {
          order.cancellationReason = args.data.cancellationReason;
        }
        order.version += args.data.version.increment;
        order.updatedAt = new Date();
        return { count: 1 };
      },
    },
    channelOrderPayment: {
      create: async (args: {
        data: {
          orderId: string;
          amountMinor: bigint;
          status: ChannelPaymentStatus;
          method: ChannelPaymentMode;
          reference: string | null;
          recordedById: string | null;
        };
      }) => {
        const order = state.orders.find((row) => row.id === args.data.orderId);
        if (!order) {
          throw new Error('order missing');
        }
        if (order.payments.length > 0) {
          throw uniqueError();
        }
        const payment: PaymentRow = {
          id: nextId(),
          ...args.data,
          createdAt: new Date(),
        };
        order.payments.push(payment);
        return payment;
      },
    },
    channelOrderEvent: {
      create: async (args: {
        data: {
          orderId: string;
          fromState: ChannelOrderState;
          toState: ChannelOrderState;
          actorId: string | null;
          reason: string;
        };
      }) => {
        const order = state.orders.find((row) => row.id === args.data.orderId);
        if (!order) {
          throw new Error('order missing');
        }
        const event: EventRow = {
          id: nextId(),
          ...args.data,
          createdAt: new Date(),
        };
        order.events.push(event);
        return event;
      },
    },
    $queryRaw: async (): Promise<
      { stockItemId: string; quantity: Prisma.Decimal; version: number }[]
    > =>
      state.balances.map((balance) => ({
        stockItemId: balance.stockItemId,
        quantity: balance.quantity,
        version: balance.version,
      })),
  };

  let tail: Promise<void> = Promise.resolve();

  const prisma = {
    ...client,
    $transaction: async <T>(callback: (tx: unknown) => Promise<T>): Promise<T> => {
      if (serializationFailures > 0) {
        serializationFailures -= 1;
        throw serializationError();
      }
      let release!: () => void;
      const current = new Promise<void>((resolve) => {
        release = resolve;
      });
      const previous = tail;
      tail = current;
      await previous;
      const snapshot = cloneState(state);
      try {
        return await callback(client);
      } catch (error) {
        restoreState(state, snapshot);
        throw error;
      } finally {
        release();
      }
    },
  };

  return { prisma: prisma as unknown as PrismaService, state };
}

function serviceFor(prisma: PrismaService): OrderingService {
  const config = new ChannelConfigService();
  const registry = new ChannelRegistryService(config);
  return new OrderingService(prisma, registry, config);
}

function manualDto(overrides: Partial<ChannelOrderManualDto> = {}): ChannelOrderManualDto {
  return {
    channel: OrderChannel.MANUAL,
    reference: 'MANUAL-1',
    items: [{ variantId: VARIANT_ID, quantity: 2 }],
    ...overrides,
  };
}

function customerDto(overrides: Partial<ChannelCustomerDto> = {}): ChannelCustomerDto {
  return {
    name: 'Ada',
    contact: 'ada@example.test',
    contactType: CustomerContactType.EMAIL,
    consent: true,
    ...overrides,
  };
}

function movementCount(state: FakeState, type?: StockMovementType): number {
  return type === undefined
    ? state.movements.length
    : state.movements.filter((movement) => movement.type === type).length;
}

function deltaFor(state: FakeState, type: StockMovementType, stockItemId: string): string {
  return state.movements
    .filter((movement) => movement.type === type && movement.stockItemId === stockItemId)
    .reduce((total, movement) => total.plus(movement.delta), new Prisma.Decimal(0))
    .toString();
}

function paymentRows(state: FakeState): PaymentRow[] {
  return state.orders.flatMap((order) => order.payments);
}

function balanceOf(state: FakeState, stockItemId: string): string {
  return state.balances.find((balance) => balance.stockItemId === stockItemId)!.quantity.toString();
}

function assertApiError(error: unknown, status: number, code: string): boolean {
  assert.ok(error instanceof HttpException, `expected HttpException, got ${String(error)}`);
  assert.equal(error.getStatus(), status);
  assert.equal((error.getResponse() as { code: string }).code, code);
  return true;
}

async function createOrder(state: FakeState, service: OrderingService): Promise<OrderRow> {
  const created = await service.createManual(OUTLET_ID, manualDto(), owner());
  return state.orders.find((order) => order.id === created.order.id)!;
}

test('AC1 accept consumes the pinned recipe once and moves RECEIVED -> ACCEPTED (docs/online-ordering.md:68,114)', async () => {
  const { prisma, state } = fakePrisma();
  const service = serviceFor(prisma);
  const order = await createOrder(state, service);

  assert.equal(order.state, ChannelOrderState.RECEIVED);
  assert.equal(movementCount(state), 0);
  assert.equal(paymentRows(state).length, 0);

  const accepted = await service.accept(OUTLET_ID, order.id, owner());

  assert.equal(accepted.state, ChannelOrderState.ACCEPTED);
  assert.ok(accepted.acceptedAt !== null);
  assert.equal(accepted.version, 2);
  assert.equal(movementCount(state, StockMovementType.CHANNEL_ORDER_ACCEPT), 2);
  assert.equal(deltaFor(state, StockMovementType.CHANNEL_ORDER_ACCEPT, COFFEE_ID), '-4');
  assert.equal(deltaFor(state, StockMovementType.CHANNEL_ORDER_ACCEPT, MILK_ID), '-200');
  assert.equal(balanceOf(state, COFFEE_ID), '996');
  assert.equal(balanceOf(state, MILK_ID), '4800');
  assert.equal(paymentRows(state).length, 0);
  assert.equal(order.paymentStatus, ChannelPaymentStatus.UNPAID);
  assert.deepEqual(
    order.events.map((event) => [event.fromState, event.toState]),
    [
      [ChannelOrderState.RECEIVED, ChannelOrderState.RECEIVED],
      [ChannelOrderState.RECEIVED, ChannelOrderState.ACCEPTED],
    ],
  );
});

test('AC1 cancel from RECEIVED cancels with no stock or payment effect (docs/online-ordering.md:54,69)', async () => {
  const { prisma, state } = fakePrisma();
  const service = serviceFor(prisma);
  const order = await createOrder(state, service);
  const coffeeBefore = balanceOf(state, COFFEE_ID);
  const milkBefore = balanceOf(state, MILK_ID);

  const cancelDto: ChannelOrderCancelDto = { reason: 'Customer cancelled' };
  const cancelled = await service.cancel(OUTLET_ID, order.id, cancelDto, owner());

  assert.equal(cancelled.state, ChannelOrderState.CANCELLED);
  assert.equal(cancelled.cancellationReason, 'Customer cancelled');
  assert.equal(cancelled.version, 2);
  assert.equal(movementCount(state), 0);
  assert.equal(paymentRows(state).length, 0);
  assert.equal(balanceOf(state, COFFEE_ID), coffeeBefore);
  assert.equal(balanceOf(state, MILK_ID), milkBefore);
});

test('AC1 cancel from ACCEPTED restores exact accepted quantities once (docs/online-ordering.md:71,117)', async () => {
  const { prisma, state } = fakePrisma();
  const service = serviceFor(prisma);
  const order = await createOrder(state, service);
  await service.accept(OUTLET_ID, order.id, owner());

  const cancelDto: ChannelOrderCancelDto = { reason: 'Kitchen closed' };
  const cancelled = await service.cancel(OUTLET_ID, order.id, cancelDto, owner());

  assert.equal(cancelled.state, ChannelOrderState.CANCELLED);
  assert.equal(movementCount(state, StockMovementType.CHANNEL_ORDER_ACCEPT), 2);
  assert.equal(movementCount(state, StockMovementType.CHANNEL_ORDER_CANCEL), 2);
  assert.equal(deltaFor(state, StockMovementType.CHANNEL_ORDER_CANCEL, COFFEE_ID), '4');
  assert.equal(deltaFor(state, StockMovementType.CHANNEL_ORDER_CANCEL, MILK_ID), '200');
  assert.equal(balanceOf(state, COFFEE_ID), '1000');
  assert.equal(balanceOf(state, MILK_ID), '5000');
  assert.equal(paymentRows(state).length, 0);
});

test('AC1 fulfil records exactly one cash payment, no stock movement, and terminal FULFILLED (docs/online-ordering.md:70,84)', async () => {
  const { prisma, state } = fakePrisma();
  const service = serviceFor(prisma);
  const order = await createOrder(state, service);
  await service.accept(OUTLET_ID, order.id, owner());
  const acceptMovements = movementCount(state, StockMovementType.CHANNEL_ORDER_ACCEPT);

  const fulfillDto: ChannelOrderFulfillDto = {
    collectedMinor: ORDER_TOTAL_MINOR.toString(),
    reference: 'cash-1',
  };
  const fulfilled = await service.fulfill(OUTLET_ID, order.id, fulfillDto, owner());

  assert.equal(fulfilled.state, ChannelOrderState.FULFILLED);
  assert.equal(fulfilled.paymentStatus, ChannelPaymentStatus.PAID);
  assert.ok(fulfilled.fulfilledAt !== null);
  assert.equal(movementCount(state, StockMovementType.CHANNEL_ORDER_ACCEPT), acceptMovements);
  assert.equal(movementCount(state), acceptMovements);
  assert.equal(paymentRows(state).length, 1);
  assert.equal(paymentRows(state)[0]?.amountMinor, ORDER_TOTAL_MINOR);
  assert.equal(paymentRows(state)[0]?.status, ChannelPaymentStatus.PAID);
  assert.equal(paymentRows(state)[0]?.method, ChannelPaymentMode.CASH_ON_PICKUP);
  assert.deepEqual(
    order.events.map((event) => [event.fromState, event.toState]),
    [
      [ChannelOrderState.RECEIVED, ChannelOrderState.RECEIVED],
      [ChannelOrderState.RECEIVED, ChannelOrderState.ACCEPTED],
      [ChannelOrderState.ACCEPTED, ChannelOrderState.FULFILLED],
    ],
  );
});

test('AC1 unpaid orders stay unpaid through acceptance and a mismatched collection records nothing (docs/online-ordering.md:79,82)', async () => {
  const { prisma, state } = fakePrisma();
  const service = serviceFor(prisma);
  const order = await createOrder(state, service);
  const accepted = await service.accept(OUTLET_ID, order.id, owner());

  assert.equal(accepted.paymentStatus, ChannelPaymentStatus.UNPAID);
  assert.equal(paymentRows(state).length, 0);

  await assert.rejects(
    service.fulfill(OUTLET_ID, order.id, { collectedMinor: '19999' }, owner()),
    (error: unknown) => assertApiError(error, 422, 'PAYMENT_AMOUNT_MISMATCH'),
  );
  assert.equal(paymentRows(state).length, 0);
  assert.equal(state.orders[0]?.state, ChannelOrderState.ACCEPTED);
  assert.equal(state.orders[0]?.paymentStatus, ChannelPaymentStatus.UNPAID);
});

test('AC1 a second fulfil and accept after terminal state return 409 and write nothing (docs/online-ordering.md:73,85)', async () => {
  const { prisma, state } = fakePrisma();
  const service = serviceFor(prisma);
  const order = await createOrder(state, service);
  await service.accept(OUTLET_ID, order.id, owner());
  await service.fulfill(
    OUTLET_ID,
    order.id,
    { collectedMinor: ORDER_TOTAL_MINOR.toString() },
    owner(),
  );

  const movementsAfterFirstFulfil = movementCount(state);

  await assert.rejects(
    service.fulfill(OUTLET_ID, order.id, { collectedMinor: ORDER_TOTAL_MINOR.toString() }, owner()),
    (error: unknown) => assertApiError(error, 409, 'ORDER_STATE_INVALID'),
  );
  await assert.rejects(service.accept(OUTLET_ID, order.id, owner()), (error: unknown) =>
    assertApiError(error, 409, 'ORDER_STATE_INVALID'),
  );
  await assert.rejects(
    service.cancel(OUTLET_ID, order.id, { reason: 'Too late' }, owner()),
    (error: unknown) => assertApiError(error, 409, 'ORDER_STATE_INVALID'),
  );

  assert.equal(paymentRows(state).length, 1);
  assert.equal(movementCount(state), movementsAfterFirstFulfil);
  assert.equal(state.orders[0]?.state, ChannelOrderState.FULFILLED);
});

test('AC1 invalid transitions return documented 409 ORDER_STATE_INVALID (docs/online-ordering.md:73)', async () => {
  const { prisma, state } = fakePrisma();
  const service = serviceFor(prisma);
  const order = await createOrder(state, service);

  await assert.rejects(
    service.fulfill(OUTLET_ID, order.id, { collectedMinor: ORDER_TOTAL_MINOR.toString() }, owner()),
    (error: unknown) => assertApiError(error, 409, 'ORDER_STATE_INVALID'),
  );

  await service.accept(OUTLET_ID, order.id, owner());
  await assert.rejects(service.accept(OUTLET_ID, order.id, owner()), (error: unknown) =>
    assertApiError(error, 409, 'ORDER_STATE_INVALID'),
  );

  await service.cancel(OUTLET_ID, order.id, { reason: 'After accept' }, owner());
  await assert.rejects(service.accept(OUTLET_ID, order.id, owner()), (error: unknown) =>
    assertApiError(error, 409, 'ORDER_STATE_INVALID'),
  );

  assert.equal(movementCount(state, StockMovementType.CHANNEL_ORDER_ACCEPT), 2);
  assert.equal(movementCount(state, StockMovementType.CHANNEL_ORDER_CANCEL), 2);
  assert.equal(paymentRows(state).length, 0);
});

test('AC1 PREPAID_PROVIDER is rejected with 422 and creates no order (docs/online-ordering.md:88)', async () => {
  const { prisma, state } = fakePrisma();
  const service = serviceFor(prisma);

  await assert.rejects(
    service.createManual(
      OUTLET_ID,
      manualDto({ paymentMode: ChannelPaymentMode.PREPAID_PROVIDER }),
      owner(),
    ),
    (error: unknown) => assertApiError(error, 422, 'PAYMENT_MODE_UNAVAILABLE'),
  );

  assert.equal(state.orders.length, 0);
  assert.equal(movementCount(state), 0);
  assert.equal(paymentRows(state).length, 0);
});

test('AC1 concurrent accept applies stock once and rejects the loser (docs/online-ordering.md:114,120)', async () => {
  const { prisma, state } = fakePrisma();
  const service = serviceFor(prisma);
  const order = await createOrder(state, service);

  const results = await Promise.allSettled([
    service.accept(OUTLET_ID, order.id, owner()),
    service.accept(OUTLET_ID, order.id, owner()),
  ]);

  assert.equal(results.filter((result) => result.status === 'fulfilled').length, 1);
  const rejected = results.find((result) => result.status === 'rejected');
  assert.ok(rejected?.status === 'rejected');
  assertApiError(rejected.reason, 409, 'ORDER_STATE_INVALID');
  assert.equal(movementCount(state, StockMovementType.CHANNEL_ORDER_ACCEPT), 2);
  assert.equal(balanceOf(state, COFFEE_ID), '996');
  assert.equal(balanceOf(state, MILK_ID), '4800');
  assert.equal(state.orders[0]?.version, 2);
});

test('AC1 a serialization failure is retried and commits exactly once (docs/online-ordering.md:120)', async () => {
  const { prisma, state } = fakePrisma({ serializationFailures: 1 });
  const service = serviceFor(prisma);

  const created = await service.createManual(OUTLET_ID, manualDto(), owner());

  assert.equal(created.duplicate, false);
  assert.equal(state.orders.length, 1);
  assert.equal(state.orders[0]?.channelReference, 'MANUAL-1');
});

test('AC1 ordering rejects a customer without consent before writing an order (docs/online-ordering.md:143)', async () => {
  const { prisma, state } = fakePrisma();
  const service = serviceFor(prisma);

  await assert.rejects(
    service.createManual(
      OUTLET_ID,
      manualDto({ customer: customerDto({ consent: false }) }),
      owner(),
    ),
    (error: unknown) => assertApiError(error, 422, 'CUSTOMER_CONSENT_REQUIRED'),
  );

  assert.equal(state.orders.length, 0);
  assert.equal(state.customers.length, 0);
});

test('AC1 ordering links a consented customer and rejects an anonymised contact (docs/online-ordering.md:152,158)', async () => {
  const { prisma, state } = fakePrisma();
  const service = serviceFor(prisma);

  const created = await service.createManual(
    OUTLET_ID,
    manualDto({ customer: customerDto() }),
    owner(),
  );

  assert.equal(created.order.customerId, state.customers[0]?.id);
  assert.equal(state.customers[0]?.contactNormalized, 'ada@example.test');

  state.customers[0]!.anonymizedAt = new Date();
  await assert.rejects(
    service.createManual(
      OUTLET_ID,
      manualDto({ reference: 'MANUAL-2', customer: customerDto() }),
      owner(),
    ),
    (error: unknown) => assertApiError(error, 409, 'CUSTOMER_RETENTION_EXPIRED'),
  );
  assert.equal(state.orders.length, 1);
});

test('AC2 a sequential duplicate delivery returns the same order with one intake event (docs/online-ordering.md:133)', async () => {
  const { prisma, state } = fakePrisma();
  const service = serviceFor(prisma);

  const first = await service.createManual(OUTLET_ID, manualDto(), owner());
  const replay = await service.createManual(OUTLET_ID, manualDto(), owner());

  assert.equal(first.duplicate, false);
  assert.equal(replay.duplicate, true);
  assert.equal(replay.order.id, first.order.id);
  assert.equal(state.orders.length, 1);
  assert.equal(state.orders[0]?.events.length, 1);
  assert.equal(movementCount(state), 0);
  assert.equal(paymentRows(state).length, 0);
});

test('AC2 a concurrent duplicate delivery resolves losers to the same order (docs/online-ordering.md:135)', async () => {
  const { prisma, state } = fakePrisma();
  const service = serviceFor(prisma);

  const [first, second] = await Promise.all([
    service.createManual(OUTLET_ID, manualDto(), owner()),
    service.createManual(OUTLET_ID, manualDto(), owner()),
  ]);

  assert.equal(state.orders.length, 1);
  assert.equal(first.order.id, second.order.id);
  assert.equal([first.duplicate, second.duplicate].filter(Boolean).length, 1);
  assert.equal(movementCount(state), 0);
  assert.equal(paymentRows(state).length, 0);
});

test('AC2 the same reference with a different payload is a 409 conflict that changes nothing (docs/online-ordering.md:137)', async () => {
  const { prisma, state } = fakePrisma();
  const service = serviceFor(prisma);

  await service.createManual(OUTLET_ID, manualDto(), owner());

  await assert.rejects(
    service.createManual(
      OUTLET_ID,
      manualDto({ items: [{ variantId: VARIANT_ID, quantity: 3 }] }),
      owner(),
    ),
    (error: unknown) => assertApiError(error, 409, 'CHANNEL_REFERENCE_CONFLICT'),
  );

  assert.equal(state.orders.length, 1);
  assert.equal(state.orders[0]?.totalMinor, ORDER_TOTAL_MINOR);
  assert.equal(movementCount(state), 0);
});

test('AC2 the channel reference is stored, returned and searchable (docs/online-ordering.md:130)', async () => {
  const { prisma, state } = fakePrisma();
  const service = serviceFor(prisma);
  const created = await service.createManual(
    OUTLET_ID,
    manualDto({ reference: 'WEB-REF-9001' }),
    owner(),
  );

  assert.equal(created.order.channelReference, 'WEB-REF-9001');
  assert.equal(
    (await service.get(OUTLET_ID, created.order.id, owner())).channelReference,
    'WEB-REF-9001',
  );

  const found = await service.list(
    OUTLET_ID,
    { search: 'ref-9001' } as ChannelOrderListQueryDto,
    owner(),
  );
  assert.equal(found.items.length, 1);
  assert.equal(found.items[0]?.id, created.order.id);

  const missing = await service.list(
    OUTLET_ID,
    { search: 'nope' } as ChannelOrderListQueryDto,
    owner(),
  );
  assert.equal(missing.items.length, 0);
});

function webhookSetup(): {
  service: OrderingService;
  state: FakeState;
  dto: ChannelOrderWebhookDto;
  rawBody: string;
} {
  setEnv({ CHANNEL_WEBHOOK_SECRET: 'unit-test-channel-secret' });
  const { prisma, state } = fakePrisma();
  const dto: ChannelOrderWebhookDto = {
    outletId: OUTLET_ID,
    reference: 'WEB-1',
    items: [{ variantId: VARIANT_ID, quantity: 2 }],
  };
  return {
    service: serviceFor(prisma),
    state,
    dto,
    rawBody: JSON.stringify(dto),
  };
}

function signature(secret: string, timestamp: number, rawBody: string): string {
  return `t=${timestamp},v1=${signWebhookPayload(secret, timestamp, rawBody)}`;
}

test('AC2 an invalid signature is rejected before any row is written (docs/online-ordering.md:139)', async () => {
  const { service, state, dto, rawBody } = webhookSetup();
  const now = Math.floor(Date.now() / 1000);

  await assert.rejects(
    service.handleWebhook('WEB', `t=${now},v1=deadbeef`, rawBody, dto),
    (error: unknown) => assertApiError(error, 401, 'CHANNEL_SIGNATURE_INVALID'),
  );
  await assert.rejects(service.handleWebhook('WEB', undefined, rawBody, dto), (error: unknown) =>
    assertApiError(error, 401, 'CHANNEL_SIGNATURE_INVALID'),
  );

  assert.equal(state.orders.length, 0);
  assert.equal(movementCount(state), 0);
  assert.equal(paymentRows(state).length, 0);
  assert.equal(state.customers.length, 0);
});

test('AC2 a replayed stale timestamp is rejected before any row is written (docs/online-ordering.md:139)', async () => {
  const { service, state, dto, rawBody } = webhookSetup();
  const stale = Math.floor(Date.now() / 1000) - 10_000;

  await assert.rejects(
    service.handleWebhook(
      'WEB',
      signature('unit-test-channel-secret', stale, rawBody),
      rawBody,
      dto,
    ),
    (error: unknown) => assertApiError(error, 401, 'CHANNEL_TIMESTAMP_INVALID'),
  );

  assert.equal(state.orders.length, 0);
  assert.equal(movementCount(state), 0);
});

test('AC2 a signed webhook is accepted once and a replay returns duplicate true (docs/online-ordering.md:133,139)', async () => {
  const { service, state, dto, rawBody } = webhookSetup();
  const now = Math.floor(Date.now() / 1000);
  const header = signature('unit-test-channel-secret', now, rawBody);

  const first = await service.handleWebhook('WEB', header, rawBody, dto);
  const replay = await service.handleWebhook('WEB', header, rawBody, dto);

  assert.equal(first.duplicate, false);
  assert.equal(first.order.channel, OrderChannel.WEB);
  assert.equal(first.order.channelReference, 'WEB-1');
  assert.equal(replay.duplicate, true);
  assert.equal(replay.order.id, first.order.id);
  assert.equal(state.orders.length, 1);
  assert.equal(state.orders[0]?.events.length, 1);
  assert.equal(movementCount(state), 0);
});
