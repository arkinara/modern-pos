import assert from 'node:assert/strict';
import { test } from 'node:test';
import { HttpException, type ExecutionContext } from '@nestjs/common';
import {
  Prisma,
  PurchaseOrderState,
  Role,
  StockMovementType,
  TransferState,
  WasteReason,
} from '@prisma/client';
import { plainToInstance } from 'class-transformer';
import { validate } from 'class-validator';
import { Reflector } from '@nestjs/core';
import type { AuthenticatedUser } from '../auth/auth.types';
import { PERMISSIONS, permissionsForRole } from '../auth/permissions';
import { PermissionsGuard } from '../common/guards/permissions.guard';
import { PERMISSIONS_KEY } from '../common/decorators/permissions.decorator';
import type { PrismaService } from '../prisma/prisma.service';
import { PurchasingController } from './purchasing.controller';
import {
  PurchaseOrderReceiptUnit,
  StockCountCreateDto,
  TransferReceiveDto,
} from './dto/purchasing.dto';
import { PurchasingService } from './purchasing.service';

const BUSINESS_ID = '00000000-0000-4000-8000-000000000001';
const OUTLET_ID = '00000000-0000-4000-8000-000000000002';
const OWNER_ID = '00000000-0000-4000-8000-000000000003';
const CASHIER_ID = '00000000-0000-4000-8000-000000000004';
const DESTINATION_OUTLET_ID = '00000000-0000-4000-8000-000000000005';
const SUPPLIER_ID = '00000000-0000-4000-8000-000000000006';
const ITEM_ID = '00000000-0000-4000-8000-000000000050';

const ZERO = new Prisma.Decimal(0);

interface OutletRow {
  id: string;
  businessId: string;
  name: string;
}

interface SupplierRow {
  id: string;
  businessId: string;
  name: string;
  reference: string | null;
  contact: string | null;
  archivedAt: Date | null;
  createdAt: Date;
}

interface StockItemRow {
  id: string;
  businessId: string;
  name: string;
  baseUnit: string;
  quantityScale: number;
}

interface BalanceRow {
  id: string;
  outletId: string;
  stockItemId: string;
  quantity: Prisma.Decimal;
  version: number;
}

interface MovementRow {
  id: string;
  outletId: string;
  stockItemId: string;
  delta: Prisma.Decimal;
  type: StockMovementType;
  actorId: string;
  reason: string;
  sourceId: string;
  supplierId: string | null;
  purchaseOrderId: string | null;
  transferId: string | null;
  stockCountId: string | null;
  stockWasteId: string | null;
  createdAt: Date;
}

interface PurchaseOrderRow {
  id: string;
  businessId: string;
  outletId: string;
  supplierId: string;
  reference: string;
  state: PurchaseOrderState;
  createdById: string;
  createdAt: Date;
  closedAt: Date | null;
}

interface PurchaseOrderLineRow {
  id: string;
  purchaseOrderId: string;
  stockItemId: string;
  supplierUnit: string;
  unitsPerSupplierUnit: Prisma.Decimal;
  orderedSupplierQuantity: Prisma.Decimal;
  receivedSupplierQuantity: Prisma.Decimal;
  orderedBaseQuantity: Prisma.Decimal;
  receivedBaseQuantity: Prisma.Decimal;
  unitPrice: Prisma.Decimal;
  version: number;
  createdAt: Date;
}

interface StockCountRow {
  id: string;
  businessId: string;
  outletId: string;
  reference: string;
  reason: string;
  actorId: string;
  createdAt: Date;
}

interface StockCountLineRow {
  id: string;
  stockCountId: string;
  stockItemId: string;
  systemQuantity: Prisma.Decimal;
  countedQuantity: Prisma.Decimal;
  variance: Prisma.Decimal;
}

interface StockWasteRow {
  id: string;
  businessId: string;
  outletId: string;
  stockItemId: string;
  quantity: Prisma.Decimal;
  reason: WasteReason;
  note: string | null;
  actorId: string;
  createdAt: Date;
}

interface TransferRow {
  id: string;
  businessId: string;
  sourceOutletId: string;
  destinationOutletId: string;
  reference: string;
  note: string | null;
  state: TransferState;
  createdById: string;
  dispatchedById: string | null;
  receivedById: string | null;
  cancelledById: string | null;
  version: number;
  createdAt: Date;
  dispatchedAt: Date | null;
  receivedAt: Date | null;
  cancelledAt: Date | null;
}

interface TransferLineRow {
  id: string;
  transferId: string;
  stockItemId: string;
  dispatchedQuantity: Prisma.Decimal;
  receivedQuantity: Prisma.Decimal;
  version: number;
  createdAt: Date;
}

interface FakeState {
  outlets: OutletRow[];
  suppliers: SupplierRow[];
  items: StockItemRow[];
  balances: BalanceRow[];
  movements: MovementRow[];
  purchaseOrders: PurchaseOrderRow[];
  purchaseOrderLines: PurchaseOrderLineRow[];
  stockCounts: StockCountRow[];
  stockCountLines: StockCountLineRow[];
  stockWastes: StockWasteRow[];
  transfers: TransferRow[];
  transferLines: TransferLineRow[];
}

type Undo = () => void;

function owner(): AuthenticatedUser {
  return {
    id: OWNER_ID,
    businessId: BUSINESS_ID,
    email: 'owner@example.test',
    role: Role.OWNER,
    outletId: OUTLET_ID,
    outletIds: [OUTLET_ID, DESTINATION_OUTLET_ID],
    sessionId: 'session-owner',
  };
}

