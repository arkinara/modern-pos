#!/usr/bin/env node
import { randomUUID } from 'node:crypto';

const API_BASE = process.env.API_BASE ?? 'http://localhost:4176';
const OUTLET_ID = process.env.OUTLET_ID ?? '00000000-0000-4000-8000-000000000002';
const DEVICE_ID = process.env.DEVICE_ID ?? '00000000-0000-4000-8000-000000000091';
const CASHIER = {
  email: process.env.CASHIER_EMAIL ?? 'cashier@example.test',
  password: process.env.SEED_PASSWORD ?? 'modern-pos-demo-password',
};
const OWNER = {
  email: process.env.OWNER_EMAIL ?? 'owner@example.test',
  password: process.env.SEED_PASSWORD ?? 'modern-pos-demo-password',
};
const CHICKEN_RICE = '00000000-0000-4000-8000-000000000042';
const TABLE_T1 = '00000000-0000-4000-8000-0000000000e1';
const CHECKOUT_RUNS = Number(process.env.CHECKOUT_RUNS ?? 10);
const REPORT_FROM = process.env.REPORT_FROM ?? '2026-01-01';
const REPORT_TO = process.env.REPORT_TO ?? '2026-11-16';

function now() {
  return Number(process.hrtime.bigint() / 1000n) / 1000;
}

async function request(path, options = {}) {
  const started = now();
  const response = await fetch(`${API_BASE}${path}`, options);
  const text = await response.text();
  const elapsedMs = Number((now() - started).toFixed(1));
  let body = null;
  if (text) {
    try {
      body = JSON.parse(text);
    } catch {
      body = text;
    }
  }
  return { status: response.status, body, elapsedMs };
}

async function login(account) {
  const result = await request('/v1/auth/mobile/login', {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ ...account, deviceId: DEVICE_ID }),
  });
  if (result.status !== 200 || !result.body?.accessToken) {
    throw new Error(`login failed for ${account.email}: ${result.status} ${result.body?.code}`);
  }
  return result.body.accessToken;
}

function auth(token) {
  return { authorization: `Bearer ${token}` };
}

async function createOrder(token, quantity, tableId) {
  const result = await request(`/v1/outlets/${OUTLET_ID}/orders`, {
    method: 'POST',
    headers: { ...auth(token), 'content-type': 'application/json', 'Idempotency-Key': randomUUID() },
    body: JSON.stringify({
      deviceId: DEVICE_ID,
      ...(tableId ? { tableId } : {}),
      lines: [{ variantId: CHICKEN_RICE, quantity }],
    }),
  });
  if (result.status !== 201) {
    throw new Error(`create order failed: ${result.status} ${result.body?.code}`);
  }
  return result.body;
}

async function createQuote(token, order) {
  const result = await request(`/v1/outlets/${OUTLET_ID}/orders/${order.id}/quotes`, {
    method: 'POST',
    headers: { ...auth(token), 'content-type': 'application/json' },
    body: JSON.stringify({ orderVersion: order.version }),
  });
  if (result.status !== 201) {
    throw new Error(`create quote failed: ${result.status} ${result.body?.code}`);
  }
  return result.body;
}

async function finalize(token, order, quote) {
  const key = randomUUID();
  const total = quote.totals.totalMinor;
  const result = await request(`/v1/outlets/${OUTLET_ID}/sales/finalize`, {
    method: 'POST',
    headers: { ...auth(token), 'content-type': 'application/json', 'Idempotency-Key': key },
    body: JSON.stringify({
      deviceId: DEVICE_ID,
      orderId: order.id,
      quoteId: quote.id,
      payment: {
        kind: 'CASH',
        amountMinor: total,
        tenderedMinor: Math.max(total, 50000),
      },
    }),
  });
  if (result.status !== 200) {
    throw new Error(`finalize failed: ${result.status} ${result.body?.code}`);
  }
  return { key, ...result };
}

function stats(values) {
  const sorted = [...values].sort((a, b) => a - b);
  const sum = values.reduce((total, value) => total + value, 0);
  return {
    n: values.length,
    min: sorted[0],
    median: sorted[Math.floor((sorted.length - 1) / 2)],
    mean: Number((sum / values.length).toFixed(1)),
    p95: sorted[Math.min(sorted.length - 1, Math.ceil(sorted.length * 0.95) - 1)],
    max: sorted[sorted.length - 1],
  };
}

function emit(name, value) {
  console.log(JSON.stringify({ scenario: name, synthetic: true, ...value }));
}

const cashierToken = await login(CASHIER);
const ownerToken = await login(OWNER);
emit('login', { cashier: 200, owner: 200, tokenType: 'bearer' });

const menuTimes = [];
let menuItems = 0;
for (let i = 0; i < 5; i += 1) {
  const menu = await request(`/v1/outlets/${OUTLET_ID}/menu`, { headers: auth(cashierToken) });
  if (menu.status !== 200) throw new Error(`menu failed: ${menu.status}`);
  menuTimes.push(menu.elapsedMs);
  menuItems = menu.body.items.length;
}
emit('catalog-search', { requests: menuTimes.length, menuItems, elapsedMs: stats(menuTimes) });

const checkoutTimes = [];
const apiErrors = [];
for (let i = 0; i < CHECKOUT_RUNS; i += 1) {
  const started = now();
  const order = await createOrder(cashierToken, 1);
  const quote = await createQuote(cashierToken, order);
  const sale = await finalize(cashierToken, order, quote);
  checkoutTimes.push(Number((now() - started).toFixed(1)));
  if (sale.status !== 200) apiErrors.push(sale.status);
}
emit('checkout', {
  runs: CHECKOUT_RUNS,
  unexpectedErrors: apiErrors.length,
  elapsedMs: stats(checkoutTimes),
  definition: 'create order + quote + finalize, one Chicken Rice, cash tender',
});

