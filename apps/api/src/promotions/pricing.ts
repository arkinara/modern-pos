import { PromotionKind, PromotionStacking } from '@prisma/client';
import { apiError } from '../common/api-error';
import { BPS_DENOMINATOR, halfUpDiv, MAX_SAFE_MINOR } from '../sales/money';

export interface PromotionEligibility {
  variantIds?: string[];
  menuItemIds?: string[];
  customerEmails?: string[];
}

export interface PromotionRule {
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
  outletId: string | null;
  eligibility: PromotionEligibility;
}

export interface PromotionCandidateLine {
  variantId: string;
  menuItemId: string;
  unitPriceMinor: bigint;
  quantity: number;
}

export interface PromotionContext {
  outletId: string;
  now: Date;
  customerEmail: string | null;
}

export interface AppliedPromotion {
  promotionId: string;
  name: string;
  kind: PromotionKind;
  discountMinor: bigint;
}

export interface PromotionPricingResult {
  discountMinor: bigint;
  promotions: AppliedPromotion[];
}

function readEligibility(value: unknown): PromotionEligibility {
  if (!value || typeof value !== 'object' || Array.isArray(value)) {
    return {};
  }

  const source = value as Record<string, unknown>;
  const readList = (key: string): string[] | undefined => {
    const list = source[key];

    if (list === undefined) {
      return undefined;
    }

    if (!Array.isArray(list) || !list.every((entry) => typeof entry === 'string')) {
      throw apiError(500, 'PROMOTION_CORRUPT', 'Stored promotion eligibility is invalid');
    }

    return list.map((entry) => entry.toLowerCase());
  };

  return {
    ...(readList('variantIds') ? { variantIds: readList('variantIds') } : {}),
    ...(readList('menuItemIds') ? { menuItemIds: readList('menuItemIds') } : {}),
    ...(readList('customerEmails') ? { customerEmails: readList('customerEmails') } : {}),
  };
}

export function normalizeEligibility(value: unknown): PromotionEligibility {
  return readEligibility(value);
}

function isWithinWindow(rule: PromotionRule, now: Date): boolean {
  const time = now.getTime();

  if (rule.startsAt && time < rule.startsAt.getTime()) {
    return false;
  }

  if (rule.endsAt && time > rule.endsAt.getTime()) {
    return false;
  }

  return true;
}

function matchesCustomer(rule: PromotionRule, customerEmail: string | null): boolean {
  const allowed = rule.eligibility.customerEmails;

  if (!allowed || allowed.length === 0) {
    return true;
  }

  if (!customerEmail) {
    return false;
  }

  return allowed.includes(customerEmail.trim().toLowerCase());
}

function eligibleSubtotal(rule: PromotionRule, lines: PromotionCandidateLine[]): bigint | null {
  const variantIds = rule.eligibility.variantIds;
  const menuItemIds = rule.eligibility.menuItemIds;
  const scoped = (variantIds && variantIds.length > 0) || (menuItemIds && menuItemIds.length > 0);

  let subtotal = 0n;

  for (const line of lines) {
    if (scoped) {
      const variantMatch = variantIds?.includes(line.variantId.toLowerCase()) ?? false;
      const itemMatch = menuItemIds?.includes(line.menuItemId.toLowerCase()) ?? false;

      if (!variantMatch && !itemMatch) {
        continue;
      }
    }

    subtotal += line.unitPriceMinor * BigInt(line.quantity);
  }

  return subtotal;
}

function rawDiscount(rule: PromotionRule, eligible: bigint): bigint {
  if (rule.kind === PromotionKind.PERCENTAGE) {
    if (rule.percentageBps === null || rule.percentageBps <= 0 || rule.percentageBps > 10_000) {
      throw apiError(500, 'PROMOTION_CORRUPT', 'Stored percentage promotion is invalid');
    }

    return halfUpDiv(eligible * BigInt(rule.percentageBps), BPS_DENOMINATOR);
  }

  if (rule.amountMinor === null || rule.amountMinor < 0n) {
    throw apiError(500, 'PROMOTION_CORRUPT', 'Stored fixed-amount promotion is invalid');
  }

  return rule.amountMinor;
}

