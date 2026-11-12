import { randomUUID } from 'node:crypto';
import { Injectable } from '@nestjs/common';
import {
  Prisma,
  PurchaseOrderState,
  StockMovementType,
  TransferState,
  WasteReason,
} from '@prisma/client';
import type { AuthenticatedUser } from '../auth/auth.types';
import { apiError } from '../common/api-error';
import { PrismaService } from '../prisma/prisma.service';
import type { MovementResponse } from '../stock/stock.service';
import {
  convertReceiptQuantity,
  nextPurchaseOrderState,
  PurchasingUnit,
  transferInTransitQuantity,
} from './purchasing.logic';
import {
  PurchaseOrderCreateDto,
  PurchaseOrderListQueryDto,
  PurchaseOrderReceiptDto,
  PurchaseOrderReceiptUnit,
  StockCountCreateDto,
  StockCountListQueryDto,
  SupplierCreateDto,
  SupplierListQueryDto,
  TransferCreateDto,
  TransferListQueryDto,
  TransferReceiveDto,
  WasteCreateDto,
  WasteListQueryDto,
} from './dto/purchasing.dto';

const MAX_QUANTITY = new Prisma.Decimal('100000000000000');
const MAX_UNIT_FACTOR = new Prisma.Decimal('1000000');
const ZERO = new Prisma.Decimal(0);

function fractionDigits(value: string): number {
  const dot = value.indexOf('.');
  return dot === -1 ? 0 : value.length - dot - 1;
}

function referenceFor(prefix: string): string {
  return `${prefix}-${randomUUID().slice(0, 8).toUpperCase()}`;
}

function isUniqueViolation(error: unknown): boolean {
  return error instanceof Prisma.PrismaClientKnownRequestError && error.code === 'P2002';
}

function isPositive(value: Prisma.Decimal): boolean {
  return value.greaterThan(0);
}

function assertQuantity(value: Prisma.Decimal, label: string): void {
  if (value.lessThanOrEqualTo(0)) {
    throw apiError(400, 'VALIDATION_ERROR', `${label} must be greater than zero`);
  }
  if (value.greaterThan(MAX_QUANTITY)) {
    throw apiError(400, 'VALIDATION_ERROR', `${label} exceeds the supported quantity limit`);
  }
}

function assertRepresentable(value: Prisma.Decimal, quantityScale: number, label: string): void {
  if (fractionDigits(value.toString()) > quantityScale) {
    throw apiError(
      422,
      'QUANTITY_PRECISION_EXCEEDED',
      `${label} cannot be represented with the item quantity scale of ${quantityScale}`,
    );
  }
}

export interface SupplierResponse {
  id: string;
  name: string;
  reference: string | null;
  contact: string | null;
  createdAt: string;
}

export interface SupplierPageResponse {
  items: SupplierResponse[];
  nextCursor: string | null;
}

export interface PurchaseOrderLineResponse {
  id: string;
  stockItemId: string;
  stockItemName: string;
  baseUnit: string;
  quantityScale: number;
  supplierUnit: string;
  unitsPerSupplierUnit: string;
  orderedQuantity: string;
  receivedQuantity: string;
  remainingQuantity: string;
  orderedBaseQuantity: string;
  receivedBaseQuantity: string;
  remainingBaseQuantity: string;
  unitPrice: string;
  version: number;
}

export interface PurchaseOrderResponse {
  id: string;
  outletId: string;
  supplierId: string;
  supplierName: string;
  supplierReference: string | null;
  reference: string;
  state: PurchaseOrderState;
  createdAt: string;
  closedAt: string | null;
  lines: PurchaseOrderLineResponse[];
}

export interface PurchaseOrderPageResponse {
  items: PurchaseOrderResponse[];
  nextCursor: string | null;
}

export interface PurchaseOrderReceiptResponse {
  purchaseOrder: PurchaseOrderResponse;
  line: PurchaseOrderLineResponse;
  movement: MovementResponse;
}

export interface StockCountLineResponse {
  stockItemId: string;
  stockItemName: string;
  baseUnit: string;
  quantityScale: number;
  systemQuantity: string;
  countedQuantity: string;
  variance: string;
}

export interface StockCountResponse {
  id: string;
  outletId: string;
  reference: string;
  reason: string;
  actorId: string;
  createdAt: string;
  lines: StockCountLineResponse[];
  movements: MovementResponse[];
}

export interface StockCountPageResponse {
  items: StockCountResponse[];
  nextCursor: string | null;
}

export interface WasteResponse {
  id: string;
  outletId: string;
  stockItemId: string;
  stockItemName: string;
  quantity: string;
  reason: WasteReason;
  note: string | null;
  actorId: string;
  createdAt: string;
  movement: MovementResponse;
}

export interface WastePageResponse {
  items: WasteResponse[];
  nextCursor: string | null;
}

export interface TransferLineResponse {
  id: string;
  stockItemId: string;
  stockItemName: string;
  baseUnit: string;
  quantityScale: number;
  dispatchedQuantity: string;
  receivedQuantity: string;
  inTransitQuantity: string;
}

export interface TransferResponse {
  id: string;
  sourceOutletId: string;
  sourceOutletName: string;
  destinationOutletId: string;
  destinationOutletName: string;
  reference: string;
  note: string | null;
  state: TransferState;
  version: number;
  createdAt: string;
  dispatchedAt: string | null;
  receivedAt: string | null;
  cancelledAt: string | null;
  inTransitQuantity: string;
  lines: TransferLineResponse[];
}

export interface TransferPageResponse {
  items: TransferResponse[];
  nextCursor: string | null;
}

export interface TransferMutationResponse {
  transfer: TransferResponse;
  movements: MovementResponse[];
}

type Tx = Prisma.TransactionClient;

@Injectable()
export class PurchasingService {
  constructor(private readonly prisma: PrismaService) {}

  async listSuppliers(
    outletId: string,
    query: SupplierListQueryDto,
    user: AuthenticatedUser,
  ): Promise<SupplierPageResponse> {
    await this.requireOutlet(this.prisma, outletId, user.businessId);
    const limit = query.limit ?? 25;
    const search = query.search?.trim();
    const rows = await this.prisma.supplier.findMany({
      where: {
        businessId: user.businessId,
        archivedAt: null,
        ...(search ? { name: { contains: search, mode: 'insensitive' as const } } : {}),
      },
      orderBy: [{ name: 'asc' }, { id: 'asc' }],
      take: limit + 1,
      ...(query.cursor ? { cursor: { id: query.cursor }, skip: 1 } : {}),
    });
    const hasMore = rows.length > limit;
    const page = hasMore ? rows.slice(0, limit) : rows;

    return {
      items: page.map((row) => this.toSupplier(row)),
      nextCursor: hasMore ? (page[page.length - 1]?.id ?? null) : null,
    };
  }

