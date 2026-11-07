import { CanActivate, ExecutionContext, Injectable } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { Role } from '@prisma/client';
import { apiError } from '../api-error';
import { IS_PUBLIC_KEY } from '../decorators/public.decorator';
import type { AuthenticatedUser } from '../../auth/auth.types';

/**
 * Every route carrying an `outletId` path parameter is scoped server-side.
 * Out-of-scope outlets return 404 (not 403) so another tenant cannot probe
 * whether an outlet ID exists.
 */
@Injectable()
export class OutletScopeGuard implements CanActivate {
  constructor(private readonly reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (isPublic) {
      return true;
    }

    const request = context.switchToHttp().getRequest<{
      user?: AuthenticatedUser;
      params?: Record<string, string | undefined>;
    }>();
    const outletId = request.params?.outletId;

    if (!outletId) {
      return true;
    }

    const user = request.user;
    if (!user) {
      throw apiError(401, 'UNAUTHENTICATED', 'Authentication required');
    }

    const authorized =
      user.role === Role.OWNER
        ? user.outletIds.includes(outletId)
        : user.outletId !== null && user.outletId === outletId;

    if (!authorized) {
      throw apiError(404, 'NOT_FOUND', 'Outlet not found');
    }

    return true;
  }
}
