import { Injectable } from '@nestjs/common';
import type { Prisma } from '@prisma/client';
import type { AuthenticatedUser } from '../auth/auth.types';
import { apiError } from '../common/api-error';
import { isValidTimeZone, TIMEZONE_VALIDATION_MESSAGE } from '../common/timezone';
import { PrismaService } from '../prisma/prisma.service';
import { SettingsUpdateDto } from './dto/settings-update.dto';

export interface SettingsResponse {
  outletId: string;
  outletName: string;
  businessName: string;
  currency: string;
  currencyExponent: number;
  timezone: string;
  receiptHeader: string;
  receiptFooter: string;
  receiptAddress: string;
  taxBps: number;
  serviceBps: number;
  pricingMode: 'EXCLUSIVE';
  version: number;
}

type OutletWithBusiness = Prisma.OutletGetPayload<{
  include: { business: { select: { name: true } } };
}>;

// The server owns minor-unit exponents so the web form never derives financial
// display rules. Unknown ISO codes fall back to the common two-decimal case.
const CURRENCY_EXPONENTS: Record<string, number> = {
  IDR: 0,
  JPY: 0,
  KRW: 0,
  VND: 0,
  USD: 2,
  EUR: 2,
  GBP: 2,
  SGD: 2,
  MYR: 2,
  AUD: 2,
  CAD: 2,
  CNY: 2,
  THB: 2,
  PHP: 2,
  INR: 2,
};

export function currencyExponentFor(currency: string): number {
  return CURRENCY_EXPONENTS[currency] ?? 2;
}

@Injectable()
export class SettingsService {
  constructor(private readonly prisma: PrismaService) {}

  async getAuthorized(outletId: string, user: AuthenticatedUser): Promise<SettingsResponse> {
    const outlet = await this.prisma.outlet.findFirst({
      where: { id: outletId, businessId: user.businessId },
      include: { business: { select: { name: true } } },
    });

    if (!outlet) {
      throw apiError(404, 'NOT_FOUND', 'Outlet not found');
    }

    return this.toResponse(outlet);
  }

  async update(
    outletId: string,
    dto: SettingsUpdateDto,
    user: AuthenticatedUser,
  ): Promise<SettingsResponse> {
    if (!isValidTimeZone(dto.timezone)) {
      throw apiError(400, 'VALIDATION_ERROR', 'Request validation failed', {
        details: { issues: [TIMEZONE_VALIDATION_MESSAGE] },
      });
    }

    await this.prisma.$transaction(async (tx) => {
      const outlet = await tx.outlet.findFirst({
        where: { id: outletId, businessId: user.businessId },
        select: { id: true, version: true },
      });

      if (!outlet) {
        throw apiError(404, 'NOT_FOUND', 'Outlet not found');
      }

      if (outlet.version !== dto.version) {
        throw apiError(409, 'VERSION_CONFLICT', 'Settings were changed by another request');
      }

      const updated = await tx.outlet.updateMany({
        where: { id: outletId, businessId: user.businessId, version: dto.version },
        data: {
          currency: dto.currency,
          currencyExponent: currencyExponentFor(dto.currency),
          timezone: dto.timezone,
          receiptHeader: dto.receiptHeader,
          receiptFooter: dto.receiptFooter,
          receiptAddress: dto.receiptAddress,
          taxBps: dto.taxBps,
          serviceBps: dto.serviceBps,
          version: { increment: 1 },
        },
      });

      if (updated.count !== 1) {
        throw apiError(409, 'VERSION_CONFLICT', 'Settings were changed by another request');
      }

      await tx.business.update({
        where: { id: user.businessId },
        data: { name: dto.businessName },
      });
    });

    return this.getAuthorized(outletId, user);
  }

  private toResponse(outlet: OutletWithBusiness): SettingsResponse {
    return {
      outletId: outlet.id,
      outletName: outlet.name,
      businessName: outlet.business.name,
      currency: outlet.currency,
      currencyExponent: outlet.currencyExponent,
      timezone: outlet.timezone,
      receiptHeader: outlet.receiptHeader,
      receiptFooter: outlet.receiptFooter,
      receiptAddress: outlet.receiptAddress,
      taxBps: outlet.taxBps,
      serviceBps: outlet.serviceBps,
      pricingMode: 'EXCLUSIVE',
      version: outlet.version,
    };
  }
}
