import { randomUUID } from 'node:crypto';
import { Injectable } from '@nestjs/common';
import { Prisma, type Station as StationRow } from '@prisma/client';
import type { AuthenticatedUser } from '../auth/auth.types';
import { apiError } from '../common/api-error';
import { PrismaService } from '../prisma/prisma.service';
import { StationJobListQueryDto } from './dto/station-job-list-query.dto';
import {
  StationJobStateDto,
  StationJobWriteDto,
  type StationJobKindValue,
} from './dto/station-job-write.dto';
import { StationRoutingWriteDto } from './dto/station-routing-write.dto';
import { StationUpdateDto } from './dto/station-update.dto';
import { StationWriteDto, type StationKindValue } from './dto/station-write.dto';

const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

export interface StationResponse {
  id: string;
  name: string;
  kind: StationKindValue;
  isDefault: boolean;
  printerConfigId: string | null;
  printerModel: string | null;
  sortOrder: number;
  revision: number;
  routeCount: number;
}

export interface StationRouteResponse {
  id: string;
  menuItemId: string;
  menuItemName: string;
  stationId: string;
  stationName: string;
  stationKind: StationKindValue;
}

export interface StationJobResponse {
  id: string;
  stationId: string;
  stationName: string;
  orderId: string;
  saleId: string | null;
  orderReference: string;
  variantId: string;
  kind: StationJobKindValue;
  state: 'QUEUED' | 'SENDING' | 'SENT' | 'FAILED' | 'UNKNOWN';
  copy: boolean;
  reprintOfId: string | null;
  itemName: string;
  variantName: string;
  quantity: number;
  modifiers: Record<string, unknown>[];
  attempts: number;
  lastError: string | null;
  createdAt: string;
  updatedAt: string;
}

export interface StationJobPageResponse {
  items: StationJobResponse[];
  nextCursor: string | null;
}

interface StationWithRelations extends StationRow {
  printer?: { model: string } | null;
  _count?: { routes: number };
}

interface StationJobWithStation {
  id: string;
  stationId: string;
  orderId: string;
  saleId: string | null;
  orderReference: string;
  variantId: string;
  kind: StationJobKindValue;
  state: 'QUEUED' | 'SENDING' | 'SENT' | 'FAILED' | 'UNKNOWN';
  copy: boolean;
  reprintOfId: string | null;
  itemName: string;
  variantName: string;
  quantity: number;
  modifiers: Prisma.JsonValue;
  attempts: number;
  lastError: string | null;
  createdAt: Date;
  updatedAt: Date;
  station: { name: string };
}

@Injectable()
export class StationRoutingService {
  constructor(private readonly prisma: PrismaService) {}

  async listStations(outletId: string, user: AuthenticatedUser): Promise<StationResponse[]> {
    await this.assertOutlet(outletId, user);
    const stations = await this.prisma.station.findMany({
      where: { businessId: user.businessId, outletId },
      orderBy: [{ sortOrder: 'asc' }, { name: 'asc' }],
      include: { printer: { select: { model: true } }, _count: { select: { routes: true } } },
    });
    return stations.map((station) => this.toStationResponse(station));
  }

  async createStation(
    outletId: string,
    dto: StationWriteDto,
    user: AuthenticatedUser,
  ): Promise<StationResponse> {
    await this.assertOutlet(outletId, user);
    await this.assertPrinter(outletId, dto.printerConfigId, user);

    try {
      return await this.prisma.$transaction(async (tx) => {
        const station = await tx.station.create({
          data: {
            businessId: user.businessId,
            outletId,
            name: dto.name,
            kind: dto.kind,
            isDefault: dto.isDefault,
            printerConfigId: dto.printerConfigId ?? null,
            sortOrder: dto.sortOrder,
          },
        });
        if (dto.isDefault) {
          await this.clearOtherDefaults(tx, outletId, user.businessId, station.id);
        }
        const created = await tx.station.findFirst({
          where: { id: station.id },
          include: { printer: { select: { model: true } }, _count: { select: { routes: true } } },
        });
        return this.toStationResponse(created ?? station);
      });
    } catch (error) {
      if (this.isUniqueViolation(error)) {
        throw apiError(409, 'STATION_EXISTS', 'A station with this name already exists');
      }
      throw error;
    }
  }

