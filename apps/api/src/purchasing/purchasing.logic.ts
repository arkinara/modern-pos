import { Prisma, PurchaseOrderState } from '@prisma/client';
import { apiError } from '../common/api-error';

export const MAX_QUANTITY = new Prisma.Decimal('100000000000000');
export const ZERO = new Prisma.Decimal(0);

export enum PurchasingUnit {
  SUPPLIER = 'SUPPLIER',
  BASE = 'BASE',
}

export function fractionDigits(value: string): number {
  const dot = value.indexOf('.');
  return dot === -1 ? 0 : value.length - dot - 1;
}

export function assertPositiveQuantity(value: Prisma.Decimal, label: string): void {
  if (value.lessThanOrEqualTo(0)) {
    throw apiError(400, 'VALIDATION_ERROR', `${label} must be greater than zero`);
  }
  if (value.greaterThan(MAX_QUANTITY)) {
    throw apiError(400, 'VALIDATION_ERROR', `${label} exceeds the supported quantity limit`);
  }
}

export function assertRepresentableQuantity(
  value: Prisma.Decimal,
  quantityScale: number,
  label: string,
): void {
  if (fractionDigits(value.toString()) > quantityScale) {
    throw apiError(
      422,
      'QUANTITY_PRECISION_EXCEEDED',
      `${label} cannot be represented with the item quantity scale of ${quantityScale}`,
    );
  }
}

/**
 * Converts a receipt into both the supplier quantity and the base quantity
 * without rounding. Supplier-unit input may produce a base fraction that the
 * item cannot store; base-unit input may not divide evenly by the pack size.
 */
export function convertReceiptQuantity(
  unitsPerSupplierUnit: Prisma.Decimal,
  quantity: string,
  unit: PurchasingUnit,
  quantityScale: number,
): { baseDelta: Prisma.Decimal; supplierDelta: Prisma.Decimal } {
  const input = new Prisma.Decimal(quantity);
  assertPositiveQuantity(input, 'quantity');

  let baseDelta: Prisma.Decimal;
  let supplierDelta: Prisma.Decimal;
  if (unit === PurchasingUnit.SUPPLIER) {
    supplierDelta = input;
    baseDelta = input.mul(unitsPerSupplierUnit);
  } else {
    baseDelta = input;
    supplierDelta = baseDelta.div(unitsPerSupplierUnit);
    if (!supplierDelta.mul(unitsPerSupplierUnit).equals(baseDelta)) {
      throw apiError(
        422,
        'CONVERSION_NOT_EXACT',
        'Base quantity does not convert to an exact supplier quantity',
      );
    }
  }

  if (baseDelta.greaterThan(MAX_QUANTITY) || supplierDelta.greaterThan(MAX_QUANTITY)) {
    throw apiError(422, 'CONVERSION_OVERFLOW', 'Converted quantity exceeds the supported limit');
  }
  assertRepresentableQuantity(baseDelta, quantityScale, 'received base quantity');
  if (fractionDigits(supplierDelta.toString()) > 6) {
    throw apiError(
      422,
      'CONVERSION_NOT_EXACT',
      'Converted supplier quantity cannot be stored without rounding',
    );
  }
  return { baseDelta, supplierDelta };
}

export function nextPurchaseOrderState(
  lines: { orderedBaseQuantity: Prisma.Decimal; receivedBaseQuantity: Prisma.Decimal }[],
): PurchaseOrderState {
  const fullyReceived = lines.every((line) =>
    line.receivedBaseQuantity.greaterThanOrEqualTo(line.orderedBaseQuantity),
  );
  return fullyReceived ? PurchaseOrderState.RECEIVED : PurchaseOrderState.PARTIALLY_RECEIVED;
}

export function transferInTransitQuantity(
  lines: { dispatchedQuantity: Prisma.Decimal; receivedQuantity: Prisma.Decimal }[],
): Prisma.Decimal {
  return lines.reduce(
    (total, line) => total.plus(line.dispatchedQuantity.minus(line.receivedQuantity)),
    ZERO,
  );
}

export function countVariance(
  systemQuantity: Prisma.Decimal,
  countedQuantity: Prisma.Decimal,
): Prisma.Decimal {
  return countedQuantity.minus(systemQuantity);
}
