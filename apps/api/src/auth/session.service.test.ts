import assert from 'node:assert/strict';
import { test } from 'node:test';
import { HttpException } from '@nestjs/common';
import { SessionPlatform } from '@prisma/client';
import type { PrismaService } from '../prisma/prisma.service';
import { SessionService } from './session.service';
import { testAuthConfig } from './test-support';
import { TokenService } from './token.service';

interface FakeSession {
  id: string;
  userId: string;
  familyId: string;
  tokenHash: string;
  csrfHash: string | null;
  platform: SessionPlatform;
  deviceId: string | null;
  expiresAt: Date;
  revokedAt: Date | null;
  replacedById: string | null;
  createdAt: Date;
  lastUsedAt: Date;
}

interface FakeUser {
  id: string;
  active: boolean;
}

class FakePrisma {
  readonly sessions: FakeSession[] = [];
  readonly users = new Map<string, FakeUser>();

  readonly session = {
    findUnique: async ({ where }: { where: Partial<FakeSession> }): Promise<FakeSession | null> => {
      return this.sessions.find((session) => this.matches(session, where)) ?? null;
    },
    create: async ({ data }: { data: Partial<FakeSession> }): Promise<FakeSession> => {
      const session: FakeSession = {
        id: data.id ?? '',
        userId: data.userId ?? '',
        familyId: data.familyId ?? '',
        tokenHash: data.tokenHash ?? '',
        csrfHash: data.csrfHash ?? null,
        platform: data.platform ?? SessionPlatform.WEB,
        deviceId: data.deviceId ?? null,
        expiresAt: data.expiresAt ?? new Date(),
        revokedAt: null,
        replacedById: null,
        createdAt: new Date(),
        lastUsedAt: new Date(),
      };
      this.sessions.push(session);
      return session;
    },
    updateMany: async ({
      where,
      data,
    }: {
      where: Partial<FakeSession>;
      data: Partial<FakeSession>;
    }): Promise<{ count: number }> => {
      const matches = this.sessions.filter((session) => this.matches(session, where));
      for (const session of matches) {
        Object.assign(session, data);
      }
      return { count: matches.length };
    },
  };

  readonly user = {
    findUnique: async ({ where }: { where: { id: string } }): Promise<FakeUser | null> => {
      return this.users.get(where.id) ?? null;
    },
  };

  async $transaction<T>(callback: (tx: FakePrisma) => Promise<T>): Promise<T> {
    return callback(this);
  }

  private matches(session: FakeSession, where: Partial<FakeSession>): boolean {
    return Object.entries(where).every(([key, value]) => {
      return session[key as keyof FakeSession] === value;
    });
  }
}

const DEVICE_ID = '11111111-1111-4111-8111-111111111111';

function build(): {
  prisma: FakePrisma;
  service: SessionService;
  tokens: TokenService;
} {
  const prisma = new FakePrisma();
  prisma.users.set('user-1', { id: 'user-1', active: true });
  const tokens = new TokenService();
  const service = new SessionService(prisma as unknown as PrismaService, tokens, testAuthConfig());
  return { prisma, service, tokens };
}

test('refresh rotation is single-use and replay revokes the whole family', async () => {
  const { prisma, service } = build();
  const issued = await service.createSession({
    userId: 'user-1',
    platform: SessionPlatform.MOBILE,
    deviceId: DEVICE_ID,
  });

  const rotated = await service.rotateSession({
    refreshToken: issued.refreshToken,
    platform: SessionPlatform.MOBILE,
    deviceId: DEVICE_ID,
  });

  assert.notEqual(rotated.issued.refreshToken, issued.refreshToken);
  assert.equal(rotated.issued.expiresAt.getTime(), issued.expiresAt.getTime());

  const old = prisma.sessions.find((session) => session.id === issued.sessionId);
  assert.ok(old);
  assert.ok(old.revokedAt);
  assert.equal(old.replacedById, rotated.issued.sessionId);

  await assert.rejects(
    () =>
      service.rotateSession({
        refreshToken: issued.refreshToken,
        platform: SessionPlatform.MOBILE,
        deviceId: DEVICE_ID,
      }),
    (error: unknown) =>
      error instanceof HttpException &&
      error.getStatus() === 401 &&
      (error.getResponse() as { code: string }).code === 'REFRESH_TOKEN_REUSED',
  );

  const replacement = prisma.sessions.find((session) => session.id === rotated.issued.sessionId);
  assert.ok(replacement?.revokedAt);
});

test('expired refresh sessions are rejected and revoked', async () => {
  const { prisma, service } = build();
  const issued = await service.createSession({
    userId: 'user-1',
    platform: SessionPlatform.MOBILE,
    deviceId: DEVICE_ID,
  });

  const stored = prisma.sessions.find((session) => session.id === issued.sessionId);
  assert.ok(stored);
  stored.expiresAt = new Date(Date.now() - 1_000);

  await assert.rejects(
    () =>
      service.rotateSession({
        refreshToken: issued.refreshToken,
        platform: SessionPlatform.MOBILE,
        deviceId: DEVICE_ID,
      }),
    (error: unknown) =>
      error instanceof HttpException &&
      error.getStatus() === 401 &&
      (error.getResponse() as { code: string }).code === 'SESSION_EXPIRED',
  );

  assert.ok(stored.revokedAt);
});

test('web refresh requires the matching CSRF token', async () => {
  const { service } = build();
  const issued = await service.createSession({
    userId: 'user-1',
    platform: SessionPlatform.WEB,
    csrfToken: 'csrf-one',
  });

  await assert.rejects(
    () =>
      service.rotateSession({
        refreshToken: issued.refreshToken,
        platform: SessionPlatform.WEB,
        csrfToken: 'csrf-wrong',
      }),
    (error: unknown) => error instanceof HttpException && error.getStatus() === 403,
  );

  const rotated = await service.rotateSession({
    refreshToken: issued.refreshToken,
    platform: SessionPlatform.WEB,
    csrfToken: 'csrf-one',
  });

  assert.notEqual(rotated.issued.csrfToken, 'csrf-one');
});

test('mobile refresh sessions are bound to their device', async () => {
  const { service } = build();
  const issued = await service.createSession({
    userId: 'user-1',
    platform: SessionPlatform.MOBILE,
    deviceId: DEVICE_ID,
  });

  await assert.rejects(
    () =>
      service.rotateSession({
        refreshToken: issued.refreshToken,
        platform: SessionPlatform.MOBILE,
        deviceId: '22222222-2222-4222-8222-222222222222',
      }),
    (error: unknown) => error instanceof HttpException && error.getStatus() === 401,
  );
});

test('password or role changes can revoke every user session', async () => {
  const { prisma, service } = build();
  await service.createSession({
    userId: 'user-1',
    platform: SessionPlatform.MOBILE,
    deviceId: DEVICE_ID,
  });
  await service.createSession({
    userId: 'user-1',
    platform: SessionPlatform.WEB,
    csrfToken: 'csrf-two',
  });

  const revoked = await service.revokeAllForUser('user-1');

  assert.equal(revoked, 2);
  assert.equal(
    prisma.sessions.every((session) => session.revokedAt !== null),
    true,
  );
});