  async createSupplier(
    outletId: string,
    dto: SupplierCreateDto,
    user: AuthenticatedUser,
  ): Promise<SupplierResponse> {
    await this.requireOutlet(this.prisma, outletId, user.businessId);
    const reference = dto.reference?.trim() || null;
    try {
      const supplier = await this.prisma.supplier.create({
        data: {
          businessId: user.businessId,
          name: dto.name,
          reference,
          contact: dto.contact?.trim() || null,
        },
      });
      return this.toSupplier(supplier);
    } catch (error) {
      if (isUniqueViolation(error)) {
        throw apiError(409, 'SUPPLIER_REFERENCE_CONFLICT', 'Supplier reference is already used');
      }
      throw error;
    }
  }

  async listPurchaseOrders(
    outletId: string,
    query: PurchaseOrderListQueryDto,
    user: AuthenticatedUser,
  ): Promise<PurchaseOrderPageResponse> {
    await this.requireOutlet(this.prisma, outletId, user.businessId);
    const limit = query.limit ?? 25;
    const rows = await this.prisma.purchaseOrder.findMany({
      where: { businessId: user.businessId, outletId },
      orderBy: [{ createdAt: 'desc' }, { id: 'desc' }],
      take: limit + 1,
      ...(query.cursor ? { cursor: { id: query.cursor }, skip: 1 } : {}),
      include: this.purchaseOrderInclude(),
    });
    const hasMore = rows.length > limit;
    const page = hasMore ? rows.slice(0, limit) : rows;

    return {
      items: page.map((row) => this.toPurchaseOrder(row)),
      nextCursor: hasMore ? (page[page.length - 1]?.id ?? null) : null,
    };
  }

  async createPurchaseOrder(
    outletId: string,
    dto: PurchaseOrderCreateDto,
    user: AuthenticatedUser,
  ): Promise<PurchaseOrderResponse> {
    await this.requireOutlet(this.prisma, outletId, user.businessId);
    const supplier = await this.prisma.supplier.findFirst({
      where: { id: dto.supplierId, businessId: user.businessId, archivedAt: null },
      select: { id: true, name: true, reference: true },
    });
    if (!supplier) {
      throw apiError(404, 'NOT_FOUND', 'Supplier not found');
    }

    const itemIds = [...new Set(dto.lines.map((line) => line.stockItemId))];
    if (itemIds.length !== dto.lines.length) {
      throw apiError(400, 'VALIDATION_ERROR', 'Purchase order lines must use distinct stock items');
    }
    const items = await this.prisma.stockItem.findMany({
      where: { id: { in: itemIds }, businessId: user.businessId },
      select: { id: true, name: true, baseUnit: true, quantityScale: true },
    });
    const itemById = new Map(items.map((item) => [item.id, item]));
    if (itemById.size !== itemIds.length) {
      throw apiError(404, 'NOT_FOUND', 'A purchase order stock item was not found');
    }

    const lines = dto.lines.map((line) => {
      const item = itemById.get(line.stockItemId);
      if (!item) {
        throw apiError(404, 'NOT_FOUND', 'A purchase order stock item was not found');
      }
      const unitsPerSupplierUnit = new Prisma.Decimal(line.unitsPerSupplierUnit);
      const orderedSupplierQuantity = new Prisma.Decimal(line.orderedQuantity);
      const unitPrice = new Prisma.Decimal(line.unitPrice);

      assertQuantity(unitsPerSupplierUnit, 'unitsPerSupplierUnit');
      if (unitsPerSupplierUnit.greaterThan(MAX_UNIT_FACTOR)) {
        throw apiError(400, 'VALIDATION_ERROR', 'unitsPerSupplierUnit exceeds the supported limit');
      }
      assertQuantity(orderedSupplierQuantity, 'orderedQuantity');
      if (unitPrice.lessThan(0) || unitPrice.greaterThan(MAX_QUANTITY)) {
        throw apiError(400, 'VALIDATION_ERROR', 'unitPrice must be non-negative and in range');
      }
      const orderedBaseQuantity = orderedSupplierQuantity.mul(unitsPerSupplierUnit);
      if (orderedBaseQuantity.greaterThan(MAX_QUANTITY)) {
        throw apiError(
          400,
          'VALIDATION_ERROR',
          'ordered base quantity exceeds the supported limit',
        );
      }
      assertRepresentable(orderedBaseQuantity, item.quantityScale, 'ordered base quantity');

      return {
        stockItemId: line.stockItemId,
        supplierUnit: line.supplierUnit,
        unitsPerSupplierUnit,
        orderedSupplierQuantity,
        orderedBaseQuantity,
        unitPrice,
      };
    });

    const reference = dto.reference?.trim() || referenceFor('PO');
    try {
      const order = await this.prisma.purchaseOrder.create({
        data: {
          businessId: user.businessId,
          outletId,
          supplierId: supplier.id,
          reference,
          createdById: user.id,
          lines: { create: lines },
        },
        include: this.purchaseOrderInclude(),
      });
      return this.toPurchaseOrder(order);
    } catch (error) {
      if (isUniqueViolation(error)) {
        throw apiError(
          409,
          'PURCHASE_ORDER_REFERENCE_CONFLICT',
          'Purchase order reference is already used',
        );
      }
      throw error;
    }
  }

