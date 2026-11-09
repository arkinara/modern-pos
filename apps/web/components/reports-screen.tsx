'use client';

import type { ApiSchemas } from '@modern-pos/api-client';
import { useQuery } from '@tanstack/react-query';
import { BarChart3, CircleAlert, Download, RefreshCw } from 'lucide-react';
import { useEffect, useState } from 'react';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { api } from '@/lib/api';
import { describeReportError } from '@/lib/api-errors';
import { useActiveOutletId } from '@/lib/use-active-outlet';
import {
  formatDateTimeInZone,
  formatMoney,
  formatQuantity,
  todayInTimeZone,
} from '@/lib/reporting';

type DailyReport = ApiSchemas['DailyReport'];

const inputClass =
  'h-12 w-full rounded-control border border-control bg-surface px-3 text-sm text-text';

const DEFINITIONS = [
  {
    term: 'Gross item sales',
    detail:
      'Sum of completed item line subtotals recorded inside the selected outlet-local period. Service and tax are excluded.',
  },
  {
    term: 'Reversal item value',
    detail:
      'Item subtotal of reversals created in the period. Reversal support is not implemented yet, so this value is 0.',
  },
  {
    term: 'Net item sales',
    detail: 'Gross item sales minus reversal item value.',
  },
  {
    term: 'Sale count',
    detail: 'Number of sales whose state is completed and whose recorded time falls in the period.',
  },
  {
    term: 'Average bill',
    detail:
      'Gross item sales divided by sale count, rounded half up on integer minor units. It is 0 when the sale count is 0.',
  },
  {
    term: 'Menu quantities',
    detail: 'Sold quantity summed by menu item name across completed sales in the period.',
  },
  {
    term: 'Payment-method totals',
    detail:
      'Recorded payment amount grouped by method. Manual external is recorded only and never proves a provider transaction.',
  },
] as const;

function Definition({ term, detail }: { term: string; detail: string }) {
  return (
    <div>
      <dt className="font-medium text-text">{term}</dt>
      <dd className="mt-1 text-muted">{detail}</dd>
    </div>
  );
}

function MetricCard({
  label,
  value,
  definition,
}: {
  label: string;
  value: string;
  definition: string;
}) {
  return (
    <div className="rounded-surface border border-border bg-surface-tint p-4">
      <p className="text-xs font-medium uppercase tracking-[0.12em] text-muted">{label}</p>
      <p className="mt-2 text-2xl font-semibold tabular-nums text-text">{value}</p>
      <p className="mt-2 text-xs text-muted">{definition}</p>
    </div>
  );
}

