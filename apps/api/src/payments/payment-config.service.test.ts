import assert from 'node:assert/strict';
import { afterEach, test } from 'node:test';
import { PaymentProvider } from '@prisma/client';
import { HttpException } from '@nestjs/common';
import { PaymentConfigService } from './payment-config.service';

const KEYS = [
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

test('mock provider is the default and requires no live credentials', () => {
  setEnv({ PAYMENT_PROVIDER: undefined });
  const config = new PaymentConfigService();

  assert.equal(config.provider, PaymentProvider.MOCK);
  assert.equal(config.describe().provider, 'MOCK');
  assert.equal(config.describe().liveSandboxVerified, false);
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
