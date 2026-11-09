import { Controller, Get, Param, Query, Res } from '@nestjs/common';
import { Role } from '@prisma/client';
import type { Response } from 'express';
import type { AuthenticatedUser } from '../auth/auth.types';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { Roles } from '../common/decorators/roles.decorator';
import { ReportRangeQueryDto } from './dto/report-range-query.dto';
import { DailyReportResponse, ReportsService } from './reports.service';

@Controller('outlets/:outletId/reports')
export class ReportsController {
  constructor(private readonly reports: ReportsService) {}

  @Roles(Role.OWNER)
  @Get('daily')
  daily(
    @Param('outletId') outletId: string,
    @Query() query: ReportRangeQueryDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<DailyReportResponse> {
    return this.reports.dailyReport(outletId, query, user);
  }

  @Roles(Role.OWNER)
  @Get('sales.csv')
  async exportSalesCsv(
    @Param('outletId') outletId: string,
    @Query() query: ReportRangeQueryDto,
    @CurrentUser() user: AuthenticatedUser,
    @Res() response: Response,
  ): Promise<void> {
    const exported = await this.reports.exportCsv(outletId, query, user);

    response.setHeader('Content-Type', 'text/csv; charset=utf-8');
    response.setHeader('Content-Disposition', `attachment; filename="${exported.filename}"`);
    response.setHeader('Cache-Control', 'no-store');
    response.send(exported.csv);
  }
}
