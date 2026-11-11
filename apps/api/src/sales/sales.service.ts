import { createHash, randomUUID } from 'node:crypto';
import { Injectable } from '@nestjs/common';
import {
  OrderAuditAction,
  OrderState,
  PaymentKind,
  PaymentStatus,
  Prisma,
  Role,
  SaleState,
  StockMovementType,
  StockPolicy,
} from '@prisma/client';
import type { AuthenticatedUser } from '../auth/auth.types';
import { apiError } from '../common/api-error';
import { PrismaService } from '../prisma/prisma.service';
import { CheckoutQueryDto } from './dto/checkout-query.dto';
import { FinalizeDto } from './dto/finalize.dto';
import { OrderCancelDto } from './dto/order-cancel.dto';
import { OrderCreateDto } from './dto/order-create.dto';
import { OrderListQueryDto } from './dto/order-list-query.dto';
import { OrderSplitDto } from './dto/order-split.dto';
import { OrderTransferDto } from './dto/order-transfer.dto';
import { OrderUpdateDto } from './dto/order-update.dto';
import { QuoteCreateDto } from './dto/quote-create.dto';
import { TableCreateDto } from './dto/table-create.dto';
import { FIXED_POINT_PATTERN, ReversalDto, RestockItemDto } from './dto/reversal.dto';
import { SalesListQueryDto } from './dto/sales-list-query.dto';
import { calculateTotals, normalizePayment, toWireMinor, type MoneyTotals } from './money';
import { localDateRangeUtc } from './outlet-time';

const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const QUOTE_TTL_MS = 60_000;
const MAX_TRANSACTION_ATTEMPTS = 3;
const ROUNDING_RULE = 'HALF_UP';

export interface OrderLineResponse {
  variantId: string;
  quantity: number;
}

export interface OrderResponse {
  id: string;
  deviceId: string;
  state: OrderState;
  version: number;
  lines: OrderLineResponse[];
  tableId?: string;
  tableLabel?: string;
  splitGroupId?: string;
  parentOrderId?: string;
}

export interface TableResponse {
  id: string;
  label: string;
  seatCount: number;
  active: boolean;
}

export interface OrderAuditResponse {
  id: string;
  orderId: string;
  action: OrderAuditAction;
  actorId: string;
  fromTableId?: string;
  toTableId?: string;
  metadata: Record<string, unknown>;
  createdAt: string;
}

export interface OrderPageResponse {
  items: OrderResponse[];
  nextCursor: string | null;
}

export interface OrderSplitResponse {
  parentOrder: OrderResponse;
  bills: OrderResponse[];
}

export interface TotalsResponse {
  subtotalMinor: number;
  serviceMinor: number;
  taxMinor: number;
  totalMinor: number;
}

export interface CalculationRulesResponse {
  taxBps: number;
  serviceBps: number;
  pricingMode: string;
  currencyExponent: number;
  rounding: string;
}

export interface QuoteLineResponse {
  variantId: string;
  name: string;
  variantName: string;
  quantity: number;
  unitPriceMinor: number;
  lineSubtotalMinor: number;
  recipeVersion: number | null;
}

export interface QuoteResponse {
  id: string;
  orderId: string;
  orderVersion: number;
  settingsVersion: number;
  currency: string;
  currencyExponent: number;
  calculation: CalculationRulesResponse;
  expiresAt: string;
  totals: TotalsResponse;
  lines: QuoteLineResponse[];
}

export interface SaleLineResponse {
  id: string;
  variantId: string;
  name: string;
  variantName: string;
  quantity: number;
  unitPriceMinor: number;
  lineSubtotalMinor: number;
}

export interface PaymentResponse {
  kind: PaymentKind;
  status: PaymentStatus;
  amountMinor: number;
  tenderedMinor?: number;
  changeMinor?: number;
  reference?: string;
}

export interface RestockResponse {
  stockItemId: string;
  quantity: string;
}

export interface ReversalResponse {
  id: string;
  saleId: string;
  reason: string;
  createdAt: string;
  restock: RestockResponse[];
  externalRefundPerformed: false;
}

export interface SaleResponse {
  id: string;
  orderId: string;
  reference: string;
  state: SaleState;
  currency: string;
  currencyExponent: number;
  timezone: string;
  completedAt: string;
  calculation: CalculationRulesResponse;
  totals: TotalsResponse;
  lines: SaleLineResponse[];
  payment: PaymentResponse;
  reversal?: ReversalResponse;
}

export interface FinalizedResponse {
  sale: SaleResponse;
  replayed: boolean;
}

export interface SalePageResponse {
  items: SaleResponse[];
  nextCursor: string | null;
}

interface QuoteLineSnapshot {
  variantId: string;
  name: string;
  variantName: string;
  quantity: number;
  unitPriceMinor: number;
  lineSubtotalMinor: number;
  recipeVersion: number | null;
}

interface SaleWithReceipt {
  id: string;
  orderId: string;
  reference: string;
  state: SaleState;
  currency: string;
  currencyExponent: number;
  taxBps: number;
  serviceBps: number;
  pricingMode: string;
  rounding: string;
  timezone: string;
  completedAt: Date;
  subtotalMinor: bigint;
  serviceMinor: bigint;
  taxMinor: bigint;
  totalMinor: bigint;
  lines: {
    id: string;
    variantId: string;
    name: string;
    variantName: string;
    quantity: number;
    unitPriceMinor: bigint;
    lineSubtotalMinor: bigint;
  }[];
  payment: {
    kind: PaymentKind;
    status: PaymentStatus;
    amountMinor: bigint;
    tenderedMinor: bigint | null;
    changeMinor: bigint | null;
    reference: string | null;
  } | null;
  reversal: {
    id: string;
    saleId: string;
    reason: string;
    createdAt: Date;
    restock: Prisma.JsonValue;
    externalRefundPerformed: boolean;
  } | null;
}

type DbClient = Prisma.TransactionClient | PrismaService;

interface VariantPricingRecord {
  id: string;
  name: string;
  priceMinor: bigint;
  active: boolean;
  stockPolicy: StockPolicy;
  menuItem: {
    name: string;
    archivedAt: Date | null;
    category: { archivedAt: Date | null };
  };
  outletMenus: { enabled: boolean }[];
}

interface OutletSettingsRecord {
  id: string;
  businessId: string;
  timezone: string;
  currency: string;
  currencyExponent: number;
  taxBps: number;
  serviceBps: number;
  pricingMode: string;
  version: number;
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

function requestHash(value: Record<string, unknown>): string {
  return createHash('sha256').update(JSON.stringify(value)).digest('hex');
}

function isUniqueViolation(error: unknown): boolean {
  return error instanceof Prisma.PrismaClientKnownRequestError && error.code === 'P2002';
}

function isSerializationFailure(error: unknown): boolean {
  const details = error as { code?: unknown; meta?: { code?: unknown } } | null;
  const code = details?.code;
  const databaseCode = details?.meta?.code;

  return (
    code === 'P2034' ||
    code === '40001' ||
    code === '40P01' ||
    databaseCode === '40001' ||
    databaseCode === '40P01'
  );
}

function sleep(milliseconds: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, milliseconds));
}

@Injectable()
export class SalesService {
  constructor(private readonly prisma: PrismaService) {}

  async createOrder(
    outletId: string,
    key: string | undefined,
    dto: OrderCreateDto,
    user: AuthenticatedUser,
  ): Promise<OrderResponse> {
    const idempotencyKey = requireIdempotencyKey(key);
    const hash = requestHash({
      operation: 'ORDER_CREATE',
      outletId,
      deviceId: dto.deviceId,
      tableId: dto.tableId ?? null,
      lines: dto.lines.map((line) => ({
        variantId: line.variantId,
        quantity: line.quantity,
      })),
    });

    const prior = await this.prisma.order.findUnique({
      where: {
        outletId_deviceId_idempotencyKey: {
          outletId,
          deviceId: dto.deviceId,
          idempotencyKey,
        },
      },
      include: {
        lines: { orderBy: [{ createdAt: 'asc' }, { id: 'asc' }] },
        table: { select: { label: true } },
      },
    });

    if (prior) {
      this.assertOrderAccess(prior, user);
      return this.replayOrder(prior, hash);
    }

    try {
      return await this.prisma.$transaction(async (tx) => {
        const outlet = await this.requireOutlet(tx, outletId, user.businessId);
        await this.requireSaleableLines(
          tx,
          outletId,
          user.businessId,
          dto.lines,
          'ITEM_UNAVAILABLE',
        );
        const table = dto.tableId
          ? await this.requireTable(tx, outletId, user.businessId, dto.tableId)
          : null;

        const order = await tx.order.create({
          data: {
            businessId: user.businessId,
            outletId: outlet.id,
            cashierId: user.id,
            deviceId: dto.deviceId,
            idempotencyKey,
            requestHash: hash,
            ...(table ? { tableId: table.id } : {}),
            lines: {
              create: dto.lines.map((line) => ({
                variantId: line.variantId,
                quantity: line.quantity,
              })),
            },
          },
          include: {
            lines: { orderBy: [{ createdAt: 'asc' }, { id: 'asc' }] },
            table: { select: { label: true } },
          },
        });

        await this.writeAudit(tx, {
          businessId: user.businessId,
          outletId,
          orderId: order.id,
          actorId: user.id,
          action: OrderAuditAction.OPEN,
          toTableId: table?.id ?? null,
          metadata: table ? { tableLabel: table.label } : {},
        });

        return this.toOrder(order);
      });
    } catch (error) {
      if (isUniqueViolation(error)) {
        const existing = await this.prisma.order.findUnique({
          where: {
            outletId_deviceId_idempotencyKey: {
              outletId,
              deviceId: dto.deviceId,
              idempotencyKey,
            },
          },
          include: {
            lines: { orderBy: [{ createdAt: 'asc' }, { id: 'asc' }] },
            table: { select: { label: true } },
          },
        });

        if (existing) {
          this.assertOrderAccess(existing, user);
          return this.replayOrder(existing, hash);
        }
      }

      throw error;
    }
  }

