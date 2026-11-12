import { randomUUID } from 'node:crypto';
import { Injectable } from '@nestjs/common';
import { PaymentProvider, PaymentStatus } from '@prisma/client';
import { apiError } from '../common/api-error';
import { PaymentConfigService } from './payment-config.service';
import { PrismaService } from '../prisma/prisma.service';
import { signWebhookPayload } from './webhook-signature';
import type {
  CreateProviderPaymentInput,
  PaymentProviderAdapter,
  ProviderPayment,
  ProviderPaymentStatus,
  ProviderRefund,
  RefundProviderPaymentInput,
} from './payment-provider.types';

function toProviderStatus(status: PaymentStatus): ProviderPaymentStatus {
  if (status === PaymentStatus.SUCCEEDED) {
    return 'SUCCEEDED';
  }

  if (status === PaymentStatus.FAILED) {
    return 'FAILED';
  }

  return 'PENDING';
}

function readRefundKeys(value: unknown): string[] {
  if (!Array.isArray(value)) {
    return [];
  }

  return value.filter((entry): entry is string => typeof entry === 'string');
}

/**
 * Deterministic local sandbox provider. The ledger lives in PostgreSQL so
 * reconciliation can be reproduced across requests and restarts. It is never
 * selected when a real provider is configured.
 */
@Injectable()
export class MockPaymentProviderService implements PaymentProviderAdapter {
  readonly name = 'MOCK' as const;

  constructor(
    private readonly prisma: PrismaService,
    private readonly config: PaymentConfigService,
  ) {}

  private toProviderPayment(row: {
    providerRef: string;
    status: PaymentStatus;
    amountMinor: bigint;
    currency: string;
    refundedMinor: bigint;
  }): ProviderPayment {
    return {
      providerRef: row.providerRef,
      status: toProviderStatus(row.status),
      amountMinor: row.amountMinor,
      currency: row.currency,
      qrPayload: `mock://qris/${row.providerRef}`,
      refundedMinor: row.refundedMinor,
    };
  }

  async createPayment(input: CreateProviderPaymentInput): Promise<ProviderPayment> {
    const existing = await this.prisma.sandboxProviderPayment.findUnique({
      where: { idempotencyKey: input.idempotencyKey },
    });

    if (existing) {
      return this.toProviderPayment(existing);
    }

    try {
      const created = await this.prisma.sandboxProviderPayment.create({
        data: {
          providerRef: `mock_${randomUUID()}`,
          idempotencyKey: input.idempotencyKey,
          amountMinor: input.amountMinor,
          currency: input.currency,
          status: PaymentStatus.PENDING,
        },
      });
      return this.toProviderPayment(created);
    } catch (error) {
      if (isUniqueViolation(error)) {
        const replay = await this.prisma.sandboxProviderPayment.findUnique({
          where: { idempotencyKey: input.idempotencyKey },
        });

        if (replay) {
          return this.toProviderPayment(replay);
        }
      }

      throw error;
    }
  }

  async fetchPayment(providerRef: string): Promise<ProviderPayment> {
    const row = await this.prisma.sandboxProviderPayment.findUnique({
      where: { providerRef },
    });

    if (!row) {
      throw apiError(404, 'PROVIDER_PAYMENT_NOT_FOUND', 'Provider has no record for this payment', {
        details: { providerRef },
      });
    }

    return this.toProviderPayment(row);
  }

  async refundPayment(input: RefundProviderPaymentInput): Promise<ProviderRefund> {
    const row = await this.prisma.sandboxProviderPayment.findUnique({
      where: { providerRef: input.providerRef },
    });

    if (!row) {
      throw apiError(404, 'PROVIDER_PAYMENT_NOT_FOUND', 'Provider has no record for this payment');
    }

    const keys = readRefundKeys(row.refundKeys);

    if (keys.includes(input.idempotencyKey)) {
      return {
        providerRef: `${row.providerRef}_refund_${input.idempotencyKey}`,
        refundedMinor: row.refundedMinor,
        status: toProviderStatus(row.status),
      };
    }

    if (row.status !== PaymentStatus.SUCCEEDED && row.status !== PaymentStatus.PARTIALLY_REFUNDED) {
      throw apiError(409, 'PROVIDER_REFUND_REJECTED', 'Provider payment is not settled', {
        details: { status: row.status },
      });
    }

    if (row.refundedMinor + input.amountMinor > row.amountMinor) {
      throw apiError(409, 'PROVIDER_REFUND_EXCEEDS_PAYMENT', 'Refund exceeds provider payment');
    }

    const refundedMinor = row.refundedMinor + input.amountMinor;
    const status =
      refundedMinor === row.amountMinor
        ? PaymentStatus.REFUNDED
        : PaymentStatus.PARTIALLY_REFUNDED;

    await this.prisma.sandboxProviderPayment.update({
      where: { id: row.id },
      data: { refundedMinor, status, refundKeys: [...keys, input.idempotencyKey] },
    });

    return {
      providerRef: `${row.providerRef}_refund_${input.idempotencyKey}`,
      refundedMinor,
      status: toProviderStatus(status),
    };
  }

  /**
   * Advances the sandbox ledger and returns a correctly signed webhook event.
   * The caller (or QA script) delivers it; nothing is claimed about a real
   * provider. Sending the same event id twice exercises dedupe.
   */
  async createEvent(
    providerRef: string,
    type: 'payment.pending' | 'payment.succeeded' | 'payment.failed',
    eventId?: string,
  ): Promise<{
    event: Record<string, unknown>;
    timestamp: number;
    signature: string;
    rawBody: string;
  }> {
    if (this.config.provider !== PaymentProvider.MOCK) {
      throw apiError(404, 'NOT_FOUND', 'Sandbox provider endpoints are disabled');
    }

    const row = await this.prisma.sandboxProviderPayment.findUnique({
      where: { providerRef },
    });

    if (!row) {
      throw apiError(404, 'PROVIDER_PAYMENT_NOT_FOUND', 'Provider has no record for this payment');
    }

    if (type === 'payment.succeeded' && row.status === PaymentStatus.PENDING) {
      await this.prisma.sandboxProviderPayment.update({
        where: { id: row.id },
        data: { status: PaymentStatus.SUCCEEDED },
      });
    }

    if (type === 'payment.failed' && row.status === PaymentStatus.PENDING) {
      await this.prisma.sandboxProviderPayment.update({
        where: { id: row.id },
        data: { status: PaymentStatus.FAILED },
      });
    }

    const event = {
      id: eventId ?? `evt_${randomUUID()}`,
      type,
      provider: 'MOCK',
      createdAt: new Date().toISOString(),
      data: {
        providerRef: row.providerRef,
        amountMinor: row.amountMinor.toString(),
        currency: row.currency,
      },
    };
    const rawBody = JSON.stringify(event);
    const timestamp = Math.floor(Date.now() / 1000);
    const signature = signWebhookPayload(this.config.requireWebhookSecret(), timestamp, rawBody);

    return { event, timestamp, signature, rawBody };
  }
}

function isUniqueViolation(error: unknown): boolean {
  return (
    typeof error === 'object' &&
    error !== null &&
    'code' in error &&
    (error as { code?: string }).code === 'P2002'
  );
}
