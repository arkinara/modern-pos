import assert from 'node:assert/strict';
import { test } from 'node:test';
import { HttpException } from '@nestjs/common';
import { Prisma, Role } from '@prisma/client';
import type { AuthenticatedUser } from '../auth/auth.types';
import { ROLES_KEY } from '../common/decorators/roles.decorator';
import type { PrismaService } from '../prisma/prisma.service';
import { StockController } from './stock.controller';
import { StockService } from './stock.service';
import type { StockAdjustmentDto } from './dto/stock-adjustment.dto';
import type { StockChangeDto } from './dto/stock-change.dto';
import type { StockCreateDto } from './dto/stock-create.dto';
import type { StockListQueryDto } from './dto/stock-list-query.dto';
import type { MovementListQueryDto } from './dto/movement-list-query.dto';

const BUSINESS_ID = '00000000-0000-4000-8000-000000000001';
const OUTLET_ID = '00000000-0000-4000-8000-000000000002';
const OTHER_OUTLET_ID = '00000000-0000-4000-8000-000000000005';
const ITEM_ID = '00000000-0000-4000-8000-000000000050';
const OTHER_ITEM_ID = '00000000-0000-4000-8000-000000000051';
const KEY_ONE = '11111111-1111-4111-8111-111111111111';
const KEY_TWO = '22222222-2222-4222-8222-222222222222';

function user(role: Role = Role.OWNER): AuthenticatedUser {
  return {
    id: '00000000-0000-4000-8000-000000000003',
    businessId: BUSINESS_ID,
    email: 'owner@example.test',
    role,
    outletId: OUTLET_ID,
    outletIds: [OUTLET_ID],
    sessionId: 'session-1',
  };
}

interface ItemRow {
  id: string;
  businessId: string;
  name: string;
  baseUnit: 'g' | 'ml' | 'each';
  quantityScale: number;
  reorderThreshold: Prisma.Decimal;
  archivedAt: Date | null;
  createdAt: Date;
  updatedAt: Date;
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
  type: 'OPENING' | 'RECEIPT' | 'ADJUSTMENT' | 'SALE' | 'REVERSAL';
  actorId: string;
  reason: string;
  sourceId: string;
  createdAt: Date;
}

interface IdemRow {
  id: string;
  outletId: string;
  key: string;
  operation: string;
  requestHash: string;
  movementId: string | null;
  responseBody: unknown;
  createdAt: Date;
}

interface SaleRow {
  id: string;
  reference: string;
}

interface FakeState {
  items: ItemRow[];
  balances: BalanceRow[];
  movements: MovementRow[];
  idempotency: IdemRow[];
  sales: SaleRow[];
}

function uniqueError(): Prisma.PrismaClientKnownRequestError {
  return new Prisma.PrismaClientKnownRequestError('Unique constraint failed', {
    code: 'P2002',
    clientVersion: '6.19.3',
  });
}