function cashier(): AuthenticatedUser {
  return {
    id: CASHIER_ID,
    businessId: BUSINESS_ID,
    email: 'cashier@example.test',
    role: Role.CASHIER,
    outletId: OUTLET_ID,
    outletIds: [OUTLET_ID],
    sessionId: 'session-cashier',
  };
}

function status(error: unknown): number | null {
  return error instanceof HttpException ? error.getStatus() : null;
}

function code(error: unknown): string | null {
  return error instanceof HttpException
    ? ((error.getResponse() as { code?: string }).code ?? null)
    : null;
}

function addBalance(
  state: FakeState,
  outletId: string,
  quantity: string,
  itemId = ITEM_ID,
): BalanceRow {
  const row: BalanceRow = {
    id: `balance-${state.balances.length + 1}`,
    outletId,
    stockItemId: itemId,
    quantity: new Prisma.Decimal(quantity),
    version: 1,
  };
  state.balances.push(row);
  state.movements.push({
    id: `opening-${state.movements.length + 1}`,
    outletId,
    stockItemId: itemId,
    delta: new Prisma.Decimal(quantity),
    type: StockMovementType.OPENING,
    actorId: OWNER_ID,
    reason: 'Opening balance',
    sourceId: row.id,
    supplierId: null,
    purchaseOrderId: null,
    transferId: null,
    stockCountId: null,
    stockWasteId: null,
    createdAt: new Date('2026-01-01T00:00:00Z'),
  });
  return row;
}

function balanceFor(state: FakeState, outletId: string, itemId = ITEM_ID): BalanceRow | undefined {
  return state.balances.find((row) => row.outletId === outletId && row.stockItemId === itemId);
}

function movementTotal(
  state: FakeState,
  outletId: string,
  type?: StockMovementType,
  itemId = ITEM_ID,
): Prisma.Decimal {
  return state.movements
    .filter(
      (row) =>
        row.outletId === outletId &&
        row.stockItemId === itemId &&
        (type === undefined || row.type === type),
    )
    .reduce((total, row) => total.plus(row.delta), ZERO);
}

