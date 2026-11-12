import { Injectable } from '@nestjs/common';
import {
  ApprovalAction,
  OperationAuditAction,
  PaymentKind,
  PaymentStatus,
  Prisma,
  Role,
  SaleState,
  ShiftCashMovementKind,
  ShiftStatus,
} from '@prisma/client';
import type { AuthenticatedUser } from '../auth/auth.types';
import { apiError } from '../common/api-error';
import { PrismaService } from '../prisma/prisma.service';
import { PromotionsService } from '../promotions/promotions.service';
import { toWireMinor } from '../sales/money';
import {
  discrepancyMinor as signedDiscrepancy,
  expectedCashMinor,
  isSettledTender,
  toSignedWireMinor,
} from './cash';
import { decodeCursor, encodeCursor } from './cursor';
import type {
  ShiftCashMovementDto,
  ShiftCloseDto,
  ShiftListQueryDto,
  ShiftOpenDto,
} from './dto/operations.dto';

type DbClient = Prisma.TransactionClient | PrismaService;

interface OutletRecord {
  id: string;
  businessId: string;
  currency: string;
  currencyExponent: number;
}

interface ShiftRow {
  id: string;
  businessId: string;
  outletId: string;
  openedById: string;
  closedById: string | null;
  status: ShiftStatus;
  openingFloatMinor: bigint;
  cashSalesMinor: bigint;
  paidInMinor: bigint;
  paidOutMinor: bigint;
  expectedCashMinor: bigint;
  countedCashMinor: bigint | null;
  discrepancyMinor: bigint | null;
  closeNote: string | null;
  version: number;
  openedAt: Date;
  closedAt: Date | null;
  createdAt: Date;
  updatedAt: Date;
}

interface MovementRow {
  id: string;
  shiftId: string;
  actorId: string;
  kind: ShiftCashMovementKind;
  amountMinor: bigint;
  reason: string;
  createdAt: Date;
}

export interface ShiftMovementResponse {
  id: string;
  actorId: string;
  kind: ShiftCashMovementKind;
  amountMinor: number;
  reason: string;
  createdAt: string;
}

export interface ShiftResponse {
  id: string;
  outletId: string;
  status: ShiftStatus;
  openedById: string;
  closedById: string | null;
  openingFloatMinor: number;
  cashSalesMinor: number;
  paidInMinor: number;
  paidOutMinor: number;
  expectedCashMinor: number;
  countedCashMinor: number | null;
  discrepancyMinor: number | null;
  closeNote: string | null;
  version: number;
  openedAt: string;
  closedAt: string | null;
  currency: string;
  currencyExponent: number;
}

export interface ShiftPageResponse {
  items: ShiftResponse[];
  nextCursor: string | null;
}

export interface TenderTotalResponse {
  kind: PaymentKind;
  count: number;
  amountMinor: number;
}

export interface ShiftReportResponse {
  shift: ShiftResponse;
  movements: ShiftMovementResponse[];
  salesByTender: TenderTotalResponse[];
  generatedAt: string;
}

const DEFAULT_LIMIT = 20;
const MAX_LIMIT = 100;
const CASH_KINDS = [PaymentKind.CASH, PaymentKind.MANUAL_EXTERNAL, PaymentKind.ONLINE];

function limitOf(value: number | undefined): number {
  return Math.min(Math.max(value ?? DEFAULT_LIMIT, 1), MAX_LIMIT);
}

async function requireOutlet(
  client: DbClient,
  outletId: string,
  businessId: string,
): Promise<OutletRecord> {
  const outlet = await client.outlet.findFirst({
    where: { id: outletId, businessId },
    select: { id: true, businessId: true, currency: true, currencyExponent: true },
  });

  if (!outlet) {
    throw apiError(404, 'NOT_FOUND', 'Outlet not found');
  }

  return outlet;
}

async function writeAudit(
  tx: Prisma.TransactionClient,
  input: {
    businessId: string;
    outletId: string;
    actorId: string;
    action: OperationAuditAction;
    entityType: string;
    entityId: string;
    metadata: Record<string, unknown>;
  },
): Promise<void> {
  await tx.operationAudit.create({
    data: {
      businessId: input.businessId,
      outletId: input.outletId,
      actorId: input.actorId,
      action: input.action,
      entityType: input.entityType,
      entityId: input.entityId,
      metadata: input.metadata as Prisma.InputJsonValue,
    },
  });
}