function fakePrisma(options: { missingOutlet?: boolean } = {}): {
  prisma: PrismaService;
  state: FakeState;
} {
  const state: FakeState = {
    items: [
      {
        id: ITEM_ID,
        businessId: BUSINESS_ID,
        name: 'Coffee Beans',
        baseUnit: 'g',
        quantityScale: 2,
        reorderThreshold: new Prisma.Decimal('5000'),
        archivedAt: null,
        createdAt: new Date('2026-01-01T00:00:00Z'),
        updatedAt: new Date('2026-01-01T00:00:00Z'),
      },
      {
        id: OTHER_ITEM_ID,
        businessId: BUSINESS_ID,
        name: 'Fresh Milk',
        baseUnit: 'ml',
        quantityScale: 0,
        reorderThreshold: new Prisma.Decimal('4000'),
        archivedAt: null,
        createdAt: new Date('2026-01-01T00:00:00Z'),
        updatedAt: new Date('2026-01-01T00:00:00Z'),
      },
    ],
    balances: [],
    movements: [],
    idempotency: [],
    sales: [],
  };

  let sequence = 0;
  const nextId = (): string =>
    `00000000-0000-4000-8000-${String(100 + sequence++).padStart(12, '0')}`;

  const client = {
    sale: {
      findMany: async (args: {
        where: {
          id: { in: string[] };
          outletId: string;
          businessId: string;
        };
      }) =>
        state.sales.filter(
          (sale) =>
            args.where.id.in.includes(sale.id) &&
            args.where.outletId === OUTLET_ID &&
            args.where.businessId === BUSINESS_ID,
        ),
    },
    outlet: {
      findFirst: async (args: { where: { id: string; businessId: string } }) => {
        if (options.missingOutlet) {
          return null;
        }
        return args.where.id === OUTLET_ID && args.where.businessId === BUSINESS_ID
          ? { id: OUTLET_ID }
          : null;
      },
    },
    stockItem: {
      findMany: async (args: {
        where?: { businessId?: string; name?: { contains: string } };
        take: number;
        cursor?: { id: string };
        skip?: number;
        include?: { balances?: { where?: { outletId?: string } } };
      }) => {
        let rows = state.items.filter((item) => item.businessId === args.where?.businessId);
        const search = args.where?.name?.contains.toLowerCase();
        if (search) {
          rows = rows.filter((item) => item.name.toLowerCase().includes(search));
        }
        rows = [...rows].sort((a, b) => a.name.localeCompare(b.name) || a.id.localeCompare(b.id));
        if (args.cursor) {
          const index = rows.findIndex((item) => item.id === args.cursor?.id);
          rows = index === -1 ? [] : rows.slice(index + (args.skip ?? 1));
        }
        return rows.slice(0, args.take).map((item) => ({
          ...item,
          balances: state.balances
            .filter(
              (balance) =>
                balance.stockItemId === item.id &&
                balance.outletId === args.include?.balances?.where?.outletId,
            )
            .map((balance) => ({ quantity: balance.quantity, version: balance.version })),
        }));
      },
      findFirst: async (args: { where: { id: string; businessId: string } }) => {
        const item = state.items.find(
          (row) => row.id === args.where.id && row.businessId === args.where.businessId,
        );
        return item ? { id: item.id, quantityScale: item.quantityScale } : null;
      },
      create: async (args: {
        data: {
          businessId: string;
          name: string;
          baseUnit: 'g' | 'ml' | 'each';
          quantityScale: number;
          reorderThreshold: string | Prisma.Decimal;
        };
      }) => {
        const item: ItemRow = {
          id: nextId(),
          businessId: args.data.businessId,
          name: args.data.name,
          baseUnit: args.data.baseUnit,
          quantityScale: args.data.quantityScale,
          reorderThreshold: new Prisma.Decimal(args.data.reorderThreshold),
          archivedAt: null,
          createdAt: new Date('2026-01-02T00:00:00Z'),
          updatedAt: new Date('2026-01-02T00:00:00Z'),
        };
        state.items.push(item);
        return item;
      },
    },
    stockBalance: {
      findUnique: async (args: {
        where: { outletId_stockItemId: { outletId: string; stockItemId: string } };
      }) => {
        const lookup = args.where.outletId_stockItemId;
        return (
          state.balances.find(
            (balance) =>
              balance.outletId === lookup.outletId && balance.stockItemId === lookup.stockItemId,
          ) ?? null
        );
      },
      create: async (args: {
        data: {
          outletId: string;
          stockItemId: string;
          quantity: Prisma.Decimal;
          version: number;
        };
      }) => {
        if (
          state.balances.some(
            (balance) =>
              balance.outletId === args.data.outletId &&
              balance.stockItemId === args.data.stockItemId,
          )
        ) {
          throw uniqueError();
        }
        const balance: BalanceRow = {
          id: nextId(),
          outletId: args.data.outletId,
          stockItemId: args.data.stockItemId,
          quantity: new Prisma.Decimal(args.data.quantity),
          version: args.data.version,
        };
        state.balances.push(balance);
        return balance;
      },
      updateMany: async (args: {
        where: { outletId: string; stockItemId: string; version?: number };
        data: {
          quantity?: Prisma.Decimal | { increment: Prisma.Decimal };
          version: { increment: number };
        };
      }) => {
        const balance = state.balances.find(
          (row) =>
            row.outletId === args.where.outletId &&
            row.stockItemId === args.where.stockItemId &&
            (args.where.version === undefined || row.version === args.where.version),
        );
        if (!balance) {
          return { count: 0 };
        }
        if (args.data.quantity instanceof Prisma.Decimal) {
          balance.quantity = args.data.quantity;
        } else if (args.data.quantity && 'increment' in args.data.quantity) {
          balance.quantity = balance.quantity.plus(args.data.quantity.increment);
        }
        balance.version += args.data.version.increment;
        return { count: 1 };
      },
    },
    stockMovement: {
      create: async (args: {
        data: {
          outletId: string;
          stockItemId: string;
          delta: Prisma.Decimal;
          type: 'OPENING' | 'RECEIPT' | 'ADJUSTMENT';
          actorId: string;
          reason: string;
          sourceId: string;
        };
      }) => {
        const movement: MovementRow = {
          id: nextId(),
          outletId: args.data.outletId,
          stockItemId: args.data.stockItemId,
          delta: new Prisma.Decimal(args.data.delta),
          type: args.data.type,
          actorId: args.data.actorId,
          reason: args.data.reason,
          sourceId: args.data.sourceId,
          createdAt: new Date('2026-01-03T00:00:00Z'),
        };
        state.movements.push(movement);
        return movement;
      },
      findFirst: async (args: {
        where: { outletId: string; stockItemId: string; type?: string };
      }) =>
        state.movements.find(
          (movement) =>
            movement.outletId === args.where.outletId &&
            movement.stockItemId === args.where.stockItemId &&
            (args.where.type === undefined || movement.type === args.where.type),
        ) ?? null,
      findMany: async (args: {
        where: { outletId: string; stockItemId: string };
        take: number;
        cursor?: { id: string };
        skip?: number;
      }) => {
        let rows = state.movements.filter(
          (movement) =>
            movement.outletId === args.where.outletId &&
            movement.stockItemId === args.where.stockItemId,
        );
        rows = [...rows].sort(
          (a, b) => b.createdAt.getTime() - a.createdAt.getTime() || b.id.localeCompare(a.id),
        );
        if (args.cursor) {
          const index = rows.findIndex((movement) => movement.id === args.cursor?.id);
          rows = index === -1 ? [] : rows.slice(index + (args.skip ?? 1));
        }
        return rows.slice(0, args.take);
      },
      aggregate: async (args: { where: { outletId: string; stockItemId: string } }) => {
        const rows = state.movements.filter(
          (movement) =>
            movement.outletId === args.where.outletId &&
            movement.stockItemId === args.where.stockItemId,
        );
        const sum = rows.reduce(
          (total, movement) => total.plus(movement.delta),
          new Prisma.Decimal(0),
        );
        return { _sum: { delta: rows.length === 0 ? null : sum } };
      },
    },
    stockIdempotency: {
      findUnique: async (args: { where: { outletId_key: { outletId: string; key: string } } }) => {
        const lookup = args.where.outletId_key;
        return (
          state.idempotency.find(
            (row) => row.outletId === lookup.outletId && row.key === lookup.key,
          ) ?? null
        );
      },
      create: async (args: {
        data: { outletId: string; key: string; operation: string; requestHash: string };
      }) => {
        if (
          state.idempotency.some(
            (row) => row.outletId === args.data.outletId && row.key === args.data.key,
          )
        ) {
          throw uniqueError();
        }
        const row: IdemRow = {
          id: nextId(),
          outletId: args.data.outletId,
          key: args.data.key,
          operation: args.data.operation,
          requestHash: args.data.requestHash,
          movementId: null,
          responseBody: null,
          createdAt: new Date('2026-01-04T00:00:00Z'),
        };
        state.idempotency.push(row);
        return row;
      },
      update: async (args: {
        where: { id: string };
        data: { movementId: string; responseBody: unknown };
      }) => {
        const row = state.idempotency.find((entry) => entry.id === args.where.id);
        if (!row) {
          throw new Error('idempotency row missing');
        }
        row.movementId = args.data.movementId;
        row.responseBody = args.data.responseBody;
        return row;
      },
    },
    $transaction: async <T>(callback: (tx: unknown) => Promise<T>): Promise<T> => {
      const snapshot: FakeState = {
        items: [...state.items],
        balances: state.balances.map((row) => ({ ...row })),
        movements: [...state.movements],
        idempotency: state.idempotency.map((row) => ({ ...row })),
        sales: [...state.sales],
      };
      try {
        return await callback(client);
      } catch (error) {
        state.items = snapshot.items;
        state.balances = snapshot.balances;
        state.movements = snapshot.movements;
        state.idempotency = snapshot.idempotency;
        throw error;
      }
    },
  };

  return { prisma: client as unknown as PrismaService, state };
}

