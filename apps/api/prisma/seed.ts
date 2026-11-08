import 'dotenv/config';
import { PrismaClient, Role } from '@prisma/client';
import argon2 from 'argon2';

const prisma = new PrismaClient();

// Synthetic demo data only. Never reuse these credentials outside local development.
const SEED_PASSWORD = process.env.SEED_PASSWORD ?? 'modern-pos-demo-password';

// Fixed IDs keep the seed deterministic and re-runnable.
const BUSINESS_ID = '00000000-0000-4000-8000-000000000001';
const OUTLET_MAIN_ID = '00000000-0000-4000-8000-000000000002';
const OWNER_MAIN_ID = '00000000-0000-4000-8000-000000000003';
const CASHIER_MAIN_ID = '00000000-0000-4000-8000-000000000004';
const OUTLET_SECOND_ID = '00000000-0000-4000-8000-000000000005';
const OWNER_SECOND_ID = '00000000-0000-4000-8000-000000000006';
const CASHIER_SECOND_ID = '00000000-0000-4000-8000-000000000007';

const CATEGORY_BEVERAGES_ID = '00000000-0000-4000-8000-000000000020';
const CATEGORY_FOOD_ID = '00000000-0000-4000-8000-000000000021';

const MENU_ICED_COFFEE_ID = '00000000-0000-4000-8000-000000000030';
const MENU_CHICKEN_RICE_ID = '00000000-0000-4000-8000-000000000031';

const VARIANT_ICED_COFFEE_REGULAR_ID = '00000000-0000-4000-8000-000000000040';
const VARIANT_ICED_COFFEE_LARGE_ID = '00000000-0000-4000-8000-000000000041';
const VARIANT_CHICKEN_RICE_ID = '00000000-0000-4000-8000-000000000042';

const OTHER_BUSINESS_ID = '00000000-0000-4000-8000-000000000010';
const OTHER_OUTLET_ID = '00000000-0000-4000-8000-000000000011';
const OTHER_OWNER_ID = '00000000-0000-4000-8000-000000000012';
const OTHER_CASHIER_ID = '00000000-0000-4000-8000-000000000013';

const SEED_ORDER_ID = '00000000-0000-4000-8000-000000000090';
const SEED_ORDER_DEVICE_ID = '00000000-0000-4000-8000-000000000091';
const SEED_ORDER_KEY = '00000000-0000-4000-8000-000000000092';
const SEED_ORDER_LINE_A_ID = '00000000-0000-4000-8000-000000000093';
const SEED_ORDER_LINE_B_ID = '00000000-0000-4000-8000-000000000094';
const SEED_QUOTE_ID = '00000000-0000-4000-8000-000000000095';
const SEED_SALE_ID = '00000000-0000-4000-8000-000000000096';
const SEED_SALE_LINE_A_ID = '00000000-0000-4000-8000-000000000097';
const SEED_SALE_LINE_B_ID = '00000000-0000-4000-8000-000000000098';
const SEED_PAYMENT_ID = '00000000-0000-4000-8000-000000000099';
const SEED_CHECKOUT_ID = '00000000-0000-4000-8000-00000000009a';
const SEED_FINALIZE_KEY = '00000000-0000-4000-8000-00000000009b';
const SEED2_ORDER_ID = '00000000-0000-4000-8000-0000000000a0';
const SEED2_ORDER_DEVICE_ID = '00000000-0000-4000-8000-0000000000a1';
const SEED2_ORDER_KEY = '00000000-0000-4000-8000-0000000000a2';
const SEED2_ORDER_LINE_A_ID = '00000000-0000-4000-8000-0000000000a3';
const SEED2_ORDER_LINE_B_ID = '00000000-0000-4000-8000-0000000000a4';
const SEED2_QUOTE_ID = '00000000-0000-4000-8000-0000000000a5';
const SEED2_SALE_ID = '00000000-0000-4000-8000-0000000000a6';
const SEED2_SALE_LINE_A_ID = '00000000-0000-4000-8000-0000000000a7';
const SEED2_SALE_LINE_B_ID = '00000000-0000-4000-8000-0000000000a8';
const SEED2_PAYMENT_ID = '00000000-0000-4000-8000-0000000000a9';
const SEED2_CHECKOUT_ID = '00000000-0000-4000-8000-0000000000aa';
const SEED2_FINALIZE_KEY = '00000000-0000-4000-8000-0000000000ab';
const SEED_COMPLETED_AT = new Date('2026-01-01T10:00:00.000Z');

