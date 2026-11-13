import { Body, Controller, Get, Headers, Param, Post, Query } from '@nestjs/common';
import { Role } from '@prisma/client';
import type { AuthenticatedUser } from '../auth/auth.types';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { Roles } from '../common/decorators/roles.decorator';
import { MovementListQueryDto } from './dto/movement-list-query.dto';
import { StockAdjustmentDto } from './dto/stock-adjustment.dto';
import { StockChangeDto } from './dto/stock-change.dto';
import { StockCreateDto } from './dto/stock-create.dto';
import { StockListQueryDto } from './dto/stock-list-query.dto';
import {
  MovementPageResponse,
  MovementResponse,
  StockPageResponse,
  StockResponse,
  StockService,
} from './stock.service';

@Controller('outlets/:outletId/stock')
export class StockController {
  constructor(private readonly stock: StockService) {}

  @Roles(Role.OWNER, Role.CASHIER)
  @Get()
  list(
    @Param('outletId') outletId: string,
    @Query() query: StockListQueryDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<StockPageResponse> {
    return this.stock.list(outletId, query, user);
  }

  @Roles(Role.OWNER)
  @Post()
  create(
    @Param('outletId') outletId: string,
    @Body() dto: StockCreateDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<StockResponse> {
    return this.stock.create(outletId, dto, user);
  }

  @Roles(Role.OWNER)
  @Get(':stockItemId/movements')
  movements(
    @Param('outletId') outletId: string,
    @Param('stockItemId') stockItemId: string,
    @Query() query: MovementListQueryDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<MovementPageResponse> {
    return this.stock.listMovements(outletId, stockItemId, query, user);
  }

  @Roles(Role.OWNER)
  @Post('opening-balances')
  opening(
    @Param('outletId') outletId: string,
    @Headers('Idempotency-Key') key: string | undefined,
    @Body() dto: StockChangeDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<MovementResponse> {
    return this.stock.recordOpening(outletId, key, dto, user);
  }

  @Roles(Role.OWNER)
  @Post('receipts')
  receipt(
    @Param('outletId') outletId: string,
    @Headers('Idempotency-Key') key: string | undefined,
    @Body() dto: StockChangeDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<MovementResponse> {
    return this.stock.recordReceipt(outletId, key, dto, user);
  }

  @Roles(Role.OWNER)
  @Post('adjustments')
  adjustment(
    @Param('outletId') outletId: string,
    @Headers('Idempotency-Key') key: string | undefined,
    @Body() dto: StockAdjustmentDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<MovementResponse> {
    return this.stock.recordAdjustment(outletId, key, dto, user);
  }
}
