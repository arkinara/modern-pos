import assert from 'node:assert/strict';
import { test } from 'node:test';
import { HttpException, type ExecutionContext } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { Role } from '@prisma/client';
import type { AuthenticatedUser } from '../../auth/auth.types';
import { IS_PUBLIC_KEY } from '../decorators/public.decorator';
import { ROLES_KEY } from '../decorators/roles.decorator';
import { RolesGuard } from './roles.guard';

function reflectorFor(metadata: { isPublic?: boolean; roles?: Role[] }): Reflector {
  return {
    getAllAndOverride: (key: string) => {
      if (key === IS_PUBLIC_KEY) {
        return metadata.isPublic;
      }
      if (key === ROLES_KEY) {
        return metadata.roles;
      }
      return undefined;
    },
  } as unknown as Reflector;
}

function contextFor(user: AuthenticatedUser | undefined): ExecutionContext {
  const request = { user };
  return {
    getHandler: () => () => undefined,
    getClass: () => class TestController {},
    switchToHttp: () => ({
      getRequest: () => request,
      getResponse: () => ({}),
      getNext: () => ({}),
    }),
  } as unknown as ExecutionContext;
}

function user(role: Role): AuthenticatedUser {
  return {
    id: 'user-1',
    businessId: 'business-1',
    email: 'user@example.test',
    role,
    outletId: 'outlet-1',
    outletIds: ['outlet-1'],
    sessionId: 'session-1',
  };
}

test('cashier is denied on an owner-only route', () => {
  const guard = new RolesGuard(reflectorFor({ roles: [Role.OWNER] }));

  assert.throws(
    () => guard.canActivate(contextFor(user(Role.CASHIER))),
    (error: unknown) => error instanceof HttpException && error.getStatus() === 403,
  );
});

test('owner and role-free routes are allowed', () => {
  const ownerOnly = new RolesGuard(reflectorFor({ roles: [Role.OWNER] }));
  assert.equal(ownerOnly.canActivate(contextFor(user(Role.OWNER))), true);

  const authenticatedOnly = new RolesGuard(reflectorFor({}));
  assert.equal(authenticatedOnly.canActivate(contextFor(user(Role.CASHIER))), true);

  const publicRoute = new RolesGuard(reflectorFor({ isPublic: true, roles: [Role.OWNER] }));
  assert.equal(publicRoute.canActivate(contextFor(undefined)), true);
});
