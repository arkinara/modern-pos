import { Injectable } from '@nestjs/common';
import { OrderChannel } from '@prisma/client';
import { apiError } from '../common/api-error';
import type { ChannelAdapter, ChannelAvailability } from './channel-adapter.types';
import { ChannelConfigService } from './channel-config.service';

class StaticChannelAdapter implements ChannelAdapter {
  constructor(
    readonly channel: OrderChannel,
    readonly label: string,
    readonly inboundWebhook: boolean,
    private readonly pendingReason: string | null = null,
  ) {}

  availability(): ChannelAvailability {
    return this.pendingReason === null ? 'AVAILABLE' : 'PENDING_CREDENTIALS';
  }

  reason(): string | null {
    return this.pendingReason;
  }
}

const pending = 'PENDING - requires channel account credentials';

@Injectable()
export class ChannelRegistryService {
  private readonly adapters = new Map<OrderChannel, ChannelAdapter>();

  constructor(private readonly config: ChannelConfigService) {
    this.register(new StaticChannelAdapter(OrderChannel.MANUAL, 'Manual counter entry', false));
    this.register(new StaticChannelAdapter(OrderChannel.PHONE, 'Phone order', false));
    this.register(
      new StaticChannelAdapter(OrderChannel.WEB, 'Signed web storefront webhook', true),
    );
    this.register(new StaticChannelAdapter(OrderChannel.GRABFOOD, 'GrabFood', true, pending));
    this.register(new StaticChannelAdapter(OrderChannel.SHOPEEFOOD, 'ShopeeFood', true, pending));
  }

  list(): ChannelAdapter[] {
    return [...this.adapters.values()];
  }

  find(channel: OrderChannel): ChannelAdapter | null {
    return this.adapters.get(channel) ?? null;
  }

  requireWebhookChannel(channel: OrderChannel): ChannelAdapter {
    const adapter = this.find(channel);

    if (!adapter || !adapter.inboundWebhook) {
      throw apiError(404, 'CHANNEL_NOT_FOUND', 'Channel does not accept inbound webhooks');
    }

    if (adapter.availability() !== 'AVAILABLE') {
      throw apiError(503, 'CHANNEL_PENDING_CREDENTIALS', adapter.reason() ?? pending);
    }

    if (channel === OrderChannel.WEB && !this.config.webhookConfigured) {
      throw apiError(
        503,
        'CHANNEL_NOT_CONFIGURED',
        'Inbound channel webhooks require CHANNEL_WEBHOOK_SECRET',
      );
    }

    return adapter;
  }

  private register(adapter: ChannelAdapter): void {
    this.adapters.set(adapter.channel, adapter);
  }
}