export function ReportsScreen() {
  const outletId = useActiveOutletId();
  const [from, setFrom] = useState('');
  const [to, setTo] = useState('');
  const [exporting, setExporting] = useState(false);
  const [exportMessage, setExportMessage] = useState<string | null>(null);
  const [exportError, setExportError] = useState<string | null>(null);

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
  }, [settingsQuery.data, from, to]);

  const validRange = Boolean(from && to && from <= to);

  const reportQuery = useQuery({
    queryKey: ['daily-report', outletId, from, to],
    queryFn: () => api.getDailyReport(outletId as string, { from, to }),
    enabled: Boolean(outletId) && validRange,
  });

  const report: DailyReport | undefined = reportQuery.data;
  const rangeError =
    from && to && from > to ? 'The start date must be on or before the end date.' : null;

  async function handleExport(): Promise<void> {
    setExporting(true);
    setExportError(null);
    setExportMessage(null);

    try {
      const exported = await api.exportSalesCsv(outletId as string, { from, to });
      const blob = new Blob([exported.csv], { type: 'text/csv;charset=utf-8' });
      const url = URL.createObjectURL(blob);
      const link = document.createElement('a');
      link.href = url;
      link.download = exported.filename;
      document.body.append(link);
      link.click();
      link.remove();
      URL.revokeObjectURL(url);
      setExportMessage(`Downloaded ${exported.filename}`);
    } catch (error) {
      setExportError(describeReportError(error, 'Could not export this date range'));
    } finally {
      setExporting(false);
    }
  }

  function money(minor: number): string {
    return report ? formatMoney(minor, report.currency, report.currencyExponent) : String(minor);
  }

  return (
    <div className="flex w-full flex-col gap-6">
      <header>
        <h1 className="text-3xl font-semibold tracking-tight text-text">Reports</h1>
        <p className="mt-2 max-w-3xl text-sm text-muted">
          Daily reconciliation from completed records created by the Android app. Figures use the
          outlet IANA timezone and half-open local-day intervals.
        </p>
      </header>

      <Card>
        <CardHeader>
          <CardTitle>Report period</CardTitle>
          <CardDescription>
            Inclusive outlet-local dates. The interval starts at local midnight on the first date
            and ends at local midnight after the last date, then converts to UTC.
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
          {rangeError ? (
            <p className="text-sm text-danger" role="alert">
              {rangeError}
            </p>
          ) : null}
          <div className="flex flex-wrap items-center gap-3">
            <Button onClick={handleExport} disabled={!validRange || exporting || !report}>
              <Download aria-hidden="true" className="size-4" />
              {exporting ? 'Exporting…' : 'Export CSV'}
            </Button>
            <Button variant="outline" onClick={() => reportQuery.refetch()}>
              <RefreshCw aria-hidden="true" className="size-4" />
              Refresh
            </Button>
            <span className="text-xs text-muted">Timezone {timezone}</span>
          </div>
          {exportMessage ? (
            <p className="text-sm text-success" role="status">
              {exportMessage}
            </p>
          ) : null}
          {exportError ? (
            <p className="text-sm text-danger" role="alert">
              {exportError}
            </p>
          ) : null}
        </CardContent>
      </Card>

      {settingsQuery.isError ? (
        <Card>
          <CardContent className="flex flex-col items-start gap-3 pt-6" role="alert">
            <p className="text-sm text-danger">
              {describeReportError(settingsQuery.error, 'Could not load outlet settings')}
            </p>
            <Button variant="outline" onClick={() => settingsQuery.refetch()}>
              Try again
            </Button>
          </CardContent>
        </Card>
      ) : reportQuery.isLoading ? (
        <Card>
          <CardContent className="pt-6" aria-busy="true">
            <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
              <div className="h-28 animate-pulse rounded-surface bg-surface-muted" />
              <div className="h-28 animate-pulse rounded-surface bg-surface-muted" />
              <div className="h-28 animate-pulse rounded-surface bg-surface-muted" />
              <div className="h-28 animate-pulse rounded-surface bg-surface-muted" />
            </div>
            <span className="sr-only">Loading report</span>
          </CardContent>
        </Card>
      ) : reportQuery.isError ? (
        <Card>
          <CardContent className="flex flex-col items-start gap-3 pt-6" role="alert">
            <p className="text-sm text-danger">
              {describeReportError(reportQuery.error, 'Could not load this report')}
            </p>
            <Button variant="outline" onClick={() => reportQuery.refetch()}>
              Try again
            </Button>
          </CardContent>
        </Card>
      ) : report ? (
        <>
          <Card>
            <CardHeader className="flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
              <div>
                <CardTitle>
                  {report.from === report.to ? report.from : `${report.from} to ${report.to}`}
                </CardTitle>
                <CardDescription>
                  Filter: completed sales only · Timezone {report.timezone} · {report.saleCount}{' '}
                  completed {report.saleCount === 1 ? 'sale' : 'sales'}
                </CardDescription>
              </div>
              <Badge tone="neutral">{report.currency}</Badge>
            </CardHeader>
            <CardContent className="flex flex-col gap-6">
              <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
                <MetricCard
                  label="Gross item sales"
                  value={money(report.grossItemSalesMinor)}
                  definition="Completed item subtotals in this period; service and tax excluded."
                />
                <MetricCard
                  label="Net item sales"
                  value={money(report.netItemSalesMinor)}
                  definition="Gross item sales minus reversal item value."
                />
                <MetricCard
                  label="Sale count"
                  value={formatQuantity(report.saleCount)}
                  definition="Completed sales recorded inside the outlet-local period."
                />
                <MetricCard
                  label="Average bill"
                  value={money(report.averageBillMinor)}
                  definition="Gross item sales ÷ sale count, half-up; 0 when there are no sales."
                />
              </div>
              <p className="text-xs text-muted">
                Generated {formatDateTimeInZone(report.generatedAt, report.timezone)} in{' '}
                {report.timezone}. Reversal item value is {money(report.reversalItemValueMinor)} and
                reversal count is {report.reversalCount} until reversal support lands.
              </p>
            </CardContent>
          </Card>

          <div className="grid gap-6 lg:grid-cols-2">
            <Card>
              <CardHeader>
                <CardTitle>Menu quantities</CardTitle>
                <CardDescription>
                  Sold quantity by menu item name for completed sales in the period.
                </CardDescription>
              </CardHeader>
              <CardContent>
                {report.topItems.length === 0 ? (
                  <div className="rounded-surface border border-dashed border-control bg-surface-tint p-6 text-center">
                    <BarChart3 aria-hidden="true" className="mx-auto size-6 text-muted" />
                    <p className="mt-3 text-sm text-muted">
                      No item quantities in this period. A zeroed report is the expected empty
                      state, not an error.
                    </p>
                  </div>
                ) : (
                  <div className="overflow-x-auto rounded-surface border border-border">
                    <table className="w-full table-auto text-left text-sm">
                      <thead className="bg-surface-tint text-xs uppercase tracking-[0.12em] text-muted">
                        <tr>
                          <th scope="col" className="px-4 py-3 font-medium">
                            Menu item
                          </th>
                          <th scope="col" className="px-4 py-3 text-right font-medium">
                            Quantity
                          </th>
                        </tr>
                      </thead>
                      <tbody>
                        {report.topItems.map((item) => (
                          <tr key={item.name} className="border-t border-border">
                            <td className="px-4 py-3 text-text">{item.name}</td>
                            <td className="px-4 py-3 text-right tabular-nums text-text">
                              {formatQuantity(item.quantity)}
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                )}
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle>Payment-method totals</CardTitle>
                <CardDescription>
                  Recorded amount grouped by payment method. Manual external does not process or
                  verify a provider payment.
                </CardDescription>
              </CardHeader>
              <CardContent>
                <div className="overflow-x-auto rounded-surface border border-border">
                  <table className="w-full table-auto text-left text-sm">
                    <thead className="bg-surface-tint text-xs uppercase tracking-[0.12em] text-muted">
                      <tr>
                        <th scope="col" className="px-4 py-3 font-medium">
                          Method
                        </th>
                        <th scope="col" className="px-4 py-3 text-right font-medium">
                          Recorded amount
                        </th>
                      </tr>
                    </thead>
                    <tbody>
                      {report.paymentBreakdown.map((entry) => (
                        <tr key={entry.kind} className="border-t border-border">
                          <td className="px-4 py-3 text-text">
                            {entry.kind === 'CASH' ? 'Cash' : 'Manual external'}
                          </td>
                          <td className="px-4 py-3 text-right tabular-nums text-text">
                            {money(entry.receivedMinor)}
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </CardContent>
            </Card>
          </div>

          <Card>
            <CardHeader>
              <CardTitle>Definitions</CardTitle>
              <CardDescription>
                Every figure on this page is defined here so the report can be reconciled without
                guessing.
              </CardDescription>
            </CardHeader>
            <CardContent className="grid gap-4 md:grid-cols-2">
              <dl className="flex flex-col gap-4">
                {DEFINITIONS.slice(0, 4).map((entry) => (
                  <Definition key={entry.term} term={entry.term} detail={entry.detail} />
                ))}
              </dl>
              <dl className="flex flex-col gap-4">
                {DEFINITIONS.slice(4).map((entry) => (
                  <Definition key={entry.term} term={entry.term} detail={entry.detail} />
                ))}
              </dl>
            </CardContent>
          </Card>
        </>
      ) : null}

      <p className="flex items-start gap-2 text-xs text-muted">
        <CircleAlert aria-hidden="true" className="mt-0.5 size-4 shrink-0" />
        Report totals reconcile to completed sales only. Sale and stock movement references share
        the completed sale id. Reversal and production deployment work remain deferred.
      </p>
    </div>
  );
}
