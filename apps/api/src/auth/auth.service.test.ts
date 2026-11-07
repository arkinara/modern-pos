import assert from 'node:assert/strict';
import { test } from 'node:test';
import { HttpException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { Role, SessionPlatform } from '@prisma/client';
import type { PrismaService } from '../prisma/prisma.service';
import type { AuthConfig } from './auth.config';
import { AuthService } from './auth.service';
import type { CreateSessionInput, IssuedSession, RotateSessionInput } from './session.service';
import type { SessionService } from './session.service';
import type { SignInRateLimiter } from './sign-in-rate-limiter.service';
import { testAuthConfig } from './test-support';

const USER = {
  id: 'user-1',
  businessId: 'business-1',
  outletId: 'outlet-1',
  email: 'owner@example.test',
  role: Role.OWNER,
  active: true,
  passwordHash: 'argon-hash',
};

class FakePrisma {
  userRecord: typeof USER | null = USER;
  readonly outlets = [{ id: 'outlet-1' }, { id: 'outlet-2' }];

  readonly user = {
    findUnique: async ({
      where,
    }: {
      where: { id?: string; email?: string };
    }): Promise<typeof USER | null> => {
      if (!this.userRecord) {
        return null;
      }
      if (where.id) {
        return where.id === this.userRecord.id ? this.userRecord : null;
      }
      return where.email === this.userRecord.email ? this.userRecord : null;
    },
  };

  readonly outlet = {
    findMany: async ({ where }: { where: { businessId: string } }): Promise<{ id: string }[]> => {
      return where.businessId === USER.businessId ? this.outlets : [];
    },
  };
}

interface FakeSessions extends Partial<SessionService> {
  created: CreateSessionInput[];
  rotated: RotateSessionInput[];
  revoked: string[];
  revokedAll: string[];
}

function build(
  options: {
    passwordValid?: boolean;
    userExists?: boolean;
    createSession?: (input: CreateSessionInput) => IssuedSession;
  } = {},
): {
  service: AuthService;
  prisma: FakePrisma;
  sessions: FakeSessions;
  passwords: {
    verifyCalls: Array<{ hash: string; password: string }>;
    dummyCalls: string[];
  };
  limiter: {
    allowed: string[];
    failures: string[];
    resets: string[];
  };
  config: AuthConfig;
} {
  const prisma = new FakePrisma();
  if (options.userExists === false) {
    prisma.userRecord = null;
  }

  const passwords = {
    verifyCalls: [] as Array<{ hash: string; password: string }>,
    dummyCalls: [] as string[],
    verify: async (hash: string, password: string) => {
      passwords.verifyCalls.push({ hash, password });
      return options.passwordValid ?? true;
    },
    verifyDummy: async (password: string) => {
      passwords.dummyCalls.push(password);
    },
  };

  const sessions: FakeSessions = {
    created: [],
    rotated: [],
    revoked: [],
    revokedAll: [],
    createSession: async (input: CreateSessionInput) => {
      sessions.created.push(input);
      return (
        options.createSession?.(input) ?? {
          sessionId: 'session-1',
          refreshToken: 'refresh-token',
          expiresAt: new Date(Date.now() + 60_000),
          platform: input.platform,
          csrfToken: input.csrfToken,
        }
      );
    },
    rotateSession: async (input: RotateSessionInput) => {
      sessions.rotated.push(input);
      return {
        userId: USER.id,
        issued: {
          sessionId: 'session-2',
          refreshToken: 'refresh-token-2',
          expiresAt: new Date(Date.now() + 60_000),
          platform: input.platform,
          csrfToken: input.platform === SessionPlatform.WEB ? 'csrf-2' : undefined,
        },
      };
    },
    revokeSession: async (sessionId: string) => {
      sessions.revoked.push(sessionId);
    },
    revokeAllForUser: async (userId: string) => {
      sessions.revokedAll.push(userId);
      return 2;
    },
  };

  const limiter = {
    allowed: [] as string[],
    failures: [] as string[],
    resets: [] as string[],
    assertAllowed: (key: string) => {
      limiter.allowed.push(key);
    },
    recordFailure: (key: string) => {
      limiter.failures.push(key);
    },
    reset: (key: string) => {
      limiter.resets.push(key);
    },
  };

  const jwt = {
    signAsync: async () => 'access-token',
  };

  const config = testAuthConfig();

  const service = new AuthService(
    prisma as unknown as PrismaService,
    passwords as never,
    { createCsrfToken: () => 'csrf-1' } as never,
    sessions as unknown as SessionService,
    jwt as unknown as JwtService,
    limiter as unknown as SignInRateLimiter,
    config,
  );

  return { service, prisma, sessions, passwords, limiter, config };
}

test('sign-in returns an access token, refresh token and owner outlet scope', async () => {
  const { service, sessions, limiter, config } = build();

  const result = await service.signInWeb(
    { email: '  OWNER@example.test ', password: 'correct' },
    { ip: '127.0.0.1' },
  );

  assert.equal(result.accessToken, 'access-token');
  assert.equal(result.refreshToken, 'refresh-token');
  assert.equal(result.expiresInSeconds, config.accessTokenTtlSeconds);
  assert.deepEqual(result.user.outletIds, ['outlet-1', 'outlet-2']);
  assert.equal(result.user.role, Role.OWNER);
  assert.equal(sessions.created[0]?.platform, SessionPlatform.WEB);
  assert.deepEqual(limiter.allowed, ['127.0.0.1:owner@example.test']);
  assert.deepEqual(limiter.resets, ['127.0.0.1:owner@example.test']);
});

test('wrong password and unknown users fail with the same 401 and count toward the limiter', async () => {
  const wrongPassword = build({ passwordValid: false });
  await assert.rejects(
    () =>
      wrongPassword.service.signInWeb(
        { email: 'owner@example.test', password: 'wrong' },
        { ip: '127.0.0.1' },
      ),
    (error: unknown) =>
      error instanceof HttpException &&
      error.getStatus() === 401 &&
      (error.getResponse() as { code: string }).code === 'INVALID_CREDENTIALS',
  );
  assert.deepEqual(wrongPassword.limiter.failures, ['127.0.0.1:owner@example.test']);

  const unknownUser = build({ userExists: false });
  await assert.rejects(
    () =>
      unknownUser.service.signInMobile(
        { email: 'missing@example.test', password: 'wrong', deviceId: 'device-1' },
        { ip: '127.0.0.1' },
      ),
    (error: unknown) =>
      error instanceof HttpException &&
      error.getStatus() === 401 &&
      (error.getResponse() as { code: string }).code === 'INVALID_CREDENTIALS',
  );
  assert.deepEqual(unknownUser.passwords.dummyCalls, ['wrong']);
  assert.deepEqual(unknownUser.limiter.failures, ['127.0.0.1:missing@example.test']);
});

test('refresh rotates the session and sign-out revokes the current session', async () => {
  const { service, sessions } = build();

  const refreshed = await service.refreshWeb('old-refresh', 'csrf-old');
  assert.equal(refreshed.refreshToken, 'refresh-token-2');
  assert.equal(refreshed.csrfToken, 'csrf-2');
  assert.equal(sessions.rotated[0]?.csrfToken, 'csrf-old');

  await service.signOut({ sessionId: 'session-1' });
  assert.deepEqual(sessions.revoked, ['session-1']);
});

test('revoking all sessions supports password and role changes', async () => {
  const { service, sessions } = build();

  const count = await service.revokeAllSessionsForUser(USER.id);

  assert.equal(count, 2);
  assert.deepEqual(sessions.revokedAll, [USER.id]);
});