  async receivePurchaseOrder(
    outletId: string,
    purchaseOrderId: string,
    dto: PurchaseOrderReceiptDto,
    user: AuthenticatedUser,
  ): Promise<PurchaseOrderReceiptResponse> {
    return this.prisma.$transaction(async (tx) => {
      await this.requireOutlet(tx, outletId, user.businessId);
      await tx.$queryRaw`SELECT id FROM "purchase_orders" WHERE id = ${purchaseOrderId}::uuid FOR UPDATE`;

      const order = await tx.purchaseOrder.findFirst({
        where: { id: purchaseOrderId, businessId: user.businessId, outletId },
        include: this.purchaseOrderInclude(),
      });
      if (!order) {
        throw apiError(404, 'NOT_FOUND', 'Purchase order not found');
      }
      if (order.state === PurchaseOrderState.CANCELLED) {
        throw apiError(409, 'PURCHASE_ORDER_CANCELLED', 'This purchase order was cancelled');
      }
      if (order.state === PurchaseOrderState.RECEIVED) {
        throw apiError(409, 'PURCHASE_ORDER_CLOSED', 'This purchase order is fully received');
      }

      const line = order.lines.find((candidate) => candidate.id === dto.lineId);
      if (!line) {
        throw apiError(404, 'NOT_FOUND', 'Purchase order line not found');
      }

      const { baseDelta, supplierDelta } = this.convertReceipt(
        line,
        dto.quantity,
        dto.unit,
        line.stockItem.quantityScale,
      );
      if (line.receivedBaseQuantity.plus(baseDelta).greaterThan(line.orderedBaseQuantity)) {
        throw apiError(
          422,
          'OVER_RECEIPT',
          'Received quantity would exceed the ordered base quantity',
        );
      }
      if (
        line.receivedSupplierQuantity.plus(supplierDelta).greaterThan(line.orderedSupplierQuantity)
      ) {
        throw apiError(
          422,
          'OVER_RECEIPT',
          'Received quantity would exceed the ordered supplier quantity',
        );
      }

      const updatedLine = await tx.purchaseOrderLine.updateMany({
        where: { id: line.id, version: line.version },
        data: {
          receivedBaseQuantity: { increment: baseDelta },
          receivedSupplierQuantity: { increment: supplierDelta },
          version: { increment: 1 },
        },
      });
      if (updatedLine.count !== 1) {
        throw apiError(409, 'RECEIPT_CONFLICT', 'The purchase order line changed during receipt');
      }

      await this.applyInboundQuantity(tx, outletId, line.stockItemId, baseDelta);

      const reason = dto.note?.trim()
        ? `Purchase receipt ${order.reference}: ${dto.note.trim()}`
        : `Purchase receipt ${order.reference} from ${order.supplier.name}`;
      const movement = await tx.stockMovement.create({
        data: {
          outletId,
          stockItemId: line.stockItemId,
          delta: baseDelta,
          type: StockMovementType.RECEIPT,
          actorId: user.id,
          reason,
          sourceId: line.id,
          supplierId: order.supplierId,
          purchaseOrderId: order.id,
        },
      });

      await this.assertBalanceDerivable(tx, outletId, line.stockItemId);

      const refreshedLines = await tx.purchaseOrderLine.findMany({
        where: { purchaseOrderId: order.id },
      });
      const fullyReceived = refreshedLines.every((row) =>
        row.receivedBaseQuantity.greaterThanOrEqualTo(row.orderedBaseQuantity),
      );
      const nextState = nextPurchaseOrderState(refreshedLines);
      await tx.purchaseOrder.update({
        where: { id: order.id },
        data: {
          state: nextState,
          closedAt: fullyReceived ? new Date() : null,
        },
      });

      const refreshedOrder = await tx.purchaseOrder.findUniqueOrThrow({
        where: { id: order.id },
        include: this.purchaseOrderInclude(),
      });
      const refreshedLine = refreshedOrder.lines.find((row) => row.id === line.id);

      return {
        purchaseOrder: this.toPurchaseOrder(refreshedOrder),
        line: this.toPurchaseOrderLine(refreshedLine ?? line),
        movement: this.toMovement(movement, line.stockItem.quantityScale),
      };
    });
  }

  async cancelPurchaseOrder(
    outletId: string,
    purchaseOrderId: string,
    user: AuthenticatedUser,
  ): Promise<PurchaseOrderResponse> {
    return this.prisma.$transaction(async (tx) => {
      await this.requireOutlet(tx, outletId, user.businessId);
      await tx.$queryRaw`SELECT id FROM "purchase_orders" WHERE id = ${purchaseOrderId}::uuid FOR UPDATE`;
      const order = await tx.purchaseOrder.findFirst({
        where: { id: purchaseOrderId, businessId: user.businessId, outletId },
        include: this.purchaseOrderInclude(),
      });
      if (!order) {
        throw apiError(404, 'NOT_FOUND', 'Purchase order not found');
      }
      if (order.state === PurchaseOrderState.CANCELLED) {
        throw apiError(
          409,
          'PURCHASE_ORDER_CANCELLED',
          'This purchase order was already cancelled',
        );
      }
      if (
        order.state === PurchaseOrderState.RECEIVED ||
        order.state === PurchaseOrderState.PARTIALLY_RECEIVED
      ) {
        throw apiError(
          409,
          'PURCHASE_ORDER_HAS_RECEIPTS',
          'A purchase order with receipts cannot be cancelled',
        );
      }
      const updated = await tx.purchaseOrder.update({
        where: { id: order.id },
        data: { state: PurchaseOrderState.CANCELLED, closedAt: new Date() },
        include: this.purchaseOrderInclude(),
      });
      return this.toPurchaseOrder(updated);
    });
  }

  async listStockCounts(
    outletId: string,
    query: StockCountListQueryDto,
    user: AuthenticatedUser,
  ): Promise<StockCountPageResponse> {
    await this.requireOutlet(this.prisma, outletId, user.businessId);
    const limit = query.limit ?? 25;
    const rows = await this.prisma.stockCount.findMany({
      where: { outletId, businessId: user.businessId },
      orderBy: [{ createdAt: 'desc' }, { id: 'desc' }],
      take: limit + 1,
      ...(query.cursor ? { cursor: { id: query.cursor }, skip: 1 } : {}),
      include: this.stockCountInclude(),
    });
    const hasMore = rows.length > limit;
    const page = hasMore ? rows.slice(0, limit) : rows;

    return {
      items: page.map((row) => this.toStockCount(row)),
      nextCursor: hasMore ? (page[page.length - 1]?.id ?? null) : null,
    };
  }