const STOCK_COFFEE_ID = '00000000-0000-4000-8000-000000000050';
const STOCK_MILK_ID = '00000000-0000-4000-8000-000000000051';
const STOCK_CUPS_ID = '00000000-0000-4000-8000-000000000052';

const STOCK_ITEMS = [
  {
    id: STOCK_COFFEE_ID,
    name: 'Coffee Beans',
    baseUnit: 'g' as const,
    quantityScale: 0,
    reorderThreshold: '5000',
    opening: '10000',
  },
  {
    id: STOCK_MILK_ID,
    name: 'Fresh Milk',
    baseUnit: 'ml' as const,
    quantityScale: 0,
    reorderThreshold: '4000',
    opening: '12000',
  },
  {
    id: STOCK_CUPS_ID,
    name: 'Paper Cups',
    baseUnit: 'each' as const,
    quantityScale: 0,
    reorderThreshold: '100',
    opening: '500',
  },
];

// Deterministic opening movements and references keep the seed repeatable.
const STOCK_OPENING = STOCK_ITEMS.map((item, index) => ({
  mainMovementId: `00000000-0000-4000-8000-00000000006${index}`,
  secondMovementId: `00000000-0000-4000-8000-00000000007${index}`,
  sourceId: `00000000-0000-4000-8000-00000000008${index}`,
  stockItemId: item.id,
  quantity: item.opening,
}));

const outletDefaults = {
  currency: 'IDR',
  currencyExponent: 0,
  receiptAddress: 'Jl. Example No. 1, Jakarta',
  receiptHeader: 'Modern POS Demo',
  receiptFooter: 'Thank you for your visit',
  taxBps: 0,
  serviceBps: 0,
  pricingMode: 'EXCLUSIVE',
  version: 1,
};

