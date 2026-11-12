import assert from 'node:assert/strict';
import { after, test } from 'node:test';
import { HttpException } from '@nestjs/common';
import {
  PaymentKind,
  PaymentProvider,
  PaymentStatus,
  Prisma,
  Role,
  SaleState,
} from '@prisma/client';
import type { AuthenticatedUser } from '../auth/auth.types';
import type { PrismaService } from '../prisma/prisma.service';
import type { MockPaymentProviderService } from './mock-payment-provider.service';
import { PaymentConfigService } from './payment-config.service';
import type { PaymentProviderAdapter, ProviderPaymentStatus } from './payment-provider.types';
import { PaymentsService } from './payments.service';
import type { QrisPaymentProviderService } from './qris-payment-provider.service';
import { signWebhookPayload } from './webhook-signature';

const BUSINESS_ID = '00000000-0000-4000-8000-000000000001';
const OUTLET_ID = '00000000-0000-4000-8000-000000000002';
const USER_ID = '00000000-0000-4000-8000-000000000003';
const SALE_ID = '00000000-0000-4000-8000-000000000010';
const PAYMENT_ID = '00000000-0000-4000-8000-000000000020';
const PAYMENT_RECORD_ID = '00000000-0000-4000-8000-000000000030';
const PROVIDER_REF = 'prov_test_1';
const WEBHOOK_SECRET = 'unit-test-webhook-secret';

const savedEnv = {
  PAYMENT_PROVIDER: process.env.PAYMENT_PROVIDER,
  PAYMENT_WEBHOOK_SECRET: process.env.PAYMENT_WEBHOOK_SECRET,
  PAYMENT_WEBHOOK_REPLAY_SECONDS: process.env.PAYMENT_WEBHOOK_REPLAY_SECONDS,
};

process.env.PAYMENT_PROVIDER = 'mock';
process.env.PAYMENT_WEBHOOK_SECRET = WEBHOOK_SECRET;
delete process.env.PAYMENT_WEBHOOK_REPLAY_SECONDS;

after(() => {
  for (const [key, value] of Object.entries(savedEnv)) {
    if (value === undefined) {
      delete process.env[key];
    } else {
      process.env[key] = value;
    }
  }
});

interface OnlinePaymentRow {
  id: string;
  businessId: string;
  outletId: string;
  saleId: string;
  provider: PaymentProvider;
  providerRef: string | null;
  status: PaymentStatus;
  amountMinor: bigint;
  refundedMinor: bigint;
  currency: string;
  currencyExponent: number;
  qrPayload: string | null;
  attempt: number;
  providerCreatedAt: Date | null;
  settledAt: Date | null;
  failedAt: Date | null;
  lastError: string | null;
  createdAt: Date;
  updatedAt: Date;
}

interface PaymentRecordRow {
  id: string;
  saleId: string;
  kind: PaymentKind;
  status: PaymentStatus;
  amountMinor: bigint;
}

interface SaleReversalRow {
  id: string;
  saleId: string;
  refundMinor: bigint;
  externalRefundPerformed: boolean;
  providerRefundRef: string | null;
}

interface SaleRow {
  id: string;
  businessId: string;
  outletId: string;
  reference: string;
  state: SaleState;
  currency: string;
  currencyExponent: number;
  totalMinor: bigint;
  completedAt: Date;
  payment: { kind: PaymentKind } | null;
  reversals: SaleReversalRow[];
}

type SettlementSaleRow = Omit<SaleRow, 'reversals'> & {
  onlinePayment: OnlinePaymentRow | null;
  reversals: { refundMinor: bigint }[];
};

interface WebhookEventRow {
  id: string;
  provider: PaymentProvider;
  eventId: string;
  eventType: string;
  onlinePaymentId: string | null;
  payload: unknown;
  receivedAt: Date;
  processedAt: Date | null;
}

interface OutletRow {
  id: string;
  businessId: string;
  timezone: string;
  currency: string;
  currencyExponent: number;
}

interface FakeState {
  onlinePayments: OnlinePaymentRow[];
  paymentRecords: PaymentRecordRow[];
  events: WebhookEventRow[];
  sales: SaleRow[];
  outlets: OutletRow[];
  stockMovements: { id: string }[];
  counters: {
    onlinePaymentUpdates: number;
    paymentRecordUpdates: number;
  };
}

