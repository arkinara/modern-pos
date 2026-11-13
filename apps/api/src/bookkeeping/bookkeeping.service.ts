import { Injectable } from '@nestjs/common';
import { CostingMethod, Prisma, StockMovementType } from '@prisma/client';
import type { AuthenticatedUser } from '../auth/auth.types';
import { apiError } from '../common/api-error';
import { PrismaService } from '../prisma/prisma.service';
import { MAX_SAFE_MINOR_NUMBER } from '../sales/money';
import { localDateRangeUtc, parseDateOnly } from '../sales/outlet-time';
import { ReportsService } from '../reports/reports.service';
import { ReportRangeQueryDto } from '../reports/dto/report-range-query.dto';
import {
  costForQuantityMicros,
  marginBps,
  quantityMicros,
  receiptValueMicros,
  resolveUnitCostMicros,
  type ReceiptCostEvent,
} from './costing';
import { buildCsv } from './csv';
import {
  CostingUpdateDto,
  ExpenseCategoryCreateDto,
  ExpenseCreateDto,
  ExpenseListQueryDto,
} from './dto/bookkeeping.dto';

const MAX_REPORT_DAYS = 366;
const DAY_MS = 24 * 60 * 60 * 1000;

interface OutletRecord {
  id: string;
  name: string;
  businessId: string;
  timezone: string;
  currency: string;
  currencyExponent: number;
}

interface CostedMovement {
  stockItemId: string;
  delta: Prisma.Decimal;
  type: StockMovementType;
}

interface CostPeriod {
  cogsMinor: bigint | null;
  reversalCogsMinor: bigint | null;
  wasteMinor: bigint | null;
  missingStockItemIds: string[];
}

export interface ExpenseCategoryResponse {
  id: string;
  name: string;
  active: boolean;
  createdAt: string;
}

export interface BookkeepingConfigurationResponse {
  outletId: string;
  costingMethod: CostingMethod | null;
  costingMethodDefined: boolean;
  version: number | null;
  expenseCategoryCount: number;
  expenseCategoriesDefined: boolean;
  expenseCategories: ExpenseCategoryResponse[];
}

export interface ExpenseResponse {
  id: string;
  outletId: string;
  categoryId: string;
  categoryName: string;
  amountMinor: number;
  incurredOn: string;
  note: string;
  createdById: string;
  createdAt: string;
}

export interface ExpensePageResponse {
  items: ExpenseResponse[];
}

export interface ExpenseBreakdownResponse {
  categoryId: string | null;
  name: string;
  amountMinor: number;
  derived: boolean;
}

export interface ProfitReportResponse {
  from: string;
  to: string;
  timezone: string;
  currency: string;
  currencyExponent: number;
  generatedAt: string;
  marginAvailable: boolean;
  unavailableReasons: string[];
  costingMethod: CostingMethod | null;
  revenue: {
    grossItemSalesMinor: number;
    reversalItemValueMinor: number;
    netItemSalesMinor: number;
    saleCount: number;
    reversalCount: number;
  };
  cogs: {
    saleCostMinor: number;
    reversalRestockCreditMinor: number;
    netCogsMinor: number;
  } | null;
  waste: {
    costMinor: number;
  } | null;
  expenses: {
    manualMinor: number;
    wasteMinor: number;
    totalMinor: number;
    breakdown: ExpenseBreakdownResponse[];
  };
  grossProfitMinor: number | null;
  netProfitMinor: number | null;
  netMarginBps: number | null;
  marginBpsUnavailableReason: string | null;
}

export interface ConsolidatedOutletResponse {
  outletId: string;
  outletName: string;
  timezone: string;
  currency: string;
  currencyExponent: number;
  grossItemSalesMinor: number;
  reversalItemValueMinor: number;
  netItemSalesMinor: number;
  refundMoneyMinor: number;
  saleCount: number;
  reversalCount: number;
  averageBillMinor: number;
  paymentBreakdown: { kind: string; receivedMinor: number }[];
  stockValueMinor: number | null;
  stockValueUnavailableReason: string | null;
  shiftsOpened: number;
  shiftsClosed: number;
  attendanceClockIns: number;
}

export interface ConsolidatedResponse {
  from: string;
  to: string;
  generatedAt: string;
  outletCount: number;
  currency: string | null;
  currencyExponent: number | null;
  currencyConsistent: boolean;
  perOutlet: ConsolidatedOutletResponse[];
  consolidated: {
    grossItemSalesMinor: number;
    reversalItemValueMinor: number;
    netItemSalesMinor: number;
    refundMoneyMinor: number;
    saleCount: number;
    reversalCount: number;
    averageBillMinor: number;
    paymentBreakdown: { kind: string; receivedMinor: number }[];
    stockValueMinor: number | null;
    stockValueUnavailableReason: string | null;
    shiftsOpened: number;
    shiftsClosed: number;
    attendanceClockIns: number;
  };
}

