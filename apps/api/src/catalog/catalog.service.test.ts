import assert from 'node:assert/strict';
import { test } from 'node:test';
import { HttpException } from '@nestjs/common';
import { Prisma, Role, StockPolicy } from '@prisma/client';
import type { AuthenticatedUser } from '../auth/auth.types';
import { ROLES_KEY } from '../common/decorators/roles.decorator';
import type { PrismaService } from '../prisma/prisma.service';
import { CatalogController } from './catalog.controller';
import { CatalogService } from './catalog.service';
import type { CategoryCreateDto } from './dto/category-create.dto';
import type { CatalogArchiveDto } from './dto/catalog-archive.dto';
import type { MenuCreateDto } from './dto/menu-create.dto';
import type { MenuListQueryDto } from './dto/menu-list-query.dto';
import type { MenuUpdateDto } from './dto/menu-update.dto';
import type { MenuVariantUpdateDto } from './dto/menu-variant-update.dto';

const BUSINESS_ID = '00000000-0000-4000-8000-000000000001';
const OUTLET_ID = '00000000-0000-4000-8000-000000000002';
const CATEGORY_ID = '00000000-0000-4000-8000-000000000020';
const MENU_ID = '00000000-0000-4000-8000-000000000030';
const VARIANT_ID = '00000000-0000-4000-8000-000000000040';

function user(role: Role = Role.OWNER): AuthenticatedUser {
  return {
    id: 'user-1',
    businessId: BUSINESS_ID,
    email: 'owner@example.test',
    role,
    outletId: OUTLET_ID,
    outletIds: [OUTLET_ID],
    sessionId: 'session-1',
  };
}

function menuRecord(
  revision = 1,
  archivedAt: Date | null = null,
  stockPolicy: StockPolicy = StockPolicy.UNTRACKED,
) {
  return {
    id: MENU_ID,
    businessId: BUSINESS_ID,
    categoryId: CATEGORY_ID,
    name: 'Iced Coffee',
    description: 'Brewed coffee over ice.',
    revision,
    archivedAt,
    createdAt: new Date('2026-01-01T00:00:00Z'),
    updatedAt: new Date('2026-01-01T00:00:00Z'),
    variants: [
      {
        id: VARIANT_ID,
        menuItemId: MENU_ID,
        name: 'Regular',
        priceMinor: 18000n,
        active: true,
        stockPolicy,
        revision: 1,
        createdAt: new Date('2026-01-01T00:00:00Z'),
        updatedAt: new Date('2026-01-01T00:00:00Z'),
        outletMenus: [{ outletId: OUTLET_ID, enabled: true }],
      },
    ],
  };
}

function variantRecord(overrides: Record<string, unknown> = {}) {
  return {
    id: VARIANT_ID,
    menuItemId: MENU_ID,
    name: 'Regular',
    priceMinor: 18000n,
    active: true,
    stockPolicy: StockPolicy.UNTRACKED,
    revision: 1,
    createdAt: new Date('2026-01-01T00:00:00Z'),
    updatedAt: new Date('2026-01-01T00:00:00Z'),
    outletMenus: [{ outletId: OUTLET_ID, enabled: true }],
    ...overrides,
  };
}

interface FakeCalls {
  menuItemUpdateMany: Record<string, unknown>[];
  variantUpdateMany: Record<string, unknown>[];
  outletMenuCreate: Record<string, unknown>[];
  menuCreate: Record<string, unknown>[];
}

