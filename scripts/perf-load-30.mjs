import { randomUUID } from 'node:crypto';
import { writeFileSync } from 'node:fs';

const BASE = process.env.API_BASE ?? 'http://localhost:4110/v1';
const LABEL = process.argv[2] ?? 'run';
const OUTLET = '00000000-0000-4000-8000-000000000002';
const DEVICE = '00000000-0000-4000-8000-000000000091';
const VARIANT = '00000000-0000-4000-8000-000000000042';
const PASSWORD = 'modern-pos-demo-password';
const SALES_CONCURRENCY = Number(process.env.SALES_CONCURRENCY ?? 6);
const SALES_TOTAL = Number(process.env.SALES_TOTAL ?? 40);
const REPORT_REQUESTS = Number(process.env.REPORT_REQUESTS ?? 20);
const REPORT_CONCURRENCY = Number(process.env.REPORT_CONCURRENCY ?? 4);
const RECOVERY_REQUESTS = Number(process.env.RECOVERY_REQUESTS ?? 20);
const RECOVERY_CONCURRENCY = Number(process.env.RECOVERY_CONCURRENCY ?? 4);
const PRINT_REQUESTS = Number(process.env.PRINT_REQUESTS ?? 20);
const PRINT_CONCURRENCY = Number(process.env.PRINT_CONCURRENCY ?? 4);

async function login(email) {
  const res = await fetch(`${BASE}/auth/mobile/login`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ email, password: PASSWORD, deviceId: DEVICE }),
  });
  if (!res.ok) throw new Error(`login ${email} -> ${res.status} ${await res.text()}`);
  return (await res.json()).accessToken;
}

function percentile(values, p) {
  if (values.length === 0) return null;
  const sorted = [...values].sort((a, b) => a - b);
  const index = Math.min(sorted.length - 1, Math.ceil((p / 100) * sorted.length) - 1);
  return sorted[index];
}

function summary(values, errors) {
  return {
    n: values.length,
    errorCount: errors,
    p50Ms: percentile(values, 50),
    p95Ms: percentile(values, 95),
    maxMs: values.length ? Math.max(...values) : null,
    meanMs: values.length
      ? Number((values.reduce((a, b) => a + b, 0) / values.length).toFixed(2))
      : null,
  };
}

async function call(token, method, path, body, headers = {}) {
  const started = performance.now();
  const res = await fetch(`${BASE}${path}`, {
    method,
    headers: {
      authorization: `Bearer ${token}`,
      ...(body ? { 'content-type': 'application/json' } : {}),
      ...headers,
    },
    body: body ? JSON.stringify(body) : undefined,
  });
  const elapsed = performance.now() - started;
  const text = await res.text();
  let json = null;
  try {
    json = text ? JSON.parse(text) : null;
  } catch {
    json = text;
  }
  return { status: res.status, json, elapsed };
}

async function runPool(items, concurrency, worker) {
  let index = 0;
  const results = new Array(items.length);
  async function next() {
    while (true) {
      const current = index++;
      if (current >= items.length) return;
      results[current] = await worker(items[current], current);
    }
  }
  await Promise.all(Array.from({ length: Math.min(concurrency, items.length) }, next));
  return results;
}

function ranges(total, size) {
  return Array.from({ length: Math.ceil(total / size) }, (_, i) => ({
    start: i * size,
    count: Math.min(size, total - i * size),
  }));
}

const cashier = await login('cashier@example.test');
const owner = await login('owner@example.test');

const completed = [];
const saleErrors = [];
const finalizeTimes = [];
const checkoutTimes = [];
const saleStarted = performance.now();

for (const range of ranges(SALES_TOTAL, SALES_CONCURRENCY)) {
  const indices = Array.from({ length: range.count }, (_, i) => range.start + i);
  const batch = await runPool(indices, SALES_CONCURRENCY, async (i) => {
    const orderKey = randomUUID();
    const finalizeKey = randomUUID();
    const flowStart = performance.now();
    try {
      const order = await call(
        cashier,
        'POST',
        `/outlets/${OUTLET}/orders`,
        { deviceId: DEVICE, lines: [{ variantId: VARIANT, quantity: 1 }] },
        { 'Idempotency-Key': orderKey },
      );
      if (order.status !== 201)
        throw new Error(`order ${order.status} ${JSON.stringify(order.json)}`);

      const quote = await call(
        cashier,
        'POST',
        `/outlets/${OUTLET}/orders/${order.json.id}/quotes`,
        {
          orderVersion: 1,
        },
      );
      if (quote.status !== 201)
        throw new Error(`quote ${quote.status} ${JSON.stringify(quote.json)}`);

      const finalize = await call(
        cashier,
        'POST',
        `/outlets/${OUTLET}/sales/finalize`,
        {
          deviceId: DEVICE,
          orderId: order.json.id,
          quoteId: quote.json.id,
          payment: {
            kind: 'CASH',
            amountMinor: quote.json.totals.totalMinor,
            tenderedMinor: 50000,
          },
        },
        { 'Idempotency-Key': finalizeKey },
      );
      const flowElapsed = performance.now() - flowStart;
      checkoutTimes.push(flowElapsed);
      finalizeTimes.push(finalize.elapsed);
      if (finalize.status !== 200) {
        throw new Error(`finalize ${finalize.status} ${JSON.stringify(finalize.json)}`);
      }
      completed.push({
        saleId: finalize.json.sale.id,
        finalizeKey,
        orderId: order.json.id,
        quoteId: quote.json.id,
        totalMinor: finalize.json.sale.totals.totalMinor,
        reference: finalize.json.sale.reference,
      });
      return { ok: true, i };
    } catch (error) {
      saleErrors.push(String(error));
      return { ok: false, i };
    }
  });
  void batch;
}
const saleWallMs = performance.now() - saleStarted;

