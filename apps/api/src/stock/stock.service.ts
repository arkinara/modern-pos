import { createHash } from 'node:crypto';
import { Injectable } from '@nestjs/common';
import { Prisma, StockMovementType } from '@prisma/client';
import type { AuthenticatedUser } from '../auth/auth.types';
import { apiError } from '../common/api-error';
import { PrismaService } from '../prisma/prisma.service';
import { StockAdjustmentDto } from './dto/stock-adjustment.dto';
import { StockChangeDto } from './dto/stock-change.dto';
import { StockCreateDto } from './dto/stock-create.dto';
import { StockListQueryDto } from './dto/stock-list-query.dto';
import { MovementListQueryDto } from './dto/movement-list-query.dto';

export interface StockResponse {
  id: string;
  name: string;
  baseUnit: string;
  quantityScale: number;
  reorderThreshold: string;
  quantity: string;
  version: number;
}

export interface StockPageResponse {
  items: StockResponse[];
  nextCursor: string | null;
}

export interface MovementResponse {
  id: string;
  stockItemId: string;
  delta: string;
  type: string;
  reason: string;
  sourceId: string;
  actorId: string;
  createdAt: string;
}

export interface MovementPageResponse {
  items: MovementResponse[];
  nextCursor: string | null;
}

const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

const ZERO = new Prisma.Decimal(0);

function fractionDigits(value: string): number {
  const dot = value.indexOf('.');
  return dot === -1 ? 0 : value.length - dot - 1;
}

function normalizeDecimal(value: string): string {
  return new Prisma.Decimal(value).toString();
}

function requestHash(operation: string, payload: Record<string, unknown>): string {
  return createHash('sha256')
    .update(JSON.stringify({ operation, ...payload }))
    .digest('hex');
}

function requireIdempotencyKey(key: string | undefined): string {
  if (!key || !UUID_PATTERN.test(key)) {
    throw apiError(
      400,
      'VALIDATION_ERROR',
      'Idempotency-Key header is required and must be a UUID',
    );
  }

  return key.toLowerCase();
}

function isUniqueViolation(error: unknown): boolean {
  return error instanceof Prisma.PrismaClientKnownRequestError && error.code === 'P2002';
}

interface WriteMovementInput {
  operation: 'OPENING' | 'RECEIPT' | 'ADJUSTMENT';
  key: string;
  stockItemId: string;
  delta: Prisma.Decimal;
  reason: string;
  expectedBalanceVersion?: number;
}

@Injectable()
export class StockService {
  constructor(private readonly prisma: PrismaService) {}

  async list(
    outletId: string,
    query: StockListQueryDto,
    user: AuthenticatedUser,
  ): Promise<StockPageResponse> {
    await this.requireOutlet(this.prisma, outletId, user.businessId);

    const limit = query.limit ?? 25;
    const search = query.search?.trim();

    const rows = await this.prisma.stockItem.findMany({
      where: {
        businessId: user.businessId,
        ...(search ? { name: { contains: search, mode: 'insensitive' as const } } : {}),
      },
      orderBy: [{ name: 'asc' }, { id: 'asc' }],
      take: limit + 1,
      ...(query.cursor ? { cursor: { id: query.cursor }, skip: 1 } : {}),
      include: {
        balances: {
          where: { outletId },
          select: { quantity: true, version: true },
        },
      },
    });

    const hasMore = rows.length > limit;
    const page = hasMore ? rows.slice(0, limit) : rows;

    return {
      items: page.map((row) => {
        const balance = row.balances[0];
        return {
          id: row.id,
          name: row.name,
          baseUnit: row.baseUnit,
          quantityScale: row.quantityScale,
          reorderThreshold: row.reorderThreshold.toFixed(row.quantityScale),
          quantity: (balance?.quantity ?? ZERO).toFixed(row.quantityScale),
          version: balance?.version ?? 1,
        };
      }),
      nextCursor: hasMore ? (page[page.length - 1]?.id ?? null) : null,
    };
  }

