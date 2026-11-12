import { Body, Controller, Get, Headers, HttpCode, Param, Post, Put, Query } from '@nestjs/common';
import { Role } from '@prisma/client';
import type { AuthenticatedUser } from '../auth/auth.types';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { Roles } from '../common/decorators/roles.decorator';
import { CheckoutQueryDto } from './dto/checkout-query.dto';
import { FinalizeDto } from './dto/finalize.dto';
import { OrderCancelDto } from './dto/order-cancel.dto';
import { OrderCreateDto } from './dto/order-create.dto';
import { OrderListQueryDto } from './dto/order-list-query.dto';
import { OrderSplitDto } from './dto/order-split.dto';
import { OrderTransferDto } from './dto/order-transfer.dto';
import { OrderUpdateDto } from './dto/order-update.dto';
import { QuoteCreateDto } from './dto/quote-create.dto';
import { ReversalDto } from './dto/reversal.dto';
import { SalesListQueryDto } from './dto/sales-list-query.dto';
import { TableCreateDto } from './dto/table-create.dto';
import {
  FinalizedResponse,
  OrderAuditResponse,
  OrderPageResponse,
  OrderResponse,
  OrderSplitResponse,
  QuoteResponse,
  ReversalResponse,
  SalePageResponse,
  SaleResponse,
  SalesService,
  TableResponse,
} from './sales.service';

@Controller('outlets/:outletId')
export class SalesController {
  constructor(private readonly sales: SalesService) {}

  @Roles(Role.OWNER, Role.CASHIER)
  @Get('tables')
  listTables(
    @Param('outletId') outletId: string,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<{ items: TableResponse[] }> {
    return this.sales.listTables(outletId, user);
  }

  @Roles(Role.OWNER)
  @Post('tables')
  @HttpCode(201)
  createTable(
    @Param('outletId') outletId: string,
    @Body() dto: TableCreateDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<TableResponse> {
    return this.sales.createTable(outletId, dto, user);
  }

  @Roles(Role.OWNER, Role.CASHIER)
  @Get('orders')
  listOpenOrders(
    @Param('outletId') outletId: string,
    @Query() query: OrderListQueryDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<OrderPageResponse> {
    return this.sales.listOpenOrders(outletId, query, user);
  }

  @Roles(Role.OWNER, Role.CASHIER)
  @Get('orders/:orderId')
  getOrder(
    @Param('outletId') outletId: string,
    @Param('orderId') orderId: string,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<OrderResponse> {
    return this.sales.getOrder(outletId, orderId, user);
  }

  @Roles(Role.OWNER)
  @Get('orders/:orderId/audit')
  listOrderAudits(
    @Param('outletId') outletId: string,
    @Param('orderId') orderId: string,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<{ items: OrderAuditResponse[] }> {
    return this.sales.listOrderAudits(outletId, orderId, user);
  }

  @Roles(Role.OWNER)
  @Post('orders/:orderId/transfer')
  transferOrder(
    @Param('outletId') outletId: string,
    @Param('orderId') orderId: string,
    @Body() dto: OrderTransferDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<OrderResponse> {
    return this.sales.transferOrder(outletId, orderId, dto, user);
  }

  @Roles(Role.OWNER, Role.CASHIER)
  @Post('orders/:orderId/splits')
  @HttpCode(201)
  splitOrder(
    @Param('outletId') outletId: string,
    @Param('orderId') orderId: string,
    @Headers('Idempotency-Key') key: string | undefined,
    @Body() dto: OrderSplitDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<OrderSplitResponse> {
    return this.sales.splitOrder(outletId, orderId, key, dto, user);
  }

  @Roles(Role.OWNER, Role.CASHIER)
  @Post('orders')
  @HttpCode(201)
  createOrder(
    @Param('outletId') outletId: string,
    @Headers('Idempotency-Key') key: string | undefined,
    @Body() dto: OrderCreateDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<OrderResponse> {
    return this.sales.createOrder(outletId, key, dto, user);
  }

  @Roles(Role.OWNER, Role.CASHIER)
  @Put('orders/:orderId')
  updateOrder(
    @Param('outletId') outletId: string,
    @Param('orderId') orderId: string,
    @Body() dto: OrderUpdateDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<OrderResponse> {
    return this.sales.updateOrder(outletId, orderId, dto, user);
  }

  @Roles(Role.OWNER, Role.CASHIER)
  @Post('orders/:orderId/cancel')
  @HttpCode(204)
  cancelOrder(
    @Param('outletId') outletId: string,
    @Param('orderId') orderId: string,
    @Body() dto: OrderCancelDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<void> {
    return this.sales.cancelOrder(outletId, orderId, dto, user);
  }

  @Roles(Role.OWNER, Role.CASHIER)
  @Post('orders/:orderId/quotes')
  @HttpCode(201)
  createQuote(
    @Param('outletId') outletId: string,
    @Param('orderId') orderId: string,
    @Body() dto: QuoteCreateDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<QuoteResponse> {
    return this.sales.createQuote(outletId, orderId, dto, user);
  }

  @Roles(Role.OWNER, Role.CASHIER)
  @Post('sales/finalize')
  @HttpCode(200)
  finalize(
    @Param('outletId') outletId: string,
    @Headers('Idempotency-Key') key: string | undefined,
    @Body() dto: FinalizeDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<FinalizedResponse> {
    return this.sales.finalize(outletId, key, dto, user);
  }

  @Roles(Role.OWNER, Role.CASHIER)
  @Get('checkout-requests/:key')
  recover(
    @Param('outletId') outletId: string,
    @Param('key') key: string,
    @Query() query: CheckoutQueryDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<FinalizedResponse> {
    return this.sales.recoverCheckout(outletId, key, query, user);
  }

  @Roles(Role.OWNER, Role.CASHIER)
  @Get('sales')
  listSales(
    @Param('outletId') outletId: string,
    @Query() query: SalesListQueryDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<SalePageResponse> {
    return this.sales.listSales(outletId, query, user);
  }

  @Roles(Role.OWNER, Role.CASHIER)
  @Get('sales/:saleId')
  getSale(
    @Param('outletId') outletId: string,
    @Param('saleId') saleId: string,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<SaleResponse> {
    return this.sales.getSale(outletId, saleId, user);
  }

  @Roles(Role.OWNER, Role.CASHIER)
  @Post('sales/:saleId/reversals')
  @HttpCode(201)
  reverse(
    @Param('outletId') outletId: string,
    @Param('saleId') saleId: string,
    @Headers('Idempotency-Key') key: string | undefined,
    @Body() dto: ReversalDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<ReversalResponse> {
    return this.sales.reverse(outletId, saleId, key, dto, user);
  }
}
