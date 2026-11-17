import 'reflect-metadata';
import assert from 'node:assert/strict';
import { randomUUID } from 'node:crypto';
import { after, test } from 'node:test';
import { Module } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { PaymentKind, PrismaClient } from '@prisma/client';
import { ApiExceptionFilter } from '../common/api-exception.filter';
import { PrismaService } from '../prisma/prisma.service';
import { PromotionsService } from '../promotions/promotions.service';
import { SalesService } from '../sales/sales.service';
import { integrationDatabaseUrl } from '../test-support/integration-database';
import {
  actor,
  outletId,
  createTrackedFixture,
  prepareCheckout,
} from '../test-support/transaction-fixture';
import { MockPaymentProviderService } from './mock-payment-provider.service';
import { PaymentConfigService } from './payment-config.service';
import { PaymentWebhookController } from './payments.controller';
import { PaymentsService } from './payments.service';
import { QrisPaymentProviderService } from './qris-payment-provider.service';
import { signWebhookPayload } from './webhook-signature';

const databaseUrl = integrationDatabaseUrl();
process.env.NODE_ENV = 'test';
process.env.PAYMENT_PROVIDER = 'mock';
process.env.PAYMENT_MODE = 'sandbox';
process.env.PAYMENT_SANDBOX_ENABLED = 'true';
process.env.PAYMENT_WEBHOOK_SECRET = 'synthetic-lifecycle-secret-for-local-tests';
const db = new PrismaClient({ datasources: { db: { url: databaseUrl } } });
const prisma = db as PrismaService;
after(() => db.$disconnect());

function services() {
  const config = new PaymentConfigService();
  const provider = new MockPaymentProviderService(prisma, config);
  const payments = new PaymentsService(
    prisma,
    config,
    provider,
    new QrisPaymentProviderService(config),
  );
  return {
    provider,
    payments,
    sales: new SalesService(prisma, new PromotionsService(prisma), payments),
  };
}

async function onlineSale() {
  const h = services();
  const fixture = await createTrackedFixture(db);
  const checkout = await prepareCheckout(h.sales, fixture.variantId);
  const finalized = await h.sales.finalize(
    outletId,
    checkout.key,
    {
      ...checkout.dto,
      payment: { kind: PaymentKind.ONLINE, amountMinor: checkout.dto.payment.amountMinor },
    },
    actor,
  );
  const saleId = finalized.sale.id;
  const payment = await h.payments.schedule(outletId, saleId, actor);
  assert.ok(payment.providerRef);
  const line = await db.saleLine.findFirstOrThrow({ where: { saleId } });
  return { ...h, fixture, saleId, payment, line };
}