export interface ExportFile {
  filename: string;
  csv: string;
}

function signedWire(value: bigint, field: string): number {
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

function positiveWire(value: bigint, field: string): number {
  if (value < 0n) {
    throw apiError(500, 'MONEY_OUT_OF_RANGE', `${field} must be non-negative`);
  }
  return signedWire(value, field);
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

function dateOnlyUtc(value: string): Date {
  const parsed = parseDateOnly(value);
  return new Date(Date.UTC(parsed.year, parsed.month - 1, parsed.day));
}

function formatLocalTimestamp(date: Date, timeZone: string): string {
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

function assertRange(from: string, to: string): void {
  const start = parseDateOnly(from);
  const end = parseDateOnly(to);
  const days =
    Math.floor(
      (Date.UTC(end.year, end.month - 1, end.day) -
        Date.UTC(start.year, start.month - 1, start.day)) /
        DAY_MS,
    ) + 1;

  if (days > MAX_REPORT_DAYS) {
    throw apiError(
      400,
      'VALIDATION_ERROR',
      `Report range must not exceed ${MAX_REPORT_DAYS} local calendar days`,
    );
  }
}

@Injectable()
export class BookkeepingService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly reports: ReportsService,
  ) {}

  async getConfiguration(
    outletId: string,
    user: AuthenticatedUser,
  ): Promise<BookkeepingConfigurationResponse> {
    await this.requireOutlet(this.prisma, outletId, user.businessId);
    const [setting, categories] = await Promise.all([
      this.prisma.bookkeepingSetting.findUnique({ where: { outletId } }),
      this.prisma.expenseCategory.findMany({
        where: { businessId: user.businessId, active: true },
        orderBy: [{ name: 'asc' }, { id: 'asc' }],
      }),
    ]);

    return {
      outletId,
      costingMethod: setting?.costingMethod ?? null,
      costingMethodDefined: Boolean(setting),
      version: setting?.version ?? null,
      expenseCategoryCount: categories.length,
      expenseCategoriesDefined: categories.length > 0,
      expenseCategories: categories.map((category) => this.toCategory(category)),
    };
  }

  async updateCosting(
    outletId: string,
    dto: CostingUpdateDto,
    user: AuthenticatedUser,
  ): Promise<BookkeepingConfigurationResponse> {
    await this.requireOutlet(this.prisma, outletId, user.businessId);

    await this.prisma.bookkeepingSetting.upsert({
      where: { outletId },
      update: { costingMethod: dto.costingMethod, version: { increment: 1 } },
      create: {
        businessId: user.businessId,
        outletId,
        costingMethod: dto.costingMethod,
      },
    });

    return this.getConfiguration(outletId, user);
  }

  async listExpenseCategories(
    outletId: string,
    user: AuthenticatedUser,
  ): Promise<{ items: ExpenseCategoryResponse[] }> {
    await this.requireOutlet(this.prisma, outletId, user.businessId);
    const categories = await this.prisma.expenseCategory.findMany({
      where: { businessId: user.businessId, active: true },
      orderBy: [{ name: 'asc' }, { id: 'asc' }],
    });

    return { items: categories.map((category) => this.toCategory(category)) };
  }

  async createExpenseCategory(
    outletId: string,
    dto: ExpenseCategoryCreateDto,
    user: AuthenticatedUser,
  ): Promise<ExpenseCategoryResponse> {
    await this.requireOutlet(this.prisma, outletId, user.businessId);

    try {
      const category = await this.prisma.expenseCategory.create({
        data: { businessId: user.businessId, name: dto.name },
      });
      return this.toCategory(category);
    } catch (error) {
      if (error instanceof Prisma.PrismaClientKnownRequestError && error.code === 'P2002') {
        throw apiError(409, 'EXPENSE_CATEGORY_EXISTS', 'An expense category with this name exists');
      }
      throw error;
    }
  }

  async listExpenses(
    outletId: string,
    query: ExpenseListQueryDto,
    user: AuthenticatedUser,
  ): Promise<ExpensePageResponse> {
    await this.requireOutlet(this.prisma, outletId, user.businessId);
    if (query.from && query.to) {
      assertRange(query.from, query.to);
    }

    const where: Prisma.ExpenseWhereInput = {
      businessId: user.businessId,
      outletId,
      ...(query.from || query.to
        ? {
            incurredOn: {
              ...(query.from ? { gte: dateOnlyUtc(query.from) } : {}),
              ...(query.to ? { lte: dateOnlyUtc(query.to) } : {}),
            },
          }
        : {}),
    };

    const rows = await this.prisma.expense.findMany({
      where,
      orderBy: [{ incurredOn: 'desc' }, { createdAt: 'desc' }, { id: 'desc' }],
      take: query.limit ?? 50,
      include: { category: { select: { name: true } } },
    });

    return {
      items: rows.map((row) => ({
        id: row.id,
        outletId: row.outletId,
        categoryId: row.categoryId,
        categoryName: row.category.name,
        amountMinor: positiveWire(row.amountMinor, 'amountMinor'),
        incurredOn: row.incurredOn.toISOString().slice(0, 10),
        note: row.note,
        createdById: row.createdById,
        createdAt: row.createdAt.toISOString(),
      })),
    };
  }

  async createExpense(
    outletId: string,
    dto: ExpenseCreateDto,
    user: AuthenticatedUser,
  ): Promise<ExpenseResponse> {
    await this.requireOutlet(this.prisma, outletId, user.businessId);
    const amount = BigInt(dto.amountMinor);
    positiveWire(amount, 'amountMinor');
    const category = await this.prisma.expenseCategory.findFirst({
      where: { id: dto.categoryId, businessId: user.businessId, active: true },
      select: { id: true, name: true },
    });

    if (!category) {
      throw apiError(404, 'NOT_FOUND', 'Expense category not found');
    }

    const expense = await this.prisma.expense.create({
      data: {
        businessId: user.businessId,
        outletId,
        categoryId: category.id,
        amountMinor: amount,
        incurredOn: dateOnlyUtc(dto.incurredOn),
        note: dto.note ?? '',
        createdById: user.id,
      },
    });

    return {
      id: expense.id,
      outletId: expense.outletId,
      categoryId: category.id,
      categoryName: category.name,
      amountMinor: positiveWire(expense.amountMinor, 'amountMinor'),
      incurredOn: expense.incurredOn.toISOString().slice(0, 10),
      note: expense.note,
      createdById: expense.createdById,
      createdAt: expense.createdAt.toISOString(),
    };
  }

  async getProfitReport(
    outletId: string,
    query: ReportRangeQueryDto,
    user: AuthenticatedUser,
  ): Promise<ProfitReportResponse> {
    const outlet = await this.requireOutlet(this.prisma, outletId, user.businessId);
    const report = await this.reports.dailyReport(outletId, query, user);
    assertRange(query.from, query.to);

    const [setting, categories, expenses] = await Promise.all([
      this.prisma.bookkeepingSetting.findUnique({ where: { outletId } }),
      this.prisma.expenseCategory.findMany({
        where: { businessId: user.businessId, active: true },
        orderBy: [{ name: 'asc' }, { id: 'asc' }],
      }),
      this.prisma.expense.findMany({
        where: {
          businessId: user.businessId,
          outletId,
          incurredOn: { gte: dateOnlyUtc(query.from), lte: dateOnlyUtc(query.to) },
        },
        include: { category: { select: { id: true, name: true } } },
      }),
    ]);

    const manualExpenses = expenses.reduce((sum, expense) => sum + expense.amountMinor, 0n);
    const categoryTotals = new Map<string, { name: string; amountMinor: bigint }>();
    for (const expense of expenses) {
      const previous = categoryTotals.get(expense.categoryId);
      categoryTotals.set(expense.categoryId, {
        name: expense.category.name,
        amountMinor: (previous?.amountMinor ?? 0n) + expense.amountMinor,
      });
    }

    const unavailableReasons: string[] = [];
    if (!setting) {
      unavailableReasons.push('COSTING_METHOD_UNDEFINED');
    }
    if (categories.length === 0) {
      unavailableReasons.push('EXPENSE_CATEGORIES_UNDEFINED');
    }

    let periodCosts: CostPeriod | null = null;
    if (setting) {
      periodCosts = await this.computePeriodCosts(outlet, query, setting.costingMethod);
      if (periodCosts.missingStockItemIds.length > 0) {
        unavailableReasons.push('INVENTORY_COST_UNDEFINED');
      }
    }

    const wasteMinor = periodCosts?.wasteMinor ?? 0n;
    const breakdown: ExpenseBreakdownResponse[] = [...categoryTotals.entries()]
      .map(([categoryId, value]) => ({
        categoryId,
        name: value.name,
        amountMinor: positiveWire(value.amountMinor, 'expenseBreakdown'),
        derived: false,
      }))
      .sort((a, b) => b.amountMinor - a.amountMinor || (a.name < b.name ? -1 : 1));

    if (periodCosts?.wasteMinor !== null && periodCosts?.wasteMinor !== undefined) {
      breakdown.push({
        categoryId: null,
        name: 'Inventory waste (derived from stock waste at cost)',
        amountMinor: positiveWire(periodCosts.wasteMinor, 'wasteExpense'),
        derived: true,
      });
    }

    const totalExpensesMinor = manualExpenses + wasteMinor;
    const marginAvailable =
      unavailableReasons.length === 0 &&
      periodCosts !== null &&
      periodCosts.cogsMinor !== null &&
      periodCosts.reversalCogsMinor !== null;

    const netItemSalesMinor = BigInt(report.netItemSalesMinor);
    const cogsMinor = marginAvailable ? (periodCosts?.cogsMinor ?? 0n) : null;
    const reversalCogsMinor = marginAvailable ? (periodCosts?.reversalCogsMinor ?? 0n) : null;
    const netCogsMinor =
      cogsMinor !== null && reversalCogsMinor !== null ? cogsMinor - reversalCogsMinor : null;
    const grossProfitMinor =
      marginAvailable && netCogsMinor !== null ? netItemSalesMinor - netCogsMinor : null;
    const netProfitMinor = grossProfitMinor !== null ? grossProfitMinor - totalExpensesMinor : null;
    const bps = netProfitMinor !== null ? marginBps(netProfitMinor, netItemSalesMinor) : null;

    return {
      from: query.from,
      to: query.to,
      timezone: report.timezone,
      currency: report.currency,
      currencyExponent: report.currencyExponent,
      generatedAt: new Date().toISOString(),
      marginAvailable,
      unavailableReasons,
      costingMethod: setting?.costingMethod ?? null,
      revenue: {
        grossItemSalesMinor: report.grossItemSalesMinor,
        reversalItemValueMinor: report.reversalItemValueMinor,
        netItemSalesMinor: report.netItemSalesMinor,
        saleCount: report.saleCount,
        reversalCount: report.reversalCount,
      },
      cogs:
        cogsMinor !== null && reversalCogsMinor !== null && netCogsMinor !== null
          ? {
              saleCostMinor: positiveWire(cogsMinor, 'saleCostMinor'),
              reversalRestockCreditMinor: positiveWire(
                reversalCogsMinor,
                'reversalRestockCreditMinor',
              ),
              netCogsMinor: signedWire(netCogsMinor, 'netCogsMinor'),
            }
          : null,
      waste:
        periodCosts?.wasteMinor !== null && periodCosts?.wasteMinor !== undefined
          ? { costMinor: positiveWire(periodCosts.wasteMinor, 'wasteCostMinor') }
          : null,
      expenses: {
        manualMinor: positiveWire(manualExpenses, 'manualExpensesMinor'),
        wasteMinor: positiveWire(wasteMinor, 'wasteExpensesMinor'),
        totalMinor: positiveWire(totalExpensesMinor, 'totalExpensesMinor'),
        breakdown,
      },
      grossProfitMinor:
        grossProfitMinor === null ? null : signedWire(grossProfitMinor, 'grossProfitMinor'),
      netProfitMinor: netProfitMinor === null ? null : signedWire(netProfitMinor, 'netProfitMinor'),
      netMarginBps: bps,
      marginBpsUnavailableReason: bps === null && marginAvailable ? 'ZERO_REVENUE' : null,
    };
  }

  async getConsolidated(
    outletId: string,
    query: ReportRangeQueryDto,
    user: AuthenticatedUser,
  ): Promise<ConsolidatedResponse> {
    await this.requireOutlet(this.prisma, outletId, user.businessId);
    assertRange(query.from, query.to);

    const outlets =
      user.outletIds.length === 0
        ? []
        : await this.prisma.outlet.findMany({
            where: { id: { in: user.outletIds }, businessId: user.businessId },
            orderBy: [{ name: 'asc' }, { id: 'asc' }],
            select: {
              id: true,
              name: true,
              businessId: true,
              timezone: true,
              currency: true,
              currencyExponent: true,
            },
          });

    const generatedAt = new Date().toISOString();
    const perOutlet: ConsolidatedOutletResponse[] = [];
    const settings = await this.prisma.bookkeepingSetting.findMany({
      where: { outletId: { in: outlets.map((outlet) => outlet.id) } },
      select: { outletId: true, costingMethod: true },
    });
    const methodByOutlet = new Map(settings.map((row) => [row.outletId, row.costingMethod]));

    for (const outlet of outlets) {
      const report = await this.reports.dailyReport(outlet.id, query, user);
      const range = localDateRangeUtc(query.from, query.to, outlet.timezone);
      const rangeEnd = range.lt ?? new Date();
      const [stockValue, shifts, attendance] = await Promise.all([
        this.stockValueForOutlet(outlet, methodByOutlet.get(outlet.id), rangeEnd),
        this.prisma.shift.findMany({
          where: { outletId: outlet.id, businessId: user.businessId, openedAt: range },
          select: { status: true },
        }),
        this.prisma.attendanceRecord.count({
          where: {
            outletId: outlet.id,
            businessId: user.businessId,
            clockInAt: range,
          },
        }),
      ]);

      perOutlet.push({
        outletId: outlet.id,
        outletName: outlet.name,
        timezone: outlet.timezone,
        currency: outlet.currency,
        currencyExponent: outlet.currencyExponent,
        grossItemSalesMinor: report.grossItemSalesMinor,
        reversalItemValueMinor: report.reversalItemValueMinor,
        netItemSalesMinor: report.netItemSalesMinor,
        refundMoneyMinor: report.refundMoneyMinor,
        saleCount: report.saleCount,
        reversalCount: report.reversalCount,
        averageBillMinor: report.averageBillMinor,
        paymentBreakdown: report.paymentBreakdown.map((row) => ({
          kind: row.kind,
          receivedMinor: row.receivedMinor,
        })),
        stockValueMinor: stockValue.valueMinor,
        stockValueUnavailableReason: stockValue.reason,
        shiftsOpened: shifts.length,
        shiftsClosed: shifts.filter((shift) => shift.status === 'CLOSED').length,
        attendanceClockIns: attendance,
      });
    }

    const currency = perOutlet[0]?.currency ?? null;
    const currencyExponent = perOutlet[0]?.currencyExponent ?? null;
    const currencyConsistent = perOutlet.every(
      (outlet) => outlet.currency === currency && outlet.currencyExponent === currencyExponent,
    );

    const sum = (pick: (outlet: ConsolidatedOutletResponse) => number): bigint =>
      perOutlet.reduce((total, outlet) => total + BigInt(pick(outlet)), 0n);
    const grossItemSalesMinor = sum((outlet) => outlet.grossItemSalesMinor);
    const saleCount = sum((outlet) => outlet.saleCount);
    const averageBillMinor =
      saleCount === 0n ? 0n : (grossItemSalesMinor * 2n + saleCount) / (saleCount * 2n);
    const paymentKinds = ['CASH', 'MANUAL_EXTERNAL', 'ONLINE'];
    const paymentBreakdown = paymentKinds.map((kind) => ({
      kind,
      receivedMinor: positiveWire(
        perOutlet.reduce(
          (total, outlet) =>
            total +
            BigInt(outlet.paymentBreakdown.find((row) => row.kind === kind)?.receivedMinor ?? 0),
          0n,
        ),
        'paymentBreakdown',
      ),
    }));
    const stockValues = perOutlet.map((outlet) => outlet.stockValueMinor);
    const stockValueUnavailable = perOutlet.find((outlet) => outlet.stockValueMinor === null);
    const stockValueMinor = stockValueUnavailable
      ? null
      : positiveWire(
          stockValues.reduce((total, value) => total + BigInt(value ?? 0), 0n),
          'stockValueMinor',
        );

    const reasons: string[] = [];
    if (!currencyConsistent) {
      reasons.push('CURRENCY_MISMATCH');
    }
    if (stockValueUnavailable) {
      reasons.push('INVENTORY_COST_UNDEFINED');
    }

    return {
      from: query.from,
      to: query.to,
      generatedAt,
      outletCount: perOutlet.length,
      currency,
      currencyExponent,
      currencyConsistent,
      perOutlet,
      consolidated: {
        grossItemSalesMinor: positiveWire(grossItemSalesMinor, 'grossItemSalesMinor'),
        reversalItemValueMinor: positiveWire(
          sum((outlet) => outlet.reversalItemValueMinor),
          'reversalItemValueMinor',
        ),
        netItemSalesMinor: signedWire(
          perOutlet.reduce((total, outlet) => total + BigInt(outlet.netItemSalesMinor), 0n),
          'netItemSalesMinor',
        ),
        refundMoneyMinor: positiveWire(
          sum((outlet) => outlet.refundMoneyMinor),
          'refundMoneyMinor',
        ),
        saleCount: positiveWire(saleCount, 'saleCount'),
        reversalCount: positiveWire(
          sum((outlet) => outlet.reversalCount),
          'reversalCount',
        ),
        averageBillMinor: positiveWire(averageBillMinor, 'averageBillMinor'),
        paymentBreakdown,
        stockValueMinor,
        stockValueUnavailableReason: stockValueUnavailable ? reasons.join('|') : null,
        shiftsOpened: positiveWire(
          sum((outlet) => outlet.shiftsOpened),
          'shiftsOpened',
        ),
        shiftsClosed: positiveWire(
          sum((outlet) => outlet.shiftsClosed),
          'shiftsClosed',
        ),
        attendanceClockIns: positiveWire(
          sum((outlet) => outlet.attendanceClockIns),
          'attendanceClockIns',
        ),
      },
    };
  }

  async exportSalesCsv(
    outletId: string,
    query: ReportRangeQueryDto,
    user: AuthenticatedUser,
  ): Promise<ExportFile> {
    const exported = await this.reports.exportCsv(outletId, query, user);
    return { filename: exported.filename, csv: exported.csv };
  }

  async exportReversalsCsv(
    outletId: string,
    query: ReportRangeQueryDto,
    user: AuthenticatedUser,
  ): Promise<ExportFile> {
    const outlet = await this.requireOutlet(this.prisma, outletId, user.businessId);
    assertRange(query.from, query.to);
    const range = localDateRangeUtc(query.from, query.to, outlet.timezone);
    const generatedAt = new Date().toISOString();
    const rows = await this.prisma.saleReversal.findMany({
      where: { businessId: user.businessId, outletId, createdAt: range },
      orderBy: [{ createdAt: 'desc' }, { id: 'desc' }],
      include: {
        sale: {
          select: {
            reference: true,
            currency: true,
            currencyExponent: true,
            timezone: true,
            subtotalMinor: true,
            lines: { select: { name: true, variantName: true, quantity: true } },
          },
        },
        refundLines: {
          select: {
            quantity: true,
            saleLine: { select: { name: true, variantName: true } },
          },
        },
        actor: { select: { email: true } },
      },
    });

    const csvRows = rows.map((reversal) => {
      const refundedItems =
        reversal.kind === 'PARTIAL'
          ? reversal.refundLines
              .map((line) => `${line.saleLine.name}/${line.saleLine.variantName} x${line.quantity}`)
              .join(' | ')
          : reversal.sale.lines
              .map((line) => `${line.name}/${line.variantName} x${line.quantity}`)
              .join(' | ');
      const refundMoneyMinor =
        reversal.kind === 'PARTIAL' ? reversal.refundMinor : reversal.sale.subtotalMinor;

      return [
        reversal.id,
        reversal.sale.reference,
        reversal.kind,
        reversal.createdAt.toISOString(),
        formatLocalTimestamp(reversal.createdAt, outlet.timezone),
        outlet.timezone,
        reversal.reason,
        signedWire(refundMoneyMinor, 'refundMoneyMinor'),
        reversal.sale.currency,
        reversal.sale.currencyExponent,
        refundedItems,
        JSON.stringify(reversal.restock),
        reversal.actor.email,
        query.from,
        query.to,
        generatedAt,
      ];
    });

    return {
      filename: `reversals-${slug(outlet.name)}-${query.from}-to-${query.to}.csv`,
      csv: buildCsv(
        [
          'reference',
          'saleReference',
          'kind',
          'createdAtUtc',
          'createdAtLocal',
          'timezone',
          'reason',
          'refundMoneyMinor',
          'currency',
          'currencyExponent',
          'refundedItems',
          'restockJson',
          'actorEmail',
          'reportFrom',
          'reportTo',
          'generatedAt',
        ],
        csvRows,
      ),
    };
  }

  async exportPaymentsCsv(
    outletId: string,
    query: ReportRangeQueryDto,
    user: AuthenticatedUser,
  ): Promise<ExportFile> {
    const outlet = await this.requireOutlet(this.prisma, outletId, user.businessId);
    assertRange(query.from, query.to);
    const range = localDateRangeUtc(query.from, query.to, outlet.timezone);
    const generatedAt = new Date().toISOString();
    const sales = await this.prisma.sale.findMany({
      where: {
        businessId: user.businessId,
        outletId,
        state: 'COMPLETED',
        completedAt: range,
      },
      orderBy: [{ completedAt: 'desc' }, { id: 'desc' }],
      include: { payment: true },
    });

    const csvRows = sales.map((sale) => {
      if (!sale.payment) {
        throw apiError(500, 'SALE_CORRUPT', 'Sale is missing its payment record');
      }

      return [
        sale.payment.id,
        sale.reference,
        sale.payment.kind,
        sale.payment.status,
        sale.completedAt.toISOString(),
        formatLocalTimestamp(sale.completedAt, outlet.timezone),
        outlet.timezone,
        sale.currency,
        sale.currencyExponent,
        positiveWire(sale.payment.amountMinor, 'amountMinor'),
        sale.payment.tenderedMinor === null
          ? null
          : positiveWire(sale.payment.tenderedMinor, 'tenderedMinor'),
        sale.payment.changeMinor === null
          ? null
          : positiveWire(sale.payment.changeMinor, 'changeMinor'),
        sale.payment.reference,
        positiveWire(sale.totalMinor, 'saleTotalMinor'),
        sale.payment.kind === 'ONLINE' &&
        !['SUCCEEDED', 'PARTIALLY_REFUNDED', 'REFUNDED'].includes(sale.payment.status)
          ? 'false'
          : 'true',
        sale.payment.kind === 'ONLINE' &&
        !['SUCCEEDED', 'PARTIALLY_REFUNDED', 'REFUNDED'].includes(sale.payment.status)
          ? 0
          : positiveWire(sale.payment.amountMinor, 'amountMinor'),
        query.from,
        query.to,
        generatedAt,
      ];
    });

    return {
      filename: `payments-${slug(outlet.name)}-${query.from}-to-${query.to}.csv`,
      csv: buildCsv(
        [
          'paymentId',
          'saleReference',
          'kind',
          'status',
          'completedAtUtc',
          'completedAtLocal',
          'timezone',
          'currency',
          'currencyExponent',
          'amountMinor',
          'tenderedMinor',
          'changeMinor',
          'paymentReference',
          'saleTotalMinor',
          'countsAsReportedReceived',
          'reportReceivedMinor',
          'reportFrom',
          'reportTo',
          'generatedAt',
        ],
        csvRows,
      ),
    };
  }

  async exportAccountingCsv(
    outletId: string,
    query: ReportRangeQueryDto,
    user: AuthenticatedUser,
  ): Promise<ExportFile> {
    const outlet = await this.requireOutlet(this.prisma, outletId, user.businessId);
    const profit = await this.getProfitReport(outletId, query, user);

    const row = [
      outlet.id,
      outlet.name,
      profit.from,
      profit.to,
      profit.timezone,
      profit.currency,
      profit.currencyExponent,
      profit.generatedAt,
      profit.costingMethod,
      profit.marginAvailable ? 'true' : 'false',
      profit.unavailableReasons.join('|'),
      profit.revenue.grossItemSalesMinor,
      profit.revenue.reversalItemValueMinor,
      profit.revenue.netItemSalesMinor,
      profit.revenue.saleCount,
      profit.revenue.reversalCount,
      profit.cogs === null ? null : profit.cogs.saleCostMinor,
      profit.cogs === null ? null : profit.cogs.reversalRestockCreditMinor,
      profit.cogs === null ? null : profit.cogs.netCogsMinor,
      profit.waste === null ? null : profit.waste.costMinor,
      profit.expenses.manualMinor,
      profit.expenses.wasteMinor,
      profit.expenses.totalMinor,
      profit.grossProfitMinor,
      profit.netProfitMinor,
      profit.netMarginBps,
    ];

    return {
      filename: `accounting-${slug(outlet.name)}-${query.from}-to-${query.to}.csv`,
      csv: buildCsv(
        [
          'outletId',
          'outletName',
          'reportFrom',
          'reportTo',
          'timezone',
          'currency',
          'currencyExponent',
          'generatedAt',
          'costingMethod',
          'marginAvailable',
          'unavailableReasons',
          'grossItemSalesMinor',
          'reversalItemValueMinor',
          'netItemSalesMinor',
          'saleCount',
          'reversalCount',
          'saleCostMinor',
          'reversalRestockCreditMinor',
          'netCogsMinor',
          'wasteCostMinor',
          'manualExpenseMinor',
          'wasteExpenseMinor',
          'totalExpenseMinor',
          'grossProfitMinor',
          'netProfitMinor',
          'netMarginBps',
        ],
        [row],
      ),
    };
  }

  private async computePeriodCosts(
    outlet: OutletRecord,
    query: ReportRangeQueryDto,
    method: CostingMethod,
  ): Promise<CostPeriod> {
    const range = localDateRangeUtc(query.from, query.to, outlet.timezone);
    const rangeEnd = range.lt ?? new Date();
    const movements = (await this.prisma.stockMovement.findMany({
      where: {
        outletId: outlet.id,
        type: {
          in: [StockMovementType.SALE, StockMovementType.REVERSAL, StockMovementType.WASTE],
        },
        createdAt: range,
      },
      select: { stockItemId: true, delta: true, type: true },
    })) as CostedMovement[];

    const stockItemIds = [...new Set(movements.map((movement) => movement.stockItemId))];
    if (stockItemIds.length === 0) {
      return { cogsMinor: 0n, reversalCogsMinor: 0n, wasteMinor: 0n, missingStockItemIds: [] };
    }

    const costs = await this.loadUnitCosts(this.prisma, outlet.id, stockItemIds, rangeEnd, method);

    if (costs.missingStockItemIds.length > 0) {
      return {
        cogsMinor: null,
        reversalCogsMinor: null,
        wasteMinor: null,
        missingStockItemIds: costs.missingStockItemIds,
      };
    }

    let cogsMinor = 0n;
    let reversalCogsMinor = 0n;
    let wasteMinor = 0n;

    for (const movement of movements) {
      const unitCost = costs.costs.get(movement.stockItemId);
      if (unitCost === undefined) {
        continue;
      }

      const quantity = quantityMicros(movement.delta.abs());

      if (movement.type === StockMovementType.SALE) {
        cogsMinor += costForQuantityMicros(quantity, unitCost);
      } else if (movement.type === StockMovementType.REVERSAL) {
        reversalCogsMinor += costForQuantityMicros(quantity, unitCost);
      } else {
        wasteMinor += costForQuantityMicros(quantity, unitCost);
      }
    }

    return {
      cogsMinor,
      reversalCogsMinor,
      wasteMinor,
      missingStockItemIds: [],
    };
  }

  private async stockValueForOutlet(
    outlet: OutletRecord,
    method: CostingMethod | undefined,
    until: Date,
  ): Promise<{ valueMinor: number | null; reason: string | null }> {
    if (!method) {
      return { valueMinor: null, reason: 'COSTING_METHOD_UNDEFINED' };
    }

    const balances = await this.prisma.stockBalance.findMany({
      where: { outletId: outlet.id, quantity: { gt: 0 } },
      select: { stockItemId: true, quantity: true },
    });

    if (balances.length === 0) {
      return { valueMinor: 0, reason: null };
    }

    const costs = await this.loadUnitCosts(
      this.prisma,
      outlet.id,
      balances.map((balance) => balance.stockItemId),
      until,
      method,
    );

    if (costs.missingStockItemIds.length > 0) {
      return { valueMinor: null, reason: 'INVENTORY_COST_UNDEFINED' };
    }

    const total = balances.reduce(
      (sum, balance) =>
        sum +
        costForQuantityMicros(
          quantityMicros(balance.quantity),
          costs.costs.get(balance.stockItemId) ?? 0n,
        ),
      0n,
    );

    return { valueMinor: positiveWire(total, 'stockValueMinor'), reason: null };
  }

  private async loadUnitCosts(
    client: Prisma.TransactionClient | PrismaService,
    outletId: string,
    stockItemIds: string[],
    until: Date,
    method: CostingMethod,
  ): Promise<{ costs: Map<string, bigint>; missingStockItemIds: string[] }> {
    const receipts = await client.stockMovement.findMany({
      where: {
        outletId,
        stockItemId: { in: stockItemIds },
        type: StockMovementType.RECEIPT,
        purchaseOrderId: { not: null },
        createdAt: { lt: until },
      },
      orderBy: [{ createdAt: 'asc' }, { id: 'asc' }],
      select: { stockItemId: true, delta: true, sourceId: true },
    });

    const lineIds = [...new Set(receipts.map((receipt) => receipt.sourceId))];
    const lines =
      lineIds.length === 0
        ? []
        : await client.purchaseOrderLine.findMany({
            where: { id: { in: lineIds } },
            select: {
              id: true,
              stockItemId: true,
              unitPrice: true,
              unitsPerSupplierUnit: true,
            },
          });
    const lineById = new Map(lines.map((line) => [line.id, line]));
    const eventsByItem = new Map<string, ReceiptCostEvent[]>();

    for (const receipt of receipts) {
      const line = lineById.get(receipt.sourceId);
      if (!line || line.stockItemId !== receipt.stockItemId) {
        continue;
      }

      const events = eventsByItem.get(receipt.stockItemId) ?? [];
      events.push({
        quantityMicros: quantityMicros(receipt.delta),
        valueMicros: receiptValueMicros(receipt.delta, line.unitPrice, line.unitsPerSupplierUnit),
      });
      eventsByItem.set(receipt.stockItemId, events);
    }

    const costs = new Map<string, bigint>();
    const missingStockItemIds: string[] = [];

    for (const stockItemId of stockItemIds) {
      const unitCost = resolveUnitCostMicros(method, eventsByItem.get(stockItemId) ?? []);
      if (unitCost === null) {
        missingStockItemIds.push(stockItemId);
      } else {
        costs.set(stockItemId, unitCost);
      }
    }

    return { costs, missingStockItemIds };
  }

  private toCategory(category: {
    id: string;
    name: string;
    active: boolean;
    createdAt: Date;
  }): ExpenseCategoryResponse {
    return {
      id: category.id,
      name: category.name,
      active: category.active,
      createdAt: category.createdAt.toISOString(),
    };
  }

  private async requireOutlet(
    client: Prisma.TransactionClient | PrismaService,
    outletId: string,
    businessId: string,
  ): Promise<OutletRecord> {
    const outlet = await client.outlet.findFirst({
      where: { id: outletId, businessId },
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

    return outlet;
  }
}
