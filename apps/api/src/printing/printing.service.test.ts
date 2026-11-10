import assert from 'node:assert/strict';
import { test } from 'node:test';
import { HttpException } from '@nestjs/common';
import { Role } from '@prisma/client';
import type { AuthenticatedUser } from '../auth/auth.types';
import type { PrismaService } from '../prisma/prisma.service';
import { PrintingService } from './printing.service';
import type { PrintJobStateDto } from './dto/print-job-state.dto';
import type { PrintJobWriteDto } from './dto/print-job-write.dto';
import type { PrinterWriteDto } from './dto/printer-write.dto';

const BUSINESS_ID = '00000000-0000-4000-8000-000000000001';
const OTHER_BUSINESS_ID = '00000000-0000-4000-8000-000000000010';
const OUTLET_ID = '00000000-0000-4000-8000-000000000002';
const DEVICE_ID = '00000000-0000-4000-8000-000000000099';
const OTHER_DEVICE_ID = '00000000-0000-4000-8000-000000000098';
const PRINTER_ID = '00000000-0000-4000-8000-000000000401';
const JOB_ID = '00000000-0000-4000-8000-000000000501';
const SALE_ID = '00000000-0000-4000-8000-000000000096';
const IDEMPOTENCY_KEY = '00000000-0000-4000-8000-000000000601';

function owner(): AuthenticatedUser {
  return {
    id: 'user-1',
    businessId: BUSINESS_ID,
    email: 'owner@example.test',
    role: Role.OWNER,
    outletId: OUTLET_ID,
    outletIds: [OUTLET_ID],
    sessionId: 'session-1',
  };
}

function printerWrite(overrides: Partial<PrinterWriteDto> = {}): PrinterWriteDto {
  return {
    deviceId: DEVICE_ID,
    name: 'Front counter',
    model: 'Candidate model',
    transport: 'BLUETOOTH',
    paperWidthMm: 58,
    encoding: 'CP437',
    connectionSettings: { address: 'AA:BB:CC:DD:EE:FF' },
    ...overrides,
  };
}

function jobWrite(overrides: Partial<PrintJobWriteDto> = {}): PrintJobWriteDto {
  return {
    id: JOB_ID,
    saleId: SALE_ID,
    deviceId: DEVICE_ID,
    printerConfigId: PRINTER_ID,
    copy: false,
    ...overrides,
  };
}

interface FakeState {
  outlet: { id: string; businessId: string } | null;
  printers: Record<string, Record<string, unknown>>;
  jobs: Record<string, Record<string, unknown>>;
  sale: { id: string; businessId: string; outletId: string; deviceId: string };
}

function fakePrisma(): { prisma: PrismaService; state: FakeState } {
  const state: FakeState = {
    outlet: { id: OUTLET_ID, businessId: BUSINESS_ID },
    printers: {},
    jobs: {},
    sale: { id: SALE_ID, businessId: BUSINESS_ID, outletId: OUTLET_ID, deviceId: DEVICE_ID },
  };

  const prisma = {
    outlet: {
      findFirst: async (args: { where: { id: string; businessId: string } }) => {
        if (
          !state.outlet ||
          args.where.id !== state.outlet.id ||
          args.where.businessId !== state.outlet.businessId
        ) {
          return null;
        }
        return { id: state.outlet.id };
      },
    },
    printer: {
      findMany: async (args: {
        where: { businessId: string; outletId: string; deviceId: string };
      }) =>
        Object.values(state.printers).filter(
          (row) =>
            row.businessId === args.where.businessId &&
            row.outletId === args.where.outletId &&
            row.deviceId === args.where.deviceId,
        ),
      findFirst: async (args: { where: Record<string, string> }) =>
        Object.values(state.printers).find((row) =>
          Object.entries(args.where).every(([key, value]) => row[key] === value),
        ) ?? null,
      create: async (args: { data: Record<string, unknown> }) => {
        const row = {
          id: PRINTER_ID,
          revision: 1,
          createdAt: new Date('2026-01-01T00:00:00Z'),
          updatedAt: new Date('2026-01-01T00:00:00Z'),
          ...args.data,
        };
        state.printers[PRINTER_ID] = row;
        return row;
      },
      updateMany: async (args: {
        where: Record<string, unknown>;
        data: Record<string, unknown>;
      }) => {
        const row = Object.values(state.printers).find((entry) =>
          Object.entries(args.where).every(([key, value]) => entry[key] === value),
        );
        if (!row) {
          return { count: 0 };
        }
        const { revision, ...rest } = args.data;
        Object.assign(row, rest);
        if (typeof revision === 'object' && revision !== null && 'increment' in revision) {
          row.revision =
            Number(row.revision) + Number((revision as { increment: number }).increment);
        }
        return { count: 1 };
      },
    },
    sale: {
      findFirst: async (args: { where: Record<string, string> }) => {
        if (
          args.where.id !== state.sale.id ||
          args.where.businessId !== state.sale.businessId ||
          args.where.outletId !== state.sale.outletId
        ) {
          return null;
        }
        return { id: state.sale.id, deviceId: state.sale.deviceId };
      },
    },
    printJob: {
      findFirst: async (args: { where: Record<string, string> }) =>
        Object.values(state.jobs).find((row) =>
          Object.entries(args.where).every(([key, value]) => row[key] === value),
        ) ?? null,
      create: async (args: { data: Record<string, unknown> }) => {
        const row: Record<string, unknown> = {
          state: 'QUEUED',
          attempts: 0,
          lastError: null,
          createdAt: new Date('2026-01-01T00:00:00Z'),
          updatedAt: new Date('2026-01-01T00:00:00Z'),
          ...args.data,
        };
        state.jobs[String(row.id)] = row;
        return row;
      },
      update: async (args: { where: { id: string }; data: Record<string, unknown> }) => {
        const row = state.jobs[args.where.id];
        if (!row) {
          throw new Error('missing job');
        }
        Object.assign(row, args.data);
        return row;
      },
    },
  };

  return { prisma: prisma as unknown as PrismaService, state };
}