function createDto(overrides: Partial<StockCreateDto> = {}): StockCreateDto {
  return {
    name: 'Coffee Beans',
    baseUnit: 'g',
    quantityScale: 2,
    reorderThreshold: '5000',
    ...overrides,
  };
}

function changeDto(overrides: Partial<StockChangeDto> = {}): StockChangeDto {
  return {
    stockItemId: ITEM_ID,
    quantity: '10',
    reason: 'Supplier delivery',
    ...overrides,
  };
}

function adjustmentDto(overrides: Partial<StockAdjustmentDto> = {}): StockAdjustmentDto {
  return {
    stockItemId: ITEM_ID,
    delta: '-5',
    reason: 'Stock count correction',
    expectedBalanceVersion: 1,
    ...overrides,
  };
}

function movementSum(state: FakeState, outletId = OUTLET_ID, itemId = ITEM_ID): Prisma.Decimal {
  return state.movements
    .filter((movement) => movement.outletId === outletId && movement.stockItemId === itemId)
    .reduce((total, movement) => total.plus(movement.delta), new Prisma.Decimal(0));
}

function balanceFor(
  state: FakeState,
  outletId = OUTLET_ID,
  itemId = ITEM_ID,
): BalanceRow | undefined {
  return state.balances.find(
    (balance) => balance.outletId === outletId && balance.stockItemId === itemId,
  );
}

