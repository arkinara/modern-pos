import assert from 'node:assert/strict';
import { test } from 'node:test';
import { PaymentKind, PaymentStatus } from '@prisma/client';
import {
  cashSalesMinorFromTenders,
  discrepancyMinor,
  expectedCashMinor,
  isSettledTender,
} from './cash';
import { decodeCursor, encodeCursor } from './cursor';

test('expected cash arithmetic is opening + cash sales + paid-in - paid-out', () => {
  const expected = expectedCashMinor({
    openingFloatMinor: 100_000n,
    cashSalesMinor: 45_000n,
    paidInMinor: 20_000n,
    paidOutMinor: 15_000n,
  });

  assert.equal(expected, 150_000n);
  assert.equal(100_000n + 45_000n + 20_000n - 15_000n, expected, 'independent hand arithmetic');
});

test('expected cash is negative when paid-outs exceed float, cash sales and paid-ins', () => {
  const expected = expectedCashMinor({
    openingFloatMinor: 100_000n,
    cashSalesMinor: 0n,
    paidInMinor: 0n,
    paidOutMinor: 104_000n,
  });

  assert.equal(expected, -4_000n);
});

test('discrepancy is signed: positive over, negative short, zero matched', () => {
  assert.equal(discrepancyMinor(151_000n, 150_000n), 1_000n);
  assert.equal(discrepancyMinor(149_000n, 150_000n), -1_000n);
  assert.equal(discrepancyMinor(150_000n, 150_000n), 0n);
});

test('cash sales come only from recorded cash tender rows', () => {
  const total = cashSalesMinorFromTenders([
    { kind: PaymentKind.CASH, status: PaymentStatus.RECORDED, amountMinor: 20_000n },
    { kind: PaymentKind.CASH, status: PaymentStatus.RECORDED, amountMinor: 30_000n },
    { kind: PaymentKind.CASH, status: PaymentStatus.REFUNDED, amountMinor: 99_000n },
    { kind: PaymentKind.ONLINE, status: PaymentStatus.SUCCEEDED, amountMinor: 70_000n },
    {
      kind: PaymentKind.MANUAL_EXTERNAL,
      status: PaymentStatus.RECORDED,
      amountMinor: 80_000n,
    },
  ]);

  assert.equal(total, 50_000n);
});

test('online tenders settle only on success or refund states', () => {
  assert.equal(isSettledTender(PaymentKind.ONLINE, PaymentStatus.SUCCEEDED), true);
  assert.equal(isSettledTender(PaymentKind.ONLINE, PaymentStatus.PENDING), false);
  assert.equal(isSettledTender(PaymentKind.CASH, PaymentStatus.RECORDED), true);
  assert.equal(isSettledTender(PaymentKind.CASH, PaymentStatus.REFUNDED), false);
});

test('cursor round-trips and rejects malformed values', () => {
  const at = new Date('2026-11-12T10:00:00.000Z');
  const id = '00000000-0000-4000-8000-000000000001';
  const decoded = decodeCursor(encodeCursor(at, id));

  assert.equal(decoded?.id, id);
  assert.equal(decoded?.at.toISOString(), at.toISOString());
  assert.equal(decodeCursor(undefined), undefined);
  assert.throws(() => decodeCursor('not-a-cursor'));
  assert.throws(() => decodeCursor(Buffer.from('{"at":"x","id":"y"}').toString('base64url')));
});