function user(role: Role = Role.OWNER): AuthenticatedUser {
  return {
    id: USER_ID,
    businessId: BUSINESS_ID,
    email: 'owner@example.test',
    role,
    outletId: OUTLET_ID,
    outletIds: [OUTLET_ID],
    sessionId: 'session-1',
  };
}

function makePayment(overrides: Partial<OnlinePaymentRow> = {}): OnlinePaymentRow {
  const now = new Date('2026-11-12T10:00:00.000Z');
  return {
    id: PAYMENT_ID,
    businessId: BUSINESS_ID,
    outletId: OUTLET_ID,
    saleId: SALE_ID,
    provider: PaymentProvider.MOCK,
    providerRef: PROVIDER_REF,
    status: PaymentStatus.PENDING,
    amountMinor: 10_000n,
    refundedMinor: 0n,
    currency: 'IDR',
    currencyExponent: 0,
    qrPayload: 'mock://qris/prov_test_1',
    attempt: 1,
    providerCreatedAt: now,
    settledAt: null,
    failedAt: null,
    lastError: null,
    createdAt: now,
    updatedAt: now,
    ...overrides,
  };
}

function makeSale(overrides: Partial<SaleRow> = {}): SaleRow {
  return {
    id: SALE_ID,
    businessId: BUSINESS_ID,
    outletId: OUTLET_ID,
    reference: 'SALE-0001',
    state: SaleState.COMPLETED,
    currency: 'IDR',
    currencyExponent: 0,
    totalMinor: 10_000n,
    completedAt: new Date('2026-11-10T03:00:00.000Z'),
    payment: { kind: PaymentKind.ONLINE },
    reversals: [],
    ...overrides,
  };
}

function makePaymentRecord(overrides: Partial<PaymentRecordRow> = {}): PaymentRecordRow {
  return {
    id: PAYMENT_RECORD_ID,
    saleId: SALE_ID,
    kind: PaymentKind.ONLINE,
    status: PaymentStatus.PENDING,
    amountMinor: 10_000n,
    ...overrides,
  };
}

function uniqueViolation(): Prisma.PrismaClientKnownRequestError {
  return new Prisma.PrismaClientKnownRequestError('Unique constraint failed', {
    code: 'P2002',
    clientVersion: '6.19.3',
  });
}

function fakeAdapter(): {
  adapter: PaymentProviderAdapter;
  state: {
    createCalls: unknown[];
    fetchCalls: string[];
    refundCalls: { providerRef: string; idempotencyKey: string; amountMinor: bigint }[];
    fetchStatus: ProviderPaymentStatus;
    refundProviderRef: string;
  };
} {
  const state = {
    createCalls: [] as unknown[],
    fetchCalls: [] as string[],
    refundCalls: [] as { providerRef: string; idempotencyKey: string; amountMinor: bigint }[],
    fetchStatus: 'PENDING' as ProviderPaymentStatus,
    refundProviderRef: 'prov_refund_1',
  };

  const adapter: PaymentProviderAdapter = {
    name: 'MOCK',
    async createPayment(input) {
      state.createCalls.push(input);
      return {
        providerRef: `prov_created_${state.createCalls.length}`,
        status: 'PENDING',
        amountMinor: input.amountMinor,
        currency: input.currency,
        qrPayload: 'mock://qris/created',
      };
    },
    async fetchPayment(providerRef) {
      state.fetchCalls.push(providerRef);
      return {
        providerRef,
        status: state.fetchStatus,
        amountMinor: 10_000n,
        currency: 'IDR',
      };
    },
    async refundPayment(input) {
      state.refundCalls.push(input);
      return {
        providerRef: state.refundProviderRef,
        refundedMinor: input.amountMinor,
        status: 'SUCCEEDED',
      };
    },
  };

  return { adapter, state };
}

