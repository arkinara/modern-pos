import { Controller, Get, Param } from '@nestjs/common';
import { Role } from '@prisma/client';
import { PERMISSIONS, PERMISSION_DEFINITIONS, ROLE_PERMISSIONS } from '../auth/permissions';
import { apiError } from '../common/api-error';
import { RequirePermission } from '../common/decorators/permissions.decorator';
import { PrismaService } from '../prisma/prisma.service';
import type { AuthenticatedUser } from '../auth/auth.types';
import { CurrentUser } from '../common/decorators/current-user.decorator';

export interface PermissionMatrixResponse {
  roles: { role: Role; permissions: string[] }[];
  operations: { key: string; label: string; description: string }[];
}

@Controller('outlets/:outletId/permissions')
export class PermissionsController {
  constructor(private readonly prisma: PrismaService) {}

  @RequirePermission(PERMISSIONS.PERMISSION_MATRIX_READ)
  @Get()
  async matrix(
    @Param('outletId') outletId: string,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<PermissionMatrixResponse> {
    const outlet = await this.prisma.outlet.findFirst({
      where: { id: outletId, businessId: user.businessId },
      select: { id: true },
    });

    if (!outlet) {
      throw apiError(404, 'NOT_FOUND', 'Outlet not found');
    }

    return {
      roles: [Role.OWNER, Role.CASHIER].map((role) => ({
        role,
        permissions: [...ROLE_PERMISSIONS[role]],
      })),
      operations: PERMISSION_DEFINITIONS.map((definition) => ({
        key: definition.key,
        label: definition.label,
        description: definition.description,
      })),
    };
  }
}
