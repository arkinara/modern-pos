import { Body, Controller, Get, Param, Patch } from '@nestjs/common';
import { Role } from '@prisma/client';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { Roles } from '../common/decorators/roles.decorator';
import type { AuthenticatedUser } from '../auth/auth.types';
import { OutletUpdateDto } from './dto/outlet-update.dto';
import { OutletResponse, OutletsService } from './outlets.service';

@Controller('outlets')
export class OutletsController {
  constructor(private readonly outlets: OutletsService) {}

  @Get()
  list(@CurrentUser() user: AuthenticatedUser): Promise<{ items: OutletResponse[] }> {
    return this.outlets.listAuthorized(user);
  }

  @Get(':outletId')
  get(
    @Param('outletId') outletId: string,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<OutletResponse> {
    return this.outlets.getAuthorized(outletId, user);
  }

  @Roles(Role.OWNER)
  @Patch(':outletId')
  update(
    @Param('outletId') outletId: string,
    @Body() dto: OutletUpdateDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<OutletResponse> {
    return this.outlets.update(outletId, dto, user);
  }
}