test('every stock operation is owner-only per the contract', () => {
  const handlers = [
    StockController.prototype.create,
    StockController.prototype.opening,
    StockController.prototype.receipt,
    StockController.prototype.adjustment,
    StockController.prototype.list,
    StockController.prototype.movements,
  ];

  for (const handler of handlers) {
    assert.deepEqual(Reflect.getMetadata(ROLES_KEY, handler), [Role.OWNER]);
  }
});

test('cross-tenant outlet access returns 404 before any stock read', async () => {
  const { prisma } = fakePrisma({ missingOutlet: true });
  const service = new StockService(prisma);

  await assert.rejects(
    () => service.list(OUTLET_ID, {} as StockListQueryDto, user()),
    (error: unknown) =>
      error instanceof HttpException &&
      error.getStatus() === 404 &&
      (error.getResponse() as { code: string }).code === 'NOT_FOUND',
  );
});

test('creating an item rejects precision beyond quantityScale', async () => {
  const { prisma, state } = fakePrisma();
  const service = new StockService(prisma);

  await assert.rejects(
    () =>
      service.create(OUTLET_ID, createDto({ quantityScale: 1, reorderThreshold: '5.25' }), user()),
    (error: unknown) => error instanceof HttpException && error.getStatus() === 400,
  );
  assert.equal(state.items.length, 2);
});

test('opening balance creates one movement and balance equals the movement sum', async () => {
  const { prisma, state } = fakePrisma();
  const service = new StockService(prisma);

  const movement = await service.recordOpening(
    OUTLET_ID,
    KEY_ONE,
    changeDto({ quantity: '10.5' }),
    user(),
  );

  assert.equal(movement.type, 'OPENING');
  assert.equal(movement.delta, '10.50');
  assert.equal(movement.sourceId, KEY_ONE);
  assert.equal(state.movements.length, 1);
  assert.ok(balanceFor(state)?.quantity.equals(movementSum(state)));
  assert.ok(balanceFor(state)?.quantity.equals(new Prisma.Decimal('10.5')));
});

test('a second opening balance for the same item and outlet is rejected', async () => {
  const { prisma, state } = fakePrisma();
  const service = new StockService(prisma);

  await service.recordOpening(OUTLET_ID, KEY_ONE, changeDto({ quantity: '10' }), user());

  await assert.rejects(
    () => service.recordOpening(OUTLET_ID, KEY_TWO, changeDto({ quantity: '20' }), user()),
    (error: unknown) =>
      error instanceof HttpException &&
      error.getStatus() === 409 &&
      (error.getResponse() as { code: string }).code === 'OPENING_ALREADY_RECORDED',
  );
  assert.equal(state.movements.length, 1);
});

test('replaying an idempotency key returns the original result and one movement', async () => {
  const { prisma, state } = fakePrisma();
  const service = new StockService(prisma);

  const first = await service.recordOpening(
    OUTLET_ID,
    KEY_ONE,
    changeDto({ quantity: '10' }),
    user(),
  );
  const replay = await service.recordOpening(
    OUTLET_ID,
    KEY_ONE,
    changeDto({ quantity: '10' }),
    user(),
  );

  assert.deepEqual(replay, first);
  assert.equal(state.movements.length, 1);
  assert.equal(state.idempotency.length, 1);
});

