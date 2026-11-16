import 'reflect-metadata';
import assert from 'node:assert/strict';
import { randomUUID } from 'node:crypto';
import { execFileSync } from 'node:child_process';
import { resolve } from 'node:path';
import { after, test } from 'node:test';
import { HttpException } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';
import type { PrismaService } from '../prisma/prisma.service';
import { PromotionsService } from '../promotions/promotions.service';
import { PurchasingService } from '../purchasing/purchasing.service';
import { integrationDatabaseUrl } from '../test-support/integration-database';
import {
  actor,
  createTrackedFixture,
  destinationOutletId,
  outletId,
  prepareCheckout,
} from '../test-support/transaction-fixture';
import { SalesService } from './sales.service';

const url = integrationDatabaseUrl();
const db = new PrismaClient({ datasources: { db: { url } } });
const prisma = db as PrismaService;
const sales = new SalesService(prisma, new PromotionsService(prisma));
after(async () => db.$disconnect());

function code(error: unknown): string | undefined {
  return error instanceof HttpException
    ? (error.getResponse() as { code?: string }).code
    : undefined;
}

async function effects(stockItemId: string, orderIds: string[]) {
  const orders = await db.order.findMany({
    where: { id: { in: orderIds } },
    select: { deviceId: true },
  });
  const [saleCount, paymentCount, reservationCount, movements, balance] = await Promise.all([
    db.sale.count({ where: { orderId: { in: orderIds } } }),
    db.paymentRecord.count({ where: { sale: { orderId: { in: orderIds } } } }),
    db.checkoutRequest.count({
      where: { deviceId: { in: orders.map((order) => order.deviceId) } },
    }),
    db.stockMovement.findMany({ where: { stockItemId, type: 'SALE' } }),
    db.stockBalance.findUniqueOrThrow({
      where: { outletId_stockItemId: { outletId, stockItemId } },
    }),
  ]);
  const ledger = await db.stockMovement.aggregate({
    where: { outletId, stockItemId },
    _sum: { delta: true },
  });
  assert.equal(balance.quantity.toString(), ledger._sum.delta!.toString());
  return {
    saleCount,
    paymentCount,
    reservationCount,
    saleMovements: movements.length,
    consumed: movements.reduce((sum, movement) => sum - Number(movement.delta), 0),
    balance: balance.quantity.toString(),
  };
}

test(
  'PostgreSQL checkout: concurrent distinct keys cannot oversell',
  { timeout: 30000 },
  async (t) => {
    const fixture = await createTrackedFixture(db, '6');
    const checkouts = await Promise.all([
      prepareCheckout(sales, fixture.variantId),
      prepareCheckout(sales, fixture.variantId),
    ]);
    const results = await Promise.allSettled(
      checkouts.map(({ key, dto }) => sales.finalize(outletId, key, dto, actor)),
    );
    assert.equal(results.filter((r) => r.status === 'fulfilled').length, 1);
    const rejected = results.find((r) => r.status === 'rejected');
    assert.ok(rejected?.status === 'rejected');
    assert.equal(code(rejected.reason), 'INSUFFICIENT_STOCK');
    const counts = await effects(
      fixture.stockItemId,
      checkouts.map((c) => c.dto.orderId),
    );
    assert.deepEqual(counts, {
      saleCount: 1,
      paymentCount: 1,
      reservationCount: 1,
      saleMovements: 1,
      consumed: 6,
      balance: '0',
    });
    t.diagnostic(JSON.stringify(counts));
  },
);

test(
  'PostgreSQL checkout: a late database failure rolls back sale, payment, stock and reservation',
  { timeout: 30000 },
  async (t) => {
    const fixture = await createTrackedFixture(db, '6');
    const checkout = await prepareCheckout(sales, fixture.variantId);
    const name = `fail_finalize_${randomUUID().replace(/-/g, '')}`;
    // The trigger raises after finalize has written sale/payment/stock. All real
    // PostgreSQL writes must roll back together. Identifiers are generated here.
    await db.$executeRawUnsafe(`CREATE FUNCTION ${name}() RETURNS trigger LANGUAGE plpgsql AS $$
    BEGIN
      IF NEW."orderId" = '${checkout.dto.orderId}'::uuid AND NEW.action = 'FINALIZE' THEN
        RAISE EXCEPTION 'injected finalize failure';
      END IF;
      RETURN NEW;
    END $$`);
    try {
      await db.$executeRawUnsafe(
        `CREATE TRIGGER ${name} BEFORE INSERT ON order_audits FOR EACH ROW EXECUTE FUNCTION ${name}()`,
      );
      await assert.rejects(
        () => sales.finalize(outletId, checkout.key, checkout.dto, actor),
        /injected finalize failure/,
      );
      const counts = await effects(fixture.stockItemId, [checkout.dto.orderId]);
      assert.deepEqual(counts, {
        saleCount: 0,
        paymentCount: 0,
        reservationCount: 0,
        saleMovements: 0,
        consumed: 0,
        balance: '6',
      });
      assert.equal(
        (await db.order.findUniqueOrThrow({ where: { id: checkout.dto.orderId } })).state,
        'DRAFT',
      );
      t.diagnostic(JSON.stringify(counts));
    } finally {
      await db.$executeRawUnsafe(`DROP TRIGGER IF EXISTS ${name} ON order_audits`);
      await db.$executeRawUnsafe(`DROP FUNCTION ${name}()`);
    }
    await sales.finalize(outletId, checkout.key, checkout.dto, actor);
    assert.equal((await effects(fixture.stockItemId, [checkout.dto.orderId])).saleCount, 1);
  },
);