function createHarness(options: { seed?: boolean; fetchStatus?: ProviderPaymentStatus } = {}): {
  service: PaymentsService;
  prisma: PrismaService;
  state: FakeState;
  adapter: ReturnType<typeof fakeAdapter>;
} {
  const state: FakeState = {
    onlinePayments: [],
    paymentRecords: [],
    events: [],
    sales: [],
    outlets: [
      {
        id: OUTLET_ID,
        businessId: BUSINESS_ID,
        timezone: 'Asia/Jakarta',
        currency: 'IDR',
        currencyExponent: 0,
      },
    ],
    stockMovements: [{ id: 'stock-movement-1' }],
    counters: { onlinePaymentUpdates: 0, paymentRecordUpdates: 0 },
  };

  if (options.seed !== false) {
    state.onlinePayments.push(makePayment());
    state.paymentRecords.push(makePaymentRecord());
    state.sales.push(makeSale());
  }

  const nextId = (() => {
    let sequence = 0;
    return (): string => `00000000-0000-4000-8000-${String(100 + sequence++).padStart(12, '0')}`;
  })();

  const applyData = (row: Record<string, unknown>, data: Record<string, unknown>): void => {
    for (const [key, value] of Object.entries(data)) {
      if (
        value !== null &&
        typeof value === 'object' &&
        'increment' in (value as Record<string, unknown>)
      ) {
        row[key] =
          Number(row[key] ?? 0) + Number((value as { increment: number | bigint }).increment);
      } else {
        row[key] = value;
      }
    }
  };

  const onlinePayment = {
    findUnique: async (args: {
      where: { id?: string; providerRef?: string; saleId?: string };
    }): Promise<OnlinePaymentRow | null> => {
      const row = state.onlinePayments.find(
        (payment) =>
          (args.where.id === undefined || payment.id === args.where.id) &&
          (args.where.providerRef === undefined ||
            payment.providerRef === args.where.providerRef) &&
          (args.where.saleId === undefined || payment.saleId === args.where.saleId),
      );
      return row ? structuredClone(row) : null;
    },
    findMany: async (args: {
      where: {
        businessId: string;
        outletId: string;
        status?: PaymentStatus;
        providerRef?: { not: null };
        sale?: { is?: { completedAt?: { gte?: Date; lt?: Date } } };
      };
    }): Promise<OnlinePaymentRow[]> => {
      const range = args.where.sale?.is?.completedAt;
      return state.onlinePayments
        .filter((payment) => {
          if (
            payment.businessId !== args.where.businessId ||
            payment.outletId !== args.where.outletId
          ) {
            return false;
          }
          if (args.where.status !== undefined && payment.status !== args.where.status) {
            return false;
          }
          if (args.where.providerRef?.not === null && payment.providerRef === null) {
            return false;
          }
          if (range) {
            const sale = state.sales.find((row) => row.id === payment.saleId);
            if (!sale) {
              return false;
            }
            if (range.gte && sale.completedAt.getTime() < range.gte.getTime()) {
              return false;
            }
            if (range.lt && sale.completedAt.getTime() >= range.lt.getTime()) {
              return false;
            }
          }
          return true;
        })
        .sort((a, b) => a.createdAt.getTime() - b.createdAt.getTime() || a.id.localeCompare(b.id))
        .map((payment) => structuredClone(payment));
    },
    update: async (args: {
      where: { id: string };
      data: Partial<OnlinePaymentRow>;
    }): Promise<OnlinePaymentRow> => {
      const row = state.onlinePayments.find((payment) => payment.id === args.where.id);
      if (!row) {
        throw new Error('online payment missing');
      }
      applyData(row as unknown as Record<string, unknown>, args.data as Record<string, unknown>);
      row.updatedAt = new Date();
      state.counters.onlinePaymentUpdates += 1;
      return structuredClone(row);
    },
    updateMany: async (args: {
      where: { id?: string; status?: PaymentStatus; providerRef?: null };
      data: Partial<OnlinePaymentRow>;
    }): Promise<{ count: number }> => {
      const rows = state.onlinePayments.filter(
        (payment) =>
          (args.where.id === undefined || payment.id === args.where.id) &&
          (args.where.status === undefined || payment.status === args.where.status) &&
          (args.where.providerRef === undefined || payment.providerRef === args.where.providerRef),
      );
      for (const row of rows) {
        applyData(row as unknown as Record<string, unknown>, args.data as Record<string, unknown>);
        row.updatedAt = new Date();
      }
      state.counters.onlinePaymentUpdates += rows.length;
      return { count: rows.length };
    },
  };

  const paymentRecord = {
    updateMany: async (args: {
      where: { saleId: string; kind: PaymentKind };
      data: { status: PaymentStatus };
    }): Promise<{ count: number }> => {
      const rows = state.paymentRecords.filter(
        (record) => record.saleId === args.where.saleId && record.kind === args.where.kind,
      );
      for (const row of rows) {
        row.status = args.data.status;
      }
      state.counters.paymentRecordUpdates += rows.length;
      return { count: rows.length };
    },
  };

  const paymentWebhookEvent = {
    create: async (args: {
      data: {
        provider: PaymentProvider;
        eventId: string;
        eventType: string;
        onlinePaymentId?: string;
        payload: unknown;
        receivedAt?: Date;
        processedAt?: Date;
      };
    }): Promise<WebhookEventRow> => {
      if (
        state.events.some(
          (event) => event.provider === args.data.provider && event.eventId === args.data.eventId,
        )
      ) {
        throw uniqueViolation();
      }
      const row: WebhookEventRow = {
        id: nextId(),
        provider: args.data.provider,
        eventId: args.data.eventId,
        eventType: args.data.eventType,
        onlinePaymentId: args.data.onlinePaymentId ?? null,
        payload: structuredClone(args.data.payload),
        receivedAt: args.data.receivedAt ?? new Date(),
        processedAt: args.data.processedAt ?? null,
      };
      state.events.push(row);
      return structuredClone(row);
    },
    updateMany: async (args: {
      where: { provider: PaymentProvider; eventId: string };
      data: { processedAt: Date };
    }): Promise<{ count: number }> => {
      const rows = state.events.filter(
        (event) => event.provider === args.where.provider && event.eventId === args.where.eventId,
      );
      for (const row of rows) {
        row.processedAt = args.data.processedAt;
      }
      return { count: rows.length };
    },
    findUnique: async (args: {
      where: { provider_eventId: { provider: PaymentProvider; eventId: string } };
    }): Promise<WebhookEventRow | null> => {
      const row = state.events.find(
        (event) =>
          event.provider === args.where.provider_eventId.provider &&
          event.eventId === args.where.provider_eventId.eventId,
      );
      return row ? structuredClone(row) : null;
    },
  };

  const sale = {
    findFirst: async (args: {
      where: { id: string; outletId: string; businessId: string };
      include?: unknown;
    }): Promise<(SaleRow & { onlinePayment: OnlinePaymentRow | null }) | null> => {
      const row = state.sales.find(
        (candidate) =>
          candidate.id === args.where.id &&
          candidate.outletId === args.where.outletId &&
          candidate.businessId === args.where.businessId,
      );
      if (!row) {
        return null;
      }
      const payment = state.onlinePayments.find((candidate) => candidate.saleId === row.id);
      return structuredClone({ ...row, onlinePayment: payment ?? null });
    },
    findMany: async (args: {
      where: {
        businessId: string;
        outletId: string;
        state: SaleState;
        completedAt: { gte?: Date; lt?: Date };
        payment: { is: { kind: PaymentKind } };
      };
    }): Promise<SettlementSaleRow[]> => {
      const range = args.where.completedAt;
      return state.sales
        .filter((row) => {
          if (
            row.businessId !== args.where.businessId ||
            row.outletId !== args.where.outletId ||
            row.state !== args.where.state ||
            row.payment?.kind !== args.where.payment.is.kind
          ) {
            return false;
          }
          if (range.gte && row.completedAt.getTime() < range.gte.getTime()) {
            return false;
          }
          if (range.lt && row.completedAt.getTime() >= range.lt.getTime()) {
            return false;
          }
          return true;
        })
        .sort(
          (a, b) => a.completedAt.getTime() - b.completedAt.getTime() || a.id.localeCompare(b.id),
        )
        .map((row) => {
          const payment = state.onlinePayments.find((candidate) => candidate.saleId === row.id);
          return structuredClone({
            ...row,
            onlinePayment: payment ?? null,
            reversals: row.reversals.map((reversal) => ({
              refundMinor: reversal.refundMinor,
            })),
          });
        });
    },
  };

  const outlet = {
    findFirst: async (args: {
      where: { id: string; businessId: string };
    }): Promise<OutletRow | null> => {
      const row = state.outlets.find(
        (candidate) =>
          candidate.id === args.where.id && candidate.businessId === args.where.businessId,
      );
      return row ? structuredClone(row) : null;
    },
  };

  const queryRaw = async (
    strings: TemplateStringsArray,
    ...values: unknown[]
  ): Promise<{ id: string }[]> => {
    const sql = strings.join('?');
    if (sql.includes('"providerRef"')) {
      return state.onlinePayments
        .filter((payment) => payment.providerRef === String(values[0]))
        .map((payment) => ({ id: payment.id }));
    }
    if (sql.includes('"online_payments"')) {
      return state.onlinePayments
        .filter((payment) => payment.id === String(values[0]))
        .map((payment) => ({ id: payment.id }));
    }
    return [];
  };

  const client = {
    onlinePayment,
    paymentRecord,
    paymentWebhookEvent,
    sale,
    outlet,
  };

  let transactionQueue: Promise<unknown> = Promise.resolve();

  const prisma = {
    ...client,
    $queryRaw: queryRaw,
    $transaction: <T>(
      operation: (tx: typeof client & { $queryRaw: typeof queryRaw }) => Promise<T>,
      _options?: unknown,
    ): Promise<T> => {
      const result = transactionQueue.then(async () => {
        const snapshot = structuredClone(state);
        try {
          return await operation({ ...client, $queryRaw: queryRaw });
        } catch (error) {
          for (const key of Object.keys(snapshot) as (keyof FakeState)[]) {
            (state as unknown as Record<string, unknown>)[key] = snapshot[key];
          }
          throw error;
        }
      });
      transactionQueue = result.then(
        () => undefined,
        () => undefined,
      );
      return result;
    },
  };

  const adapter = fakeAdapter();
  adapter.state.fetchStatus = options.fetchStatus ?? 'PENDING';
  const service = new PaymentsService(
    prisma as unknown as PrismaService,
    new PaymentConfigService(),
    adapter.adapter as unknown as MockPaymentProviderService,
    adapter.adapter as unknown as QrisPaymentProviderService,
  );

  return { service, prisma: prisma as unknown as PrismaService, state, adapter };
}