async function main(): Promise<void> {
  const passwordHash = await argon2.hash(SEED_PASSWORD, {
    type: argon2.argon2id,
  });

  await prisma.business.upsert({
    where: { id: BUSINESS_ID },
    update: { name: 'Modern POS Demo' },
    create: { id: BUSINESS_ID, name: 'Modern POS Demo' },
  });

  await prisma.business.upsert({
    where: { id: OTHER_BUSINESS_ID },
    update: { name: 'Other Tenant Demo' },
    create: { id: OTHER_BUSINESS_ID, name: 'Other Tenant Demo' },
  });

  const outlets = [
    {
      id: OUTLET_MAIN_ID,
      businessId: BUSINESS_ID,
      name: 'Main Outlet',
    },
    {
      id: OUTLET_SECOND_ID,
      businessId: BUSINESS_ID,
      name: 'Second Outlet',
    },
    {
      id: OTHER_OUTLET_ID,
      businessId: OTHER_BUSINESS_ID,
      name: 'Other Tenant Outlet',
    },
  ];

  for (const outlet of outlets) {
    await prisma.outlet.upsert({
      where: { id: outlet.id },
      update: {
        businessId: outlet.businessId,
        name: outlet.name,
        timezone: 'Asia/Jakarta',
        ...outletDefaults,
      },
      create: {
        id: outlet.id,
        businessId: outlet.businessId,
        name: outlet.name,
        timezone: 'Asia/Jakarta',
        ...outletDefaults,
      },
    });
  }

  const users = [
    {
      id: OWNER_MAIN_ID,
      businessId: BUSINESS_ID,
      outletId: OUTLET_MAIN_ID,
      email: 'owner@example.test',
      name: 'Demo Owner',
      role: Role.OWNER,
    },
    {
      id: CASHIER_MAIN_ID,
      businessId: BUSINESS_ID,
      outletId: OUTLET_MAIN_ID,
      email: 'cashier@example.test',
      name: 'Demo Cashier',
      role: Role.CASHIER,
    },
    {
      id: OWNER_SECOND_ID,
      businessId: BUSINESS_ID,
      outletId: OUTLET_SECOND_ID,
      email: 'owner.second@example.test',
      name: 'Second Outlet Owner',
      role: Role.OWNER,
    },
    {
      id: CASHIER_SECOND_ID,
      businessId: BUSINESS_ID,
      outletId: OUTLET_SECOND_ID,
      email: 'cashier.second@example.test',
      name: 'Second Outlet Cashier',
      role: Role.CASHIER,
    },
    {
      id: OTHER_OWNER_ID,
      businessId: OTHER_BUSINESS_ID,
      outletId: OTHER_OUTLET_ID,
      email: 'owner.other@example.test',
      name: 'Other Tenant Owner',
      role: Role.OWNER,
    },
    {
      id: OTHER_CASHIER_ID,
      businessId: OTHER_BUSINESS_ID,
      outletId: OTHER_OUTLET_ID,
      email: 'cashier.other@example.test',
      name: 'Other Tenant Cashier',
      role: Role.CASHIER,
    },
  ];

  for (const user of users) {
    await prisma.user.upsert({
      where: { id: user.id },
      update: {
        businessId: user.businessId,
        outletId: user.outletId,
        email: user.email,
        name: user.name,
        role: user.role,
        passwordHash,
        active: true,
      },
      create: {
        ...user,
        passwordHash,
        active: true,
      },
    });
  }

  const categories = [
    { id: CATEGORY_BEVERAGES_ID, name: 'Beverages', sortOrder: 10 },
    { id: CATEGORY_FOOD_ID, name: 'Food', sortOrder: 20 },
  ];

  for (const category of categories) {
    await prisma.category.upsert({
      where: { id: category.id },
      update: {
        businessId: BUSINESS_ID,
        name: category.name,
        sortOrder: category.sortOrder,
        archivedAt: null,
      },
      create: {
        id: category.id,
        businessId: BUSINESS_ID,
        name: category.name,
        sortOrder: category.sortOrder,
      },
    });
  }

  const menuItems = [
    {
      id: MENU_ICED_COFFEE_ID,
      categoryId: CATEGORY_BEVERAGES_ID,
      name: 'Iced Coffee',
      description: 'Brewed coffee served over ice.',
    },
    {
      id: MENU_CHICKEN_RICE_ID,
      categoryId: CATEGORY_FOOD_ID,
      name: 'Chicken Rice',
      description: 'Steamed rice with roasted chicken.',
    },
  ];

  for (const item of menuItems) {
    await prisma.menuItem.upsert({
      where: { id: item.id },
      update: {
        businessId: BUSINESS_ID,
        categoryId: item.categoryId,
        name: item.name,
        description: item.description,
        revision: 1,
        archivedAt: null,
      },
      create: {
        id: item.id,
        businessId: BUSINESS_ID,
        categoryId: item.categoryId,
        name: item.name,
        description: item.description,
      },
    });
  }

  const variants = [
    {
      id: VARIANT_ICED_COFFEE_REGULAR_ID,
      menuItemId: MENU_ICED_COFFEE_ID,
      name: 'Regular',
      priceMinor: 18000n,
      stockPolicy: 'UNTRACKED' as const,
    },
    {
      id: VARIANT_ICED_COFFEE_LARGE_ID,
      menuItemId: MENU_ICED_COFFEE_ID,
      name: 'Large',
      priceMinor: 22000n,
      stockPolicy: 'UNTRACKED' as const,
    },
    {
      id: VARIANT_CHICKEN_RICE_ID,
      menuItemId: MENU_CHICKEN_RICE_ID,
      name: 'Default',
      priceMinor: 35000n,
      stockPolicy: 'TRACKED' as const,
    },
  ];

  for (const variant of variants) {
    await prisma.menuVariant.upsert({
      where: { id: variant.id },
      update: {
        menuItemId: variant.menuItemId,
        name: variant.name,
        priceMinor: variant.priceMinor,
        active: true,
        stockPolicy: variant.stockPolicy,
        revision: 1,
      },
      create: {
        id: variant.id,
        menuItemId: variant.menuItemId,
        name: variant.name,
        priceMinor: variant.priceMinor,
        stockPolicy: variant.stockPolicy,
      },
    });
  }

  for (const outletId of [OUTLET_MAIN_ID, OUTLET_SECOND_ID]) {
    for (const variant of variants) {
      await prisma.outletMenu.upsert({
        where: { outletId_variantId: { outletId, variantId: variant.id } },
        update: { enabled: true },
        create: { outletId, variantId: variant.id, enabled: true },
      });
    }
  }

  for (const item of STOCK_ITEMS) {
    await prisma.stockItem.upsert({
      where: { id: item.id },
      update: {
        businessId: BUSINESS_ID,
        name: item.name,
        baseUnit: item.baseUnit,
        quantityScale: item.quantityScale,
        reorderThreshold: item.reorderThreshold,
        archivedAt: null,
      },
      create: {
        id: item.id,
        businessId: BUSINESS_ID,
        name: item.name,
        baseUnit: item.baseUnit,
        quantityScale: item.quantityScale,
        reorderThreshold: item.reorderThreshold,
      },
    });
  }

  for (const opening of STOCK_OPENING) {
    for (const outlet of [
      { id: OUTLET_MAIN_ID, movementId: opening.mainMovementId },
      { id: OUTLET_SECOND_ID, movementId: opening.secondMovementId },
    ]) {
      const existing = await prisma.stockMovement.findUnique({
        where: { id: outlet.movementId },
        select: { id: true },
      });

      if (!existing) {
        await prisma.stockMovement.create({
          data: {
            id: outlet.movementId,
            outletId: outlet.id,
            stockItemId: opening.stockItemId,
            delta: opening.quantity,
            type: 'OPENING',
            actorId: OWNER_MAIN_ID,
            reason: 'Synthetic opening balance',
            sourceId: opening.sourceId,
          },
        });
      }

      const summed = await prisma.stockMovement.aggregate({
        where: { outletId: outlet.id, stockItemId: opening.stockItemId },
        _sum: { delta: true },
      });
      const quantity = summed._sum.delta ?? 0;

      await prisma.stockBalance.upsert({
        where: {
          outletId_stockItemId: { outletId: outlet.id, stockItemId: opening.stockItemId },
        },
        update: { quantity },
        create: {
          outletId: outlet.id,
          stockItemId: opening.stockItemId,
          quantity,
        },
      });
    }
  }

  // One deterministic completed sale per demo outlet proves receipt snapshots,
  // checkout recovery and cashier/owner sale list scoping without real data.
  for (const outletId of [OUTLET_MAIN_ID, OUTLET_SECOND_ID]) {
    const isMain = outletId === OUTLET_MAIN_ID;
    const suffix = isMain ? 'main' : 'second';
    const ids = isMain
      ? {
          order: SEED_ORDER_ID,
          device: SEED_ORDER_DEVICE_ID,
          orderKey: SEED_ORDER_KEY,
          orderLineA: SEED_ORDER_LINE_A_ID,
          orderLineB: SEED_ORDER_LINE_B_ID,
          quote: SEED_QUOTE_ID,
          sale: SEED_SALE_ID,
          saleLineA: SEED_SALE_LINE_A_ID,
          saleLineB: SEED_SALE_LINE_B_ID,
          payment: SEED_PAYMENT_ID,
          checkout: SEED_CHECKOUT_ID,
          finalizeKey: SEED_FINALIZE_KEY,
          cashierId: CASHIER_MAIN_ID,
        }
      : {
          order: SEED2_ORDER_ID,
          device: SEED2_ORDER_DEVICE_ID,
          orderKey: SEED2_ORDER_KEY,
          orderLineA: SEED2_ORDER_LINE_A_ID,
          orderLineB: SEED2_ORDER_LINE_B_ID,
          quote: SEED2_QUOTE_ID,
          sale: SEED2_SALE_ID,
          saleLineA: SEED2_SALE_LINE_A_ID,
          saleLineB: SEED2_SALE_LINE_B_ID,
          payment: SEED2_PAYMENT_ID,
          checkout: SEED2_CHECKOUT_ID,
          finalizeKey: SEED2_FINALIZE_KEY,
          cashierId: CASHIER_SECOND_ID,
        };
    const quoteLines = [
      {
        variantId: VARIANT_ICED_COFFEE_REGULAR_ID,
        name: 'Iced Coffee',
        variantName: 'Regular',
        quantity: 2,
        unitPriceMinor: 18000,
        lineSubtotalMinor: 36000,
        recipeVersion: null,
      },
      {
        variantId: VARIANT_CHICKEN_RICE_ID,
        name: 'Chicken Rice',
        variantName: 'Default',
        quantity: 1,
        unitPriceMinor: 35000,
        lineSubtotalMinor: 35000,
        recipeVersion: null,
      },
    ];

    await prisma.order.upsert({
      where: { id: ids.order },
      update: {
        businessId: BUSINESS_ID,
        outletId,
        cashierId: ids.cashierId,
        deviceId: ids.device,
        state: 'COMPLETED',
        version: 2,
        idempotencyKey: ids.orderKey,
        requestHash: `seed-order-${suffix}`,
      },
      create: {
        id: ids.order,
        businessId: BUSINESS_ID,
        outletId,
        cashierId: ids.cashierId,
        deviceId: ids.device,
        state: 'COMPLETED',
        version: 2,
        idempotencyKey: ids.orderKey,
        requestHash: `seed-order-${suffix}`,
      },
    });

    for (const [lineId, line] of [
      [ids.orderLineA, quoteLines[0]!],
      [ids.orderLineB, quoteLines[1]!],
    ] as const) {
      await prisma.orderLine.upsert({
        where: { id: lineId },
        update: { orderId: ids.order, variantId: line.variantId, quantity: line.quantity },
        create: {
          id: lineId,
          orderId: ids.order,
          variantId: line.variantId,
          quantity: line.quantity,
        },
      });
    }

    await prisma.quote.upsert({
      where: { id: ids.quote },
      update: {
        businessId: BUSINESS_ID,
        outletId,
        orderId: ids.order,
        orderVersion: 1,
        settingsVersion: 1,
        currency: 'IDR',
        currencyExponent: 0,
        expiresAt: SEED_COMPLETED_AT,
        subtotalMinor: 71000n,
        serviceMinor: 0n,
        taxMinor: 0n,
        totalMinor: 71000n,
        lines: quoteLines,
      },
      create: {
        id: ids.quote,
        businessId: BUSINESS_ID,
        outletId,
        orderId: ids.order,
        orderVersion: 1,
        settingsVersion: 1,
        currency: 'IDR',
        currencyExponent: 0,
        expiresAt: SEED_COMPLETED_AT,
        subtotalMinor: 71000n,
        serviceMinor: 0n,
        taxMinor: 0n,
        totalMinor: 71000n,
        lines: quoteLines,
      },
    });

    await prisma.sale.upsert({
      where: { id: ids.sale },
      update: {
        businessId: BUSINESS_ID,
        outletId,
        orderId: ids.order,
        cashierId: ids.cashierId,
        deviceId: ids.device,
        reference: `SALE-SEED-${suffix.toUpperCase()}`,
        state: 'COMPLETED',
        currency: 'IDR',
        currencyExponent: 0,
        timezone: 'Asia/Jakarta',
        subtotalMinor: 71000n,
        serviceMinor: 0n,
        taxMinor: 0n,
        totalMinor: 71000n,
        completedAt: SEED_COMPLETED_AT,
      },
      create: {
        id: ids.sale,
        businessId: BUSINESS_ID,
        outletId,
        orderId: ids.order,
        cashierId: ids.cashierId,
        deviceId: ids.device,
        reference: `SALE-SEED-${suffix.toUpperCase()}`,
        state: 'COMPLETED',
        currency: 'IDR',
        currencyExponent: 0,
        timezone: 'Asia/Jakarta',
        subtotalMinor: 71000n,
        serviceMinor: 0n,
        taxMinor: 0n,
        totalMinor: 71000n,
        completedAt: SEED_COMPLETED_AT,
      },
    });

    for (const [lineId, line] of [
      [ids.saleLineA, quoteLines[0]!],
      [ids.saleLineB, quoteLines[1]!],
    ] as const) {
      await prisma.saleLine.upsert({
        where: { id: lineId },
        update: {
          saleId: ids.sale,
          variantId: line.variantId,
          name: line.name,
          variantName: line.variantName,
          quantity: line.quantity,
          unitPriceMinor: BigInt(line.unitPriceMinor),
          lineSubtotalMinor: BigInt(line.lineSubtotalMinor),
          recipeVersion: null,
        },
        create: {
          id: lineId,
          saleId: ids.sale,
          variantId: line.variantId,
          name: line.name,
          variantName: line.variantName,
          quantity: line.quantity,
          unitPriceMinor: BigInt(line.unitPriceMinor),
          lineSubtotalMinor: BigInt(line.lineSubtotalMinor),
          recipeVersion: null,
        },
      });
    }

    await prisma.paymentRecord.upsert({
      where: { id: ids.payment },
      update: {
        saleId: ids.sale,
        kind: 'CASH',
        status: 'RECORDED',
        amountMinor: 71000n,
        tenderedMinor: 100000n,
        changeMinor: 29000n,
        reference: null,
      },
      create: {
        id: ids.payment,
        saleId: ids.sale,
        kind: 'CASH',
        status: 'RECORDED',
        amountMinor: 71000n,
        tenderedMinor: 100000n,
        changeMinor: 29000n,
        reference: null,
      },
    });

    await prisma.checkoutRequest.upsert({
      where: {
        outletId_deviceId_idempotencyKey: {
          outletId,
          deviceId: ids.device,
          idempotencyKey: ids.finalizeKey,
        },
      },
      update: {
        businessId: BUSINESS_ID,
        requestHash: `seed-finalize-${suffix}`,
        saleId: ids.sale,
      },
      create: {
        id: ids.checkout,
        businessId: BUSINESS_ID,
        outletId,
        deviceId: ids.device,
        idempotencyKey: ids.finalizeKey,
        requestHash: `seed-finalize-${suffix}`,
        saleId: ids.sale,
      },
    });
  }

  console.log(
    `Synthetic demo data seeded: ${users.length} users across ${outlets.length} outlets and 2 businesses, ${categories.length} categories, ${menuItems.length} menu items, ${variants.length} variants, ${STOCK_ITEMS.length} stock items and 2 completed demo sales.`,
  );
}

main()
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
