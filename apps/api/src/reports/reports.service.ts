import { Injectable } from '@nestjs/common';
import { PaymentKind, SaleState } from '@prisma/client';
import type { AuthenticatedUser } from '../auth/auth.types';
import { apiError } from '../common/api-error';
import { PrismaService } from '../prisma/prisma.service';
import { localDateRangeUtc, parseDateOnly } from '../sales/outlet-time';
import { MAX_SAFE_MINOR_NUMBER } from '../sales/money';
import { CSV_COLUMNS, toCsv, type CsvSaleRow } from './csv';
import { ReportRangeQueryDto } from './dto/report-range-query.dto';

const MAX_REPORT_DAYS = 366;
const DAY_MS = 24 * 60 * 60 * 1000;

export interface PaymentBreakdownResponse {
  kind: PaymentKind;
  receivedMinor: number;
}

export interface TopItemResponse {
  name: string;
  quantity: number;
}

export interface DailyReportResponse {
  from: string;
  to: string;
  timezone: string;
  currency: string;
  currencyExponent: number;
  grossItemSalesMinor: number;
  reversalItemValueMinor: number;
  refundMoneyMinor: number;
  netItemSalesMinor: number;
  saleCount: number;
  reversalCount: number;
  averageBillMinor: number;
  paymentBreakdown: PaymentBreakdownResponse[];
  topItems: TopItemResponse[];
  generatedAt: string;
}

export interface SalesCsvExport {
  filename: string;
  csv: string;
  saleCount: number;
  reversalCount: number;
}

interface OutletRecord {
  id: string;
  name: string;
  businessId: string;
  timezone: string;
  currency: string;
  currencyExponent: number;
}

interface ReportSaleLine {
  id: string;
  name: string;
  variantName: string;
  quantity: number;
  unitPriceMinor: bigint;
  lineSubtotalMinor: bigint;
}

interface ReportPayment {
  kind: PaymentKind;
  status: string;
  amountMinor: bigint;
  tenderedMinor: bigint | null;
  changeMinor: bigint | null;
  reference: string | null;
}

interface ReportSale {
  id: string;
  reference: string;
  state: SaleState;
  currency: string;
  currencyExponent: number;
  timezone: string;
  completedAt: Date;
  subtotalMinor: bigint;
  serviceMinor: bigint;
  taxMinor: bigint;
  totalMinor: bigint;
  lines: ReportSaleLine[];
  payment: ReportPayment | null;
}

interface ReportReversal {
  id: string;
  saleId: string;
  kind?: string;
  reason: string;
  refundMinor?: bigint;
  lines?: unknown;
  refundLines?: { saleLineId: string; quantity: number }[];
  createdAt: Date;
  sale: {
    reference: string;
    currency: string;
    currencyExponent: number;
    timezone: string;
    subtotalMinor: bigint;
    lines: ReportSaleLine[];
  };
}

function wireMinor(value: bigint, field: string): number {
  if (value < 0n || value > BigInt(MAX_SAFE_MINOR_NUMBER)) {
    throw apiError(
      500,
      'MONEY_OUT_OF_RANGE',
      `${field} is outside the JavaScript safe-integer range`,
    );
  }

  return Number(value);
}

