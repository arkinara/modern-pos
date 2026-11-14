'use client';

import type { ApiSchemas } from '@modern-pos/api-client';
import { useQuery } from '@tanstack/react-query';
import { AlertTriangle, BookOpen, Download, RefreshCw } from 'lucide-react';
import { useEffect, useState } from 'react';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { api } from '@/lib/api';
import { apiErrorCode, describeReportError } from '@/lib/api-errors';
import { useActiveOutletId } from '@/lib/use-active-outlet';
import { useAuth } from '@/lib/auth';
import {
  formatDateTimeInZone,
  formatMoney,
  formatQuantity,
  todayInTimeZone,
} from '@/lib/reporting';

type ProfitReport = ApiSchemas['ProfitReport'];
type ConsolidatedReport = ApiSchemas['ConsolidatedReport'];

const inputClass =
  'h-12 w-full rounded-control border border-control bg-surface px-3 text-sm text-text';
const selectClass =
  'h-12 w-full rounded-control border border-control bg-surface px-3 text-sm text-text';

const REASON_LABELS: Record<string, string> = {
  COSTING_METHOD_UNDEFINED: 'Choose an inventory costing method before margin is calculated.',
  EXPENSE_CATEGORIES_UNDEFINED: 'Define at least one expense category before margin is calculated.',
  INVENTORY_COST_UNDEFINED:
    'A consumed or stocked item has no purchase receipt cost inside the selected period.',
  CURRENCY_MISMATCH: 'The selected outlets do not share one currency and exponent.',
  ZERO_REVENUE: 'Margin percent is undefined when net revenue is zero.',
};

function reasonText(reason: string): string {
  return REASON_LABELS[reason] ?? reason;
}

function money(value: number | null, report: ProfitReport | undefined): string {
  if (value === null || !report) {
    return 'Unavailable';
  }
  return formatMoney(value, report.currency, report.currencyExponent);
}

function Metric({
  label,
  value,
  detail,
  unavailable = false,
}: {
  label: string;
  value: string;
  detail: string;
  unavailable?: boolean;
}) {
  return (
    <div className="rounded-surface border border-border bg-surface-tint p-4">
      <p className="text-xs font-medium uppercase tracking-[0.12em] text-muted">{label}</p>
      <p
        className={
          unavailable
            ? 'mt-2 text-lg font-semibold text-warning'
            : 'mt-2 text-2xl font-semibold tabular-nums text-text'
        }
      >
        {value}
      </p>
      <p className="mt-2 text-xs text-muted">{detail}</p>
    </div>
  );
}

function download(filename: string, csv: string): void {
  const blob = new Blob([csv], { type: 'text/csv;charset=utf-8' });
  const url = URL.createObjectURL(blob);
  const link = document.createElement('a');
  link.href = url;
  link.download = filename;
  document.body.append(link);
  link.click();
  link.remove();
  URL.revokeObjectURL(url);
}

