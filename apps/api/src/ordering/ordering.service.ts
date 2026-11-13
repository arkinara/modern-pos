import { createHash, randomUUID } from 'node:crypto';
import { Injectable } from '@nestjs/common';
import {
  ChannelOrderState,
  ChannelPaymentMode,
  ChannelPaymentStatus,
  CustomerConsentSource,
  CustomerContactType,
  OrderChannel,
  Prisma,
  StockMovementType,
  StockPolicy,
} from '@prisma/client';
import type { AuthenticatedUser } from '../auth/auth.types';
import { apiError } from '../common/api-error';
import { PrismaService } from '../prisma/prisma.service';
import { calculateTotals, toWireMinor, type MoneyTotals } from '../sales/money';
import { verifyWebhookSignature } from '../payments/webhook-signature';
import { ChannelRegistryService } from './channel-registry.service';
import type { ChannelDescriptor } from './channel-adapter.types';
import { ChannelConfigService } from './channel-config.service';
import {
  ChannelCustomerDto,
  ChannelOrderCancelDto,
  ChannelOrderFulfillDto,
  ChannelOrderListQueryDto,
  ChannelOrderManualDto,
  ChannelOrderWebhookDto,
} from './dto/channel-order.dto';

const MAX_TRANSACTION_ATTEMPTS = 3;
const ZERO = new Prisma.Decimal(0);

type OrderWithRelations = Prisma.ChannelOrderGetPayload<{
  include: { lines: true; payments: true; events: true };
}>;

interface OrderLineInput {
  variantId: string;
  quantity: number;
}

interface CustomerSnapshot {
  id: string | null;
}

export interface ChannelOrderLineResponse {
  id: string;
  variantId: string;
  name: string;
  variantName: string;
  quantity: number;
  unitPriceMinor: number;
  lineSubtotalMinor: number;
  recipeVersion: number | null;
}

export interface ChannelOrderPaymentResponse {
  id: string;
  amountMinor: number;
  status: ChannelPaymentStatus;
  method: ChannelPaymentMode;
  reference: string | null;
  createdAt: string;
}

export interface ChannelOrderEventResponse {
  id: string;
  fromState: ChannelOrderState;
  toState: ChannelOrderState;
  actorId: string | null;
  reason: string;
  createdAt: string;
}

export interface ChannelOrderResponse {
  id: string;
  outletId: string;
  channel: OrderChannel;
  channelReference: string;
  state: ChannelOrderState;
  paymentMode: ChannelPaymentMode;
  paymentStatus: ChannelPaymentStatus;
  currency: string;
  currencyExponent: number;
  subtotalMinor: number;
  serviceMinor: number;
  taxMinor: number;
  totalMinor: number;
  note: string;
  customerId: string | null;
  acceptedAt: string | null;
  fulfilledAt: string | null;
  cancelledAt: string | null;
  cancellationReason: string | null;
  createdAt: string;
  updatedAt: string;
  version: number;
  lines: ChannelOrderLineResponse[];
  payments: ChannelOrderPaymentResponse[];
  events: ChannelOrderEventResponse[];
}

export interface ChannelOrderListResponse {
  items: ChannelOrderResponse[];
}

export interface ChannelOrderCreateResponse {
  duplicate: boolean;
  order: ChannelOrderResponse;
}

export interface ChannelListResponse {
  items: ChannelDescriptor[];
  webhook: { configured: boolean; replayWindowSeconds: number };
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

function requestHash(value: Record<string, unknown>): string {
  return createHash('sha256').update(JSON.stringify(value)).digest('hex');
}

function normaliseContact(
  contact: string,
  type: CustomerContactType,
): { normalised: string; email: string | null; phone: string | null } {
  const trimmed = contact.trim();

  if (type === CustomerContactType.EMAIL) {
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(trimmed)) {
      throw apiError(422, 'CUSTOMER_CONTACT_INVALID', 'Email contact is not a valid address');
    }
    const email = trimmed.toLowerCase();
    return { normalised: email, email, phone: null };
  }

  const phone = trimmed.replace(/[\s().-]/g, '');
  if (!/^\+?\d{7,20}$/.test(phone)) {
    throw apiError(422, 'CUSTOMER_CONTACT_INVALID', 'Phone contact is not a valid number');
  }
  return { normalised: phone.replace(/^\+/, ''), email: null, phone };
}