test(
  'PostgreSQL checkout: concurrent duplicate keys commit exactly one sale and stock effect',
  { timeout: 30000 },
  async (t) => {
    const fixture = await createTrackedFixture(db, '6');
    const checkout = await prepareCheckout(sales, fixture.variantId);
    const results = await Promise.all(
      Array.from({ length: 4 }, () => sales.finalize(outletId, checkout.key, checkout.dto, actor)),
    );
    assert.equal(new Set(results.map((r) => r.sale.id)).size, 1);
    const counts = await effects(fixture.stockItemId, [checkout.dto.orderId]);
    assert.deepEqual(counts, {
      saleCount: 1,
      paymentCount: 1,
      reservationCount: 1,
      saleMovements: 1,
      consumed: 6,
      balance: '0',
    });
    await assert.rejects(
      () =>
        sales.finalize(
          outletId,
          checkout.key,
          {
            ...checkout.dto,
            payment: {
              ...checkout.dto.payment,
              tenderedMinor: checkout.dto.payment.tenderedMinor + 1,
            },
          },
          actor,
        ),
      (error: unknown) => code(error) === 'IDEMPOTENCY_CONFLICT',
    );
    t.diagnostic(JSON.stringify(counts));
  },
);

test(
  'PostgreSQL checkout: a lost response recovers in a fresh process without another effect',
  { timeout: 30000 },
  async (t) => {
    const fixture = await createTrackedFixture(db, '6');
    const checkout = await prepareCheckout(sales, fixture.variantId);
    await assert.rejects(async () => {
      await sales.finalize(outletId, checkout.key, checkout.dto, actor);
      throw new Error('simulated response timeout after commit');
    }, /response timeout/);
    const output = execFileSync(
      process.execPath,
      ['--import', 'tsx', resolve('src/test-support/checkout-recovery-worker.ts')],
      {
        encoding: 'utf8',
        timeout: 15000,
        windowsHide: true,
        env: { ...process.env, CHECKOUT_RECOVERY_INPUT: JSON.stringify(checkout) },
      },
    );
    const recovered = JSON.parse(output) as {
      recoveredId: string;
      replayId: string;
      replayed: boolean;
    };
    assert.equal(recovered.replayId, recovered.recoveredId);
    assert.equal(recovered.replayed, true);
    const counts = await effects(fixture.stockItemId, [checkout.dto.orderId]);
    assert.deepEqual(counts, {
      saleCount: 1,
      paymentCount: 1,
      reservationCount: 1,
      saleMovements: 1,
      consumed: 6,
      balance: '0',
    });
    t.diagnostic(JSON.stringify({ ...counts, recoveryProcess: 'fresh' }));
  },
);

test(
  'PostgreSQL transfer: concurrent receive and later replay create one destination movement',
  { timeout: 30000 },
  async (t) => {
    const fixture = await createTrackedFixture(db, '10');
    const purchasing = new PurchasingService(prisma);
    const transfer = await purchasing.createTransfer(
      outletId,
      {
        destinationOutletId,
        reason: 'Synthetic transfer',
        lines: [{ stockItemId: fixture.stockItemId, quantity: '4' }],
      },
      actor,
    );
    await purchasing.dispatchTransfer(outletId, transfer.id, actor);
    const dto = { lines: [{ lineId: transfer.lines[0]!.id, quantity: '4' }] };
    const results = await Promise.allSettled(
      Array.from({ length: 4 }, () =>
        purchasing.receiveTransfer(destinationOutletId, transfer.id, dto, actor),
      ),
    );
    assert.equal(results.filter((r) => r.status === 'fulfilled').length, 1);
    for (const r of results)
      if (r.status === 'rejected') assert.equal(code(r.reason), 'TRANSFER_ALREADY_RECEIVED');
    await assert.rejects(
      () => purchasing.receiveTransfer(destinationOutletId, transfer.id, dto, actor),
      (error: unknown) => code(error) === 'TRANSFER_ALREADY_RECEIVED',
    );
    const movements = await db.stockMovement.findMany({ where: { transferId: transfer.id } });
    assert.equal(movements.filter((r) => r.type === 'TRANSFER_OUT').length, 1);
    assert.equal(movements.filter((r) => r.type === 'TRANSFER_IN').length, 1);
    const balances = await db.stockBalance.findMany({
      where: { stockItemId: fixture.stockItemId },
    });
    assert.equal(balances.find((r) => r.outletId === outletId)!.quantity.toString(), '6');
    assert.equal(
      balances.find((r) => r.outletId === destinationOutletId)!.quantity.toString(),
      '4',
    );
    assert.equal(
      (await db.outletTransfer.findUniqueOrThrow({ where: { id: transfer.id } })).state,
      'RECEIVED',
    );
    t.diagnostic(
      JSON.stringify({
        attempts: 5,
        sourceMovements: 1,
        destinationMovements: 1,
        sourceBalance: 6,
        destinationBalance: 4,
      }),
    );
  },
);
