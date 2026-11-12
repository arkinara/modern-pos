import { Injectable } from '@nestjs/common';
import type { OperationAuditAction } from '@prisma/client';
import type { AuthenticatedUser } from '../auth/auth.types';
import { apiError } from '../common/api-error';
import { PrismaService } from '../prisma/prisma.service';
import { decodeCursor, encodeCursor } from './cursor';
import type { AuditSearchQueryDto } from './dto/operations.dto';

interface AuditRow {
  id: string;
  actorId: string;
  action: OperationAuditAction;
  entityType: string;
  entityId: string;
  metadata: unknown;
  createdAt: Date;
}

export interface OperationAuditResponse {
  id: string;
  actorId: string;
  action: OperationAuditAction;
  entityType: string;
  entityId: string;
  metadata: Record<string, unknown>;
  createdAt: string;
}

export interface OperationAuditPageResponse {
  items: OperationAuditResponse[];
  nextCursor: string | null;
}

const DEFAULT_LIMIT = 25;
const MAX_LIMIT = 100;

@Injectable()
export class AuditService {
  constructor(private readonly prisma: PrismaService) {}

  async search(
    outletId: string,
    query: AuditSearchQueryDto,
    user: AuthenticatedUser,
  ): Promise<OperationAuditPageResponse> {
    const outlet = await this.prisma.outlet.findFirst({
      where: { id: outletId, businessId: user.businessId },
      select: { id: true },
    });
    if (!outlet) {
      throw apiError(404, 'NOT_FOUND', 'Outlet not found');
    }

    const from = query.from ? new Date(query.from) : undefined;
    const to = query.to ? new Date(query.to) : undefined;
    if (from && Number.isNaN(from.getTime())) {
      throw apiError(400, 'VALIDATION_ERROR', 'from must be an ISO-8601 timestamp');
    }
    if (to && Number.isNaN(to.getTime())) {
      throw apiError(400, 'VALIDATION_ERROR', 'to must be an ISO-8601 timestamp');
    }
    if (from && to && from.getTime() > to.getTime()) {
      throw apiError(400, 'VALIDATION_ERROR', 'from must not be after to');
    }

    const limit = Math.min(Math.max(query.limit ?? DEFAULT_LIMIT, 1), MAX_LIMIT);
    const cursor = decodeCursor(query.cursor);

    const rows = await this.prisma.operationAudit.findMany({
      where: {
        businessId: user.businessId,
        outletId,
        ...(query.actorId ? { actorId: query.actorId } : {}),
        ...(query.action ? { action: query.action } : {}),
        ...(from || to
          ? {
              createdAt: {
                ...(from ? { gte: from } : {}),
                ...(to ? { lte: to } : {}),
              },
            }
          : {}),
        ...(cursor
          ? {
              OR: [
                { createdAt: { lt: cursor.at } },
                { createdAt: cursor.at, id: { lt: cursor.id } },
              ],
            }
          : {}),
      },
      orderBy: [{ createdAt: 'desc' }, { id: 'desc' }],
      take: limit + 1,
    });

    const page = rows.slice(0, limit);
    const last = page.at(-1);

    return {
      items: page.map((row) => {
        const typed = row as AuditRow;
        return {
          id: typed.id,
          actorId: typed.actorId,
          action: typed.action,
          entityType: typed.entityType,
          entityId: typed.entityId,
          metadata:
            typeof typed.metadata === 'object' && typed.metadata !== null
              ? (typed.metadata as Record<string, unknown>)
              : {},
          createdAt: typed.createdAt.toISOString(),
        };
      }),
      nextCursor: rows.length > limit && last ? encodeCursor(last.createdAt, last.id) : null,
    };
  }
}