  async createStockCount(
    outletId: string,
    dto: StockCountCreateDto,
    user: AuthenticatedUser,
  ): Promise<StockCountResponse> {
    return this.prisma.$transaction(async (tx) => {
      await this.requireOutlet(tx, outletId, user.businessId);
      const itemIds = dto.lines.map((line) => line.stockItemId);
      if (new Set(itemIds).size !== itemIds.length) {
        throw apiError(400, 'VALIDATION_ERROR', 'Stock count lines must use distinct stock items');
      }
      const items = await tx.stockItem.findMany({
        where: { id: { in: itemIds }, businessId: user.businessId },
        select: {
          id: true,
          name: true,
          baseUnit: true,
          quantityScale: true,
        },
      });
      const itemById = new Map(items.map((item) => [item.id, item]));
      if (itemById.size !== itemIds.length) {
        throw apiError(404, 'NOT_FOUND', 'A stock count item was not found');
      }

      for (const itemId of itemIds) {
        await tx.$queryRaw`SELECT id FROM "stock_items" WHERE id = ${itemId}::uuid FOR UPDATE`;
      }

      const balances = await tx.stockBalance.findMany({
        where: { outletId, stockItemId: { in: itemIds } },
        select: { stockItemId: true, quantity: true },
      });
      const balanceByItem = new Map(balances.map((row) => [row.stockItemId, row.quantity]));

      const lines = dto.lines.map((line) => {
        const item = itemById.get(line.stockItemId);
        if (!item) {
          throw apiError(404, 'NOT_FOUND', 'A stock count item was not found');
        }
        const countedQuantity = new Prisma.Decimal(line.countedQuantity);
        if (countedQuantity.lessThan(0) || countedQuantity.greaterThan(MAX_QUANTITY)) {
          throw apiError(400, 'VALIDATION_ERROR', 'countedQuantity is out of range');
        }
        assertRepresentable(countedQuantity, item.quantityScale, 'countedQuantity');
        const systemQuantity = balanceByItem.get(line.stockItemId) ?? ZERO;
        return {
          stockItemId: line.stockItemId,
          systemQuantity,
          countedQuantity,
          variance: countedQuantity.minus(systemQuantity),
          item,
        };
      });

      const reference = dto.reference?.trim() || referenceFor('SC');
      let count;
      try {
        count = await tx.stockCount.create({
          data: {
            businessId: user.businessId,
            outletId,
            reference,
            reason: dto.reason,
            actorId: user.id,
            lines: {
              create: lines.map((line) => ({
                stockItemId: line.stockItemId,
                systemQuantity: line.systemQuantity,
                countedQuantity: line.countedQuantity,
                variance: line.variance,
              })),
            },
          },
        });
      } catch (error) {
        if (isUniqueViolation(error)) {
          throw apiError(
            409,
            'STOCK_COUNT_REFERENCE_CONFLICT',
            'Stock count reference is already used',
          );
        }
        throw error;
      }

      const movements: MovementResponse[] = [];
      for (const line of lines) {
        if (line.variance.isZero()) {
          continue;
        }
        await this.applySignedVariance(
          tx,
          outletId,
          line.stockItemId,
          line.variance,
          line.item.quantityScale,
        );
        const movement = await tx.stockMovement.create({
          data: {
            outletId,
            stockItemId: line.stockItemId,
            delta: line.variance,
            type: StockMovementType.COUNT,
            actorId: user.id,
            reason: dto.reason,
            sourceId: count.id,
            stockCountId: count.id,
          },
        });
        movements.push(this.toMovement(movement, line.item.quantityScale));
        await this.assertBalanceDerivable(tx, outletId, line.stockItemId);
      }

      return {
        id: count.id,
        outletId,
        reference,
        reason: dto.reason,
        actorId: user.id,
        createdAt: count.createdAt.toISOString(),
        lines: lines.map((line) => ({
          stockItemId: line.stockItemId,
          stockItemName: line.item.name,
          baseUnit: line.item.baseUnit,
          quantityScale: line.item.quantityScale,
          systemQuantity: line.systemQuantity.toFixed(line.item.quantityScale),
          countedQuantity: line.countedQuantity.toFixed(line.item.quantityScale),
          variance: line.variance.toFixed(line.item.quantityScale),
        })),
        movements,
      };
    });
  }

  async listWaste(
    outletId: string,
    query: WasteListQueryDto,
    user: AuthenticatedUser,
  ): Promise<WastePageResponse> {
    await this.requireOutlet(this.prisma, outletId, user.businessId);
    const limit = query.limit ?? 25;
    const rows = await this.prisma.stockWaste.findMany({
      where: { outletId, businessId: user.businessId },
      orderBy: [{ createdAt: 'desc' }, { id: 'desc' }],
      take: limit + 1,
      ...(query.cursor ? { cursor: { id: query.cursor }, skip: 1 } : {}),
      include: { stockItem: { select: { name: true, quantityScale: true } } },
    });
    const hasMore = rows.length > limit;
    const page = hasMore ? rows.slice(0, limit) : rows;

    return {
      items: page.map((row) => ({
        id: row.id,
        outletId: row.outletId,
        stockItemId: row.stockItemId,
        stockItemName: row.stockItem.name,
        quantity: row.quantity.toFixed(row.stockItem.quantityScale),
        reason: row.reason,
        note: row.note,
        actorId: row.actorId,
        createdAt: row.createdAt.toISOString(),
        movement: {
          id: '',
          outletId: row.outletId,
          stockItemId: row.stockItemId,
          delta: row.quantity.negated().toFixed(row.stockItem.quantityScale),
          type: StockMovementType.WASTE,
          reason: row.note ? `${row.reason}: ${row.note}` : row.reason,
          sourceId: row.id,
          sourceReference: null,
          supplierId: null,
          supplierName: null,
          supplierReference: null,
          purchaseOrderId: null,
          purchaseOrderReference: null,
          transferId: null,
          transferReference: null,
          stockCountId: null,
          stockCountReference: null,
          stockWasteId: row.id,
          actorId: row.actorId,
          createdAt: row.createdAt.toISOString(),
        },
      })),
      nextCursor: hasMore ? (page[page.length - 1]?.id ?? null) : null,
    };
  }