function webhook(
  eventId: string,
  type: string,
  options: {
    providerRef?: string;
    amountMinor?: bigint;
    timestamp?: number;
    secret?: string;
  } = {},
): { rawBody: string; header: string } {
  const providerRef = options.providerRef ?? PROVIDER_REF;
  const amountMinor = options.amountMinor ?? 10_000n;
  const event = {
    id: eventId,
    type,
    provider: 'MOCK',
    data: {
      providerRef,
      amountMinor: amountMinor.toString(),
    },
  };
  const rawBody = JSON.stringify(event);
  const timestamp = options.timestamp ?? Math.floor(Date.now() / 1000);
  const secret = options.secret ?? WEBHOOK_SECRET;
  return {
    rawBody,
    header: `t=${timestamp},v1=${signWebhookPayload(secret, timestamp, rawBody)}`,
  };
}

function statusOf(error: unknown): number | undefined {
  return error instanceof HttpException ? error.getStatus() : undefined;
}

function codeOf(error: unknown): string | undefined {
  return error instanceof HttpException
    ? (error.getResponse() as { code: string }).code
    : undefined;
}

test('handleWebhook duplicate delivery applies one transition and one record update', async () => {
  const { service, state } = createHarness();
  const delivery = webhook('evt_dup_1', 'payment.succeeded');

  const first = await service.handleWebhook(delivery.header, delivery.rawBody);
  const second = await service.handleWebhook(delivery.header, delivery.rawBody);

  assert.equal(first.duplicate, false);
  assert.equal(first.status, PaymentStatus.SUCCEEDED);
  assert.equal(second.duplicate, true);
  assert.equal(second.status, PaymentStatus.SUCCEEDED);
  assert.equal(state.onlinePayments.length, 1);
  assert.equal(state.sales.length, 1);
  assert.equal(state.stockMovements.length, 1);
  assert.equal(state.onlinePayments[0]?.status, PaymentStatus.SUCCEEDED);
  assert.ok(state.onlinePayments[0]?.settledAt instanceof Date);
  assert.equal(state.paymentRecords[0]?.status, PaymentStatus.SUCCEEDED);
  assert.equal(state.counters.paymentRecordUpdates, 1);
  assert.equal(state.events.length, 1);
  assert.ok(state.events[0]?.processedAt instanceof Date);
});