test('the same idempotency key with a different payload is a conflict', async () => {
  const { prisma, state } = fakePrisma();
  const service = new StockService(prisma);

  await service.recordReceipt(OUTLET_ID, KEY_ONE, changeDto({ quantity: '10' }), user());

  await assert.rejects(
    () => service.recordReceipt(OUTLET_ID, KEY_ONE, changeDto({ quantity: '11' }), user()),
    (error: unknown) =>
      error instanceof HttpException &&
      error.getStatus() === 409 &&
      (error.getResponse() as { code: string }).code === 'IDEMPOTENCY_CONFLICT',
  );
  assert.equal(state.movements.length, 1);
});

test('a negative receipt quantity is rejected without a movement', async () => {
  const { prisma, state } = fakePrisma();
  const service = new StockService(prisma);

  await assert.rejects(
    () => service.recordReceipt(OUTLET_ID, KEY_ONE, changeDto({ quantity: '-5' }), user()),
    (error: unknown) => error instanceof HttpException && error.getStatus() === 400,
  );
  assert.equal(state.movements.length, 0);
  assert.equal(state.balances.length, 0);
});

test('an adjustment with more decimals than quantityScale is rejected', async () => {
  const { prisma, state } = fakePrisma();
  const service = new StockService(prisma);

  await service.recordOpening(OUTLET_ID, KEY_ONE, changeDto({ quantity: '10' }), user());

  await assert.rejects(
    () =>
      service.recordAdjustment(
        OUTLET_ID,
        KEY_TWO,
        adjustmentDto({ delta: '-1.005', expectedBalanceVersion: 1 }),
        user(),
      ),
    (error: unknown) => error instanceof HttpException && error.getStatus() === 400,
  );
  assert.equal(state.movements.length, 1);
});

test('a stale expectedBalanceVersion returns 409 and writes nothing', async () => {
  const { prisma, state } = fakePrisma();
  const service = new StockService(prisma);

  await service.recordOpening(OUTLET_ID, KEY_ONE, changeDto({ quantity: '10' }), user());

  await assert.rejects(
    () =>
      service.recordAdjustment(
        OUTLET_ID,
        KEY_TWO,
        adjustmentDto({ delta: '-1', expectedBalanceVersion: 3 }),
        user(),
      ),
    (error: unknown) =>
      error instanceof HttpException &&
      error.getStatus() === 409 &&
      (error.getResponse() as { code: string }).code === 'VERSION_CONFLICT',
  );
  assert.equal(state.movements.length, 1);
  assert.equal(balanceFor(state)?.version, 1);
});

test('an adjustment below zero is rejected with the balance unchanged', async () => {
  const { prisma, state } = fakePrisma();
  const service = new StockService(prisma);

  await service.recordOpening(OUTLET_ID, KEY_ONE, changeDto({ quantity: '10' }), user());
  const before = balanceFor(state)?.quantity.toString();

  await assert.rejects(
    () =>
      service.recordAdjustment(
        OUTLET_ID,
        KEY_TWO,
        adjustmentDto({ delta: '-10.01', expectedBalanceVersion: 1 }),
        user(),
      ),
    (error: unknown) =>
      error instanceof HttpException &&
      error.getStatus() === 422 &&
      (error.getResponse() as { code: string }).code === 'INSUFFICIENT_STOCK',
  );

  assert.equal(state.movements.length, 1);
  assert.equal(balanceFor(state)?.quantity.toString(), before);
});

test('receipt and negative adjustment keep balance equal to the movement sum', async () => {
  const { prisma, state } = fakePrisma();
  const service = new StockService(prisma);

  await service.recordOpening(OUTLET_ID, KEY_ONE, changeDto({ quantity: '10' }), user());
  await service.recordReceipt(OUTLET_ID, KEY_TWO, changeDto({ quantity: '2.25' }), user());
  await service.recordAdjustment(
    OUTLET_ID,
    '33333333-3333-4333-8333-333333333333',
    adjustmentDto({ delta: '-4.25', expectedBalanceVersion: 2 }),
    user(),
  );

  assert.equal(state.movements.length, 3);
  assert.ok(balanceFor(state)?.quantity.equals(new Prisma.Decimal('8')));
  assert.ok(balanceFor(state)?.quantity.equals(movementSum(state)));
});