  async updateStation(
    outletId: string,
    stationId: string,
    dto: StationUpdateDto,
    user: AuthenticatedUser,
  ): Promise<StationResponse> {
    await this.assertOutlet(outletId, user);
    await this.assertPrinter(outletId, dto.printerConfigId, user);

    const existing = await this.prisma.station.findFirst({
      where: { id: stationId, businessId: user.businessId, outletId },
    });
    if (!existing) {
      throw apiError(404, 'NOT_FOUND', 'Station not found');
    }
    if (existing.revision !== dto.revision) {
      throw apiError(409, 'VERSION_CONFLICT', 'Station was changed by another request');
    }

    try {
      return await this.prisma.$transaction(async (tx) => {
        const updated = await tx.station.updateMany({
          where: {
            id: stationId,
            businessId: user.businessId,
            outletId,
            revision: dto.revision,
          },
          data: {
            name: dto.name,
            kind: dto.kind,
            isDefault: dto.isDefault,
            printerConfigId: dto.printerConfigId ?? null,
            sortOrder: dto.sortOrder,
            revision: { increment: 1 },
          },
        });
        if (updated.count !== 1) {
          throw apiError(409, 'VERSION_CONFLICT', 'Station was changed by another request');
        }
        if (dto.isDefault) {
          await this.clearOtherDefaults(tx, outletId, user.businessId, stationId);
        }
        const station = await tx.station.findFirst({
          where: { id: stationId },
          include: { printer: { select: { model: true } }, _count: { select: { routes: true } } },
        });
        if (!station) {
          throw apiError(404, 'NOT_FOUND', 'Station not found');
        }
        return this.toStationResponse(station);
      });
    } catch (error) {
      if (this.isUniqueViolation(error)) {
        throw apiError(409, 'STATION_EXISTS', 'A station with this name already exists');
      }
      throw error;
    }
  }

  async listRoutes(outletId: string, user: AuthenticatedUser): Promise<StationRouteResponse[]> {
    await this.assertOutlet(outletId, user);
    const routes = await this.prisma.stationRoute.findMany({
      where: { businessId: user.businessId, outletId },
      orderBy: [{ createdAt: 'asc' }, { id: 'asc' }],
      include: {
        station: { select: { name: true, kind: true } },
        menuItem: { select: { name: true } },
      },
    });
    return routes.map((route) => ({
      id: route.id,
      menuItemId: route.menuItemId,
      menuItemName: route.menuItem.name,
      stationId: route.stationId,
      stationName: route.station.name,
      stationKind: route.station.kind,
    }));
  }

  async replaceRoutes(
    outletId: string,
    dto: StationRoutingWriteDto,
    user: AuthenticatedUser,
  ): Promise<StationRouteResponse[]> {
    await this.assertOutlet(outletId, user);

    const menuItemIds = dto.routes.map((route) => route.menuItemId);
    if (new Set(menuItemIds).size !== menuItemIds.length) {
      throw apiError(400, 'VALIDATION_ERROR', 'Each menu item may route to only one station');
    }
    const stationIds = [...new Set(dto.routes.map((route) => route.stationId))];

    const stations = await this.prisma.station.findMany({
      where: { id: { in: stationIds }, businessId: user.businessId, outletId },
      select: { id: true },
    });
    if (stations.length !== stationIds.length) {
      throw apiError(404, 'STATION_NOT_FOUND', 'Station not found for this outlet');
    }

    const menuItems = await this.prisma.menuItem.findMany({
      where: { id: { in: menuItemIds }, businessId: user.businessId },
      select: { id: true },
    });
    if (menuItems.length !== menuItemIds.length) {
      throw apiError(404, 'MENU_ITEM_NOT_FOUND', 'Menu item not found for this business');
    }

    await this.prisma.$transaction(async (tx) => {
      await tx.stationRoute.deleteMany({ where: { businessId: user.businessId, outletId } });
      if (dto.routes.length > 0) {
        await tx.stationRoute.createMany({
          data: dto.routes.map((route) => ({
            businessId: user.businessId,
            outletId,
            stationId: route.stationId,
            menuItemId: route.menuItemId,
          })),
        });
      }
    });

    return this.listRoutes(outletId, user);
  }