function signedWireMinor(value: bigint, field: string): number {
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

/** Half-up average for nonnegative money and a positive count. */
export function halfUpAverage(numerator: bigint, denominator: bigint): bigint {
  if (denominator <= 0n) {
    return 0n;
  }

  const quotient = numerator / denominator;
  const remainder = numerator % denominator;
  return remainder * 2n >= denominator ? quotient + 1n : quotient;
}

export function assertReportRange(from: string, to: string): void {
  const start = parseDateOnly(from);
  const end = parseDateOnly(to);
  const startUtc = Date.UTC(start.year, start.month - 1, start.day);
  const endUtc = Date.UTC(end.year, end.month - 1, end.day);
  const days = Math.floor((endUtc - startUtc) / DAY_MS) + 1;

  if (days > MAX_REPORT_DAYS) {
    throw apiError(
      400,
      'VALIDATION_ERROR',
      `Report range must not exceed ${MAX_REPORT_DAYS} local calendar days`,
    );
  }
}

export function formatLocalTimestamp(date: Date, timeZone: string): string {
  const parts = new Intl.DateTimeFormat('en-US', {
    timeZone,
    hour12: false,
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
  }).formatToParts(date);

  const read = (type: Intl.DateTimeFormatPartTypes): string =>
    parts.find((part) => part.type === type)?.value ?? '00';

  const hour = read('hour') === '24' ? '00' : read('hour');
  return `${read('year')}-${read('month')}-${read('day')} ${hour}:${read('minute')}:${read(
    'second',
  )}`;
}

function slug(value: string): string {
  const normalized = value
    .normalize('NFKD')
    .replaceAll(/[^\x20-\x7e]/g, '')
    .toLowerCase()
    .replaceAll(/[^a-z0-9]+/g, '-')
    .replaceAll(/^-+|-+$/g, '');

  return normalized.length > 0 ? normalized : 'outlet';
}

@Injectable()
export class ReportsService {
  constructor(private readonly prisma: PrismaService) {}

  async dailyReport(
    outletId: string,
    query: ReportRangeQueryDto,
    user: AuthenticatedUser,
  ): Promise<DailyReportResponse> {
    const { outlet, sales, reversals } = await this.loadPeriod(outletId, query, user);

    const grossItemSalesMinor = sales.reduce((sum, sale) => sum + sale.subtotalMinor, 0n);
    const reversalItemValueMinor = reversals.reduce(
      (sum, reversal) =>
        sum +
        (reversal.kind === 'PARTIAL' ? (reversal.refundMinor ?? 0n) : reversal.sale.subtotalMinor),
      0n,
    );
    const refundMoneyMinor = reversals.reduce(
      (sum, reversal) => sum + (reversal.refundMinor ?? reversal.sale.subtotalMinor),
      0n,
    );
    const netItemSalesMinor = grossItemSalesMinor - reversalItemValueMinor;
    const saleCount = sales.length;
    const reversalCount = reversals.length;
    const averageBillMinor = halfUpAverage(grossItemSalesMinor, BigInt(saleCount));

    const received = new Map<PaymentKind, bigint>([
      [PaymentKind.CASH, 0n],
      [PaymentKind.MANUAL_EXTERNAL, 0n],
    ]);
    const quantities = new Map<string, number>();

    for (const sale of sales) {
      if (!sale.payment) {
        throw apiError(500, 'SALE_CORRUPT', 'Sale is missing its payment record');
      }

      received.set(
        sale.payment.kind,
        (received.get(sale.payment.kind) ?? 0n) + sale.payment.amountMinor,
      );

      for (const line of sale.lines) {
        quantities.set(line.name, (quantities.get(line.name) ?? 0) + line.quantity);
      }
    }

    const topItems = [...quantities.entries()]
      .map(([name, quantity]) => ({ name, quantity }))
      .sort((a, b) => b.quantity - a.quantity || (a.name < b.name ? -1 : a.name > b.name ? 1 : 0));

    return {
      from: query.from,
      to: query.to,
      timezone: outlet.timezone,
      currency: outlet.currency,
      currencyExponent: outlet.currencyExponent,
      grossItemSalesMinor: wireMinor(grossItemSalesMinor, 'grossItemSalesMinor'),
      reversalItemValueMinor: wireMinor(reversalItemValueMinor, 'reversalItemValueMinor'),
      refundMoneyMinor: wireMinor(refundMoneyMinor, 'refundMoneyMinor'),
      netItemSalesMinor: signedWireMinor(netItemSalesMinor, 'netItemSalesMinor'),
      saleCount,
      reversalCount,
      averageBillMinor: wireMinor(averageBillMinor, 'averageBillMinor'),
      paymentBreakdown: [
        {
          kind: PaymentKind.CASH,
          receivedMinor: wireMinor(received.get(PaymentKind.CASH) ?? 0n, 'paymentBreakdown'),
        },
        {
          kind: PaymentKind.MANUAL_EXTERNAL,
          receivedMinor: wireMinor(
            received.get(PaymentKind.MANUAL_EXTERNAL) ?? 0n,
            'paymentBreakdown',
          ),
        },
      ],
      topItems,
      generatedAt: new Date().toISOString(),
    };
  }

  async exportCsv(
    outletId: string,
    query: ReportRangeQueryDto,
    user: AuthenticatedUser,
  ): Promise<SalesCsvExport> {
    const { outlet, sales, reversals } = await this.loadPeriod(outletId, query, user);

    const rows: CsvSaleRow[] = [];

    for (const sale of sales) {
      if (!sale.payment) {
        throw apiError(500, 'SALE_CORRUPT', 'Sale is missing its payment record');
      }

      for (const line of sale.lines) {
        rows.push({
          reference: sale.reference,
          completedAtUtc: sale.completedAt.toISOString(),
          completedAtLocal: formatLocalTimestamp(sale.completedAt, outlet.timezone),
          timezone: outlet.timezone,
          state: sale.state,
          currency: sale.currency,
          currencyExponent: sale.currencyExponent,
          itemName: line.name,
          variantName: line.variantName,
          quantity: line.quantity,
          unitPriceMinor: wireMinor(line.unitPriceMinor, 'unitPriceMinor'),
          lineSubtotalMinor: wireMinor(line.lineSubtotalMinor, 'lineSubtotalMinor'),
          saleSubtotalMinor: wireMinor(sale.subtotalMinor, 'subtotalMinor'),
          saleServiceMinor: wireMinor(sale.serviceMinor, 'serviceMinor'),
          saleTaxMinor: wireMinor(sale.taxMinor, 'taxMinor'),
          saleTotalMinor: wireMinor(sale.totalMinor, 'totalMinor'),
          paymentKind: sale.payment.kind,
          paymentStatus: sale.payment.status,
          paymentAmountMinor: wireMinor(sale.payment.amountMinor, 'paymentAmountMinor'),
          tenderedMinor:
            sale.payment.tenderedMinor === null
              ? null
              : wireMinor(sale.payment.tenderedMinor, 'tenderedMinor'),
          changeMinor:
            sale.payment.changeMinor === null
              ? null
              : wireMinor(sale.payment.changeMinor, 'changeMinor'),
          paymentReference: sale.payment.reference,
          rowType: 'SALE',
          reversalReason: null,
        });
      }
    }

    for (const reversal of reversals) {
      if (reversal.kind === 'PARTIAL') {
        const refundMinor = reversal.refundMinor ?? 0n;
        const refundedQuantity = (reversal.refundLines ?? []).reduce(
          (sum, line) => sum + line.quantity,
          0,
        );
        const firstLine = reversal.sale.lines[0];

        rows.push({
          reference: reversal.sale.reference,
          completedAtUtc: reversal.createdAt.toISOString(),
          completedAtLocal: formatLocalTimestamp(reversal.createdAt, outlet.timezone),
          timezone: reversal.sale.timezone,
          state: SaleState.REVERSED,
          currency: reversal.sale.currency,
          currencyExponent: reversal.sale.currencyExponent,
          itemName: firstLine?.name ?? 'Partial refund',
          variantName: firstLine?.variantName ?? '',
          quantity: -refundedQuantity,
          unitPriceMinor: 0,
          lineSubtotalMinor: signedWireMinor(-refundMinor, 'partialRefundMinor'),
          saleSubtotalMinor: signedWireMinor(-refundMinor, 'partialRefundMinor'),
          saleServiceMinor: 0,
          saleTaxMinor: 0,
          saleTotalMinor: signedWireMinor(-refundMinor, 'partialRefundMinor'),
          paymentKind: null,
          paymentStatus: null,
          paymentAmountMinor: null,
          tenderedMinor: null,
          changeMinor: null,
          paymentReference: null,
          rowType: 'REFUND',
          reversalReason: reversal.reason,
        });
        continue;
      }

      for (const line of reversal.sale.lines) {
        rows.push({
          reference: reversal.sale.reference,
          completedAtUtc: reversal.createdAt.toISOString(),
          completedAtLocal: formatLocalTimestamp(reversal.createdAt, outlet.timezone),
          timezone: reversal.sale.timezone,
          state: SaleState.REVERSED,
          currency: reversal.sale.currency,
          currencyExponent: reversal.sale.currencyExponent,
          itemName: line.name,
          variantName: line.variantName,
          quantity: -line.quantity,
          unitPriceMinor: signedWireMinor(-line.unitPriceMinor, 'reversalUnitPriceMinor'),
          lineSubtotalMinor: signedWireMinor(-line.lineSubtotalMinor, 'reversalLineSubtotalMinor'),
          saleSubtotalMinor: signedWireMinor(-reversal.sale.subtotalMinor, 'reversalSubtotalMinor'),
          saleServiceMinor: 0,
          saleTaxMinor: 0,
          saleTotalMinor: signedWireMinor(-reversal.sale.subtotalMinor, 'reversalTotalMinor'),
          paymentKind: null,
          paymentStatus: null,
          paymentAmountMinor: null,
          tenderedMinor: null,
          changeMinor: null,
          paymentReference: null,
          rowType: 'REVERSAL',
          reversalReason: reversal.reason,
        });
      }
    }

    return {
      filename: `sales-${slug(outlet.name)}-${query.from}-to-${query.to}.csv`,
      csv: toCsv(rows),
      saleCount: sales.length,
      reversalCount: reversals.length,
    };
  }

  private async loadPeriod(
    outletId: string,
    query: ReportRangeQueryDto,
    user: AuthenticatedUser,
  ): Promise<{ outlet: OutletRecord; sales: ReportSale[]; reversals: ReportReversal[] }> {
    assertReportRange(query.from, query.to);

    const outlet = await this.prisma.outlet.findFirst({
      where: { id: outletId, businessId: user.businessId },
      select: {
        id: true,
        name: true,
        businessId: true,
        timezone: true,
        currency: true,
        currencyExponent: true,
      },
    });

    if (!outlet) {
      throw apiError(404, 'NOT_FOUND', 'Outlet not found');
    }

    const completedAt = localDateRangeUtc(query.from, query.to, outlet.timezone);

    const sales = (await this.prisma.sale.findMany({
      where: {
        businessId: user.businessId,
        outletId,
        state: SaleState.COMPLETED,
        completedAt,
      },
      orderBy: [{ completedAt: 'desc' }, { id: 'desc' }],
      include: {
        lines: { orderBy: [{ id: 'asc' }] },
        payment: true,
      },
    })) as ReportSale[];

    const reversals = (await this.prisma.saleReversal.findMany({
      where: {
        businessId: user.businessId,
        outletId,
        createdAt: completedAt,
      },
      orderBy: [{ createdAt: 'desc' }, { id: 'desc' }],
      include: {
        refundLines: { select: { saleLineId: true, quantity: true } },
        sale: {
          select: {
            reference: true,
            currency: true,
            currencyExponent: true,
            timezone: true,
            subtotalMinor: true,
            lines: { orderBy: [{ id: 'asc' }] },
          },
        },
      },
    })) as ReportReversal[];

    return { outlet, sales, reversals };
  }
}

export { CSV_COLUMNS };
