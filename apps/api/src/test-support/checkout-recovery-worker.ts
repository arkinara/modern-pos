import 'reflect-metadata';
import { PrismaClient } from '@prisma/client';
import type { PrismaService } from '../prisma/prisma.service';
import { PromotionsService } from '../promotions/promotions.service';
import type { FinalizeDto } from '../sales/dto/finalize.dto';
import { SalesService } from '../sales/sales.service';
import { integrationDatabaseUrl } from './integration-database';
import { actor, outletId } from './transaction-fixture';

async function recover(): Promise<void> {
  const input = JSON.parse(process.env.CHECKOUT_RECOVERY_INPUT ?? '') as {
    key: string;
    dto: FinalizeDto;
  };
  const db = new PrismaClient({ datasources: { db: { url: integrationDatabaseUrl() } } });
  try {
    const prisma = db as PrismaService;
    const service = new SalesService(prisma, new PromotionsService(prisma));
    const recovered = await service.recoverCheckout(
      outletId,
      input.key,
      { deviceId: input.dto.deviceId },
      actor,
    );
    const replay = await service.finalize(outletId, input.key, input.dto, actor);
    console.log(
      JSON.stringify({
        recoveredId: recovered.sale.id,
        replayId: replay.sale.id,
        replayed: recovered.replayed,
      }),
    );
  } finally {
    await db.$disconnect();
  }
}

void recover().catch((error: unknown) => {
  console.error(error instanceof Error ? error.message : 'Checkout recovery worker failed');
  process.exitCode = 1;
});
