import assert from 'node:assert/strict';
import { test } from 'node:test';
import { CustomerConsentSource, CustomerContactType, Role } from '@prisma/client';
import type { AuthenticatedUser } from '../auth/auth.types';
import type { PrismaService } from '../prisma/prisma.service';
import { CustomersService } from './customers.service';

const BUSINESS_ID = '00000000-0000-4000-8000-000000000001';
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

function fakePrisma(options: {
  existing?: { id: string; anonymizedAt: Date | null } | null;
  expired?: { id: string }[];
  receiptsPurged?: number;
}): PrismaService {
  return {
    outlet: {
      findFirst: async () => ({ id: OUTLET_ID }),
    },
    customer: {
      findUnique: async () => options.existing ?? null,
      findMany: async () => options.expired ?? [],
      create: async (args: { data: { name: string } }) => ({
        id: 'customer-1',
        outletId: OUTLET_ID,
        name: args.data.name,
        email: null,
        phone: null,
        consentAt: new Date('2026-11-13T00:00:00.000Z'),
        consentSource: CustomerConsentSource.STAFF_ENTRY,
        anonymizedAt: null,
        createdAt: new Date('2026-11-13T00:00:00.000Z'),
      }),
      update: async () => ({ id: 'customer-1' }),
    },
    customerRetentionPolicy: {
      findUnique: async () => ({
        customerRetentionDays: 365,
        receiptRetentionDays: 90,
        receiptLinkTtlMinutes: 1440,
        version: 1,
        updatedAt: new Date('2026-11-13T00:00:00.000Z'),
      }),
    },
    digitalReceipt: {
      deleteMany: async () => ({ count: options.receiptsPurged ?? 0 }),
    },
  } as unknown as PrismaService;
}

test('a customer without consent is rejected before any write', async () => {
  const service = new CustomersService(fakePrisma({}));

  await assert.rejects(
    service.create(
      OUTLET_ID,
      {
        name: 'No Consent',
        contact: 'no-consent@example.test',
        contactType: CustomerContactType.EMAIL,
        consent: false,
        consentSource: CustomerConsentSource.STAFF_ENTRY,
      },
      owner(),
    ),
    (error: unknown) =>
      typeof error === 'object' &&
      error !== null &&
      'getStatus' in error &&
      (error as { getStatus: () => number }).getStatus() === 422,
  );
});

test('an expired customer is anonymised and expired receipts removed', async () => {
  const service = new CustomersService(
    fakePrisma({ expired: [{ id: 'customer-old' }], receiptsPurged: 2 }),
  );
  const result = await service.purge(OUTLET_ID, owner());

  assert.equal(result.customersAnonymised, 1);
  assert.equal(result.receiptsPurged, 2);
  assert.equal(result.policy.customerRetentionDays, 365);
});