function statusOf(error: unknown): number | undefined {
  return error instanceof HttpException ? error.getStatus() : undefined;
}

test('lists only device-owned printers inside the authenticated business', async () => {
  const { prisma, state } = fakePrisma();
  const service = new PrintingService(prisma);
  const created = await service.createPrinter(OUTLET_ID, printerWrite(), owner());

  assert.equal(created.deviceId, DEVICE_ID);
  state.printers['foreign'] = {
    id: 'foreign',
    businessId: OTHER_BUSINESS_ID,
    outletId: OUTLET_ID,
    deviceId: DEVICE_ID,
    name: 'Other tenant',
    model: 'x',
    transport: 'BLUETOOTH',
    paperWidthMm: 58,
    encoding: 'CP437',
    revision: 1,
  };

  const list = await service.listPrinters(OUTLET_ID, DEVICE_ID, owner());
  assert.equal(list.length, 1);
  assert.equal(list[0]?.name, 'Front counter');
});

test('printer update uses optimistic revision and rejects stale writes', async () => {
  const { prisma } = fakePrisma();
  const service = new PrintingService(prisma);
  await service.createPrinter(OUTLET_ID, printerWrite(), owner());

  const updated = await service.updatePrinter(
    OUTLET_ID,
    PRINTER_ID,
    { ...printerWrite({ name: 'Bar counter' }), revision: 1 },
    owner(),
  );
  assert.equal(updated.name, 'Bar counter');
  assert.equal(updated.revision, 2);

  await assert.rejects(
    service.updatePrinter(
      OUTLET_ID,
      PRINTER_ID,
      { ...printerWrite({ name: 'Stale' }), revision: 1 },
      owner(),
    ),
    (error: unknown) => statusOf(error) === 409,
  );
});

test('job creation is idempotent for the same payload and rejects a conflicting key', async () => {
  const { prisma } = fakePrisma();
  const service = new PrintingService(prisma);
  await service.createPrinter(OUTLET_ID, printerWrite(), owner());

  const first = await service.createJob(OUTLET_ID, IDEMPOTENCY_KEY, jobWrite(), owner());
  const replay = await service.createJob(OUTLET_ID, IDEMPOTENCY_KEY, jobWrite(), owner());
  assert.equal(first.id, replay.id);
  assert.equal(replay.state, 'QUEUED');

  await assert.rejects(
    service.createJob(OUTLET_ID, IDEMPOTENCY_KEY, jobWrite({ copy: true }), owner()),
    (error: unknown) => statusOf(error) === 409,
  );
});

test('another device cannot update a print job and receives 404', async () => {
  const { prisma } = fakePrisma();
  const service = new PrintingService(prisma);
  await service.createPrinter(OUTLET_ID, printerWrite(), owner());
  await service.createJob(OUTLET_ID, IDEMPOTENCY_KEY, jobWrite(), owner());

  const stateUpdate: PrintJobStateDto = {
    deviceId: OTHER_DEVICE_ID,
    state: 'SENT',
    attempts: 1,
    lastError: null,
  };

  await assert.rejects(
    service.updateJobState(OUTLET_ID, JOB_ID, stateUpdate, owner()),
    (error: unknown) => statusOf(error) === 404,
  );
});

test('owned job state is persisted and returned for read-back', async () => {
  const { prisma } = fakePrisma();
  const service = new PrintingService(prisma);
  await service.createPrinter(OUTLET_ID, printerWrite(), owner());
  await service.createJob(OUTLET_ID, IDEMPOTENCY_KEY, jobWrite(), owner());

  const updated = await service.updateJobState(
    OUTLET_ID,
    JOB_ID,
    { deviceId: DEVICE_ID, state: 'FAILED', attempts: 2, lastError: 'Printer off' },
    owner(),
  );

  assert.equal(updated.state, 'FAILED');
  assert.equal(updated.attempts, 2);
  assert.equal(updated.lastError, 'Printer off');
  assert.equal(updated.copy, false);
});

test('job creation rejects a sale that belongs to another device', async () => {
  const { prisma, state } = fakePrisma();
  state.sale.deviceId = OTHER_DEVICE_ID;
  const service = new PrintingService(prisma);
  await service.createPrinter(OUTLET_ID, printerWrite(), owner());

  await assert.rejects(
    service.createJob(OUTLET_ID, IDEMPOTENCY_KEY, jobWrite(), owner()),
    (error: unknown) => statusOf(error) === 404,
  );
});
