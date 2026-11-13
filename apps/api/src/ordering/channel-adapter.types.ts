import { OrderChannel } from '@prisma/client';

export type ChannelAvailability = 'AVAILABLE' | 'PENDING_CREDENTIALS';

export interface ChannelDescriptor {
  channel: OrderChannel;
  label: string;
  availability: ChannelAvailability;
  reason: string | null;
  inboundWebhook: boolean;
}

/**
 * A channel adapter only translates an external delivery into the shared
 * ChannelOrderInput contract. Order, stock, payment and receipt semantics live
 * in one service, so adding a channel cannot fork those rules.
 */
export interface ChannelAdapter {
  readonly channel: OrderChannel;
  readonly label: string;
  readonly inboundWebhook: boolean;
  availability(): ChannelAvailability;
  reason(): string | null;
}