  async updateOrder(
    outletId: string,
    orderId: string,
    dto: OrderUpdateDto,
    user: AuthenticatedUser,
  ): Promise<OrderResponse> {
    return this.prisma.$transaction(async (tx) => {
      const order = await this.requireOrder(tx, outletId, orderId, user);

      if (order.state !== OrderState.DRAFT) {
        throw apiError(409, 'ORDER_NOT_DRAFT', 'Only draft orders can be updated');
      }

      if (order.version !== dto.version) {
        throw apiError(409, 'VERSION_CONFLICT', 'Order was changed by another request');
      }

      await this.requireSaleableLines(tx, outletId, user.businessId, dto.lines, 'ITEM_UNAVAILABLE');

      const updated = await tx.order.updateMany({
        where: {
          id: orderId,
          outletId,
          businessId: user.businessId,
          state: OrderState.DRAFT,
          version: dto.version,
        },
        data: {
          version: { increment: 1 },
        },
      });

      if (updated.count !== 1) {
        throw apiError(409, 'VERSION_CONFLICT', 'Order was changed by another request');
      }

      await tx.orderLine.deleteMany({ where: { orderId } });
      await tx.orderLine.createMany({
        data: dto.lines.map((line) => ({
          orderId,
          variantId: line.variantId,
          quantity: line.quantity,
        })),
      });

      await this.writeAudit(tx, {
        businessId: user.businessId,
        outletId,
        orderId,
        actorId: user.id,
        action: OrderAuditAction.UPDATE,
        metadata: { fromVersion: order.version, toVersion: order.version + 1 },
      });

      const refreshed = await this.loadOrder(tx, orderId);
      return this.toOrder(refreshed);
    });
  }

  async cancelOrder(
    outletId: string,
    orderId: string,
    dto: OrderCancelDto,
    user: AuthenticatedUser,
  ): Promise<void> {
    await this.prisma.$transaction(async (tx) => {
      const order = await this.requireOrder(tx, outletId, orderId, user);

      if (order.state !== OrderState.DRAFT) {
        throw apiError(409, 'ORDER_NOT_DRAFT', 'Only draft orders can be cancelled');
      }

      if (order.version !== dto.version) {
        throw apiError(409, 'VERSION_CONFLICT', 'Order was changed by another request');
      }

      const updated = await tx.order.updateMany({
        where: {
          id: orderId,
          outletId,
          businessId: user.businessId,
          state: OrderState.DRAFT,
          version: dto.version,
        },
        data: {
          state: OrderState.CANCELLED,
          version: { increment: 1 },
        },
      });

      if (updated.count !== 1) {
        throw apiError(409, 'VERSION_CONFLICT', 'Order was changed by another request');
      }

      await this.writeAudit(tx, {
        businessId: user.businessId,
        outletId,
        orderId,
        actorId: user.id,
        action: OrderAuditAction.CANCEL,
        fromTableId: order.tableId,
        metadata: { stockConsumed: false },
      });
    });
  }

  async listTables(outletId: string, user: AuthenticatedUser): Promise<{ items: TableResponse[] }> {
    await this.requireOutlet(this.prisma, outletId, user.businessId);
    const rows = await this.prisma.diningTable.findMany({
      where: { outletId, businessId: user.businessId, active: true },
      orderBy: [{ label: 'asc' }, { id: 'asc' }],
    });

    return {
      items: rows.map((row) => ({
        id: row.id,
        label: row.label,
        seatCount: row.seatCount,
        active: row.active,
      })),
    };
  }

  async createTable(
    outletId: string,
    dto: TableCreateDto,
    user: AuthenticatedUser,
  ): Promise<TableResponse> {
    if (user.role !== Role.OWNER) {
      throw apiError(403, 'FORBIDDEN', 'Only an owner can create tables');
    }

    try {
      return await this.prisma.$transaction(async (tx) => {
        const outlet = await this.requireOutlet(tx, outletId, user.businessId);
        const table = await tx.diningTable.create({
          data: {
            businessId: user.businessId,
            outletId: outlet.id,
            label: dto.label,
            seatCount: dto.seatCount ?? 0,
          },
        });

        return {
          id: table.id,
          label: table.label,
          seatCount: table.seatCount,
          active: table.active,
        };
      });
    } catch (error) {
      if (isUniqueViolation(error)) {
        throw apiError(409, 'TABLE_EXISTS', 'A table with this label already exists');
      }

      throw error;
    }
  }

  async listOpenOrders(
    outletId: string,
    query: OrderListQueryDto,
    user: AuthenticatedUser,
  ): Promise<OrderPageResponse> {
    await this.requireOutlet(this.prisma, outletId, user.businessId);
    const limit = query.limit ?? 100;

    const rows = await this.prisma.order.findMany({
      where: {
        businessId: user.businessId,
        outletId,
        state: OrderState.DRAFT,
      },
      orderBy: [{ updatedAt: 'desc' }, { id: 'desc' }],
      take: limit + 1,
      ...(query.cursor ? { cursor: { id: query.cursor }, skip: 1 } : {}),
      include: {
        lines: { orderBy: [{ createdAt: 'asc' }, { id: 'asc' }] },
        table: { select: { label: true } },
      },
    });

    const hasMore = rows.length > limit;
    const page = hasMore ? rows.slice(0, limit) : rows;

    return {
      items: page.map((order) => this.toOrder(order)),
      nextCursor: hasMore ? (page[page.length - 1]?.id ?? null) : null,
    };
  }

  async getOrder(
    outletId: string,
    orderId: string,
    user: AuthenticatedUser,
  ): Promise<OrderResponse> {
    const order = await this.prisma.order.findFirst({
      where: { id: orderId, outletId, businessId: user.businessId },
      include: {
        lines: { orderBy: [{ createdAt: 'asc' }, { id: 'asc' }] },
        table: { select: { label: true } },
      },
    });

    if (!order) {
      throw apiError(404, 'NOT_FOUND', 'Order not found');
    }

    return this.toOrder(order);
  }

  async transferOrder(
    outletId: string,
    orderId: string,
    dto: OrderTransferDto,
    user: AuthenticatedUser,
  ): Promise<OrderResponse> {
    if (user.role !== Role.OWNER) {
      throw apiError(403, 'FORBIDDEN', 'Only an owner can transfer a table order');
    }

    return this.prisma.$transaction(async (tx) => {
      const order = await this.requireOrder(tx, outletId, orderId, user);

      if (order.state !== OrderState.DRAFT) {
        throw apiError(409, 'ORDER_NOT_DRAFT', 'Only draft orders can be transferred');
      }

      if (order.version !== dto.version) {
        throw apiError(409, 'VERSION_CONFLICT', 'Order was changed by another request');
      }

      if (order.tableId === dto.tableId) {
        throw apiError(422, 'TABLE_UNCHANGED', 'Order is already assigned to this table');
      }

      const table = await this.requireTable(tx, outletId, user.businessId, dto.tableId);
      const fromTable = order.tableId
        ? await this.findTable(tx, outletId, user.businessId, order.tableId)
        : null;

      const updated = await tx.order.updateMany({
        where: {
          id: orderId,
          outletId,
          businessId: user.businessId,
          state: OrderState.DRAFT,
          version: dto.version,
        },
        data: { tableId: table.id, version: { increment: 1 } },
      });

      if (updated.count !== 1) {
        throw apiError(409, 'VERSION_CONFLICT', 'Order was changed by another request');
      }

      await this.writeAudit(tx, {
        businessId: user.businessId,
        outletId,
        orderId,
        actorId: user.id,
        action: OrderAuditAction.TRANSFER,
        fromTableId: order.tableId,
        toTableId: table.id,
        metadata: {
          fromTableLabel: fromTable?.label ?? null,
          toTableLabel: table.label,
        },
      });

      const refreshed = await this.loadOrder(tx, orderId);
      return this.toOrder(refreshed);
    });
  }

  async splitOrder(
    outletId: string,
    orderId: string,
    key: string | undefined,
    dto: OrderSplitDto,
    user: AuthenticatedUser,
  ): Promise<OrderSplitResponse> {
    const idempotencyKey = requireIdempotencyKey(key);
    const bills = this.normalizeSplitBills(dto.bills);
    const hash = requestHash({
      operation: 'ORDER_SPLIT',
      outletId,
      orderId,
      version: dto.version,
      bills,
    });

    const prior = await this.prisma.orderSplit.findUnique({
      where: { outletId_idempotencyKey: { outletId, idempotencyKey } },
    });

    if (prior) {
      return this.replaySplit(prior, outletId, orderId, hash, user);
    }

    try {
      return await this.runSerializable(
        () =>
          this.prisma.$transaction(
            async (tx) =>
              this.applySplit(
                tx,
                outletId,
                orderId,
                idempotencyKey,
                hash,
                dto.version,
                bills,
                user,
              ),
            { isolationLevel: Prisma.TransactionIsolationLevel.Serializable },
          ),
        'Order split',
      );
    } catch (error) {
      if (isUniqueViolation(error)) {
        const existing = await this.prisma.orderSplit.findUnique({
          where: { outletId_idempotencyKey: { outletId, idempotencyKey } },
        });

        if (existing) {
          return this.replaySplit(existing, outletId, orderId, hash, user);
        }
      }

      throw error;
    }
  }

