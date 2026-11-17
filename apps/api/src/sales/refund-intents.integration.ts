import 'reflect-metadata';
import assert from 'node:assert/strict';
import { randomUUID } from 'node:crypto';
import { after, test } from 'node:test';
import { HttpException } from '@nestjs/common';
import { Prisma, PrismaClient } from '@prisma/client';
import { PaymentsService } from '../payments/payments.service';
import { PaymentConfigService } from '../payments/payment-config.service';
import type { MockPaymentProviderService } from '../payments/mock-payment-provider.service';
import type { QrisPaymentProviderService } from '../payments/qris-payment-provider.service';
import type { PaymentProviderAdapter } from '../payments/payment-provider.types';
import type { PrismaService } from '../prisma/prisma.service';
import { PromotionsService } from '../promotions/promotions.service';
import { SalesService } from './sales.service';
import { integrationDatabaseUrl } from '../test-support/integration-database';
import {
  actor,
  businessId,
  createTrackedFixture,
  outletId,
  prepareCheckout,
} from '../test-support/transaction-fixture';

// Explicit opt-in to a disposable, migrated and seeded database. This suite
// never cleans/truncates an arbitrary DATABASE_URL or touches production data.
const url = integrationDatabaseUrl();
const db = new PrismaClient({ datasources: { db: { url } } });
const prisma = db as PrismaService;
const fixtureSales: string[] = [];
let providerEffects = 0;
after(async () => {
  const [reversals, intents] = await Promise.all([
    db.saleReversal.count({ where: { saleId: { in: fixtureSales } } }),
    db.refundIntent.count({ where: { saleId: { in: fixtureSales } } }),
  ]);
  console.log(`Refund effects ${JSON.stringify({ providerEffects, reversals, intents })}`);
  await db.$disconnect();
});

function code(error: unknown) {
  return error instanceof HttpException
    ? (error.getResponse() as { code: string }).code
    : undefined;
}

async function harness() {
  const effects = {
    calls: 0,
    refunds: new Map<string, string>(),
    localFailure: false,
    loseResponse: false,
    entered: undefined as (() => void) | undefined,
    release: undefined as Promise<void> | undefined,
  };
  const adapter: PaymentProviderAdapter = {
    name: 'MOCK',
    createPayment: async () => {
      throw new Error('not used');
    },
    fetchPayment: async () => {
      throw new Error('not used');
    },
    refundPayment: async (input) => {
      effects.calls++;
      // Separate database connection observes the committed reservation while
      // provider I/O is in flight; the sales transaction cannot still own it.
      const intent = await db.refundIntent.findUniqueOrThrow({
        where: { providerKey: input.idempotencyKey },
      });
      assert.equal(intent.refundMinor, input.amountMinor);
      effects.entered?.();
      await effects.release;
      if (!effects.refunds.has(input.idempotencyKey)) {
        effects.refunds.set(input.idempotencyKey, randomUUID());
        providerEffects++;
      }
      if (effects.loseResponse) throw new Error('injected provider response loss');
      return {
        providerRef: effects.refunds.get(input.idempotencyKey)!,
        refundedMinor: input.amountMinor,
        status: 'SUCCEEDED',
      };
    },
  };
  const payments = new PaymentsService(
    prisma,
    new PaymentConfigService(),
    adapter as unknown as MockPaymentProviderService,
    adapter as unknown as QrisPaymentProviderService,
  );
  const apply = payments.applyReversalRefund.bind(payments);
  payments.applyReversalRefund = async (...args) => {
    if (effects.localFailure) throw new Error('injected local database failure');
    return apply(...args);
  };
  const service = new SalesService(prisma, new PromotionsService(prisma), payments);
  const fixture = await createTrackedFixture(db);
  const checkout = await prepareCheckout(service, fixture.variantId);
  const finalized = await service.finalize(outletId, checkout.key, checkout.dto, actor);
  const saleId = finalized.sale.id;
  fixtureSales.push(saleId);
  await db.paymentRecord.update({
    where: { saleId },
    data: { kind: 'ONLINE', status: 'SUCCEEDED' },
  });
  await db.onlinePayment.create({
    data: {
      businessId,
      outletId,
      saleId,
      provider: 'MOCK',
      providerRef: randomUUID(),
      status: 'SUCCEEDED',
      amountMinor: BigInt(checkout.dto.payment.amountMinor),
      currency: 'IDR',
      currencyExponent: 0,
    },
  });
  const line = await db.saleLine.findFirstOrThrow({ where: { saleId } });
  // Derive an actual consumed ingredient from the pinned sale recipe.
  const recipe = await db.recipeVersion.findFirstOrThrow({
    where: { outletId, variantId: line.variantId, version: line.recipeVersion! },
    include: { lines: true },
  });
  const ingredient = recipe.lines[0]!;
  const dto = {
    reason: 'Integration refund',
    refundMinor: 1000,
    lines: [{ saleLineId: line.id, quantity: 1 }],
    restock: [
      { stockItemId: ingredient.stockItemId, quantity: ingredient.quantityPerSaleUnit.toString() },
    ],
  };
  const reverse = (key: string, payload = dto) =>
    service.reverse(outletId, saleId, key, payload, actor);
  const restarted = () => new SalesService(prisma, new PromotionsService(prisma), payments);
  return { service, effects, dto, reverse, saleId, restarted };
}