  async create(
    outletId: string,
    dto: StockCreateDto,
    user: AuthenticatedUser,
  ): Promise<StockResponse> {
    await this.requireOutlet(this.prisma, outletId, user.businessId);

    if (fractionDigits(dto.reorderThreshold) > dto.quantityScale) {
      throw apiError(
        400,
        'VALIDATION_ERROR',
        'reorderThreshold has more decimals than quantityScale allows',
      );
    }

    const item = await this.prisma.stockItem.create({
      data: {
        businessId: user.businessId,
        name: dto.name,
        baseUnit: dto.baseUnit,
        quantityScale: dto.quantityScale,
        reorderThreshold: new Prisma.Decimal(dto.reorderThreshold),
      },
    });

    return {
      id: item.id,
      name: item.name,
      baseUnit: item.baseUnit,
      quantityScale: item.quantityScale,
      reorderThreshold: item.reorderThreshold.toFixed(item.quantityScale),
      quantity: ZERO.toFixed(item.quantityScale),
      version: 1,
    };
  }

  async listMovements(
    outletId: string,
    stockItemId: string,
    query: MovementListQueryDto,
    user: AuthenticatedUser,
  ): Promise<MovementPageResponse> {
    await this.requireOutlet(this.prisma, outletId, user.businessId);
    const item = await this.requireStockItem(this.prisma, stockItemId, user.businessId);

    const limit = query.limit ?? 25;
    const rows = await this.prisma.stockMovement.findMany({
      where: { outletId, stockItemId },
      orderBy: [{ createdAt: 'desc' }, { id: 'desc' }],
      take: limit + 1,
      ...(query.cursor ? { cursor: { id: query.cursor }, skip: 1 } : {}),
    });

    const hasMore = rows.length > limit;
    const page = hasMore ? rows.slice(0, limit) : rows;

    return {
      items: page.map((row) => this.toMovement(row, item.quantityScale)),
      nextCursor: hasMore ? (page[page.length - 1]?.id ?? null) : null,
    };
  }

  async recordOpening(
    outletId: string,
    key: string | undefined,
    dto: StockChangeDto,
    user: AuthenticatedUser,
  ): Promise<MovementResponse> {
    return this.recordPositive(outletId, key, 'OPENING', dto, user);
  }

  async recordReceipt(
    outletId: string,
    key: string | undefined,
    dto: StockChangeDto,
    user: AuthenticatedUser,
  ): Promise<MovementResponse> {
    return this.recordPositive(outletId, key, 'RECEIPT', dto, user);
  }

  async recordAdjustment(
    outletId: string,
    key: string | undefined,
    dto: StockAdjustmentDto,
    user: AuthenticatedUser,
  ): Promise<MovementResponse> {
    const idempotencyKey = requireIdempotencyKey(key);
    const delta = new Prisma.Decimal(dto.delta);

    return this.recordMovement(outletId, user, {
      operation: 'ADJUSTMENT',
      key: idempotencyKey,
      stockItemId: dto.stockItemId,
      delta,
      reason: dto.reason,
      expectedBalanceVersion: dto.expectedBalanceVersion,
    });
  }

  private async recordPositive(
    outletId: string,
    key: string | undefined,
    operation: 'OPENING' | 'RECEIPT',
    dto: StockChangeDto,
    user: AuthenticatedUser,
  ): Promise<MovementResponse> {
    const idempotencyKey = requireIdempotencyKey(key);
    const quantity = new Prisma.Decimal(dto.quantity);

    if (quantity.lessThanOrEqualTo(0)) {
      throw apiError(
        400,
        'VALIDATION_ERROR',
        'quantity must be greater than zero for opening and receipt movements',
      );
    }

    return this.recordMovement(outletId, user, {
      operation,
      key: idempotencyKey,
      stockItemId: dto.stockItemId,
      delta: quantity,
      reason: dto.reason,
    });
  }