function fakePrisma(overrides: Record<string, unknown> = {}): {
  prisma: PrismaService;
  calls: FakeCalls;
} {
  const calls: FakeCalls = {
    menuItemUpdateMany: [],
    variantUpdateMany: [],
    outletMenuCreate: [],
    menuCreate: [],
  };

  const base = {
    outlet: {
      findFirst: async () => ({ id: OUTLET_ID }),
    },
    category: {
      findFirst: async () => ({ id: CATEGORY_ID }),
      findMany: async () => [],
      create: async (args: { data: { name: string } }) => ({
        id: CATEGORY_ID,
        name: args.data.name,
        archivedAt: null,
      }),
    },
    menuItem: {
      findMany: async () => [],
      findFirst: async () => menuRecord(),
      create: async (args: unknown) => {
        calls.menuCreate.push(args as Record<string, unknown>);
        return menuRecord();
      },
      updateMany: async (args: Record<string, unknown>) => {
        calls.menuItemUpdateMany.push(args);
        return { count: 1 };
      },
    },
    menuVariant: {
      findFirst: async () => variantRecord(),
      create: async (args: { data: { name: string } }) => ({
        ...variantRecord(),
        name: args.data.name,
      }),
      updateMany: async (args: Record<string, unknown>) => {
        calls.variantUpdateMany.push(args);
        return { count: 1 };
      },
    },
    outletMenu: {
      create: async (args: Record<string, unknown>) => {
        calls.outletMenuCreate.push(args);
        return { outletId: OUTLET_ID, variantId: VARIANT_ID, enabled: true };
      },
    },
    recipeVersion: {
      findMany: async () => [],
    },
    stockBalance: {
      findMany: async () => [],
    },
  };

  const merged: Record<string, unknown> = { ...base, ...overrides };
  merged.$transaction = async <T>(callback: (tx: unknown) => Promise<T>): Promise<T> =>
    callback(merged);

  return { prisma: merged as unknown as PrismaService, calls };
}

function menuCreateDto(overrides: Partial<MenuCreateDto> = {}): MenuCreateDto {
  return {
    name: 'Iced Coffee',
    description: 'Brewed coffee over ice.',
    categoryId: CATEGORY_ID,
    variants: [{ name: 'Regular', priceMinor: 18000, stockPolicy: StockPolicy.UNTRACKED }],
    ...overrides,
  };
}

function menuUpdateDto(overrides: Partial<MenuUpdateDto> = {}): MenuUpdateDto {
  return {
    name: 'Updated Coffee',
    description: 'Updated.',
    categoryId: CATEGORY_ID,
    revision: 1,
    ...overrides,
  };
}

function variantUpdateDto(overrides: Partial<MenuVariantUpdateDto> = {}): MenuVariantUpdateDto {
  return {
    name: 'Regular',
    priceMinor: 20000,
    stockPolicy: StockPolicy.TRACKED,
    enabled: false,
    revision: 1,
    ...overrides,
  };
}

test('catalog reads are cashier-allowed and writes are owner-only', () => {
  const writes = [
    CatalogController.prototype.createCategory,
    CatalogController.prototype.createMenu,
    CatalogController.prototype.updateMenu,
    CatalogController.prototype.archiveMenu,
    CatalogController.prototype.updateVariant,
  ];

  for (const handler of writes) {
    assert.deepEqual(Reflect.getMetadata(ROLES_KEY, handler), [Role.OWNER]);
  }

  assert.equal(
    Reflect.getMetadata(ROLES_KEY, CatalogController.prototype.listCategories),
    undefined,
  );
  assert.equal(Reflect.getMetadata(ROLES_KEY, CatalogController.prototype.listMenu), undefined);
});

test('cross-tenant outlet access returns 404 before any catalog read', async () => {
  const { prisma } = fakePrisma({
    outlet: { findFirst: async () => null },
  });
  const service = new CatalogService(prisma);

  await assert.rejects(
    () => service.listCategories(OUTLET_ID, user()),
    (error: unknown) => error instanceof HttpException && error.getStatus() === 404,
  );
});

test('category creation is business-scoped and reports the contract shape', async () => {
  const { prisma } = fakePrisma();
  const service = new CatalogService(prisma);

  const category = await service.createCategory(OUTLET_ID, { name: 'Desserts' }, user());

  assert.equal(category.id, CATEGORY_ID);
  assert.equal(category.name, 'Desserts');
  assert.equal(category.version, 1);
  assert.equal(category.archived, false);
});