function fakePrisma(): { prisma: PrismaService; state: FakeState } {
  const state: FakeState = {
    outlets: [
      { id: OUTLET_ID, businessId: BUSINESS_ID, name: 'Main Outlet' },
      { id: DESTINATION_OUTLET_ID, businessId: BUSINESS_ID, name: 'Second Outlet' },
    ],
    suppliers: [
      {
        id: SUPPLIER_ID,
        businessId: BUSINESS_ID,
        name: 'Bean Supplier',
        reference: 'SUP-1',
        contact: null,
        archivedAt: null,
        createdAt: new Date('2026-01-01T00:00:00Z'),
      },
    ],
    items: [
      {
        id: ITEM_ID,
        businessId: BUSINESS_ID,
        name: 'Coffee Beans',
        baseUnit: 'g',
        quantityScale: 0,
      },
    ],
    balances: [],
    movements: [],
    purchaseOrders: [],
    purchaseOrderLines: [],
    stockCounts: [],
    stockCountLines: [],
    stockWastes: [],
    transfers: [],
    transferLines: [],
  };

  let sequence = 0;
  const nextId = (): string => {
    sequence += 1;
    return `00000000-0000-4000-8000-${String(sequence).padStart(12, '0')}`;
  };
  const now = (): Date => new Date('2026-02-01T00:00:00Z');

  const itemFor = (stockItemId: string): StockItemRow => {
    const item = state.items.find((row) => row.id === stockItemId);
    if (!item) {
      throw new Error(`missing stock item ${stockItemId}`);
    }
    return { ...item };
  };

  const supplierFor = (supplierId: string): SupplierRow => {
    const supplier = state.suppliers.find((row) => row.id === supplierId);
    if (!supplier) {
      throw new Error(`missing supplier ${supplierId}`);
    }
    return { ...supplier };
  };

  const outletFor = (outletId: string): OutletRow => {
    const outlet = state.outlets.find((row) => row.id === outletId);
    if (!outlet) {
      throw new Error(`missing outlet ${outletId}`);
    }
    return { ...outlet };
  };

  const materializeOrder = (order: PurchaseOrderRow): any => ({
    ...order,
    supplier: supplierFor(order.supplierId),
    lines: state.purchaseOrderLines
      .filter((line) => line.purchaseOrderId === order.id)
      .sort((a, b) => a.createdAt.getTime() - b.createdAt.getTime() || a.id.localeCompare(b.id))
      .map((line) => ({ ...line, stockItem: itemFor(line.stockItemId) })),
  });

  const materializeTransfer = (transfer: TransferRow): any => ({
    ...transfer,
    sourceOutlet: { name: outletFor(transfer.sourceOutletId).name },
    destinationOutlet: { name: outletFor(transfer.destinationOutletId).name },
    lines: state.transferLines
      .filter((line) => line.transferId === transfer.id)
      .sort((a, b) => a.createdAt.getTime() - b.createdAt.getTime() || a.id.localeCompare(b.id))
      .map((line) => ({ ...line, stockItem: itemFor(line.stockItemId) })),
  });

  const makeClient = (undo: Undo[]): any => {
    const client: any = {
      $queryRaw: (..._args: unknown[]) => Promise.resolve([]),
      outlet: {
        findFirst: async (args: any) =>
          state.outlets.find(
            (row) => row.id === args.where.id && row.businessId === args.where.businessId,
          ) ?? null,
      },
      supplier: {
        findFirst: async (args: any) =>
          state.suppliers.find(
            (row) =>
              row.id === args.where.id &&
              row.businessId === args.where.businessId &&
              (args.where.archivedAt === undefined || row.archivedAt === args.where.archivedAt),
          ) ?? null,
      },
      stockItem: {
        findMany: async (args: any) =>
          state.items.filter(
            (row) => row.businessId === args.where.businessId && args.where.id.in.includes(row.id),
          ),
        findFirst: async (args: any) =>
          state.items.find(
            (row) => row.id === args.where.id && row.businessId === args.where.businessId,
          ) ?? null,
      },
      stockBalance: {
        findMany: async (args: any) =>
          state.balances
            .filter(
              (row) =>
                row.outletId === args.where.outletId &&
                args.where.stockItemId.in.includes(row.stockItemId),
            )
            .map((row) => ({ stockItemId: row.stockItemId, quantity: row.quantity })),
        findUnique: async (args: any) => {
          const lookup = args.where.outletId_stockItemId;
          const row = balanceFor(state, lookup.outletId, lookup.stockItemId);
          return row ? { quantity: row.quantity } : null;
        },
        upsert: async (args: any) => {
          const lookup = args.where.outletId_stockItemId;
          const existing = balanceFor(state, lookup.outletId, lookup.stockItemId);
          if (existing) {
            const old = { ...existing };
            existing.quantity = existing.quantity.plus(args.update.quantity.increment);
            existing.version += args.update.version.increment;
            undo.push(() => Object.assign(existing, old));
            return { ...existing };
          }
          const created: BalanceRow = {
            id: nextId(),
            outletId: args.create.outletId,
            stockItemId: args.create.stockItemId,
            quantity: new Prisma.Decimal(args.create.quantity),
            version: args.create.version,
          };
          state.balances.push(created);
          undo.push(() => {
            const index = state.balances.indexOf(created);
            if (index >= 0) {
              state.balances.splice(index, 1);
            }
          });
          return { ...created };
        },
        updateMany: async (args: any) => {
          const row = state.balances.find(
            (candidate) =>
              candidate.outletId === args.where.outletId &&
              candidate.stockItemId === args.where.stockItemId,
          );
          if (!row) {
            return { count: 0 };
          }
          if (args.where.quantity?.gte && row.quantity.lessThan(args.where.quantity.gte)) {
            return { count: 0 };
          }
          const old = { ...row };
          const change = args.data.quantity;
          if (change && 'decrement' in change) {
            row.quantity = row.quantity.minus(change.decrement);
          } else if (change && 'increment' in change) {
            row.quantity = row.quantity.plus(change.increment);
          }
          row.version += args.data.version.increment;
          undo.push(() => Object.assign(row, old));
          return { count: 1 };
        },
      },
      stockMovement: {
        create: async (args: any) => {
          const row: MovementRow = {
            id: nextId(),
            outletId: args.data.outletId,
            stockItemId: args.data.stockItemId,
            delta: new Prisma.Decimal(args.data.delta),
            type: args.data.type,
            actorId: args.data.actorId,
            reason: args.data.reason,
            sourceId: args.data.sourceId,
            supplierId: args.data.supplierId ?? null,
            purchaseOrderId: args.data.purchaseOrderId ?? null,
            transferId: args.data.transferId ?? null,
            stockCountId: args.data.stockCountId ?? null,
            stockWasteId: args.data.stockWasteId ?? null,
            createdAt: now(),
          };
          state.movements.push(row);
          undo.push(() => {
            const index = state.movements.indexOf(row);
            if (index >= 0) {
              state.movements.splice(index, 1);
            }
          });
          return { ...row };
        },
        aggregate: async (args: any) => {
          const rows = state.movements.filter(
            (row) =>
              row.outletId === args.where.outletId && row.stockItemId === args.where.stockItemId,
          );
          return {
            _sum: {
              delta:
                rows.length === 0 ? null : rows.reduce((total, row) => total.plus(row.delta), ZERO),
            },
          };
        },
      },
      purchaseOrder: {
        create: async (args: any) => {
          const order: PurchaseOrderRow = {
            id: nextId(),
            businessId: args.data.businessId,
            outletId: args.data.outletId,
            supplierId: args.data.supplierId,
            reference: args.data.reference,
            state: PurchaseOrderState.OPEN,
            createdById: args.data.createdById,
            createdAt: now(),
            closedAt: null,
          };
          state.purchaseOrders.push(order);
          undo.push(() => {
            const index = state.purchaseOrders.indexOf(order);
            if (index >= 0) {
              state.purchaseOrders.splice(index, 1);
            }
          });
          for (const line of args.data.lines.create) {
            const row: PurchaseOrderLineRow = {
              id: nextId(),
              purchaseOrderId: order.id,
              stockItemId: line.stockItemId,
              supplierUnit: line.supplierUnit,
              unitsPerSupplierUnit: new Prisma.Decimal(line.unitsPerSupplierUnit),
              orderedSupplierQuantity: new Prisma.Decimal(line.orderedSupplierQuantity),
              receivedSupplierQuantity: ZERO,
              orderedBaseQuantity: new Prisma.Decimal(line.orderedBaseQuantity),
              receivedBaseQuantity: ZERO,
              unitPrice: new Prisma.Decimal(line.unitPrice),
              version: 1,
              createdAt: now(),
            };
            state.purchaseOrderLines.push(row);
            undo.push(() => {
              const index = state.purchaseOrderLines.indexOf(row);
              if (index >= 0) {
                state.purchaseOrderLines.splice(index, 1);
              }
            });
          }
          return materializeOrder(order);
        },
        findFirst: async (args: any) => {
          const order = state.purchaseOrders.find(
            (row) =>
              row.id === args.where.id &&
              row.businessId === args.where.businessId &&
              row.outletId === args.where.outletId,
          );
          return order ? materializeOrder(order) : null;
        },
        findUniqueOrThrow: async (args: any) => {
          const order = state.purchaseOrders.find((row) => row.id === args.where.id);
          if (!order) {
            throw new Error('purchase order not found');
          }
          return materializeOrder(order);
        },
        update: async (args: any) => {
          const order = state.purchaseOrders.find((row) => row.id === args.where.id);
          if (!order) {
            throw new Error('purchase order not found');
          }
          const old = { ...order };
          Object.assign(order, args.data);
          undo.push(() => Object.assign(order, old));
          return materializeOrder(order);
        },
      },
      purchaseOrderLine: {
        updateMany: async (args: any) => {
          const line = state.purchaseOrderLines.find(
            (row) => row.id === args.where.id && row.version === args.where.version,
          );
          if (!line) {
            return { count: 0 };
          }
          const old = { ...line };
          line.receivedBaseQuantity = line.receivedBaseQuantity.plus(
            args.data.receivedBaseQuantity.increment,
          );
          line.receivedSupplierQuantity = line.receivedSupplierQuantity.plus(
            args.data.receivedSupplierQuantity.increment,
          );
          line.version += args.data.version.increment;
          undo.push(() => Object.assign(line, old));
          return { count: 1 };
        },
        findMany: async (args: any) =>
          state.purchaseOrderLines
            .filter((row) => row.purchaseOrderId === args.where.purchaseOrderId)
            .map((row) => ({ ...row })),
      },
      stockCount: {
        create: async (args: any) => {
          const count: StockCountRow = {
            id: nextId(),
            businessId: args.data.businessId,
            outletId: args.data.outletId,
            reference: args.data.reference,
            reason: args.data.reason,
            actorId: args.data.actorId,
            createdAt: now(),
          };
          state.stockCounts.push(count);
          undo.push(() => {
            const index = state.stockCounts.indexOf(count);
            if (index >= 0) {
              state.stockCounts.splice(index, 1);
            }
          });
          for (const line of args.data.lines.create) {
            const row: StockCountLineRow = {
              id: nextId(),
              stockCountId: count.id,
              stockItemId: line.stockItemId,
              systemQuantity: new Prisma.Decimal(line.systemQuantity),
              countedQuantity: new Prisma.Decimal(line.countedQuantity),
              variance: new Prisma.Decimal(line.variance),
            };
            state.stockCountLines.push(row);
            undo.push(() => {
              const index = state.stockCountLines.indexOf(row);
              if (index >= 0) {
                state.stockCountLines.splice(index, 1);
              }
            });
          }
          return { ...count };
        },
      },
      stockWaste: {
        create: async (args: any) => {
          const row: StockWasteRow = {
            id: nextId(),
            businessId: args.data.businessId,
            outletId: args.data.outletId,
            stockItemId: args.data.stockItemId,
            quantity: new Prisma.Decimal(args.data.quantity),
            reason: args.data.reason,
            note: args.data.note,
            actorId: args.data.actorId,
            createdAt: now(),
          };
          state.stockWastes.push(row);
          undo.push(() => {
            const index = state.stockWastes.indexOf(row);
            if (index >= 0) {
              state.stockWastes.splice(index, 1);
            }
          });
          return { ...row };
        },
      },
      outletTransfer: {
        create: async (args: any) => {
          const transfer: TransferRow = {
            id: nextId(),
            businessId: args.data.businessId,
            sourceOutletId: args.data.sourceOutletId,
            destinationOutletId: args.data.destinationOutletId,
            reference: args.data.reference,
            note: args.data.note,
            state: TransferState.DRAFT,
            createdById: args.data.createdById,
            dispatchedById: null,
            receivedById: null,
            cancelledById: null,
            version: 1,
            createdAt: now(),
            dispatchedAt: null,
            receivedAt: null,
            cancelledAt: null,
          };
          state.transfers.push(transfer);
          undo.push(() => {
            const index = state.transfers.indexOf(transfer);
            if (index >= 0) {
              state.transfers.splice(index, 1);
            }
          });
          for (const line of args.data.lines.create) {
            const row: TransferLineRow = {
              id: nextId(),
              transferId: transfer.id,
              stockItemId: line.stockItemId,
              dispatchedQuantity: new Prisma.Decimal(line.dispatchedQuantity),
              receivedQuantity: ZERO,
              version: 1,
              createdAt: now(),
            };
            state.transferLines.push(row);
            undo.push(() => {
              const index = state.transferLines.indexOf(row);
              if (index >= 0) {
                state.transferLines.splice(index, 1);
              }
            });
          }
          return materializeTransfer(transfer);
        },
        findFirst: async (args: any) => {
          const transfer = state.transfers.find(
            (row) => row.id === args.where.id && row.businessId === args.where.businessId,
          );
          return transfer ? materializeTransfer(transfer) : null;
        },
        findUniqueOrThrow: async (args: any) => {
          const transfer = state.transfers.find((row) => row.id === args.where.id);
          if (!transfer) {
            throw new Error('transfer not found');
          }
          return materializeTransfer(transfer);
        },
        updateMany: async (args: any) => {
          const transfer = state.transfers.find(
            (row) =>
              row.id === args.where.id &&
              row.version === args.where.version &&
              (args.where.state === undefined || row.state === args.where.state),
          );
          if (!transfer) {
            return { count: 0 };
          }
          const old = { ...transfer };
          const { version, ...fields } = args.data;
          Object.assign(transfer, fields);
          transfer.version += version.increment;
          undo.push(() => Object.assign(transfer, old));
          return { count: 1 };
        },
      },
      outletTransferLine: {
        updateMany: async (args: any) => {
          const line = state.transferLines.find(
            (row) => row.id === args.where.id && row.version === args.where.version,
          );
          if (!line) {
            return { count: 0 };
          }
          const old = { ...line };
          line.receivedQuantity = line.receivedQuantity.plus(args.data.receivedQuantity.increment);
          line.version += args.data.version.increment;
          undo.push(() => Object.assign(line, old));
          return { count: 1 };
        },
        findMany: async (args: any) =>
          state.transferLines
            .filter((row) => row.transferId === args.where.transferId)
            .map((row) => ({ ...row })),
      },
    };

    client.$transaction = async <T>(callback: (tx: unknown) => Promise<T>): Promise<T> => {
      const transactionUndo: Undo[] = [];
      const tx = makeClient(transactionUndo);
      try {
        return await callback(tx);
      } catch (error) {
        for (const rollback of transactionUndo.reverse()) {
          rollback();
        }
        throw error;
      }
    };

    return client;
  };

  return { prisma: makeClient([]) as PrismaService, state };
}