  async listOrderAudits(
    outletId: string,
    orderId: string,
    user: AuthenticatedUser,
  ): Promise<{ items: OrderAuditResponse[] }> {
    if (user.role !== Role.OWNER) {
      throw apiError(403, 'FORBIDDEN', 'Only an owner can read the order audit trail');
    }

    await this.requireOrder(this.prisma, outletId, orderId, user);
    const rows = await this.prisma.orderAudit.findMany({
      where: { orderId, outletId, businessId: user.businessId },
      orderBy: [{ createdAt: 'asc' }, { id: 'asc' }],
    });

    return {
      items: rows.map((row) => ({
        id: row.id,
        orderId: row.orderId,
        action: row.action,
        actorId: row.actorId,
        ...(row.fromTableId !== null ? { fromTableId: row.fromTableId } : {}),
        ...(row.toTableId !== null ? { toTableId: row.toTableId } : {}),
        metadata:
          row.metadata && typeof row.metadata === 'object' && !Array.isArray(row.metadata)
            ? (row.metadata as Record<string, unknown>)
            : {},
        createdAt: row.createdAt.toISOString(),
      })),
    };
  }

  async createQuote(
    outletId: string,
    orderId: string,
    dto: QuoteCreateDto,
    user: AuthenticatedUser,
  ): Promise<QuoteResponse> {
    return this.prisma.$transaction(async (tx) => {
      const order = await this.requireOrder(tx, outletId, orderId, user);

      if (order.state !== OrderState.DRAFT) {
        throw apiError(409, 'ORDER_NOT_DRAFT', 'Only draft orders can be quoted');
      }

      if (order.version !== dto.orderVersion) {
        throw apiError(409, 'VERSION_CONFLICT', 'Order was changed by another request');
      }

      const outlet = await this.requireOutlet(tx, outletId, user.businessId);
      const variants = await this.requireSaleableLines(
        tx,
        outletId,
        user.businessId,
        order.lines,
        'ITEM_UNAVAILABLE',
      );
      const recipes = await this.loadRecipeVersions(
        tx,
        outletId,
        user.businessId,
        order.lines.map((line) => line.variantId),
      );
      const snapshots = this.buildQuoteLines(order.lines, variants, false, recipes);
      const totals = calculateTotals(
        snapshots.map((line) => ({
          unitPriceMinor: BigInt(line.unitPriceMinor),
          quantity: line.quantity,
        })),
        outlet.serviceBps,
        outlet.taxBps,
      );
      const expiresAt = new Date(Date.now() + QUOTE_TTL_MS);

      const quote = await tx.quote.create({
        data: {
          businessId: user.businessId,
          outletId,
          orderId,
          orderVersion: order.version,
          settingsVersion: outlet.version,
          currency: outlet.currency,
          currencyExponent: outlet.currencyExponent,
          taxBps: outlet.taxBps,
          serviceBps: outlet.serviceBps,
          pricingMode: outlet.pricingMode,
          rounding: ROUNDING_RULE,
          expiresAt,
          subtotalMinor: totals.subtotalMinor,
          serviceMinor: totals.serviceMinor,
          taxMinor: totals.taxMinor,
          totalMinor: totals.totalMinor,
          lines: snapshots as unknown as Prisma.InputJsonValue,
        },
      });

      return {
        id: quote.id,
        orderId: quote.orderId,
        orderVersion: quote.orderVersion,
        settingsVersion: quote.settingsVersion,
        currency: quote.currency,
        currencyExponent: quote.currencyExponent,
        calculation: this.toCalculation(quote),
        expiresAt: quote.expiresAt.toISOString(),
        totals: this.toTotals(totals),
        lines: snapshots,
      };
    });
  }

  async finalize(
    outletId: string,
    key: string | undefined,
    dto: FinalizeDto,
    user: AuthenticatedUser,
  ): Promise<FinalizedResponse> {
    const idempotencyKey = requireIdempotencyKey(key);
    const hash = requestHash({
      operation: 'SALE_FINALIZE',
      outletId,
      deviceId: dto.deviceId,
      orderId: dto.orderId,
      quoteId: dto.quoteId,
      payment: {
        kind: dto.payment.kind,
        amountMinor: dto.payment.amountMinor,
        tenderedMinor: dto.payment.tenderedMinor ?? null,
        reference: dto.payment.reference ?? null,
      },
    });

    const prior = await this.prisma.checkoutRequest.findUnique({
      where: {
        outletId_deviceId_idempotencyKey: {
          outletId,
          deviceId: dto.deviceId,
          idempotencyKey,
        },
      },
    });

    if (prior) {
      return this.replayCheckout(prior.requestHash, prior.saleId, outletId, hash, user);
    }

    try {
      return await this.runSerializable(async () => {
        return this.prisma.$transaction(
          async (tx) => {
            const reservation = await tx.checkoutRequest.create({
              data: {
                businessId: user.businessId,
                outletId,
                deviceId: dto.deviceId,
                idempotencyKey,
                requestHash: hash,
              },
            });

            const order = await this.requireOrder(tx, outletId, dto.orderId, user);

            if (order.deviceId !== dto.deviceId) {
              throw apiError(
                422,
                'DEVICE_MISMATCH',
                'Finalize deviceId does not match the draft order device',
              );
            }

            if (order.state === OrderState.COMPLETED) {
              const completedSale = await tx.sale.findUnique({
                where: { orderId: order.id },
                select: { id: true },
              });
              throw apiError(409, 'ORDER_ALREADY_COMPLETED', 'Order already has a completed sale', {
                details: { saleId: completedSale?.id ?? null },
              });
            }

            if (order.state !== OrderState.DRAFT) {
              throw apiError(409, 'ORDER_NOT_DRAFT', 'Only draft orders can be finalized');
            }

            const outlet = await this.requireOutlet(tx, outletId, user.businessId);
            const quote = await tx.quote.findFirst({
              where: {
                id: dto.quoteId,
                orderId: order.id,
                outletId,
                businessId: user.businessId,
              },
            });

            if (!quote) {
              throw apiError(404, 'NOT_FOUND', 'Quote not found');
            }

            const now = new Date();

            if (quote.expiresAt.getTime() <= now.getTime()) {
              throw apiError(
                409,
                'QUOTE_EXPIRED',
                'Quote has expired; request a new quote before charging',
              );
            }

            if (quote.orderVersion !== order.version) {
              throw apiError(
                409,
                'QUOTE_STALE',
                'Quote is stale for the current order version; request a new quote',
              );
            }

            if (quote.settingsVersion !== outlet.version) {
              throw apiError(
                409,
                'QUOTE_STALE',
                'Outlet settings changed after the quote; request a new quote',
              );
            }

            if (
              quote.currency !== outlet.currency ||
              quote.currencyExponent !== outlet.currencyExponent
            ) {
              throw apiError(
                409,
                'QUOTE_STALE',
                'Currency changed after the quote; request a new quote',
              );
            }

            const variants = await this.loadVariants(
              tx,
              outletId,
              user.businessId,
              order.lines.map((line) => line.variantId),
            );
            const recipes = await this.loadRecipeVersions(
              tx,
              outletId,
              user.businessId,
              order.lines.map((line) => line.variantId),
            );
            const currentLines = this.buildQuoteLines(order.lines, variants, true, recipes);
            const currentTotals = calculateTotals(
              currentLines.map((line) => ({
                unitPriceMinor: BigInt(line.unitPriceMinor),
                quantity: line.quantity,
              })),
              outlet.serviceBps,
              outlet.taxBps,
            );
            const quotedLines = this.readQuoteLines(quote.lines);

            this.assertQuoteStillValid(quotedLines, currentLines, quote, currentTotals);

            const currentRecipeVersions = new Map(
              currentLines.map((line) => [line.variantId, line.recipeVersion]),
            );
            const snapshots = quotedLines.map((line) => ({
              ...line,
              recipeVersion: currentRecipeVersions.get(line.variantId) ?? line.recipeVersion,
            }));
            const totals: MoneyTotals = {
              subtotalMinor: quote.subtotalMinor,
              serviceMinor: quote.serviceMinor,
              taxMinor: quote.taxMinor,
              totalMinor: quote.totalMinor,
            };
            const payment = normalizePayment(totals.totalMinor, dto.payment);

            const sale = await tx.sale.create({
              data: {
                businessId: user.businessId,
                outletId,
                orderId: order.id,
                cashierId: order.cashierId,
                deviceId: order.deviceId,
                reference: `SALE-${order.id}`,
                state: SaleState.COMPLETED,
                currency: quote.currency,
                currencyExponent: quote.currencyExponent,
                taxBps: outlet.taxBps,
                serviceBps: outlet.serviceBps,
                pricingMode: outlet.pricingMode,
                rounding: ROUNDING_RULE,
                timezone: outlet.timezone,
                subtotalMinor: totals.subtotalMinor,
                serviceMinor: totals.serviceMinor,
                taxMinor: totals.taxMinor,
                totalMinor: totals.totalMinor,
                completedAt: now,
                lines: {
                  create: snapshots.map((line) => ({
                    variantId: line.variantId,
                    name: line.name,
                    variantName: line.variantName,
                    quantity: line.quantity,
                    unitPriceMinor: BigInt(line.unitPriceMinor),
                    lineSubtotalMinor: BigInt(line.lineSubtotalMinor),
                    recipeVersion: line.recipeVersion,
                  })),
                },
                payment: {
                  create: {
                    kind: payment.kind,
                    status: PaymentStatus.RECORDED,
                    amountMinor: payment.amountMinor,
                    tenderedMinor: payment.tenderedMinor,
                    changeMinor: payment.changeMinor,
                    reference: payment.reference,
                  },
                },
              },
              include: {
                lines: { orderBy: [{ id: 'asc' }] },
                payment: true,
                reversal: true,
              },
            });

            const completed = await tx.order.updateMany({
              where: {
                id: order.id,
                outletId,
                businessId: user.businessId,
                state: OrderState.DRAFT,
                version: order.version,
              },
              data: {
                state: OrderState.COMPLETED,
                version: { increment: 1 },
              },
            });

            if (completed.count !== 1) {
              throw apiError(409, 'VERSION_CONFLICT', 'Order was changed by another request');
            }

            await this.applyStockConsumption(tx, {
              outletId,
              orderId: order.id,
              saleId: sale.id,
              actorId: user.id,
              lines: snapshots.map((line) => ({
                variantId: line.variantId,
                quantity: line.quantity,
                recipeVersion: line.recipeVersion,
              })),
            });

            await this.writeAudit(tx, {
              businessId: user.businessId,
              outletId,
              orderId: order.id,
              actorId: user.id,
              action: OrderAuditAction.FINALIZE,
              fromTableId: order.tableId,
              metadata: {
                saleId: sale.id,
                totalMinor: toWireMinor(totals.totalMinor, 'totalMinor'),
              },
            });

            await tx.checkoutRequest.update({
              where: { id: reservation.id },
              data: { saleId: sale.id },
            });

            return { sale: this.toSale(sale), replayed: false };
          },
          { isolationLevel: Prisma.TransactionIsolationLevel.Serializable },
        );
      });
    } catch (error) {
      if (isUniqueViolation(error)) {
        const existing = await this.prisma.checkoutRequest.findUnique({
          where: {
            outletId_deviceId_idempotencyKey: {
              outletId,
              deviceId: dto.deviceId,
              idempotencyKey,
            },
          },
        });

        if (existing) {
          return this.replayCheckout(existing.requestHash, existing.saleId, outletId, hash, user);
        }
      }

      throw error;
    }
  }

