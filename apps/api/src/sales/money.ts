import { PaymentKind } from '@prisma/client';
import { apiError } from '../common/api-error';

export const BPS_DENOMINATOR = 10_000n;
export const MAX_SAFE_MINOR = 9_007_199_254_740_991n;
export const MAX_SAFE_MINOR_NUMBER = Number.MAX_SAFE_INTEGER;

export interface MoneyTotals {
  subtotalMinor: bigint;
  serviceMinor: bigint;
  taxMinor: bigint;
  totalMinor: bigint;
}

export interface DiscountedTotals extends MoneyTotals {
  discountMinor: bigint;
}

export interface PricedLine {
  unitPriceMinor: bigint;
  quantity: number;
}

export interface PaymentInputLike {
  kind: PaymentKind;
  amountMinor: number;
  tenderedMinor?: number;
  reference?: string;
}

export interface NormalizedPayment {
  kind: PaymentKind;
  amountMinor: bigint;
  tenderedMinor: bigint | null;
  changeMinor: bigint | null;
  reference: string | null;
}

export function toMinor(value: number | bigint, field: string): bigint {
  const minor = typeof value === 'bigint' ? value : BigInt(value);

  if (minor < 0n || minor > MAX_SAFE_MINOR) {
    throw apiError(
      422,
      'MONEY_OUT_OF_RANGE',
      `${field} must be a nonnegative integer within the JavaScript safe-integer range`,
    );
  }

  return minor;
}

export function toWireMinor(value: bigint, field: string): number {
  if (value < 0n || value > MAX_SAFE_MINOR) {
    throw apiError(
      500,
      'MONEY_OUT_OF_RANGE',
      `${field} is outside the JavaScript safe-integer range`,
    );
  }

  return Number(value);
}

export function halfUpDiv(numerator: bigint, denominator: bigint = BPS_DENOMINATOR): bigint {
  if (numerator < 0n || denominator <= 0n) {
    throw apiError(500, 'MONEY_CALCULATION_FAILED', 'Invalid money calculation input');
  }

  const quotient = numerator / denominator;
  const remainder = numerator % denominator;
  return remainder * 2n >= denominator ? quotient + 1n : quotient;
}

export function lineSubtotalMinor(line: PricedLine): bigint {
  if (!Number.isInteger(line.quantity) || line.quantity <= 0) {
    throw apiError(422, 'INVALID_QUANTITY', 'Line quantity must be a positive integer');
  }

  const product = line.unitPriceMinor * BigInt(line.quantity);

  if (product > MAX_SAFE_MINOR) {
    throw apiError(
      422,
      'MONEY_OUT_OF_RANGE',
      'Line subtotal exceeds the JavaScript safe-integer range',
    );
  }

  return product;
}

export function calculateTotals(
  lines: PricedLine[],
  serviceBps: number,
  taxBps: number,
): MoneyTotals {
  const subtotalMinor = lines.reduce((sum, line) => sum + lineSubtotalMinor(line), 0n);

  if (subtotalMinor > MAX_SAFE_MINOR) {
    throw apiError(422, 'MONEY_OUT_OF_RANGE', 'Subtotal exceeds the safe-integer range');
  }

  const serviceMinor = halfUpDiv(subtotalMinor * BigInt(serviceBps));
  const taxableMinor = subtotalMinor + serviceMinor;

  if (taxableMinor > MAX_SAFE_MINOR) {
    throw apiError(422, 'MONEY_OUT_OF_RANGE', 'Taxable amount exceeds the safe-integer range');
  }

  const taxMinor = halfUpDiv(taxableMinor * BigInt(taxBps));
  const totalMinor = subtotalMinor + serviceMinor + taxMinor;

  if (totalMinor > MAX_SAFE_MINOR) {
    throw apiError(422, 'MONEY_OUT_OF_RANGE', 'Total exceeds the safe-integer range');
  }

  return { subtotalMinor, serviceMinor, taxMinor, totalMinor };
}

/**
 * Discounts reduce the taxable basket first. Service is charged on the
 * discounted subtotal and tax on the discounted subtotal plus service, all
 * rounded half-up to integer minor units.
 */
export function calculateDiscountedTotals(
  lines: PricedLine[],
  serviceBps: number,
  taxBps: number,
  discountMinor: bigint,
): DiscountedTotals {
  const base = calculateTotals(lines, 0, 0);

  if (discountMinor < 0n) {
    throw apiError(500, 'MONEY_CALCULATION_FAILED', 'Discount must be nonnegative');
  }

  if (discountMinor > base.subtotalMinor) {
    throw apiError(500, 'MONEY_CALCULATION_FAILED', 'Discount exceeds the basket subtotal');
  }

  const discountedSubtotal = base.subtotalMinor - discountMinor;
  const serviceMinor = halfUpDiv(discountedSubtotal * BigInt(serviceBps));
  const taxableMinor = discountedSubtotal + serviceMinor;

  if (taxableMinor > MAX_SAFE_MINOR) {
    throw apiError(422, 'MONEY_OUT_OF_RANGE', 'Taxable amount exceeds the safe-integer range');
  }

  const taxMinor = halfUpDiv(taxableMinor * BigInt(taxBps));
  const totalMinor = discountedSubtotal + serviceMinor + taxMinor;

  if (totalMinor > MAX_SAFE_MINOR) {
    throw apiError(422, 'MONEY_OUT_OF_RANGE', 'Total exceeds the safe-integer range');
  }

  return {
    subtotalMinor: base.subtotalMinor,
    discountMinor,
    serviceMinor,
    taxMinor,
    totalMinor,
  };
}

export function normalizePayment(totalMinor: bigint, input: PaymentInputLike): NormalizedPayment {  const amountMinor = toMinor(input.amountMinor, 'payment.amountMinor');

  if (amountMinor !== totalMinor) {
    throw apiError(422, 'PAYMENT_INVALID', 'payment.amountMinor must equal the quoted total', {
      details: { reason: 'AMOUNT_MISMATCH' },
    });
  }

  if (input.kind === PaymentKind.MANUAL_EXTERNAL) {
    if (input.tenderedMinor !== undefined) {
      throw apiError(
        422,
        'PAYMENT_INVALID',
        'MANUAL_EXTERNAL payments must omit tenderedMinor and changeMinor',
        { details: { reason: 'TENDER_NOT_ALLOWED' } },
      );
    }

    return {
      kind: input.kind,
      amountMinor,
      tenderedMinor: null,
      changeMinor: null,
      reference: input.reference ?? null,
    };
  }

  if (input.tenderedMinor === undefined) {
    throw apiError(422, 'PAYMENT_INVALID', 'CASH payments require tenderedMinor', {
      details: { reason: 'TENDER_REQUIRED' },
    });
  }

  const tenderedMinor = toMinor(input.tenderedMinor, 'payment.tenderedMinor');

  if (tenderedMinor < totalMinor) {
    throw apiError(
      422,
      'PAYMENT_INVALID',
      'CASH tender must be greater than or equal to the quoted total',
      { details: { reason: 'INSUFFICIENT_TENDER' } },
    );
  }

  return {
    kind: input.kind,
    amountMinor,
    tenderedMinor,
    changeMinor: tenderedMinor - totalMinor,
    reference: input.reference ?? null,
  };
}
