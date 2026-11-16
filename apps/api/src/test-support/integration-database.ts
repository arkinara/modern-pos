type Environment = Readonly<Record<string, string | undefined>>;

export function integrationDatabaseUrl(env: Environment = process.env): string {
  const value = env.TRANSACTION_TEST_DATABASE_URL ?? env.REFUND_TEST_DATABASE_URL;
  if (!value) throw new Error('Set TRANSACTION_TEST_DATABASE_URL to an isolated test database');
  let url: URL;
  try {
    url = new URL(value);
  } catch {
    throw new Error('Integration database URL is invalid');
  }
  if (
    !['postgres:', 'postgresql:'].includes(url.protocol) ||
    !/_(transaction|refund)_test$/.test(url.pathname) ||
    env.NODE_ENV?.trim().toLowerCase() === 'production'
  ) {
    throw new Error(
      'Integration tests require an explicitly named disposable PostgreSQL test database',
    );
  }
  if (env.DATABASE_URL && env.DATABASE_URL !== value) {
    throw new Error('DATABASE_URL and the integration test database URL must match');
  }
  return value;
}
