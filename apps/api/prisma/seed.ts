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

  console.log(
    `Synthetic demo data seeded: ${users.length} users across ${outlets.length} outlets and 2 businesses, ${categories.length} categories, ${menuItems.length} menu items and ${variants.length} variants.`,
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
