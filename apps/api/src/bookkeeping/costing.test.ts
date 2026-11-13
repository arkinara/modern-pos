import assert from 'node:assert/strict';
import { test } from 'node:test';
import {
  costForQuantityMicros,
  marginBps,
  quantityMicros,
  receiptValueMicros,
  resolveUnitCostMicros,
} from './costing';

test('receipt value converts supplier packs to base units without floats', () => {
  assert.equal(receiptValueMicros('1000', '120000', '1000'), 120_000_000_000n);
  assert.equal(receiptValueMicros('1', '1000', '3'), 333_333_333n);
});

test('moving average weights receipt values by quantity', () => {
  const events = [
    { quantityMicros: quantityMicros('1000'), valueMicros: receiptValueMicros('1000', '100', '1') },
    { quantityMicros: quantityMicros('3000'), valueMicros: receiptValueMicros('3000', '200', '1') },
  ];

  assert.equal(resolveUnitCostMicros('MOVING_AVERAGE', events), 175_000_000n);
});

test('last purchase changes the unit cost predictably', () => {
  const events = [
    { quantityMicros: quantityMicros('1000'), valueMicros: receiptValueMicros('1000', '100', '1') },
    { quantityMicros: quantityMicros('3000'), valueMicros: receiptValueMicros('3000', '200', '1') },
  ];

  assert.equal(resolveUnitCostMicros('LAST_PURCHASE', events), 200_000_000n);
});

test('cost and margin use integer half-up arithmetic', () => {
  assert.equal(costForQuantityMicros(quantityMicros('2'), 175_000_000n), 350n);
  assert.equal(marginBps(1n, 3n), 3333);
  assert.equal(marginBps(-1n, 3n), -3333);
  assert.equal(marginBps(1n, 0n), null);
});
