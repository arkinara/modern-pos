import assert from 'node:assert/strict';
import { test } from 'node:test';
import { HttpException } from '@nestjs/common';
import { addDays, localDateRangeUtc, parseDateOnly, startOfDayUtc } from './outlet-time';

test('outlet-local midnight converts to UTC for the configured timezone', () => {
  const start = startOfDayUtc(parseDateOnly('2026-01-01'), 'Asia/Jakarta');
  assert.equal(start.toISOString(), '2025-12-31T17:00:00.000Z');
});

test('date ranges are half-open in outlet-local time', () => {
  const range = localDateRangeUtc('2026-01-01', '2026-01-01', 'Asia/Jakarta');
  assert.equal(range.gte?.toISOString(), '2025-12-31T17:00:00.000Z');
  assert.equal(range.lt?.toISOString(), '2026-01-01T17:00:00.000Z');
});

test('DST transitions use the offset at local midnight', () => {
  const spring = startOfDayUtc(parseDateOnly('2026-03-08'), 'America/New_York');
  const next = startOfDayUtc(parseDateOnly('2026-03-09'), 'America/New_York');
  assert.equal(spring.toISOString(), '2026-03-08T05:00:00.000Z');
  assert.equal(next.toISOString(), '2026-03-09T04:00:00.000Z');
});

test('addDays crosses month and year boundaries', () => {
  assert.deepEqual(addDays(parseDateOnly('2026-12-31'), 1), {
    year: 2027,
    month: 1,
    day: 1,
  });
});

test('invalid dates are rejected', () => {
  assert.throws(
    () => parseDateOnly('2026-02-30'),
    (error: unknown) => error instanceof HttpException && error.getStatus() === 400,
  );
  assert.throws(
    () => localDateRangeUtc('2026-02-02', '2026-02-01', 'Asia/Jakarta'),
    (error: unknown) => error instanceof HttpException && error.getStatus() === 400,
  );
});