test('unknown stock item ids return 404 and write nothing', async () => {
  const { prisma, state } = fakePrisma();
  const service = new StockService(prisma);

  await assert.rejects(
    () =>
      service.recordReceipt(
        OUTLET_ID,
        KEY_ONE,
        changeDto({ stockItemId: '99999999-9999-4999-8999-999999999999' }),
        user(),
      ),
    (error: unknown) => error instanceof HttpException && error.getStatus() === 404,
  );
  assert.equal(state.movements.length, 0);
});

test('movements are listed newest first for an owned item', async () => {
  const { prisma, state } = fakePrisma();
  const service = new StockService(prisma);

  await service.recordOpening(OUTLET_ID, KEY_ONE, changeDto({ quantity: '10' }), user());
  await service.recordReceipt(OUTLET_ID, KEY_TWO, changeDto({ quantity: '5' }), user());
  state.movements[0]!.createdAt = new Date('2026-01-05T00:00:00Z');
  state.movements[1]!.createdAt = new Date('2026-01-06T00:00:00Z');

  const page = await service.listMovements(OUTLET_ID, ITEM_ID, {} as MovementListQueryDto, user());

  assert.equal(page.items.length, 2);
  assert.equal(page.items[0]?.type, 'RECEIPT');
  assert.equal(page.nextCursor, null);
});

test('listing returns quantity and version from the outlet balance', async () => {
  const { prisma } = fakePrisma();
  const service = new StockService(prisma);

  await service.recordOpening(OUTLET_ID, KEY_ONE, changeDto({ quantity: '10.25' }), user());

  const page = await service.list(OUTLET_ID, {} as StockListQueryDto, user());
  const coffee = page.items.find((item) => item.id === ITEM_ID);

  assert.equal(coffee?.quantity, '10.25');
  assert.equal(coffee?.version, 1);
  assert.equal(coffee?.reorderThreshold, '5000.00');
});

test('movement history resolves sale references and degrades when a sale is missing', async () => {
  const { prisma, state } = fakePrisma();
  const service = new StockService(prisma);
  const SALE_ID = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
  const MISSING_SALE_ID = 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb';

  state.sales.push({ id: SALE_ID, reference: 'SALE-42' });
  state.movements.push(
    {
      id: '00000000-0000-4000-8000-000000000301',
      outletId: OUTLET_ID,
      stockItemId: ITEM_ID,
      delta: new Prisma.Decimal('-3'),
      type: 'SALE',
      actorId: '00000000-0000-4000-8000-000000000003',
      reason: `Sale ${SALE_ID}`,
      sourceId: SALE_ID,
      createdAt: new Date('2026-01-07T00:00:00Z'),
    },
    {
      id: '00000000-0000-4000-8000-000000000302',
      outletId: OUTLET_ID,
      stockItemId: ITEM_ID,
      delta: new Prisma.Decimal('3'),
      type: 'REVERSAL',
      actorId: '00000000-0000-4000-8000-000000000003',
      reason: 'Reversal for a sale that is no longer visible',
      sourceId: MISSING_SALE_ID,
      createdAt: new Date('2026-01-08T00:00:00Z'),
    },
    {
      id: '00000000-0000-4000-8000-000000000303',
      outletId: OUTLET_ID,
      stockItemId: ITEM_ID,
      delta: new Prisma.Decimal('5'),
      type: 'RECEIPT',
      actorId: '00000000-0000-4000-8000-000000000003',
      reason: 'Supplier delivery',
      sourceId: KEY_TWO,
      createdAt: new Date('2026-01-09T00:00:00Z'),
    },
  );

  const page = await service.listMovements(OUTLET_ID, ITEM_ID, {} as MovementListQueryDto, user());
  const byType = new Map(page.items.map((movement) => [movement.type, movement]));

  assert.equal(byType.get('SALE')?.sourceReference, 'SALE-42');
  assert.equal(byType.get('REVERSAL')?.sourceReference, null);
  assert.equal(byType.get('RECEIPT')?.sourceReference, null);
  assert.equal(byType.get('SALE')?.sourceId, SALE_ID);
});

test('stock write responses expose a null sourceReference', async () => {
  const { prisma } = fakePrisma();
  const service = new StockService(prisma);

  const movement = await service.recordOpening(
    OUTLET_ID,
    KEY_ONE,
    changeDto({ quantity: '10' }),
    user(),
  );

  assert.equal(movement.sourceReference, null);
});