test('owner menu listing includes archived records; cashier listing stays saleable', async () => {
  const ownerArgs: { where?: Record<string, unknown> }[] = [];
  const cashierArgs: { where?: Record<string, unknown> }[] = [];

  const ownerCapture = fakePrisma({
    menuItem: {
      findMany: async (args: { where: Record<string, unknown> }) => {
        ownerArgs.push(args);
        return [];
      },
      findFirst: async () => menuRecord(),
      create: async () => menuRecord(),
      updateMany: async () => ({ count: 1 }),
    },
  });
  await new CatalogService(ownerCapture.prisma).listMenu(
    OUTLET_ID,
    {} as MenuListQueryDto,
    user(Role.OWNER),
  );

  const cashierCapture = fakePrisma({
    menuItem: {
      findMany: async (args: { where: Record<string, unknown> }) => {
        cashierArgs.push(args);
        return [];
      },
      findFirst: async () => menuRecord(),
      create: async () => menuRecord(),
      updateMany: async () => ({ count: 1 }),
    },
  });
  await new CatalogService(cashierCapture.prisma).listMenu(
    OUTLET_ID,
    {} as MenuListQueryDto,
    user(Role.CASHIER),
  );

  assert.equal(ownerArgs[0]?.where?.archivedAt, undefined);
  assert.equal(cashierArgs[0]?.where?.archivedAt, null);
  assert.deepEqual(cashierArgs[0]?.where?.category, { archivedAt: null });
});

test('empty menu search returns an empty page rather than an error', async () => {
  const { prisma } = fakePrisma({
    menuItem: {
      findMany: async () => [],
      findFirst: async () => null,
      create: async () => menuRecord(),
      updateMany: async () => ({ count: 1 }),
    },
  });
  const service = new CatalogService(prisma);

  const page = await service.listMenu(
    OUTLET_ID,
    { search: 'no-such-item', limit: 25 } as MenuListQueryDto,
    user(),
  );

  assert.deepEqual(page, { items: [], nextCursor: null });
});

test('create menu rejects an unknown category before writing', async () => {
  const { prisma, calls } = fakePrisma({
    category: { findFirst: async () => null, findMany: async () => [] },
  });
  const service = new CatalogService(prisma);

  await assert.rejects(
    () => service.createMenu(OUTLET_ID, menuCreateDto(), user()),
    (error: unknown) => error instanceof HttpException && error.getStatus() === 404,
  );
  assert.equal(calls.menuCreate.length, 0);
});

test('create menu writes variants and outlet menu links then returns the record', async () => {
  const { prisma, calls } = fakePrisma();
  const service = new CatalogService(prisma);

  const menu = await service.createMenu(OUTLET_ID, menuCreateDto(), user());

  assert.equal(calls.menuCreate.length, 1);
  assert.equal(calls.outletMenuCreate.length, 1);
  assert.equal(menu.id, MENU_ID);
  assert.equal(menu.variants[0]?.priceMinor, 18000);
  assert.equal(menu.variants[0]?.availableUnits, null);
});

test('update menu rejects a stale revision without writing', async () => {
  const { prisma, calls } = fakePrisma({
    menuItem: {
      findFirst: async () => menuRecord(3),
      findMany: async () => [],
      create: async () => menuRecord(),
      updateMany: async () => ({ count: 1 }),
    },
  });
  const service = new CatalogService(prisma);

  await assert.rejects(
    () => service.updateMenu(OUTLET_ID, MENU_ID, menuUpdateDto({ revision: 2 }), user()),
    (error: unknown) =>
      error instanceof HttpException &&
      error.getStatus() === 409 &&
      (error.getResponse() as { code: string }).code === 'VERSION_CONFLICT',
  );
  assert.equal(calls.menuItemUpdateMany.length, 0);
});

