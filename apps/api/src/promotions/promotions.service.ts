import { Injectable } from '@nestjs/common';
import {
  ApprovalAction,
  PromotionKind,
  PromotionStacking,
  Prisma,
  Role,
} from '@prisma/client';
import type { AuthenticatedUser } from '../auth/auth.types';
import { apiError } from '../common/api-error';
import { PrismaService } from '../prisma/prisma.service';
import { toWireMinor } from '../sales/money';
import {
  ApprovalRuleUpsertDto,
  ModifierCreateDto,
  PromotionCreateDto,
  PromotionUpdateDto,
} from './dto/promotion.dto';
import {
  normalizeEligibility,
  type PromotionEligibility,
  type PromotionRule,
} from './pricing';

export interface PromotionResponse {
  id: string;
  name: string;
  kind: PromotionKind;
  percentageBps: number | null;
  amountMinor: number | null;
  minBasketMinor: number;
  startsAt: string | null;
  endsAt: string | null;
  active: boolean;
  stacking: PromotionStacking;
  priority: number;
  eligibility: PromotionEligibility;
  revision: number;
  createdAt: string;
  updatedAt: string;
}

export interface ModifierResponse {
  id: string;
  menuItemId: string;
  name: string;
  priceDeltaMinor: number;
  stockItemId: string | null;
  quantityPerSaleUnit: string | null;
  active: boolean;
}

export interface ApprovalRuleResponse {
  id: string;
  action: ApprovalAction;
  thresholdMinor: number;
  active: boolean;
}

type DbClient = Prisma.TransactionClient | PrismaService;

function requireOwner(user: AuthenticatedUser): void {
  if (user.role !== Role.OWNER) {
    throw apiError(403, 'FORBIDDEN', 'Only an owner can manage promotions and approval rules');
  }
}

function normalizeOptionalList(values: string[] | undefined): string[] | undefined {
  if (values === undefined) {
    return undefined;
  }

  return [...new Set(values.map((value) => value.trim().toLowerCase()))].sort();
}

function validateDates(startsAt: Date | null, endsAt: Date | null): void {
  if (startsAt && endsAt && startsAt.getTime() > endsAt.getTime()) {
    throw apiError(422, 'INVALID_PROMOTION_WINDOW', 'startsAt must not be after endsAt');
  }
}

@Injectable()
export class PromotionsService {
  constructor(private readonly prisma: PrismaService) {}

  async listPromotions(outletId: string, user: AuthenticatedUser): Promise<PromotionResponse[]> {
    await this.requireOutlet(this.prisma, outletId, user.businessId);
    const rows = await this.prisma.promotion.findMany({
      where: {
        businessId: user.businessId,
        OR: [{ outletId: null }, { outletId }],
      },
      orderBy: [{ priority: 'desc' }, { createdAt: 'asc' }, { id: 'asc' }],
    });

    return rows.map((row) => this.toPromotion(row));
  }

  async createPromotion(
    outletId: string,
    dto: PromotionCreateDto,
    user: AuthenticatedUser,
  ): Promise<PromotionResponse> {
    requireOwner(user);
    await this.requireOutlet(this.prisma, outletId, user.businessId);
    const data = this.normalizePromotionInput(dto);

    const created = await this.prisma.promotion.create({
      data: {
        businessId: user.businessId,
        outletId,
        ...data,
      },
    });

    return this.toPromotion(created);
  }

  async updatePromotion(
    outletId: string,
    promotionId: string,
    dto: PromotionUpdateDto,
    user: AuthenticatedUser,
  ): Promise<PromotionResponse> {
    requireOwner(user);
    await this.requireOutlet(this.prisma, outletId, user.businessId);
    const existing = await this.prisma.promotion.findFirst({
      where: { id: promotionId, businessId: user.businessId },
    });

    if (!existing || (existing.outletId !== null && existing.outletId !== outletId)) {
      throw apiError(404, 'NOT_FOUND', 'Promotion not found');
    }

    if (existing.revision !== dto.revision) {
      throw apiError(409, 'VERSION_CONFLICT', 'Promotion was changed by another request');
    }

    const data = this.normalizePromotionInput(dto);
    const updated = await this.prisma.promotion.updateMany({
      where: {
        id: promotionId,
        businessId: user.businessId,
        revision: dto.revision,
      },
      data: {
        ...data,
        revision: { increment: 1 },
      },
    });

    if (updated.count !== 1) {
      throw apiError(409, 'VERSION_CONFLICT', 'Promotion was changed by another request');
    }

    const reloaded = await this.prisma.promotion.findUnique({ where: { id: promotionId } });

    if (!reloaded) {
      throw apiError(404, 'NOT_FOUND', 'Promotion not found');
    }

    return this.toPromotion(reloaded);
  }

