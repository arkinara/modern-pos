import { Body, Controller, Get, Param, ParseEnumPipe, Patch, Post, Put } from '@nestjs/common';
import { ApprovalAction, Role } from '@prisma/client';
import type { AuthenticatedUser } from '../auth/auth.types';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { Roles } from '../common/decorators/roles.decorator';
import {
  ApprovalRuleUpsertDto,
  ModifierCreateDto,
  PromotionCreateDto,
  PromotionUpdateDto,
} from './dto/promotion.dto';
import {
  ApprovalRuleResponse,
  ModifierResponse,
  PromotionResponse,
  PromotionsService,
} from './promotions.service';

@Controller('outlets/:outletId')
export class PromotionsController {
  constructor(private readonly promotions: PromotionsService) {}

  @Roles(Role.OWNER, Role.CASHIER)
  @Get('promotions')
  listPromotions(
    @Param('outletId') outletId: string,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<PromotionResponse[]> {
    return this.promotions.listPromotions(outletId, user);
  }

  @Roles(Role.OWNER)
  @Post('promotions')
  createPromotion(
    @Param('outletId') outletId: string,
    @Body() dto: PromotionCreateDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<PromotionResponse> {
    return this.promotions.createPromotion(outletId, dto, user);
  }

  @Roles(Role.OWNER)
  @Patch('promotions/:promotionId')
  updatePromotion(
    @Param('outletId') outletId: string,
    @Param('promotionId') promotionId: string,
    @Body() dto: PromotionUpdateDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<PromotionResponse> {
    return this.promotions.updatePromotion(outletId, promotionId, dto, user);
  }

  @Roles(Role.OWNER, Role.CASHIER)
  @Get('modifiers')
  listModifiers(
    @Param('outletId') outletId: string,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<ModifierResponse[]> {
    return this.promotions.listModifiers(outletId, user);
  }

  @Roles(Role.OWNER)
  @Post('modifiers')
  createModifier(
    @Param('outletId') outletId: string,
    @Body() dto: ModifierCreateDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<ModifierResponse> {
    return this.promotions.createModifier(outletId, dto, user);
  }

  @Roles(Role.OWNER)
  @Get('approval-rules')
  listApprovalRules(
    @Param('outletId') outletId: string,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<ApprovalRuleResponse[]> {
    return this.promotions.listApprovalRules(outletId, user);
  }

  @Roles(Role.OWNER)
  @Put('approval-rules/:action')
  upsertApprovalRule(
    @Param('outletId') outletId: string,
    @Param('action', new ParseEnumPipe(ApprovalAction)) action: ApprovalAction,
    @Body() dto: ApprovalRuleUpsertDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<ApprovalRuleResponse> {
    return this.promotions.upsertApprovalRule(outletId, action, dto, user);
  }
}