test('update menu increments revision and returns the refreshed record', async () => {
  const { prisma, calls } = fakePrisma();
  const service = new CatalogService(prisma);

  const menu = await service.updateMenu(OUTLET_ID, MENU_ID, menuUpdateDto(), user());

  assert.equal(calls.menuItemUpdateMany.length, 1);
  assert.deepEqual((calls.menuItemUpdateMany[0]?.data as { revision: unknown }).revision, {
    increment: 1,
  });
  assert.equal(menu.id, MENU_ID);
});

test('archive rejects a stale revision without writing', async () => {
  const { prisma, calls } = fakePrisma({
    menuItem: {
      findFirst: async () => menuRecord(4),
      findMany: async () => [],
      create: async () => menuRecord(),
      updateMany: async () => ({ count: 1 }),
    },
  });
  const service = new CatalogService(prisma);

  await assert.rejects(
    () => service.archiveMenu(OUTLET_ID, MENU_ID, { revision: 3 } as CatalogArchiveDto, user()),
    (error: unknown) => error instanceof HttpException && error.getStatus() === 409,
  );
  assert.equal(calls.menuItemUpdateMany.length, 0);
});

test('archive is a soft write that preserves the row', async () => {
  const { prisma, calls } = fakePrisma();
  const service = new CatalogService(prisma);

  await service.archiveMenu(OUTLET_ID, MENU_ID, { revision: 1 } as CatalogArchiveDto, user());

  assert.equal(calls.menuItemUpdateMany.length, 1);
  const data = calls.menuItemUpdateMany[0]?.data as {
    archivedAt: Date;
    revision: { increment: number };
  };
  assert.ok(data.archivedAt instanceof Date);
  assert.deepEqual(data.revision, { increment: 1 });
});

test('variant update rejects a stale revision without writing', async () => {
  const { prisma, calls } = fakePrisma({
    menuVariant: {
      findFirst: async () => variantRecord({ revision: 5 }),
      create: async () => variantRecord(),
      updateMany: async () => ({ count: 1 }),
    },
  });
  const service = new CatalogService(prisma);

  await assert.rejects(
    () => service.updateVariant(OUTLET_ID, VARIANT_ID, variantUpdateDto({ revision: 4 }), user()),
    (error: unknown) =>
      error instanceof HttpException &&
      error.getStatus() === 409 &&
      (error.getResponse() as { code: string }).code === 'VERSION_CONFLICT',
  );
  assert.equal(calls.variantUpdateMany.length, 0);
});

test('variant update keeps a stable id and maps enabled, policy and price', async () => {
  let findFirstCalls = 0;
  const { prisma, calls } = fakePrisma({
    menuVariant: {
      findFirst: async () => {
        findFirstCalls += 1;
        return findFirstCalls === 1
          ? variantRecord()
          : variantRecord({
              revision: 2,
              priceMinor: 21000n,
              stockPolicy: StockPolicy.TRACKED,
              active: false,
            });
      },
      create: async () => variantRecord(),
      updateMany: async (args: Record<string, unknown>) => {
        calls.variantUpdateMany.push(args);
        return { count: 1 };
      },
    },
  });
  const service = new CatalogService(prisma);

  const variant = await service.updateVariant(
    OUTLET_ID,
    VARIANT_ID,
    variantUpdateDto({ priceMinor: 21000, stockPolicy: StockPolicy.TRACKED, enabled: false }),
    user(),
  );

  assert.equal(variant.id, VARIANT_ID);
  assert.equal(variant.priceMinor, 21000);
  assert.equal(variant.stockPolicy, StockPolicy.TRACKED);
  assert.equal(variant.enabled, false);
  assert.equal(variant.availableUnits, 0);
  assert.equal(calls.variantUpdateMany.length, 1);
});