test('PostgreSQL: distinct-key requests cannot reserve overlapping money, line or restock capacity', async () => {
  const h = await harness();
  let enter!: () => void;
  const entered = new Promise<void>((resolve) => {
    enter = resolve;
  });
  let release!: () => void;
  h.effects.entered = enter;
  h.effects.release = new Promise<void>((resolve) => {
    release = resolve;
  });
  const key = randomUUID();
  const winner = h.reverse(key);
  await entered;
  try {
    const competitors = await Promise.allSettled(
      Array.from({ length: 4 }, () => h.reverse(randomUUID())),
    );
    assert.equal(competitors.filter((r) => r.status === 'fulfilled').length, 0);
    for (const r of competitors)
      if (r.status === 'rejected') assert.equal(code(r.reason), 'REFUND_IN_PROGRESS');
    assert.equal(h.effects.calls, 1);
    assert.equal(await db.refundIntent.count({ where: { saleId: h.saleId } }), 1);
    assert.equal(await db.saleReversal.count({ where: { saleId: h.saleId } }), 0);
    const active = await db.refundIntent.findFirstOrThrow({ where: { saleId: h.saleId } });
    const { id: _id, createdAt: _created, updatedAt: _updated, ...copy } = active;
    await assert.rejects(
      () =>
        db.refundIntent.create({
          data: {
            ...copy,
            lines: copy.lines ?? Prisma.JsonNull,
            restock: copy.restock ?? Prisma.JsonNull,
            idempotencyKey: randomUUID(),
            providerKey: randomUUID(),
          },
        }),
      (e: unknown) => typeof e === 'object' && e !== null && 'code' in e && e.code === 'P2002',
    );
  } finally {
    release();
  }
  await winner;
  assert.equal(await db.saleReversal.count({ where: { saleId: h.saleId } }), 1);
  assert.equal(
    (await db.onlinePayment.findUniqueOrThrow({ where: { saleId: h.saleId } })).refundedMinor,
    1000n,
  );
});

test('PostgreSQL: concurrent same-key requests create one reversal, payment correction and restock set', async () => {
  const h = await harness();
  const key = randomUUID();
  const results = await Promise.all(Array.from({ length: 4 }, () => h.reverse(key)));
  assert.equal(new Set(results.map((r) => r.id)).size, 1);
  assert.equal(h.effects.refunds.size, 1);
  assert.equal(await db.saleReversal.count({ where: { saleId: h.saleId } }), 1);
  assert.equal(await db.saleRefundLine.count({ where: { reversalId: results[0]!.id } }), 1);
  assert.equal(
    await db.stockMovement.count({ where: { sourceId: results[0]!.id, type: 'REVERSAL' } }),
    1,
  );
  assert.equal(
    (await db.onlinePayment.findUniqueOrThrow({ where: { saleId: h.saleId } })).refundedMinor,
    1000n,
  );
});

test('PostgreSQL: provider success/local failure rolls back every local effect and restart completes once', async () => {
  const h = await harness();
  const key = randomUUID();
  h.effects.localFailure = true;
  await assert.rejects(() => h.reverse(key), /injected local database failure/);
  const intent = await db.refundIntent.findUniqueOrThrow({
    where: { outletId_idempotencyKey: { outletId, idempotencyKey: key } },
  });
  assert.equal(intent.state, 'SUCCEEDED');
  assert.equal(await db.saleReversal.count({ where: { saleId: h.saleId } }), 0);
  assert.equal(
    (await db.onlinePayment.findUniqueOrThrow({ where: { saleId: h.saleId } })).refundedMinor,
    0n,
  );
  h.effects.localFailure = false;
  const result = await h.restarted().reverse(outletId, h.saleId, key, h.dto, actor);
  const replay = await h.reverse(key);
  assert.equal(replay.id, result.id);
  assert.equal(h.effects.calls, 1);
  assert.equal(
    await db.stockMovement.count({ where: { sourceId: result.id, type: 'REVERSAL' } }),
    1,
  );
  assert.equal(
    (await db.refundIntent.findUniqueOrThrow({ where: { id: intent.id } })).state,
    'COMPLETED',
  );
});

