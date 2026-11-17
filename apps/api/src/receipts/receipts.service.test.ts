import assert from 'node:assert/strict';
import { test } from 'node:test';
import { Role } from '@prisma/client';
import type { AuthenticatedUser } from '../auth/auth.types';
import type { PrismaService } from '../prisma/prisma.service';
import { ReceiptsService } from './receipts.service';

const BUSINESS_ID = '00000000-0000-4000-8000-000000000001';
const OUTLET_ID = '00000000-0000-4000-8000-000000000002';
const OWNER_ID = '00000000-0000-4000-8000-000000000003';
const SALE_ID = '00000000-0000-4000-8000-0000000000aa';

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

function fakePrisma(overrides: Record<string, unknown>): PrismaService {
  return overrides as unknown as PrismaService;
}

for (const [kind, label] of [
  ['MANUAL_EXTERNAL', 'QRIS / Non-cash'],
  ['CASH', 'CASH'],
  ['ONLINE', 'ONLINE'],
]) {
  test(`digital receipt renders the ${kind} payment label in HTML and text`, async () => {
    const service = new ReceiptsService(
      fakePrisma({
        sale: {
          findFirst: async () => ({
            id: SALE_ID,
            reference: 'SALE-RECEIPT-LABEL',
            currency: 'IDR',
            currencyExponent: 0,
            subtotalMinor: 35000n,
            discountMinor: 0n,
            serviceMinor: 0n,
            taxMinor: 0n,
            totalMinor: 35000n,
            completedAt: new Date('2026-11-17T00:00:00.000Z'),
            lines: [],
            payment: { kind, status: 'RECORDED', amountMinor: 35000n },
            outlet: { name: 'Main', receiptHeader: '', receiptFooter: '', receiptAddress: '' },
          }),
        },
        customerRetentionPolicy: { findUnique: async () => null },
        digitalReceipt: {
          create: async ({ data }: { data: Record<string, unknown> }) => ({
            id: 'receipt-1',
            ...data,
          }),
        },
      }),
    );

    const receipt = await service.createForSale(OUTLET_ID, SALE_ID, {}, owner());
    assert.ok(receipt.html.includes(`<td>${label}</td>`));
    assert.ok(receipt.text.includes(`Payment: ${label} RECORDED IDR 35000`));
    assert.ok(receipt.text.includes('SALE-RECEIPT-LABEL'));
    assert.ok(receipt.text.includes('Total: IDR 35000'));
  });
}

test('an expired or foreign receipt token returns not found', async () => {
  const service = new ReceiptsService(
    fakePrisma({
      digitalReceipt: { findFirst: async () => null },
    }),
  );

  await assert.rejects(
    service.getPublic('a'.repeat(64)),
    (error: unknown) =>
      typeof error === 'object' &&
      error !== null &&
      'getStatus' in error &&
      (error as { getStatus: () => number }).getStatus() === 404,
  );
});

test('a receipt for an anonymised customer is rejected without leaking data', async () => {
  const service = new ReceiptsService(
    fakePrisma({
      sale: {
        findFirst: async () => ({
          id: SALE_ID,
          reference: 'SALE-TEST',
          currency: 'IDR',
          currencyExponent: 0,
          subtotalMinor: 18000n,
          discountMinor: 0n,
          serviceMinor: 0n,
          taxMinor: 0n,
          totalMinor: 18000n,
          completedAt: new Date('2026-11-13T00:00:00.000Z'),
          lines: [],
          payment: null,
          outlet: { name: 'Main', receiptHeader: '', receiptFooter: '', receiptAddress: '' },
        }),
      },
      customer: {
        findFirst: async () => ({ id: 'customer-1', anonymizedAt: new Date() }),
      },
    }),
  );

  await assert.rejects(
    service.createForSale(OUTLET_ID, SALE_ID, { customerId: 'customer-1' }, owner()),
    (error: unknown) =>
      typeof error === 'object' &&
      error !== null &&
      'getStatus' in error &&
      (error as { getStatus: () => number }).getStatus() === 422,
  );
});
