import assert from 'node:assert/strict';
import { test } from 'node:test';
import { HttpException } from '@nestjs/common';
import { SignInRateLimiter } from './sign-in-rate-limiter.service';
import { testAuthConfig } from './test-support';

test('sign-in rate limiter blocks after the configured number of failures', () => {
  const limiter = new SignInRateLimiter(
    testAuthConfig({ signInMaxAttempts: 3, signInWindowSeconds: 60 }),
  );
  const key = '127.0.0.1:user@example.test';

  limiter.assertAllowed(key);
  limiter.recordFailure(key);
  limiter.recordFailure(key);
  limiter.recordFailure(key);

  assert.throws(
    () => limiter.assertAllowed(key),
    (error: unknown) =>
      error instanceof HttpException &&
      error.getStatus() === 429 &&
      (error.getResponse() as { code: string }).code === 'RATE_LIMITED',
  );
});

test('a successful sign-in resets the limiter', () => {
  const limiter = new SignInRateLimiter(
    testAuthConfig({ signInMaxAttempts: 2, signInWindowSeconds: 60 }),
  );
  const key = '127.0.0.1:user@example.test';

  limiter.recordFailure(key);
  limiter.recordFailure(key);
  assert.throws(() => limiter.assertAllowed(key), HttpException);

  limiter.reset(key);
  assert.doesNotThrow(() => limiter.assertAllowed(key));
});
