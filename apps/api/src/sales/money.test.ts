import assert from 'node:assert/strict';
import { test } from 'node:test';
import { HttpException } from '@nestjs/common';
import { PaymentKind } from '@prisma/client';
import { calculateTotals, halfUpDiv, normalizePayment, toMinor, toWireMinor } from './money';

function statusOf(error: unknown): number | undefined {
  return error instanceof HttpException ? error.getStatus() : undefined;
}

function codeOf(error: unknown): string | undefined {
  return error instanceof HttpException
    ? (error.getResponse() as { code: string }).code
    : undefined;
}

test('configured service and tax are half-up and tax applies to subtotal plus service', () => {
  const totals = calculateTotals(
    [
      { unitPriceMinor: 18000n, quantity: 2 },
      { unitPriceMinor: 35000n, quantity: 1 },
    ],
    500,
    1100,
  );

  assert.equal(totals.subtotalMinor, 71000n);
  assert.equal(totals.serviceMinor, 3550n);
  assert.equal(totals.taxMinor, 8201n);
  assert.equal(totals.totalMinor, 82751n);
});

test('half-up rounds exact .5 up and below .5 down', () => {
  assert.equal(halfUpDiv(1n * 5000n), 1n);
  assert.equal(halfUpDiv(999n * 5n), 0n);
  assert.equal(halfUpDiv(1000n * 5n), 1n);
  assert.equal(halfUpDiv(15000n), 2n);
});

test('tax is calculated on subtotal plus service', () => {
  const totals = calculateTotals([{ unitPriceMinor: 1000n, quantity: 1 }], 1000, 1000);
  assert.equal(totals.serviceMinor, 100n);
  assert.equal(totals.taxMinor, 110n);
  assert.equal(totals.totalMinor, 1210n);
});

test('money beyond JavaScript safe integer is rejected', () => {
  assert.throws(
    () => calculateTotals([{ unitPriceMinor: 9_007_199_254_740_991n, quantity: 2 }], 0, 0),
    (error: unknown) => statusOf(error) === 422 && codeOf(error) === 'MONEY_OUT_OF_RANGE',
  );

  assert.throws(
    () => toMinor(9_007_199_254_740_992, 'amountMinor'),
    (error: unknown) => statusOf(error) === 422 && codeOf(error) === 'MONEY_OUT_OF_RANGE',
  );

  assert.throws(
    () => toWireMinor(9_007_199_254_740_992n, 'totalMinor'),
    (error: unknown) => statusOf(error) === 500 && codeOf(error) === 'MONEY_OUT_OF_RANGE',
  );
});

test('cash payment requires exact amount, sufficient tender and records change', () => {
  const payment = normalizePayment(82751n, {
    kind: PaymentKind.CASH,
    amountMinor: 82751,
    tenderedMinor: 100000,
  });

  assert.equal(payment.amountMinor, 82751n);
  assert.equal(payment.tenderedMinor, 100000n);
  assert.equal(payment.changeMinor, 17249n);
});

test('cash below total is rejected', () => {
  assert.throws(
    () =>
      normalizePayment(82751n, {
        kind: PaymentKind.CASH,
        amountMinor: 82751,
        tenderedMinor: 80000,
      }),
    (error: unknown) => statusOf(error) === 422 && codeOf(error) === 'PAYMENT_INVALID',
  );
});

test('cash amount must equal the quoted total', () => {
  assert.throws(
    () =>
      normalizePayment(82751n, {
        kind: PaymentKind.CASH,
        amountMinor: 80000,
        tenderedMinor: 100000,
      }),
    (error: unknown) =>
      statusOf(error) === 422 &&
      codeOf(error) === 'PAYMENT_INVALID' &&
      (error instanceof HttpException
        ? (error.getResponse() as { details?: { reason?: string } }).details?.reason
        : undefined) === 'AMOUNT_MISMATCH',
  );
});

test('manual external payment equals total and omits tender and change', () => {
  const payment = normalizePayment(82751n, {
    kind: PaymentKind.MANUAL_EXTERNAL,
    amountMinor: 82751,
    reference: 'TRX-1',
  });

  assert.equal(payment.tenderedMinor, null);
  assert.equal(payment.changeMinor, null);
  assert.equal(payment.reference, 'TRX-1');

  assert.throws(
    () =>
      normalizePayment(82751n, {
        kind: PaymentKind.MANUAL_EXTERNAL,
        amountMinor: 82751,
        tenderedMinor: 90000,
      }),
    (error: unknown) => statusOf(error) === 422 && codeOf(error) === 'PAYMENT_INVALID',
  );
});