test('handleWebhook concurrent duplicates produce one winner and one effect', async () => {
  const { service, state } = createHarness();
  const delivery = webhook('evt_concurrent_1', 'payment.succeeded');

  const results = await Promise.all([
    service.handleWebhook(delivery.header, delivery.rawBody),
    service.handleWebhook(delivery.header, delivery.rawBody),
  ]);

  assert.deepEqual(results.map((result) => result.duplicate).sort(), [false, true]);
  assert.equal(state.onlinePayments.length, 1);
  assert.equal(state.onlinePayments[0]?.status, PaymentStatus.SUCCEEDED);
  assert.equal(state.paymentRecords[0]?.status, PaymentStatus.SUCCEEDED);
  assert.equal(state.counters.paymentRecordUpdates, 1);
  assert.equal(state.events.length, 1);
});

test('handleWebhook out-of-order succeeded before pending keeps the settled state', async () => {
  const { service, state } = createHarness();
  const succeeded = webhook('evt_succeeded_1', 'payment.succeeded');
  const pending = webhook('evt_pending_1', 'payment.pending');

  const settled = await service.handleWebhook(succeeded.header, succeeded.rawBody);
  const late = await service.handleWebhook(pending.header, pending.rawBody);

  assert.equal(settled.status, PaymentStatus.SUCCEEDED);
  assert.equal(late.status, PaymentStatus.SUCCEEDED);
  assert.equal(state.onlinePayments[0]?.status, PaymentStatus.SUCCEEDED);
  assert.equal(state.paymentRecords[0]?.status, PaymentStatus.SUCCEEDED);
  assert.equal(state.counters.paymentRecordUpdates, 1);
  assert.equal(state.events.length, 2);
});

