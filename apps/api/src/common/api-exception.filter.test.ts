import assert from 'node:assert/strict';
import { test } from 'node:test';
import { ArgumentsHost, Logger } from '@nestjs/common';
import { ApiExceptionFilter } from './api-exception.filter';

test('production unexpected-error logs omit secrets, raw exceptions and untrusted request identifiers', (context) => {
  const previous = process.env.NODE_ENV;
  process.env.NODE_ENV = 'production';
  const logs: unknown[][] = [];
  context.mock.method(Logger.prototype, 'error', (...args: unknown[]) => logs.push(args));
  try {
    for (const requestId of [
      'synthetic-secret-in-header',
      '11111111-2222-4333-8444-555555555555',
    ]) {
      let status = 0;
      let body: unknown;
      const response = {
        status: (value: number) => {
          status = value;
          return response;
        },
        json: (value: unknown) => {
          body = value;
        },
        setHeader: () => {},
      };
      const host = {
        switchToHttp: () => ({ getResponse: () => response, getRequest: () => ({ requestId }) }),
      } as unknown as ArgumentsHost;
      new ApiExceptionFilter().catch(
        new Error('postgresql://user:synthetic-password@host/db private-customer-payload'),
        host,
      );
      assert.equal(status, 500);
      assert.equal((body as { code: string }).code, 'INTERNAL_ERROR');
    }
    assert.equal(logs.length, 2);
    assert.ok(!JSON.stringify(logs).includes('synthetic-'));
    assert.ok(!JSON.stringify(logs).includes('private-customer-payload'));
    const record = JSON.parse(String(logs[1]![0])) as {
      event: string;
      requestId: string;
      status: number;
    };
    assert.equal(record.event, 'api_unhandled_error');
    assert.equal(record.status, 500);
    assert.equal(record.requestId, '11111111-2222-4333-8444-555555555555');
  } finally {
    if (previous === undefined) delete process.env.NODE_ENV;
    else process.env.NODE_ENV = previous;
  }
});