  async listModifiers(outletId: string, user: AuthenticatedUser): Promise<ModifierResponse[]> {
    await this.requireOutlet(this.prisma, outletId, user.businessId);
    const rows = await this.prisma.menuItemModifier.findMany({
      where: {
        businessId: user.businessId,
        OR: [{ outletId: null }, { outletId }],
      },
      orderBy: [{ name: 'asc' }, { id: 'asc' }],
    });

    return rows.map((row) => this.toModifier(row));
  }

  async createModifier(
    outletId: string,
    dto: ModifierCreateDto,
    user: AuthenticatedUser,
  ): Promise<ModifierResponse> {
    requireOwner(user);
    await this.requireOutlet(this.prisma, outletId, user.businessId);
    const menuItem = await this.prisma.menuItem.findFirst({
      where: { id: dto.menuItemId, businessId: user.businessId },
      select: { id: true },
    });

    if (!menuItem) {
      throw apiError(404, 'NOT_FOUND', 'Menu item not found');
    }

    const hasStock = dto.stockItemId !== undefined || dto.quantityPerSaleUnit !== undefined;

    if (hasStock && (dto.stockItemId === undefined || dto.quantityPerSaleUnit === undefined)) {
      throw apiError(
        422,
        'INVALID_MODIFIER',
        'stockItemId and quantityPerSaleUnit must be provided together',
      );
    }

    if (dto.stockItemId) {
      const stockItem = await this.prisma.stockItem.findFirst({
        where: { id: dto.stockItemId, businessId: user.businessId },
        select: { id: true },
      });

      if (!stockItem) {
        throw apiError(404, 'NOT_FOUND', 'Stock item not found');
      }

      if (dto.quantityPerSaleUnit !== undefined && Number(dto.quantityPerSaleUnit) <= 0) {
        throw apiError(422, 'INVALID_MODIFIER', 'quantityPerSaleUnit must be greater than zero');
      }
    }

    const created = await this.prisma.menuItemModifier.create({
      data: {
        businessId: user.businessId,
        outletId,
        menuItemId: dto.menuItemId,
        name: dto.name,
        priceDeltaMinor: BigInt(dto.priceDeltaMinor),
        stockItemId: dto.stockItemId ?? null,
        quantityPerSaleUnit:
          dto.quantityPerSaleUnit !== undefined
            ? new Prisma.Decimal(dto.quantityPerSaleUnit)
            : null,
        active: dto.active ?? true,
      },
    });

    return this.toModifier(created);
  }

  async listApprovalRules(
    outletId: string,
    user: AuthenticatedUser,
  ): Promise<ApprovalRuleResponse[]> {
    requireOwner(user);
    await this.requireOutlet(this.prisma, outletId, user.businessId);
    const rows = await this.prisma.approvalRule.findMany({
      where: { outletId, businessId: user.businessId },
      orderBy: { action: 'asc' },
    });

    return rows.map((row) => this.toApprovalRule(row));
  }

  async upsertApprovalRule(
    outletId: string,
    action: ApprovalAction,
    dto: ApprovalRuleUpsertDto,
    user: AuthenticatedUser,
  ): Promise<ApprovalRuleResponse> {
    requireOwner(user);
    await this.requireOutlet(this.prisma, outletId, user.businessId);

    const row = await this.prisma.approvalRule.upsert({
      where: { outletId_action: { outletId, action } },
      create: {
        businessId: user.businessId,
        outletId,
        action,
        thresholdMinor: BigInt(dto.thresholdMinor),
        active: dto.active ?? true,
      },
      update: {
        thresholdMinor: BigInt(dto.thresholdMinor),
        active: dto.active ?? true,
      },
    });

    return this.toApprovalRule(row);
  }

  async findApprovalRule(
    client: DbClient,
    outletId: string,
    businessId: string,
    action: ApprovalAction,
  ): Promise<{ thresholdMinor: bigint; active: boolean } | null> {
    return client.approvalRule.findFirst({
      where: { outletId, businessId, action },
      select: { thresholdMinor: true, active: true },
    });
  }

  async loadPromotionRules(
    client: DbClient,
    outletId: string,
    businessId: string,
    promotionIds: string[],
  ): Promise<PromotionRule[]> {
    const unique = [...new Set(promotionIds.map((id) => id.toLowerCase()))];

    if (unique.length === 0) {
      return [];
    }

    const rows = await client.promotion.findMany({
      where: { id: { in: unique }, businessId },
    });
    const byId = new Map(rows.map((row) => [row.id, row]));
    const missing = unique.filter((id) => !byId.has(id));

    if (missing.length > 0) {
      throw apiError(404, 'NOT_FOUND', 'Promotion not found', {
        details: { promotionIds: missing },
      });
    }

    return unique.map((id) => {
      const row = byId.get(id)!;

      return {
        id: row.id,
        name: row.name,
        kind: row.kind,
        percentageBps: row.percentageBps,
        amountMinor: row.amountMinor,
        minBasketMinor: row.minBasketMinor,
        startsAt: row.startsAt,
        endsAt: row.endsAt,
        active: row.active,
        stacking: row.stacking,
        priority: row.priority,
        outletId: row.outletId,
        eligibility: normalizeEligibility(row.eligibility),
      };
    });
  }