  async recordWaste(
    outletId: string,
    dto: WasteCreateDto,
    user: AuthenticatedUser,
  ): Promise<WasteResponse> {
    return this.prisma.$transaction(async (tx) => {
      await this.requireOutlet(tx, outletId, user.businessId);
      const item = await tx.stockItem.findFirst({
        where: { id: dto.stockItemId, businessId: user.businessId },
        select: { id: true, name: true, quantityScale: true },
      });
      if (!item) {
        throw apiError(404, 'NOT_FOUND', 'Stock item not found');
      }
      const quantity = new Prisma.Decimal(dto.quantity);
      assertQuantity(quantity, 'quantity');
      assertRepresentable(quantity, item.quantityScale, 'quantity');

      const updated = await tx.stockBalance.updateMany({
        where: {
          outletId,
          stockItemId: item.id,
          quantity: { gte: quantity },
        },
        data: { quantity: { decrement: quantity }, version: { increment: 1 } },
      });
      if (updated.count !== 1) {
        throw apiError(422, 'INSUFFICIENT_STOCK', 'Waste would make the stock balance negative');
      }

      const waste = await tx.stockWaste.create({
        data: {
          businessId: user.businessId,
          outletId,
          stockItemId: item.id,
          quantity,
          reason: dto.reason,
          note: dto.note?.trim() || null,
          actorId: user.id,
        },
      });
      const reason = dto.note?.trim() ? `${dto.reason}: ${dto.note.trim()}` : dto.reason;
      const movement = await tx.stockMovement.create({
        data: {
          outletId,
          stockItemId: item.id,
          delta: quantity.negated(),
          type: StockMovementType.WASTE,
          actorId: user.id,
          reason,
          sourceId: waste.id,
          stockWasteId: waste.id,
        },
      });
      await this.assertBalanceDerivable(tx, outletId, item.id);

      return {
        id: waste.id,
        outletId,
        stockItemId: item.id,
        stockItemName: item.name,
        quantity: quantity.toFixed(item.quantityScale),
        reason: waste.reason,
        note: waste.note,
        actorId: waste.actorId,
        createdAt: waste.createdAt.toISOString(),
        movement: this.toMovement(movement, item.quantityScale),
      };
    });
  }

  async listTransfers(
    outletId: string,
    query: TransferListQueryDto,
    user: AuthenticatedUser,
  ): Promise<TransferPageResponse> {
    await this.requireOutlet(this.prisma, outletId, user.businessId);
    const limit = query.limit ?? 25;
    const rows = await this.prisma.outletTransfer.findMany({
      where: {
        businessId: user.businessId,
        OR: [{ sourceOutletId: outletId }, { destinationOutletId: outletId }],
        ...(query.state ? { state: query.state } : {}),
      },
      orderBy: [{ createdAt: 'desc' }, { id: 'desc' }],
      take: limit + 1,
      ...(query.cursor ? { cursor: { id: query.cursor }, skip: 1 } : {}),
      include: this.transferInclude(),
    });
    const hasMore = rows.length > limit;
    const page = hasMore ? rows.slice(0, limit) : rows;

    return {
      items: page.map((row) => this.toTransfer(row)),
      nextCursor: hasMore ? (page[page.length - 1]?.id ?? null) : null,
    };
  }

  async createTransfer(
    outletId: string,
    dto: TransferCreateDto,
    user: AuthenticatedUser,
  ): Promise<TransferResponse> {
    await this.requireOutlet(this.prisma, outletId, user.businessId);
    if (dto.destinationOutletId === outletId) {
      throw apiError(400, 'VALIDATION_ERROR', 'A transfer requires two different outlets');
    }
    const destination = await this.prisma.outlet.findFirst({
      where: { id: dto.destinationOutletId, businessId: user.businessId },
      select: { id: true },
    });
    if (!destination) {
      throw apiError(404, 'NOT_FOUND', 'Destination outlet not found');
    }
    const itemIds = dto.lines.map((line) => line.stockItemId);
    if (new Set(itemIds).size !== itemIds.length) {
      throw apiError(400, 'VALIDATION_ERROR', 'Transfer lines must use distinct stock items');
    }
    const items = await this.prisma.stockItem.findMany({
      where: { id: { in: itemIds }, businessId: user.businessId },
      select: { id: true, quantityScale: true },
    });
    const itemById = new Map(items.map((item) => [item.id, item]));
    if (itemById.size !== itemIds.length) {
      throw apiError(404, 'NOT_FOUND', 'A transfer stock item was not found');
    }
    const lines = dto.lines.map((line) => {
      const item = itemById.get(line.stockItemId);
      if (!item) {
        throw apiError(404, 'NOT_FOUND', 'A transfer stock item was not found');
      }
      const quantity = new Prisma.Decimal(line.quantity);
      assertQuantity(quantity, 'quantity');
      assertRepresentable(quantity, item.quantityScale, 'quantity');
      return { stockItemId: line.stockItemId, dispatchedQuantity: quantity };
    });
    const reference = dto.reference?.trim() || referenceFor('TR');
    try {
      const transfer = await this.prisma.outletTransfer.create({
        data: {
          businessId: user.businessId,
          sourceOutletId: outletId,
          destinationOutletId: dto.destinationOutletId,
          reference,
          note: dto.reason?.trim() || null,
          createdById: user.id,
          lines: { create: lines },
        },
        include: this.transferInclude(),
      });
      return this.toTransfer(transfer);
    } catch (error) {
      if (isUniqueViolation(error)) {
        throw apiError(409, 'TRANSFER_REFERENCE_CONFLICT', 'Transfer reference is already used');
      }
      throw error;
    }
  }

  async dispatchTransfer(
    outletId: string,
    transferId: string,
    user: AuthenticatedUser,
  ): Promise<TransferMutationResponse> {
    return this.prisma.$transaction(async (tx) => {
      await this.requireOutlet(tx, outletId, user.businessId);
      await tx.$queryRaw`SELECT id FROM "outlet_transfers" WHERE id = ${transferId}::uuid FOR UPDATE`;
      const transfer = await tx.outletTransfer.findFirst({
        where: { id: transferId, businessId: user.businessId },
        include: this.transferInclude(),
      });
      if (!transfer || transfer.sourceOutletId !== outletId) {
        throw apiError(404, 'NOT_FOUND', 'Transfer not found');
      }
      if (transfer.state === TransferState.CANCELLED) {
        throw apiError(409, 'TRANSFER_CANCELLED', 'This transfer was cancelled');
      }
      if (transfer.state !== TransferState.DRAFT) {
        throw apiError(409, 'TRANSFER_NOT_DRAFT', 'Only a draft transfer can be dispatched');
      }

      const movements: MovementResponse[] = [];
      for (const line of transfer.lines) {
        const delta = line.dispatchedQuantity.negated();
        const updated = await tx.stockBalance.updateMany({
          where: {
            outletId,
            stockItemId: line.stockItemId,
            quantity: { gte: line.dispatchedQuantity },
          },
          data: {
            quantity: { decrement: line.dispatchedQuantity },
            version: { increment: 1 },
          },
        });
        if (updated.count !== 1) {
          throw apiError(422, 'INSUFFICIENT_STOCK', 'Transfer exceeds the source outlet stock');
        }
        const movement = await tx.stockMovement.create({
          data: {
            outletId,
            stockItemId: line.stockItemId,
            delta,
            type: StockMovementType.TRANSFER_OUT,
            actorId: user.id,
            reason: `Transfer ${transfer.reference} dispatched`,
            sourceId: transfer.id,
            transferId: transfer.id,
          },
        });
        movements.push(this.toMovement(movement, line.stockItem.quantityScale));
        await this.assertBalanceDerivable(tx, outletId, line.stockItemId);
      }

      const updatedTransfer = await tx.outletTransfer.updateMany({
        where: { id: transfer.id, version: transfer.version, state: TransferState.DRAFT },
        data: {
          state: TransferState.DISPATCHED,
          dispatchedById: user.id,
          dispatchedAt: new Date(),
          version: { increment: 1 },
        },
      });
      if (updatedTransfer.count !== 1) {
        throw apiError(409, 'TRANSFER_CONFLICT', 'The transfer changed during dispatch');
      }

      const refreshed = await tx.outletTransfer.findUniqueOrThrow({
        where: { id: transfer.id },
        include: this.transferInclude(),
      });
      return { transfer: this.toTransfer(refreshed), movements };
    });
  }

