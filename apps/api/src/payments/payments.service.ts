import { Injectable } from '@nestjs/common';
import { PaymentKind, PaymentProvider, PaymentStatus, Prisma, SaleState } from '@prisma/client';
import type { AuthenticatedUser } from '../auth/auth.types';
import { apiError } from '../common/api-error';
import { PrismaService } from '../prisma/prisma.service';
import { MAX_SAFE_MINOR_NUMBER } from '../sales/money';
import { localDateRangeUtc, parseDateOnly } from '../sales/outlet-time';
import { PaymentConfigService } from './payment-config.service';
import type {
  PaymentProviderAdapter,
  ProviderPayment,
  ProviderPaymentStatus,
} from './payment-provider.types';
import { MockPaymentProviderService } from './mock-payment-provider.service';
import { QrisPaymentProviderService } from './qris-payment-provider.service';
import { PaymentListQueryDto, SettlementQueryDto } from './dto/settlement-query.dto';
import { verifyWebhookSignature } from './webhook-signature';

const PROVIDER_NAMES: Record<PaymentProvider, 'MOCK' | 'QRIS'> = {
  [PaymentProvider.MOCK]: 'MOCK',
  [PaymentProvider.QRIS]: 'QRIS',
};

export interface OnlinePaymentResponse {
  id: string;
  saleId: string;
  provider: 'MOCK' | 'QRIS';
  providerRef: string | null;
  status: PaymentStatus;
  amountMinor: number;
  refundedMinor: number;
  currency: string;
  currencyExponent: number;
  qrPayload: string | null;
  settledAt: string | null;
  failedAt: string | null;
  createdAt: string;
  updatedAt: string;
}

export interface OnlinePaymentListItem extends OnlinePaymentResponse {
  saleReference: string;
  saleCompletedAt: string;
}

export interface WebhookAck {
  received: true;
  duplicate: boolean;
  status: PaymentStatus | null;
  eventId: string;
}

export interface ReconciliationSummary {
  checked: number;
  settled: number;
  failed: number;
  unchanged: number;
  errors: { paymentId: string; code: string }[];
  items: OnlinePaymentResponse[];
}

export interface SettlementDayResponse {
  date: string;
  paymentCount: number;
  capturedMinor: number;
  refundedMinor: number;
  netMinor: number;
  pendingMinor: number;
  failedMinor: number;
}

export interface SettlementPaymentResponse {
  paymentId: string;
  saleId: string;
  saleReference: string;
  completedAt: string;
  status: PaymentStatus;
  capturedMinor: number;
  refundedMinor: number;
  netMinor: number;
  settledAt: string | null;
}

export interface SettlementReportResponse {
  from: string;
  to: string;
  timezone: string;
  currency: string;
  currencyExponent: number;
  onlineSaleTotalMinor: number;
  capturedMinor: number;
  refundedMinor: number;
  netMinor: number;
  pendingMinor: number;
  failedMinor: number;
  driftMinor: number;
  saleCount: number;
  days: SettlementDayResponse[];
  payments: SettlementPaymentResponse[];
  generatedAt: string;
}

export interface ProviderRefundResult {
  performed: boolean;
  providerRefundRef: string | null;
}

interface OnlinePaymentRow {
  id: string;
  businessId: string;
  outletId: string;
  saleId: string;
  provider: PaymentProvider;
  providerRef: string | null;
  status: PaymentStatus;
  amountMinor: bigint;
  refundedMinor: bigint;
  currency: string;
  currencyExponent: number;
  qrPayload: string | null;
  attempt: number;
  providerCreatedAt: Date | null;
  settledAt: Date | null;
  failedAt: Date | null;
  lastError: string | null;
  createdAt: Date;
  updatedAt: Date;
}

function wireMinor(value: bigint, field: string): number {
  if (value < 0n || value > BigInt(MAX_SAFE_MINOR_NUMBER)) {
    throw apiError(
      500,
      'MONEY_OUT_OF_RANGE',
      `${field} is outside the JavaScript safe-integer range`,
    );
  }

  return Number(value);
}