const reportTimes = [];
const reportErrors = [];
const reportQueries = Array.from(
  { length: REPORT_REQUESTS },
  (_, i) => `/outlets/${OUTLET}/reports/daily?from=2026-01-01&to=2026-12-31`,
);
await runPool(reportQueries, REPORT_CONCURRENCY, async (path) => {
  const res = await call(owner, 'GET', path);
  reportTimes.push(res.elapsed);
  if (res.status !== 200) reportErrors.push(`${res.status} ${JSON.stringify(res.json)}`);
});

const recoveryTimes = [];
const recoveryErrors = [];
const recoveryItems = completed.slice(0, RECOVERY_REQUESTS);
await runPool(recoveryItems, RECOVERY_CONCURRENCY, async (item) => {
  const res = await call(
    cashier,
    'GET',
    `/outlets/${OUTLET}/checkout-requests/${item.finalizeKey}?deviceId=${DEVICE}`,
  );
  recoveryTimes.push(res.elapsed);
  if (res.status !== 200) recoveryErrors.push(`${res.status} ${JSON.stringify(res.json)}`);
});

const printer = await call(owner, 'POST', `/outlets/${OUTLET}/printers`, {
  deviceId: DEVICE,
  name: `Load test printer ${LABEL}`,
  model: 'Synthetic 80mm',
  transport: 'LAN',
  paperWidthMm: 80,
  encoding: 'ESC_POS',
  connectionSettings: { host: '127.0.0.1', port: '9100' },
});
let printerId = printer.status === 201 ? printer.json.id : null;
if (!printerId && printer.status === 409) {
  const list = await call(owner, 'GET', `/outlets/${OUTLET}/printers?deviceId=${DEVICE}`);
  printerId = (list.json ?? []).find((p) => p.name === `Load test printer ${LABEL}`)?.id ?? null;
}
if (!printerId) throw new Error(`printer setup ${printer.status} ${JSON.stringify(printer.json)}`);

const printTimes = [];
const printErrors = [];
const printItems = completed.slice(0, PRINT_REQUESTS);
await runPool(printItems, PRINT_CONCURRENCY, async (item) => {
  const res = await call(
    cashier,
    'POST',
    `/outlets/${OUTLET}/print-jobs`,
    {
      id: randomUUID(),
      saleId: item.saleId,
      deviceId: DEVICE,
      printerConfigId: printerId,
      copy: false,
    },
    { 'Idempotency-Key': randomUUID() },
  );
  printTimes.push(res.elapsed);
  if (res.status !== 201) printErrors.push(`${res.status} ${JSON.stringify(res.json)}`);
});

const replayTimes = [];
const replayErrors = [];
const replayItems = completed.slice(0, Math.min(10, completed.length));
await runPool(replayItems, 4, async (item) => {
  const res = await call(
    cashier,
    'POST',
    `/outlets/${OUTLET}/sales/finalize`,
    {
      deviceId: DEVICE,
      orderId: item.orderId,
      quoteId: item.quoteId,
      payment: { kind: 'CASH', amountMinor: item.totalMinor, tenderedMinor: 50000 },
    },
    { 'Idempotency-Key': item.finalizeKey },
  );
  replayTimes.push(res.elapsed);
  if (res.status !== 200 || res.json?.replayed !== true || res.json?.sale?.id !== item.saleId) {
    replayErrors.push(`${res.status} ${JSON.stringify(res.json)}`);
  }
});

const result = {
  label: LABEL,
  base: BASE,
  configuration: {
    salesTotal: SALES_TOTAL,
    salesConcurrency: SALES_CONCURRENCY,
    reportRequests: REPORT_REQUESTS,
    reportConcurrency: REPORT_CONCURRENCY,
    recoveryRequests: RECOVERY_REQUESTS,
    recoveryConcurrency: RECOVERY_CONCURRENCY,
    printRequests: PRINT_REQUESTS,
    printConcurrency: PRINT_CONCURRENCY,
  },
  sales: {
    completed: completed.length,
    attempted: SALES_TOTAL,
    errors: saleErrors,
    wallMs: Number(saleWallMs.toFixed(1)),
    throughputPerSecond: Number((completed.length / (saleWallMs / 1000)).toFixed(2)),
    finalize: summary(finalizeTimes, saleErrors.length),
    checkoutFlow: summary(checkoutTimes, saleErrors.length),
  },
  reports: summary(reportTimes, reportErrors.length),
  reportErrorSamples: reportErrors.slice(0, 3),
  recovery: summary(recoveryTimes, recoveryErrors.length),
  recoveryErrorSamples: recoveryErrors.slice(0, 3),
  printEnqueue: summary(printTimes, printErrors.length),
  printErrorSamples: printErrors.slice(0, 3),
  replay: {
    ...summary(replayTimes, replayErrors.length),
    replayedRequests: replayItems.length,
    uniqueSaleIds: new Set(replayItems.map((item) => item.saleId)).size,
    errorSamples: replayErrors.slice(0, 3),
  },
};

const file = `/tmp/modern-pos-dev/load30-${LABEL}.json`;
writeFileSync(file, JSON.stringify(result, null, 2));
console.log(JSON.stringify(result, null, 2));
console.error(`wrote ${file}`);