  async recoverCheckout(
    outletId: string,
    key: string,
    query: CheckoutQueryDto,
    user: AuthenticatedUser,
  ): Promise<FinalizedResponse> {
    if (!UUID_PATTERN.test(key)) {
      throw apiError(400, 'VALIDATION_ERROR', 'Checkout key must be a UUID');
    }

    const mapping = await this.prisma.checkoutRequest.findUnique({
      where: {
        outletId_deviceId_idempotencyKey: {
          outletId,
          deviceId: query.deviceId,
          idempotencyKey: key.toLowerCase(),
        },
      },
    });

    if (!mapping) {
      throw apiError(
        404,
        'NOT_FOUND',
        'No completed checkout is recorded for this key; resubmit the same key and payload',
      );
    }

    if (!mapping.saleId) {
      throw apiError(
        409,
        'IDEMPOTENCY_IN_PROGRESS',
        'This checkout is still being processed; retry shortly',
        { retryable: true },
      );
    }

    const sale = await this.loadSale(this.prisma, mapping.saleId, outletId, user.businessId, user);
    return { sale: this.toSale(sale), replayed: true };
  }

  async listSales(
    outletId: string,
    query: SalesListQueryDto,
    user: AuthenticatedUser,
  ): Promise<SalePageResponse> {
    const outlet = await this.requireOutlet(this.prisma, outletId, user.businessId);
    const completedAt = localDateRangeUtc(query.from, query.to, outlet.timezone);
    const limit = query.limit ?? 25;

    const rows = await this.prisma.sale.findMany({
      where: {
        businessId: user.businessId,
        outletId,
        ...(user.role === Role.CASHIER ? { cashierId: user.id } : {}),
        ...(completedAt.gte || completedAt.lt ? { completedAt } : {}),
      },
      orderBy: [{ completedAt: 'desc' }, { id: 'desc' }],
      take: limit + 1,
      ...(query.cursor ? { cursor: { id: query.cursor }, skip: 1 } : {}),
      include: {
        lines: { orderBy: [{ id: 'asc' }] },
        payment: true,
        reversal: true,
      },
    });

    const hasMore = rows.length > limit;
    const page = hasMore ? rows.slice(0, limit) : rows;

    return {
      items: page.map((sale) => this.toSale(sale)),
      nextCursor: hasMore ? (page[page.length - 1]?.id ?? null) : null,
    };
  }

  async getSale(outletId: string, saleId: string, user: AuthenticatedUser): Promise<SaleResponse> {
    const sale = await this.loadSale(this.prisma, saleId, outletId, user.businessId, user);
    return this.toSale(sale);
  }

  /**
   * Records one immutable reversal for a completed sale. The original sale row is
   * never updated. Stock moves only for the explicit restock selection, and the
   * response never claims an external payment provider performed a refund.
   */
  async reverse(
    outletId: string,
    saleId: string,
    key: string | undefined,
    dto: ReversalDto,
    user: AuthenticatedUser,
  ): Promise<ReversalResponse> {
    if (user.role !== Role.OWNER) {
      throw apiError(403, 'FORBIDDEN', 'Only an owner can reverse a sale');
    }

    const idempotencyKey = requireIdempotencyKey(key);
    const reason = this.normalizeReason(dto.reason);
    const restock = this.normalizeRestock(dto.restock);
    const hash = requestHash({
      operation: 'SALE_REVERSE',
      outletId,
      saleId,
      reason,
      restock: restock.map((item) => ({
        stockItemId: item.stockItemId.toLowerCase(),
        quantity: item.quantity,
      })),
    });

    const prior = await this.prisma.saleReversal.findUnique({
      where: { outletId_idempotencyKey: { outletId, idempotencyKey } },
    });

    if (prior) {
      return this.replayReversal(prior, saleId, hash);
    }

    const alreadyReversed = await this.prisma.saleReversal.findUnique({ where: { saleId } });

    if (alreadyReversed) {
      throw apiError(409, 'SALE_ALREADY_REVERSED', 'This sale has already been reversed');
    }

    try {
      return await this.runSerializable(
        () =>
          this.prisma.$transaction(
            async (tx) =>
              this.applyReversal(tx, outletId, saleId, idempotencyKey, reason, restock, hash, user),
            { isolationLevel: Prisma.TransactionIsolationLevel.Serializable },
          ),
        'Sale reversal',
      );
    } catch (error) {
      if (isUniqueViolation(error)) {
        const sameKey = await this.prisma.saleReversal.findUnique({
          where: { outletId_idempotencyKey: { outletId, idempotencyKey } },
        });

        if (sameKey) {
          return this.replayReversal(sameKey, saleId, hash);
        }

        const existing = await this.prisma.saleReversal.findUnique({ where: { saleId } });

        if (existing) {
          throw apiError(409, 'SALE_ALREADY_REVERSED', 'This sale has already been reversed');
        }
      }

      throw error;
    }
  }

  private normalizeReason(value: string): string {
    const reason = typeof value === 'string' ? value.trim() : '';

    if (reason.length < 3 || reason.length > 500) {
      throw apiError(400, 'VALIDATION_ERROR', 'reason must contain between 3 and 500 characters');
    }

    return reason;
  }

  private normalizeRestock(input: RestockItemDto[]): { stockItemId: string; quantity: string }[] {
    if (!Array.isArray(input)) {
      throw apiError(400, 'VALIDATION_ERROR', 'restock must be an array');
    }

    const seen = new Set<string>();
    const normalized = input.map((item) => {
      if (!UUID_PATTERN.test(item.stockItemId)) {
        throw apiError(400, 'VALIDATION_ERROR', 'restock stockItemId must be a UUID');
      }

      if (!FIXED_POINT_PATTERN.test(item.quantity)) {
        throw apiError(
          400,
          'VALIDATION_ERROR',
          'restock quantity must be a nonnegative fixed-point base-unit string',
        );
      }

      const quantity = new Prisma.Decimal(item.quantity);
      const stockItemId = item.stockItemId.toLowerCase();

      if (seen.has(stockItemId)) {
        throw apiError(
          422,
          'DUPLICATE_RESTOCK_ITEM',
          'A stock item can appear only once in restock',
          {
            details: { stockItemId },
          },
        );
      }

      if (quantity.lessThanOrEqualTo(0)) {
        throw apiError(
          422,
          'INVALID_RESTOCK_QUANTITY',
          'restock quantity must be greater than zero',
          {
            details: { stockItemId },
          },
        );
      }

      seen.add(stockItemId);
      return { stockItemId, quantity: quantity.toString() };
    });

    return normalized.sort((a, b) => a.stockItemId.localeCompare(b.stockItemId));
  }

  private replayReversal(
    record: {
      saleId: string;
      requestHash: string;
      id: string;
      reason: string;
      createdAt: Date;
      restock: Prisma.JsonValue;
    },
    saleId: string,
    hash: string,
  ): ReversalResponse {
    if (record.saleId !== saleId || record.requestHash !== hash) {
      throw apiError(
        409,
        'IDEMPOTENCY_CONFLICT',
        'Idempotency-Key was already used with a different request payload',
      );
    }

    return this.toReversal(record);
  }

