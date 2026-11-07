import 'dotenv/config';
import { PrismaClient, Role } from '@prisma/client';

const prisma = new PrismaClient();

// Fixed IDs keep the seed deterministic and re-runnable.
const BUSINESS_ID = '00000000-0000-4000-8000-000000000001';
const OUTLET_ID = '00000000-0000-4000-8000-000000000002';
const OWNER_ID = '00000000-0000-4000-8000-000000000003';
const CASHIER_ID = '00000000-0000-4000-8000-000000000004';

async function main() {
  await prisma.business.upsert({
    where: { id: BUSINESS_ID },
    update: { name: 'Modern POS Demo' },
    create: { id: BUSINESS_ID, name: 'Modern POS Demo' },
  });

  await prisma.outlet.upsert({
    where: { id: OUTLET_ID },
    update: {
      businessId: BUSINESS_ID,
      name: 'Main Outlet',
      timezone: 'Asia/Jakarta',
    },
    create: {
      id: OUTLET_ID,
      businessId: BUSINESS_ID,
      name: 'Main Outlet',
      timezone: 'Asia/Jakarta',
    },
  });

  await prisma.user.upsert({
    where: { id: OWNER_ID },
    update: {
      businessId: BUSINESS_ID,
      outletId: OUTLET_ID,
      email: 'owner@example.test',
      name: 'Demo Owner',
      role: Role.OWNER,
    },
    create: {
      id: OWNER_ID,
      businessId: BUSINESS_ID,
      outletId: OUTLET_ID,
      email: 'owner@example.test',
      name: 'Demo Owner',
      role: Role.OWNER,
    },
  });

  await prisma.user.upsert({
    where: { id: CASHIER_ID },
    update: {
      businessId: BUSINESS_ID,
      outletId: OUTLET_ID,
      email: 'cashier@example.test',
      name: 'Demo Cashier',
      role: Role.CASHIER,
    },
    create: {
      id: CASHIER_ID,
      businessId: BUSINESS_ID,
      outletId: OUTLET_ID,
      email: 'cashier@example.test',
      name: 'Demo Cashier',
      role: Role.CASHIER,
    },
  });

  console.log('Synthetic demo data seeded (business, outlet, owner, cashier).');
}

main()
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
