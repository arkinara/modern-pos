import { Injectable } from '@nestjs/common';
import { apiError } from '../common/api-error';

const DEFAULT_REPLAY_SECONDS = 300;

@Injectable()
export class ChannelConfigService {
  get webhookSecret(): string | null {
    const value = process.env.CHANNEL_WEBHOOK_SECRET?.trim();
    return value ? value : null;
  }

  get replayWindowSeconds(): number {
    const raw = Number(process.env.CHANNEL_WEBHOOK_REPLAY_SECONDS ?? DEFAULT_REPLAY_SECONDS);
    return Number.isInteger(raw) && raw > 0 ? raw : DEFAULT_REPLAY_SECONDS;
  }

  get webhookConfigured(): boolean {
    return this.webhookSecret !== null;
  }

  requireWebhookSecret(): string {
    const secret = this.webhookSecret;

    if (!secret) {
      throw apiError(
        503,
        'CHANNEL_NOT_CONFIGURED',
        'Inbound channel webhooks require CHANNEL_WEBHOOK_SECRET',
      );
    }

    return secret;
  }

  describe(): { webhookConfigured: boolean; replayWindowSeconds: number } {
    return {
      webhookConfigured: this.webhookConfigured,
      replayWindowSeconds: this.replayWindowSeconds,
    };
  }
}