function purchaseOrderLineDto(overrides: Record<string, unknown> = {}): any {
  return {
    stockItemId: ITEM_ID,
    supplierUnit: 'case',
    unitsPerSupplierUnit: '1',
    orderedQuantity: '10',
    unitPrice: '100',
    ...overrides,
  };
}

function receiptDto(
  lineId: string,
  quantity: string,
  unit = PurchaseOrderReceiptUnit.SUPPLIER,
): any {
  return { lineId, quantity, unit };
}

async function createOrder(
  service: PurchasingService,
  overrides: Record<string, unknown> = {},
): Promise<any> {
  return service.createPurchaseOrder(
    OUTLET_ID,
    { supplierId: SUPPLIER_ID, lines: [purchaseOrderLineDto(overrides)] } as any,
    owner(),
  );
}

async function createTransfer(service: PurchasingService, quantity: string): Promise<any> {
  return service.createTransfer(
    OUTLET_ID,
    {
      destinationOutletId: DESTINATION_OUTLET_ID,
      lines: [{ stockItemId: ITEM_ID, quantity }],
    } as any,
    owner(),
  );
}

test('partial purchase receipts accumulate, close the order and keep one ledger row each', async () => {
  const { prisma, state } = fakePrisma();
  const service = new PurchasingService(prisma);
  const order = await createOrder(service);
  const lineId = order.lines[0].id;

  await service.receivePurchaseOrder(OUTLET_ID, order.id, receiptDto(lineId, '4'), owner());
  const second = await service.receivePurchaseOrder(
    OUTLET_ID,
    order.id,
    receiptDto(lineId, '4'),
    owner(),
  );
  assert.equal(second.purchaseOrder.state, PurchaseOrderState.PARTIALLY_RECEIVED);

  const final = await service.receivePurchaseOrder(
    OUTLET_ID,
    order.id,
    receiptDto(lineId, '2'),
    owner(),
  );

  assert.equal(final.purchaseOrder.state, PurchaseOrderState.RECEIVED);
  assert.ok(final.purchaseOrder.closedAt);
  assert.equal(final.line.receivedBaseQuantity, '10');
  assert.equal(state.movements.filter((row) => row.type === StockMovementType.RECEIPT).length, 3);
  assert.equal(balanceFor(state, OUTLET_ID)?.quantity.toFixed(0), '10');
  assert.equal(movementTotal(state, OUTLET_ID).toFixed(0), '10');
});