  async receiveTransfer(
    outletId: string,
    transferId: string,
    dto: TransferReceiveDto,
    user: AuthenticatedUser,
  ): Promise<TransferMutationResponse> {
    return this.prisma.$transaction(async (tx) => {
      await this.requireOutlet(tx, outletId, user.businessId);
      await tx.$queryRaw`SELECT id FROM "outlet_transfers" WHERE id = ${transferId}::uuid FOR UPDATE`;
      const transfer = await tx.outletTransfer.findFirst({
        where: { id: transferId, businessId: user.businessId },
        include: this.transferInclude(),
      });
      if (!transfer || transfer.destinationOutletId !== outletId) {
        throw apiError(404, 'NOT_FOUND', 'Transfer not found');
      }
      if (transfer.state === TransferState.CANCELLED) {
        throw apiError(409, 'TRANSFER_CANCELLED', 'This transfer was cancelled');
      }
      if (transfer.state === TransferState.RECEIVED) {
        throw apiError(409, 'TRANSFER_ALREADY_RECEIVED', 'This transfer was already received');
      }
      if (transfer.state !== TransferState.DISPATCHED) {
        throw apiError(409, 'TRANSFER_NOT_DISPATCHED', 'Dispatch the transfer before receiving it');
      }
      const lineIds = dto.lines.map((line) => line.lineId);
      if (new Set(lineIds).size !== lineIds.length) {
        throw apiError(400, 'VALIDATION_ERROR', 'Receive lines must be distinct');
      }

      const movements: MovementResponse[] = [];
      for (const received of dto.lines) {
        const line = transfer.lines.find((candidate) => candidate.id === received.lineId);
        if (!line) {
          throw apiError(404, 'NOT_FOUND', 'Transfer line not found');
        }
        const quantity = new Prisma.Decimal(received.quantity);
        assertQuantity(quantity, 'quantity');
        assertRepresentable(quantity, line.stockItem.quantityScale, 'quantity');
        if (line.receivedQuantity.plus(quantity).greaterThan(line.dispatchedQuantity)) {
          throw apiError(
            422,
            'RECEIVE_EXCEEDS_DISPATCHED',
            'Received quantity exceeds the dispatched quantity',
          );
        }
        const updatedLine = await tx.outletTransferLine.updateMany({
          where: { id: line.id, version: line.version },
          data: {
            receivedQuantity: { increment: quantity },
            version: { increment: 1 },
          },
        });
        if (updatedLine.count !== 1) {
          throw apiError(409, 'RECEIVE_CONFLICT', 'The transfer line changed during receive');
        }
        await this.applyInboundQuantity(tx, outletId, line.stockItemId, quantity);
        const movement = await tx.stockMovement.create({
          data: {
            outletId,
            stockItemId: line.stockItemId,
            delta: quantity,
            type: StockMovementType.TRANSFER_IN,
            actorId: user.id,
            reason: `Transfer ${transfer.reference} received`,
            sourceId: transfer.id,
            transferId: transfer.id,
          },
        });
        movements.push(this.toMovement(movement, line.stockItem.quantityScale));
        await this.assertBalanceDerivable(tx, outletId, line.stockItemId);
      }

      const refreshedLines = await tx.outletTransferLine.findMany({
        where: { transferId: transfer.id },
      });
      const fullyReceived = refreshedLines.every((line) =>
        line.receivedQuantity.greaterThanOrEqualTo(line.dispatchedQuantity),
      );
      const updatedTransfer = await tx.outletTransfer.updateMany({
        where: {
          id: transfer.id,
          version: transfer.version,
          state: TransferState.DISPATCHED,
        },
        data: fullyReceived
          ? {
              state: TransferState.RECEIVED,
              receivedById: user.id,
              receivedAt: new Date(),
              version: { increment: 1 },
            }
          : { version: { increment: 1 } },
      });
      if (updatedTransfer.count !== 1) {
        throw apiError(409, 'TRANSFER_CONFLICT', 'The transfer changed during receive');
      }

      const refreshed = await tx.outletTransfer.findUniqueOrThrow({
        where: { id: transfer.id },
        include: this.transferInclude(),
      });
      return { transfer: this.toTransfer(refreshed), movements };
    });
  }

