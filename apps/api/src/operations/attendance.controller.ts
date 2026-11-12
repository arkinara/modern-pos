import { Body, Controller, Get, HttpCode, Param, Post, Query } from '@nestjs/common';
import type { AuthenticatedUser } from '../auth/auth.types';
import { PERMISSIONS } from '../auth/permissions';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { RequirePermission } from '../common/decorators/permissions.decorator';
import {
  AttendancePageResponse,
  AttendanceResponse,
  AttendanceService,
} from './attendance.service';
import { AttendanceClockDto, AttendanceListQueryDto } from './dto/operations.dto';

@Controller('outlets/:outletId/attendance')
export class AttendanceController {
  constructor(private readonly attendance: AttendanceService) {}

  @RequirePermission(PERMISSIONS.ATTENDANCE_CLOCK)
  @Post('clock-in')
  @HttpCode(201)
  clockIn(
    @Param('outletId') outletId: string,
    @Body() dto: AttendanceClockDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<AttendanceResponse> {
    return this.attendance.clockIn(outletId, dto, user);
  }

  @RequirePermission(PERMISSIONS.ATTENDANCE_CLOCK)
  @Post('clock-out')
  @HttpCode(200)
  clockOut(
    @Param('outletId') outletId: string,
    @Body() dto: AttendanceClockDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<AttendanceResponse> {
    return this.attendance.clockOut(outletId, dto, user);
  }

  @RequirePermission(PERMISSIONS.ATTENDANCE_READ)
  @Get()
  list(
    @Param('outletId') outletId: string,
    @Query() query: AttendanceListQueryDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<AttendancePageResponse> {
    return this.attendance.listAttendance(outletId, query, user);
  }
}
