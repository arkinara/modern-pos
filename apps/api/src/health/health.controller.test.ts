import assert from 'node:assert/strict';
import { test } from 'node:test';
import { ServiceUnavailableException } from '@nestjs/common';
import { HealthController } from './health.controller';
import type { PrismaService } from '../prisma/prisma.service';

function controllerWithDatabase(healthy: boolean): HealthController {
  const prisma = {
    isHealthy: async () => healthy,
  } as unknown as PrismaService;

  return new HealthController(prisma);
}

test('health returns ok when the database responds', async () => {
  const result = await controllerWithDatabase(true).check();

  assert.equal(result.status, 'ok');
  assert.equal(result.database, 'up');
  assert.equal(result.service, 'modern-pos-api');
});

test('health fails closed when the database is unreachable', async () => {
  await assert.rejects(() => controllerWithDatabase(false).check(), ServiceUnavailableException);
});
