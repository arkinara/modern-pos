import { randomUUID } from 'node:crypto';
import { PaymentKind, PrismaClient, Role } from '@prisma/client';
import type { AuthenticatedUser } from '../auth/auth.types';
import type { SalesService } from '../sales/sales.service';

export const businessId = '00000000-0000-4000-8000-000000000001';
export const outletId = '00000000-0000-4000-8000-000000000002';
export const destinationOutletId = '00000000-0000-4000-8000-000000000005';
export const actor: AuthenticatedUser = {
  id: '00000000-0000-4000-8000-000000000003',
  businessId,
  role: Role.OWNER,
  email: 'owner@example.test',
  outletId,
  outletIds: [outletId, destinationOutletId],
  sessionId: 'integration-test',
};

export async function createTrackedFixture(db: PrismaClient, opening = '12') {
  return db.$transaction(async (tx) => {
    const category = await tx.category.create({
      data: { businessId, name: `DB regression ${randomUUID()}` },
    });
    const item = await tx.menuItem.create({
      data: { businessId, categoryId: category.id, name: 'Synthetic item' },
    });
    const stock = await tx.stockItem.create({
      data: {
        businessId,
        name: 'Synthetic ingredient',
        baseUnit: 'each',
        quantityScale: 0,
        reorderThreshold: 0,
      },
    });
    await tx.stockBalance.create({ data: { outletId, stockItemId: stock.id, quantity: opening } });
    await tx.stockMovement.create({
      data: {
        outletId,
        stockItemId: stock.id,
        actorId: actor.id,
        delta: opening,
        type: 'OPENING',
        reason: 'Synthetic integration opening',
        sourceId: randomUUID(),
      },
    });
    const variant = await tx.menuVariant.create({
      data: {
        menuItemId: item.id,
        name: 'Default',
        priceMinor: 1000n,
        stockPolicy: 'TRACKED',
      },
    });
    await tx.outletMenu.create({ data: { outletId, variantId: variant.id } });
    await tx.recipeVersion.create({
      data: {
        businessId,
        outletId,
        variantId: variant.id,
        version: 1,
        lines: { create: [{ stockItemId: stock.id, quantityPerSaleUnit: '3' }] },
      },
    });
    return { variantId: variant.id, stockItemId: stock.id };
  });
}

export async function prepareCheckout(service: SalesService, variantId: string) {
  const deviceId = randomUUID();
  const order = await service.createOrder(
    outletId,
    randomUUID(),
    {
      deviceId,
      lines: [{ variantId, quantity: 2 }],
    },
    actor,
  );
  const quote = await service.createQuote(
    outletId,
    order.id,
    { orderVersion: order.version },
    actor,
  );
  return {
    key: randomUUID(),
    dto: {
      deviceId,
      orderId: order.id,
      quoteId: quote.id,
      payment: {
        kind: PaymentKind.CASH,
        amountMinor: quote.totals.totalMinor,
        tenderedMinor: quote.totals.totalMinor,
      },
    },
  };
}
