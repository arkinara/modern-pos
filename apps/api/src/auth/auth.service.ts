import { Inject, Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { Role, SessionPlatform } from '@prisma/client';
import { apiError } from '../common/api-error';
import { PrismaService } from '../prisma/prisma.service';
import { AUTH_CONFIG, type AuthConfig } from './auth.config';
import { AuthUserProfile, SignInResult } from './auth.responses';
import type { AccessTokenPayload } from './auth.types';
import { PasswordService } from './password.service';
import { SessionService } from './session.service';
import { SignInRateLimiter } from './sign-in-rate-limiter.service';
import { TokenService } from './token.service';

export interface SignInInput {
  email: string;
  password: string;
  deviceId?: string;
}

export interface SignInContext {
  ip: string;
}

interface UserRecord {
  id: string;
  businessId: string;
  outletId: string | null;
  email: string;
  role: Role;
  active: boolean;
  passwordHash: string;
}

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly passwords: PasswordService,
    private readonly tokens: TokenService,
    private readonly sessions: SessionService,
    private readonly jwt: JwtService,
    private readonly limiter: SignInRateLimiter,
    @Inject(AUTH_CONFIG) private readonly config: AuthConfig,
  ) {}

  async signInMobile(input: SignInInput, context: SignInContext): Promise<SignInResult> {
    return this.signIn(input, SessionPlatform.MOBILE, context);
  }

  async signInWeb(input: SignInInput, context: SignInContext): Promise<SignInResult> {
    return this.signIn(input, SessionPlatform.WEB, context);
  }

  private async signIn(
    input: SignInInput,
    platform: SessionPlatform,
    context: SignInContext,
  ): Promise<SignInResult> {
    const email = input.email.trim().toLowerCase();
    const limiterKey = `${context.ip}:${email}`;
    this.limiter.assertAllowed(limiterKey);

    const user = (await this.prisma.user.findUnique({ where: { email } })) as UserRecord | null;

    if (!user || !user.active) {
      await this.passwords.verifyDummy(input.password);
      this.limiter.recordFailure(limiterKey);
      throw apiError(401, 'INVALID_CREDENTIALS', 'Email or password is incorrect');
    }

    const passwordValid = await this.passwords.verify(user.passwordHash, input.password);
    if (!passwordValid) {
      this.limiter.recordFailure(limiterKey);
      throw apiError(401, 'INVALID_CREDENTIALS', 'Email or password is incorrect');
    }

    this.limiter.reset(limiterKey);

    const csrfToken = platform === SessionPlatform.WEB ? this.tokens.createCsrfToken() : undefined;
    const issued = await this.sessions.createSession({
      userId: user.id,
      platform,
      deviceId: input.deviceId,
      csrfToken,
    });
    const accessToken = await this.issueAccessToken(user.id, issued.sessionId);
    const profile = await this.profileFor(user);

    return {
      accessToken,
      refreshToken: issued.refreshToken,
      expiresInSeconds: this.config.accessTokenTtlSeconds,
      csrfToken,
      refreshExpiresAt: issued.expiresAt,
      user: profile,
    };
  }

  async refreshMobile(refreshToken: string, deviceId: string): Promise<SignInResult> {
    const rotated = await this.sessions.rotateSession({
      refreshToken,
      platform: SessionPlatform.MOBILE,
      deviceId,
    });

    return this.buildRefreshedResult(rotated.userId, rotated.issued.sessionId, {
      refreshToken: rotated.issued.refreshToken,
      refreshExpiresAt: rotated.issued.expiresAt,
    });
  }

  async refreshWeb(refreshToken: string, csrfToken: string): Promise<SignInResult> {
    const rotated = await this.sessions.rotateSession({
      refreshToken,
      platform: SessionPlatform.WEB,
      csrfToken,
    });

    return this.buildRefreshedResult(rotated.userId, rotated.issued.sessionId, {
      refreshToken: rotated.issued.refreshToken,
      refreshExpiresAt: rotated.issued.expiresAt,
      csrfToken: rotated.issued.csrfToken,
    });
  }

  private async buildRefreshedResult(
    userId: string,
    sessionId: string,
    refresh: {
      refreshToken: string;
      refreshExpiresAt: Date;
      csrfToken?: string;
    },
  ): Promise<SignInResult> {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user || !user.active) {
      await this.sessions.revokeAllForUser(userId);
      throw apiError(401, 'SESSION_REVOKED', 'Session is no longer valid');
    }

    return {
      accessToken: await this.issueAccessToken(user.id, sessionId),
      refreshToken: refresh.refreshToken,
      expiresInSeconds: this.config.accessTokenTtlSeconds,
      csrfToken: refresh.csrfToken,
      refreshExpiresAt: refresh.refreshExpiresAt,
      user: await this.profileFor(user),
    };
  }

  async signOut(user: { sessionId: string }): Promise<void> {
    await this.sessions.revokeSession(user.sessionId);
  }

  /** Revokes every session for a user; call on password or role changes. */
  async revokeAllSessionsForUser(userId: string): Promise<number> {
    return this.sessions.revokeAllForUser(userId);
  }

  private async issueAccessToken(userId: string, sessionId: string): Promise<string> {
    const payload: AccessTokenPayload = {
      sub: userId,
      sid: sessionId,
      typ: 'access',
    };

    return this.jwt.signAsync(payload, {
      expiresIn: this.config.accessTokenTtlSeconds,
      issuer: this.config.jwtIssuer,
      secret: this.config.jwtSecret,
    });
  }

  private async profileFor(user: UserRecord): Promise<AuthUserProfile> {
    const outletIds =
      user.role === Role.OWNER
        ? (
            await this.prisma.outlet.findMany({
              where: { businessId: user.businessId },
              select: { id: true },
              orderBy: [{ createdAt: 'asc' }, { id: 'asc' }],
            })
          ).map((outlet) => outlet.id)
        : user.outletId
          ? [user.outletId]
          : [];

    return {
      id: user.id,
      email: user.email,
      role: user.role,
      outletIds,
    };
  }
}