  private async applyReversal(
    tx: Prisma.TransactionClient,
    outletId: string,
    saleId: string,
    idempotencyKey: string,
    reason: string,
    restock: { stockItemId: string; quantity: string }[],
    hash: string,
    user: AuthenticatedUser,
  ): Promise<ReversalResponse> {
    await tx.$queryRaw`
      SELECT "id"
      FROM "sales"
      WHERE "id" = ${saleId}::uuid
        AND "outletId" = ${outletId}::uuid
      FOR UPDATE
    `;

    const sale = await tx.sale.findFirst({
      where: { id: saleId, outletId, businessId: user.businessId },
      include: { lines: { orderBy: [{ id: 'asc' }] } },
    });

    if (!sale) {
      throw apiError(404, 'NOT_FOUND', 'Sale not found');
    }

    const existing = await tx.saleReversal.findUnique({ where: { saleId } });

    if (existing) {
      if (existing.idempotencyKey === idempotencyKey) {
        return this.replayReversal(existing, saleId, hash);
      }

      throw apiError(409, 'SALE_ALREADY_REVERSED', 'This sale has already been reversed');
    }

    if (sale.state !== SaleState.COMPLETED) {
      throw apiError(409, 'SALE_NOT_COMPLETED', 'Only completed sales can be reversed');
    }

    const consumed = await this.loadConsumedStock(tx, outletId, sale);

    if (restock.length > 0) {
      const ids = [...new Set(restock.map((item) => item.stockItemId))];
      const stockItems = await tx.stockItem.findMany({
        where: { id: { in: ids }, businessId: user.businessId },
        select: { id: true, quantityScale: true },
      });
      const scaleById = new Map(stockItems.map((item) => [item.id, item.quantityScale]));

      for (const item of restock) {
        const scale = scaleById.get(item.stockItemId);
        const consumedQuantity = consumed.get(item.stockItemId);

        if (scale === undefined || consumedQuantity === undefined) {
          throw apiError(
            422,
            'RESTOCK_ITEM_NOT_SOLD',
            'Only stock items consumed by this sale can be restocked',
            { details: { stockItemId: item.stockItemId } },
          );
        }

        const quantity = new Prisma.Decimal(item.quantity);

        if (quantity.decimalPlaces() > scale) {
          throw apiError(
            422,
            'INVALID_RESTOCK_QUANTITY',
            'restock quantity has more decimals than the stock item allows',
            { details: { stockItemId: item.stockItemId } },
          );
        }

        if (quantity.greaterThan(consumedQuantity)) {
          throw apiError(
            422,
            'RESTOCK_EXCEEDS_SOLD',
            'restock quantity exceeds the amount consumed by this sale',
            {
              details: {
                stockItemId: item.stockItemId,
                consumed: consumedQuantity.toString(),
                requested: quantity.toString(),
              },
            },
          );
        }

        item.quantity = quantity.toFixed(scale);
      }
    }

    const reversal = await tx.saleReversal.create({
      data: {
        businessId: user.businessId,
        outletId,
        saleId,
        actorId: user.id,
        reason,
        restock: restock as unknown as Prisma.InputJsonValue,
        externalRefundPerformed: false,
        idempotencyKey,
        requestHash: hash,
      },
    });

    await this.applyReversalRestock(tx, {
      outletId,
      saleId,
      reversalId: reversal.id,
      actorId: user.id,
      reason,
      items: restock,
    });

    return this.toReversal(reversal);
  }

  private async loadConsumedStock(
    tx: Prisma.TransactionClient,
    outletId: string,
    sale: {
      lines: { variantId: string; quantity: number; recipeVersion: number | null }[];
    },
  ): Promise<Map<string, Prisma.Decimal>> {
    const consumed = new Map<string, Prisma.Decimal>();
    const zero = new Prisma.Decimal(0);
    const variantIds = [...new Set(sale.lines.map((line) => line.variantId))];

    if (variantIds.length === 0) {
      return consumed;
    }

    const variants = await tx.menuVariant.findMany({
      where: { id: { in: variantIds } },
      select: { id: true, stockPolicy: true },
    });
    const policies = new Map(variants.map((variant) => [variant.id, variant.stockPolicy]));
    const pins = new Map<string, { variantId: string; version: number }>();

    for (const line of sale.lines) {
      if (policies.get(line.variantId) !== StockPolicy.TRACKED || line.recipeVersion === null) {
        continue;
      }

      pins.set(`${line.variantId}:${line.recipeVersion}`, {
        variantId: line.variantId,
        version: line.recipeVersion,
      });
    }

    if (pins.size === 0) {
      return consumed;
    }

    const recipes = await tx.recipeVersion.findMany({
      where: {
        outletId,
        OR: [...pins.values()].map((pin) => ({
          variantId: pin.variantId,
          version: pin.version,
        })),
      },
      select: {
        variantId: true,
        version: true,
        lines: { select: { stockItemId: true, quantityPerSaleUnit: true } },
      },
    });
    const recipeByPin = new Map(
      recipes.map((recipe) => [`${recipe.variantId}:${recipe.version}`, recipe]),
    );

    for (const line of sale.lines) {
      if (policies.get(line.variantId) !== StockPolicy.TRACKED) {
        continue;
      }

      const recipe =
        line.recipeVersion === null
          ? null
          : recipeByPin.get(`${line.variantId}:${line.recipeVersion}`);

      if (!recipe) {
        throw apiError(
          409,
          'RECIPE_SNAPSHOT_MISSING',
          'The pinned recipe version for this sale is unavailable',
          { details: { variantId: line.variantId, recipeVersion: line.recipeVersion } },
        );
      }

      for (const recipeLine of recipe.lines) {
        const amount = new Prisma.Decimal(recipeLine.quantityPerSaleUnit).mul(line.quantity);
        consumed.set(
          recipeLine.stockItemId,
          (consumed.get(recipeLine.stockItemId) ?? zero).plus(amount),
        );
      }
    }

    return consumed;
  }

  private async applyReversalRestock(
    tx: Prisma.TransactionClient,
    context: {
      outletId: string;
      saleId: string;
      reversalId: string;
      actorId: string;
      reason: string;
      items: { stockItemId: string; quantity: string }[];
    },
  ): Promise<void> {
    const { outletId, saleId, reversalId, actorId, reason, items } = context;

    if (items.length === 0) {
      return;
    }

    const stockItemIds = items.map((item) => item.stockItemId).sort();
    const lockedBalances = await tx.$queryRaw<
      { stockItemId: string; quantity: Prisma.Decimal; version: number }[]
    >`
      SELECT "stockItemId", "quantity", "version"
      FROM "stock_balances"
      WHERE "outletId" = ${outletId}::uuid
        AND "stockItemId"::text IN (${Prisma.join(stockItemIds)})
      ORDER BY "stockItemId"
      FOR UPDATE
    `;
    const balances = new Map(
      lockedBalances.map((row) => [
        row.stockItemId,
        { quantity: new Prisma.Decimal(row.quantity), version: row.version },
      ]),
    );

    await tx.stockMovement.createMany({
      data: items.map((item) => ({
        outletId,
        stockItemId: item.stockItemId,
        delta: new Prisma.Decimal(item.quantity),
        type: StockMovementType.REVERSAL,
        actorId,
        reason: `Reversal ${reversalId} for sale ${saleId}: ${reason}`,
        sourceId: reversalId,
      })),
    });

    for (const item of items) {
      const amount = new Prisma.Decimal(item.quantity);
      const balance = balances.get(item.stockItemId);

      if (!balance) {
        await tx.stockBalance.create({
          data: {
            outletId,
            stockItemId: item.stockItemId,
            quantity: amount,
            version: 1,
          },
        });
        continue;
      }

      const updated = await tx.stockBalance.updateMany({
        where: {
          outletId,
          stockItemId: item.stockItemId,
          version: balance.version,
        },
        data: {
          quantity: { increment: amount },
          version: { increment: 1 },
        },
      });

      if (updated.count !== 1) {
        throw apiError(
          409,
          'STOCK_CHANGED',
          'Stock changed while the reversal was committing; retry with the same key',
          { retryable: true },
        );
      }
    }
  }

  private toReversal(record: {
    id: string;
    saleId: string;
    reason: string;
    createdAt: Date;
    restock: Prisma.JsonValue;
  }): ReversalResponse {
    if (!Array.isArray(record.restock)) {
      throw apiError(500, 'REVERSAL_CORRUPT', 'Stored reversal restock is invalid');
    }

    const restock = record.restock.map((entry) => {
      const item = entry as { stockItemId?: unknown; quantity?: unknown };

      if (typeof item.stockItemId !== 'string' || typeof item.quantity !== 'string') {
        throw apiError(500, 'REVERSAL_CORRUPT', 'Stored reversal restock is invalid');
      }

      return { stockItemId: item.stockItemId, quantity: item.quantity };
    });

    return {
      id: record.id,
      saleId: record.saleId,
      reason: record.reason,
      createdAt: record.createdAt.toISOString(),
      restock,
      externalRefundPerformed: false,
    };
  }

  private normalizeSplitBills(
    bills: { lines: { variantId: string; quantity: number }[] }[],
  ): { lines: { variantId: string; quantity: number }[] }[] {
    if (!Array.isArray(bills) || bills.length < 2) {
      throw apiError(400, 'VALIDATION_ERROR', 'A split requires at least two bills');
    }

    return bills.map((bill, index) => {
      if (!Array.isArray(bill.lines) || bill.lines.length === 0) {
        throw apiError(400, 'VALIDATION_ERROR', `Bill ${index + 1} has no lines`);
      }

      const seen = new Set<string>();
      const lines = bill.lines.map((line) => {
        const variantId = line.variantId.toLowerCase();
        const quantity = Number(line.quantity);

        if (!UUID_PATTERN.test(variantId)) {
          throw apiError(400, 'VALIDATION_ERROR', 'Split line variantId must be a UUID');
        }

        if (!Number.isInteger(quantity) || quantity < 1) {
          throw apiError(400, 'VALIDATION_ERROR', 'Split line quantity must be a positive integer');
        }

        if (seen.has(variantId)) {
          throw apiError(
            422,
            'SPLIT_MISMATCH',
            'A bill cannot repeat the same variant; merge the quantities',
          );
        }

        seen.add(variantId);
        return { variantId, quantity };
      });

      return { lines };
    });
  }