test('PostgreSQL: ambiguous provider outcome survives restart; payload changes are refused', async () => {
  const h = await harness();
  const key = randomUUID();
  h.effects.loseResponse = true;
  await assert.rejects(() => h.reverse(key), /provider response loss/);
  assert.equal(
    (
      await db.refundIntent.findUniqueOrThrow({
        where: { outletId_idempotencyKey: { outletId, idempotencyKey: key } },
      })
    ).state,
    'UNKNOWN',
  );
  await assert.rejects(
    () => h.reverse(key, { ...h.dto, refundMinor: 999 }),
    (e: unknown) => code(e) === 'IDEMPOTENCY_CONFLICT',
  );
  await assert.rejects(
    () => h.reverse(randomUUID()),
    (e: unknown) => code(e) === 'REFUND_IN_PROGRESS',
  );
  h.effects.loseResponse = false;
  await h.restarted().reverse(outletId, h.saleId, key, h.dto, actor);
  assert.equal(h.effects.refunds.size, 1);
  assert.equal(await db.saleReversal.count({ where: { saleId: h.saleId } }), 1);
});

test('PostgreSQL: completed partial refunds enforce remaining money, lines and restock before further I/O', async () => {
  const h = await harness();
  await h.reverse(randomUUID());
  const sale = await db.sale.findUniqueOrThrow({ where: { id: h.saleId } });
  const invalid = [
    { ...h.dto, refundMinor: Number(sale.totalMinor) },
    { ...h.dto, lines: [{ ...h.dto.lines[0]!, quantity: 2 }] },
    {
      ...h.dto,
      restock: [{ ...h.dto.restock[0]!, quantity: String(Number(h.dto.restock[0]!.quantity) * 2) }],
    },
  ];
  for (const dto of invalid) await assert.rejects(() => h.reverse(randomUUID(), dto));
  assert.equal(h.effects.calls, 1);
  await h.reverse(randomUUID(), { ...h.dto, refundMinor: Number(sale.totalMinor) - 1000 });
  assert.equal(h.effects.refunds.size, 2);
  assert.equal(
    (await db.onlinePayment.findUniqueOrThrow({ where: { saleId: h.saleId } })).refundedMinor,
    sale.totalMinor,
  );
  assert.equal(await db.saleReversal.count({ where: { saleId: h.saleId } }), 2);
});

test('PostgreSQL: a full online refund preserves FULL kind and exhausts refundable capacity', async () => {
  const h = await harness();
  const key = randomUUID();
  const full = { reason: 'Full refund', restock: [] };
  const result = await h.service.reverse(outletId, h.saleId, key, full, actor);
  assert.equal(result.kind, 'FULL');
  const replay = await h.service.reverse(outletId, h.saleId, key, full, actor);
  assert.equal(replay.id, result.id);
  await assert.rejects(
    () => h.reverse(randomUUID()),
    (e: unknown) => code(e) === 'SALE_ALREADY_REVERSED',
  );
  assert.equal(h.effects.calls, 1);
  const payment = await db.onlinePayment.findUniqueOrThrow({ where: { saleId: h.saleId } });
  assert.equal(payment.refundedMinor, payment.amountMinor);
  assert.equal(payment.status, 'REFUNDED');
});

test('PostgreSQL: invalid refund payloads create no intent, reversal or provider effect', async (t) => {
  const h = await harness();
  for (const payload of [
    { ...h.dto, lines: [{ saleLineId: randomUUID(), quantity: 1 }] },
    { ...h.dto, lines: [{ ...h.dto.lines[0]!, quantity: 3 }] },
    { ...h.dto, refundMinor: 1000000 },
    { ...h.dto, restock: [{ stockItemId: randomUUID(), quantity: '1' }] },
    { ...h.dto, restock: [{ ...h.dto.restock[0]!, quantity: '7' }] },
  ])
    await assert.rejects(() => h.reverse(randomUUID(), payload));
  const intents = await db.refundIntent.count({ where: { saleId: h.saleId } });
  const reversals = await db.saleReversal.count({ where: { saleId: h.saleId } });
  assert.equal(intents, 0);
  assert.equal(reversals, 0);
  assert.equal(h.effects.calls, 0);
  assert.equal(
    (await db.onlinePayment.findUniqueOrThrow({ where: { saleId: h.saleId } })).refundedMinor,
    0n,
  );
  t.diagnostic(
    JSON.stringify({ invalidRequests: 5, intents, reversals, providerCalls: h.effects.calls }),
  );
});
