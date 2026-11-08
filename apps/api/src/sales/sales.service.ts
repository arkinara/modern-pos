import { createHash } from 'node:crypto';
import { Injectable } from '@nestjs/common';
import { OrderState, PaymentKind, PaymentStatus, Prisma, Role, SaleState } from '@prisma/client';
import type { AuthenticatedUser } from '../auth/auth.types';
import { apiError } from '../common/api-error';
import { PrismaService } from '../prisma/prisma.service';
import { CheckoutQueryDto } from './dto/checkout-query.dto';
import { FinalizeDto } from './dto/finalize.dto';
import { OrderCancelDto } from './dto/order-cancel.dto';
import { OrderCreateDto } from './dto/order-create.dto';
import { OrderUpdateDto } from './dto/order-update.dto';
import { QuoteCreateDto } from './dto/quote-create.dto';
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
}

type DbClient = Prisma.TransactionClient | PrismaService;

interface VariantPricingRecord {
  id: string;
  name: string;
  priceMinor: bigint;
  active: boolean;
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
  return error instanceof Prisma.PrismaClientKnownRequestError && error.code === 'P2034';
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
      include: { lines: { orderBy: [{ createdAt: 'asc' }, { id: 'asc' }] } },
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

        const order = await tx.order.create({
          data: {
            businessId: user.businessId,
            outletId: outlet.id,
            cashierId: user.id,
            deviceId: dto.deviceId,
            idempotencyKey,
            requestHash: hash,
            lines: {
              create: dto.lines.map((line) => ({
                variantId: line.variantId,
                quantity: line.quantity,
              })),
            },
          },
          include: { lines: { orderBy: [{ createdAt: 'asc' }, { id: 'asc' }] } },
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
          include: { lines: { orderBy: [{ createdAt: 'asc' }, { id: 'asc' }] } },
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
    });
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
      const snapshots = this.buildQuoteLines(order.lines, variants);
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
            const currentLines = this.buildQuoteLines(order.lines, variants, true);
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

            const snapshots = quotedLines;
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

  private async replayOrder(
    order: {
      requestHash: string;
      state: OrderState;
      version: number;
      id: string;
      deviceId: string;
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
    lines: { variantId: string; quantity: number }[];
  }> {
    const order = await client.order.findUnique({
      where: { id: orderId },
      include: { lines: { orderBy: [{ createdAt: 'asc' }, { id: 'asc' }] } },
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
        recipeVersion: null,
      };
    });
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
      quotedLines.every((line, index) => {
        const current = currentLines[index];
        return (
          current !== undefined &&
          line.variantId === current.variantId &&
          line.quantity === current.quantity &&
          line.unitPriceMinor === current.unitPriceMinor &&
          line.lineSubtotalMinor === current.lineSubtotalMinor
        );
      });

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
    lines: { variantId: string; quantity: number }[];
  }): OrderResponse {
    return {
      id: order.id,
      deviceId: order.deviceId,
      state: order.state,
      version: order.version,
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
    };
  }

  private async runSerializable<T>(operation: () => Promise<T>): Promise<T> {
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
            'Checkout could not commit due to concurrent activity; retry with the same key',
            { retryable: true },
          );
        }

        await sleep(20 * attempt + Math.floor(Math.random() * 20));
      }
    }

    throw apiError(503, 'TRANSACTION_RETRY_EXHAUSTED', 'Checkout could not commit', {
      retryable: true,
    });
  }

  private async applyStockConsumption(
    _tx: Prisma.TransactionClient,
    _context: {
      outletId: string;
      orderId: string;
      saleId: string;
      actorId: string;
    },
  ): Promise<void> {
    // Ticket #10 adds SALE stock movements and nonnegative balance guards here,
    // inside the same serializable transaction. Ticket #9 leaves stock untouched.
  }
}
