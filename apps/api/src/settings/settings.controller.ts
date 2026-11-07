import { Body, Controller, Get, Param, Patch } from '@nestjs/common';
import { Role } from '@prisma/client';
import type { AuthenticatedUser } from '../auth/auth.types';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { Roles } from '../common/decorators/roles.decorator';
import { SettingsUpdateDto } from './dto/settings-update.dto';
import { SettingsResponse, SettingsService } from './settings.service';

@Controller('outlets/:outletId/settings')
export class SettingsController {
  constructor(private readonly settings: SettingsService) {}

  @Get()
  get(
    @Param('outletId') outletId: string,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<SettingsResponse> {
    return this.settings.getAuthorized(outletId, user);
  }

  @Roles(Role.OWNER)
  @Patch()
  update(
    @Param('outletId') outletId: string,
    @Body() dto: SettingsUpdateDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<SettingsResponse> {
    return this.settings.update(outletId, dto, user);
  }
}
