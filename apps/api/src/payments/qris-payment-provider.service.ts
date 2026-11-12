import { Injectable } from '@nestjs/common';
import { apiError } from '../common/api-error';
import { PaymentConfigService } from './payment-config.service';
import type {
  CreateProviderPaymentInput,
  PaymentProviderAdapter,
  ProviderPayment,
  ProviderPaymentStatus,
  ProviderRefund,
  RefundProviderPaymentInput,
} from './payment-provider.types';

interface ProviderWirePayment {
  id?: string;
  providerRef?: string;
  status?: string;
  amountMinor?: number | string;
  currency?: string;
  qrPayload?: string | null;
  refundedMinor?: number | string;
}

function mapStatus(value: string | undefined): ProviderPaymentStatus {
  const normalized = (value ?? '').toUpperCase();

  if (['SUCCEEDED', 'SETTLED', 'PAID', 'CAPTURED'].includes(normalized)) {
    return 'SUCCEEDED';
  }

  if (['FAILED', 'DECLINED', 'EXPIRED', 'CANCELLED'].includes(normalized)) {
    return 'FAILED';
  }

  return 'PENDING';
}

/**
 * Configured real-provider surface. It is intentionally not exercised by the
 * automated suite: live sandbox verification is PENDING until credentials and
 * commercial setup exist. The adapter still validates configuration and refuses
 * rather than pretending a provider call succeeded.
 */
@Injectable()
export class QrisPaymentProviderService implements PaymentProviderAdapter {
  readonly name = 'QRIS' as const;

  constructor(private readonly config: PaymentConfigService) {}

  private async call(path: string, init?: RequestInit): Promise<ProviderWirePayment> {
    const { baseUrl, apiKey } = this.config.requireQrisCredentials();
    let response: Response;

    try {
      response = await fetch(`${baseUrl.replace(/\/$/, '')}${path}`, {
        ...init,
        headers: {
          Accept: 'application/json',
          'Content-Type': 'application/json',
          Authorization: `Bearer ${apiKey}`,
          ...init?.headers,
        },
      });
    } catch {
      throw apiError(
        502,
        'PROVIDER_UNREACHABLE',
        'The payment provider could not be reached; local state is unchanged',
        { retryable: true },
      );
    }

    if (!response.ok) {
      throw apiError(
        response.status === 404 ? 404 : 502,
        response.status === 404 ? 'PROVIDER_PAYMENT_NOT_FOUND' : 'PROVIDER_ERROR',
        'The payment provider rejected the request',
        { retryable: response.status >= 500 },
      );
    }

    return (await response.json()) as ProviderWirePayment;
  }

  async createPayment(input: CreateProviderPaymentInput): Promise<ProviderPayment> {
    const wire = await this.call('/payments', {
      method: 'POST',
      body: JSON.stringify({
        idempotencyKey: input.idempotencyKey,
        amountMinor: input.amountMinor.toString(),
        currency: input.currency,
      }),
      headers: { 'Idempotency-Key': input.idempotencyKey },
    });
    return this.toProviderPayment(wire);
  }

  async fetchPayment(providerRef: string): Promise<ProviderPayment> {
    const wire = await this.call(`/payments/${encodeURIComponent(providerRef)}`, {
      method: 'GET',
    });
    return this.toProviderPayment(wire);
  }

  async refundPayment(input: RefundProviderPaymentInput): Promise<ProviderRefund> {
    const wire = await this.call(`/payments/${encodeURIComponent(input.providerRef)}/refunds`, {
      method: 'POST',
      body: JSON.stringify({ amountMinor: input.amountMinor.toString() }),
      headers: { 'Idempotency-Key': input.idempotencyKey },
    });
    return {
      providerRef: wire.providerRef ?? wire.id ?? input.providerRef,
      refundedMinor: BigInt(wire.refundedMinor ?? '0'),
      status: mapStatus(wire.status),
    };
  }

  private toProviderPayment(wire: ProviderWirePayment): ProviderPayment {
    const providerRef = wire.providerRef ?? wire.id;

    if (!providerRef) {
      throw apiError(502, 'PROVIDER_ERROR', 'Provider response did not include a payment reference');
    }

    return {
      providerRef,
      status: mapStatus(wire.status),
      amountMinor: BigInt(wire.amountMinor ?? '0'),
      currency: wire.currency ?? '',
      qrPayload: wire.qrPayload ?? null,
      refundedMinor: BigInt(wire.refundedMinor ?? '0'),
    };
  }
}