test('mock lifecycle: raw-body HTTP signatures, concurrent duplicate delivery and terminal ordering', async () => {
  const h = await onlineSale();
  const replay = await h.payments.schedule(outletId, h.saleId, actor);
  assert.equal(replay.providerRef, h.payment.providerRef);
  assert.equal(
    await db.sandboxProviderPayment.count({ where: { providerRef: replay.providerRef! } }),
    1,
  );

  // tsx does not emit constructor metadata. Match the compiled controller's injection metadata.
  Reflect.defineMetadata('design:paramtypes', [PaymentsService], PaymentWebhookController);
  @Module({
    controllers: [PaymentWebhookController],
    providers: [{ provide: PaymentsService, useValue: h.payments }],
  })
  class WebhookTestModule {}
  const app = await NestFactory.create(WebhookTestModule, { rawBody: true, logger: false });
  app.useGlobalFilters(new ApiExceptionFilter());
  await app.listen(0, '127.0.0.1');
  try {
    const url = `${await app.getUrl()}/payments/webhook`;
    const event = await h.provider.createEvent(h.payment.providerRef!, 'payment.succeeded');
    const deliver = (body: string, signature: string) =>
      fetch(url, {
        method: 'POST',
        headers: { 'content-type': 'application/json', 'x-payment-signature': signature },
        body,
      });
    const signature = `t=${event.timestamp},v1=${event.signature}`;
    assert.equal((await deliver(event.rawBody + ' ', signature)).status, 401);
    const staleTime = event.timestamp - 3600;
    const stale = signWebhookPayload(process.env.PAYMENT_WEBHOOK_SECRET!, staleTime, event.rawBody);
    assert.equal((await deliver(event.rawBody, `t=${staleTime},v1=${stale}`)).status, 401);
    assert.equal(
      await db.paymentWebhookEvent.count({ where: { eventId: String(event.event.id) } }),
      0,
    );
    const responses = await Promise.all(
      Array.from({ length: 3 }, () => deliver(event.rawBody, signature)),
    );
    assert.deepEqual(
      responses.map((response) => response.status),
      [200, 200, 200],
    );
    const acks = (await Promise.all(responses.map((response) => response.json()))) as {
      duplicate: boolean;
    }[];
    assert.equal(acks.filter((ack) => !ack.duplicate).length, 1);
    assert.equal(
      await db.paymentWebhookEvent.count({ where: { eventId: String(event.event.id) } }),
      1,
    );
    for (const type of ['payment.pending', 'payment.failed'] as const) {
      const late = await h.provider.createEvent(h.payment.providerRef!, type);
      const response = await deliver(late.rawBody, `t=${late.timestamp},v1=${late.signature}`);
      assert.equal(response.status, 200);
      assert.equal(((await response.json()) as { status: string }).status, 'SUCCEEDED');
    }
    assert.equal(
      (await db.paymentRecord.findUniqueOrThrow({ where: { saleId: h.saleId } })).status,
      'SUCCEEDED',
    );
    console.log(
      JSON.stringify({
        scenario: 'signed-mock-webhook',
        saleId: h.saleId,
        providerRef: h.payment.providerRef,
        eventId: event.event.id,
        outcome: 'passed',
      }),
    );
  } finally {
    await app.close();
  }
});

test('mock lifecycle: lost webhook reconciles after fresh service instances', async () => {
  const h = await onlineSale();
  await h.provider.createEvent(h.payment.providerRef!, 'payment.succeeded');
  assert.equal((await h.payments.getForSale(outletId, h.saleId, actor)).status, 'PENDING');
  const restarted = services();
  assert.equal((await restarted.payments.refresh(outletId, h.saleId, actor)).status, 'SUCCEEDED');
  assert.equal((await restarted.provider.fetchPayment(h.payment.providerRef!)).status, 'SUCCEEDED');
});

test('mock lifecycle: failed payment retry gets a new provider reference and old events stay harmless', async () => {
  const h = await onlineSale();
  const failed = await h.provider.createEvent(h.payment.providerRef!, 'payment.failed');
  await h.payments.handleWebhook(`t=${failed.timestamp},v1=${failed.signature}`, failed.rawBody);
  const retry = await h.payments.schedule(outletId, h.saleId, actor);
  assert.notEqual(retry.providerRef, h.payment.providerRef);
  const duplicate = await h.payments.handleWebhook(
    `t=${failed.timestamp},v1=${failed.signature}`,
    failed.rawBody,
  );
  assert.equal(duplicate.duplicate, true);
  assert.equal((await h.payments.getForSale(outletId, h.saleId, actor)).status, 'PENDING');
  await h.provider.createEvent(retry.providerRef!, 'payment.succeeded');
  assert.equal((await services().payments.refresh(outletId, h.saleId, actor)).status, 'SUCCEEDED');
});

