import { Body, Controller, Get, Headers, HttpCode, Param, Post, Query, RawBodyRequest, Req } from '@nestjs/common';
import { Role } from '@prisma/client';
import type { Request } from 'express';
import type { AuthenticatedUser } from '../auth/auth.types';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { Public } from '../common/decorators/public.decorator';
import { Roles } from '../common/decorators/roles.decorator';
import { apiError } from '../common/api-error';
import { PaymentListQueryDto, SettlementQueryDto } from './dto/settlement-query.dto';
import {
  OnlinePaymentListItem,
  OnlinePaymentResponse,
  PaymentsService,
  ReconciliationSummary,
  SettlementReportResponse,
  WebhookAck,
} from './payments.service';
import { PAYMENT_SIGNATURE_HEADER } from './webhook-signature';

@Controller('outlets/:outletId')
export class PaymentsController {
  constructor(private readonly payments: PaymentsService) {}

  @Roles(Role.OWNER, Role.CASHIER)
  @Post('sales/:saleId/online-payment')
  @HttpCode(200)
  schedule(
    @Param('outletId') outletId: string,
    @Param('saleId') saleId: string,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<OnlinePaymentResponse> {
    return this.payments.schedule(outletId, saleId, user);
  }

  @Roles(Role.OWNER, Role.CASHIER)
  @Get('sales/:saleId/online-payment')
  getForSale(
    @Param('outletId') outletId: string,
    @Param('saleId') saleId: string,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<OnlinePaymentResponse> {
    return this.payments.getForSale(outletId, saleId, user);
  }

  @Roles(Role.OWNER, Role.CASHIER)
  @Post('sales/:saleId/online-payment/refresh')
  @HttpCode(200)
  refresh(
    @Param('outletId') outletId: string,
    @Param('saleId') saleId: string,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<OnlinePaymentResponse> {
    return this.payments.refresh(outletId, saleId, user);
  }

  @Roles(Role.OWNER, Role.CASHIER)
  @Get('online-payments')
  list(
    @Param('outletId') outletId: string,
    @Query() query: PaymentListQueryDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<{ items: OnlinePaymentListItem[] }> {
    return this.payments.list(outletId, query, user);
  }

  @Roles(Role.OWNER)
  @Post('online-payments/reconcile')
  @HttpCode(200)
  reconcile(
    @Param('outletId') outletId: string,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<ReconciliationSummary> {
    return this.payments.reconcilePending(outletId, user);
  }

  @Roles(Role.OWNER)
  @Get('online-payments/settlements')
  settlements(
    @Param('outletId') outletId: string,
    @Query() query: SettlementQueryDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<SettlementReportResponse> {
    return this.payments.settlementReport(outletId, query, user);
  }
}

@Controller('payments')
export class PaymentWebhookController {
  constructor(private readonly payments: PaymentsService) {}

  @Public()
  @Post('webhook')
  @HttpCode(200)
  webhook(
    @Req() request: RawBodyRequest<Request>,
    @Headers(PAYMENT_SIGNATURE_HEADER) signature: string | undefined,
  ): Promise<WebhookAck> {
    const raw = request.rawBody;

    if (!raw || raw.length === 0) {
      throw apiError(400, 'WEBHOOK_PAYLOAD_INVALID', 'Webhook raw body is required');
    }

    return this.payments.handleWebhook(signature, raw.toString('utf8'));
  }
}