  private async recordMovement(
    outletId: string,
    user: AuthenticatedUser,
    input: WriteMovementInput,
  ): Promise<MovementResponse> {
    const normalizedPayload: Record<string, unknown> = {
      outletId,
      stockItemId: input.stockItemId,
      reason: input.reason,
      ...(input.operation === 'ADJUSTMENT'
        ? {
            delta: normalizeDecimal(input.delta.toString()),
            expectedBalanceVersion: input.expectedBalanceVersion,
          }
        : { quantity: normalizeDecimal(input.delta.toString()) }),
    };
    const hash = requestHash(input.operation, normalizedPayload);

    const prior = await this.prisma.stockIdempotency.findUnique({
      where: { outletId_key: { outletId, key: input.key } },
    });

    if (prior) {
      return this.replay(prior, hash);
    }

    try {
      return await this.prisma.$transaction(async (tx) =>
        this.applyMovement(tx, outletId, user, input, hash),
      );
    } catch (error) {
      if (isUniqueViolation(error)) {
        const existing = await this.prisma.stockIdempotency.findUnique({
          where: { outletId_key: { outletId, key: input.key } },
        });

        if (existing) {
          return this.replay(existing, hash);
        }
      }

      throw error;
    }
  }

  private replay(
    record: {
      requestHash: string;
      responseBody: Prisma.JsonValue | null;
    },
    hash: string,
  ): MovementResponse {
    if (record.requestHash !== hash) {
      throw apiError(
        409,
        'IDEMPOTENCY_CONFLICT',
        'Idempotency-Key was already used with a different request payload',
      );
    }

    if (record.responseBody === null) {
      throw apiError(
        409,
        'IDEMPOTENCY_IN_PROGRESS',
        'A request with this Idempotency-Key is still being processed',
        { retryable: true },
      );
    }

    return record.responseBody as unknown as MovementResponse;
  }

  private async applyMovement(
    tx: Prisma.TransactionClient,
    outletId: string,
    user: AuthenticatedUser,
    input: WriteMovementInput,
    hash: string,
  ): Promise<MovementResponse> {
    await this.requireOutlet(tx, outletId, user.businessId);

    // Reserving the key inside the same transaction keeps retries single-shot.
    const reservation = await tx.stockIdempotency.create({
      data: {
        outletId,
        key: input.key,
        operation: input.operation,
        requestHash: hash,
      },
    });

    const item = await this.requireStockItem(tx, input.stockItemId, user.businessId);

    if (fractionDigits(input.delta.abs().toString()) > item.quantityScale) {
      throw apiError(
        400,
        'VALIDATION_ERROR',
        'quantity has more decimals than quantityScale allows',
      );
    }

    if (input.operation === 'ADJUSTMENT' && input.delta.isZero()) {
      throw apiError(400, 'VALIDATION_ERROR', 'delta must not be zero');
    }

    if (input.operation === 'OPENING') {
      const existingOpening = await tx.stockMovement.findFirst({
        where: { outletId, stockItemId: input.stockItemId, type: StockMovementType.OPENING },
        select: { id: true },
      });

      if (existingOpening) {
        throw apiError(
          409,
          'OPENING_ALREADY_RECORDED',
          'An opening balance already exists for this stock item and outlet',
        );
      }
    }

    const balance = await tx.stockBalance.findUnique({
      where: { outletId_stockItemId: { outletId, stockItemId: input.stockItemId } },
    });

    const current = balance?.quantity ?? ZERO;
    const currentVersion = balance?.version ?? 1;

    if (input.operation === 'ADJUSTMENT' && input.expectedBalanceVersion !== currentVersion) {
      throw apiError(409, 'VERSION_CONFLICT', 'Stock balance was changed by another request');
    }

    const next = current.plus(input.delta);

    if (next.lessThan(0)) {
      throw apiError(422, 'INSUFFICIENT_STOCK', 'Adjustment would make the stock balance negative');
    }

    const movement = await tx.stockMovement.create({
      data: {
        outletId,
        stockItemId: input.stockItemId,
        delta: input.delta,
        type: input.operation,
        actorId: user.id,
        reason: input.reason,
        sourceId: input.key,
      },
    });

    if (!balance) {
      await tx.stockBalance.create({
        data: {
          outletId,
          stockItemId: input.stockItemId,
          quantity: next,
          version: 1,
        },
      });
    } else if (input.operation === 'ADJUSTMENT') {
      const updated = await tx.stockBalance.updateMany({
        where: { outletId, stockItemId: input.stockItemId, version: currentVersion },
        data: {
          quantity: next,
          version: { increment: 1 },
        },
      });

      if (updated.count !== 1) {
        throw apiError(409, 'VERSION_CONFLICT', 'Stock balance was changed by another request');
      }
    } else {
      const updated = await tx.stockBalance.updateMany({
        where: { outletId, stockItemId: input.stockItemId },
        data: {
          quantity: { increment: input.delta },
          version: { increment: 1 },
        },
      });

      if (updated.count !== 1) {
        throw apiError(409, 'VERSION_CONFLICT', 'Stock balance was changed by another request');
      }
    }

    await this.assertBalanceDerivable(tx, outletId, input.stockItemId);

    const response = this.toMovement(movement, item.quantityScale);

    await tx.stockIdempotency.update({
      where: { id: reservation.id },
      data: {
        movementId: movement.id,
        responseBody: response as unknown as Prisma.InputJsonValue,
      },
    });

    return response;
  }