function toShiftResponse(shift: ShiftRow, outlet: OutletRecord): ShiftResponse {
  return {
    id: shift.id,
    outletId: shift.outletId,
    status: shift.status,
    openedById: shift.openedById,
    closedById: shift.closedById,
    openingFloatMinor: toWireMinor(shift.openingFloatMinor, 'openingFloatMinor'),
    cashSalesMinor: toWireMinor(shift.cashSalesMinor, 'cashSalesMinor'),
    paidInMinor: toWireMinor(shift.paidInMinor, 'paidInMinor'),
    paidOutMinor: toWireMinor(shift.paidOutMinor, 'paidOutMinor'),
    expectedCashMinor: toSignedWireMinor(shift.expectedCashMinor, 'expectedCashMinor'),
    countedCashMinor:
      shift.countedCashMinor === null
        ? null
        : toWireMinor(shift.countedCashMinor, 'countedCashMinor'),
    discrepancyMinor:
      shift.discrepancyMinor === null
        ? null
        : toSignedWireMinor(shift.discrepancyMinor, 'discrepancyMinor'),
    closeNote: shift.closeNote,
    version: shift.version,
    openedAt: shift.openedAt.toISOString(),
    closedAt: shift.closedAt ? shift.closedAt.toISOString() : null,
    currency: outlet.currency,
    currencyExponent: outlet.currencyExponent,
  };
}

function toMovementResponse(row: MovementRow): ShiftMovementResponse {
  return {
    id: row.id,
    actorId: row.actorId,
    kind: row.kind,
    amountMinor: toWireMinor(row.amountMinor, 'amountMinor'),
    reason: row.reason,
    createdAt: row.createdAt.toISOString(),
  };
}

