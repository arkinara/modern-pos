import { SetMetadata } from '@nestjs/common';
import type { Permission } from '../../auth/permissions';

export const PERMISSIONS_KEY = 'permissions';

/** Restricts a route to every listed operational permission. */
export const RequirePermission = (...permissions: Permission[]): MethodDecorator & ClassDecorator =>
  SetMetadata(PERMISSIONS_KEY, permissions);
