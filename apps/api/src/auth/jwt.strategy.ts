import { Inject, Injectable } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { Role } from '@prisma/client';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { apiError } from '../common/api-error';
import { PrismaService } from '../prisma/prisma.service';
import { AUTH_CONFIG, type AuthConfig } from './auth.config';
import type { AccessTokenPayload, AuthenticatedUser } from './auth.types';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy, 'jwt') {
  constructor(
    @Inject(AUTH_CONFIG) config: AuthConfig,
    private readonly prisma: PrismaService,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: config.jwtSecret,
      issuer: config.jwtIssuer,
    });
  }

  async validate(payload: AccessTokenPayload): Promise<AuthenticatedUser> {
    if (!payload || payload.typ !== 'access' || !payload.sub || !payload.sid) {
      throw apiError(401, 'UNAUTHENTICATED', 'Authentication required');
    }

    const session = await this.prisma.session.findUnique({
      where: { id: payload.sid },
      include: {
        user: {
          include: {
            business: {
              select: {
                outlets: {
                  select: { id: true },
                  orderBy: [{ createdAt: 'asc' }, { id: 'asc' }],
                },
              },
            },
          },
        },
      },
    });

    if (
      !session ||
      session.userId !== payload.sub ||
      session.revokedAt !== null ||
      session.expiresAt.getTime() <= Date.now() ||
      !session.user.active
    ) {
      throw apiError(401, 'UNAUTHENTICATED', 'Authentication required');
    }

    const user = session.user;
    const outletIds =
      user.role === Role.OWNER
        ? user.business.outlets.map((outlet) => outlet.id)
        : user.outletId
          ? [user.outletId]
          : [];

    return {
      id: user.id,
      businessId: user.businessId,
      email: user.email,
      role: user.role,
      outletId: user.outletId,
      outletIds,
      sessionId: session.id,
    };
  }
}