function isSerializationFailure(error: unknown): boolean {
  return (
    typeof error === 'object' &&
    error !== null &&
    (('code' in error && (error as { code?: string }).code === 'P2034') ||
      ('meta' in error &&
        (error as { meta?: { code?: string } }).meta?.code !== undefined &&
        ['40001', '40P01'].includes((error as { meta?: { code?: string } }).meta?.code ?? '')))
  );
}

function isUniqueViolation(error: unknown): boolean {
  return (
    typeof error === 'object' &&
    error !== null &&
    'code' in error &&
    (error as { code?: string }).code === 'P2002'
  );
}

function localDate(date: Date, timeZone: string): string {
  const parts = new Intl.DateTimeFormat('en-CA', {
    timeZone,
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  }).formatToParts(date);
  const read = (type: Intl.DateTimeFormatPartTypes): string =>
    parts.find((part) => part.type === type)?.value ?? '00';

  return `${read('year')}-${read('month')}-${read('day')}`;
}

@Injectable()
export class PaymentsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly config: PaymentConfigService,
    private readonly mockProvider: MockPaymentProviderService,
    private readonly qrisProvider: QrisPaymentProviderService,
  ) {}

  private adapter(): PaymentProviderAdapter {
    return this.config.provider === PaymentProvider.MOCK ? this.mockProvider : this.qrisProvider;
  }

  /** Called inside the finalize transaction; performs no provider network call. */
  async registerFinalizedSale(
    tx: Prisma.TransactionClient,
    input: {
      businessId: string;
      outletId: string;
      saleId: string;
      amountMinor: bigint;
      currency: string;
      currencyExponent: number;
    },
  ): Promise<void> {
    await tx.onlinePayment.create({
      data: {
        businessId: input.businessId,
        outletId: input.outletId,
        saleId: input.saleId,
        provider: this.config.provider,
        status: PaymentStatus.PENDING,
        amountMinor: input.amountMinor,
        currency: input.currency,
        currencyExponent: input.currencyExponent,
      },
    });
  }

  async createForSale(
    outletId: string,
    saleId: string,
    user: AuthenticatedUser,
  ): Promise<OnlinePaymentResponse> {
    const sale = await this.loadSale(outletId, saleId, user);
    let payment = sale.onlinePayment;

    if (!payment) {
      try {
        payment = await this.prisma.onlinePayment.create({
          data: {
            businessId: sale.businessId,
            outletId,
            saleId,
            provider: this.config.provider,
            status: PaymentStatus.PENDING,
            amountMinor: sale.totalMinor,
            currency: sale.currency,
            currencyExponent: sale.currencyExponent,
          },
        });
      } catch (error) {
        if (!isUniqueViolation(error)) {
          throw error;
        }

        const replay = await this.prisma.onlinePayment.findUnique({ where: { saleId } });
        if (!replay) {
          throw error;
        }
        payment = replay;
      }
    }

    if (payment.status === PaymentStatus.FAILED) {
      const reset = await this.prisma.onlinePayment.updateMany({
        where: { id: payment.id, status: PaymentStatus.FAILED },
        data: {
          status: PaymentStatus.PENDING,
          providerRef: null,
          failedAt: null,
          lastError: null,
          attempt: { increment: 1 },
        },
      });
      if (reset.count === 1) {
        await this.prisma.paymentRecord.updateMany({
          where: { saleId, kind: PaymentKind.ONLINE },
          data: { status: PaymentStatus.PENDING },
        });
        const reread = await this.prisma.onlinePayment.findUnique({ where: { id: payment.id } });
        if (reread) {
          payment = reread;
        }
      }
    }

    if (payment.status !== PaymentStatus.PENDING) {
      return this.toResponse(payment);
    }

    if (!payment.providerRef) {
      const provider = await this.adapter().createPayment({
        idempotencyKey: payment.attempt > 1 ? `${payment.id}:retry:${payment.attempt}` : payment.id,
        amountMinor: payment.amountMinor,
        currency: payment.currency,
      });

      await this.prisma.onlinePayment.updateMany({
        where: { id: payment.id, status: PaymentStatus.PENDING, providerRef: null },
        data: {
          providerRef: provider.providerRef,
          qrPayload: provider.qrPayload ?? null,
          providerCreatedAt: new Date(),
        },
      });

      const reread = await this.prisma.onlinePayment.findUnique({ where: { id: payment.id } });
      if (reread) {
        payment = reread;
      }

      if (provider.status !== 'PENDING') {
        payment = await this.applyProviderStatus(payment.id, provider.status);
      }
    }

    return this.toResponse(payment);
  }

  async getForSale(
    outletId: string,
    saleId: string,
    user: AuthenticatedUser,
  ): Promise<OnlinePaymentResponse> {
    const sale = await this.loadSale(outletId, saleId, user);

    if (!sale.onlinePayment) {
      throw apiError(404, 'NOT_FOUND', 'No online payment exists for this sale');
    }

    return this.toResponse(sale.onlinePayment);
  }

  async list(
    outletId: string,
    query: PaymentListQueryDto,
    user: AuthenticatedUser,
  ): Promise<{ items: OnlinePaymentListItem[] }> {
    const rows = await this.prisma.onlinePayment.findMany({
      where: {
        businessId: user.businessId,
        outletId,
        ...(user.role === 'CASHIER' ? { sale: { is: { cashierId: user.id } } } : {}),
      },
      include: { sale: { select: { reference: true, completedAt: true } } },
      orderBy: [{ createdAt: 'desc' }, { id: 'desc' }],
      take: query.limit ?? 25,
    });

    return {
      items: rows.map((row) => ({
        ...this.toResponse(row),
        saleReference: row.sale.reference,
        saleCompletedAt: row.sale.completedAt.toISOString(),
      })),
    };
  }

  async schedule(
    outletId: string,
    saleId: string,
    user: AuthenticatedUser,
  ): Promise<OnlinePaymentResponse> {
    return this.createForSale(outletId, saleId, user);
  }

  async refresh(
    outletId: string,
    saleId: string,
    user: AuthenticatedUser,
  ): Promise<OnlinePaymentResponse> {
    const sale = await this.loadSale(outletId, saleId, user);

    if (!sale.onlinePayment) {
      throw apiError(404, 'NOT_FOUND', 'No online payment exists for this sale');
    }

    if (!sale.onlinePayment.providerRef) {
      return this.createForSale(outletId, saleId, user);
    }

    const provider = await this.adapter().fetchPayment(sale.onlinePayment.providerRef);
    const updated = await this.applyProviderStatus(sale.onlinePayment.id, provider.status);
    return this.toResponse(updated);
  }

  async reconcile(
    outletId: string,
    user: AuthenticatedUser,
    query?: SettlementQueryDto,
  ): Promise<ReconciliationSummary> {
    const outlet = await this.prisma.outlet.findFirst({
      where: { id: outletId, businessId: user.businessId },
      select: { timezone: true },
    });

    if (!outlet) {
      throw apiError(404, 'NOT_FOUND', 'Outlet not found');
    }

    const completedAt = query
      ? localDateRangeUtc(query.from, query.to, outlet.timezone)
      : undefined;

    const rows = await this.prisma.onlinePayment.findMany({
      where: {
        businessId: user.businessId,
        outletId,
        status: PaymentStatus.PENDING,
        providerRef: { not: null },
        ...(completedAt ? { sale: { is: { completedAt } } } : {}),
      },
      orderBy: [{ createdAt: 'asc' }, { id: 'asc' }],
    });

    let settled = 0;
    let failed = 0;
    let unchanged = 0;
    const errors: { paymentId: string; code: string }[] = [];
    const items: OnlinePaymentResponse[] = [];

    for (const row of rows) {
      try {
        const provider = await this.adapter().fetchPayment(row.providerRef as string);

        if (provider.status === 'SUCCEEDED') {
          const updated = await this.applyProviderStatus(row.id, 'SUCCEEDED');
          settled += 1;
          items.push(this.toResponse(updated));
          continue;
        }

        if (provider.status === 'FAILED') {
          const updated = await this.applyProviderStatus(row.id, 'FAILED');
          failed += 1;
          items.push(this.toResponse(updated));
          continue;
        }

        unchanged += 1;
        items.push(this.toResponse(row));
      } catch (error) {
        const code =
          typeof error === 'object' && error !== null && 'getResponse' in error
            ? ((error as { getResponse: () => { code?: string } }).getResponse().code ??
              'PROVIDER_ERROR')
            : 'PROVIDER_ERROR';
        errors.push({ paymentId: row.id, code });
        items.push(this.toResponse(row));
      }
    }

    return { checked: rows.length, settled, failed, unchanged, errors, items };
  }

  async handleWebhook(signatureHeader: string | undefined, rawBody: string): Promise<WebhookAck> {
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
        stale ? 'WEBHOOK_TIMESTAMP_INVALID' : 'WEBHOOK_SIGNATURE_INVALID',
        stale
          ? 'Webhook timestamp is outside the replay window'
          : 'Webhook signature is missing or invalid',
      );
    }

    let event: {
      id?: unknown;
      type?: unknown;
      provider?: unknown;
      data?: { providerRef?: unknown; amountMinor?: unknown };
    };

    try {
      event = JSON.parse(rawBody) as typeof event;
    } catch {
      throw apiError(400, 'WEBHOOK_PAYLOAD_INVALID', 'Webhook body must be valid JSON');
    }

    const eventId = typeof event.id === 'string' ? event.id.trim() : '';
    const eventType = typeof event.type === 'string' ? event.type : '';
    const providerRef = typeof event.data?.providerRef === 'string' ? event.data.providerRef : '';
    const providerName =
      typeof event.provider === 'string' ? event.provider : this.config.providerName;

    if (!eventId || !eventType || !providerRef) {
      throw apiError(
        400,
        'WEBHOOK_PAYLOAD_INVALID',
        'Webhook requires id, type and data.providerRef',
      );
    }

    if (providerName !== this.config.providerName) {
      throw apiError(
        401,
        'WEBHOOK_PROVIDER_MISMATCH',
        'Webhook provider does not match configuration',
      );
    }

    for (let attempt = 0; attempt < 5; attempt += 1) {
      try {
        const result = await this.prisma.$transaction(
          async (tx) => {
            await tx.$queryRaw`
              SELECT "id"
              FROM "online_payments"
              WHERE "providerRef" = ${providerRef}
              FOR UPDATE
            `;

            const payment = await tx.onlinePayment.findUnique({ where: { providerRef } });

            if (!payment) {
              await tx.paymentWebhookEvent.create({
                data: {
                  provider: this.config.provider,
                  eventId,
                  eventType,
                  payload: event as Prisma.InputJsonValue,
                  processedAt: new Date(),
                },
              });
              return { status: null as PaymentStatus | null, duplicate: false };
            }

            const amountMinor =
              event.data?.amountMinor === undefined ? null : BigInt(String(event.data.amountMinor));

            if (amountMinor !== payment.amountMinor) {
              throw apiError(
                422,
                'WEBHOOK_AMOUNT_MISMATCH',
                'Webhook amount does not match payment',
              );
            }

            await tx.paymentWebhookEvent.create({
              data: {
                provider: this.config.provider,
                eventId,
                eventType,
                onlinePaymentId: payment.id,
                payload: event as Prisma.InputJsonValue,
              },
            });

            const status = await this.transition(tx, payment, eventType);
            await tx.paymentWebhookEvent.updateMany({
              where: { provider: this.config.provider, eventId },
              data: { processedAt: new Date() },
            });

            return { status, duplicate: false };
          },
          { isolationLevel: Prisma.TransactionIsolationLevel.Serializable },
        );

        return {
          received: true,
          duplicate: result.duplicate,
          status: result.status,
          eventId,
        };
      } catch (error) {
        if (isUniqueViolation(error)) {
          return this.duplicateWebhookAck(eventId);
        }

        if (isSerializationFailure(error) && attempt < 4) {
          await new Promise((resolve) => setTimeout(resolve, 10 * (attempt + 1)));
          continue;
        }

        throw error;
      }
    }

    return this.duplicateWebhookAck(eventId);
  }

  private async duplicateWebhookAck(eventId: string): Promise<WebhookAck> {
    const existing = await this.prisma.paymentWebhookEvent.findUnique({
      where: { provider_eventId: { provider: this.config.provider, eventId } },
    });

    if (!existing) {
      throw apiError(
        503,
        'WEBHOOK_RETRY',
        'Webhook delivery conflicted with another delivery; retry the same event',
        { retryable: true },
      );
    }

    const payment = existing.onlinePaymentId
      ? await this.prisma.onlinePayment.findUnique({
          where: { id: existing.onlinePaymentId },
          select: { status: true },
        })
      : null;

    return {
      received: true,
      duplicate: true,
      status: payment?.status ?? null,
      eventId,
    };
  }

  async refundForReversal(input: {
    outletId: string;
    saleId: string;
    idempotencyKey: string;
    amountMinor: bigint;
    user: AuthenticatedUser;
  }): Promise<ProviderRefundResult> {
    const sale = await this.prisma.sale.findFirst({
      where: {
        id: input.saleId,
        outletId: input.outletId,
        businessId: input.user.businessId,
      },
      include: { payment: true, onlinePayment: true },
    });

    if (!sale || sale.payment?.kind !== PaymentKind.ONLINE) {
      return { performed: false, providerRefundRef: null };
    }

    const payment = sale.onlinePayment;

    if (input.amountMinor === 0n) {
      return { performed: false, providerRefundRef: null };
    }

    if (
      !payment ||
      (payment.status !== PaymentStatus.SUCCEEDED &&
        payment.status !== PaymentStatus.PARTIALLY_REFUNDED)
    ) {
      throw apiError(
        409,
        'PAYMENT_NOT_SETTLED',
        'An online payment must be settled before it can be refunded',
        { details: { status: payment?.status ?? null } },
      );
    }

    if (payment.refundedMinor + input.amountMinor > payment.amountMinor) {
      throw apiError(409, 'REFUND_EXCEEDS_PAYMENT', 'Refund exceeds the settled online payment', {
        details: {
          settledMinor: wireMinor(payment.amountMinor, 'amountMinor'),
          alreadyRefundedMinor: wireMinor(payment.refundedMinor, 'refundedMinor'),
          requestedMinor: wireMinor(input.amountMinor, 'refundMinor'),
        },
      });
    }

    if (!payment.providerRef) {
      throw apiError(409, 'PAYMENT_NOT_SETTLED', 'Online payment has no provider reference');
    }

    const refund = await this.adapter().refundPayment({
      providerRef: payment.providerRef,
      idempotencyKey: `reversal:${input.idempotencyKey}`,
      amountMinor: input.amountMinor,
    });

    return { performed: true, providerRefundRef: refund.providerRef };
  }

  async applyReversalRefund(
    tx: Prisma.TransactionClient,
    saleId: string,
    amountMinor: bigint,
  ): Promise<void> {
    const payment = await tx.onlinePayment.findUnique({ where: { saleId } });

    if (!payment) {
      return;
    }

    const refundedMinor = payment.refundedMinor + amountMinor;
    const status =
      refundedMinor >= payment.amountMinor
        ? PaymentStatus.REFUNDED
        : PaymentStatus.PARTIALLY_REFUNDED;

    await tx.onlinePayment.update({
      where: { id: payment.id },
      data: { refundedMinor, status },
    });
    await tx.paymentRecord.updateMany({
      where: { saleId, kind: PaymentKind.ONLINE },
      data: { status },
    });
  }

  async settlementReport(
    outletId: string,
    query: SettlementQueryDto,
    user: AuthenticatedUser,
  ): Promise<SettlementReportResponse> {
    const outlet = await this.prisma.outlet.findFirst({
      where: { id: outletId, businessId: user.businessId },
      select: { timezone: true, currency: true, currencyExponent: true },
    });

    if (!outlet) {
      throw apiError(404, 'NOT_FOUND', 'Outlet not found');
    }

    const completedAt = localDateRangeUtc(query.from, query.to, outlet.timezone);
    const sales = await this.prisma.sale.findMany({
      where: {
        businessId: user.businessId,
        outletId,
        state: SaleState.COMPLETED,
        completedAt,
        payment: { is: { kind: PaymentKind.ONLINE } },
      },
      include: {
        onlinePayment: true,
        reversals: { select: { refundMinor: true } },
      },
      orderBy: [{ completedAt: 'asc' }, { id: 'asc' }],
    });

    const days = new Map<string, SettlementDayResponse>();
    const payments: SettlementPaymentResponse[] = [];
    let onlineSaleTotalMinor = 0n;
    let capturedMinor = 0n;
    let refundedMinor = 0n;
    let pendingMinor = 0n;
    let failedMinor = 0n;

    for (const sale of sales) {
      const payment = sale.onlinePayment;
      onlineSaleTotalMinor += sale.totalMinor;

      if (!payment) {
        failedMinor += 0n;
        continue;
      }

      const captured =
        payment.status === PaymentStatus.SUCCEEDED ||
        payment.status === PaymentStatus.PARTIALLY_REFUNDED ||
        payment.status === PaymentStatus.REFUNDED
          ? payment.amountMinor
          : 0n;
      const refunded = sale.reversals.reduce((sum, reversal) => sum + reversal.refundMinor, 0n);
      const net = captured - refunded;
      const date = localDate(sale.completedAt, outlet.timezone);

      capturedMinor += captured;
      refundedMinor += refunded;
      if (payment.status === PaymentStatus.PENDING) {
        pendingMinor += payment.amountMinor;
      }
      if (payment.status === PaymentStatus.FAILED) {
        failedMinor += payment.amountMinor;
      }

      const day = days.get(date) ?? {
        date,
        paymentCount: 0,
        capturedMinor: 0,
        refundedMinor: 0,
        netMinor: 0,
        pendingMinor: 0,
        failedMinor: 0,
      };
      day.paymentCount += 1;
      day.capturedMinor += wireMinor(captured, 'capturedMinor');
      day.refundedMinor += wireMinor(refunded, 'refundedMinor');
      day.netMinor += wireMinor(net, 'netMinor');
      if (payment.status === PaymentStatus.PENDING) {
        day.pendingMinor += wireMinor(payment.amountMinor, 'pendingMinor');
      }
      if (payment.status === PaymentStatus.FAILED) {
        day.failedMinor += wireMinor(payment.amountMinor, 'failedMinor');
      }
      days.set(date, day);

      payments.push({
        paymentId: payment.id,
        saleId: sale.id,
        saleReference: sale.reference,
        completedAt: sale.completedAt.toISOString(),
        status: payment.status,
        capturedMinor: wireMinor(captured, 'capturedMinor'),
        refundedMinor: wireMinor(refunded, 'refundedMinor'),
        netMinor: wireMinor(net, 'netMinor'),
        settledAt: payment.settledAt?.toISOString() ?? null,
      });
    }

    const driftMinor = onlineSaleTotalMinor - (capturedMinor + pendingMinor + failedMinor);

    return {
      from: query.from,
      to: query.to,
      timezone: outlet.timezone,
      currency: outlet.currency,
      currencyExponent: outlet.currencyExponent,
      onlineSaleTotalMinor: wireMinor(onlineSaleTotalMinor, 'onlineSaleTotalMinor'),
      capturedMinor: wireMinor(capturedMinor, 'capturedMinor'),
      refundedMinor: wireMinor(refundedMinor, 'refundedMinor'),
      netMinor: wireMinor(capturedMinor - refundedMinor, 'netMinor'),
      pendingMinor: wireMinor(pendingMinor, 'pendingMinor'),
      failedMinor: wireMinor(failedMinor, 'failedMinor'),
      driftMinor: wireMinor(driftMinor, 'driftMinor'),
      saleCount: sales.length,
      days: [...days.values()].sort((a, b) => a.date.localeCompare(b.date)),
      payments,
      generatedAt: new Date().toISOString(),
    };
  }

  /** Reconciliation entry point used by tests and operators. */
  async reconcilePending(
    outletId: string,
    user: AuthenticatedUser,
  ): Promise<ReconciliationSummary> {
    return this.reconcile(outletId, user);
  }

  static assertDateQuery(query: SettlementQueryDto): void {
    parseDateOnly(query.from);
    parseDateOnly(query.to);
  }

  private async loadSale(
    outletId: string,
    saleId: string,
    user: AuthenticatedUser,
  ): Promise<{
    id: string;
    businessId: string;
    totalMinor: bigint;
    currency: string;
    currencyExponent: number;
    onlinePayment: OnlinePaymentRow | null;
    payment: { kind: PaymentKind } | null;
    state: SaleState;
  }> {
    const sale = await this.prisma.sale.findFirst({
      where: { id: saleId, outletId, businessId: user.businessId },
      select: {
        id: true,
        businessId: true,
        totalMinor: true,
        currency: true,
        currencyExponent: true,
        state: true,
        onlinePayment: true,
        payment: { select: { kind: true } },
      },
    });

    if (!sale) {
      throw apiError(404, 'NOT_FOUND', 'Sale not found');
    }

    if (sale.payment?.kind !== PaymentKind.ONLINE) {
      throw apiError(
        422,
        'PAYMENT_NOT_ONLINE',
        'This sale was recorded as a manual payment, not an online payment',
      );
    }

    if (sale.state !== SaleState.COMPLETED) {
      throw apiError(409, 'SALE_NOT_COMPLETED', 'Only completed sales can use online payment');
    }

    return sale;
  }

  private async applyProviderStatus(
    paymentId: string,
    status: ProviderPaymentStatus,
  ): Promise<OnlinePaymentRow> {
    return this.prisma.$transaction(async (tx) => {
      const updated = await this.transitionById(tx, paymentId, status);
      return updated;
    });
  }

  private async transitionById(
    tx: Prisma.TransactionClient,
    paymentId: string,
    status: ProviderPaymentStatus,
  ): Promise<OnlinePaymentRow> {
    await tx.$queryRaw`
      SELECT "id"
      FROM "online_payments"
      WHERE "id" = ${paymentId}::uuid
      FOR UPDATE
    `;
    const payment = await tx.onlinePayment.findUnique({ where: { id: paymentId } });

    if (!payment) {
      throw apiError(404, 'NOT_FOUND', 'Online payment not found');
    }

    await this.transition(tx, payment, `payment.${status.toLowerCase()}`);
    const reread = await tx.onlinePayment.findUnique({ where: { id: paymentId } });
    return reread as OnlinePaymentRow;
  }

  /**
   * Terminal-state rules: a captured payment wins over a late failure, a
   * failure cannot undo a capture, and refunds are never overwritten.
   */
  private async transition(
    tx: Prisma.TransactionClient,
    payment: {
      id: string;
      saleId: string;
      status: PaymentStatus;
      amountMinor: bigint;
    },
    eventType: string,
  ): Promise<PaymentStatus> {
    if (eventType === 'payment.succeeded') {
      if (payment.status === PaymentStatus.PENDING || payment.status === PaymentStatus.FAILED) {
        await tx.onlinePayment.update({
          where: { id: payment.id },
          data: { status: PaymentStatus.SUCCEEDED, settledAt: new Date(), failedAt: null },
        });
        await tx.paymentRecord.updateMany({
          where: { saleId: payment.saleId, kind: PaymentKind.ONLINE },
          data: { status: PaymentStatus.SUCCEEDED },
        });
        return PaymentStatus.SUCCEEDED;
      }
    }

    if (eventType === 'payment.failed') {
      if (payment.status === PaymentStatus.PENDING) {
        await tx.onlinePayment.update({
          where: { id: payment.id },
          data: {
            status: PaymentStatus.FAILED,
            failedAt: new Date(),
            lastError: 'Provider reported the payment as failed',
          },
        });
        await tx.paymentRecord.updateMany({
          where: { saleId: payment.saleId, kind: PaymentKind.ONLINE },
          data: { status: PaymentStatus.FAILED },
        });
        return PaymentStatus.FAILED;
      }
    }

    return payment.status;
  }

  private toResponse(row: OnlinePaymentRow): OnlinePaymentResponse {
    return {
      id: row.id,
      saleId: row.saleId,
      provider: PROVIDER_NAMES[row.provider],
      providerRef: row.providerRef,
      status: row.status,
      amountMinor: wireMinor(row.amountMinor, 'amountMinor'),
      refundedMinor: wireMinor(row.refundedMinor, 'refundedMinor'),
      currency: row.currency,
      currencyExponent: row.currencyExponent,
      qrPayload: row.qrPayload,
      settledAt: row.settledAt?.toISOString() ?? null,
      failedAt: row.failedAt?.toISOString() ?? null,
      createdAt: row.createdAt.toISOString(),
      updatedAt: row.updatedAt.toISOString(),
    };
  }
}
