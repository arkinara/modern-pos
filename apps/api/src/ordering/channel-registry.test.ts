import assert from 'node:assert/strict';
import { afterEach, test } from 'node:test';
import { OrderChannel } from '@prisma/client';
import { ChannelConfigService } from './channel-config.service';
import { ChannelRegistryService } from './channel-registry.service';

const saved = new Map<string, string | undefined>();

function setEnv(values: Record<string, string | undefined>): void {
  for (const [key, value] of Object.entries(values)) {
    if (!saved.has(key)) {
      saved.set(key, process.env[key]);
    }
    if (value === undefined) {
      delete process.env[key];
    } else {
      process.env[key] = value;
    }
  }
}

afterEach(() => {
  for (const [key, value] of saved) {
    if (value === undefined) {
      delete process.env[key];
    } else {
      process.env[key] = value;
    }
  }
  saved.clear();
});

test('web channel is available only when a webhook secret exists', () => {
  setEnv({ CHANNEL_WEBHOOK_SECRET: undefined });
  const registry = new ChannelRegistryService(new ChannelConfigService());
  const web = registry.list().find((adapter) => adapter.channel === OrderChannel.WEB);

  assert.equal(web?.availability(), 'AVAILABLE');
  assert.equal(new ChannelConfigService().webhookConfigured, false);

  setEnv({ CHANNEL_WEBHOOK_SECRET: 'unit-test-channel-secret' });
  assert.equal(new ChannelConfigService().webhookConfigured, true);
});

test('third-party channels are documented as pending credentials', () => {
  const registry = new ChannelRegistryService(new ChannelConfigService());
  const grab = registry.list().find((adapter) => adapter.channel === OrderChannel.GRABFOOD);

  assert.equal(grab?.availability(), 'PENDING_CREDENTIALS');
  assert.match(grab?.reason() ?? '', /PENDING/);
  assert.throws(
    () => registry.requireWebhookChannel(OrderChannel.GRABFOOD),
    (error: unknown) =>
      typeof error === 'object' &&
      error !== null &&
      'getStatus' in error &&
      (error as { getStatus: () => number }).getStatus() === 503,
  );
});

test('manual and phone channels never expose an inbound webhook', () => {
  const registry = new ChannelRegistryService(new ChannelConfigService());
  const manual = registry.list().find((adapter) => adapter.channel === OrderChannel.MANUAL);

  assert.equal(manual?.inboundWebhook, false);
  assert.throws(
    () => registry.requireWebhookChannel(OrderChannel.MANUAL),
    (error: unknown) =>
      typeof error === 'object' &&
      error !== null &&
      'getStatus' in error &&
      (error as { getStatus: () => number }).getStatus() === 404,
  );
});
