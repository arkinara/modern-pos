import assert from 'node:assert/strict';
import { test } from 'node:test';
import { HttpException, type ExecutionContext } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { Role } from '@prisma/client';
import type { AuthenticatedUser } from '../../auth/auth.types';
import { PERMISSIONS, permissionsForRole } from '../../auth/permissions';
import { PERMISSIONS_KEY } from '../decorators/permissions.decorator';
import { IS_PUBLIC_KEY } from '../decorators/public.decorator';
import { PermissionsGuard } from './permissions.guard';

function reflectorFor(metadata: { isPublic?: boolean; permissions?: string[] }): Reflector {
  return {
    getAllAndOverride: (key: string) => {
      if (key === IS_PUBLIC_KEY) {
        return metadata.isPublic;
      }
      if (key === PERMISSIONS_KEY) {
        return metadata.permissions;
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

test('permission matrix is the single source for owner and cashier access', () => {
  assert.ok(permissionsForRole(Role.OWNER).includes(PERMISSIONS.AUDIT_SEARCH));
  assert.ok(permissionsForRole(Role.OWNER).includes(PERMISSIONS.SHIFT_CLOSE));
  assert.ok(permissionsForRole(Role.CASHIER).includes(PERMISSIONS.SHIFT_OPEN));
  assert.ok(!permissionsForRole(Role.CASHIER).includes(PERMISSIONS.AUDIT_SEARCH));
  assert.ok(!permissionsForRole(Role.CASHIER).includes(PERMISSIONS.SHIFT_REPORT_READ));
});

test('cashier is denied an owner-only permission with a stable code', () => {
  const guard = new PermissionsGuard(reflectorFor({ permissions: [PERMISSIONS.AUDIT_SEARCH] }));

  assert.throws(
    () => guard.canActivate(contextFor(user(Role.CASHIER))),
    (error: unknown) =>
      error instanceof HttpException &&
      error.getStatus() === 403 &&
      (error.getResponse() as { code: string }).code === 'FORBIDDEN',
  );
});

test('owner passes and unmarked routes are unaffected', () => {
  const guard = new PermissionsGuard(reflectorFor({ permissions: [PERMISSIONS.AUDIT_SEARCH] }));
  assert.equal(guard.canActivate(contextFor(user(Role.OWNER))), true);

  const unmarked = new PermissionsGuard(reflectorFor({}));
  assert.equal(unmarked.canActivate(contextFor(user(Role.CASHIER))), true);

  const publicRoute = new PermissionsGuard(
    reflectorFor({ isPublic: true, permissions: [PERMISSIONS.AUDIT_SEARCH] }),
  );
  assert.equal(publicRoute.canActivate(contextFor(undefined)), true);
});

test('all listed permissions must be held', () => {
  const guard = new PermissionsGuard(
    reflectorFor({
      permissions: [PERMISSIONS.SHIFT_CASH_IN, PERMISSIONS.AUDIT_SEARCH],
    }),
  );
  assert.throws(
    () => guard.canActivate(contextFor(user(Role.CASHIER))),
    (error: unknown) => error instanceof HttpException && error.getStatus() === 403,
  );
});