  private async assertBalanceDerivable(
    tx: Prisma.TransactionClient,
    outletId: string,
    stockItemId: string,
  ): Promise<void> {
    const [summed, balance] = await Promise.all([
      tx.stockMovement.aggregate({
        where: { outletId, stockItemId },
        _sum: { delta: true },
      }),
      tx.stockBalance.findUnique({
        where: { outletId_stockItemId: { outletId, stockItemId } },
        select: { quantity: true },
      }),
    ]);

    const movementSum = summed._sum.delta ?? ZERO;

    if (!balance || !movementSum.equals(balance.quantity)) {
      throw apiError(500, 'BALANCE_MISMATCH', 'Stock balance does not match the movement ledger');
    }
  }

  private async requireOutlet(
    client: Prisma.TransactionClient | PrismaService,
    outletId: string,
    businessId: string,
  ): Promise<void> {
    const outlet = await client.outlet.findFirst({
      where: { id: outletId, businessId },
      select: { id: true },
    });

    if (!outlet) {
      throw apiError(404, 'NOT_FOUND', 'Outlet not found');
    }
  }

  private async requireStockItem(
    client: Prisma.TransactionClient | PrismaService,
    stockItemId: string,
    businessId: string,
  ): Promise<{ id: string; quantityScale: number }> {
    const item = await client.stockItem.findFirst({
      where: { id: stockItemId, businessId },
      select: { id: true, quantityScale: true },
    });

    if (!item) {
      throw apiError(404, 'NOT_FOUND', 'Stock item not found');
    }

    return item;
  }

  private toMovement(
    movement: {
      id: string;
      stockItemId: string;
      delta: Prisma.Decimal;
      type: StockMovementType;
      reason: string;
      sourceId: string;
      actorId: string;
      createdAt: Date;
    },
    quantityScale: number,
  ): MovementResponse {
    return {
      id: movement.id,
      stockItemId: movement.stockItemId,
      delta: movement.delta.toFixed(quantityScale),
      type: movement.type,
      reason: movement.reason,
      sourceId: movement.sourceId,
      actorId: movement.actorId,
      createdAt: movement.createdAt.toISOString(),
    };
  }
}