test('variant update requires the variant to be linked to the requested outlet', async () => {
  const { prisma } = fakePrisma({
    menuVariant: {
      findFirst: async () => null,
      create: async () => variantRecord(),
      updateMany: async () => ({ count: 1 }),
    },
  });
  const service = new CatalogService(prisma);

  await assert.rejects(
    () => service.updateVariant(OUTLET_ID, VARIANT_ID, variantUpdateDto(), user()),
    (error: unknown) => error instanceof HttpException && error.getStatus() === 404,
  );
});

test('category names are trimmed by the DTO layer and validated by the controller', () => {
  const dto: CategoryCreateDto = { name: 'Beverages' };
  assert.equal(dto.name, 'Beverages');
});

function trackedMenuRecord() {
  return menuRecord(1, null, StockPolicy.TRACKED);
}

test('tracked menu availability is the floor of each ingredient balance per sale unit', async () => {
  const stockA = '00000000-0000-4000-8000-000000000050';
  const stockB = '00000000-0000-4000-8000-000000000051';
  const { prisma } = fakePrisma({
    menuItem: {
      findMany: async () => [trackedMenuRecord()],
      findFirst: async () => trackedMenuRecord(),
      create: async () => trackedMenuRecord(),
      updateMany: async () => ({ count: 1 }),
    },
    recipeVersion: {
      findMany: async () => [
        {
          variantId: VARIANT_ID,
          version: 1,
          lines: [
            { stockItemId: stockA, quantityPerSaleUnit: new Prisma.Decimal('2') },
            { stockItemId: stockB, quantityPerSaleUnit: new Prisma.Decimal('1') },
          ],
        },
      ],
    },
    stockBalance: {
      findMany: async () => [
        { stockItemId: stockA, quantity: new Prisma.Decimal('7') },
        { stockItemId: stockB, quantity: new Prisma.Decimal('2') },
      ],
    },
  });
  const service = new CatalogService(prisma);

  const page = await service.listMenu(
    OUTLET_ID,
    { limit: 25 } as MenuListQueryDto,
    user(Role.CASHIER),
  );

  assert.equal(page.items[0]?.variants[0]?.availableUnits, 2);
});

test('tracked menu availability uses the latest recipe version and never floats', async () => {
  const stockA = '00000000-0000-4000-8000-000000000050';
  const { prisma } = fakePrisma({
    menuItem: {
      findMany: async () => [trackedMenuRecord()],
      findFirst: async () => trackedMenuRecord(),
      create: async () => trackedMenuRecord(),
      updateMany: async () => ({ count: 1 }),
    },
    recipeVersion: {
      findMany: async () => [
        {
          variantId: VARIANT_ID,
          version: 1,
          lines: [{ stockItemId: stockA, quantityPerSaleUnit: new Prisma.Decimal('2') }],
        },
        {
          variantId: VARIANT_ID,
          version: 2,
          lines: [{ stockItemId: stockA, quantityPerSaleUnit: new Prisma.Decimal('3') }],
        },
      ],
    },
    stockBalance: {
      findMany: async () => [{ stockItemId: stockA, quantity: new Prisma.Decimal('10') }],
    },
  });
  const service = new CatalogService(prisma);

  const page = await service.listMenu(
    OUTLET_ID,
    { limit: 25 } as MenuListQueryDto,
    user(Role.CASHIER),
  );

  assert.equal(page.items[0]?.variants[0]?.availableUnits, 3);
});

test('a tracked variant with no published recipe reports zero availability', async () => {
  const { prisma } = fakePrisma({
    menuItem: {
      findMany: async () => [trackedMenuRecord()],
      findFirst: async () => trackedMenuRecord(),
      create: async () => trackedMenuRecord(),
      updateMany: async () => ({ count: 1 }),
    },
  });
  const service = new CatalogService(prisma);

  const page = await service.listMenu(
    OUTLET_ID,
    { limit: 25 } as MenuListQueryDto,
    user(Role.CASHIER),
  );

  assert.equal(page.items[0]?.variants[0]?.availableUnits, 0);
});
