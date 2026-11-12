import { Body, Controller, Get, HttpCode, Param, Post, Query } from '@nestjs/common';
import type { AuthenticatedUser } from '../auth/auth.types';
import { PERMISSIONS } from '../auth/permissions';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { RequirePermission } from '../common/decorators/permissions.decorator';
import {
  ShiftCashMovementDto,
  ShiftCloseDto,
  ShiftListQueryDto,
  ShiftOpenDto,
} from './dto/operations.dto';
import {
  ShiftPageResponse,
  ShiftReportResponse,
  ShiftResponse,
  ShiftsService,
} from './shifts.service';

@Controller('outlets/:outletId/shifts')
export class ShiftsController {
  constructor(private readonly shifts: ShiftsService) {}

  @RequirePermission(PERMISSIONS.SHIFT_READ)
  @Get()
  list(
    @Param('outletId') outletId: string,
    @Query() query: ShiftListQueryDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<ShiftPageResponse> {
    return this.shifts.listShifts(outletId, query, user);
  }

  @RequirePermission(PERMISSIONS.SHIFT_OPEN)
  @Post()
  @HttpCode(201)
  open(
    @Param('outletId') outletId: string,
    @Body() dto: ShiftOpenDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<ShiftResponse> {
    return this.shifts.openShift(outletId, dto, user);
  }

  @RequirePermission(PERMISSIONS.SHIFT_READ)
  @Get(':shiftId')
  get(
    @Param('outletId') outletId: string,
    @Param('shiftId') shiftId: string,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<ShiftResponse> {
    return this.shifts.getShift(outletId, shiftId, user);
  }

  @RequirePermission(PERMISSIONS.SHIFT_CASH_IN, PERMISSIONS.SHIFT_CASH_OUT)
  @Post(':shiftId/cash-movements')
  @HttpCode(201)
  cashMovement(
    @Param('outletId') outletId: string,
    @Param('shiftId') shiftId: string,
    @Body() dto: ShiftCashMovementDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<ShiftResponse> {
    return this.shifts.recordCashMovement(outletId, shiftId, dto, user);
  }

  @RequirePermission(PERMISSIONS.SHIFT_CLOSE)
  @Post(':shiftId/close')
  @HttpCode(200)
  close(
    @Param('outletId') outletId: string,
    @Param('shiftId') shiftId: string,
    @Body() dto: ShiftCloseDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<ShiftResponse> {
    return this.shifts.closeShift(outletId, shiftId, dto, user);
  }

  @RequirePermission(PERMISSIONS.SHIFT_REPORT_READ)
  @Get(':shiftId/report')
  report(
    @Param('outletId') outletId: string,
    @Param('shiftId') shiftId: string,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<ShiftReportResponse> {
    return this.shifts.shiftReport(outletId, shiftId, user);
  }
}