test('mock lifecycle: lost refund response replays the persisted provider key after restart', async () => {
  const h = await onlineSale();
  await h.provider.createEvent(h.payment.providerRef!, 'payment.succeeded');
  await h.payments.refresh(outletId, h.saleId, actor);
  const original = h.provider.refundPayment.bind(h.provider);
  h.provider.refundPayment = async (input) => {
    await original(input);
    throw new Error('injected response loss after provider commit');
  };
  const key = randomUUID();
  const refund = {
    reason: 'Synthetic lost response',
    refundMinor: 1000,
    lines: [{ saleLineId: h.line.id, quantity: 1 }],
    restock: [],
  };
  await assert.rejects(
    () => h.sales.reverse(outletId, h.saleId, key, refund, actor),
    /injected response loss/,
  );
  assert.equal(
    (
      await db.refundIntent.findUniqueOrThrow({
        where: {
          outletId_idempotencyKey: { outletId, idempotencyKey: key },
        },
      })
    ).state,
    'UNKNOWN',
  );
  await services().sales.reverse(outletId, h.saleId, key, refund, actor);
  const ledger = await db.sandboxProviderPayment.findUniqueOrThrow({
    where: { providerRef: h.payment.providerRef! },
  });
  assert.equal(ledger.refundedMinor, 1000n);
  assert.equal((ledger.refundKeys as string[]).length, 1);
  assert.equal(await db.saleReversal.count({ where: { saleId: h.saleId } }), 1);
});

test('mock lifecycle: real provider ledger survives local refund failure, partial/full refunds reconcile', async () => {
  const h = await onlineSale();
  await h.provider.createEvent(h.payment.providerRef!, 'payment.succeeded');
  await h.payments.refresh(outletId, h.saleId, actor);
  const key = randomUUID();
  const refund = {
    reason: 'Synthetic lifecycle acceptance',
    refundMinor: 1000,
    lines: [{ saleLineId: h.line.id, quantity: 1 }],
    restock: [{ stockItemId: h.fixture.stockItemId, quantity: '3' }],
  };
  h.payments.applyReversalRefund = async () => {
    throw new Error('injected local commit failure');
  };
  await assert.rejects(
    () => h.sales.reverse(outletId, h.saleId, key, refund, actor),
    /injected local commit failure/,
  );
  const provider = await db.sandboxProviderPayment.findUniqueOrThrow({
    where: { providerRef: h.payment.providerRef! },
  });
  assert.equal(provider.refundedMinor, 1000n);
  assert.equal(await db.saleReversal.count({ where: { saleId: h.saleId } }), 0);
  const restarted = services();
  const first = await restarted.sales.reverse(outletId, h.saleId, key, refund, actor);
  assert.equal(
    (await restarted.sales.reverse(outletId, h.saleId, key, refund, actor)).id,
    first.id,
  );
  assert.equal(
    (await restarted.payments.getForSale(outletId, h.saleId, actor)).status,
    'PARTIALLY_REFUNDED',
  );
  await restarted.sales.reverse(outletId, h.saleId, randomUUID(), refund, actor);
  const local = await restarted.payments.getForSale(outletId, h.saleId, actor);
  const ledger = await db.sandboxProviderPayment.findUniqueOrThrow({ where: { id: provider.id } });
  const reversals = await db.saleReversal.aggregate({
    where: { saleId: h.saleId },
    _sum: { refundMinor: true },
  });
  assert.equal(local.status, 'REFUNDED');
  assert.equal(BigInt(local.refundedMinor), ledger.refundedMinor);
  assert.equal(reversals._sum.refundMinor, ledger.refundedMinor);
  assert.equal(ledger.refundedMinor, ledger.amountMinor);
  assert.equal((ledger.refundKeys as string[]).length, 2);
  assert.equal(await db.refundIntent.count({ where: { saleId: h.saleId, state: 'COMPLETED' } }), 2);
  assert.equal(
    (
      await db.stockBalance.findUniqueOrThrow({
        where: {
          outletId_stockItemId: { outletId, stockItemId: h.fixture.stockItemId },
        },
      })
    ).quantity.toString(),
    '12',
  );
  console.log(
    JSON.stringify({
      scenario: 'mock-refund-reconciliation',
      saleId: h.saleId,
      providerRef: ledger.providerRef,
      capturedMinor: ledger.amountMinor.toString(),
      refundedMinor: ledger.refundedMinor.toString(),
      unexplainedDriftMinor: '0',
      outcome: 'passed',
    }),
  );
});