  private assertExactSplit(
    orderLines: { variantId: string; quantity: number }[],
    bills: { lines: { variantId: string; quantity: number }[] }[],
  ): void {
    const original = new Map<string, number>();
    for (const line of orderLines) {
      original.set(line.variantId, (original.get(line.variantId) ?? 0) + line.quantity);
    }

    const allocated = new Map<string, number>();
    for (const bill of bills) {
      for (const line of bill.lines) {
        allocated.set(line.variantId, (allocated.get(line.variantId) ?? 0) + line.quantity);
      }
    }

    const unknown = [...allocated.keys()].filter((variantId) => !original.has(variantId));
    const mismatched = [...original.entries()].filter(
      ([variantId, quantity]) => allocated.get(variantId) !== quantity,
    );

    if (unknown.length > 0 || mismatched.length > 0) {
      throw apiError(
        422,
        'SPLIT_MISMATCH',
        'Split bills must allocate every original quantity exactly once',
        {
          details: {
            unknownVariantIds: unknown,
            mismatchedVariantIds: mismatched.map(([variantId]) => variantId),
          },
        },
      );
    }
  }

  private async applySplit(
    tx: Prisma.TransactionClient,
    outletId: string,
    orderId: string,
    idempotencyKey: string,
    hash: string,
    version: number,
    bills: { lines: { variantId: string; quantity: number }[] }[],
    user: AuthenticatedUser,
  ): Promise<OrderSplitResponse> {
    const order = await this.requireOrder(tx, outletId, orderId, user);

    if (order.state !== OrderState.DRAFT) {
      throw apiError(409, 'ORDER_NOT_DRAFT', 'Only draft orders can be split');
    }

    if (order.version !== version) {
      throw apiError(409, 'VERSION_CONFLICT', 'Order was changed by another request');
    }

    await this.requireSaleableLines(tx, outletId, user.businessId, order.lines, 'ITEM_UNAVAILABLE');
    this.assertExactSplit(order.lines, bills);

    const splitGroupId = randomUUID();
    const updated = await tx.order.updateMany({
      where: {
        id: order.id,
        outletId,
        businessId: user.businessId,
        state: OrderState.DRAFT,
        version: order.version,
      },
      data: { state: OrderState.SPLIT, splitGroupId, version: { increment: 1 } },
    });

    if (updated.count !== 1) {
      throw apiError(409, 'VERSION_CONFLICT', 'Order was changed by another request');
    }

    const children = [];
    for (const bill of bills) {
      const child = await tx.order.create({
        data: {
          businessId: user.businessId,
          outletId,
          cashierId: order.cashierId,
          deviceId: order.deviceId,
          idempotencyKey: randomUUID(),
          requestHash: requestHash({
            operation: 'ORDER_SPLIT_CHILD',
            parentOrderId: order.id,
            splitGroupId,
            lines: bill.lines,
          }),
          tableId: order.tableId,
          splitGroupId,
          parentOrderId: order.id,
          lines: {
            create: bill.lines.map((line) => ({
              variantId: line.variantId,
              quantity: line.quantity,
            })),
          },
        },
        include: {
          lines: { orderBy: [{ createdAt: 'asc' }, { id: 'asc' }] },
          table: { select: { label: true } },
        },
      });
      children.push(child);
    }

    await tx.orderSplit.create({
      data: {
        businessId: user.businessId,
        outletId,
        parentOrderId: order.id,
        actorId: user.id,
        idempotencyKey,
        requestHash: hash,
        splitGroupId,
        billCount: children.length,
        childOrderIds: children.map((child) => child.id),
      },
    });

    await this.writeAudit(tx, {
      businessId: user.businessId,
      outletId,
      orderId: order.id,
      actorId: user.id,
      action: OrderAuditAction.SPLIT,
      fromTableId: order.tableId,
      metadata: {
        splitGroupId,
        billCount: children.length,
        childOrderIds: children.map((child) => child.id),
      },
    });

    const refreshed = await this.loadOrder(tx, order.id);
    return {
      parentOrder: this.toOrder(refreshed),
      bills: children.map((child) => this.toOrder(child)),
    };
  }

  private async replaySplit(
    record: {
      parentOrderId: string;
      requestHash: string;
      childOrderIds: Prisma.JsonValue;
    },
    outletId: string,
    orderId: string,
    hash: string,
    user: AuthenticatedUser,
  ): Promise<OrderSplitResponse> {
    if (record.requestHash !== hash || record.parentOrderId !== orderId) {
      throw apiError(
        409,
        'IDEMPOTENCY_CONFLICT',
        'Idempotency-Key was already used with a different split payload',
      );
    }

    const ids = Array.isArray(record.childOrderIds)
      ? record.childOrderIds.filter((value): value is string => typeof value === 'string')
      : [];
    const bills = [];

    for (const id of ids) {
      const child = await this.prisma.order.findFirst({
        where: { id, outletId, businessId: user.businessId, parentOrderId: orderId },
        include: {
          lines: { orderBy: [{ createdAt: 'asc' }, { id: 'asc' }] },
          table: { select: { label: true } },
        },
      });

      if (!child) {
        throw apiError(409, 'IDEMPOTENCY_IN_PROGRESS', 'Split is still being applied; retry');
      }

      bills.push(this.toOrder(child));
    }

    const parent = await this.loadOrder(this.prisma, orderId);
    return { parentOrder: this.toOrder(parent), bills };
  }

  private async requireTable(
    client: DbClient,
    outletId: string,
    businessId: string,
    tableId: string,
  ): Promise<{ id: string; label: string }> {
    const table = await client.diningTable.findFirst({
      where: { id: tableId, outletId, businessId, active: true },
      select: { id: true, label: true },
    });

    if (!table) {
      throw apiError(404, 'NOT_FOUND', 'Table not found');
    }

    return table;
  }

  private async findTable(
    client: DbClient,
    outletId: string,
    businessId: string,
    tableId: string,
  ): Promise<{ id: string; label: string } | null> {
    return client.diningTable.findFirst({
      where: { id: tableId, outletId, businessId },
      select: { id: true, label: true },
    });
  }

  private async writeAudit(
    client: DbClient,
    input: {
      businessId: string;
      outletId: string;
      orderId: string;
      actorId: string;
      action: OrderAuditAction;
      fromTableId?: string | null;
      toTableId?: string | null;
      metadata?: Record<string, unknown>;
    },
  ): Promise<void> {
    await client.orderAudit.create({
      data: {
        businessId: input.businessId,
        outletId: input.outletId,
        orderId: input.orderId,
        actorId: input.actorId,
        action: input.action,
        fromTableId: input.fromTableId ?? null,
        toTableId: input.toTableId ?? null,
        metadata: (input.metadata ?? {}) as Prisma.InputJsonValue,
      },
    });
  }

  private async replayOrder(
    order: {
      requestHash: string;
      state: OrderState;
      version: number;
      id: string;
      deviceId: string;
      tableId?: string | null;
      splitGroupId?: string | null;
      parentOrderId?: string | null;
      table?: { label: string } | null;
      lines: { variantId: string; quantity: number }[];
    },
    hash: string,
  ): Promise<OrderResponse> {
    if (order.requestHash !== hash) {
      throw apiError(
        409,
        'IDEMPOTENCY_CONFLICT',
        'Idempotency-Key was already used with a different request payload',
      );
    }

    return this.toOrder(order);
  }

  private async replayCheckout(
    storedHash: string,
    saleId: string | null,
    outletId: string,
    hash: string,
    user: AuthenticatedUser,
  ): Promise<FinalizedResponse> {
    if (storedHash !== hash) {
      throw apiError(
        409,
        'IDEMPOTENCY_CONFLICT',
        'Idempotency-Key was already used with a different request payload',
      );
    }

    if (!saleId) {
      throw apiError(
        409,
        'IDEMPOTENCY_IN_PROGRESS',
        'This checkout is still being processed; retry with the same key and payload',
        { retryable: true },
      );
    }

    const sale = await this.loadSale(this.prisma, saleId, outletId, user.businessId, user);
    return { sale: this.toSale(sale), replayed: true };
  }

  private assertOrderAccess(order: { cashierId: string }, user: AuthenticatedUser): void {
    if (user.role === Role.CASHIER && order.cashierId !== user.id) {
      throw apiError(404, 'NOT_FOUND', 'Order not found');
    }
  }

  private async requireOrder(
    client: DbClient,
    outletId: string,
    orderId: string,
    user: AuthenticatedUser,
  ): Promise<{
    id: string;
    businessId: string;
    outletId: string;
    cashierId: string;
    deviceId: string;
    state: OrderState;
    version: number;
    tableId: string | null;
    splitGroupId: string | null;
    parentOrderId: string | null;
    lines: { variantId: string; quantity: number }[];
  }> {
    const order = await client.order.findFirst({
      where: { id: orderId, outletId, businessId: user.businessId },
      include: { lines: { orderBy: [{ createdAt: 'asc' }, { id: 'asc' }] } },
    });

    if (!order) {
      throw apiError(404, 'NOT_FOUND', 'Order not found');
    }

    this.assertOrderAccess(order, user);
    return order;
  }

