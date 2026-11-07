import assert from 'node:assert/strict';
import { test } from 'node:test';
import { HttpException, type ExecutionContext } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { Role } from '@prisma/client';
import type { AuthenticatedUser } from '../../auth/auth.types';
import { IS_PUBLIC_KEY } from '../decorators/public.decorator';
import { OutletScopeGuard } from './outlet-scope.guard';

const reflector = {
  getAllAndOverride: (key: string) => (key === IS_PUBLIC_KEY ? false : undefined),
} as unknown as Reflector;

function contextFor(user: AuthenticatedUser | undefined, outletId?: string): ExecutionContext {
  const request = { user, params: outletId ? { outletId } : {} };
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

function user(role: Role, outletIds: string[], outletId: string | null): AuthenticatedUser {
  return {
    id: 'user-1',
    businessId: 'business-1',
    email: 'user@example.test',
    role,
    outletId,
    outletIds,
    sessionId: 'session-1',
  };
}

test('cashier cannot cross into another outlet', () => {
  const guard = new OutletScopeGuard(reflector);
  const cashier = user(Role.CASHIER, ['outlet-a'], 'outlet-a');

  assert.equal(guard.canActivate(contextFor(cashier, 'outlet-a')), true);
  assert.throws(
    () => guard.canActivate(contextFor(cashier, 'outlet-b')),
    (error: unknown) => error instanceof HttpException && error.getStatus() === 404,
  );
});

test('owner is limited to outlets in its business and cross-tenant IDs leak nothing', () => {
  const guard = new OutletScopeGuard(reflector);
  const owner = user(Role.OWNER, ['outlet-a', 'outlet-b'], 'outlet-a');

  assert.equal(guard.canActivate(contextFor(owner, 'outlet-b')), true);
  assert.throws(
    () => guard.canActivate(contextFor(owner, 'other-tenant-outlet')),
    (error: unknown) =>
      error instanceof HttpException &&
      error.getStatus() === 404 &&
      (error.getResponse() as { code: string }).code === 'NOT_FOUND',
  );
});

test('routes without an outlet parameter are unaffected', () => {
  const guard = new OutletScopeGuard(reflector);
  assert.equal(guard.canActivate(contextFor(undefined)), true);
});