const recoveryOrder = await createOrder(cashierToken, 1);
const recoveryQuote = await createQuote(cashierToken, recoveryOrder);
const recoverySale = await finalize(cashierToken, recoveryOrder, recoveryQuote);
const recovery = await request(
  `/v1/outlets/${OUTLET_ID}/checkout-requests/${recoverySale.key}?deviceId=${DEVICE_ID}`,
  { headers: auth(cashierToken) },
);
const replay = await request(`/v1/outlets/${OUTLET_ID}/sales/finalize`, {
  method: 'POST',
  headers: {
    ...auth(cashierToken),
    'content-type': 'application/json',
    'Idempotency-Key': recoverySale.key,
  },
  body: JSON.stringify({
    deviceId: DEVICE_ID,
    orderId: recoveryOrder.id,
    quoteId: recoveryQuote.id,
    payment: {
      kind: 'CASH',
      amountMinor: recoveryQuote.totals.totalMinor,
      tenderedMinor: 50000,
    },
  }),
});
emit('uncertain-recovery', {
  recoverStatus: recovery.status,
  recoveredReference: recovery.body?.sale?.reference ?? recovery.body?.reference ?? null,
  replayStatus: replay.status,
  replayReference:
    replay.body?.sale?.reference ?? replay.body?.reference ?? null,
  replaySameSale:
    (recovery.body?.sale?.reference ?? recovery.body?.reference) ===
    (replay.body?.sale?.reference ?? replay.body?.reference),
  recoverElapsedMs: recovery.elapsedMs,
  replayElapsedMs: replay.elapsedMs,
});

const tableOrder = await createOrder(cashierToken, 2, TABLE_T1);
const tableQuote = await createQuote(cashierToken, tableOrder);
const splitStarted = now();
const split = await request(`/v1/outlets/${OUTLET_ID}/orders/${tableOrder.id}/splits`, {
  method: 'POST',
  headers: {
    ...auth(cashierToken),
    'content-type': 'application/json',
    'Idempotency-Key': randomUUID(),
  },
  body: JSON.stringify({
    version: tableOrder.version,
    bills: [
      { lines: [{ variantId: CHICKEN_RICE, quantity: 1 }] },
      { lines: [{ variantId: CHICKEN_RICE, quantity: 1 }] },
    ],
  }),
});
if (split.status !== 201) throw new Error(`split failed: ${split.status} ${split.body?.code}`);
const bills = split.body.bills ?? split.body.orders ?? split.body;
const childSales = [];
for (const bill of bills) {
  const childQuote = await createQuote(cashierToken, bill);
  const childSale = await finalize(cashierToken, bill, childQuote);
  childSales.push({
    totalMinor: childQuote.totals.totalMinor,
    reference: childSale.body.sale.reference,
  });
}
emit('table-split', {
  tableOrderId: tableOrder.id,
  splitStatus: split.status,
  splitElapsedMs: Number((now() - splitStarted).toFixed(1)),
  originalTotalMinor: tableQuote.totals.totalMinor,
  childTotalsMinor: childSales.map((sale) => sale.totalMinor),
  childTotalSumMinor: childSales.reduce((total, sale) => total + sale.totalMinor, 0),
  childSales: childSales.length,
});

const stock = await request(`/v1/outlets/${OUTLET_ID}/stock`, { headers: auth(ownerToken) });
if (stock.status !== 200) throw new Error(`stock read failed: ${stock.status}`);
const stockTimes = [stock.elapsedMs];
const countLines = stock.body.items.map((item) => ({
  stockItemId: item.id,
  countedQuantity: item.quantity,
}));
const count = await request(`/v1/outlets/${OUTLET_ID}/stock-counts`, {
  method: 'POST',
  headers: { ...auth(ownerToken), 'content-type': 'application/json' },
  body: JSON.stringify({ reason: 'synthetic operator-pilot exact count', lines: countLines }),
});
if (count.status !== 201) throw new Error(`stock count failed: ${count.status} ${count.body?.code}`);
stockTimes.push(count.elapsedMs);
const movements = await request(
  `/v1/outlets/${OUTLET_ID}/stock/${stock.body.items[0].id}/movements`,
  { headers: auth(ownerToken) },
);
emit('owner-stock', {
  stockStatus: stock.status,
  countStatus: count.status,
  countedLines: countLines.length,
  countVariance:
    count.body.lines?.filter((line) => line.variance !== '0' && line.variance !== 0).length ?? 0,
  elapsedMs: stats(stockTimes),
  movementStatus: movements.status,
});

const sales = await request(
  `/v1/outlets/${OUTLET_ID}/sales?from=${REPORT_FROM}&to=${REPORT_TO}`,
  { headers: auth(ownerToken) },
);
const report = await request(
  `/v1/outlets/${OUTLET_ID}/reports/daily?from=${REPORT_FROM}&to=${REPORT_TO}`,
  { headers: auth(ownerToken) },
);
emit('owner-sales-report', {
  salesStatus: sales.status,
  salesRows: sales.body.items?.length ?? 0,
  reportStatus: report.status,
  reportSaleCount: report.body?.saleCount ?? null,
  reportGrossItemSalesMinor: report.body?.grossItemSalesMinor ?? null,
  salesElapsedMs: sales.elapsedMs,
  reportElapsedMs: report.elapsedMs,
});

emit('observation-limits', {
  humanMistakes: null,
  supportFriction: null,
  note: 'Scripted API walkthrough has no human participant; no mistake or support-friction value is observed.',
});