test('handleWebhook rejects an invalid signature without changing the payment row', async () => {
  const { service, state } = createHarness();
  const before = structuredClone(state.onlinePayments[0]);
  const delivery = webhook('evt_bad_sig', 'payment.succeeded', { secret: 'wrong-secret' });

  await assert.rejects(
    () => service.handleWebhook(delivery.header, delivery.rawBody),
    (error: unknown) => statusOf(error) === 401 && codeOf(error) === 'WEBHOOK_SIGNATURE_INVALID',
  );

  assert.deepEqual(state.onlinePayments[0], before);
  assert.equal(state.events.length, 0);
  assert.equal(state.counters.paymentRecordUpdates, 0);
});

test('handleWebhook rejects a replayed timestamp without changing the payment row', async () => {
  const { service, state } = createHarness();
  const before = structuredClone(state.onlinePayments[0]);
  const delivery = webhook('evt_stale', 'payment.succeeded', {
    timestamp: Math.floor(Date.now() / 1000) - 3_600,
  });

  await assert.rejects(
    () => service.handleWebhook(delivery.header, delivery.rawBody),
    (error: unknown) => statusOf(error) === 401 && codeOf(error) === 'WEBHOOK_TIMESTAMP_INVALID',
  );

  assert.deepEqual(state.onlinePayments[0], before);
  assert.equal(state.events.length, 0);
  assert.equal(state.counters.paymentRecordUpdates, 0);
});

test('handleWebhook failure then retry reaches one terminal charge with no duplicate row', async () => {
  const { service, state } = createHarness();
  const failed = webhook('evt_failed_1', 'payment.failed');
  const retried = webhook('evt_retry_1', 'payment.succeeded');

  const failedAck = await service.handleWebhook(failed.header, failed.rawBody);
  const retriedAck = await service.handleWebhook(retried.header, retried.rawBody);

  assert.equal(failedAck.status, PaymentStatus.FAILED);
  assert.equal(retriedAck.status, PaymentStatus.SUCCEEDED);
  assert.equal(state.onlinePayments.length, 1);
  assert.equal(state.onlinePayments[0]?.status, PaymentStatus.SUCCEEDED);
  assert.equal(state.onlinePayments[0]?.failedAt, null);
  assert.ok(state.onlinePayments[0]?.settledAt instanceof Date);
  assert.equal(state.paymentRecords[0]?.status, PaymentStatus.SUCCEEDED);
  assert.equal(state.counters.paymentRecordUpdates, 2);
  assert.equal(state.events.length, 2);
});

test('reconcile settles one stuck pending payment without creating a second charge', async () => {
  const { service, state, adapter } = createHarness({ fetchStatus: 'SUCCEEDED' });

  const summary = await service.reconcile(OUTLET_ID, user());
  const second = await service.reconcile(OUTLET_ID, user());

  assert.equal(summary.checked, 1);
  assert.equal(summary.settled, 1);
  assert.equal(summary.failed, 0);
  assert.equal(summary.unchanged, 0);
  assert.equal(summary.items[0]?.status, PaymentStatus.SUCCEEDED);
  assert.equal(second.checked, 0);
  assert.equal(second.settled, 0);
  assert.equal(state.onlinePayments.length, 1);
  assert.equal(state.onlinePayments[0]?.status, PaymentStatus.SUCCEEDED);
  assert.equal(state.paymentRecords[0]?.status, PaymentStatus.SUCCEEDED);
  assert.equal(state.counters.paymentRecordUpdates, 1);
  assert.equal(state.stockMovements.length, 1);
  assert.equal(adapter.state.fetchCalls.length, 1);
  assert.equal(adapter.state.createCalls.length, 0);
});