/**
 * Applies the requested promotions in deterministic order. Discounts are capped
 * by the remaining basket subtotal so a total can never become negative. Any
 * combination that violates the stacking rule is rejected before pricing.
 */
export function applyPromotions(
  lines: PromotionCandidateLine[],
  rules: PromotionRule[],
  context: PromotionContext,
): PromotionPricingResult {
  if (rules.length === 0) {
    return { discountMinor: 0n, promotions: [] };
  }

  const seen = new Set<string>();

  for (const rule of rules) {
    if (seen.has(rule.id)) {
      throw apiError(422, 'PROMOTION_DUPLICATE', 'A promotion can be applied only once per sale');
    }

    seen.add(rule.id);
  }

  const exclusive = rules.filter((rule) => rule.stacking === PromotionStacking.EXCLUSIVE);

  if (rules.length > 1 && exclusive.length > 0) {
    throw apiError(
      422,
      'PROMOTION_STACK_NOT_ALLOWED',
      'An exclusive promotion cannot be combined with another promotion',
      { details: { exclusivePromotionIds: exclusive.map((rule) => rule.id) } },
    );
  }

  let basketSubtotal = 0n;

  for (const line of lines) {
    basketSubtotal += line.unitPriceMinor * BigInt(line.quantity);
  }

  if (basketSubtotal > MAX_SAFE_MINOR) {
    throw apiError(422, 'MONEY_OUT_OF_RANGE', 'Subtotal exceeds the safe-integer range');
  }

  const ordered = [...rules].sort((a, b) => {
    if (b.priority !== a.priority) {
      return b.priority - a.priority;
    }

    return a.id < b.id ? -1 : a.id > b.id ? 1 : 0;
  });

  let discountMinor = 0n;
  const applied: AppliedPromotion[] = [];

  for (const rule of ordered) {
    if (!rule.active) {
      throw apiError(422, 'PROMOTION_NOT_ELIGIBLE', 'Promotion is not active', {
        details: { promotionId: rule.id },
      });
    }

    if (rule.outletId !== null && rule.outletId !== context.outletId) {
      throw apiError(422, 'PROMOTION_NOT_ELIGIBLE', 'Promotion does not apply to this outlet', {
        details: { promotionId: rule.id },
      });
    }

    if (!isWithinWindow(rule, context.now)) {
      throw apiError(422, 'PROMOTION_NOT_ELIGIBLE', 'Promotion is outside its date window', {
        details: { promotionId: rule.id },
      });
    }

    if (!matchesCustomer(rule, context.customerEmail)) {
      throw apiError(422, 'PROMOTION_NOT_ELIGIBLE', 'Promotion does not apply to this customer', {
        details: { promotionId: rule.id },
      });
    }

    const eligible = eligibleSubtotal(rule, lines);

    if (eligible === null || eligible <= 0n) {
      throw apiError(
        422,
        'PROMOTION_NOT_ELIGIBLE',
        'Basket has no eligible items for this promotion',
        {
          details: { promotionId: rule.id },
        },
      );
    }

    if (eligible < rule.minBasketMinor) {
      throw apiError(422, 'PROMOTION_NOT_ELIGIBLE', 'Basket is below the promotion minimum', {
        details: {
          promotionId: rule.id,
          minBasketMinor: Number(rule.minBasketMinor),
          eligibleMinor: Number(eligible),
        },
      });
    }

    const remaining = basketSubtotal - discountMinor;
    const candidate = rawDiscount(rule, eligible);
    const capped = candidate > remaining ? remaining : candidate;

    discountMinor += capped;

    applied.push({
      promotionId: rule.id,
      name: rule.name,
      kind: rule.kind,
      discountMinor: capped,
    });
  }

  return { discountMinor, promotions: applied };
}