test('supplier units convert into base units end to end in the receipt ledger', async () => {
  const { prisma, state } = fakePrisma();
  const service = new PurchasingService(prisma);
  const order = await createOrder(service, {
    unitsPerSupplierUnit: '250',
    orderedQuantity: '10',
  });

  const receipt = await service.receivePurchaseOrder(
    OUTLET_ID,
    order.id,
    receiptDto(order.lines[0].id, '4', PurchaseOrderReceiptUnit.SUPPLIER),
    owner(),
  );

  const movement = state.movements.find((row) => row.type === StockMovementType.RECEIPT);
  assert.ok(movement);
  assert.equal(movement.delta.toFixed(0), '1000');
  assert.equal(receipt.line.receivedBaseQuantity, '1000');
  assert.equal(receipt.line.receivedQuantity, '4.000000');
  assert.equal(balanceFor(state, OUTLET_ID)?.quantity.toFixed(0), '1000');
});

test('over-receipt is rejected with OVER_RECEIPT and leaves the balance and ledger unchanged', async () => {
  const { prisma, state } = fakePrisma();
  const service = new PurchasingService(prisma);
  const order = await createOrder(service);
  const lineId = order.lines[0].id;

  await service.receivePurchaseOrder(OUTLET_ID, order.id, receiptDto(lineId, '9'), owner());

  await assert.rejects(
    () => service.receivePurchaseOrder(OUTLET_ID, order.id, receiptDto(lineId, '2'), owner()),
    (error: unknown) => status(error) === 422 && code(error) === 'OVER_RECEIPT',
  );

  assert.equal(balanceFor(state, OUTLET_ID)?.quantity.toFixed(0), '9');
  assert.equal(state.movements.filter((row) => row.type === StockMovementType.RECEIPT).length, 1);
});

test('receipt against a cancelled purchase order returns PURCHASE_ORDER_CANCELLED without a ledger row', async () => {
  const { prisma, state } = fakePrisma();
  const service = new PurchasingService(prisma);
  const order = await createOrder(service);

  await service.cancelPurchaseOrder(OUTLET_ID, order.id, owner());

  await assert.rejects(
    () =>
      service.receivePurchaseOrder(
        OUTLET_ID,
        order.id,
        receiptDto(order.lines[0].id, '1'),
        owner(),
      ),
    (error: unknown) => status(error) === 409 && code(error) === 'PURCHASE_ORDER_CANCELLED',
  );

  assert.equal(state.movements.length, 0);
  assert.equal(state.balances.length, 0);
});