  async createJobs(
    outletId: string,
    orderId: string,
    idempotencyKey: string | undefined,
    dto: StationJobWriteDto,
    user: AuthenticatedUser,
  ): Promise<StationJobResponse[]> {
    await this.assertOutlet(outletId, user);
    if (!idempotencyKey || !UUID_PATTERN.test(idempotencyKey)) {
      throw apiError(400, 'VALIDATION_ERROR', 'A UUID Idempotency-Key header is required');
    }

    const order = await this.prisma.order.findFirst({
      where: { id: orderId, businessId: user.businessId, outletId },
      include: { sale: { select: { id: true, reference: true } } },
    });
    if (!order) {
      throw apiError(404, 'ORDER_NOT_FOUND', 'Order not found for this outlet');
    }
    if (dto.saleId) {
      if (order.sale?.id !== dto.saleId) {
        throw apiError(404, 'SALE_NOT_FOUND', 'Sale not found for this order');
      }
    }
    const sale = order.sale ? { id: order.sale.id, reference: order.sale.reference } : null;

    const variantIds = [...new Set(dto.lines.map((line) => line.variantId))];
    const variants = await this.prisma.menuVariant.findMany({
      where: { id: { in: variantIds } },
      include: { menuItem: { select: { id: true, name: true, businessId: true } } },
    });
    const variantById = new Map(variants.map((variant) => [variant.id, variant]));
    for (const variantId of variantIds) {
      const variant = variantById.get(variantId);
      if (!variant || variant.menuItem.businessId !== user.businessId) {
        throw apiError(404, 'VARIANT_NOT_FOUND', 'Menu variant not found for this business');
      }
    }

    const stations = await this.prisma.station.findMany({
      where: { businessId: user.businessId, outletId },
      orderBy: [{ sortOrder: 'asc' }, { name: 'asc' }],
    });
    if (stations.length === 0) {
      throw apiError(
        409,
        'STATION_NOT_CONFIGURED',
        'Configure at least one station before dispatching station jobs',
      );
    }
    const routeByMenuItem = new Map(
      (
        await this.prisma.stationRoute.findMany({
          where: { businessId: user.businessId, outletId },
          select: { menuItemId: true, stationId: true },
        })
      ).map((route) => [route.menuItemId, route.stationId]),
    );
    const stationById = new Map(stations.map((station) => [station.id, station]));
    const fallback = stations.find((station) => station.isDefault) ?? stations[0];

    const orderReference = sale?.reference ?? `ORDER-${order.id}`;
    const resolved = dto.lines.map((line, index) => {
      const variant = variantById.get(line.variantId);
      if (!variant) {
        throw apiError(404, 'VARIANT_NOT_FOUND', 'Menu variant not found for this business');
      }
      const routedId = routeByMenuItem.get(variant.menuItem.id);
      const station = (routedId ? stationById.get(routedId) : undefined) ?? fallback;
      return {
        line,
        variant,
        station,
        lineIndex: index,
      };
    });

    const existing = await this.findJobsByKey(outletId, user.businessId, idempotencyKey);
    if (existing.length > 0) {
      return this.assertReplay(existing, dto, order.id, resolved);
    }

    const rows = resolved.map(({ line, variant, station, lineIndex }) => ({
      id: randomUUID(),
      businessId: user.businessId,
      outletId,
      stationId: station.id,
      orderId: order.id,
      saleId: sale?.id ?? null,
      variantId: line.variantId,
      orderReference,
      kind: dto.kind,
      itemName: variant.menuItem.name,
      variantName: variant.name,
      quantity: line.quantity,
      modifiers: (line.modifiers ?? []) as unknown as Prisma.InputJsonValue,
      printerConfigId: station.printerConfigId,
      idempotencyKey,
      lineIndex,
    }));

    try {
      await this.prisma.stationJob.createMany({ data: rows });
    } catch (error) {
      if (this.isUniqueViolation(error)) {
        const replay = await this.findJobsByKey(outletId, user.businessId, idempotencyKey);
        if (replay.length > 0) {
          return this.assertReplay(replay, dto, order.id, resolved);
        }
      }
      throw error;
    }
    return this.findJobsByKey(outletId, user.businessId, idempotencyKey);
  }

  async listJobs(
    outletId: string,
    stationId: string,
    query: StationJobListQueryDto,
    user: AuthenticatedUser,
  ): Promise<StationJobPageResponse> {
    await this.assertOutlet(outletId, user);
    await this.assertStation(outletId, stationId, user);

    const limit = query.limit ?? 50;
    const jobs = await this.prisma.stationJob.findMany({
      where: {
        businessId: user.businessId,
        outletId,
        stationId,
        ...(query.state ? { state: query.state } : {}),
      },
      orderBy: [{ createdAt: 'desc' }, { id: 'desc' }],
      take: limit + 1,
      ...(query.cursor ? { cursor: { id: query.cursor }, skip: 1 } : {}),
      include: { station: { select: { name: true } } },
    });
    const hasMore = jobs.length > limit;
    const page = hasMore ? jobs.slice(0, limit) : jobs;
    return {
      items: page.map((job) => this.toJobResponse(job)),
      nextCursor: hasMore ? (page[page.length - 1]?.id ?? null) : null,
    };
  }

