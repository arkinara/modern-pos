import assert from 'node:assert/strict';
import { afterEach, test } from 'node:test';
import { HttpException } from '@nestjs/common';
import type { PrismaService } from '../prisma/prisma.service';
import { MockPaymentProviderService } from './mock-payment-provider.service';
import { PaymentConfigService } from './payment-config.service';
import { SandboxProviderController, SandboxProviderGuard } from './sandbox-provider.controller';

const keys = ['NODE_ENV', 'PAYMENT_PROVIDER', 'PAYMENT_MODE', 'PAYMENT_SANDBOX_ENABLED'];
const saved = new Map<string, string | undefined>();
function setEnv(env: Record<string, string | undefined>) {
  for (const key of keys) {
    if (!saved.has(key)) saved.set(key, process.env[key]);
    if (env[key] === undefined) delete process.env[key];
    else process.env[key] = env[key];
  }
}
afterEach(() => {
  for (const [key, value] of saved) {
    if (value === undefined) delete process.env[key];
    else process.env[key] = value;
  }
  saved.clear();
});
const notFound = (error: unknown) => error instanceof HttpException && error.getStatus() === 404;

test('sandbox guard rejects production before request-body validation and allows opted-in local requests', () => {
  setEnv({ NODE_ENV: 'production', PAYMENT_PROVIDER: 'mock', PAYMENT_SANDBOX_ENABLED: 'true' });
  assert.throws(() => new SandboxProviderGuard(new PaymentConfigService()).canActivate(), notFound);
  setEnv({ NODE_ENV: 'test', PAYMENT_PROVIDER: 'mock', PAYMENT_SANDBOX_ENABLED: 'true' });
  assert.equal(new SandboxProviderGuard(new PaymentConfigService()).canActivate(), true);
});

test('all public sandbox endpoints return 404 in production even with MOCK and opt-in forced on', async () => {
  setEnv({
    NODE_ENV: 'production',
    PAYMENT_PROVIDER: 'mock',
    PAYMENT_MODE: 'sandbox',
    PAYMENT_SANDBOX_ENABLED: 'true',
  });
  let calls = 0;
  const provider = {
    createPayment: async () => {
      calls++;
    },
    fetchPayment: async () => {
      calls++;
    },
    createEvent: async () => {
      calls++;
    },
  } as unknown as MockPaymentProviderService;
  const controller = new SandboxProviderController(new PaymentConfigService(), provider);
  await assert.rejects(
    () => controller.create({ idempotencyKey: 'key', amountMinor: 1000, currency: 'IDR' }),
    notFound,
  );
  await assert.rejects(() => controller.read('provider-ref'), notFound);
  await assert.rejects(
    () => controller.event('provider-ref', { type: 'payment.succeeded' }),
    notFound,
  );
  assert.equal(calls, 0);
});

test('sandbox endpoints also stay unavailable without opt-in or with a real provider/live mode', async () => {
  for (const env of [
    { NODE_ENV: 'development', PAYMENT_PROVIDER: 'mock' },
    { NODE_ENV: 'test', PAYMENT_PROVIDER: 'qris', PAYMENT_SANDBOX_ENABLED: 'true' },
    {
      NODE_ENV: 'development',
      PAYMENT_PROVIDER: 'mock',
      PAYMENT_MODE: 'live',
      PAYMENT_SANDBOX_ENABLED: 'true',
    },
    { NODE_ENV: 'staging', PAYMENT_PROVIDER: 'mock', PAYMENT_SANDBOX_ENABLED: 'true' },
  ]) {
    setEnv(env);
    const controller = new SandboxProviderController(
      new PaymentConfigService(),
      {} as MockPaymentProviderService,
    );
    await assert.rejects(() => controller.read('provider-ref'), notFound);
  }
});

test('explicit local sandbox opt-in retains create/read/event behavior and serialization', async () => {
  setEnv({
    NODE_ENV: 'test',
    PAYMENT_PROVIDER: 'mock',
    PAYMENT_MODE: 'sandbox',
    PAYMENT_SANDBOX_ENABLED: 'true',
  });
  const calls: string[] = [];
  const payment = {
    providerRef: 'provider-ref',
    amountMinor: 1000n,
    currency: 'IDR',
    status: 'PENDING',
  };
  const provider = {
    createPayment: async () => {
      calls.push('create');
      return payment;
    },
    fetchPayment: async () => {
      calls.push('read');
      return payment;
    },
    createEvent: async () => {
      calls.push('event');
      return { eventId: 'signed-event' };
    },
  } as unknown as MockPaymentProviderService;
  const controller = new SandboxProviderController(new PaymentConfigService(), provider);
  assert.equal(
    (await controller.create({ idempotencyKey: 'key', amountMinor: 1000, currency: 'IDR' }))
      .amountMinor,
    '1000',
  );
  assert.equal((await controller.read('provider-ref')).providerRef, 'provider-ref');
  assert.deepEqual(await controller.event('provider-ref', { type: 'payment.succeeded' }), {
    eventId: 'signed-event',
  });
  assert.deepEqual(calls, ['create', 'read', 'event']);
});

test('direct mock-provider access cannot bypass the production controller gate', async () => {
  setEnv({
    NODE_ENV: 'production',
    PAYMENT_PROVIDER: 'mock',
    PAYMENT_MODE: 'sandbox',
    PAYMENT_SANDBOX_ENABLED: 'true',
  });
  const provider = new MockPaymentProviderService({} as PrismaService, new PaymentConfigService());
  await assert.rejects(
    () => provider.createPayment({ idempotencyKey: 'key', amountMinor: 1000n, currency: 'IDR' }),
    notFound,
  );
  await assert.rejects(() => provider.fetchPayment('provider-ref'), notFound);
  await assert.rejects(
    () =>
      provider.refundPayment({
        providerRef: 'provider-ref',
        idempotencyKey: 'key',
        amountMinor: 1000n,
      }),
    notFound,
  );
  await assert.rejects(() => provider.createEvent('provider-ref', 'payment.succeeded'), notFound);
});