test('receipt against a fully received purchase order is rejected without a second ledger row', async () => {
  const { prisma, state } = fakePrisma();
  const service = new PurchasingService(prisma);
  const order = await createOrder(service);
  const lineId = order.lines[0].id;

  await service.receivePurchaseOrder(OUTLET_ID, order.id, receiptDto(lineId, '10'), owner());

  await assert.rejects(
    () => service.receivePurchaseOrder(OUTLET_ID, order.id, receiptDto(lineId, '1'), owner()),
    (error: unknown) => status(error) === 409 && code(error) === 'PURCHASE_ORDER_CLOSED',
  );

  assert.equal(state.movements.filter((row) => row.type === StockMovementType.RECEIPT).length, 1);
  assert.equal(balanceFor(state, OUTLET_ID)?.quantity.toFixed(0), '10');
});

test('concurrent receipts on the same line: one wins and the stale writer gets RECEIPT_CONFLICT', async () => {
  const { prisma, state } = fakePrisma();
  const service = new PurchasingService(prisma);
  const order = await createOrder(service);
  const lineId = order.lines[0].id;

  const results = await Promise.allSettled([
    service.receivePurchaseOrder(OUTLET_ID, order.id, receiptDto(lineId, '5'), owner()),
    service.receivePurchaseOrder(OUTLET_ID, order.id, receiptDto(lineId, '5'), owner()),
  ]);

  const fulfilled = results.filter((result) => result.status === 'fulfilled');
  const rejected = results.filter((result) => result.status === 'rejected');
  assert.equal(fulfilled.length, 1);
  assert.equal(rejected.length, 1);
  const failure = rejected[0] as PromiseRejectedResult;
  assert.equal(status(failure.reason), 409);
  assert.equal(code(failure.reason), 'RECEIPT_CONFLICT');

  assert.equal(state.movements.filter((row) => row.type === StockMovementType.RECEIPT).length, 1);
  assert.equal(balanceFor(state, OUTLET_ID)?.quantity.toFixed(0), '5');
  assert.equal(state.purchaseOrderLines[0].version, 2);
  assert.equal(state.purchaseOrderLines[0].receivedBaseQuantity.toFixed(0), '5');
});

test('stock count variance posts a COUNT row with reason and actor and adjusts the balance', async () => {
  const { prisma, state } = fakePrisma();
  addBalance(state, OUTLET_ID, '10');
  const service = new PurchasingService(prisma);

  const count = await service.createStockCount(
    OUTLET_ID,
    {
      reason: 'Weekly count',
      lines: [{ stockItemId: ITEM_ID, countedQuantity: '7' }],
    } as any,
    owner(),
  );

  const movement = state.movements.find((row) => row.type === StockMovementType.COUNT);
  assert.ok(movement);
  assert.equal(movement.delta.toFixed(0), '-3');
  assert.equal(movement.reason, 'Weekly count');
  assert.equal(movement.actorId, OWNER_ID);
  assert.equal(movement.stockCountId, count.id);
  assert.equal(balanceFor(state, OUTLET_ID)?.quantity.toFixed(0), '7');
  assert.equal(count.reason, 'Weekly count');
  assert.equal(count.actorId, OWNER_ID);
  assert.equal(count.lines[0].variance, '-3');
  assert.equal(count.movements.length, 1);
  assert.equal(state.stockCountLines[0].variance.toFixed(0), '-3');
});

test('stock count without a reason fails DTO validation with a 400 field error', async () => {
  const errors = await validate(
    plainToInstance(StockCountCreateDto, {
      lines: [{ stockItemId: ITEM_ID, countedQuantity: '7' }],
    }),
  );

  assert.ok(errors.some((error) => error.property === 'reason'));
  const emptyReason = await validate(
    plainToInstance(StockCountCreateDto, {
      reason: '',
      lines: [{ stockItemId: ITEM_ID, countedQuantity: '7' }],
    }),
  );
  assert.ok(emptyReason.some((error) => error.property === 'reason'));
});

test('waste posts a WASTE row with reason and actor, reduces the balance and keeps quantity positive', async () => {
  const { prisma, state } = fakePrisma();
  addBalance(state, OUTLET_ID, '10');
  const service = new PurchasingService(prisma);

  const waste = await service.recordWaste(
    OUTLET_ID,
    {
      stockItemId: ITEM_ID,
      quantity: '3',
      reason: WasteReason.SPOILAGE,
      note: 'Milk left out',
    } as any,
    owner(),
  );

  const movement = state.movements.find((row) => row.type === StockMovementType.WASTE);
  assert.ok(movement);
  assert.equal(movement.delta.toFixed(0), '-3');
  assert.equal(movement.reason, 'SPOILAGE: Milk left out');
  assert.equal(movement.actorId, OWNER_ID);
  assert.equal(movement.stockWasteId, waste.id);
  assert.equal(balanceFor(state, OUTLET_ID)?.quantity.toFixed(0), '7');
  assert.equal(waste.quantity, '3');
  assert.equal(waste.reason, WasteReason.SPOILAGE);
  assert.equal(waste.actorId, OWNER_ID);
  assert.equal(state.stockWastes.length, 1);
});