  async cancelTransfer(
    outletId: string,
    transferId: string,
    user: AuthenticatedUser,
  ): Promise<TransferResponse> {
    return this.prisma.$transaction(async (tx) => {
      await this.requireOutlet(tx, outletId, user.businessId);
      await tx.$queryRaw`SELECT id FROM "outlet_transfers" WHERE id = ${transferId}::uuid FOR UPDATE`;
      const transfer = await tx.outletTransfer.findFirst({
        where: { id: transferId, businessId: user.businessId },
        include: this.transferInclude(),
      });
      if (!transfer || transfer.sourceOutletId !== outletId) {
        throw apiError(404, 'NOT_FOUND', 'Transfer not found');
      }
      if (transfer.state === TransferState.CANCELLED) {
        throw apiError(409, 'TRANSFER_CANCELLED', 'This transfer was already cancelled');
      }
      if (transfer.state === TransferState.RECEIVED) {
        throw apiError(409, 'TRANSFER_ALREADY_RECEIVED', 'A received transfer cannot be cancelled');
      }
      if (transfer.lines.some((line) => line.receivedQuantity.greaterThan(0))) {
        throw apiError(
          409,
          'TRANSFER_PARTIALLY_RECEIVED',
          'A partially received transfer cannot be cancelled',
        );
      }

      if (transfer.state === TransferState.DISPATCHED) {
        for (const line of transfer.lines) {
          await this.applyInboundQuantity(tx, outletId, line.stockItemId, line.dispatchedQuantity);
          await tx.stockMovement.create({
            data: {
              outletId,
              stockItemId: line.stockItemId,
              delta: line.dispatchedQuantity,
              type: StockMovementType.TRANSFER_CANCEL,
              actorId: user.id,
              reason: `Transfer ${transfer.reference} cancelled`,
              sourceId: transfer.id,
              transferId: transfer.id,
            },
          });
          await this.assertBalanceDerivable(tx, outletId, line.stockItemId);
        }
      }

      const updated = await tx.outletTransfer.updateMany({
        where: { id: transfer.id, version: transfer.version, state: transfer.state },
        data: {
          state: TransferState.CANCELLED,
          cancelledById: user.id,
          cancelledAt: new Date(),
          version: { increment: 1 },
        },
      });
      if (updated.count !== 1) {
        throw apiError(409, 'TRANSFER_CONFLICT', 'The transfer changed during cancellation');
      }

      const refreshed = await tx.outletTransfer.findUniqueOrThrow({
        where: { id: transfer.id },
        include: this.transferInclude(),
      });
      return this.toTransfer(refreshed);
    });
  }

  private convertReceipt(
    line: { unitsPerSupplierUnit: Prisma.Decimal },
    quantity: string,
    unit: PurchaseOrderReceiptUnit,
    quantityScale: number,
  ): { baseDelta: Prisma.Decimal; supplierDelta: Prisma.Decimal } {
    return convertReceiptQuantity(
      line.unitsPerSupplierUnit,
      quantity,
      unit === PurchaseOrderReceiptUnit.SUPPLIER ? PurchasingUnit.SUPPLIER : PurchasingUnit.BASE,
      quantityScale,
    );
  }

  private async applyInboundQuantity(
    tx: Tx,
    outletId: string,
    stockItemId: string,
    quantity: Prisma.Decimal,
  ): Promise<void> {
    await tx.stockBalance.upsert({
      where: { outletId_stockItemId: { outletId, stockItemId } },
      create: { outletId, stockItemId, quantity, version: 1 },
      update: { quantity: { increment: quantity }, version: { increment: 1 } },
    });
  }

  private async applySignedVariance(
    tx: Tx,
    outletId: string,
    stockItemId: string,
    delta: Prisma.Decimal,
    quantityScale: number,
  ): Promise<void> {
    assertRepresentable(delta, quantityScale, 'variance');
    if (delta.greaterThan(0)) {
      await this.applyInboundQuantity(tx, outletId, stockItemId, delta);
      return;
    }
    const magnitude = delta.abs();
    const updated = await tx.stockBalance.updateMany({
      where: { outletId, stockItemId, quantity: { gte: magnitude } },
      data: { quantity: { decrement: magnitude }, version: { increment: 1 } },
    });
    if (updated.count !== 1) {
      throw apiError(422, 'INSUFFICIENT_STOCK', 'Stock count variance makes the balance negative');
    }
  }

  private async assertBalanceDerivable(
    tx: Tx,
    outletId: string,
    stockItemId: string,
  ): Promise<void> {
    const [summed, balance] = await Promise.all([
      tx.stockMovement.aggregate({
        where: { outletId, stockItemId },
        _sum: { delta: true },
      }),
      tx.stockBalance.findUnique({
        where: { outletId_stockItemId: { outletId, stockItemId } },
        select: { quantity: true },
      }),
    ]);
    const movementSum = summed._sum.delta ?? ZERO;
    if (!balance || !movementSum.equals(balance.quantity)) {
      throw apiError(500, 'BALANCE_MISMATCH', 'Stock balance does not match the movement ledger');
    }
  }