  private async loadOrder(
    client: DbClient,
    orderId: string,
  ): Promise<{
    id: string;
    deviceId: string;
    state: OrderState;
    version: number;
    tableId: string | null;
    splitGroupId: string | null;
    parentOrderId: string | null;
    table: { label: string } | null;
    lines: { variantId: string; quantity: number }[];
  }> {
    const order = await client.order.findUnique({
      where: { id: orderId },
      include: {
        lines: { orderBy: [{ createdAt: 'asc' }, { id: 'asc' }] },
        table: { select: { label: true } },
      },
    });

    if (!order) {
      throw apiError(404, 'NOT_FOUND', 'Order not found');
    }

    return order;
  }

  private async requireOutlet(
    client: DbClient,
    outletId: string,
    businessId: string,
  ): Promise<OutletSettingsRecord> {
    const outlet = await client.outlet.findFirst({
      where: { id: outletId, businessId },
      select: {
        id: true,
        businessId: true,
        timezone: true,
        currency: true,
        currencyExponent: true,
        taxBps: true,
        serviceBps: true,
        pricingMode: true,
        version: true,
      },
    });

    if (!outlet) {
      throw apiError(404, 'NOT_FOUND', 'Outlet not found');
    }

    return outlet;
  }

  private async requireSaleableLines(
    client: DbClient,
    outletId: string,
    businessId: string,
    lines: { variantId: string; quantity: number }[],
    unavailableCode: 'ITEM_UNAVAILABLE' | 'QUOTE_STALE',
  ): Promise<Map<string, VariantPricingRecord>> {
    const variants = await this.loadVariants(
      client,
      outletId,
      businessId,
      lines.map((line) => line.variantId),
    );
    const missing = lines
      .filter((line) => !variants.has(line.variantId))
      .map((line) => line.variantId);

    if (missing.length > 0) {
      throw apiError(
        unavailableCode === 'QUOTE_STALE' ? 409 : 422,
        unavailableCode,
        unavailableCode === 'QUOTE_STALE'
          ? 'Catalog changed after the quote; request a new quote'
          : 'One or more variants are not saleable at this outlet',
        { details: { variantIds: [...new Set(missing)] } },
      );
    }

    return variants;
  }

  private async loadVariants(
    client: DbClient,
    outletId: string,
    businessId: string,
    variantIds: string[],
  ): Promise<Map<string, VariantPricingRecord>> {
    if (variantIds.length === 0) {
      return new Map();
    }

    const rows = await client.menuVariant.findMany({
      where: {
        id: { in: [...new Set(variantIds)] },
        menuItem: { businessId },
        outletMenus: { some: { outletId } },
      },
      include: {
        menuItem: {
          select: {
            name: true,
            archivedAt: true,
            category: { select: { archivedAt: true } },
          },
        },
        outletMenus: { where: { outletId }, select: { enabled: true } },
      },
    });

    const saleable = new Map<string, VariantPricingRecord>();

    for (const row of rows) {
      const enabled = row.outletMenus[0]?.enabled ?? false;

      if (
        row.active &&
        enabled &&
        row.menuItem.archivedAt === null &&
        row.menuItem.category.archivedAt === null
      ) {
        saleable.set(row.id, row);
      }
    }

    return saleable;
  }

  private buildQuoteLines(
    orderLines: { variantId: string; quantity: number }[],
    variants: Map<string, VariantPricingRecord>,
    strict = false,
    recipes: Map<string, number> = new Map(),
  ): QuoteLineSnapshot[] {
    return orderLines.map((line) => {
      const variant = variants.get(line.variantId);

      if (!variant) {
        if (strict) {
          throw apiError(
            409,
            'QUOTE_STALE',
            'Catalog changed after the quote; request a new quote',
            { details: { variantIds: [line.variantId] } },
          );
        }

        throw apiError(422, 'ITEM_UNAVAILABLE', 'Variant is not saleable at this outlet');
      }

      const recipeVersion = recipes.get(line.variantId) ?? null;

      if (variant.stockPolicy === StockPolicy.TRACKED && recipeVersion === null) {
        throw apiError(
          422,
          'RECIPE_REQUIRED',
          'Tracked variants require a published recipe before they can be sold',
          { details: { variantId: line.variantId } },
        );
      }

      const unitPriceMinor = toWireMinor(variant.priceMinor, 'unitPriceMinor');
      const lineSubtotal = calculateTotals(
        [{ unitPriceMinor: variant.priceMinor, quantity: line.quantity }],
        0,
        0,
      ).subtotalMinor;

      return {
        variantId: line.variantId,
        name: variant.menuItem.name,
        variantName: variant.name,
        quantity: line.quantity,
        unitPriceMinor,
        lineSubtotalMinor: toWireMinor(lineSubtotal, 'lineSubtotalMinor'),
        recipeVersion,
      };
    });
  }

  private async loadRecipeVersions(
    client: DbClient,
    outletId: string,
    businessId: string,
    variantIds: string[],
  ): Promise<Map<string, number>> {
    if (variantIds.length === 0) {
      return new Map();
    }

    const rows = await client.recipeVersion.findMany({
      where: {
        outletId,
        businessId,
        variantId: { in: [...new Set(variantIds)] },
      },
      orderBy: { version: 'asc' },
      select: { variantId: true, version: true },
    });

    const versions = new Map<string, number>();

    for (const row of rows) {
      versions.set(row.variantId, row.version);
    }

    return versions;
  }

  private readQuoteLines(value: Prisma.JsonValue): QuoteLineSnapshot[] {
    if (!Array.isArray(value)) {
      throw apiError(500, 'QUOTE_CORRUPT', 'Stored quote lines are invalid');
    }

    return value as unknown as QuoteLineSnapshot[];
  }

  private assertQuoteStillValid(
    quotedLines: QuoteLineSnapshot[],
    currentLines: QuoteLineSnapshot[],
    quote: {
      subtotalMinor: bigint;
      serviceMinor: bigint;
      taxMinor: bigint;
      totalMinor: bigint;
    },
    currentTotals: MoneyTotals,
  ): void {
    const sameLines =
      quotedLines.length === currentLines.length &&
      this.lineSignatures(quotedLines) === this.lineSignatures(currentLines);

    if (
      !sameLines ||
      quote.subtotalMinor !== currentTotals.subtotalMinor ||
      quote.serviceMinor !== currentTotals.serviceMinor ||
      quote.taxMinor !== currentTotals.taxMinor ||
      quote.totalMinor !== currentTotals.totalMinor
    ) {
      throw apiError(
        409,
        'QUOTE_STALE',
        'Prices or charges changed after the quote; request a new quote',
      );
    }
  }

  private lineSignatures(lines: QuoteLineSnapshot[]): string {
    return lines
      .map((line) =>
        [line.variantId, line.quantity, line.unitPriceMinor, line.lineSubtotalMinor].join(':'),
      )
      .sort()
      .join('|');
  }

  private async loadSale(
    client: DbClient,
    saleId: string,
    outletId: string,
    businessId: string,
    user: AuthenticatedUser,
  ): Promise<SaleWithReceipt> {
    const sale = await client.sale.findFirst({
      where: {
        id: saleId,
        outletId,
        businessId,
        ...(user.role === Role.CASHIER ? { cashierId: user.id } : {}),
      },
      include: {
        lines: { orderBy: [{ id: 'asc' }] },
        payment: true,
        reversal: true,
      },
    });

    if (!sale) {
      throw apiError(404, 'NOT_FOUND', 'Sale not found');
    }

    return sale as SaleWithReceipt;
  }

  private toOrder(order: {
    id: string;
    deviceId: string;
    state: OrderState;
    version: number;
    tableId?: string | null;
    splitGroupId?: string | null;
    parentOrderId?: string | null;
    table?: { label: string } | null;
    lines: { variantId: string; quantity: number }[];
  }): OrderResponse {
    return {
      id: order.id,
      deviceId: order.deviceId,
      state: order.state,
      version: order.version,
      ...(order.tableId ? { tableId: order.tableId } : {}),
      ...(order.table?.label ? { tableLabel: order.table.label } : {}),
      ...(order.splitGroupId ? { splitGroupId: order.splitGroupId } : {}),
      ...(order.parentOrderId ? { parentOrderId: order.parentOrderId } : {}),
      lines: order.lines.map((line) => ({
        variantId: line.variantId,
        quantity: line.quantity,
      })),
    };
  }

  private toCalculation(record: {
    taxBps: number;
    serviceBps: number;
    pricingMode: string;
    currencyExponent: number;
    rounding: string;
  }): CalculationRulesResponse {
    return {
      taxBps: record.taxBps,
      serviceBps: record.serviceBps,
      pricingMode: record.pricingMode,
      currencyExponent: record.currencyExponent,
      rounding: record.rounding,
    };
  }

  private toTotals(totals: MoneyTotals): TotalsResponse {
    return {
      subtotalMinor: toWireMinor(totals.subtotalMinor, 'subtotalMinor'),
      serviceMinor: toWireMinor(totals.serviceMinor, 'serviceMinor'),
      taxMinor: toWireMinor(totals.taxMinor, 'taxMinor'),
      totalMinor: toWireMinor(totals.totalMinor, 'totalMinor'),
    };
  }