test('zero and negative waste quantities are rejected before any ledger or balance write', async () => {
  const { prisma, state } = fakePrisma();
  addBalance(state, OUTLET_ID, '10');
  const service = new PurchasingService(prisma);

  for (const quantity of ['0', '-1']) {
    await assert.rejects(
      () =>
        service.recordWaste(
          OUTLET_ID,
          { stockItemId: ITEM_ID, quantity, reason: WasteReason.DAMAGE } as any,
          owner(),
        ),
      (error: unknown) => status(error) === 400,
    );
  }

  assert.equal(state.stockWastes.length, 0);
  assert.equal(state.movements.filter((row) => row.type === StockMovementType.WASTE).length, 0);
  assert.equal(balanceFor(state, OUTLET_ID)?.quantity.toFixed(0), '10');
});

test('waste beyond the available balance is rejected with INSUFFICIENT_STOCK', async () => {
  const { prisma, state } = fakePrisma();
  addBalance(state, OUTLET_ID, '2');
  const service = new PurchasingService(prisma);

  await assert.rejects(
    () =>
      service.recordWaste(
        OUTLET_ID,
        { stockItemId: ITEM_ID, quantity: '3', reason: WasteReason.DAMAGE } as any,
        owner(),
      ),
    (error: unknown) => status(error) === 422 && code(error) === 'INSUFFICIENT_STOCK',
  );

  assert.equal(state.stockWastes.length, 0);
  assert.equal(balanceFor(state, OUTLET_ID)?.quantity.toFixed(0), '2');
});

test('cashiers may count and record waste while owner-only transfer writes return 403', () => {
  const countPermissions = Reflect.getMetadata(
    PERMISSIONS_KEY,
    PurchasingController.prototype.createStockCount,
  ) as string[];
  const wastePermissions = Reflect.getMetadata(
    PERMISSIONS_KEY,
    PurchasingController.prototype.recordWaste,
  ) as string[];
  const transferPermissions = Reflect.getMetadata(
    PERMISSIONS_KEY,
    PurchasingController.prototype.dispatchTransfer,
  ) as string[];

  assert.deepEqual(countPermissions, [PERMISSIONS.STOCK_COUNT]);
  assert.deepEqual(wastePermissions, [PERMISSIONS.STOCK_WASTE]);
  assert.deepEqual(transferPermissions, [PERMISSIONS.STOCK_TRANSFER]);

  const guardFor = (permissions: string[]): PermissionsGuard =>
    new PermissionsGuard({
      getAllAndOverride: (key: string) => (key === PERMISSIONS_KEY ? permissions : undefined),
    } as unknown as Reflector);
  const contextFor = (user: AuthenticatedUser): ExecutionContext =>
    ({
      getHandler: () => () => undefined,
      getClass: () => class TestController {},
      switchToHttp: () => ({
        getRequest: () => ({ user }),
        getResponse: () => ({}),
        getNext: () => ({}),
      }),
    }) as unknown as ExecutionContext;

  assert.equal(guardFor(countPermissions).canActivate(contextFor(cashier())), true);
  assert.equal(guardFor(wastePermissions).canActivate(contextFor(cashier())), true);
  assert.equal(
    guardFor([PERMISSIONS.PURCHASE_ORDER_MANAGE]).canActivate(contextFor(owner())),
    true,
  );
  assert.throws(
    () => guardFor(transferPermissions).canActivate(contextFor(cashier())),
    (error: unknown) => status(error) === 403 && code(error) === 'FORBIDDEN',
  );
  assert.ok(permissionsForRole(Role.CASHIER).includes(PERMISSIONS.STOCK_COUNT));
  assert.ok(permissionsForRole(Role.CASHIER).includes(PERMISSIONS.STOCK_WASTE));
  assert.ok(!permissionsForRole(Role.CASHIER).includes(PERMISSIONS.STOCK_TRANSFER));
});

test('dispatch moves stock out of the source and exposes the gap as in-transit only', async () => {
  const { prisma, state } = fakePrisma();
  addBalance(state, OUTLET_ID, '10');
  const service = new PurchasingService(prisma);
  const transfer = await createTransfer(service, '4');

  const dispatched = await service.dispatchTransfer(OUTLET_ID, transfer.id, owner());

  assert.equal(dispatched.transfer.state, TransferState.DISPATCHED);
  assert.equal(dispatched.transfer.inTransitQuantity, '4');
  assert.equal(balanceFor(state, OUTLET_ID)?.quantity.toFixed(0), '6');
  assert.equal(balanceFor(state, DESTINATION_OUTLET_ID), undefined);
  assert.equal(
    state.movements.filter((row) => row.type === StockMovementType.TRANSFER_OUT).length,
    1,
  );
  assert.equal(movementTotal(state, OUTLET_ID).toFixed(0), '6');
});

test('receive adds the dispatched amount to the destination, zeroes in-transit and preserves grand total', async () => {
  const { prisma, state } = fakePrisma();
  addBalance(state, OUTLET_ID, '10');
  const service = new PurchasingService(prisma);
  const transfer = await createTransfer(service, '4');

  const dispatched = await service.dispatchTransfer(OUTLET_ID, transfer.id, owner());
  const sourceAfterDispatch = balanceFor(state, OUTLET_ID)?.quantity ?? ZERO;
  const destinationAfterDispatch = balanceFor(state, DESTINATION_OUTLET_ID)?.quantity ?? ZERO;
  assert.equal(
    sourceAfterDispatch
      .plus(destinationAfterDispatch)
      .plus(new Prisma.Decimal(dispatched.transfer.inTransitQuantity))
      .toFixed(0),
    '10',
  );

  const received = await service.receiveTransfer(
    DESTINATION_OUTLET_ID,
    transfer.id,
    { lines: [{ lineId: transfer.lines[0].id, quantity: '4' }] } as TransferReceiveDto,
    owner(),
  );

  assert.equal(received.transfer.state, TransferState.RECEIVED);
  assert.equal(received.transfer.inTransitQuantity, '0');
  assert.equal(balanceFor(state, OUTLET_ID)?.quantity.toFixed(0), '6');
  assert.equal(balanceFor(state, DESTINATION_OUTLET_ID)?.quantity.toFixed(0), '4');
  assert.equal(
    (balanceFor(state, OUTLET_ID)?.quantity ?? ZERO)
      .plus(balanceFor(state, DESTINATION_OUTLET_ID)?.quantity ?? ZERO)
      .plus(new Prisma.Decimal(received.transfer.inTransitQuantity))
      .toFixed(0),
    '10',
  );
  assert.equal(
    state.movements.filter((row) => row.type === StockMovementType.TRANSFER_IN).length,
    1,
  );
});

