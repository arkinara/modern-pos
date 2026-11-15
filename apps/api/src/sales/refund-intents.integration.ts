import 'reflect-metadata';
import assert from 'node:assert/strict';
import { randomUUID } from 'node:crypto';
import { after, test } from 'node:test';
import { HttpException } from '@nestjs/common';
import { PaymentKind, Prisma, PrismaClient, Role } from '@prisma/client';
import type { AuthenticatedUser } from '../auth/auth.types';
import { PaymentsService } from '../payments/payments.service';
import { PaymentConfigService } from '../payments/payment-config.service';
import type { MockPaymentProviderService } from '../payments/mock-payment-provider.service';
import type { QrisPaymentProviderService } from '../payments/qris-payment-provider.service';
import type { PaymentProviderAdapter } from '../payments/payment-provider.types';
import type { PrismaService } from '../prisma/prisma.service';
import { PromotionsService } from '../promotions/promotions.service';
import { SalesService } from './sales.service';

// Explicit opt-in to a disposable, migrated and seeded database. This suite
// never cleans/truncates an arbitrary DATABASE_URL or touches production data.
const url = process.env.REFUND_TEST_DATABASE_URL;
if (!url || !new URL(url).pathname.endsWith('_refund_test')) {
  throw new Error('Set REFUND_TEST_DATABASE_URL to a disposable database ending in _refund_test');
}
const db = new PrismaClient({ datasources: { db: { url } } });
const prisma = db as PrismaService;
after(async () => db.$disconnect());
const outletId = '00000000-0000-4000-8000-000000000002';
const businessId = '00000000-0000-4000-8000-000000000001';
const actor: AuthenticatedUser = {
  id: '00000000-0000-4000-8000-000000000003',
  businessId,
  role: Role.OWNER,
  email: 'owner@example.test',
  outletId,
  outletIds: [outletId],
  sessionId: 'test',
};

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
      if (!effects.refunds.has(input.idempotencyKey))
        effects.refunds.set(input.idempotencyKey, randomUUID());
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
  const deviceId = randomUUID();
  const order = await service.createOrder(
    outletId,
    randomUUID(),
    {
      deviceId,
      lines: [{ variantId: '00000000-0000-4000-8000-000000000042', quantity: 2 }],
    },
    actor,
  );
  const quote = await service.createQuote(outletId, order.id, { orderVersion: 1 }, actor);
  const finalized = await service.finalize(
    outletId,
    randomUUID(),
    {
      deviceId,
      orderId: order.id,
      quoteId: quote.id,
      payment: {
        kind: PaymentKind.CASH,
        amountMinor: quote.totals.totalMinor,
        tenderedMinor: quote.totals.totalMinor,
      },
    },
    actor,
  );
  const saleId = finalized.sale.id;
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
      amountMinor: BigInt(quote.totals.totalMinor),
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
