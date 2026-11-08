import assert from 'node:assert/strict';
import { test } from 'node:test';
import { HttpException } from '@nestjs/common';
import { Prisma, StockBaseUnit } from '@prisma/client';
import type { AuthenticatedUser } from '../auth/auth.types';
import type { PrismaService } from '../prisma/prisma.service';
import { RecipeService } from './recipe.service';

const BUSINESS_ID = '00000000-0000-4000-8000-000000000001';
const OTHER_BUSINESS_ID = '00000000-0000-4000-8000-000000000010';
const OUTLET_ID = '00000000-0000-4000-8000-000000000002';
const VARIANT_ID = '00000000-0000-4000-8000-000000000040';
const STOCK_G_ID = '00000000-0000-4000-8000-000000000050';
const STOCK_ML_ID = '00000000-0000-4000-8000-000000000051';
const STOCK_EACH_ID = '00000000-0000-4000-8000-000000000052';
const OTHER_STOCK_ID = '00000000-0000-4000-8000-000000000060';
const OWNER_ID = '00000000-0000-4000-8000-000000000003';

function user(businessId = BUSINESS_ID): AuthenticatedUser {
  return {
    id: OWNER_ID,
    businessId,
    email: 'owner@example.test',
    role: 'OWNER' as AuthenticatedUser['role'],
    outletId: OUTLET_ID,
    outletIds: [OUTLET_ID],
    sessionId: 'session-1',
  };
}

interface StockRow {
  id: string;
  businessId: string;
  name: string;
  baseUnit: StockBaseUnit;
  quantityScale: number;
}

interface RecipeLineRow {
  id: string;
  recipeVersionId: string;
  stockItemId: string;
  quantityPerSaleUnit: Prisma.Decimal;
  createdAt: Date;
}

interface RecipeRow {
  id: string;
  businessId: string;
  outletId: string;
  variantId: string;
  version: number;
  effectiveAt: Date;
  createdAt: Date;
  lines: RecipeLineRow[];
}

interface FakeState {
  outlets: { id: string; businessId: string }[];
  variants: { id: string; businessId: string; outletId: string }[];
  stockItems: StockRow[];
  recipes: RecipeRow[];
}