test('double receive returns 409 and does not write a second TRANSFER_IN row', async () => {
  const { prisma, state } = fakePrisma();
  addBalance(state, OUTLET_ID, '10');
  const service = new PurchasingService(prisma);
  const transfer = await createTransfer(service, '4');
  await service.dispatchTransfer(OUTLET_ID, transfer.id, owner());
  await service.receiveTransfer(
    DESTINATION_OUTLET_ID,
    transfer.id,
    { lines: [{ lineId: transfer.lines[0].id, quantity: '4' }] } as TransferReceiveDto,
    owner(),
  );

  await assert.rejects(
    () =>
      service.receiveTransfer(
        DESTINATION_OUTLET_ID,
        transfer.id,
        { lines: [{ lineId: transfer.lines[0].id, quantity: '4' }] } as TransferReceiveDto,
        owner(),
      ),
    (error: unknown) => status(error) === 409 && code(error) === 'TRANSFER_ALREADY_RECEIVED',
  );

  assert.equal(balanceFor(state, DESTINATION_OUTLET_ID)?.quantity.toFixed(0), '4');
  assert.equal(
    state.movements.filter((row) => row.type === StockMovementType.TRANSFER_IN).length,
    1,
  );
});

test('over-receive is rejected and leaves the destination and in-transit state untouched', async () => {
  const { prisma, state } = fakePrisma();
  addBalance(state, OUTLET_ID, '10');
  const service = new PurchasingService(prisma);
  const transfer = await createTransfer(service, '10');
  await service.dispatchTransfer(OUTLET_ID, transfer.id, owner());

  await assert.rejects(
    () =>
      service.receiveTransfer(
        DESTINATION_OUTLET_ID,
        transfer.id,
        { lines: [{ lineId: transfer.lines[0].id, quantity: '11' }] } as TransferReceiveDto,
        owner(),
      ),
    (error: unknown) => status(error) === 422 && code(error) === 'RECEIVE_EXCEEDS_DISPATCHED',
  );

  assert.equal(balanceFor(state, DESTINATION_OUTLET_ID), undefined);
  assert.equal(
    state.movements.filter((row) => row.type === StockMovementType.TRANSFER_IN).length,
    0,
  );
  const current = state.transfers[0];
  assert.equal(current.state, TransferState.DISPATCHED);
  assert.equal(current.version, 2);
});

test('cancelling an un-received dispatched transfer restores the source balance', async () => {
  const { prisma, state } = fakePrisma();
  addBalance(state, OUTLET_ID, '10');
  const service = new PurchasingService(prisma);
  const transfer = await createTransfer(service, '4');
  await service.dispatchTransfer(OUTLET_ID, transfer.id, owner());
  assert.equal(balanceFor(state, OUTLET_ID)?.quantity.toFixed(0), '6');

  const cancelled = await service.cancelTransfer(OUTLET_ID, transfer.id, owner());

  assert.equal(cancelled.state, TransferState.CANCELLED);
  assert.equal(balanceFor(state, OUTLET_ID)?.quantity.toFixed(0), '10');
  assert.equal(
    state.movements.filter((row) => row.type === StockMovementType.TRANSFER_CANCEL).length,
    1,
  );
  assert.equal(movementTotal(state, OUTLET_ID).toFixed(0), '10');
});

test('concurrent receives on the same transfer: one wins and the stale writer gets RECEIVE_CONFLICT', async () => {
  const { prisma, state } = fakePrisma();
  addBalance(state, OUTLET_ID, '10');
  const service = new PurchasingService(prisma);
  const transfer = await createTransfer(service, '10');
  await service.dispatchTransfer(OUTLET_ID, transfer.id, owner());
  const dto = {
    lines: [{ lineId: transfer.lines[0].id, quantity: '10' }],
  } as TransferReceiveDto;

  const results = await Promise.allSettled([
    service.receiveTransfer(DESTINATION_OUTLET_ID, transfer.id, dto, owner()),
    service.receiveTransfer(DESTINATION_OUTLET_ID, transfer.id, dto, owner()),
  ]);

  const fulfilled = results.filter((result) => result.status === 'fulfilled');
  const rejected = results.filter((result) => result.status === 'rejected');
  assert.equal(fulfilled.length, 1);
  assert.equal(rejected.length, 1);
  const failure = rejected[0] as PromiseRejectedResult;
  assert.equal(status(failure.reason), 409);
  assert.equal(code(failure.reason), 'RECEIVE_CONFLICT');

  assert.equal(balanceFor(state, DESTINATION_OUTLET_ID)?.quantity.toFixed(0), '10');
  assert.equal(
    state.movements.filter((row) => row.type === StockMovementType.TRANSFER_IN).length,
    1,
  );
  assert.equal(state.transferLines[0].version, 2);
  assert.equal(state.transfers[0].state, TransferState.RECEIVED);
});
