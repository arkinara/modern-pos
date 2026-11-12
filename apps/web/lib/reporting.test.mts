import assert from 'node:assert/strict';
import { test } from 'node:test';
import { formatMoney } from './reporting.ts';

test('back-office money rendering keeps negative expected cash signed', () => {
  const negative = formatMoney(-4_000, 'IDR', 0);
  const positive = formatMoney(4_000, 'IDR', 0);

  assert.notEqual(negative, positive);
  assert.match(negative, /[-−]/);
  assert.match(negative, /4/);
});
