import { Prisma } from '@prisma/client';
import { apiError } from '../common/api-error';

export const MICROS_PER_MINOR = 1_000_000n;
export const BPS_DENOMINATOR = 10_000n;

export interface ReceiptCostEvent {
  quantityMicros: bigint;
  valueMicros: bigint;
}

export type CostingMethodName = 'MOVING_AVERAGE' | 'LAST_PURCHASE';

function toMicros(value: Prisma.Decimal): bigint {
  return BigInt(value.times('1000000').toDecimalPlaces(0, Prisma.Decimal.ROUND_HALF_UP).toString());
}

export function quantityMicros(quantity: Prisma.Decimal | string): bigint {
  return toMicros(new Prisma.Decimal(quantity));
}

/**
 * Receipt value in micro-minor units. unitPrice is the supplier-unit price and
 * unitsPerSupplierUnit converts one supplier unit into base units, so the
 * division happens before the half-up rounding to an integer micro value.
 */
export function receiptValueMicros(
  baseQuantity: Prisma.Decimal | string,
  unitPrice: Prisma.Decimal | string,
  unitsPerSupplierUnit: Prisma.Decimal | string,
): bigint {
  const quantity = new Prisma.Decimal(baseQuantity);
  const price = new Prisma.Decimal(unitPrice);
  const factor = new Prisma.Decimal(unitsPerSupplierUnit);

  if (quantity.lessThan(0) || price.lessThan(0) || factor.lessThanOrEqualTo(0)) {
    throw apiError(422, 'COST_INPUT_INVALID', 'Receipt cost inputs must be non-negative');
  }

  return BigInt(
    quantity
      .times(price)
      .times('1000000')
      .div(factor)
      .toDecimalPlaces(0, Prisma.Decimal.ROUND_HALF_UP)
      .toString(),
  );
}

function divideHalfUp(numerator: bigint, denominator: bigint): bigint {
  if (denominator === 0n) {
    return 0n;
  }

  const negative = numerator < 0n !== denominator < 0n;
  const absoluteNumerator = numerator < 0n ? -numerator : numerator;
  const absoluteDenominator = denominator < 0n ? -denominator : denominator;
  const quotient = absoluteNumerator / absoluteDenominator;
  const remainder = absoluteNumerator % absoluteDenominator;
  const rounded = remainder * 2n >= absoluteDenominator ? quotient + 1n : quotient;

  return negative ? -rounded : rounded;
}

export function resolveUnitCostMicros(
  method: CostingMethodName,
  events: readonly ReceiptCostEvent[],
): bigint | null {
  if (events.length === 0) {
    return null;
  }

  if (method === 'LAST_PURCHASE') {
    const last = events[events.length - 1]!;
    if (last.quantityMicros <= 0n) {
      return null;
    }
    return divideHalfUp(last.valueMicros * MICROS_PER_MINOR, last.quantityMicros);
  }

  const totalQuantity = events.reduce((sum, event) => sum + event.quantityMicros, 0n);
  const totalValue = events.reduce((sum, event) => sum + event.valueMicros, 0n);

  if (totalQuantity <= 0n) {
    return null;
  }

  return divideHalfUp(totalValue * MICROS_PER_MINOR, totalQuantity);
}

/** Cost for a non-negative quantity at an integer micro unit cost. */
export function costForQuantityMicros(quantity: bigint, unitCostMicros: bigint): bigint {
  if (quantity < 0n || unitCostMicros < 0n) {
    throw apiError(422, 'COST_INPUT_INVALID', 'Cost quantity and unit cost must be non-negative');
  }

  return divideHalfUp(quantity * unitCostMicros, MICROS_PER_MINOR * MICROS_PER_MINOR);
}

export function marginBps(netProfitMinor: bigint, revenueMinor: bigint): number | null {
  if (revenueMinor === 0n) {
    return null;
  }

  const bps = divideHalfUp(netProfitMinor * BPS_DENOMINATOR, revenueMinor);
  const numeric = Number(bps);

  if (!Number.isSafeInteger(numeric)) {
    return null;
  }

  return numeric;
}