test('reconcile leaves a consistent pending provider state unchanged', async () => {
  const { service, state, adapter } = createHarness({ fetchStatus: 'PENDING' });

  const summary = await service.reconcile(OUTLET_ID, user());

  assert.equal(summary.checked, 1);
  assert.equal(summary.settled, 0);
  assert.equal(summary.failed, 0);
  assert.equal(summary.unchanged, 1);
  assert.equal(summary.items[0]?.status, PaymentStatus.PENDING);
  assert.equal(state.onlinePayments[0]?.status, PaymentStatus.PENDING);
  assert.equal(state.paymentRecords[0]?.status, PaymentStatus.PENDING);
  assert.equal(state.counters.onlinePaymentUpdates, 0);
  assert.equal(state.counters.paymentRecordUpdates, 0);
  assert.equal(adapter.state.fetchCalls.length, 1);
  assert.equal(adapter.state.createCalls.length, 0);
});

test('refundForReversal uses the reversal idempotency key and records the provider refund', async () => {
  const { service, prisma, state, adapter } = createHarness();
  state.onlinePayments[0]!.status = PaymentStatus.SUCCEEDED;
  state.onlinePayments[0]!.settledAt = new Date('2026-11-10T03:01:00.000Z');
  state.paymentRecords[0]!.status = PaymentStatus.SUCCEEDED;

  const result = await service.refundForReversal({
    outletId: OUTLET_ID,
    saleId: SALE_ID,
    idempotencyKey: '11111111-1111-4111-8111-111111111111',
    amountMinor: 4_000n,
    user: user(),
  });

  assert.equal(result.performed, true);
  assert.equal(result.providerRefundRef, 'prov_refund_1');
  assert.equal(adapter.state.refundCalls.length, 1);
  assert.equal(
    adapter.state.refundCalls[0]?.idempotencyKey,
    'reversal:11111111-1111-4111-8111-111111111111',
  );
  assert.equal(adapter.state.refundCalls[0]?.amountMinor, 4_000n);

  await service.applyReversalRefund(prisma as unknown as Prisma.TransactionClient, SALE_ID, 4_000n);

  assert.equal(state.onlinePayments[0]?.refundedMinor, 4_000n);
  assert.equal(state.onlinePayments[0]?.status, PaymentStatus.PARTIALLY_REFUNDED);
  assert.equal(state.paymentRecords[0]?.status, PaymentStatus.PARTIALLY_REFUNDED);
});

test('refundForReversal keeps financial-only corrections out of the provider', async () => {
  const { service, state, adapter } = createHarness();

  const result = await service.refundForReversal({
    outletId: OUTLET_ID,
    saleId: SALE_ID,
    idempotencyKey: '22222222-2222-4222-8222-222222222222',
    amountMinor: 0n,
    user: user(),
  });

  assert.equal(result.performed, false);
  assert.equal(result.providerRefundRef, null);
  assert.equal(adapter.state.refundCalls.length, 0);
  assert.equal(state.onlinePayments[0]?.refundedMinor, 0n);
});

test('refundForReversal rejects a double refund with 409', async () => {
  const { service, prisma, state, adapter } = createHarness();
  state.onlinePayments[0]!.status = PaymentStatus.SUCCEEDED;
  state.paymentRecords[0]!.status = PaymentStatus.SUCCEEDED;
  const input = {
    outletId: OUTLET_ID,
    saleId: SALE_ID,
    idempotencyKey: '33333333-3333-4333-8333-333333333333',
    amountMinor: 6_000n,
    user: user(),
  };

  await service.refundForReversal(input);
  await service.applyReversalRefund(prisma as unknown as Prisma.TransactionClient, SALE_ID, 6_000n);

  await assert.rejects(
    () => service.refundForReversal(input),
    (error: unknown) => statusOf(error) === 409 && codeOf(error) === 'REFUND_EXCEEDS_PAYMENT',
  );

  assert.equal(adapter.state.refundCalls.length, 1);
  assert.equal(state.onlinePayments[0]?.refundedMinor, 6_000n);
});

