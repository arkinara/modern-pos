import { Injectable } from '@nestjs/common';
import { Role, type Outlet } from '@prisma/client';
import { apiError } from '../common/api-error';
import { isValidTimeZone, TIMEZONE_VALIDATION_MESSAGE } from '../common/timezone';
import type { AuthenticatedUser } from '../auth/auth.types';
import { PrismaService } from '../prisma/prisma.service';
import { OutletUpdateDto } from './dto/outlet-update.dto';

export interface OutletResponse {
  id: string;
  name: string;
  currency: string;
  currencyExponent: number;
  timezone: string;
  receiptAddress: string;
  taxBps: number;
  serviceBps: number;
  pricingMode: 'EXCLUSIVE';
  version: number;
}

@Injectable()
export class OutletsService {
  constructor(private readonly prisma: PrismaService) {}

  async listAuthorized(user: AuthenticatedUser): Promise<{ items: OutletResponse[] }> {
    const outletIds =
      user.role === Role.OWNER ? user.outletIds : user.outletId === null ? [] : [user.outletId];

    const outlets =
      outletIds.length === 0
        ? []
        : await this.prisma.outlet.findMany({
            where: { id: { in: outletIds }, businessId: user.businessId },
            orderBy: [{ name: 'asc' }, { id: 'asc' }],
          });

    return { items: outlets.map((outlet) => this.toResponse(outlet)) };
  }

  async getAuthorized(outletId: string, user: AuthenticatedUser): Promise<OutletResponse> {
    const outlet = await this.prisma.outlet.findFirst({
      where: { id: outletId, businessId: user.businessId },
    });

    if (!outlet) {
      throw apiError(404, 'NOT_FOUND', 'Outlet not found');
    }

    return this.toResponse(outlet);
  }

  async update(
    outletId: string,
    dto: OutletUpdateDto,
    user: AuthenticatedUser,
  ): Promise<OutletResponse> {
    if (!isValidTimeZone(dto.timezone)) {
      throw apiError(400, 'VALIDATION_ERROR', 'Request validation failed', {
        details: { issues: [TIMEZONE_VALIDATION_MESSAGE] },
      });
    }

    const result = await this.prisma.outlet.updateMany({
      where: { id: outletId, businessId: user.businessId, version: dto.version },
      data: {
        name: dto.name,
        timezone: dto.timezone,
        receiptAddress: dto.receiptAddress,
        taxBps: dto.taxBps,
        serviceBps: dto.serviceBps,
        version: { increment: 1 },
      },
    });

    if (result.count !== 1) {
      const exists = await this.prisma.outlet.findFirst({
        where: { id: outletId, businessId: user.businessId },
        select: { id: true },
      });

      if (!exists) {
        throw apiError(404, 'NOT_FOUND', 'Outlet not found');
      }

      throw apiError(409, 'VERSION_CONFLICT', 'Outlet settings were changed by another request');
    }

    return this.getAuthorized(outletId, user);
  }

  private toResponse(outlet: Outlet): OutletResponse {
    return {
      id: outlet.id,
      name: outlet.name,
      currency: outlet.currency,
      currencyExponent: outlet.currencyExponent,
      timezone: outlet.timezone,
      receiptAddress: outlet.receiptAddress,
      taxBps: outlet.taxBps,
      serviceBps: outlet.serviceBps,
      pricingMode: 'EXCLUSIVE',
      version: outlet.version,
    };
  }
}
