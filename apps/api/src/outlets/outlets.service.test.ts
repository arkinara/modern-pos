import assert from 'node:assert/strict';
import { test } from 'node:test';
import { HttpException } from '@nestjs/common';
import { plainToInstance } from 'class-transformer';
import { validate } from 'class-validator';
import { Role } from '@prisma/client';
import type { AuthenticatedUser } from '../auth/auth.types';
import type { PrismaService } from '../prisma/prisma.service';
import { OutletUpdateDto } from './dto/outlet-update.dto';
import { OutletsService } from './outlets.service';
import { SettingsUpdateDto } from '../settings/dto/settings-update.dto';

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

function dto(overrides: Partial<OutletUpdateDto> = {}): OutletUpdateDto {
  return {
    name: 'Main Outlet',
    timezone: 'Asia/Jakarta',
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
      taxBps: 0,
      serviceBps: 0,
      pricingMode: 'EXCLUSIVE',
      version: existingVersion,
    },
  };
  let updateCalls = 0;

  const prisma = {
    outlet: {
      findFirst: async (args: { where: { id: string; businessId: string } }) => {
        if (args.where.id !== state.outlet.id || args.where.businessId !== BUSINESS_ID) {
          return null;
        }
        return state.outlet;
      },
      updateMany: async (args: {
        where: { id: string; businessId: string; version: number };
        data: Record<string, unknown>;
      }) => {
        updateCalls += 1;
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
  };

  return {
    prisma: prisma as unknown as PrismaService,
    state,
    updateCalls: () => updateCalls,
  };
}

test('outlet update rejects an unknown timezone before writing', async () => {
  const { prisma, updateCalls } = fakePrisma();
  const service = new OutletsService(prisma);

  await assert.rejects(
    () => service.update(OUTLET_ID, dto({ timezone: 'Not/AZone' }), user()),
    (error: unknown) =>
      error instanceof HttpException &&
      error.getStatus() === 400 &&
      (error.getResponse() as { code: string }).code === 'VALIDATION_ERROR',
  );
  assert.equal(updateCalls(), 0);
});

test('outlet update accepts a valid timezone and increments the version', async () => {
  const { prisma, state } = fakePrisma();
  const service = new OutletsService(prisma);

  const outlet = await service.update(OUTLET_ID, dto({ timezone: 'Asia/Jakarta' }), user());

  assert.equal(state.outlet.timezone, 'Asia/Jakarta');
  assert.equal(state.outlet.version, 2);
  assert.equal(outlet.timezone, 'Asia/Jakarta');
  assert.equal(outlet.version, 2);
});

test('outlet DTO rejects an invalid IANA timezone with a validation issue', async () => {
  const errors = await validate(plainToInstance(OutletUpdateDto, dto({ timezone: 'Not/AZone' })));

  assert.equal(errors.length, 1);
  assert.equal(errors[0].property, 'timezone');
  assert.deepEqual(errors[0].constraints, {
    isValidTimeZone: 'timezone must be a valid IANA time zone',
  });
});

test('both update paths accept the same overlapping values', async () => {
  const outletErrors = await validate(
    plainToInstance(
      OutletUpdateDto,
      dto({ timezone: 'Asia/Jakarta', receiptAddress: 'Jl. Example No. 1' }),
    ),
  );
  const settingsErrors = await validate(
    plainToInstance(SettingsUpdateDto, {
      businessName: 'Updated Business',
      currency: 'IDR',
      timezone: 'Asia/Jakarta',
      receiptHeader: '',
      receiptFooter: '',
      receiptAddress: 'Jl. Example No. 1',
      taxBps: 1100,
      serviceBps: 500,
      version: 1,
    }),
  );

  assert.deepEqual(outletErrors, []);
  assert.deepEqual(settingsErrors, []);
});
