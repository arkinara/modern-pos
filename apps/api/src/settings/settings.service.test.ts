import assert from 'node:assert/strict';
import { test } from 'node:test';
import { HttpException } from '@nestjs/common';
import { Role } from '@prisma/client';
import type { AuthenticatedUser } from '../auth/auth.types';
import type { PrismaService } from '../prisma/prisma.service';
import { SettingsController } from './settings.controller';
import type { SettingsUpdateDto } from './dto/settings-update.dto';
import { currencyExponentFor, SettingsService } from './settings.service';
import { isValidTimeZone } from '../common/timezone';
import { ROLES_KEY } from '../common/decorators/roles.decorator';

const BUSINESS_ID = '00000000-0000-4000-8000-000000000001';
const OUTLET_ID = '00000000-0000-4000-8000-000000000002';

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

function dto(overrides: Partial<SettingsUpdateDto> = {}): SettingsUpdateDto {
  return {
    businessName: 'Updated Business',
    currency: 'USD',
    timezone: 'Asia/Jakarta',
    receiptHeader: 'Header',
    receiptFooter: 'Footer',
    receiptAddress: 'Jl. Example No. 1',
    taxBps: 1100,
    serviceBps: 500,
    version: 1,
    ...overrides,
  };
}

function fakePrisma(existingVersion = 1) {
  const state = {
    outlet: {
      id: OUTLET_ID,
      businessId: BUSINESS_ID,
      name: 'Main Outlet',
      currency: 'IDR',
      currencyExponent: 0,
      timezone: 'Asia/Jakarta',
      receiptAddress: '',
      receiptHeader: '',
      receiptFooter: '',
      taxBps: 0,
      serviceBps: 0,
      pricingMode: 'EXCLUSIVE',
      version: existingVersion,
    },
    business: { name: 'Modern POS Demo' },
  };

  const prisma = {
    outlet: {
      findFirst: async (args: {
        where: { id: string; businessId: string };
        select?: unknown;
        include?: unknown;
      }) => {
        if (args.where.id !== state.outlet.id || args.where.businessId !== BUSINESS_ID) {
          return null;
        }
        if (args.select) {
          return { id: state.outlet.id, version: state.outlet.version };
        }
        if (args.include) {
          return { ...state.outlet, business: { name: state.business.name } };
        }
        return state.outlet;
      },
      updateMany: async (args: {
        where: { id: string; businessId: string; version: number };
        data: Record<string, unknown>;
      }) => {
        if (
          args.where.id !== state.outlet.id ||
          args.where.businessId !== BUSINESS_ID ||
          args.where.version !== state.outlet.version
        ) {
          return { count: 0 };
        }

        const { version: versionUpdate, ...rest } = args.data;
        Object.assign(state.outlet, rest);
        if (
          typeof versionUpdate === 'object' &&
          versionUpdate !== null &&
          'increment' in versionUpdate
        ) {
          state.outlet.version += Number((versionUpdate as { increment: number }).increment);
        }
        return { count: 1 };
      },
    },
    business: {
      update: async (args: { where: { id: string }; data: { name: string } }) => {
        state.business.name = args.data.name;
        return { id: args.where.id, name: state.business.name };
      },
    },
    $transaction: async <T>(callback: (tx: unknown) => Promise<T>): Promise<T> => callback(prisma),
  };

  return { prisma: prisma as unknown as PrismaService, state };
}

test('settings read is scoped to the authenticated business', async () => {
  const { prisma } = fakePrisma();
  const service = new SettingsService(prisma);

  const settings = await service.getAuthorized(OUTLET_ID, user());

  assert.equal(settings.outletId, OUTLET_ID);
  assert.equal(settings.outletName, 'Main Outlet');
  assert.equal(settings.businessName, 'Modern POS Demo');
  assert.equal(settings.pricingMode, 'EXCLUSIVE');
});

test('settings read returns 404 for another business', async () => {
  const { prisma } = fakePrisma();
  const service = new SettingsService(prisma);

  await assert.rejects(
    () => service.getAuthorized('other-outlet', user()),
    (error: unknown) => error instanceof HttpException && error.getStatus() === 404,
  );
});

test('settings update rejects an unknown timezone before writing', async () => {
  let transactionCalls = 0;
  const { prisma } = fakePrisma();
  const originalTransaction = prisma.$transaction.bind(prisma);
  (prisma as unknown as { $transaction: unknown }).$transaction = async <T>(
    callback: (tx: unknown) => Promise<T>,
  ): Promise<T> => {
    transactionCalls += 1;
    return originalTransaction(callback);
  };
  const service = new SettingsService(prisma);

  await assert.rejects(
    () => service.update(OUTLET_ID, dto({ timezone: 'Not/AZone' }), user()),
    (error: unknown) =>
      error instanceof HttpException &&
      error.getStatus() === 400 &&
      (error.getResponse() as { code: string }).code === 'VALIDATION_ERROR',
  );
  assert.equal(transactionCalls, 0);
});

test('settings update rejects a stale version with a conflict', async () => {
  const { prisma } = fakePrisma(3);
  const service = new SettingsService(prisma);

  await assert.rejects(
    () => service.update(OUTLET_ID, dto({ version: 2 }), user()),
    (error: unknown) =>
      error instanceof HttpException &&
      error.getStatus() === 409 &&
      (error.getResponse() as { code: string }).code === 'VERSION_CONFLICT',
  );
});

test('settings update writes business name and outlet settings then returns the record', async () => {
  const { prisma, state } = fakePrisma();
  const service = new SettingsService(prisma);

  const settings = await service.update(OUTLET_ID, dto(), user());

  assert.equal(state.business.name, 'Updated Business');
  assert.equal(state.outlet.currency, 'USD');
  assert.equal(state.outlet.currencyExponent, 2);
  assert.equal(state.outlet.taxBps, 1100);
  assert.equal(state.outlet.serviceBps, 500);
  assert.equal(state.outlet.version, 2);
  assert.equal(settings.businessName, 'Updated Business');
  assert.equal(settings.version, 2);
});

test('settings mutation is owner-only', () => {
  const roles = Reflect.getMetadata(ROLES_KEY, SettingsController.prototype.update) as Role[];
  assert.deepEqual(roles, [Role.OWNER]);
});

test('currency exponents and timezone validation are server-owned', () => {
  assert.equal(currencyExponentFor('IDR'), 0);
  assert.equal(currencyExponentFor('JPY'), 0);
  assert.equal(currencyExponentFor('USD'), 2);
  assert.equal(currencyExponentFor('ZZZ'), 2);
  assert.equal(isValidTimeZone('Asia/Jakarta'), true);
  assert.equal(isValidTimeZone('Not/AZone'), false);
});
