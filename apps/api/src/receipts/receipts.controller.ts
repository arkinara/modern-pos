import { Body, Controller, Get, Header, HttpCode, Param, Post } from '@nestjs/common';
import { Role } from '@prisma/client';
import type { AuthenticatedUser } from '../auth/auth.types';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { Public } from '../common/decorators/public.decorator';
import { Roles } from '../common/decorators/roles.decorator';
import { ReceiptCreateDto } from './dto/receipt.dto';
import { PublicReceiptResponse, ReceiptResponse, ReceiptsService } from './receipts.service';

@Controller('outlets/:outletId/sales/:saleId/receipt')
export class ReceiptsController {
  constructor(private readonly receipts: ReceiptsService) {}

  @Roles(Role.OWNER)
  @Post()
  @HttpCode(201)
  create(
    @Param('outletId') outletId: string,
    @Param('saleId') saleId: string,
    @Body() dto: ReceiptCreateDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<ReceiptResponse> {
    return this.receipts.createForSale(outletId, saleId, dto, user);
  }
}

@Controller('receipts')
export class PublicReceiptsController {
  constructor(private readonly receipts: ReceiptsService) {}

  @Public()
  @Get(':token')
  get(@Param('token') token: string): Promise<PublicReceiptResponse> {
    return this.receipts.getPublic(token);
  }

  @Public()
  @Get(':token/html')
  @Header('Content-Type', 'text/html; charset=utf-8')
  @Header('Cache-Control', 'no-store')
  async getHtml(@Param('token') token: string): Promise<string> {
    return this.receipts.getPublicHtml(token);
  }
}