export function BookkeepingScreen() {
  const outletId = useActiveOutletId();
  const { user } = useAuth();
  const isOwner = user?.role === 'OWNER';
  const [from, setFrom] = useState('');
  const [to, setTo] = useState('');
  const [costingMethod, setCostingMethod] = useState<'MOVING_AVERAGE' | 'LAST_PURCHASE'>(
    'MOVING_AVERAGE',
  );
  const [categoryName, setCategoryName] = useState('');
  const [expenseCategoryId, setExpenseCategoryId] = useState('');
  const [expenseAmount, setExpenseAmount] = useState('');
  const [expenseDate, setExpenseDate] = useState('');
  const [expenseNote, setExpenseNote] = useState('');
  const [pending, setPending] = useState<string | null>(null);
  const [message, setMessage] = useState<string | null>(null);
  const [actionError, setActionError] = useState<string | null>(null);

  const settingsQuery = useQuery({
    queryKey: ['settings', outletId],
    queryFn: () => api.getSettings(outletId as string),
    enabled: Boolean(outletId),
  });
  const timezone = settingsQuery.data?.timezone ?? 'UTC';

  useEffect(() => {
    if (!settingsQuery.data || from || to) {
      return;
    }
    const today = todayInTimeZone(settingsQuery.data.timezone);
    setFrom(today);
    setTo(today);
    setExpenseDate(today);
  }, [settingsQuery.data, from, to]);

  const configQuery = useQuery({
    queryKey: ['bookkeeping', outletId],
    queryFn: () => api.getBookkeeping(outletId as string),
    enabled: Boolean(outletId),
  });

  useEffect(() => {
    if (configQuery.data?.costingMethod) {
      setCostingMethod(configQuery.data.costingMethod);
    }
  }, [configQuery.data?.costingMethod]);

  const categoriesQuery = useQuery({
    queryKey: ['expense-categories', outletId],
    queryFn: () => api.listExpenseCategories(outletId as string),
    enabled: Boolean(outletId),
  });

  useEffect(() => {
    const first = categoriesQuery.data?.items[0];
    if (first && !expenseCategoryId) {
      setExpenseCategoryId(first.id);
    }
  }, [categoriesQuery.data?.items, expenseCategoryId]);

  const validRange = Boolean(from && to && from <= to);
  const profitQuery = useQuery({
    queryKey: ['profit-report', outletId, from, to],
    queryFn: () => api.getProfitReport(outletId as string, { from, to }),
    enabled: Boolean(outletId) && validRange,
  });
  const expensesQuery = useQuery({
    queryKey: ['expenses', outletId, from, to],
    queryFn: () => api.listExpenses(outletId as string, { from, to, limit: 25 }),
    enabled: Boolean(outletId) && validRange,
  });
  const consolidatedQuery = useQuery({
    queryKey: ['consolidated-report', outletId, from, to],
    queryFn: () => api.getConsolidatedReport(outletId as string, { from, to }),
    enabled: Boolean(outletId) && validRange && isOwner,
  });

  const report = profitQuery.data;
  const consolidated: ConsolidatedReport | undefined = consolidatedQuery.data;

  function clearFeedback(): void {
    setMessage(null);
    setActionError(null);
  }

  async function saveCosting(): Promise<void> {
    if (!outletId) {
      return;
    }
    clearFeedback();
    setPending('costing');
    try {
      await api.updateCostingMethod(outletId, costingMethod);
      await configQuery.refetch();
      await profitQuery.refetch();
      setMessage('Costing method saved. Profit recalculates from recorded receipts.');
    } catch (error) {
      setActionError(describeReportError(error, 'Could not save the costing method'));
    } finally {
      setPending(null);
    }
  }

  async function addCategory(): Promise<void> {
    if (!outletId || categoryName.trim().length < 2) {
      return;
    }
    clearFeedback();
    setPending('category');
    try {
      const category = await api.createExpenseCategory(outletId, { name: categoryName.trim() });
      setCategoryName('');
      setExpenseCategoryId(category.id);
      await categoriesQuery.refetch();
      await configQuery.refetch();
      await profitQuery.refetch();
      setMessage('Expense category added.');
    } catch (error) {
      const code = apiErrorCode(error);
      setActionError(
        code === 'EXPENSE_CATEGORY_EXISTS'
          ? 'That expense category already exists.'
          : describeReportError(error, 'Could not add the expense category'),
      );
    } finally {
      setPending(null);
    }
  }

  async function addExpense(): Promise<void> {
    if (!outletId || !expenseCategoryId || !expenseAmount || !expenseDate) {
      return;
    }
    clearFeedback();
    setPending('expense');
    try {
      await api.createExpense(outletId, {
        categoryId: expenseCategoryId,
        amountMinor: expenseAmount,
        incurredOn: expenseDate,
        ...(expenseNote.trim() ? { note: expenseNote.trim() } : {}),
      });
      setExpenseAmount('');
      setExpenseNote('');
      await expensesQuery.refetch();
      await profitQuery.refetch();
      setMessage('Expense recorded.');
    } catch (error) {
      setActionError(describeReportError(error, 'Could not record the expense'));
    } finally {
      setPending(null);
    }
  }

  async function exportDataset(
    dataset: 'sales' | 'reversals' | 'payments' | 'accounting',
  ): Promise<void> {
    if (!outletId || !validRange) {
      return;
    }
    clearFeedback();
    setPending(`export-${dataset}`);
    try {
      const exported = await api.exportBookkeepingCsv(outletId, dataset, { from, to });
      download(exported.filename, exported.csv);
      setMessage(`Downloaded ${exported.filename}`);
    } catch (error) {
      setActionError(describeReportError(error, `Could not export ${dataset}`));
    } finally {
      setPending(null);
    }
  }

  if (!outletId) {
    return (
      <Card>
        <CardHeader>
          <CardTitle>No outlet assigned</CardTitle>
          <CardDescription>Bookkeeping needs an outlet in your account scope.</CardDescription>
        </CardHeader>
      </Card>
    );
  }

  return (
    <div className="flex w-full max-w-7xl flex-col gap-6">
      <header>
        <h1 className="text-3xl font-semibold tracking-tight text-text">Bookkeeping</h1>
        <p className="mt-2 max-w-3xl text-sm text-muted">
          Costing method, operating expense categories, profit and margin, consolidated owner view,
          and auditable exports. Margin stays unavailable until costing and expense categories are
          defined; unavailable figures are never replaced with estimates.
        </p>
      </header>

      <Card>
        <CardHeader>
          <CardTitle>Report period</CardTitle>
          <CardDescription>
            Inclusive outlet-local dates. Revenue reuses the same daily-report calculation as the
            Reports screen. Timezone {timezone}.
          </CardDescription>
        </CardHeader>
        <CardContent className="flex flex-col gap-4">
          <div className="grid gap-4 sm:grid-cols-2 lg:max-w-2xl">
            <label className="flex flex-col gap-1 text-sm font-medium text-text">
              From
              <input
                type="date"
                className={inputClass}
                value={from}
                max={to || undefined}
                onChange={(event) => setFrom(event.target.value)}
              />
            </label>
            <label className="flex flex-col gap-1 text-sm font-medium text-text">
              To
              <input
                type="date"
                className={inputClass}
                value={to}
                min={from || undefined}
                onChange={(event) => setTo(event.target.value)}
              />
            </label>
          </div>
          {from && to && from > to ? (
            <p className="text-sm text-danger" role="alert">
              The start date must be on or before the end date.
            </p>
          ) : null}
          <div className="flex flex-wrap gap-2">
            {(
              [
                ['sales', 'Sales CSV'],
                ['reversals', 'Reversals CSV'],
                ['payments', 'Payments CSV'],
                ['accounting', 'Accounting CSV'],
              ] as const
            ).map(([dataset, label]) => (
              <Button
                key={dataset}
                variant="outline"
                size="sm"
                disabled={!validRange || pending !== null}
                onClick={() => void exportDataset(dataset)}
              >
                <Download aria-hidden="true" className="size-4" />
                {pending === `export-${dataset}` ? 'Exporting…' : label}
              </Button>
            ))}
          </div>
          {message ? (
            <p className="text-sm text-success" role="status">
              {message}
            </p>
          ) : null}
          {actionError ? (
            <p className="text-sm text-danger" role="alert">
              {actionError}
            </p>
          ) : null}
        </CardContent>
      </Card>

      {configQuery.isLoading ? (
        <Card>
          <CardContent className="pt-6" aria-busy="true">
            <div className="h-24 animate-pulse rounded-surface bg-surface-muted" />
            <span className="sr-only">Loading bookkeeping configuration</span>
          </CardContent>
        </Card>
      ) : configQuery.isError ? (
        <Card>
          <CardContent className="flex flex-col items-start gap-3 pt-6" role="alert">
            <p className="text-sm text-danger">
              {describeReportError(configQuery.error, 'Could not load bookkeeping settings')}
            </p>
            <Button variant="outline" onClick={() => configQuery.refetch()}>
              <RefreshCw aria-hidden="true" className="size-4" />
              Try again
            </Button>
          </CardContent>
        </Card>
      ) : (
        <div className="grid gap-6 lg:grid-cols-2">
          <Card className="min-w-0">
            <CardHeader>
              <CardTitle>Inventory costing</CardTitle>
              <CardDescription>
                Moving average weights every purchase receipt by base quantity. Last purchase uses
                the newest receipt at or before the report end. Money is integer minor units.
              </CardDescription>
            </CardHeader>
            <CardContent className="flex flex-col gap-3">
              <label className="flex flex-col gap-1 text-sm font-medium text-text">
                Costing method
                <select
                  className={selectClass}
                  value={costingMethod}
                  onChange={(event) =>
                    setCostingMethod(event.target.value as 'MOVING_AVERAGE' | 'LAST_PURCHASE')
                  }
                >
                  <option value="MOVING_AVERAGE">Moving average</option>
                  <option value="LAST_PURCHASE">Last purchase</option>
                </select>
              </label>
              <div className="flex items-center gap-3">
                <Button size="sm" onClick={() => void saveCosting()} disabled={pending !== null}>
                  {pending === 'costing' ? 'Saving…' : 'Save costing method'}
                </Button>
                <Badge tone={configQuery.data?.costingMethodDefined ? 'success' : 'warning'}>
                  {configQuery.data?.costingMethodDefined ? 'Defined' : 'Undefined'}
                </Badge>
              </div>
            </CardContent>
          </Card>

          <Card className="min-w-0">
            <CardHeader>
              <CardTitle>Expense categories</CardTitle>
              <CardDescription>
                Operating costs reduce margin. Inventory purchases are capitalised through costing,
                not double-counted as an operating expense. Stock waste is derived at cost.
              </CardDescription>
            </CardHeader>
            <CardContent className="flex flex-col gap-4">
              <div className="flex flex-wrap gap-2">
                {categoriesQuery.data?.items.length ? (
                  categoriesQuery.data.items.map((category) => (
                    <Badge key={category.id} tone="neutral">
                      {category.name}
                    </Badge>
                  ))
                ) : (
                  <p className="text-sm text-warning" role="status">
                    No expense categories defined. Margin remains unavailable.
                  </p>
                )}
              </div>
              <div className="flex flex-col gap-2 sm:flex-row">
                <input
                  className={inputClass}
                  placeholder="Category name"
                  value={categoryName}
                  onChange={(event) => setCategoryName(event.target.value)}
                  aria-label="New expense category"
                />
                <Button
                  size="sm"
                  className="sm:w-auto"
                  onClick={() => void addCategory()}
                  disabled={pending !== null || categoryName.trim().length < 2}
                >
                  {pending === 'category' ? 'Adding…' : 'Add category'}
                </Button>
              </div>
            </CardContent>
          </Card>
        </div>
      )}

      <Card>
        <CardHeader>
          <CardTitle>Record operating expense</CardTitle>
          <CardDescription>
            Manual expenses are stored in integer minor units for the outlet-local incurral date.
          </CardDescription>
        </CardHeader>
        <CardContent className="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
          <label className="flex flex-col gap-1 text-sm font-medium text-text">
            Category
            <select
              className={selectClass}
              value={expenseCategoryId}
              onChange={(event) => setExpenseCategoryId(event.target.value)}
            >
              <option value="">Select category</option>
              {(categoriesQuery.data?.items ?? []).map((category) => (
                <option key={category.id} value={category.id}>
                  {category.name}
                </option>
              ))}
            </select>
          </label>
          <label className="flex flex-col gap-1 text-sm font-medium text-text">
            Amount (minor units)
            <input
              inputMode="numeric"
              className={inputClass}
              value={expenseAmount}
              onChange={(event) => setExpenseAmount(event.target.value.replaceAll(/\D/g, ''))}
              placeholder="100000"
            />
          </label>
          <label className="flex flex-col gap-1 text-sm font-medium text-text">
            Incurred on
            <input
              type="date"
              className={inputClass}
              value={expenseDate}
              onChange={(event) => setExpenseDate(event.target.value)}
            />
          </label>
          <label className="flex flex-col gap-1 text-sm font-medium text-text">
            Note
            <input
              className={inputClass}
              value={expenseNote}
              onChange={(event) => setExpenseNote(event.target.value)}
              maxLength={500}
            />
          </label>
          <div className="md:col-span-2 xl:col-span-4">
            <Button
              size="sm"
              onClick={() => void addExpense()}
              disabled={pending !== null || !expenseCategoryId || !expenseAmount || !expenseDate}
            >
              {pending === 'expense' ? 'Recording…' : 'Record expense'}
            </Button>
          </div>
        </CardContent>
      </Card>

      {profitQuery.isLoading ? (
        <Card>
          <CardContent className="pt-6" aria-busy="true">
            <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
              <div className="h-28 animate-pulse rounded-surface bg-surface-muted" />
              <div className="h-28 animate-pulse rounded-surface bg-surface-muted" />
              <div className="h-28 animate-pulse rounded-surface bg-surface-muted" />
              <div className="h-28 animate-pulse rounded-surface bg-surface-muted" />
            </div>
            <span className="sr-only">Loading profit report</span>
          </CardContent>
        </Card>
      ) : profitQuery.isError ? (
        <Card>
          <CardContent className="flex flex-col items-start gap-3 pt-6" role="alert">
            <p className="text-sm text-danger">
              {describeReportError(profitQuery.error, 'Could not load the profit report')}
            </p>
            <Button variant="outline" onClick={() => profitQuery.refetch()}>
              <RefreshCw aria-hidden="true" className="size-4" />
              Try again
            </Button>
          </CardContent>
        </Card>
      ) : report ? (
        <>
          {!report.marginAvailable ? (
            <Card className="border-warning bg-warning-soft">
              <CardContent className="flex flex-col gap-2 pt-6" role="status">
                <p className="flex items-center gap-2 text-sm font-semibold text-warning">
                  <AlertTriangle aria-hidden="true" className="size-4" />
                  Profit and margin unavailable
                </p>
                <ul className="list-disc pl-5 text-sm text-warning">
                  {report.unavailableReasons.map((reason) => (
                    <li key={reason}>{reasonText(reason)}</li>
                  ))}
                </ul>
              </CardContent>
            </Card>
          ) : null}

          <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
            <Metric
              label="Net item sales"
              value={money(report.revenue.netItemSalesMinor, report)}
              detail="Gross item sales minus reversal item value from the daily-report calculation."
            />
            <Metric
              label="Net COGS"
              value={money(report.cogs?.netCogsMinor ?? null, report)}
              detail="Sale movement cost minus reversal restock credit, valued by the selected method."
              unavailable={report.cogs === null}
            />
            <Metric
              label="Operating expenses"
              value={money(report.expenses.totalMinor, report)}
              detail="Manual expenses plus stock waste valued at cost."
            />
            <Metric
              label="Net profit"
              value={money(report.netProfitMinor, report)}
              detail="Net item sales minus net COGS minus operating expenses."
              unavailable={report.netProfitMinor === null}
            />
          </div>

          <Card>
            <CardHeader>
              <CardTitle>Margin calculation</CardTitle>
              <CardDescription>
                Net margin = (net item sales − net COGS − operating expenses) ÷ net item sales.
                Rounded half up to basis points on integer minor units.
              </CardDescription>
            </CardHeader>
            <CardContent className="flex flex-col gap-3">
              <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
                <div>
                  <p className="text-xs uppercase tracking-[0.12em] text-muted">Net COGS</p>
                  <p className="mt-1 text-lg font-semibold tabular-nums text-text">
                    {money(report.cogs?.netCogsMinor ?? null, report)}
                  </p>
                </div>
                <div>
                  <p className="text-xs uppercase tracking-[0.12em] text-muted">Gross profit</p>
                  <p className="mt-1 text-lg font-semibold tabular-nums text-text">
                    {money(report.grossProfitMinor, report)}
                  </p>
                </div>
                <div>
                  <p className="text-xs uppercase tracking-[0.12em] text-muted">Net margin</p>
                  <p className="mt-1 text-lg font-semibold tabular-nums text-text">
                    {report.netMarginBps === null
                      ? report.marginBpsUnavailableReason
                        ? reasonText(report.marginBpsUnavailableReason)
                        : 'Unavailable'
                      : `${(report.netMarginBps / 100).toFixed(2)}%`}
                  </p>
                </div>
                <div>
                  <p className="text-xs uppercase tracking-[0.12em] text-muted">Costing method</p>
                  <p className="mt-1 text-lg font-semibold text-text">
                    {report.costingMethod ?? 'Undefined'}
                  </p>
                </div>
              </div>
              <div>
                <p className="text-xs font-medium uppercase tracking-[0.12em] text-muted">
                  Expense breakdown
                </p>
                <ul className="mt-2 divide-y divide-border text-sm">
                  {report.expenses.breakdown.length === 0 ? (
                    <li className="py-2 text-muted">No expenses in this period.</li>
                  ) : (
                    report.expenses.breakdown.map((row) => (
                      <li
                        key={`${row.categoryId ?? 'waste'}-${row.name}`}
                        className="flex flex-wrap items-center justify-between gap-2 py-2"
                      >
                        <span className="text-text">
                          {row.name}
                          {row.derived ? (
                            <span className="ml-2 text-xs text-muted">derived</span>
                          ) : null}
                        </span>
                        <span className="tabular-nums text-text">
                          {money(row.amountMinor, report)}
                        </span>
                      </li>
                    ))
                  )}
                </ul>
              </div>
              <p className="text-xs text-muted">
                Generated {formatDateTimeInZone(report.generatedAt, report.timezone)} · range{' '}
                {report.from} to {report.to} · {report.revenue.saleCount} completed sale(s),{' '}
                {report.revenue.reversalCount} reversal(s).
              </p>
            </CardContent>
          </Card>
        </>
      ) : null}

      {isOwner ? (
        <Card>
          <CardHeader>
            <CardTitle>Consolidated owner view</CardTitle>
            <CardDescription>
              Consolidated = sum of per-outlet rows from the same daily-report numbers. Average bill
              uses combined gross item sales ÷ combined completed sale count.
            </CardDescription>
          </CardHeader>
          <CardContent>
            {consolidatedQuery.isLoading ? (
              <div className="h-32 animate-pulse rounded-surface bg-surface-muted" aria-busy="true">
                <span className="sr-only">Loading consolidated view</span>
              </div>
            ) : consolidatedQuery.isError ? (
              <div className="flex flex-col items-start gap-3" role="alert">
                <p className="text-sm text-danger">
                  {describeReportError(
                    consolidatedQuery.error,
                    'Could not load the consolidated view',
                  )}
                </p>
                <Button variant="outline" onClick={() => consolidatedQuery.refetch()}>
                  <RefreshCw aria-hidden="true" className="size-4" />
                  Try again
                </Button>
              </div>
            ) : consolidated ? (
              <div className="flex flex-col gap-4">
                {consolidated.outletCount === 0 ? (
                  <p className="text-sm text-muted">
                    No outlets are in scope. All consolidated totals are zero.
                  </p>
                ) : null}
                <div className="overflow-x-auto">
                  <table className="w-full min-w-[720px] border-collapse text-sm">
                    <thead>
                      <tr className="border-b border-border text-left text-xs uppercase tracking-[0.12em] text-muted">
                        <th className="py-2 pr-3 font-medium">Outlet</th>
                        <th className="py-2 pr-3 font-medium">Gross</th>
                        <th className="py-2 pr-3 font-medium">Net sales</th>
                        <th className="py-2 pr-3 font-medium">Sales</th>
                        <th className="py-2 pr-3 font-medium">Stock value</th>
                        <th className="py-2 pr-3 font-medium">Shifts</th>
                        <th className="py-2 pr-3 font-medium">Clock-ins</th>
                      </tr>
                    </thead>
                    <tbody>
                      {consolidated.perOutlet.map((row) => (
                        <tr key={row.outletId} className="border-b border-border/70">
                          <td className="py-2 pr-3 font-medium text-text">{row.outletName}</td>
                          <td className="py-2 pr-3 tabular-nums">
                            {formatMoney(
                              row.grossItemSalesMinor,
                              row.currency,
                              row.currencyExponent,
                            )}
                          </td>
                          <td className="py-2 pr-3 tabular-nums">
                            {formatMoney(row.netItemSalesMinor, row.currency, row.currencyExponent)}
                          </td>
                          <td className="py-2 pr-3 tabular-nums">{row.saleCount}</td>
                          <td className="py-2 pr-3 tabular-nums">
                            {row.stockValueMinor === null
                              ? 'Unavailable'
                              : formatMoney(
                                  row.stockValueMinor,
                                  row.currency,
                                  row.currencyExponent,
                                )}
                          </td>
                          <td className="py-2 pr-3 tabular-nums">
                            {row.shiftsOpened} / {row.shiftsClosed}
                          </td>
                          <td className="py-2 pr-3 tabular-nums">{row.attendanceClockIns}</td>
                        </tr>
                      ))}
                      <tr className="font-semibold text-text">
                        <td className="py-3 pr-3">Consolidated</td>
                        <td className="py-3 pr-3 tabular-nums">
                          {consolidated.currency
                            ? formatMoney(
                                consolidated.consolidated.grossItemSalesMinor,
                                consolidated.currency,
                                consolidated.currencyExponent ?? 0,
                              )
                            : '0'}
                        </td>
                        <td className="py-3 pr-3 tabular-nums">
                          {consolidated.currency
                            ? formatMoney(
                                consolidated.consolidated.netItemSalesMinor,
                                consolidated.currency,
                                consolidated.currencyExponent ?? 0,
                              )
                            : '0'}
                        </td>
                        <td className="py-3 pr-3 tabular-nums">
                          {consolidated.consolidated.saleCount}
                        </td>
                        <td className="py-3 pr-3 tabular-nums">
                          {consolidated.consolidated.stockValueMinor === null
                            ? 'Unavailable'
                            : consolidated.currency
                              ? formatMoney(
                                  consolidated.consolidated.stockValueMinor,
                                  consolidated.currency,
                                  consolidated.currencyExponent ?? 0,
                                )
                              : '0'}
                        </td>
                        <td className="py-3 pr-3 tabular-nums">
                          {consolidated.consolidated.shiftsOpened} /{' '}
                          {consolidated.consolidated.shiftsClosed}
                        </td>
                        <td className="py-3 pr-3 tabular-nums">
                          {consolidated.consolidated.attendanceClockIns}
                        </td>
                      </tr>
                    </tbody>
                  </table>
                </div>
                <p className="text-xs text-muted">
                  {consolidated.perOutlet
                    .map(
                      (row) =>
                        `${row.outletName}: ${formatQuantity(row.grossItemSalesMinor)} gross, ${row.saleCount} sale(s)`,
                    )
                    .join(' + ')}{' '}
                  = {formatQuantity(consolidated.consolidated.grossItemSalesMinor)} gross,{' '}
                  {consolidated.consolidated.saleCount} sale(s).
                  {consolidated.consolidated.stockValueUnavailableReason
                    ? ` Stock value unavailable: ${consolidated.consolidated.stockValueUnavailableReason
                        .split('|')
                        .map(reasonText)
                        .join(' ')}`
                    : ''}
                </p>
                <p className="text-xs text-muted">
                  Generated {formatDateTimeInZone(consolidated.generatedAt, timezone)} · range{' '}
                  {consolidated.from} to {consolidated.to}.
                </p>
              </div>
            ) : null}
          </CardContent>
        </Card>
      ) : (
        <Card>
          <CardContent className="flex items-start gap-3 pt-6">
            <BookOpen aria-hidden="true" className="mt-0.5 size-5 text-muted" />
            <p className="text-sm text-muted">
              Consolidated owner views are available to owner accounts. This account can still read
              its own outlet bookkeeping.
            </p>
          </CardContent>
        </Card>
      )}

      <Card>
        <CardHeader>
          <CardTitle>Recent expenses</CardTitle>
          <CardDescription>
            Latest manual operating expenses in the selected range. Stock waste is shown in the
            profit breakdown at its inventory cost.
          </CardDescription>
        </CardHeader>
        <CardContent>
          {expensesQuery.isLoading ? (
            <div className="h-20 animate-pulse rounded-surface bg-surface-muted" aria-busy="true">
              <span className="sr-only">Loading expenses</span>
            </div>
          ) : expensesQuery.isError ? (
            <p className="text-sm text-danger" role="alert">
              {describeReportError(expensesQuery.error, 'Could not load expenses')}
            </p>
          ) : expensesQuery.data?.items.length ? (
            <ul className="divide-y divide-border text-sm">
              {expensesQuery.data.items.map((expense) => (
                <li key={expense.id} className="flex flex-wrap justify-between gap-2 py-2">
                  <span className="text-text">
                    {expense.incurredOn} · {expense.categoryName}
                  </span>
                  <span className="tabular-nums text-text">
                    {report
                      ? formatMoney(expense.amountMinor, report.currency, report.currencyExponent)
                      : expense.amountMinor}
                  </span>
                </li>
              ))}
            </ul>
          ) : (
            <p className="text-sm text-muted">No manual expenses in this period.</p>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
