import { spawn } from 'node:child_process';
import { randomUUID } from 'node:crypto';
import { writeFileSync } from 'node:fs';

const BASE = process.env.API_BASE ?? 'http://localhost:4110/v1';
const API_PID = Number(process.env.API_PID);
const API_ROOT = process.env.API_ROOT ?? '/home/ubuntu/modern-pos';
const PID_FILE = process.env.API_PID_FILE ?? '/tmp/modern-pos-dev/api30.pid';
const OUTLET = '00000000-0000-4000-8000-000000000002';
const DEVICE = '00000000-0000-4000-8000-000000000091';
const VARIANT = '00000000-0000-4000-8000-000000000042';
const PASSWORD = 'modern-pos-demo-password';
const REQUESTS = Number(process.env.FAILURE_REQUESTS ?? 12);
const CONCURRENCY = Number(process.env.FAILURE_CONCURRENCY ?? 12);

if (!API_PID) throw new Error('API_PID is required');

async function login() {
  const res = await fetch(`${BASE}/auth/mobile/login`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ email: 'cashier@example.test', password: PASSWORD, deviceId: DEVICE }),
  });
  if (!res.ok) throw new Error(`login ${res.status} ${await res.text()}`);
  return (await res.json()).accessToken;
}

async function call(token, method, path, body, headers = {}) {
  const res = await fetch(`${BASE}${path}`, {
    method,
    headers: {
      authorization: `Bearer ${token}`,
      ...(body ? { 'content-type': 'application/json' } : {}),
      ...headers,
    },
    body: body ? JSON.stringify(body) : undefined,
  });
  const text = await res.text();
  let json = null;
  try {
    json = text ? JSON.parse(text) : null;
  } catch {
    json = text;
  }
  return { status: res.status, json };
}

async function waitForHealth(timeoutMs) {
  const started = Date.now();
  while (Date.now() - started < timeoutMs) {
    try {
      const res = await fetch(`${BASE.replace(/\/v1$/, '')}/health`);
      if (res.ok) return true;
    } catch {
      // still down
    }
    await new Promise((resolve) => setTimeout(resolve, 500));
  }
  return false;
}

const token = await login();
const payloads = [];

for (let i = 0; i < REQUESTS; i += 1) {
  const orderKey = randomUUID();
  const finalizeKey = randomUUID();
  const order = await call(
    token,
    'POST',
    `/outlets/${OUTLET}/orders`,
    { deviceId: DEVICE, lines: [{ variantId: VARIANT, quantity: 1 }] },
    { 'Idempotency-Key': orderKey },
  );
  if (order.status !== 201) throw new Error(`order ${order.status} ${JSON.stringify(order.json)}`);
  const quote = await call(token, 'POST', `/outlets/${OUTLET}/orders/${order.json.id}/quotes`, {
    orderVersion: 1,
  });
  if (quote.status !== 201) throw new Error(`quote ${quote.status} ${JSON.stringify(quote.json)}`);
  payloads.push({
    orderId: order.json.id,
    quoteId: quote.json.id,
    finalizeKey,
    totalMinor: quote.json.totals.totalMinor,
  });
}

const inFlight = payloads.map((payload) =>
  call(
    token,
    'POST',
    `/outlets/${OUTLET}/sales/finalize`,
    {
      deviceId: DEVICE,
      orderId: payload.orderId,
      quoteId: payload.quoteId,
      payment: {
        kind: 'CASH',
        amountMinor: payload.totalMinor,
        tenderedMinor: Math.max(50000, payload.totalMinor),
      },
    },
    { 'Idempotency-Key': payload.finalizeKey },
  )
    .then((res) => ({ kind: 'response', ...res }))
    .catch((error) => ({ kind: 'network-error', error: String(error) })),
);

await new Promise((resolve) => setTimeout(resolve, 200));
process.kill(API_PID, 'SIGKILL');
const outcomes = await Promise.all(inFlight);

const killedAt = new Date().toISOString();
await new Promise((resolve) => setTimeout(resolve, 2000));

const child = spawn(process.execPath, ['apps/api/dist/main.js'], {
  cwd: API_ROOT,
  env: {
    ...process.env,
    DATABASE_URL: process.env.DATABASE_URL,
    PORT: process.env.API_PORT ?? '4110',
    WEB_ORIGIN: process.env.WEB_ORIGIN ?? 'http://localhost:3102,http://localhost:3001',
  },
  detached: true,
  stdio: 'ignore',
});
child.unref();
if (child.pid) writeFileSync(PID_FILE, String(child.pid));
const healthy = await waitForHealth(30000);

const resolved = [];
for (const payload of payloads) {
  const recovery = await call(
    token,
    'GET',
    `/outlets/${OUTLET}/checkout-requests/${payload.finalizeKey}?deviceId=${DEVICE}`,
  );

  let action;
  let final;
  if (recovery.status === 200) {
    action = 'committed-before-restart';
    final = await call(
      token,
      'POST',
      `/outlets/${OUTLET}/sales/finalize`,
      {
        deviceId: DEVICE,
        orderId: payload.orderId,
        quoteId: payload.quoteId,
        payment: {
          kind: 'CASH',
          amountMinor: payload.totalMinor,
          tenderedMinor: Math.max(50000, payload.totalMinor),
        },
      },
      { 'Idempotency-Key': payload.finalizeKey },
    );
  } else if (recovery.status === 404) {
    action = 'not-committed-retry-same-key';
    final = await call(
      token,
      'POST',
      `/outlets/${OUTLET}/sales/finalize`,
      {
        deviceId: DEVICE,
        orderId: payload.orderId,
        quoteId: payload.quoteId,
        payment: {
          kind: 'CASH',
          amountMinor: payload.totalMinor,
          tenderedMinor: Math.max(50000, payload.totalMinor),
        },
      },
      { 'Idempotency-Key': payload.finalizeKey },
    );
  } else {
    action = `recovery-${recovery.status}`;
    final = recovery;
  }

  resolved.push({
    finalizeKey: payload.finalizeKey,
    orderId: payload.orderId,
    recoveryStatus: recovery.status,
    action,
    finalStatus: final.status,
    replayed: final.json?.replayed ?? null,
    saleId: final.json?.sale?.id ?? recovery.json?.sale?.id ?? null,
    recoverySaleId: recovery.json?.sale?.id ?? null,
  });
}

const results = {
  killedAt,
  healthyAfterRestart: healthy,
  requests: REQUESTS,
  inFlightOutcomes: outcomes.map((outcome) =>
    outcome.kind === 'response'
      ? { kind: outcome.kind, status: outcome.status }
      : { kind: outcome.kind, error: outcome.error },
  ),
  committedBeforeRestart: resolved.filter((row) => row.recoveryStatus === 200).length,
  notCommittedRetried: resolved.filter((row) => row.recoveryStatus === 404).length,
  finalFailures: resolved.filter((row) => row.finalStatus !== 200).length,
  changedSaleOnReplay: resolved.filter(
    (row) => row.recoverySaleId && row.saleId && row.recoverySaleId !== row.saleId,
  ).length,
  resolved,
};

writeFileSync('/tmp/modern-pos-dev/failure30-result.json', JSON.stringify(results, null, 2));
console.log(JSON.stringify(results, null, 2));
