import { PaymentKind, PaymentStatus } from '@prisma/client';
import { apiError } from '../common/api-error';
import { MAX_SAFE_MINOR_NUMBER } from '../sales/money';

export interface CashInputs {
  openingFloatMinor: bigint;
  cashSalesMinor: bigint;
  paidInMinor: bigint;
  paidOutMinor: bigint;
}

/** Expected drawer cash: opening float + cash sales + paid-ins - paid-outs. */
export function expectedCashMinor(input: CashInputs): bigint {
  return input.openingFloatMinor + input.cashSalesMinor + input.paidInMinor - input.paidOutMinor;
}

/** Positive means the drawer is over; negative means it is short. */
export function discrepancyMinor(countedCashMinor: bigint, expected: bigint): bigint {
  return countedCashMinor - expected;
}

export interface TenderRecord {
  kind: PaymentKind;
  status: PaymentStatus;
  amountMinor: bigint;
}

export function isSettledTender(kind: PaymentKind, status: PaymentStatus): boolean {
  if (kind !== PaymentKind.ONLINE) {
    return status === PaymentStatus.RECORDED;
  }

  return (
    status === PaymentStatus.SUCCEEDED ||
    status === PaymentStatus.PARTIALLY_REFUNDED ||
    status === PaymentStatus.REFUNDED
  );
}

/** Cash sales come only from recorded cash tender rows. */
export function cashSalesMinorFromTenders(tenders: readonly TenderRecord[]): bigint {
  return tenders.reduce(
    (sum, tender) =>
      tender.kind === PaymentKind.CASH && tender.status === PaymentStatus.RECORDED
        ? sum + tender.amountMinor
        : sum,
    0n,
  );
}

export function toSignedWireMinor(value: bigint, field: string): number {
  const absolute = value < 0n ? -value : value;
  if (absolute > BigInt(MAX_SAFE_MINOR_NUMBER)) {
    throw apiError(
      500,
      'MONEY_OUT_OF_RANGE',
      `${field} is outside the JavaScript safe-integer range`,
    );
  }
  return Number(value);
}