test('settlementReport totals reconcile against hand-computable payment fixtures', async () => {
  const { service, state } = createHarness({ seed: false });

  state.sales.push(
    makeSale({
      id: 'sale-a',
      reference: 'SALE-A',
      totalMinor: 100_000n,
      completedAt: new Date('2026-11-10T03:00:00.000Z'),
      reversals: [
        {
          id: 'reversal-a',
          saleId: 'sale-a',
          refundMinor: 25_000n,
          externalRefundPerformed: true,
          providerRefundRef: 'prov_refund_a',
        },
      ],
    }),
    makeSale({
      id: 'sale-b',
      reference: 'SALE-B',
      totalMinor: 50_000n,
      completedAt: new Date('2026-11-10T09:00:00.000Z'),
    }),
    makeSale({
      id: 'sale-c',
      reference: 'SALE-C',
      totalMinor: 30_000n,
      completedAt: new Date('2026-11-11T03:00:00.000Z'),
    }),
  );
  state.onlinePayments.push(
    makePayment({
      id: 'payment-a',
      saleId: 'sale-a',
      providerRef: 'prov_a',
      status: PaymentStatus.SUCCEEDED,
      amountMinor: 100_000n,
      settledAt: new Date('2026-11-10T03:01:00.000Z'),
    }),
    makePayment({
      id: 'payment-b',
      saleId: 'sale-b',
      providerRef: 'prov_b',
      status: PaymentStatus.PENDING,
      amountMinor: 50_000n,
      settledAt: null,
    }),
    makePayment({
      id: 'payment-c',
      saleId: 'sale-c',
      providerRef: 'prov_c',
      status: PaymentStatus.FAILED,
      amountMinor: 30_000n,
      settledAt: null,
      failedAt: new Date('2026-11-11T03:01:00.000Z'),
    }),
  );
  state.paymentRecords.push(
    makePaymentRecord({ id: 'record-a', saleId: 'sale-a', status: PaymentStatus.SUCCEEDED }),
    makePaymentRecord({ id: 'record-b', saleId: 'sale-b', status: PaymentStatus.PENDING }),
    makePaymentRecord({ id: 'record-c', saleId: 'sale-c', status: PaymentStatus.FAILED }),
  );

  const report = await service.settlementReport(
    OUTLET_ID,
    { from: '2026-11-10', to: '2026-11-11' },
    user(),
  );

  assert.equal(report.saleCount, 3);
  assert.equal(report.onlineSaleTotalMinor, 180_000);
  assert.equal(report.capturedMinor, 100_000);
  assert.equal(report.refundedMinor, 25_000);
  assert.equal(report.netMinor, 75_000);
  assert.equal(report.pendingMinor, 50_000);
  assert.equal(report.failedMinor, 30_000);
  assert.equal(report.driftMinor, 0);
  assert.deepEqual(report.days, [
    {
      date: '2026-11-10',
      paymentCount: 2,
      capturedMinor: 100_000,
      refundedMinor: 25_000,
      netMinor: 75_000,
      pendingMinor: 50_000,
      failedMinor: 0,
    },
    {
      date: '2026-11-11',
      paymentCount: 1,
      capturedMinor: 0,
      refundedMinor: 0,
      netMinor: 0,
      pendingMinor: 0,
      failedMinor: 30_000,
    },
  ]);
  assert.deepEqual(
    report.payments.map((payment) => ({
      saleId: payment.saleId,
      capturedMinor: payment.capturedMinor,
      refundedMinor: payment.refundedMinor,
      netMinor: payment.netMinor,
      status: payment.status,
    })),
    [
      {
        saleId: 'sale-a',
        capturedMinor: 100_000,
        refundedMinor: 25_000,
        netMinor: 75_000,
        status: PaymentStatus.SUCCEEDED,
      },
      {
        saleId: 'sale-b',
        capturedMinor: 0,
        refundedMinor: 0,
        netMinor: 0,
        status: PaymentStatus.PENDING,
      },
      {
        saleId: 'sale-c',
        capturedMinor: 0,
        refundedMinor: 0,
        netMinor: 0,
        status: PaymentStatus.FAILED,
      },
    ],
  );
});
