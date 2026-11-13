import { Body, Controller, Get, Param, Post, Put, Query, Res } from '@nestjs/common';
import { Role } from '@prisma/client';
import type { Response } from 'express';
import type { AuthenticatedUser } from '../auth/auth.types';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { Roles } from '../common/decorators/roles.decorator';
import { ReportRangeQueryDto } from '../reports/dto/report-range-query.dto';
import {
  BookkeepingConfigurationResponse,
  BookkeepingService,
  ConsolidatedResponse,
  ExpenseCategoryResponse,
  ExpensePageResponse,
  ExpenseResponse,
  ExportFile,
  ProfitReportResponse,
} from './bookkeeping.service';
import {
  CostingUpdateDto,
  ExpenseCategoryCreateDto,
  ExpenseCreateDto,
  ExpenseListQueryDto,
} from './dto/bookkeeping.dto';

@Roles(Role.OWNER)
@Controller('outlets/:outletId/bookkeeping')
export class BookkeepingController {
  constructor(private readonly bookkeeping: BookkeepingService) {}

  @Get()
  getConfiguration(
    @Param('outletId') outletId: string,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<BookkeepingConfigurationResponse> {
    return this.bookkeeping.getConfiguration(outletId, user);
  }

  @Put('costing')
  updateCosting(
    @Param('outletId') outletId: string,
    @Body() dto: CostingUpdateDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<BookkeepingConfigurationResponse> {
    return this.bookkeeping.updateCosting(outletId, dto, user);
  }

  @Get('expense-categories')
  listExpenseCategories(
    @Param('outletId') outletId: string,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<{ items: ExpenseCategoryResponse[] }> {
    return this.bookkeeping.listExpenseCategories(outletId, user);
  }

  @Post('expense-categories')
  createExpenseCategory(
    @Param('outletId') outletId: string,
    @Body() dto: ExpenseCategoryCreateDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<ExpenseCategoryResponse> {
    return this.bookkeeping.createExpenseCategory(outletId, dto, user);
  }

  @Get('expenses')
  listExpenses(
    @Param('outletId') outletId: string,
    @Query() query: ExpenseListQueryDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<ExpensePageResponse> {
    return this.bookkeeping.listExpenses(outletId, query, user);
  }

  @Post('expenses')
  createExpense(
    @Param('outletId') outletId: string,
    @Body() dto: ExpenseCreateDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<ExpenseResponse> {
    return this.bookkeeping.createExpense(outletId, dto, user);
  }

  @Get('profit')
  getProfitReport(
    @Param('outletId') outletId: string,
    @Query() query: ReportRangeQueryDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<ProfitReportResponse> {
    return this.bookkeeping.getProfitReport(outletId, query, user);
  }

  @Get('consolidated')
  getConsolidated(
    @Param('outletId') outletId: string,
    @Query() query: ReportRangeQueryDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<ConsolidatedResponse> {
    return this.bookkeeping.getConsolidated(outletId, query, user);
  }

  @Get('exports/sales.csv')
  async exportSales(
    @Param('outletId') outletId: string,
    @Query() query: ReportRangeQueryDto,
    @CurrentUser() user: AuthenticatedUser,
    @Res() response: Response,
  ): Promise<void> {
    await this.sendCsv(response, await this.bookkeeping.exportSalesCsv(outletId, query, user));
  }

  @Get('exports/reversals.csv')
  async exportReversals(
    @Param('outletId') outletId: string,
    @Query() query: ReportRangeQueryDto,
    @CurrentUser() user: AuthenticatedUser,
    @Res() response: Response,
  ): Promise<void> {
    await this.sendCsv(response, await this.bookkeeping.exportReversalsCsv(outletId, query, user));
  }

  @Get('exports/payments.csv')
  async exportPayments(
    @Param('outletId') outletId: string,
    @Query() query: ReportRangeQueryDto,
    @CurrentUser() user: AuthenticatedUser,
    @Res() response: Response,
  ): Promise<void> {
    await this.sendCsv(response, await this.bookkeeping.exportPaymentsCsv(outletId, query, user));
  }

  @Get('exports/accounting.csv')
  async exportAccounting(
    @Param('outletId') outletId: string,
    @Query() query: ReportRangeQueryDto,
    @CurrentUser() user: AuthenticatedUser,
    @Res() response: Response,
  ): Promise<void> {
    await this.sendCsv(response, await this.bookkeeping.exportAccountingCsv(outletId, query, user));
  }

  private async sendCsv(response: Response, exported: ExportFile): Promise<void> {
    response.setHeader('Content-Type', 'text/csv; charset=utf-8');
    response.setHeader('Content-Disposition', `attachment; filename="${exported.filename}"`);
    response.setHeader('Cache-Control', 'no-store');
    response.send(exported.csv);
  }
}
