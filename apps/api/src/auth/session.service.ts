import { Inject, Injectable } from '@nestjs/common';
import { SessionPlatform } from '@prisma/client';
import { apiError } from '../common/api-error';
import { PrismaService } from '../prisma/prisma.service';
import { AUTH_CONFIG, type AuthConfig } from './auth.config';
import { TokenService } from './token.service';

export interface CreateSessionInput {
  userId: string;
  platform: SessionPlatform;
  deviceId?: string;
  csrfToken?: string;
}

export interface IssuedSession {
  sessionId: string;
  refreshToken: string;
  expiresAt: Date;
  platform: SessionPlatform;
  csrfToken?: string;
}

export interface RotateSessionInput {
  refreshToken: string;
  platform: SessionPlatform;
  deviceId?: string;
  csrfToken?: string;
}

export interface RotatedSession {
  issued: IssuedSession;
  userId: string;
}

@Injectable()
export class SessionService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly tokens: TokenService,
    @Inject(AUTH_CONFIG) private readonly config: AuthConfig,
  ) {}

  private expiryFromNow(): Date {
    return new Date(Date.now() + this.config.refreshTokenTtlSeconds * 1000);
  }

  async createSession(input: CreateSessionInput): Promise<IssuedSession> {
    const refreshToken = this.tokens.createOpaqueToken();
    const sessionId = this.tokens.createId();
    const expiresAt = this.expiryFromNow();

    await this.prisma.session.create({
      data: {
        id: sessionId,
        userId: input.userId,
        familyId: sessionId,
        tokenHash: this.tokens.hashToken(refreshToken),
        csrfHash: input.csrfToken ? this.tokens.hashToken(input.csrfToken) : null,
        platform: input.platform,
        deviceId: input.deviceId ?? null,
        expiresAt,
      },
    });

    return {
      sessionId,
      refreshToken,
      expiresAt,
      platform: input.platform,
      csrfToken: input.csrfToken,
    };
  }

  /**
   * Rotates a refresh token atomically. Rotated tokens cannot be replayed; a
   * replay revokes the entire session family. The seven-day lifetime is
   * absolute: rotated sessions inherit the original expiry.
   */
  async rotateSession(input: RotateSessionInput): Promise<RotatedSession> {
    const tokenHash = this.tokens.hashToken(input.refreshToken);
    const current = await this.prisma.session.findUnique({ where: { tokenHash } });

    if (!current || current.platform !== input.platform) {
      throw apiError(401, 'INVALID_REFRESH_TOKEN', 'Refresh session is not valid');
    }

    if (
      input.platform === SessionPlatform.MOBILE &&
      input.deviceId !== undefined &&
      current.deviceId !== input.deviceId
    ) {
      throw apiError(401, 'INVALID_REFRESH_TOKEN', 'Refresh session is not valid');
    }

    if (current.revokedAt !== null || current.replacedById !== null) {
      await this.revokeFamily(current.familyId);
      throw apiError(401, 'REFRESH_TOKEN_REUSED', 'Refresh session has been revoked');
    }

    if (current.expiresAt.getTime() <= Date.now()) {
      await this.revokeSession(current.id);
      throw apiError(401, 'SESSION_EXPIRED', 'Session has expired');
    }

    const user = await this.prisma.user.findUnique({ where: { id: current.userId } });
    if (!user || !user.active) {
      await this.revokeAllForUser(current.userId);
      throw apiError(401, 'SESSION_REVOKED', 'Session is no longer valid');
    }

    if (
      input.platform === SessionPlatform.WEB &&
      (!current.csrfHash ||
        !input.csrfToken ||
        this.tokens.hashToken(input.csrfToken) !== current.csrfHash)
    ) {
      throw apiError(403, 'CSRF_INVALID', 'CSRF token is missing or invalid');
    }

    const refreshToken = this.tokens.createOpaqueToken();
    const nextId = this.tokens.createId();
    const nextCsrfToken =
      input.platform === SessionPlatform.WEB ? this.tokens.createCsrfToken() : undefined;

    const rotated = await this.prisma.$transaction(async (tx) => {
      const claimed = await tx.session.updateMany({
        where: { id: current.id, revokedAt: null, replacedById: null },
        data: { revokedAt: new Date(), replacedById: nextId, lastUsedAt: new Date() },
      });

      if (claimed.count !== 1) {
        return false;
      }

      await tx.session.create({
        data: {
          id: nextId,
          userId: current.userId,
          familyId: current.familyId,
          tokenHash: this.tokens.hashToken(refreshToken),
          csrfHash: nextCsrfToken ? this.tokens.hashToken(nextCsrfToken) : null,
          platform: current.platform,
          deviceId: current.deviceId,
          expiresAt: current.expiresAt,
        },
      });

      return true;
    });

    if (!rotated) {
      await this.revokeFamily(current.familyId);
      throw apiError(401, 'REFRESH_TOKEN_REUSED', 'Refresh session has been revoked');
    }

    return {
      userId: current.userId,
      issued: {
        sessionId: nextId,
        refreshToken,
        expiresAt: current.expiresAt,
        platform: current.platform,
        csrfToken: nextCsrfToken,
      },
    };
  }

  async revokeSession(sessionId: string): Promise<void> {
    await this.prisma.session.updateMany({
      where: { id: sessionId, revokedAt: null },
      data: { revokedAt: new Date() },
    });
  }

  async revokeAllForUser(userId: string): Promise<number> {
    const result = await this.prisma.session.updateMany({
      where: { userId, revokedAt: null },
      data: { revokedAt: new Date() },
    });

    return result.count;
  }

  async revokeFamily(familyId: string): Promise<number> {
    const result = await this.prisma.session.updateMany({
      where: { familyId, revokedAt: null },
      data: { revokedAt: new Date() },
    });

    return result.count;
  }
}