  private normalizePromotionInput(dto: PromotionCreateDto): {
    name: string;
    kind: PromotionKind;
    percentageBps: number | null;
    amountMinor: bigint | null;
    minBasketMinor: bigint;
    startsAt: Date | null;
    endsAt: Date | null;
    active: boolean;
    stacking: PromotionStacking;
    priority: number;
    eligibility: Prisma.InputJsonValue;
  } {
    const isPercentage = dto.kind === PromotionKind.PERCENTAGE;

    if (isPercentage && dto.percentageBps === undefined) {
      throw apiError(422, 'INVALID_PROMOTION', 'percentageBps is required for percentage promotions');
    }

    if (!isPercentage && dto.amountMinor === undefined) {
      throw apiError(422, 'INVALID_PROMOTION', 'amountMinor is required for fixed promotions');
    }

    const startsAt = dto.startsAt ? new Date(dto.startsAt) : null;
    const endsAt = dto.endsAt ? new Date(dto.endsAt) : null;
    validateDates(startsAt, endsAt);

    return {
      name: dto.name,
      kind: dto.kind,
      percentageBps: isPercentage ? (dto.percentageBps ?? null) : null,
      amountMinor: isPercentage ? null : BigInt(dto.amountMinor ?? 0),
      minBasketMinor: BigInt(dto.minBasketMinor ?? 0),
      startsAt,
      endsAt,
      active: dto.active ?? true,
      stacking: dto.stacking ?? PromotionStacking.EXCLUSIVE,
      priority: dto.priority ?? 0,
      eligibility: {
        variantIds: normalizeOptionalList(dto.eligibility?.variantIds),
        menuItemIds: normalizeOptionalList(dto.eligibility?.menuItemIds),
        customerEmails: normalizeOptionalList(dto.eligibility?.customerEmails),
      } as Prisma.InputJsonValue,
    };
  }

  private async requireOutlet(
    client: DbClient,
    outletId: string,
    businessId: string,
  ): Promise<void> {
    const outlet = await client.outlet.findFirst({
      where: { id: outletId, businessId },
      select: { id: true },
    });

    if (!outlet) {
      throw apiError(404, 'NOT_FOUND', 'Outlet not found');
    }
  }

  private toPromotion(row: {
    id: string;
    name: string;
    kind: PromotionKind;
    percentageBps: number | null;
    amountMinor: bigint | null;
    minBasketMinor: bigint;
    startsAt: Date | null;
    endsAt: Date | null;
    active: boolean;
    stacking: PromotionStacking;
    priority: number;
    eligibility: Prisma.JsonValue;
    revision: number;
    createdAt: Date;
    updatedAt: Date;
  }): PromotionResponse {
    return {
      id: row.id,
      name: row.name,
      kind: row.kind,
      percentageBps: row.percentageBps,
      amountMinor: row.amountMinor === null ? null : toWireMinor(row.amountMinor, 'amountMinor'),
      minBasketMinor: toWireMinor(row.minBasketMinor, 'minBasketMinor'),
      startsAt: row.startsAt ? row.startsAt.toISOString() : null,
      endsAt: row.endsAt ? row.endsAt.toISOString() : null,
      active: row.active,
      stacking: row.stacking,
      priority: row.priority,
      eligibility: normalizeEligibility(row.eligibility),
      revision: row.revision,
      createdAt: row.createdAt.toISOString(),
      updatedAt: row.updatedAt.toISOString(),
    };
  }

  private toModifier(row: {
    id: string;
    menuItemId: string;
    name: string;
    priceDeltaMinor: bigint;
    stockItemId: string | null;
    quantityPerSaleUnit: Prisma.Decimal | null;
    active: boolean;
  }): ModifierResponse {
    return {
      id: row.id,
      menuItemId: row.menuItemId,
      name: row.name,
      priceDeltaMinor: Number(row.priceDeltaMinor),
      stockItemId: row.stockItemId,
      quantityPerSaleUnit: row.quantityPerSaleUnit ? row.quantityPerSaleUnit.toString() : null,
      active: row.active,
    };
  }

  private toApprovalRule(row: {
    id: string;
    action: ApprovalAction;
    thresholdMinor: bigint;
    active: boolean;
  }): ApprovalRuleResponse {
    return {
      id: row.id,
      action: row.action,
      thresholdMinor: toWireMinor(row.thresholdMinor, 'thresholdMinor'),
      active: row.active,
    };
  }
}