@Injectable()
export class ShiftsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly promotions: PromotionsService,
  ) {}

  async openShift(
    outletId: string,
    dto: ShiftOpenDto,
    user: AuthenticatedUser,
  ): Promise<ShiftResponse> {
    const outlet = await requireOutlet(this.prisma, outletId, user.businessId);

    try {
      const shift = await this.prisma.$transaction(async (tx) => {
        const open = await tx.shift.findFirst({
          where: { outletId, openedById: user.id, status: ShiftStatus.OPEN },
          select: { id: true },
        });

        if (open) {
          throw apiError(
            409,
            'SHIFT_ALREADY_OPEN',
            'You already have an open shift in this outlet',
          );
        }

        const created = await tx.shift.create({
          data: {
            businessId: user.businessId,
            outletId,
            openedById: user.id,
            openingFloatMinor: BigInt(dto.openingFloatMinor),
            expectedCashMinor: BigInt(dto.openingFloatMinor),
          },
        });

        await writeAudit(tx, {
          businessId: user.businessId,
          outletId,
          actorId: user.id,
          action: OperationAuditAction.SHIFT_OPENED,
          entityType: 'SHIFT',
          entityId: created.id,
          metadata: { openingFloatMinor: dto.openingFloatMinor },
        });

        return created;
      });

      return toShiftResponse(shift as ShiftRow, outlet);
    } catch (error) {
      if (error instanceof Prisma.PrismaClientKnownRequestError && error.code === 'P2002') {
        throw apiError(409, 'SHIFT_ALREADY_OPEN', 'You already have an open shift in this outlet');
      }
      throw error;
    }
  }

  async listShifts(
    outletId: string,
    query: ShiftListQueryDto,
    user: AuthenticatedUser,
  ): Promise<ShiftPageResponse> {
    const outlet = await requireOutlet(this.prisma, outletId, user.businessId);
    const cursor = decodeCursor(query.cursor);
    const limit = limitOf(query.limit);

    const rows = await this.prisma.shift.findMany({
      where: {
        businessId: user.businessId,
        outletId,
        ...(query.status ? { status: query.status } : {}),
        ...(user.role === Role.OWNER ? {} : { openedById: user.id }),
        ...(cursor
          ? {
              OR: [{ openedAt: { lt: cursor.at } }, { openedAt: cursor.at, id: { lt: cursor.id } }],
            }
          : {}),
      },
      orderBy: [{ openedAt: 'desc' }, { id: 'desc' }],
      take: limit + 1,
    });

    const page = rows.slice(0, limit);
    const last = page.at(-1);

    return {
      items: page.map((row) => toShiftResponse(row as ShiftRow, outlet)),
      nextCursor: rows.length > limit && last ? encodeCursor(last.openedAt, last.id) : null,
    };
  }

  async getShift(
    outletId: string,
    shiftId: string,
    user: AuthenticatedUser,
  ): Promise<ShiftResponse> {
    const outlet = await requireOutlet(this.prisma, outletId, user.businessId);
    const shift = await this.prisma.shift.findFirst({
      where: {
        id: shiftId,
        businessId: user.businessId,
        outletId,
        ...(user.role === Role.OWNER ? {} : { openedById: user.id }),
      },
    });

    if (!shift) {
      throw apiError(404, 'NOT_FOUND', 'Shift not found');
    }

    return toShiftResponse(shift as ShiftRow, outlet);
  }

  async recordCashMovement(
    outletId: string,
    shiftId: string,
    dto: ShiftCashMovementDto,
    user: AuthenticatedUser,
  ): Promise<ShiftResponse> {
    const outlet = await requireOutlet(this.prisma, outletId, user.businessId);

    const updated = await this.prisma.$transaction(async (tx) => {
      const shift = await tx.shift.findFirst({
        where: { id: shiftId, businessId: user.businessId, outletId },
      });

      if (!shift) {
        throw apiError(404, 'NOT_FOUND', 'Shift not found');
      }

      if (shift.status !== ShiftStatus.OPEN) {
        throw apiError(409, 'SHIFT_NOT_OPEN', 'This shift is already closed');
      }

      if (shift.openedById !== user.id && user.role !== Role.OWNER) {
        throw apiError(
          409,
          'SHIFT_NOT_YOURS',
          'Only the staff member who opened this shift or an owner can change it',
        );
      }

      if (dto.kind === ShiftCashMovementKind.PAID_OUT && user.role !== Role.OWNER) {
        const rule = await this.promotions.findApprovalRule(
          tx,
          outletId,
          user.businessId,
          ApprovalAction.CASH_OUT,
        );

        if (!rule || !rule.active || BigInt(dto.amountMinor) > rule.thresholdMinor) {
          throw apiError(
            403,
            'APPROVAL_REQUIRED',
            'This cash payout exceeds your approval limit; an owner must record it',
            {
              details: {
                thresholdMinor:
                  rule && rule.active ? toWireMinor(rule.thresholdMinor, 'thresholdMinor') : null,
                amountMinor: dto.amountMinor,
              },
            },
          );
        }
      }

      await tx.shiftCashMovement.create({
        data: {
          businessId: user.businessId,
          outletId,
          shiftId,
          actorId: user.id,
          kind: dto.kind,
          amountMinor: BigInt(dto.amountMinor),
          reason: dto.reason,
        },
      });

      const increment =
        dto.kind === ShiftCashMovementKind.PAID_IN
          ? { paidInMinor: { increment: BigInt(dto.amountMinor) } }
          : { paidOutMinor: { increment: BigInt(dto.amountMinor) } };

      const row = await tx.shift.update({
        where: { id: shiftId },
        data: { ...increment, version: { increment: 1 } },
      });

      await writeAudit(tx, {
        businessId: user.businessId,
        outletId,
        actorId: user.id,
        action:
          dto.kind === ShiftCashMovementKind.PAID_IN
            ? OperationAuditAction.CASH_PAID_IN
            : OperationAuditAction.CASH_PAID_OUT,
        entityType: 'SHIFT',
        entityId: shiftId,
        metadata: {
          amountMinor: dto.amountMinor,
          reason: dto.reason,
          movementKind: dto.kind,
        },
      });

      return row;
    });

    return toShiftResponse(updated as ShiftRow, outlet);
  }

  async closeShift(
    outletId: string,
    shiftId: string,
    dto: ShiftCloseDto,
    user: AuthenticatedUser,
  ): Promise<ShiftResponse> {
    const outlet = await requireOutlet(this.prisma, outletId, user.businessId);

    const closed = await this.prisma.$transaction(async (tx) => {
      const shift = await tx.shift.findFirst({
        where: { id: shiftId, businessId: user.businessId, outletId },
      });

      if (!shift) {
        throw apiError(404, 'NOT_FOUND', 'Shift not found');
      }

      if (shift.status === ShiftStatus.CLOSED) {
        throw apiError(409, 'SHIFT_ALREADY_CLOSED', 'This shift is already closed');
      }

      if (shift.openedById !== user.id) {
        throw apiError(
          409,
          'SHIFT_NOT_YOURS',
          'Only the staff member who opened this shift can close it',
        );
      }

      const now = new Date();
      const movementTotals = await tx.shiftCashMovement.groupBy({
        by: ['kind'],
        where: { shiftId },
        _sum: { amountMinor: true },
      });
      const paidInMinor =
        movementTotals.find((row) => row.kind === ShiftCashMovementKind.PAID_IN)?._sum
          .amountMinor ?? 0n;
      const paidOutMinor =
        movementTotals.find((row) => row.kind === ShiftCashMovementKind.PAID_OUT)?._sum
          .amountMinor ?? 0n;

      const sales = await tx.sale.findMany({
        where: {
          businessId: user.businessId,
          outletId,
          state: SaleState.COMPLETED,
          completedAt: { gte: shift.openedAt, lt: now },
        },
        select: {
          totalMinor: true,
          payment: { select: { kind: true, status: true, amountMinor: true } },
        },
      });

      const cashSales = sales.reduce(
        (sum, sale) =>
          sale.payment &&
          sale.payment.kind === PaymentKind.CASH &&
          sale.payment.status === PaymentStatus.RECORDED
            ? sum + sale.payment.amountMinor
            : sum,
        0n,
      );
      const cashSaleTotals = sales.reduce(
        (sum, sale) =>
          sale.payment &&
          sale.payment.kind === PaymentKind.CASH &&
          sale.payment.status === PaymentStatus.RECORDED
            ? sum + sale.totalMinor
            : sum,
        0n,
      );

      if (cashSales !== cashSaleTotals) {
        throw apiError(
          500,
          'CASH_SALES_MISMATCH',
          'Recorded cash tender does not match the cash sale totals in this shift window',
          {
            details: {
              tenderMinor: cashSales.toString(),
              saleMinor: cashSaleTotals.toString(),
            },
          },
        );
      }

      const expected = expectedCashMinor({
        openingFloatMinor: shift.openingFloatMinor,
        cashSalesMinor: cashSales,
        paidInMinor,
        paidOutMinor,
      });
      const counted = BigInt(dto.countedCashMinor);
      const variance = signedDiscrepancy(counted, expected);

      const result = await tx.shift.updateMany({
        where: { id: shiftId, status: ShiftStatus.OPEN, version: shift.version },
        data: {
          status: ShiftStatus.CLOSED,
          closedById: user.id,
          cashSalesMinor: cashSales,
          paidInMinor,
          paidOutMinor,
          expectedCashMinor: expected,
          countedCashMinor: counted,
          discrepancyMinor: variance,
          closeNote: dto.note && dto.note.length > 0 ? dto.note : null,
          closedAt: now,
          version: { increment: 1 },
        },
      });

      if (result.count !== 1) {
        throw apiError(409, 'SHIFT_CLOSE_CONFLICT', 'Another close attempt already won');
      }

      await writeAudit(tx, {
        businessId: user.businessId,
        outletId,
        actorId: user.id,
        action: OperationAuditAction.SHIFT_CLOSED,
        entityType: 'SHIFT',
        entityId: shiftId,
        metadata: {
          openingFloatMinor: Number(shift.openingFloatMinor),
          cashSalesMinor: Number(cashSales),
          paidInMinor: Number(paidInMinor),
          paidOutMinor: Number(paidOutMinor),
          expectedCashMinor: Number(expected),
          countedCashMinor: dto.countedCashMinor,
          discrepancyMinor: Number(variance),
        },
      });

      const row = await tx.shift.findUniqueOrThrow({ where: { id: shiftId } });
      return row;
    });

    return toShiftResponse(closed as ShiftRow, outlet);
  }

  async shiftReport(
    outletId: string,
    shiftId: string,
    user: AuthenticatedUser,
  ): Promise<ShiftReportResponse> {
    if (user.role !== Role.OWNER) {
      throw apiError(403, 'FORBIDDEN', 'Only an owner can read shift reports');
    }

    const outlet = await requireOutlet(this.prisma, outletId, user.businessId);
    const shift = await this.prisma.shift.findFirst({
      where: { id: shiftId, businessId: user.businessId, outletId },
    });

    if (!shift) {
      throw apiError(404, 'NOT_FOUND', 'Shift not found');
    }

    const end = shift.closedAt ?? new Date();
    const [movements, sales] = await Promise.all([
      this.prisma.shiftCashMovement.findMany({
        where: { shiftId },
        orderBy: [{ createdAt: 'asc' }, { id: 'asc' }],
      }),
      this.prisma.sale.findMany({
        where: {
          businessId: user.businessId,
          outletId,
          state: SaleState.COMPLETED,
          completedAt: { gte: shift.openedAt, lt: end },
        },
        select: { payment: { select: { kind: true, status: true, amountMinor: true } } },
      }),
    ]);

    const totals = new Map<PaymentKind, { count: number; amountMinor: bigint }>(
      CASH_KINDS.map((kind) => [kind, { count: 0, amountMinor: 0n }]),
    );

    for (const sale of sales) {
      if (!sale.payment || !isSettledTender(sale.payment.kind, sale.payment.status)) {
        continue;
      }
      const current = totals.get(sale.payment.kind) ?? { count: 0, amountMinor: 0n };
      totals.set(sale.payment.kind, {
        count: current.count + 1,
        amountMinor: current.amountMinor + sale.payment.amountMinor,
      });
    }

    return {
      shift: toShiftResponse(shift as ShiftRow, outlet),
      movements: (movements as MovementRow[]).map(toMovementResponse),
      salesByTender: CASH_KINDS.map((kind) => {
        const total = totals.get(kind) ?? { count: 0, amountMinor: 0n };
        return {
          kind,
          count: total.count,
          amountMinor: toWireMinor(total.amountMinor, 'amountMinor'),
        };
      }),
      generatedAt: new Date().toISOString(),
    };
  }
}