  private async requireOutlet(
    client: Tx | PrismaService,
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

  private purchaseOrderInclude() {
    return {
      supplier: { select: { id: true, name: true, reference: true } },
      lines: {
        orderBy: { createdAt: 'asc' as const },
        include: {
          stockItem: { select: { name: true, baseUnit: true, quantityScale: true } },
        },
      },
    } satisfies Prisma.PurchaseOrderInclude;
  }

  private stockCountInclude() {
    return {
      lines: {
        include: {
          stockItem: { select: { name: true, baseUnit: true, quantityScale: true } },
        },
      },
      movements: true,
    } satisfies Prisma.StockCountInclude;
  }

  private transferInclude() {
    return {
      sourceOutlet: { select: { name: true } },
      destinationOutlet: { select: { name: true } },
      lines: {
        orderBy: { createdAt: 'asc' as const },
        include: {
          stockItem: { select: { name: true, baseUnit: true, quantityScale: true } },
        },
      },
    } satisfies Prisma.OutletTransferInclude;
  }

  private toSupplier(row: {
    id: string;
    name: string;
    reference: string | null;
    contact: string | null;
    createdAt: Date;
  }): SupplierResponse {
    return {
      id: row.id,
      name: row.name,
      reference: row.reference,
      contact: row.contact,
      createdAt: row.createdAt.toISOString(),
    };
  }

  private toPurchaseOrderLine(row: {
    id: string;
    stockItemId: string;
    supplierUnit: string;
    unitsPerSupplierUnit: Prisma.Decimal;
    orderedSupplierQuantity: Prisma.Decimal;
    receivedSupplierQuantity: Prisma.Decimal;
    orderedBaseQuantity: Prisma.Decimal;
    receivedBaseQuantity: Prisma.Decimal;
    unitPrice: Prisma.Decimal;
    version: number;
    stockItem: { name: string; baseUnit: string; quantityScale: number };
  }): PurchaseOrderLineResponse {
    const scale = row.stockItem.quantityScale;
    return {
      id: row.id,
      stockItemId: row.stockItemId,
      stockItemName: row.stockItem.name,
      baseUnit: row.stockItem.baseUnit,
      quantityScale: scale,
      supplierUnit: row.supplierUnit,
      unitsPerSupplierUnit: row.unitsPerSupplierUnit.toFixed(6),
      orderedQuantity: row.orderedSupplierQuantity.toFixed(6),
      receivedQuantity: row.receivedSupplierQuantity.toFixed(6),
      remainingQuantity: row.orderedSupplierQuantity.minus(row.receivedSupplierQuantity).toFixed(6),
      orderedBaseQuantity: row.orderedBaseQuantity.toFixed(scale),
      receivedBaseQuantity: row.receivedBaseQuantity.toFixed(scale),
      remainingBaseQuantity: row.orderedBaseQuantity.minus(row.receivedBaseQuantity).toFixed(scale),
      unitPrice: row.unitPrice.toFixed(6),
      version: row.version,
    };
  }

  private toPurchaseOrder(row: {
    id: string;
    outletId: string;
    supplierId: string;
    reference: string;
    state: PurchaseOrderState;
    createdAt: Date;
    closedAt: Date | null;
    supplier: { name: string; reference: string | null };
    lines: Parameters<PurchasingService['toPurchaseOrderLine']>[0][];
  }): PurchaseOrderResponse {
    return {
      id: row.id,
      outletId: row.outletId,
      supplierId: row.supplierId,
      supplierName: row.supplier.name,
      supplierReference: row.supplier.reference,
      reference: row.reference,
      state: row.state,
      createdAt: row.createdAt.toISOString(),
      closedAt: row.closedAt?.toISOString() ?? null,
      lines: row.lines.map((line) => this.toPurchaseOrderLine(line)),
    };
  }

  private toStockCount(row: {
    id: string;
    outletId: string;
    reference: string;
    reason: string;
    actorId: string;
    createdAt: Date;
    lines: {
      stockItemId: string;
      systemQuantity: Prisma.Decimal;
      countedQuantity: Prisma.Decimal;
      variance: Prisma.Decimal;
      stockItem: { name: string; baseUnit: string; quantityScale: number };
    }[];
    movements: {
      id: string;
      outletId: string;
      stockItemId: string;
      delta: Prisma.Decimal;
      type: StockMovementType;
      reason: string;
      sourceId: string;
      actorId: string;
      supplierId: string | null;
      purchaseOrderId: string | null;
      transferId: string | null;
      stockCountId: string | null;
      stockWasteId: string | null;
      createdAt: Date;
    }[];
  }): StockCountResponse {
    const scales = new Map(
      row.lines.map((line) => [line.stockItemId, line.stockItem.quantityScale]),
    );
    return {
      id: row.id,
      outletId: row.outletId,
      reference: row.reference,
      reason: row.reason,
      actorId: row.actorId,
      createdAt: row.createdAt.toISOString(),
      lines: row.lines.map((line) => ({
        stockItemId: line.stockItemId,
        stockItemName: line.stockItem.name,
        baseUnit: line.stockItem.baseUnit,
        quantityScale: line.stockItem.quantityScale,
        systemQuantity: line.systemQuantity.toFixed(line.stockItem.quantityScale),
        countedQuantity: line.countedQuantity.toFixed(line.stockItem.quantityScale),
        variance: line.variance.toFixed(line.stockItem.quantityScale),
      })),
      movements: row.movements.map((movement) =>
        this.toMovement(movement, scales.get(movement.stockItemId) ?? 0),
      ),
    };
  }

  private toTransfer(row: {
    id: string;
    sourceOutletId: string;
    destinationOutletId: string;
    reference: string;
    note: string | null;
    state: TransferState;
    version: number;
    createdAt: Date;
    dispatchedAt: Date | null;
    receivedAt: Date | null;
    cancelledAt: Date | null;
    sourceOutlet: { name: string };
    destinationOutlet: { name: string };
    lines: {
      id: string;
      stockItemId: string;
      dispatchedQuantity: Prisma.Decimal;
      receivedQuantity: Prisma.Decimal;
      stockItem: { name: string; baseUnit: string; quantityScale: number };
    }[];
  }): TransferResponse {
    const inTransit = transferInTransitQuantity(row.lines);
    const lines = row.lines.map((line) => {
      const inTransitQuantity = line.dispatchedQuantity.minus(line.receivedQuantity);
      return {
        id: line.id,
        stockItemId: line.stockItemId,
        stockItemName: line.stockItem.name,
        baseUnit: line.stockItem.baseUnit,
        quantityScale: line.stockItem.quantityScale,
        dispatchedQuantity: line.dispatchedQuantity.toFixed(line.stockItem.quantityScale),
        receivedQuantity: line.receivedQuantity.toFixed(line.stockItem.quantityScale),
        inTransitQuantity: inTransitQuantity.toFixed(line.stockItem.quantityScale),
      };
    });
    return {
      id: row.id,
      sourceOutletId: row.sourceOutletId,
      sourceOutletName: row.sourceOutlet.name,
      destinationOutletId: row.destinationOutletId,
      destinationOutletName: row.destinationOutlet.name,
      reference: row.reference,
      note: row.note,
      state: row.state,
      version: row.version,
      createdAt: row.createdAt.toISOString(),
      dispatchedAt: row.dispatchedAt?.toISOString() ?? null,
      receivedAt: row.receivedAt?.toISOString() ?? null,
      cancelledAt: row.cancelledAt?.toISOString() ?? null,
      inTransitQuantity: inTransit.toString(),
      lines,
    };
  }

  private toMovement(
    movement: {
      id: string;
      outletId: string;
      stockItemId: string;
      delta: Prisma.Decimal;
      type: StockMovementType;
      reason: string;
      sourceId: string;
      supplierId?: string | null;
      purchaseOrderId?: string | null;
      transferId?: string | null;
      stockCountId?: string | null;
      stockWasteId?: string | null;
      actorId: string;
      createdAt: Date;
    },
    quantityScale: number,
  ): MovementResponse {
    return {
      id: movement.id,
      outletId: movement.outletId,
      stockItemId: movement.stockItemId,
      delta: movement.delta.toFixed(quantityScale),
      type: movement.type,
      reason: movement.reason,
      sourceId: movement.sourceId,
      sourceReference: null,
      supplierId: movement.supplierId ?? null,
      supplierName: null,
      supplierReference: null,
      purchaseOrderId: movement.purchaseOrderId ?? null,
      purchaseOrderReference: null,
      transferId: movement.transferId ?? null,
      transferReference: null,
      stockCountId: movement.stockCountId ?? null,
      stockCountReference: null,
      stockWasteId: movement.stockWasteId ?? null,
      actorId: movement.actorId,
      createdAt: movement.createdAt.toISOString(),
    };
  }
}
