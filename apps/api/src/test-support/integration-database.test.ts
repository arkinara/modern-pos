import assert from 'node:assert/strict';
import { test } from 'node:test';
import { integrationDatabaseUrl } from './integration-database';

const url = 'postgresql://synthetic:synthetic@localhost:5432/pos_transaction_test';
test('integration target requires explicit opt-in and a PostgreSQL test database name', () => {
  assert.throws(() => integrationDatabaseUrl({}));
  for (const value of [
    'invalid',
    'https://localhost/pos_transaction_test',
    'postgresql://localhost/production',
  ]) {
    assert.throws(() => integrationDatabaseUrl({ TRANSACTION_TEST_DATABASE_URL: value }));
  }
  assert.equal(
    integrationDatabaseUrl({ TRANSACTION_TEST_DATABASE_URL: url, DATABASE_URL: url }),
    url,
  );
});

test('integration target rejects production mode and migration/test target mismatches without leaking credentials', () => {
  for (const env of [
    { TRANSACTION_TEST_DATABASE_URL: url, NODE_ENV: 'production' },
    {
      TRANSACTION_TEST_DATABASE_URL: url,
      DATABASE_URL: 'postgresql://secret:secret@localhost/other',
    },
  ]) {
    assert.throws(
      () => integrationDatabaseUrl(env),
      (error: unknown) => {
        assert.ok(error instanceof Error);
        assert.doesNotMatch(error.message, /synthetic:synthetic|secret:secret/);
        return true;
      },
    );
  }
});

test('standalone refund suite retains its explicit test URL entry point', () => {
  const refundUrl = url.replace('_transaction_test', '_refund_test');
  assert.equal(integrationDatabaseUrl({ REFUND_TEST_DATABASE_URL: refundUrl }), refundUrl);
});