function createFakePrisma(): { prisma: PrismaService; state: FakeState } {
  const state: FakeState = {
    outlets: [{ id: OUTLET_ID, businessId: BUSINESS_ID }],
    variants: [{ id: VARIANT_ID, businessId: BUSINESS_ID, outletId: OUTLET_ID }],
    stockItems: [
      { id: STOCK_G_ID, businessId: BUSINESS_ID, name: 'Beans', baseUnit: 'g', quantityScale: 0 },
      { id: STOCK_ML_ID, businessId: BUSINESS_ID, name: 'Milk', baseUnit: 'ml', quantityScale: 3 },
      {
        id: STOCK_EACH_ID,
        businessId: BUSINESS_ID,
        name: 'Cup',
        baseUnit: 'each',
        quantityScale: 0,
      },
      {
        id: OTHER_STOCK_ID,
        businessId: OTHER_BUSINESS_ID,
        name: 'Foreign',
        baseUnit: 'g',
        quantityScale: 0,
      },
    ],
    recipes: [],
  };

  let sequence = 0;
  const nextId = (): string =>
    `00000000-0000-4000-8000-${String(700 + sequence++).padStart(12, '0')}`;
  const now = new Date('2026-01-01T00:00:00.000Z');

  function withLines(recipe: RecipeRow) {
    return {
      id: recipe.id,
      variantId: recipe.variantId,
      version: recipe.version,
      lines: recipe.lines
        .map((line) => ({
          stockItemId: line.stockItemId,
          quantityPerSaleUnit: new Prisma.Decimal(line.quantityPerSaleUnit.toString()),
          stockItem: {
            quantityScale:
              state.stockItems.find((item) => item.id === line.stockItemId)?.quantityScale ?? 6,
          },
        }))
        .sort((a, b) => a.stockItemId.localeCompare(b.stockItemId)),
    };
  }

  const client = {
    outlet: {
      findFirst: async (args: { where: { id: string; businessId: string } }) =>
        state.outlets.find(
          (outlet) => outlet.id === args.where.id && outlet.businessId === args.where.businessId,
        ) ?? null,
    },
    menuVariant: {
      findFirst: async (args: {
        where: {
          id: string;
          menuItem: { businessId: string };
          outletMenus: { some: { outletId: string } };
        };
      }) =>
        state.variants.find(
          (variant) =>
            variant.id === args.where.id &&
            variant.businessId === args.where.menuItem.businessId &&
            variant.outletId === args.where.outletMenus.some.outletId,
        ) ?? null,
    },
    stockItem: {
      findMany: async (args: { where: { id: { in: string[] }; businessId: string } }) =>
        state.stockItems.filter(
          (item) => args.where.id.in.includes(item.id) && item.businessId === args.where.businessId,
        ),
    },
    recipeVersion: {
      findFirst: async (args: {
        where: { outletId: string; variantId: string; businessId: string };
        orderBy: { version: 'desc' };
      }) => {
        const matches = state.recipes
          .filter(
            (recipe) =>
              recipe.outletId === args.where.outletId &&
              recipe.variantId === args.where.variantId &&
              recipe.businessId === args.where.businessId,
          )
          .sort((a, b) => b.version - a.version);

        return matches[0] ? withLines(matches[0]) : null;
      },
      create: async (args: {
        data: {
          businessId: string;
          outletId: string;
          variantId: string;
          version: number;
          lines: {
            create: { stockItemId: string; quantityPerSaleUnit: Prisma.Decimal }[];
          };
        };
      }) => {
        const id = nextId();
        const recipe: RecipeRow = {
          id,
          businessId: args.data.businessId,
          outletId: args.data.outletId,
          variantId: args.data.variantId,
          version: args.data.version,
          effectiveAt: now,
          createdAt: now,
          lines: args.data.lines.create.map((line) => ({
            id: nextId(),
            recipeVersionId: id,
            stockItemId: line.stockItemId,
            quantityPerSaleUnit: new Prisma.Decimal(line.quantityPerSaleUnit.toString()),
            createdAt: now,
          })),
        };
        state.recipes.push(recipe);
        return withLines(recipe);
      },
    },
  };

  const prisma = {
    ...client,
    $transaction: async <T>(operation: (tx: typeof client) => Promise<T>): Promise<T> =>
      operation(client),
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

test('publishing version 2 keeps version 1 immutable and stale expectedVersion returns 409', async () => {
  const { prisma, state } = createFakePrisma();
  const service = new RecipeService(prisma);

  const v1 = await service.publish(
    OUTLET_ID,
    VARIANT_ID,
    {
      expectedVersion: 0,
      lines: [
        { stockItemId: STOCK_G_ID, quantityPerSaleUnit: '150' },
        { stockItemId: STOCK_ML_ID, quantityPerSaleUnit: '1.25' },
      ],
    },
    user(),
  );

  assert.equal(v1.version, 1);
  assert.deepEqual(v1.lines, [
    { stockItemId: STOCK_G_ID, quantityPerSaleUnit: '150' },
    { stockItemId: STOCK_ML_ID, quantityPerSaleUnit: '1.250' },
  ]);

  const read = await service.get(OUTLET_ID, VARIANT_ID, user());
  assert.equal(read.version, 1);
  assert.equal(state.recipes.length, 1);

  const v2 = await service.publish(
    OUTLET_ID,
    VARIANT_ID,
    { expectedVersion: 1, lines: [{ stockItemId: STOCK_EACH_ID, quantityPerSaleUnit: '1' }] },
    user(),
  );

  assert.equal(v2.version, 2);
  assert.equal((await service.get(OUTLET_ID, VARIANT_ID, user())).version, 2);
  assert.equal(state.recipes[0]?.version, 1);
  assert.equal(state.recipes[0]?.lines.length, 2);

  await assert.rejects(
    () =>
      service.publish(
        OUTLET_ID,
        VARIANT_ID,
        { expectedVersion: 1, lines: [{ stockItemId: STOCK_EACH_ID, quantityPerSaleUnit: '2' }] },
        user(),
      ),
    (error: unknown) => statusOf(error) === 409 && codeOf(error) === 'VERSION_CONFLICT',
  );

  assert.equal(state.recipes.length, 2);
});

test('recipe validation rejects zero, extra precision, duplicates and foreign stock items', async () => {
  const { prisma, state } = createFakePrisma();
  const service = new RecipeService(prisma);

  await assert.rejects(
    () =>
      service.publish(
        OUTLET_ID,
        VARIANT_ID,
        { expectedVersion: 0, lines: [{ stockItemId: STOCK_G_ID, quantityPerSaleUnit: '0' }] },
        user(),
      ),
    (error: unknown) => statusOf(error) === 400 && codeOf(error) === 'VALIDATION_ERROR',
  );

  await assert.rejects(
    () =>
      service.publish(
        OUTLET_ID,
        VARIANT_ID,
        {
          expectedVersion: 0,
          lines: [{ stockItemId: STOCK_G_ID, quantityPerSaleUnit: '1.5' }],
        },
        user(),
      ),
    (error: unknown) => statusOf(error) === 400 && codeOf(error) === 'VALIDATION_ERROR',
  );

  await assert.rejects(
    () =>
      service.publish(
        OUTLET_ID,
        VARIANT_ID,
        {
          expectedVersion: 0,
          lines: [
            { stockItemId: STOCK_G_ID, quantityPerSaleUnit: '10' },
            { stockItemId: STOCK_G_ID, quantityPerSaleUnit: '20' },
          ],
        },
        user(),
      ),
    (error: unknown) => statusOf(error) === 400 && codeOf(error) === 'VALIDATION_ERROR',
  );

  await assert.rejects(
    () =>
      service.publish(
        OUTLET_ID,
        VARIANT_ID,
        {
          expectedVersion: 0,
          lines: [{ stockItemId: OTHER_STOCK_ID, quantityPerSaleUnit: '10' }],
        },
        user(),
      ),
    (error: unknown) => statusOf(error) === 404 && codeOf(error) === 'NOT_FOUND',
  );

  assert.equal(state.recipes.length, 0);
});

test('reads return 404 before a recipe is published and for another business', async () => {
  const { prisma } = createFakePrisma();
  const service = new RecipeService(prisma);

  await assert.rejects(
    () => service.get(OUTLET_ID, VARIANT_ID, user()),
    (error: unknown) => statusOf(error) === 404 && codeOf(error) === 'NOT_FOUND',
  );

  await assert.rejects(
    () => service.get(OUTLET_ID, VARIANT_ID, user(OTHER_BUSINESS_ID)),
    (error: unknown) => statusOf(error) === 404 && codeOf(error) === 'NOT_FOUND',
  );
});
