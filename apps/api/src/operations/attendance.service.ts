import { Injectable } from '@nestjs/common';
import { OperationAuditAction, Prisma, Role } from '@prisma/client';
import type { AuthenticatedUser } from '../auth/auth.types';
import { apiError } from '../common/api-error';
import { PrismaService } from '../prisma/prisma.service';
import { decodeCursor, encodeCursor } from './cursor';
import type { AttendanceClockDto, AttendanceListQueryDto } from './dto/operations.dto';

interface AttendanceRow {
  id: string;
  outletId: string;
  userId: string;
  clockInAt: Date;
  clockOutAt: Date | null;
  clockInNote: string | null;
  clockOutNote: string | null;
  createdAt: Date;
  updatedAt: Date;
}

export interface AttendanceResponse {
  id: string;
  outletId: string;
  userId: string;
  clockInAt: string;
  clockOutAt: string | null;
  clockInNote: string | null;
  clockOutNote: string | null;
}

export interface AttendancePageResponse {
  items: AttendanceResponse[];
  nextCursor: string | null;
}

const DEFAULT_LIMIT = 20;
const MAX_LIMIT = 100;

function limitOf(value: number | undefined): number {
  return Math.min(Math.max(value ?? DEFAULT_LIMIT, 1), MAX_LIMIT);
}

function toResponse(row: AttendanceRow): AttendanceResponse {
  return {
    id: row.id,
    outletId: row.outletId,
    userId: row.userId,
    clockInAt: row.clockInAt.toISOString(),
    clockOutAt: row.clockOutAt ? row.clockOutAt.toISOString() : null,
    clockInNote: row.clockInNote,
    clockOutNote: row.clockOutNote,
  };
}

@Injectable()
export class AttendanceService {
  constructor(private readonly prisma: PrismaService) {}

  async clockIn(
    outletId: string,
    dto: AttendanceClockDto,
    user: AuthenticatedUser,
  ): Promise<AttendanceResponse> {
    await this.requireOutlet(outletId, user.businessId);

    try {
      const row = await this.prisma.$transaction(async (tx) => {
        const open = await tx.attendanceRecord.findFirst({
          where: { outletId, userId: user.id, clockOutAt: null },
          select: { id: true },
        });

        if (open) {
          throw apiError(
            409,
            'ATTENDANCE_ALREADY_OPEN',
            'You are already clocked in at this outlet',
          );
        }

        const created = await tx.attendanceRecord.create({
          data: {
            businessId: user.businessId,
            outletId,
            userId: user.id,
            clockInNote: dto.note && dto.note.length > 0 ? dto.note : null,
          },
        });

        await tx.operationAudit.create({
          data: {
            businessId: user.businessId,
            outletId,
            actorId: user.id,
            action: OperationAuditAction.ATTENDANCE_CLOCK_IN,
            entityType: 'ATTENDANCE',
            entityId: created.id,
            metadata: { note: dto.note ?? null } as Prisma.InputJsonValue,
          },
        });

        return created;
      });

      return toResponse(row as AttendanceRow);
    } catch (error) {
      if (error instanceof Prisma.PrismaClientKnownRequestError && error.code === 'P2002') {
        throw apiError(409, 'ATTENDANCE_ALREADY_OPEN', 'You are already clocked in at this outlet');
      }
      throw error;
    }
  }

  async clockOut(
    outletId: string,
    dto: AttendanceClockDto,
    user: AuthenticatedUser,
  ): Promise<AttendanceResponse> {
    await this.requireOutlet(outletId, user.businessId);

    const row = await this.prisma.$transaction(async (tx) => {
      const open = await tx.attendanceRecord.findFirst({
        where: { outletId, userId: user.id, clockOutAt: null },
        orderBy: { clockInAt: 'desc' },
      });

      if (!open) {
        throw apiError(409, 'ATTENDANCE_NOT_OPEN', 'You are not clocked in at this outlet');
      }

      const now = new Date();
      const updated = await tx.attendanceRecord.updateMany({
        where: { id: open.id, clockOutAt: null },
        data: {
          clockOutAt: now,
          clockOutNote: dto.note && dto.note.length > 0 ? dto.note : null,
        },
      });

      if (updated.count !== 1) {
        throw apiError(409, 'ATTENDANCE_CLOCK_OUT_CONFLICT', 'Another clock-out already won');
      }

      await tx.operationAudit.create({
        data: {
          businessId: user.businessId,
          outletId,
          actorId: user.id,
          action: OperationAuditAction.ATTENDANCE_CLOCK_OUT,
          entityType: 'ATTENDANCE',
          entityId: open.id,
          metadata: { note: dto.note ?? null } as Prisma.InputJsonValue,
        },
      });

      return tx.attendanceRecord.findUniqueOrThrow({ where: { id: open.id } });
    });

    return toResponse(row as AttendanceRow);
  }

  async listAttendance(
    outletId: string,
    query: AttendanceListQueryDto,
    user: AuthenticatedUser,
  ): Promise<AttendancePageResponse> {
    await this.requireOutlet(outletId, user.businessId);
    const cursor = decodeCursor(query.cursor);
    const limit = limitOf(query.limit);

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

    const scopeUserId = user.role === Role.OWNER ? query.userId : user.id;

    const rows = await this.prisma.attendanceRecord.findMany({
      where: {
        businessId: user.businessId,
        outletId,
        ...(scopeUserId ? { userId: scopeUserId } : {}),
        ...(from || to
          ? {
              clockInAt: {
                ...(from ? { gte: from } : {}),
                ...(to ? { lte: to } : {}),
              },
            }
          : {}),
        ...(cursor
          ? {
              OR: [
                { clockInAt: { lt: cursor.at } },
                { clockInAt: cursor.at, id: { lt: cursor.id } },
              ],
            }
          : {}),
      },
      orderBy: [{ clockInAt: 'desc' }, { id: 'desc' }],
      take: limit + 1,
    });

    const page = rows.slice(0, limit);
    const last = page.at(-1);

    return {
      items: page.map((row) => toResponse(row as AttendanceRow)),
      nextCursor: rows.length > limit && last ? encodeCursor(last.clockInAt, last.id) : null,
    };
  }

  private async requireOutlet(outletId: string, businessId: string): Promise<void> {
    const outlet = await this.prisma.outlet.findFirst({
      where: { id: outletId, businessId },
      select: { id: true },
    });

    if (!outlet) {
      throw apiError(404, 'NOT_FOUND', 'Outlet not found');
    }
  }
}
