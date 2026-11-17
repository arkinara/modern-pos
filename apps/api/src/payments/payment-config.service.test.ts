import assert from 'node:assert/strict';
import { afterEach, test } from 'node:test';
import { PaymentProvider } from '@prisma/client';
import { HttpException } from '@nestjs/common';
import { PaymentConfigService } from './payment-config.service';

const KEYS = [
  'NODE_ENV',
  'PAYMENT_MODE',
  'PAYMENT_SANDBOX_ENABLED',
  'PAYMENT_PROVIDER',
  'PAYMENT_PROVIDER_BASE_URL',
  'PAYMENT_PROVIDER_API_KEY',
  'PAYMENT_WEBHOOK_SECRET',
  'PAYMENT_WEBHOOK_REPLAY_SECONDS',
];

const saved = new Map<string, string | undefined>();

function setEnv(values: Record<string, string | undefined>): void {
  for (const key of KEYS) {
    if (!saved.has(key)) {
      saved.set(key, process.env[key]);
    }
    const value = values[key];
    if (value === undefined) {
      delete process.env[key];
    } else {
      process.env[key] = value;
    }
  }
}

afterEach(() => {
  for (const [key, value] of saved) {
    if (value === undefined) {
      delete process.env[key];
    } else {
      process.env[key] = value;
    }
  }
  saved.clear();
});

test('local mock provider requires explicit opt-in and no live credentials', () => {
  setEnv({ PAYMENT_PROVIDER: undefined, PAYMENT_SANDBOX_ENABLED: 'true' });
  const config = new PaymentConfigService();

  assert.equal(config.provider, PaymentProvider.MOCK);
  assert.equal(config.describe().provider, 'MOCK');
  assert.equal(config.describe().liveSandboxVerified, false);
});

test('manual-only recording disables automatic provider selection, webhooks and refunds', () => {
  setEnv({
    NODE_ENV: 'production',
    PAYMENT_PROVIDER: 'manual',
    PAYMENT_PROVIDER_API_KEY: 'synthetic-stale-provider-key',
    PAYMENT_WEBHOOK_SECRET: 'synthetic-stale-webhook-secret',
    PAYMENT_PROVIDER_BASE_URL: 'https://provider.example.test',
  });
  const config = new PaymentConfigService();
  assert.equal(config.describe().provider, 'MANUAL');
  assert.equal(config.sandboxEnabled, false);
  for (const operation of [
    () => config.provider,
    () => config.requireWebhookSecret(),
    () => config.requireQrisCredentials(),
  ]) {
    assert.throws(
      operation,
      (error: unknown) =>
        error instanceof HttpException &&
        (error.getResponse() as { code: string }).code === 'ONLINE_PAYMENTS_DISABLED',
    );
  }
});

test('mock selection without opt-in fails closed and production cannot select MOCK', () => {
  for (const env of [
    { PAYMENT_PROVIDER: 'mock' },
    { NODE_ENV: 'production', PAYMENT_PROVIDER: 'mock', PAYMENT_SANDBOX_ENABLED: 'true' },
    { NODE_ENV: 'production', PAYMENT_SANDBOX_ENABLED: 'true' },
  ]) {
    setEnv(env);
    assert.throws(
      () => new PaymentConfigService().provider,
      (error: unknown) => error instanceof HttpException && error.getStatus() === 503,
    );
    assert.equal(new PaymentConfigService().sandboxEnabled, false);
  }
});

test('qris is selected only with complete configuration', () => {
  setEnv({
    PAYMENT_PROVIDER: 'qris',
    PAYMENT_PROVIDER_BASE_URL: 'https://sandbox.example.test',
    PAYMENT_PROVIDER_API_KEY: 'fake-unit-test-key',
    PAYMENT_WEBHOOK_SECRET: 'fake-unit-test-secret',
  });
  const config = new PaymentConfigService();

  assert.equal(config.provider, PaymentProvider.QRIS);
  assert.equal(config.describe().apiKeyConfigured, true);
  assert.equal(config.describe().webhookSecretConfigured, true);
});

test('missing qris credentials fail closed', () => {
  setEnv({ PAYMENT_PROVIDER: 'qris', PAYMENT_PROVIDER_BASE_URL: undefined });
  const config = new PaymentConfigService();

  assert.throws(
    () => config.requireQrisCredentials(),
    (error: unknown) =>
      error instanceof HttpException &&
      (error.getResponse() as { code: string }).code === 'PROVIDER_NOT_CONFIGURED',
  );
});

test('configuration dumps never contain secret values', () => {
  const apiKey = 'fake-unit-test-api-key-do-not-log';
  const secret = 'fake-unit-test-webhook-secret-do-not-log';
  setEnv({
    PAYMENT_PROVIDER: 'qris',
    PAYMENT_PROVIDER_BASE_URL: 'https://sandbox.example.test',
    PAYMENT_PROVIDER_API_KEY: apiKey,
    PAYMENT_WEBHOOK_SECRET: secret,
  });
  const config = new PaymentConfigService();
  const dump = JSON.stringify(config.describe());

  assert.doesNotMatch(dump, new RegExp(apiKey));
  assert.doesNotMatch(dump, new RegExp(secret));
  assert.match(dump, /"apiKeyConfigured":true/);
});

test('an unknown provider is rejected instead of silently falling back', () => {
  setEnv({ PAYMENT_PROVIDER: 'paypal' });
  const config = new PaymentConfigService();

  assert.throws(
    () => config.provider,
    (error: unknown) =>
      error instanceof HttpException &&
      (error.getResponse() as { code: string }).code === 'PAYMENT_PROVIDER_INVALID',
  );
});