  private toSale(sale: SaleWithReceipt): SaleResponse {
    const payment = sale.payment;

    if (!payment) {
      throw apiError(500, 'SALE_CORRUPT', 'Sale is missing its payment record');
    }

    const paymentResponse: PaymentResponse = {
      kind: payment.kind,
      status: payment.status,
      amountMinor: toWireMinor(payment.amountMinor, 'payment.amountMinor'),
      ...(payment.tenderedMinor !== null
        ? { tenderedMinor: toWireMinor(payment.tenderedMinor, 'payment.tenderedMinor') }
        : {}),
      ...(payment.changeMinor !== null
        ? { changeMinor: toWireMinor(payment.changeMinor, 'payment.changeMinor') }
        : {}),
      ...(payment.reference !== null ? { reference: payment.reference } : {}),
    };

    return {
      id: sale.id,
      orderId: sale.orderId,
      reference: sale.reference,
      state: sale.state,
      currency: sale.currency,
      currencyExponent: sale.currencyExponent,
      timezone: sale.timezone,
      completedAt: sale.completedAt.toISOString(),
      calculation: this.toCalculation(sale),
      totals: {
        subtotalMinor: toWireMinor(sale.subtotalMinor, 'subtotalMinor'),
        serviceMinor: toWireMinor(sale.serviceMinor, 'serviceMinor'),
        taxMinor: toWireMinor(sale.taxMinor, 'taxMinor'),
        totalMinor: toWireMinor(sale.totalMinor, 'totalMinor'),
      },
      lines: sale.lines.map((line) => ({
        id: line.id,
        variantId: line.variantId,
        name: line.name,
        variantName: line.variantName,
        quantity: line.quantity,
        unitPriceMinor: toWireMinor(line.unitPriceMinor, 'unitPriceMinor'),
        lineSubtotalMinor: toWireMinor(line.lineSubtotalMinor, 'lineSubtotalMinor'),
      })),
      payment: paymentResponse,
      ...(sale.reversal ? { reversal: this.toReversal(sale.reversal) } : {}),
    };
  }

  private async runSerializable<T>(
    operation: () => Promise<T>,
    operationLabel = 'Checkout',
  ): Promise<T> {
    for (let attempt = 1; attempt <= MAX_TRANSACTION_ATTEMPTS; attempt += 1) {
      try {
        return await operation();
      } catch (error) {
        if (!isSerializationFailure(error)) {
          throw error;
        }

        if (attempt === MAX_TRANSACTION_ATTEMPTS) {
          throw apiError(
            503,
            'TRANSACTION_RETRY_EXHAUSTED',
            `${operationLabel} could not commit due to concurrent activity; retry with the same key`,
            { retryable: true },
          );
        }

        await sleep(20 * attempt + Math.floor(Math.random() * 20));
      }
    }

    throw apiError(503, 'TRANSACTION_RETRY_EXHAUSTED', `${operationLabel} could not commit`, {
      retryable: true,
    });
  }

  private async applyStockConsumption(
    tx: Prisma.TransactionClient,
    context: {
      outletId: string;
      orderId: string;
      saleId: string;
      actorId: string;
      lines: { variantId: string; quantity: number; recipeVersion: number | null }[];
    },
  ): Promise<void> {
    const { outletId, orderId, saleId, actorId, lines } = context;
    const zero = new Prisma.Decimal(0);

    await tx.$queryRaw`
      SELECT "id"
      FROM "orders"
      WHERE "id" = ${orderId}::uuid
      FOR UPDATE
    `;

    const lockedOrder = await tx.order.findUnique({
      where: { id: orderId },
      select: { id: true, outletId: true, state: true },
    });

    if (!lockedOrder || lockedOrder.outletId !== outletId) {
      throw apiError(404, 'NOT_FOUND', 'Order not found');
    }

    if (lockedOrder.state !== OrderState.COMPLETED) {
      throw apiError(409, 'ORDER_NOT_DRAFT', 'Only draft orders can be finalized');
    }

    const variantIds = [...new Set(lines.map((line) => line.variantId))];
    const variantRows = await tx.menuVariant.findMany({
      where: { id: { in: variantIds } },
      select: { id: true, stockPolicy: true },
    });
    const variantPolicies = new Map(
      variantRows.map((variant) => [variant.id, variant.stockPolicy]),
    );

    const trackedLines = lines.flatMap((line) => {
      const policy = variantPolicies.get(line.variantId);

      if (!policy) {
        throw apiError(
          422,
          'ITEM_UNAVAILABLE',
          'One or more variants are not saleable at this outlet',
          { details: { variantIds: [line.variantId] } },
        );
      }

      if (policy === StockPolicy.UNTRACKED) {
        return [];
      }

      if (line.recipeVersion === null) {
        throw apiError(
          422,
          'RECIPE_REQUIRED',
          'Tracked variants require a published recipe before they can be sold',
          { details: { variantId: line.variantId } },
        );
      }

      return [line as { variantId: string; quantity: number; recipeVersion: number }];
    });

    const pins = new Map<string, { variantId: string; version: number }>();

    for (const line of trackedLines) {
      pins.set(`${line.variantId}:${line.recipeVersion}`, {
        variantId: line.variantId,
        version: line.recipeVersion,
      });
    }

    const recipeByPin = new Map<
      string,
      {
        variantId: string;
        version: number;
        lines: { stockItemId: string; quantityPerSaleUnit: Prisma.Decimal }[];
      }
    >();

    if (pins.size > 0) {
      const recipeRows = await tx.recipeVersion.findMany({
        where: {
          outletId,
          OR: [...pins.values()].map((pin) => ({
            variantId: pin.variantId,
            version: pin.version,
          })),
        },
        select: {
          variantId: true,
          version: true,
          lines: {
            select: { stockItemId: true, quantityPerSaleUnit: true },
          },
        },
      });

      for (const recipe of recipeRows) {
        recipeByPin.set(`${recipe.variantId}:${recipe.version}`, recipe);
      }
    }

    const consumption = new Map<string, Prisma.Decimal>();

    for (const line of trackedLines) {
      const recipe = recipeByPin.get(`${line.variantId}:${line.recipeVersion}`);

      if (!recipe) {
        throw apiError(
          409,
          'RECIPE_SNAPSHOT_MISSING',
          'The pinned recipe version for this sale is unavailable',
          { details: { variantId: line.variantId, recipeVersion: line.recipeVersion } },
        );
      }

      for (const recipeLine of recipe.lines) {
        const amount = new Prisma.Decimal(recipeLine.quantityPerSaleUnit).mul(line.quantity);
        const previous = consumption.get(recipeLine.stockItemId) ?? zero;
        consumption.set(recipeLine.stockItemId, previous.plus(amount));
      }
    }

    const stockItemIds = [...consumption.keys()].sort();

    if (stockItemIds.length === 0) {
      return;
    }

    const stockItems = await tx.stockItem.findMany({
      where: { id: { in: stockItemIds } },
      select: { id: true, name: true, quantityScale: true },
    });
    const stockItemsById = new Map(stockItems.map((item) => [item.id, item]));

    const missingItems = stockItemIds.filter((id) => !stockItemsById.has(id));

    if (missingItems.length > 0) {
      throw apiError(500, 'STOCK_ITEM_MISSING', 'A recipe references a missing stock item', {
        details: { stockItemIds: missingItems },
      });
    }

    const lockedBalances = await tx.$queryRaw<
      { stockItemId: string; quantity: Prisma.Decimal; version: number }[]
    >`
      SELECT "stockItemId", "quantity", "version"
      FROM "stock_balances"
      WHERE "outletId" = ${outletId}::uuid
        AND "stockItemId"::text IN (${Prisma.join(stockItemIds)})
      ORDER BY "stockItemId"
      FOR UPDATE
    `;

    const balances = new Map(
      lockedBalances.map((row) => [
        row.stockItemId,
        { quantity: new Prisma.Decimal(row.quantity), version: row.version },
      ]),
    );

    const shortages = stockItemIds.flatMap((stockItemId) => {
      const item = stockItemsById.get(stockItemId)!;
      const required = consumption.get(stockItemId) ?? zero;
      const available = balances.get(stockItemId)?.quantity ?? zero;

      if (available.greaterThanOrEqualTo(required)) {
        return [];
      }

      return [
        {
          stockItemId,
          name: item.name,
          required: required.toFixed(item.quantityScale),
          available: available.toFixed(item.quantityScale),
          shortage: required.minus(available).toFixed(item.quantityScale),
        },
      ];
    });

    if (shortages.length > 0) {
      throw apiError(422, 'INSUFFICIENT_STOCK', 'Insufficient stock for this sale', {
        details: { shortages },
      });
    }

    await tx.stockMovement.createMany({
      data: stockItemIds.map((stockItemId) => ({
        outletId,
        stockItemId,
        delta: (consumption.get(stockItemId) ?? zero).negated(),
        type: StockMovementType.SALE,
        actorId,
        reason: `Sale ${saleId}`,
        sourceId: saleId,
      })),
    });

    for (const stockItemId of stockItemIds) {
      const balance = balances.get(stockItemId);
      const amount = consumption.get(stockItemId) ?? zero;

      if (!balance) {
        continue;
      }

      const updated = await tx.stockBalance.updateMany({
        where: {
          outletId,
          stockItemId,
          version: balance.version,
          quantity: { gte: amount },
        },
        data: {
          quantity: balance.quantity.minus(amount),
          version: { increment: 1 },
        },
      });

      if (updated.count !== 1) {
        throw apiError(
          409,
          'STOCK_CHANGED',
          'Stock changed while the sale was committing; retry with the same key',
          { retryable: true },
        );
      }
    }
  }
}