  async updateJobState(
    outletId: string,
    jobId: string,
    dto: StationJobStateDto,
    user: AuthenticatedUser,
  ): Promise<StationJobResponse> {
    await this.assertOutlet(outletId, user);
    const job = await this.prisma.stationJob.findFirst({
      where: { id: jobId, businessId: user.businessId, outletId },
    });
    if (!job) {
      throw apiError(404, 'NOT_FOUND', 'Station job not found');
    }
    await this.prisma.stationJob.update({
      where: { id: jobId },
      data: {
        state: dto.state,
        attempts: dto.attempts,
        lastError: dto.lastError ?? null,
      },
    });
    return this.requireJob(outletId, jobId, user);
  }

  async retryJob(
    outletId: string,
    jobId: string,
    user: AuthenticatedUser,
  ): Promise<StationJobResponse> {
    await this.assertOutlet(outletId, user);
    const job = await this.prisma.stationJob.findFirst({
      where: { id: jobId, businessId: user.businessId, outletId },
    });
    if (!job) {
      throw apiError(404, 'NOT_FOUND', 'Station job not found');
    }
    if (job.state !== 'FAILED' && job.state !== 'UNKNOWN') {
      throw apiError(409, 'JOB_NOT_RETRYABLE', 'Only failed or uncertain jobs can be retried');
    }
    await this.prisma.stationJob.update({
      where: { id: jobId },
      data: { state: 'QUEUED', lastError: null },
    });
    return this.requireJob(outletId, jobId, user);
  }

  async reprintJob(
    outletId: string,
    jobId: string,
    idempotencyKey: string | undefined,
    user: AuthenticatedUser,
  ): Promise<StationJobResponse> {
    await this.assertOutlet(outletId, user);
    if (!idempotencyKey || !UUID_PATTERN.test(idempotencyKey)) {
      throw apiError(400, 'VALIDATION_ERROR', 'A UUID Idempotency-Key header is required');
    }
    const original = await this.prisma.stationJob.findFirst({
      where: { id: jobId, businessId: user.businessId, outletId },
    });
    if (!original) {
      throw apiError(404, 'NOT_FOUND', 'Station job not found');
    }

    const existing = await this.prisma.stationJob.findFirst({
      where: {
        businessId: user.businessId,
        outletId,
        idempotencyKey,
        lineIndex: original.lineIndex,
      },
    });
    if (existing) {
      if (existing.copy && existing.reprintOfId === original.id) {
        return this.requireJob(outletId, existing.id, user);
      }
      throw apiError(
        409,
        'IDEMPOTENCY_CONFLICT',
        'The idempotency key was used for another station job',
      );
    }

    const copyId = randomUUID();
    await this.prisma.stationJob.create({
      data: {
        id: copyId,
        businessId: user.businessId,
        outletId,
        stationId: original.stationId,
        orderId: original.orderId,
        saleId: original.saleId,
        variantId: original.variantId,
        orderReference: original.orderReference,
        kind: original.kind,
        state: 'QUEUED',
        copy: true,
        reprintOfId: original.id,
        itemName: original.itemName,
        variantName: original.variantName,
        quantity: original.quantity,
        modifiers: original.modifiers as Prisma.InputJsonValue,
        printerConfigId: original.printerConfigId,
        idempotencyKey,
        lineIndex: original.lineIndex,
      },
    });
    return this.requireJob(outletId, copyId, user);
  }

  private async findJobsByKey(
    outletId: string,
    businessId: string,
    idempotencyKey: string,
  ): Promise<StationJobResponse[]> {
    const jobs = await this.prisma.stationJob.findMany({
      where: { businessId, outletId, idempotencyKey },
      orderBy: { lineIndex: 'asc' },
      include: { station: { select: { name: true } } },
    });
    return jobs.map((job) => this.toJobResponse(job));
  }

