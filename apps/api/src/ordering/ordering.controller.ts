import {
  Body,
  Controller,
  Get,
  Headers,
  HttpCode,
  Param,
  Post,
  Query,
  RawBodyRequest,
  Req,
} from '@nestjs/common';
import { Role } from '@prisma/client';
import type { Request } from 'express';
import type { AuthenticatedUser } from '../auth/auth.types';
import { apiError } from '../common/api-error';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { Public } from '../common/decorators/public.decorator';
import { Roles } from '../common/decorators/roles.decorator';
import {
  ChannelOrderCancelDto,
  ChannelOrderFulfillDto,
  ChannelOrderListQueryDto,
  ChannelOrderManualDto,
  ChannelOrderWebhookDto,
} from './dto/channel-order.dto';
import {
  ChannelListResponse,
  ChannelOrderCreateResponse,
  ChannelOrderListResponse,
  ChannelOrderResponse,
  OrderingService,
} from './ordering.service';

@Controller('outlets/:outletId')
export class OrderingController {
  constructor(private readonly ordering: OrderingService) {}

  @Roles(Role.OWNER, Role.CASHIER)
  @Get('channels')
  listChannels(
    @Param('outletId') outletId: string,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<ChannelListResponse> {
    return this.ordering.listChannels(outletId, user);
  }

  @Roles(Role.OWNER, Role.CASHIER)
  @Get('channel-orders')
  list(
    @Param('outletId') outletId: string,
    @Query() query: ChannelOrderListQueryDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<ChannelOrderListResponse> {
    return this.ordering.list(outletId, query, user);
  }

  @Roles(Role.OWNER, Role.CASHIER)
  @Post('channel-orders')
  @HttpCode(201)
  createManual(
    @Param('outletId') outletId: string,
    @Body() dto: ChannelOrderManualDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<ChannelOrderCreateResponse> {
    return this.ordering.createManual(outletId, dto, user);
  }

  @Roles(Role.OWNER, Role.CASHIER)
  @Get('channel-orders/:orderId')
  get(
    @Param('outletId') outletId: string,
    @Param('orderId') orderId: string,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<ChannelOrderResponse> {
    return this.ordering.get(outletId, orderId, user);
  }

  @Roles(Role.OWNER, Role.CASHIER)
  @Post('channel-orders/:orderId/accept')
  @HttpCode(200)
  accept(
    @Param('outletId') outletId: string,
    @Param('orderId') orderId: string,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<ChannelOrderResponse> {
    return this.ordering.accept(outletId, orderId, user);
  }

  @Roles(Role.OWNER, Role.CASHIER)
  @Post('channel-orders/:orderId/cancel')
  @HttpCode(200)
  cancel(
    @Param('outletId') outletId: string,
    @Param('orderId') orderId: string,
    @Body() dto: ChannelOrderCancelDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<ChannelOrderResponse> {
    return this.ordering.cancel(outletId, orderId, dto, user);
  }

  @Roles(Role.OWNER, Role.CASHIER)
  @Post('channel-orders/:orderId/fulfill')
  @HttpCode(200)
  fulfill(
    @Param('outletId') outletId: string,
    @Param('orderId') orderId: string,
    @Body() dto: ChannelOrderFulfillDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<ChannelOrderResponse> {
    return this.ordering.fulfill(outletId, orderId, dto, user);
  }
}

export const CHANNEL_SIGNATURE_HEADER = 'x-channel-signature';

@Controller('channels')
export class ChannelWebhookController {
  constructor(private readonly ordering: OrderingService) {}

  @Public()
  @Post(':channel/orders')
  @HttpCode(200)
  receive(
    @Param('channel') channel: string,
    @Req() request: RawBodyRequest<Request>,
    @Headers(CHANNEL_SIGNATURE_HEADER) signature: string | undefined,
    @Body() dto: ChannelOrderWebhookDto,
  ): Promise<ChannelOrderCreateResponse> {
    const raw = request.rawBody;

    if (!raw || raw.length === 0) {
      throw apiError(400, 'CHANNEL_PAYLOAD_INVALID', 'Channel webhook raw body is required');
    }

    return this.ordering.handleWebhook(channel, signature, raw.toString('utf8'), dto);
  }
}
