import { Injectable } from '@nestjs/common';
import { PaymentProvider } from '@prisma/client';
import { apiError } from '../common/api-error';

const DEFAULT_REPLAY_WINDOW_SECONDS = 300;

function readProvider(value: string | undefined): PaymentProvider {
  const normalized = (value ?? 'mock').trim().toLowerCase();

  if (normalized === 'mock') {
    return PaymentProvider.MOCK;
  }

  if (normalized === 'qris') {
    return PaymentProvider.QRIS;
  }

  throw apiError(
    503,
    'PAYMENT_PROVIDER_INVALID',
    'PAYMENT_PROVIDER must be either "mock" or "qris"',
  );
}

function readPositiveInteger(value: string | undefined, fallback: number): number {
  const parsed = Number(value);
  return Number.isInteger(parsed) && parsed > 0 ? parsed : fallback;
}

/**
 * Reads provider credentials from the process environment only. No secret is
 * ever written to a database, response or log line. The redacted descriptor is
 * safe to include in diagnostics.
 */
@Injectable()
export class PaymentConfigService {
  get provider(): PaymentProvider {
    return readProvider(process.env.PAYMENT_PROVIDER);
  }

  get providerName(): 'MOCK' | 'QRIS' {
    return this.provider === PaymentProvider.MOCK ? 'MOCK' : 'QRIS';
  }

  get replayWindowSeconds(): number {
    return readPositiveInteger(process.env.PAYMENT_WEBHOOK_REPLAY_SECONDS, DEFAULT_REPLAY_WINDOW_SECONDS);
  }

  get providerBaseUrl(): string | null {
    return process.env.PAYMENT_PROVIDER_BASE_URL?.trim() || null;
  }

  get providerApiKey(): string | null {
    return process.env.PAYMENT_PROVIDER_API_KEY?.trim() || null;
  }

  get webhookSecret(): string | null {
    return process.env.PAYMENT_WEBHOOK_SECRET?.trim() || null;
  }

  requireWebhookSecret(): string {
    const secret = this.webhookSecret;

    if (!secret) {
      throw apiError(
        503,
        'PROVIDER_NOT_CONFIGURED',
        'PAYMENT_WEBHOOK_SECRET is not configured; provider verification cannot run',
      );
    }

    return secret;
  }

  requireQrisCredentials(): { baseUrl: string; apiKey: string; secret: string } {
    const baseUrl = this.providerBaseUrl;
    const apiKey = this.providerApiKey;
    const secret = this.webhookSecret;

    if (!baseUrl || !apiKey || !secret) {
      throw apiError(
        503,
        'PROVIDER_NOT_CONFIGURED',
        'QRIS requires PAYMENT_PROVIDER_BASE_URL, PAYMENT_PROVIDER_API_KEY and PAYMENT_WEBHOOK_SECRET',
      );
    }

    return { baseUrl, apiKey, secret };
  }

  /** Credential names and configuration state, never credential values. */
  describe(): {
    provider: 'MOCK' | 'QRIS';
    webhookSecretConfigured: boolean;
    apiKeyConfigured: boolean;
    baseUrlConfigured: boolean;
    replayWindowSeconds: number;
    liveSandboxVerified: false;
  } {
    return {
      provider: this.providerName,
      webhookSecretConfigured: Boolean(this.webhookSecret),
      apiKeyConfigured: Boolean(this.providerApiKey),
      baseUrlConfigured: Boolean(this.providerBaseUrl),
      replayWindowSeconds: this.replayWindowSeconds,
      liveSandboxVerified: false,
    };
  }
}
