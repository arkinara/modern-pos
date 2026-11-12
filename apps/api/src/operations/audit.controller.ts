import { Controller, Get, Param, Query } from '@nestjs/common';
import type { AuthenticatedUser } from '../auth/auth.types';
import { PERMISSIONS } from '../auth/permissions';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { RequirePermission } from '../common/decorators/permissions.decorator';
import { AuditService, OperationAuditPageResponse } from './audit.service';
import { AuditSearchQueryDto } from './dto/operations.dto';

@Controller('outlets/:outletId/audit')
export class AuditController {
  constructor(private readonly audit: AuditService) {}

  @RequirePermission(PERMISSIONS.AUDIT_SEARCH)
  @Get()
  search(
    @Param('outletId') outletId: string,
    @Query() query: AuditSearchQueryDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<OperationAuditPageResponse> {
    return this.audit.search(outletId, query, user);
  }
}