@Injectable()
export class OrderingService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly registry: ChannelRegistryService,
    private readonly config: ChannelConfigService,
  ) {}

  listChannels(outletId: string, user: AuthenticatedUser): Promise<ChannelListResponse> {
    return this.requireOutlet(this.prisma, outletId, user.businessId).then(() => ({
      items: this.registry.list().map((adapter) => ({
        channel: adapter.channel,
        label: adapter.label,
        availability: adapter.availability(),
        reason: adapter.reason(),
        inboundWebhook: adapter.inboundWebhook,
      })),
      webhook: {
        configured: this.config.webhookConfigured,
        replayWindowSeconds: this.config.replayWindowSeconds,
      },
    }));
  }

  async createManual(
    outletId: string,
    dto: ChannelOrderManualDto,
    user: AuthenticatedUser,
  ): Promise<ChannelOrderCreateResponse> {
    const outlet = await this.requireOutlet(this.prisma, outletId, user.businessId);
    return this.createOrder({
      outlet,
      channel: dto.channel,
      reference: dto.reference,
      items: dto.items,
      customer: dto.customer,
      note: dto.note ?? '',
      paymentMode: dto.paymentMode ?? ChannelPaymentMode.CASH_ON_PICKUP,
      actorId: user.id,
    });
  }

  async handleWebhook(
    channelParam: string,
    signatureHeader: string | undefined,
    rawBody: string,
    dto: ChannelOrderWebhookDto,
  ): Promise<ChannelOrderCreateResponse> {
    const channel = this.parseChannel(channelParam);
    this.registry.requireWebhookChannel(channel);

    const verification = verifyWebhookSignature({
      secret: this.config.requireWebhookSecret(),
      header: signatureHeader,
      rawBody,
      windowSeconds: this.config.replayWindowSeconds,
    });

    if (!verification.ok) {
      const stale = verification.reason === 'STALE';
      throw apiError(
        401,
        stale ? 'CHANNEL_TIMESTAMP_INVALID' : 'CHANNEL_SIGNATURE_INVALID',
        stale
          ? 'Channel webhook timestamp is outside the replay window'
          : 'Channel webhook signature is missing or invalid',
      );
    }

    const outlet = await this.prisma.outlet.findUnique({ where: { id: dto.outletId } });
    if (!outlet) {
      throw apiError(404, 'NOT_FOUND', 'Outlet not found');
    }

    return this.createOrder({
      outlet,
      channel,
      reference: dto.reference,
      items: dto.items,
      customer: dto.customer,
      note: dto.note ?? '',
      paymentMode: dto.paymentMode ?? ChannelPaymentMode.CASH_ON_PICKUP,
      actorId: null,
    });
  }

  async list(
    outletId: string,
    query: ChannelOrderListQueryDto,
    user: AuthenticatedUser,
  ): Promise<ChannelOrderListResponse> {
    await this.requireOutlet(this.prisma, outletId, user.businessId);
    const search = query.search?.trim();

    const orders = await this.prisma.channelOrder.findMany({
      where: {
        outletId,
        businessId: user.businessId,
        ...(query.state ? { state: query.state } : {}),
        ...(query.channel ? { channel: query.channel } : {}),
        ...(search
          ? {
              OR: [
                { channelReference: { contains: search, mode: 'insensitive' } },
                { note: { contains: search, mode: 'insensitive' } },
              ],
            }
          : {}),
      },
      include: { lines: true, payments: true, events: true },
      orderBy: [{ createdAt: 'desc' }, { id: 'desc' }],
      take: query.limit ?? 50,
    });

    return { items: orders.map((order) => this.toResponse(order)) };
  }

  async get(
    outletId: string,
    orderId: string,
    user: AuthenticatedUser,
  ): Promise<ChannelOrderResponse> {
    await this.requireOutlet(this.prisma, outletId, user.businessId);
    const order = await this.prisma.channelOrder.findFirst({
      where: { id: orderId, outletId, businessId: user.businessId },
      include: { lines: true, payments: true, events: true },
    });

    if (!order) {
      throw apiError(404, 'NOT_FOUND', 'Channel order not found');
    }

    return this.toResponse(order);
  }

  async accept(
    outletId: string,
    orderId: string,
    user: AuthenticatedUser,
  ): Promise<ChannelOrderResponse> {
    return this.runSerializable(
      () =>
        this.prisma.$transaction(
          async (tx) => {
            const outlet = await this.requireOutlet(tx, outletId, user.businessId);
            const order = await this.lockOrder(tx, outletId, user.businessId, orderId);

            if (order.state !== ChannelOrderState.RECEIVED) {
              throw apiError(
                409,
                'ORDER_STATE_INVALID',
                `Order cannot be accepted from state ${order.state}`,
              );
            }

            await this.consumeStock(tx, outlet, order, user.id);

            const updated = await tx.channelOrder.updateMany({
              where: { id: order.id, state: ChannelOrderState.RECEIVED, version: order.version },
              data: {
                state: ChannelOrderState.ACCEPTED,
                acceptedAt: new Date(),
                version: { increment: 1 },
              },
            });

            if (updated.count !== 1) {
              throw apiError(409, 'VERSION_CONFLICT', 'Order was changed by another request');
            }

            await tx.channelOrderEvent.create({
              data: {
                orderId: order.id,
                fromState: ChannelOrderState.RECEIVED,
                toState: ChannelOrderState.ACCEPTED,
                actorId: user.id,
                reason: 'Order accepted; stock consumed at acceptance',
              },
            });

            return this.reload(tx, order.id);
          },
          { isolationLevel: Prisma.TransactionIsolationLevel.Serializable },
        ),
      'Order acceptance',
    );
  }

  async cancel(
    outletId: string,
    orderId: string,
    dto: ChannelOrderCancelDto,
    user: AuthenticatedUser,
  ): Promise<ChannelOrderResponse> {
    return this.runSerializable(
      () =>
        this.prisma.$transaction(
          async (tx) => {
            await this.requireOutlet(tx, outletId, user.businessId);
            const order = await this.lockOrder(tx, outletId, user.businessId, orderId);

            if (
              order.state !== ChannelOrderState.RECEIVED &&
              order.state !== ChannelOrderState.ACCEPTED
            ) {
              throw apiError(
                409,
                'ORDER_STATE_INVALID',
                `Order cannot be cancelled from state ${order.state}`,
              );
            }

            if (order.state === ChannelOrderState.ACCEPTED) {
              await this.restoreStock(tx, order, user.id);
            }

            const updated = await tx.channelOrder.updateMany({
              where: { id: order.id, state: order.state, version: order.version },
              data: {
                state: ChannelOrderState.CANCELLED,
                cancelledAt: new Date(),
                cancellationReason: dto.reason,
                version: { increment: 1 },
              },
            });

            if (updated.count !== 1) {
              throw apiError(409, 'VERSION_CONFLICT', 'Order was changed by another request');
            }

            await tx.channelOrderEvent.create({
              data: {
                orderId: order.id,
                fromState: order.state,
                toState: ChannelOrderState.CANCELLED,
                actorId: user.id,
                reason: dto.reason,
              },
            });

            return this.reload(tx, order.id);
          },
          { isolationLevel: Prisma.TransactionIsolationLevel.Serializable },
        ),
      'Order cancellation',
    );
  }

  async fulfill(
    outletId: string,
    orderId: string,
    dto: ChannelOrderFulfillDto,
    user: AuthenticatedUser,
  ): Promise<ChannelOrderResponse> {
    const collectedMinor = BigInt(dto.collectedMinor);

    return this.runSerializable(
      () =>
        this.prisma.$transaction(
          async (tx) => {
            await this.requireOutlet(tx, outletId, user.businessId);
            const order = await this.lockOrder(tx, outletId, user.businessId, orderId);

            if (order.state !== ChannelOrderState.ACCEPTED) {
              throw apiError(
                409,
                'ORDER_STATE_INVALID',
                `Order cannot be fulfilled from state ${order.state}`,
              );
            }

            if (order.paymentMode !== ChannelPaymentMode.CASH_ON_PICKUP) {
              throw apiError(
                422,
                'PAYMENT_MODE_UNAVAILABLE',
                'Only cash on pickup is enforced in this release',
              );
            }

            if (collectedMinor !== order.totalMinor) {
              throw apiError(
                422,
                'PAYMENT_AMOUNT_MISMATCH',
                'Collected cash must equal the order total',
                {
                  details: {
                    collectedMinor: toWireMinor(collectedMinor, 'collectedMinor'),
                    totalMinor: toWireMinor(order.totalMinor, 'totalMinor'),
                  },
                },
              );
            }

            await tx.channelOrderPayment.create({
              data: {
                orderId: order.id,
                amountMinor: collectedMinor,
                status: ChannelPaymentStatus.PAID,
                method: ChannelPaymentMode.CASH_ON_PICKUP,
                reference: dto.reference ?? null,
                recordedById: user.id,
              },
            });

            const updated = await tx.channelOrder.updateMany({
              where: { id: order.id, state: ChannelOrderState.ACCEPTED, version: order.version },
              data: {
                state: ChannelOrderState.FULFILLED,
                paymentStatus: ChannelPaymentStatus.PAID,
                fulfilledAt: new Date(),
                version: { increment: 1 },
              },
            });

            if (updated.count !== 1) {
              throw apiError(409, 'VERSION_CONFLICT', 'Order was changed by another request');
            }

            await tx.channelOrderEvent.create({
              data: {
                orderId: order.id,
                fromState: ChannelOrderState.ACCEPTED,
                toState: ChannelOrderState.FULFILLED,
                actorId: user.id,
                reason: 'Collected on pickup',
              },
            });

            return this.reload(tx, order.id);
          },
          { isolationLevel: Prisma.TransactionIsolationLevel.Serializable },
        ),
      'Order fulfilment',
    );
  }

  private async createOrder(input: {
    outlet: {
      id: string;
      businessId: string;
      currency: string;
      currencyExponent: number;
      serviceBps: number;
      taxBps: number;
    };
    channel: OrderChannel;
    reference: string;
    items: OrderLineInput[];
    customer?: ChannelCustomerDto;
    note: string;
    paymentMode: ChannelPaymentMode;
    actorId: string | null;
  }): Promise<ChannelOrderCreateResponse> {
    if (input.paymentMode === ChannelPaymentMode.PREPAID_PROVIDER) {
      throw apiError(
        422,
        'PAYMENT_MODE_UNAVAILABLE',
        'Prepaid provider orders are PENDING - requires provider credentials',
      );
    }

    const reference = input.reference.trim();
    const hash = requestHash({
      outletId: input.outlet.id,
      channel: input.channel,
      reference,
      items: input.items.map((item) => ({ variantId: item.variantId, quantity: item.quantity })),
      note: input.note,
      paymentMode: input.paymentMode,
      customer: input.customer
        ? {
            contact: input.customer.contact,
            contactType: input.customer.contactType,
            name: input.customer.name ?? null,
            consent: input.customer.consent,
          }
        : null,
    });

    const existing = await this.prisma.channelOrder.findUnique({
      where: {
        businessId_channel_channelReference: {
          businessId: input.outlet.businessId,
          channel: input.channel,
          channelReference: reference,
        },
      },
      include: { lines: true, payments: true, events: true },
    });

    if (existing) {
      if (existing.requestHash !== hash) {
        throw apiError(
          409,
          'CHANNEL_REFERENCE_CONFLICT',
          'The channel reference already exists with a different payload',
          { details: { orderId: existing.id } },
        );
      }
      return { duplicate: true, order: this.toResponse(existing) };
    }

    try {
      return await this.runSerializable(
        () =>
          this.prisma.$transaction(
            async (tx) => {
              const outlet = await this.requireOutlet(tx, input.outlet.id, input.outlet.businessId);
              const customer = input.customer
                ? await this.resolveCustomer(
                    tx,
                    outlet.id,
                    outlet.businessId,
                    input.customer,
                    input.channel,
                  )
                : { id: null };
              const snapshots = await this.priceLines(
                tx,
                outlet.id,
                outlet.businessId,
                input.items,
              );
              const totals = calculateTotals(
                snapshots.map((line) => ({
                  unitPriceMinor: line.unitPriceMinor,
                  quantity: line.quantity,
                })),
                outlet.serviceBps,
                outlet.taxBps,
              );

              const order = await tx.channelOrder.create({
                data: {
                  businessId: outlet.businessId,
                  outletId: outlet.id,
                  channel: input.channel,
                  channelReference: reference,
                  requestHash: hash,
                  state: ChannelOrderState.RECEIVED,
                  paymentMode: input.paymentMode,
                  paymentStatus: ChannelPaymentStatus.UNPAID,
                  currency: outlet.currency,
                  currencyExponent: outlet.currencyExponent,
                  subtotalMinor: totals.subtotalMinor,
                  serviceMinor: totals.serviceMinor,
                  taxMinor: totals.taxMinor,
                  totalMinor: totals.totalMinor,
                  note: input.note,
                  customerId: customer.id,
                  lines: {
                    create: snapshots.map((line) => ({
                      variantId: line.variantId,
                      name: line.name,
                      variantName: line.variantName,
                      quantity: line.quantity,
                      unitPriceMinor: line.unitPriceMinor,
                      lineSubtotalMinor: line.lineSubtotalMinor,
                      recipeVersion: line.recipeVersion,
                    })),
                  },
                  events: {
                    create: {
                      fromState: ChannelOrderState.RECEIVED,
                      toState: ChannelOrderState.RECEIVED,
                      actorId: input.actorId,
                      reason: `Received from ${input.channel}`,
                    },
                  },
                },
                include: { lines: true, payments: true, events: true },
              });

              return { duplicate: false, order: this.toResponse(order) };
            },
            { isolationLevel: Prisma.TransactionIsolationLevel.Serializable },
          ),
        'Order intake',
      );
    } catch (error) {
      if (isUniqueViolation(error)) {
        const duplicate = await this.prisma.channelOrder.findUnique({
          where: {
            businessId_channel_channelReference: {
              businessId: input.outlet.businessId,
              channel: input.channel,
              channelReference: reference,
            },
          },
          include: { lines: true, payments: true, events: true },
        });

        if (duplicate) {
          if (duplicate.requestHash !== hash) {
            throw apiError(
              409,
              'CHANNEL_REFERENCE_CONFLICT',
              'The channel reference already exists with a different payload',
              { details: { orderId: duplicate.id } },
            );
          }
          return { duplicate: true, order: this.toResponse(duplicate) };
        }
      }

      throw error;
    }
  }

  private async priceLines(
    tx: Prisma.TransactionClient,
    outletId: string,
    businessId: string,
    items: OrderLineInput[],
  ): Promise<
    {
      variantId: string;
      name: string;
      variantName: string;
      quantity: number;
      unitPriceMinor: bigint;
      lineSubtotalMinor: bigint;
      recipeVersion: number | null;
    }[]
  > {
    const variantIds = [...new Set(items.map((item) => item.variantId))];
    const variants = await tx.menuVariant.findMany({
      where: {
        id: { in: variantIds },
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

    const saleable = new Map(
      variants
        .filter(
          (variant) =>
            variant.active &&
            (variant.outletMenus[0]?.enabled ?? false) &&
            variant.menuItem.archivedAt === null &&
            variant.menuItem.category.archivedAt === null,
        )
        .map((variant) => [variant.id, variant]),
    );

    const missing = variantIds.filter((id) => !saleable.has(id));
    if (missing.length > 0) {
      throw apiError(
        422,
        'ITEM_UNAVAILABLE',
        'One or more variants are not saleable at this outlet',
        {
          details: { variantIds: missing },
        },
      );
    }

    const recipes = await tx.recipeVersion.findMany({
      where: { outletId, businessId, variantId: { in: variantIds } },
      orderBy: { version: 'asc' },
      select: { variantId: true, version: true },
    });
    const recipeVersions = new Map<string, number>();
    for (const recipe of recipes) {
      recipeVersions.set(recipe.variantId, recipe.version);
    }

    return items.map((item) => {
      const variant = saleable.get(item.variantId)!;
      const recipeVersion = recipeVersions.get(item.variantId) ?? null;

      if (variant.stockPolicy === StockPolicy.TRACKED && recipeVersion === null) {
        throw apiError(
          422,
          'RECIPE_REQUIRED',
          'Tracked variants require a published recipe before they can be sold',
          { details: { variantId: item.variantId } },
        );
      }

      return {
        variantId: item.variantId,
        name: variant.menuItem.name,
        variantName: variant.name,
        quantity: item.quantity,
        unitPriceMinor: variant.priceMinor,
        lineSubtotalMinor: variant.priceMinor * BigInt(item.quantity),
        recipeVersion,
      };
    });
  }

  private async resolveCustomer(
    tx: Prisma.TransactionClient,
    outletId: string,
    businessId: string,
    customer: ChannelCustomerDto,
    channel: OrderChannel,
  ): Promise<CustomerSnapshot> {
    if (!customer.consent) {
      throw apiError(
        422,
        'CUSTOMER_CONSENT_REQUIRED',
        'Customer records are opt-in and require explicit consent',
      );
    }

    const contact = normaliseContact(customer.contact, customer.contactType);
    const consentSource =
      customer.consentSource === CustomerConsentSource.IMPORT
        ? CustomerConsentSource.IMPORT
        : channel === OrderChannel.WEB
          ? CustomerConsentSource.WEB_CHECKOUT
          : CustomerConsentSource.STAFF_ENTRY;
    const existing = await tx.customer.findUnique({
      where: { outletId_contactNormalized: { outletId, contactNormalized: contact.normalised } },
    });

    if (existing) {
      if (existing.anonymizedAt !== null) {
        throw apiError(409, 'CUSTOMER_RETENTION_EXPIRED', 'This contact must be re-consented');
      }
      await tx.customer.update({
        where: { id: existing.id },
        data: {
          ...(customer.name ? { name: customer.name } : {}),
          consentAt: new Date(),
          consentSource,
        },
      });
      return { id: existing.id };
    }

    const created = await tx.customer.create({
      data: {
        businessId,
        outletId,
        name: customer.name?.trim() || 'Customer',
        contactType: customer.contactType,
        contactNormalized: contact.normalised,
        email: contact.email,
        phone: contact.phone,
        consentAt: new Date(),
        consentSource,
      },
    });

    return { id: created.id };
  }

  private async consumeStock(
    tx: Prisma.TransactionClient,
    outlet: { id: string; businessId: string },
    order: OrderWithRelations,
    actorId: string,
  ): Promise<void> {
    const variantIds = [...new Set(order.lines.map((line) => line.variantId))];
    const variants = await tx.menuVariant.findMany({
      where: { id: { in: variantIds }, menuItem: { businessId: outlet.businessId } },
      select: { id: true, stockPolicy: true },
    });
    const policies = new Map(variants.map((variant) => [variant.id, variant.stockPolicy]));
    const tracked = order.lines.flatMap((line) => {
      const policy = policies.get(line.variantId);
      if (!policy) {
        throw apiError(422, 'ITEM_UNAVAILABLE', 'A variant is no longer saleable', {
          details: { variantId: line.variantId },
        });
      }
      if (policy === StockPolicy.UNTRACKED) {
        return [];
      }
      if (line.recipeVersion === null) {
        throw apiError(422, 'RECIPE_REQUIRED', 'Tracked variants require a published recipe', {
          details: { variantId: line.variantId },
        });
      }
      return [line];
    });

    const pins = new Map<string, { variantId: string; version: number }>();
    for (const line of tracked) {
      pins.set(`${line.variantId}:${line.recipeVersion}`, {
        variantId: line.variantId,
        version: line.recipeVersion!,
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
          outletId: outlet.id,
          OR: [...pins.values()].map((pin) => ({ variantId: pin.variantId, version: pin.version })),
        },
        select: {
          variantId: true,
          version: true,
          lines: { select: { stockItemId: true, quantityPerSaleUnit: true } },
        },
      });
      for (const recipe of recipeRows) {
        recipeByPin.set(`${recipe.variantId}:${recipe.version}`, recipe);
      }
    }

    const consumption = new Map<string, Prisma.Decimal>();
    for (const line of tracked) {
      const recipe = recipeByPin.get(`${line.variantId}:${line.recipeVersion}`);
      if (!recipe) {
        throw apiError(409, 'RECIPE_SNAPSHOT_MISSING', 'The pinned recipe version is unavailable', {
          details: { variantId: line.variantId, recipeVersion: line.recipeVersion },
        });
      }
      for (const recipeLine of recipe.lines) {
        const amount = new Prisma.Decimal(recipeLine.quantityPerSaleUnit).mul(line.quantity);
        consumption.set(
          recipeLine.stockItemId,
          (consumption.get(recipeLine.stockItemId) ?? ZERO).plus(amount),
        );
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
    const itemsById = new Map(stockItems.map((item) => [item.id, item]));
    const missing = stockItemIds.filter((id) => !itemsById.has(id));
    if (missing.length > 0) {
      throw apiError(500, 'STOCK_ITEM_MISSING', 'A recipe references a missing stock item', {
        details: { stockItemIds: missing },
      });
    }

    const lockedBalances = await tx.$queryRaw<
      { stockItemId: string; quantity: Prisma.Decimal; version: number }[]
    >`
      SELECT "stockItemId", "quantity", "version"
      FROM "stock_balances"
      WHERE "outletId" = ${outlet.id}::uuid
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
      const item = itemsById.get(stockItemId)!;
      const required = consumption.get(stockItemId) ?? ZERO;
      const available = balances.get(stockItemId)?.quantity ?? ZERO;
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
      throw apiError(422, 'INSUFFICIENT_STOCK', 'Insufficient stock to accept this order', {
        details: { shortages },
      });
    }

    await tx.stockMovement.createMany({
      data: stockItemIds.map((stockItemId) => ({
        outletId: outlet.id,
        stockItemId,
        delta: (consumption.get(stockItemId) ?? ZERO).negated(),
        type: StockMovementType.CHANNEL_ORDER_ACCEPT,
        actorId,
        reason: `Channel order ${order.id} acceptance`,
        sourceId: order.id,
      })),
    });

    for (const stockItemId of stockItemIds) {
      const balance = balances.get(stockItemId);
      const amount = consumption.get(stockItemId) ?? ZERO;
      if (!balance) {
        continue;
      }
      const updated = await tx.stockBalance.updateMany({
        where: {
          outletId: outlet.id,
          stockItemId,
          version: balance.version,
          quantity: { gte: amount },
        },
        data: { quantity: balance.quantity.minus(amount), version: { increment: 1 } },
      });
      if (updated.count !== 1) {
        throw apiError(409, 'STOCK_CHANGED', 'Stock changed while accepting the order; retry', {
          retryable: true,
        });
      }
    }
  }

  private async restoreStock(
    tx: Prisma.TransactionClient,
    order: OrderWithRelations,
    actorId: string,
  ): Promise<void> {
    const movements = await tx.stockMovement.findMany({
      where: { sourceId: order.id, type: StockMovementType.CHANNEL_ORDER_ACCEPT },
      select: { stockItemId: true, delta: true },
    });

    if (movements.length === 0) {
      return;
    }

    const restore = new Map<string, Prisma.Decimal>();
    for (const movement of movements) {
      const amount = new Prisma.Decimal(movement.delta).negated();
      restore.set(movement.stockItemId, (restore.get(movement.stockItemId) ?? ZERO).plus(amount));
    }

    const stockItemIds = [...restore.keys()].sort();
    const lockedBalances = await tx.$queryRaw<
      { stockItemId: string; quantity: Prisma.Decimal; version: number }[]
    >`
      SELECT "stockItemId", "quantity", "version"
      FROM "stock_balances"
      WHERE "outletId" = ${order.outletId}::uuid
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
      data: stockItemIds.map((stockItemId) => ({
        outletId: order.outletId,
        stockItemId,
        delta: restore.get(stockItemId) ?? ZERO,
        type: StockMovementType.CHANNEL_ORDER_CANCEL,
        actorId,
        reason: `Channel order ${order.id} cancellation`,
        sourceId: order.id,
      })),
    });

    for (const stockItemId of stockItemIds) {
      const balance = balances.get(stockItemId);
      const amount = restore.get(stockItemId) ?? ZERO;
      if (!balance) {
        throw apiError(500, 'STOCK_BALANCE_MISSING', 'A stock balance is missing for cancellation');
      }
      const updated = await tx.stockBalance.updateMany({
        where: { outletId: order.outletId, stockItemId, version: balance.version },
        data: { quantity: balance.quantity.plus(amount), version: { increment: 1 } },
      });
      if (updated.count !== 1) {
        throw apiError(409, 'STOCK_CHANGED', 'Stock changed while cancelling the order; retry', {
          retryable: true,
        });
      }
    }
  }

  private async lockOrder(
    tx: Prisma.TransactionClient,
    outletId: string,
    businessId: string,
    orderId: string,
  ): Promise<OrderWithRelations> {
    const rows = await tx.$queryRaw<{ id: string }[]>`
      SELECT "id"
      FROM "channel_orders"
      WHERE "id" = ${orderId}::uuid
        AND "outletId" = ${outletId}::uuid
        AND "businessId" = ${businessId}::uuid
      FOR UPDATE
    `;

    if (rows.length === 0) {
      throw apiError(404, 'NOT_FOUND', 'Channel order not found');
    }

    const order = await tx.channelOrder.findFirst({
      where: { id: orderId, outletId, businessId },
      include: { lines: true, payments: true, events: true },
    });

    if (!order) {
      throw apiError(404, 'NOT_FOUND', 'Channel order not found');
    }

    return order;
  }

  private async reload(
    tx: Prisma.TransactionClient,
    orderId: string,
  ): Promise<ChannelOrderResponse> {
    const order = await tx.channelOrder.findUniqueOrThrow({
      where: { id: orderId },
      include: { lines: true, payments: true, events: true },
    });
    return this.toResponse(order);
  }

  private async requireOutlet(
    client: Pick<PrismaService, 'outlet'> | Prisma.TransactionClient,
    outletId: string,
    businessId: string,
  ): Promise<{
    id: string;
    businessId: string;
    currency: string;
    currencyExponent: number;
    serviceBps: number;
    taxBps: number;
  }> {
    const outlet = await client.outlet.findFirst({
      where: { id: outletId, businessId },
      select: {
        id: true,
        businessId: true,
        currency: true,
        currencyExponent: true,
        serviceBps: true,
        taxBps: true,
      },
    });

    if (!outlet) {
      throw apiError(404, 'NOT_FOUND', 'Outlet not found');
    }

    return outlet;
  }

  private async runSerializable<T>(operation: () => Promise<T>, label: string): Promise<T> {
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
            `${label} could not commit due to concurrent activity; retry`,
            { retryable: true },
          );
        }
        await sleep(20 * attempt + Math.floor(Math.random() * 20));
      }
    }

    throw apiError(503, 'TRANSACTION_RETRY_EXHAUSTED', `${label} could not commit`, {
      retryable: true,
    });
  }

  private parseChannel(value: string): OrderChannel {
    const upper = value.toUpperCase();
    if (!Object.values(OrderChannel).includes(upper as OrderChannel)) {
      throw apiError(404, 'CHANNEL_NOT_FOUND', 'Unknown channel');
    }
    return upper as OrderChannel;
  }

  private toResponse(order: OrderWithRelations): ChannelOrderResponse {
    return {
      id: order.id,
      outletId: order.outletId,
      channel: order.channel,
      channelReference: order.channelReference,
      state: order.state,
      paymentMode: order.paymentMode,
      paymentStatus: order.paymentStatus,
      currency: order.currency,
      currencyExponent: order.currencyExponent,
      subtotalMinor: toWireMinor(order.subtotalMinor, 'subtotalMinor'),
      serviceMinor: toWireMinor(order.serviceMinor, 'serviceMinor'),
      taxMinor: toWireMinor(order.taxMinor, 'taxMinor'),
      totalMinor: toWireMinor(order.totalMinor, 'totalMinor'),
      note: order.note,
      customerId: order.customerId,
      acceptedAt: order.acceptedAt?.toISOString() ?? null,
      fulfilledAt: order.fulfilledAt?.toISOString() ?? null,
      cancelledAt: order.cancelledAt?.toISOString() ?? null,
      cancellationReason: order.cancellationReason,
      createdAt: order.createdAt.toISOString(),
      updatedAt: order.updatedAt.toISOString(),
      version: order.version,
      lines: order.lines.map((line) => ({
        id: line.id,
        variantId: line.variantId,
        name: line.name,
        variantName: line.variantName,
        quantity: line.quantity,
        unitPriceMinor: toWireMinor(line.unitPriceMinor, 'unitPriceMinor'),
        lineSubtotalMinor: toWireMinor(line.lineSubtotalMinor, 'lineSubtotalMinor'),
        recipeVersion: line.recipeVersion,
      })),
      payments: order.payments.map((payment) => ({
        id: payment.id,
        amountMinor: toWireMinor(payment.amountMinor, 'amountMinor'),
        status: payment.status,
        method: payment.method,
        reference: payment.reference,
        createdAt: payment.createdAt.toISOString(),
      })),
      events: order.events.map((event) => ({
        id: event.id,
        fromState: event.fromState,
        toState: event.toState,
        actorId: event.actorId,
        reason: event.reason,
        createdAt: event.createdAt.toISOString(),
      })),
    };
  }
}