  private assertReplay(
    existing: StationJobResponse[],
    dto: StationJobWriteDto,
    orderId: string,
    resolved: { line: StationJobWriteDto['lines'][number]; lineIndex: number }[],
  ): StationJobResponse[] {
    const matches =
      existing.length === dto.lines.length &&
      existing.every((job, index) => {
        const resolvedLine = resolved[index];
        return (
          job.orderId === orderId &&
          job.kind === dto.kind &&
          resolvedLine !== undefined &&
          job.variantId === resolvedLine.line.variantId &&
          job.quantity === resolvedLine.line.quantity
        );
      });
    if (!matches) {
      throw apiError(
        409,
        'IDEMPOTENCY_CONFLICT',
        'The idempotency key was used for another station job batch',
      );
    }
    return existing;
  }

  private async requireJob(
    outletId: string,
    jobId: string,
    user: AuthenticatedUser,
  ): Promise<StationJobResponse> {
    const job = await this.prisma.stationJob.findFirst({
      where: { id: jobId, businessId: user.businessId, outletId },
      include: { station: { select: { name: true } } },
    });
    if (!job) {
      throw apiError(404, 'NOT_FOUND', 'Station job not found');
    }
    return this.toJobResponse(job);
  }

  private async assertOutlet(outletId: string, user: AuthenticatedUser): Promise<void> {
    const outlet = await this.prisma.outlet.findFirst({
      where: { id: outletId, businessId: user.businessId },
      select: { id: true },
    });
    if (!outlet) {
      throw apiError(404, 'NOT_FOUND', 'Outlet not found');
    }
  }

  private async assertStation(
    outletId: string,
    stationId: string,
    user: AuthenticatedUser,
  ): Promise<void> {
    const station = await this.prisma.station.findFirst({
      where: { id: stationId, businessId: user.businessId, outletId },
      select: { id: true },
    });
    if (!station) {
      throw apiError(404, 'NOT_FOUND', 'Station not found');
    }
  }

  private async assertPrinter(
    outletId: string,
    printerConfigId: string | undefined,
    user: AuthenticatedUser,
  ): Promise<void> {
    if (!printerConfigId) {
      return;
    }
    const printer = await this.prisma.printer.findFirst({
      where: { id: printerConfigId, businessId: user.businessId, outletId },
      select: { id: true },
    });
    if (!printer) {
      throw apiError(404, 'PRINTER_NOT_FOUND', 'Printer configuration not found for this outlet');
    }
  }

  private async clearOtherDefaults(
    tx: Prisma.TransactionClient,
    outletId: string,
    businessId: string,
    stationId: string,
  ): Promise<void> {
    await tx.station.updateMany({
      where: { outletId, businessId, isDefault: true, id: { not: stationId } },
      data: { isDefault: false },
    });
  }

  private isUniqueViolation(error: unknown): boolean {
    return error instanceof Prisma.PrismaClientKnownRequestError && error.code === 'P2002';
  }

  private toStationResponse(station: StationWithRelations): StationResponse {
    return {
      id: station.id,
      name: station.name,
      kind: station.kind,
      isDefault: station.isDefault,
      printerConfigId: station.printerConfigId,
      printerModel: station.printer?.model ?? null,
      sortOrder: station.sortOrder,
      revision: station.revision,
      routeCount: station._count?.routes ?? 0,
    };
  }

  private toJobResponse(job: StationJobWithStation): StationJobResponse {
    return {
      id: job.id,
      stationId: job.stationId,
      stationName: job.station.name,
      orderId: job.orderId,
      saleId: job.saleId,
      orderReference: job.orderReference,
      variantId: job.variantId,
      kind: job.kind,
      state: job.state,
      copy: job.copy,
      reprintOfId: job.reprintOfId,
      itemName: job.itemName,
      variantName: job.variantName,
      quantity: job.quantity,
      modifiers: this.readModifiers(job.modifiers),
      attempts: job.attempts,
      lastError: job.lastError,
      createdAt: job.createdAt.toISOString(),
      updatedAt: job.updatedAt.toISOString(),
    };
  }

  private readModifiers(value: Prisma.JsonValue): Record<string, unknown>[] {
    if (!Array.isArray(value)) {
      return [];
    }
    const modifiers: Record<string, unknown>[] = [];
    for (const entry of value) {
      if (typeof entry === 'object' && entry !== null && !Array.isArray(entry)) {
        modifiers.push(entry as Record<string, unknown>);
      }
    }
    return modifiers;
  }
}
