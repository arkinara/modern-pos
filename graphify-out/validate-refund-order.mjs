import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { stripTypeScriptTypes } from 'node:module';

// Execute unchanged service methods with isolated database/provider boundaries.
// This is a control-flow reproduction, not a live provider/database test.
const source = readFileSync('apps/api/src/sales/sales.service.ts', 'utf8');
const between = (start, end) => source.slice(source.indexOf(start), source.indexOf(end));
const methods = between('  async reverse(', '  private normalizeReason(') +
  between('  private async applyReversal(', '  private sumPriorRestock(');
const javascript = stripTypeScriptTypes(`class Probe { ${methods} }`) + '; return Probe;';
const apiError = (status, code, message) => Object.assign(new Error(message), { status, code });
const Probe = new Function('requireIdempotencyKey', 'requestHash', 'PaymentKind',
  'Prisma', 'SaleState', 'SaleReversalKind', 'ApprovalAction', 'apiError',
  'toWireMinor', 'isUniqueViolation', javascript)(
  value => value, JSON.stringify, { ONLINE: 'ONLINE' },
  { TransactionIsolationLevel: { Serializable: 'Serializable' } },
  { COMPLETED: 'COMPLETED' }, { FULL: 'FULL' }, { REFUND: 'REFUND' }, apiError,
  Number, () => false,
);
const calls = [];
const sale = { id: 'sale', orderId: 'order', totalMinor: 1000n,
  payment: { kind: 'ONLINE' }, state: 'COMPLETED', lines: [{ id: 'sold-line', quantity: 1 }] };
const tx = {
  $queryRaw: async () => [],
  sale: { findFirst: async () => sale },
  saleReversal: { findMany: async () => [] },
};
const probe = new Probe();
Object.assign(probe, {
  prisma: { sale: tx.sale, saleReversal: { findUnique: async () => null },
    $transaction: async callback => { calls.push('database transaction'); return callback(tx); } },
  normalizeReason: value => value,
  normalizeRestock: value => value,
  normalizeRefundLines: value => value,
  assertApproval: async () => {},
  requirePayments: () => ({ refundForReversal: async () => {
    calls.push('provider refund accepted');
    return { performed: true, providerRefundRef: 'refund-1' };
  } }),
  runSerializable: callback => callback(),
});
await assert.rejects(
  probe.reverse('outlet', 'sale', 'key', {
    reason: 'Return item', restock: [], refundMinor: 500,
    lines: [{ saleLineId: 'line-not-in-this-sale', quantity: 1 }],
  }, { id: 'owner', businessId: 'business' }),
  error => { calls.push(`API rejected: ${error.code}`); return error.code === 'REFUND_LINE_NOT_FOUND'; },
);
assert.deepEqual(calls, ['provider refund accepted', 'database transaction', 'API rejected: REFUND_LINE_NOT_FOUND']);
console.log(JSON.stringify({ result: 'REPRODUCED', boundary: 'source methods with mocked I/O', calls }, null, 2));
