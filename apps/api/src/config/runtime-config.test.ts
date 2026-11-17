import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { afterEach, test } from 'node:test';
import { parse } from 'dotenv';
import { type INestApplication } from '@nestjs/common';
import { loadAuthConfig } from '../auth/auth.config';
import { bootstrap } from '../main';
import {
  RuntimeConfigurationError,
  sandboxPaymentsEnabled,
  validateRuntimeConfig,
} from './runtime-config';

const safe = {
  NODE_ENV: 'production',
  JWT_SECRET: '769f2c1a0d84eb35c9164f2b8a0e731d',
  COOKIE_SECURE: 'true',
  WEB_ORIGIN: 'https://office.example.test,https://owner.example.test',
  PAYMENT_PROVIDER: 'qris',
  PAYMENT_MODE: 'sandbox',
  PAYMENT_SANDBOX_ENABLED: 'false',
  PAYMENT_PROVIDER_BASE_URL: 'https://provider.example.test/api',
  PAYMENT_PROVIDER_API_KEY: 'a1b2c3d4e5f60789',
  PAYMENT_WEBHOOK_SECRET: 'f0927e4a16bc8530d2fa8e7c19046b3d',
};
const keys = [...Object.keys(safe), 'CHANNEL_WEBHOOK_SECRET'];
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

test('production accepts explicit HTTPS origins, secure cookies and non-mock payment mode', () => {
  for (const PAYMENT_MODE of ['sandbox', 'live']) {
    assert.deepEqual(validateRuntimeConfig({ ...safe, PAYMENT_MODE }).allowedOrigins, [
      'https://office.example.test',
      'https://owner.example.test',
    ]);
  }
  setEnv({ ...safe, COOKIE_SECURE: ' TRUE ' });
  assert.equal(loadAuthConfig().cookieSecure, true);
  assert.equal(sandboxPaymentsEnabled(), false);
});

for (const key of [
  'JWT_SECRET',
  'COOKIE_SECURE',
  'WEB_ORIGIN',
  'PAYMENT_PROVIDER',
  'PAYMENT_MODE',
  'PAYMENT_PROVIDER_BASE_URL',
  'PAYMENT_PROVIDER_API_KEY',
  'PAYMENT_WEBHOOK_SECRET',
]) {
  test(`production rejects missing ${key} before constructing Nest or opening a listener`, async () => {
    setEnv({ ...safe, [key]: undefined });
    let calls = 0;
    await assert.rejects(
      () =>
        bootstrap(async () => {
          calls++;
          throw new Error('must not construct');
        }),
      (error: unknown) => error instanceof RuntimeConfigurationError && error.message.includes(key),
    );
    assert.equal(calls, 0);
  });
}

test('production rejects placeholder secrets, insecure cookies and malformed origins without reflecting their values', () => {
  const invalid: Record<string, string[]> = {
    JWT_SECRET: [
      'modern-pos-local-development-secret',
      'changeme'.repeat(8),
      'x'.repeat(64),
      'short',
    ],
    COOKIE_SECURE: ['false', '0', 'yes', ''],
    WEB_ORIGIN: [
      '*',
      'null',
      'http://owner.example.test',
      'https://*.example.test',
      'https://user:secret@owner.example.test',
      'https://owner.example.test/path',
      'https://owner.example.test?token=DO-NOT-LOG',
      'https://owner.example.test#fragment',
      'https://owner.example.test,',
      'not-an-origin',
    ],
    PAYMENT_PROVIDER: ['mock', 'unknown', ''],
    PAYMENT_MODE: ['unknown', ''],
    PAYMENT_SANDBOX_ENABLED: ['true', '1', 'yes'],
    PAYMENT_PROVIDER_BASE_URL: [
      'http://provider.example.test',
      'https://user:password@provider.example.test',
    ],
    PAYMENT_PROVIDER_API_KEY: ['placeholder-provider-api-key', '<insert-api-key>'],
    PAYMENT_WEBHOOK_SECRET: [
      'modern-pos-local-payment-secret',
      'replace-me-with-a-long-secret-123456789',
    ],
    CHANNEL_WEBHOOK_SECRET: ['modern-pos-local-channel-secret'],
  };
  for (const [key, values] of Object.entries(invalid)) {
    for (const value of values) {
      assert.throws(
        () => validateRuntimeConfig({ ...safe, [key]: value }),
        (error: unknown) => {
          assert.ok(error instanceof RuntimeConfigurationError);
          assert.ok(error.message.includes(key));
          assert.ok(
            !value || !error.message.includes(value),
            'configuration value must not appear in diagnostics',
          );
          return true;
        },
      );
    }
  }
});

test('a local mock provider requires opt-in and a sandbox mode; unknown runtime names fail closed', () => {
  assert.throws(() => validateRuntimeConfig({}), RuntimeConfigurationError);
  assert.throws(
    () => validateRuntimeConfig({ NODE_ENV: 'staging', PAYMENT_SANDBOX_ENABLED: 'true' }),
    RuntimeConfigurationError,
  );
  for (const NODE_ENV of ['development', 'test']) {
    assert.deepEqual(
      validateRuntimeConfig({
        NODE_ENV,
        PAYMENT_PROVIDER: 'mock',
        PAYMENT_SANDBOX_ENABLED: 'true',
      }),
      { allowedOrigins: [] },
    );
    assert.equal(
      sandboxPaymentsEnabled({
        NODE_ENV,
        PAYMENT_PROVIDER: 'mock',
        PAYMENT_SANDBOX_ENABLED: 'true',
      }),
      true,
    );
    assert.throws(
      () =>
        validateRuntimeConfig({
          NODE_ENV,
          PAYMENT_PROVIDER: 'mock',
          PAYMENT_MODE: 'live',
          PAYMENT_SANDBOX_ENABLED: 'true',
        }),
      RuntimeConfigurationError,
    );
  }
});

test('safe bootstrap configures the exact credentialed origin allowlist and retains request validation', async () => {
  setEnv(safe);
  const calls: Record<string, unknown[]> = {};
  const app = Object.fromEntries(
    [
      'use',
      'useGlobalPipes',
      'useGlobalFilters',
      'setGlobalPrefix',
      'enableCors',
      'enableShutdownHooks',
      'listen',
    ].map((name) => [
      name,
      (...args: unknown[]) => {
        calls[name] = args;
      },
    ]),
  ) as unknown as INestApplication;
  await bootstrap(async () => app);
  assert.deepEqual(calls.enableCors, [
    {
      origin: ['https://office.example.test', 'https://owner.example.test'],
      credentials: true,
      exposedHeaders: ['Content-Disposition'],
    },
  ]);
  assert.ok(calls.useGlobalPipes);
  assert.ok(calls.useGlobalFilters);
  assert.ok(calls.use);
  assert.ok(calls.listen);
});

test('auth config also rejects unsafe production values when loaded outside bootstrap', () => {
  setEnv({ ...safe, JWT_SECRET: 'modern-pos-local-development-secret' });
  assert.throws(() => loadAuthConfig(), RuntimeConfigurationError);
});

test('committed environment example enables reproducible local development without production credentials', () => {
  const example = parse(readFileSync(resolve(__dirname, '../../.env.example')));
  const config = validateRuntimeConfig(example);
  assert.deepEqual(config.allowedOrigins, ['http://localhost:3000', 'http://localhost:3001']);
  assert.equal(sandboxPaymentsEnabled(example), true);
  setEnv(example);
  assert.equal(loadAuthConfig().cookieSecure, false);
});
