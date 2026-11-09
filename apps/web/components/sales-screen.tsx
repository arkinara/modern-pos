'use client';

import type { ApiSchemas } from '@modern-pos/api-client';
import { useInfiniteQuery, useQuery } from '@tanstack/react-query';
import { CircleAlert, ReceiptText, RefreshCw, X } from 'lucide-react';
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

type Sale = ApiSchemas['Sale'];

const inputClass =
  'h-12 w-full rounded-control border border-control bg-surface px-3 text-sm text-text';

function paymentLabel(kind: Sale['payment']['kind']): string {
  return kind === 'CASH' ? 'Cash' : 'Manual external';
}

function SaleDetail({
  sale,
  loading,
  error,
  onRetry,
  onClose,
}: {
  sale: Sale | undefined;
  loading: boolean;
  error: string | null;
  onRetry: () => void;
  onClose: () => void;
}) {
  return (
    <Card aria-live="polite">
      <CardHeader className="flex-row items-start justify-between gap-4">
        <div>
          <CardTitle>Receipt detail</CardTitle>
          <CardDescription>
            Immutable snapshot read from the sale record. Catalog and settings edits never rewrite a
            completed receipt.
          </CardDescription>
        </div>
        <Button variant="ghost" size="icon" aria-label="Close receipt" onClick={onClose}>
          <X aria-hidden="true" className="size-5" />
        </Button>
      </CardHeader>
      <CardContent>
        {loading ? (
          <p className="text-sm text-muted">Loading receipt…</p>
        ) : error ? (
          <div className="flex flex-col items-start gap-3" role="alert">
            <p className="text-sm text-danger">{error}</p>
            <Button variant="outline" onClick={onRetry}>
              <RefreshCw aria-hidden="true" className="size-4" />
              Try again
            </Button>
          </div>
        ) : sale ? (
          <div className="flex flex-col gap-6">
            <dl className="grid gap-4 text-sm sm:grid-cols-2 lg:grid-cols-3">
              <div>
                <dt className="text-xs uppercase tracking-[0.12em] text-muted">Reference</dt>
                <dd className="mt-1 font-mono text-text">{sale.reference}</dd>
              </div>
              <div>
                <dt className="text-xs uppercase tracking-[0.12em] text-muted">Recorded</dt>
                <dd className="mt-1 text-text">
                  {formatDateTimeInZone(sale.completedAt, sale.timezone)}
                  <span className="block text-xs text-muted">{sale.timezone}</span>
                </dd>
              </div>
              <div>
                <dt className="text-xs uppercase tracking-[0.12em] text-muted">State</dt>
                <dd className="mt-1">
                  <Badge tone={sale.state === 'COMPLETED' ? 'success' : 'warning'}>
                    {sale.state === 'COMPLETED' ? 'Completed' : 'Reversed'}
                  </Badge>
                </dd>
              </div>
            </dl>

            <div className="overflow-x-auto rounded-surface border border-border">
              <table className="w-full table-auto text-left text-sm">
                <thead className="bg-surface-tint text-xs uppercase tracking-[0.12em] text-muted">
                  <tr>
                    <th scope="col" className="px-4 py-3 font-medium">
                      Item
                    </th>
                    <th scope="col" className="px-4 py-3 text-right font-medium">
                      Qty
                    </th>
                    <th scope="col" className="px-4 py-3 text-right font-medium">
                      Unit price
                    </th>
                    <th scope="col" className="px-4 py-3 text-right font-medium">
                      Line subtotal
                    </th>
                  </tr>
                </thead>
                <tbody>
                  {sale.lines.map((line) => (
                    <tr key={line.id} className="border-t border-border align-top">
                      <td className="px-4 py-3">
                        <span className="font-medium text-text">{line.name}</span>
                        {line.variantName ? (
                          <span className="block text-xs text-muted">{line.variantName}</span>
                        ) : null}
                      </td>
                      <td className="px-4 py-3 text-right tabular-nums text-text">
                        {formatQuantity(line.quantity)}
                      </td>
                      <td className="px-4 py-3 text-right tabular-nums text-text">
                        {formatMoney(line.unitPriceMinor, sale.currency, sale.currencyExponent)}
                      </td>
                      <td className="px-4 py-3 text-right tabular-nums text-text">
                        {formatMoney(line.lineSubtotalMinor, sale.currency, sale.currencyExponent)}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>

            <div className="grid gap-6 md:grid-cols-2">
              <dl className="flex flex-col gap-2 text-sm">
                <div className="flex items-center justify-between gap-4">
                  <dt className="text-muted">Subtotal</dt>
                  <dd className="tabular-nums text-text">
                    {formatMoney(sale.totals.subtotalMinor, sale.currency, sale.currencyExponent)}
                  </dd>
                </div>
                <div className="flex items-center justify-between gap-4">
                  <dt className="text-muted">Service</dt>
                  <dd className="tabular-nums text-text">
                    {formatMoney(sale.totals.serviceMinor, sale.currency, sale.currencyExponent)}
                  </dd>
                </div>
                <div className="flex items-center justify-between gap-4">
                  <dt className="text-muted">Tax</dt>
                  <dd className="tabular-nums text-text">
                    {formatMoney(sale.totals.taxMinor, sale.currency, sale.currencyExponent)}
                  </dd>
                </div>
                <div className="flex items-center justify-between gap-4 border-t border-border pt-2 text-base font-semibold">
                  <dt className="text-text">Total</dt>
                  <dd className="tabular-nums text-text">
                    {formatMoney(sale.totals.totalMinor, sale.currency, sale.currencyExponent)}
                  </dd>
                </div>
              </dl>
              <dl className="flex flex-col gap-2 text-sm">
                <div className="flex items-center justify-between gap-4">
                  <dt className="text-muted">Payment method</dt>
                  <dd className="text-text">{paymentLabel(sale.payment.kind)}</dd>
                </div>
                <div className="flex items-center justify-between gap-4">
                  <dt className="text-muted">Amount received</dt>
                  <dd className="tabular-nums text-text">
                    {formatMoney(sale.payment.amountMinor, sale.currency, sale.currencyExponent)}
                  </dd>
                </div>
                {sale.payment.tenderedMinor !== undefined ? (
                  <div className="flex items-center justify-between gap-4">
                    <dt className="text-muted">Handed over</dt>
                    <dd className="tabular-nums text-text">
                      {formatMoney(
                        sale.payment.tenderedMinor,
                        sale.currency,
                        sale.currencyExponent,
                      )}
                    </dd>
                  </div>
                ) : null}
                {sale.payment.changeMinor !== undefined ? (
                  <div className="flex items-center justify-between gap-4">
                    <dt className="text-muted">Change</dt>
                    <dd className="tabular-nums text-text">
                      {formatMoney(sale.payment.changeMinor, sale.currency, sale.currencyExponent)}
                    </dd>
                  </div>
                ) : null}
                {sale.payment.reference ? (
                  <div className="flex items-center justify-between gap-4">
                    <dt className="text-muted">Payment reference</dt>
                    <dd className="break-all font-mono text-text">{sale.payment.reference}</dd>
                  </div>
                ) : null}
                <p className="text-xs text-muted">
                  Manual external means recorded only. No provider verification or refund is
                  implied.
                </p>
              </dl>
            </div>
          </div>
        ) : null}
      </CardContent>
    </Card>
  );
}

export function SalesScreen() {
  const outletId = useActiveOutletId();
  const [from, setFrom] = useState('');
  const [to, setTo] = useState('');
  const [selectedId, setSelectedId] = useState<string | null>(null);

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

  const salesQuery = useInfiniteQuery({
    queryKey: ['sales', outletId, from, to],
    initialPageParam: undefined as string | undefined,
    queryFn: ({ pageParam }) =>
      api.listSales(outletId as string, {
        from,
        to,
        limit: 25,
        ...(pageParam ? { cursor: pageParam } : {}),
      }),
    getNextPageParam: (lastPage) => lastPage.nextCursor ?? undefined,
    enabled: Boolean(outletId) && validRange,
  });

  const detailQuery = useQuery({
    queryKey: ['sale', outletId, selectedId],
    queryFn: () => api.getSale(outletId as string, selectedId as string),
    enabled: Boolean(outletId) && Boolean(selectedId),
  });

  const sales = salesQuery.data?.pages.flatMap((page) => page.items) ?? [];
  const rangeError =
    from && to && from > to ? 'The start date must be on or before the end date.' : null;

  return (
    <div className="flex w-full flex-col gap-6">
      <header>
        <h1 className="text-3xl font-semibold tracking-tight text-text">Sales</h1>
        <p className="mt-2 max-w-3xl text-sm text-muted">
          Read-only history of records created by the Android app, filtered by outlet-local dates.
          This back office cannot create, edit or complete a sale.
        </p>
      </header>

      <Card>
        <CardHeader>
          <CardTitle>Filter</CardTitle>
          <CardDescription>
            Dates are interpreted in the outlet timezone ({timezone}) and include both start and end
            days.
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
        </CardContent>
      </Card>

      <Card>
        <CardHeader className="flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <CardTitle>Recorded sales</CardTitle>
            <CardDescription>
              {from && to && validRange
                ? `${from} to ${to} · ${timezone} · ${sales.length} loaded`
                : 'Choose a valid outlet-local date range.'}
            </CardDescription>
          </div>
          <Button variant="outline" size="sm" onClick={() => salesQuery.refetch()}>
            <RefreshCw aria-hidden="true" className="size-4" />
            Refresh
          </Button>
        </CardHeader>
        <CardContent>
          {settingsQuery.isError ? (
            <div className="flex flex-col items-start gap-3" role="alert">
              <p className="text-sm text-danger">
                {describeReportError(settingsQuery.error, 'Could not load outlet settings')}
              </p>
              <Button variant="outline" onClick={() => settingsQuery.refetch()}>
                Try again
              </Button>
            </div>
          ) : salesQuery.isLoading ? (
            <div className="flex flex-col gap-2" aria-busy="true">
              <div className="h-12 animate-pulse rounded-control bg-surface-muted" />
              <div className="h-12 animate-pulse rounded-control bg-surface-muted" />
              <div className="h-12 animate-pulse rounded-control bg-surface-muted" />
              <span className="sr-only">Loading sales</span>
            </div>
          ) : salesQuery.isError ? (
            <div className="flex flex-col items-start gap-3" role="alert">
              <p className="text-sm text-danger">
                {describeReportError(salesQuery.error, 'Could not load sales')}
              </p>
              <Button variant="outline" onClick={() => salesQuery.refetch()}>
                Try again
              </Button>
            </div>
          ) : sales.length === 0 ? (
            <div className="rounded-surface border border-dashed border-control bg-surface-tint p-8 text-center">
              <ReceiptText aria-hidden="true" className="mx-auto size-6 text-muted" />
              <p className="mt-3 text-sm text-muted">
                No sales were recorded in this outlet-local date range. The empty state is not an
                error; choose another range or refresh.
              </p>
            </div>
          ) : (
            <div className="overflow-x-auto rounded-surface border border-border">
              <table className="w-full table-auto text-left text-sm">
                <caption className="sr-only">Recorded sales for the selected local dates</caption>
                <thead className="bg-surface-tint text-xs uppercase tracking-[0.12em] text-muted">
                  <tr>
                    <th scope="col" className="px-4 py-3 font-medium">
                      Date and time
                    </th>
                    <th scope="col" className="px-4 py-3 font-medium">
                      Reference
                    </th>
                    <th scope="col" className="px-4 py-3 font-medium">
                      Items
                    </th>
                    <th scope="col" className="px-4 py-3 font-medium">
                      Payment
                    </th>
                    <th scope="col" className="px-4 py-3 text-right font-medium">
                      Service and tax
                    </th>
                    <th scope="col" className="px-4 py-3 text-right font-medium">
                      Total
                    </th>
                    <th scope="col" className="px-4 py-3 font-medium">
                      Receipt
                    </th>
                  </tr>
                </thead>
                <tbody>
                  {sales.map((sale) => (
                    <tr key={sale.id} className="border-t border-border align-top">
                      <td className="px-4 py-3 text-text">
                        {formatDateTimeInZone(sale.completedAt, sale.timezone)}
                        <span className="block text-xs text-muted">{sale.timezone}</span>
                      </td>
                      <td className="px-4 py-3">
                        <span className="break-all font-mono text-xs text-text">
                          {sale.reference}
                        </span>
                        <span className="mt-1 block">
                          <Badge tone={sale.state === 'COMPLETED' ? 'success' : 'warning'}>
                            {sale.state === 'COMPLETED' ? 'Completed' : 'Reversed'}
                          </Badge>
                        </span>
                      </td>
                      <td className="min-w-48 px-4 py-3 text-text">
                        <ul className="flex flex-col gap-1">
                          {sale.lines.map((line) => (
                            <li key={line.id}>
                              {line.name}
                              {line.variantName ? (
                                <span className="text-muted"> · {line.variantName}</span>
                              ) : null}
                              <span className="tabular-nums text-muted">
                                {' '}
                                × {formatQuantity(line.quantity)}
                              </span>
                            </li>
                          ))}
                        </ul>
                      </td>
                      <td className="px-4 py-3 text-text">
                        {paymentLabel(sale.payment.kind)}
                        <span className="block text-xs text-muted">
                          {sale.payment.status === 'RECORDED' ? 'Recorded' : sale.payment.status}
                        </span>
                        {sale.payment.tenderedMinor !== undefined ? (
                          <span className="mt-1 block text-xs text-muted">
                            Received{' '}
                            {formatMoney(
                              sale.payment.tenderedMinor,
                              sale.currency,
                              sale.currencyExponent,
                            )}
                          </span>
                        ) : null}
                      </td>
                      <td className="px-4 py-3 text-right tabular-nums text-text">
                        <span className="block">
                          {formatMoney(
                            sale.totals.serviceMinor,
                            sale.currency,
                            sale.currencyExponent,
                          )}
                        </span>
                        <span className="block text-xs text-muted">
                          tax{' '}
                          {formatMoney(sale.totals.taxMinor, sale.currency, sale.currencyExponent)}
                        </span>
                      </td>
                      <td className="px-4 py-3 text-right font-semibold tabular-nums text-text">
                        {formatMoney(sale.totals.totalMinor, sale.currency, sale.currencyExponent)}
                      </td>
                      <td className="px-4 py-3">
                        <Button
                          variant="outline"
                          size="sm"
                          aria-expanded={selectedId === sale.id}
                          onClick={() =>
                            setSelectedId((current) => (current === sale.id ? null : sale.id))
                          }
                        >
                          {selectedId === sale.id ? 'Hide receipt' : 'View receipt'}
                        </Button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}

          {salesQuery.hasNextPage ? (
            <div className="mt-4 flex justify-center">
              <Button
                variant="outline"
                onClick={() => salesQuery.fetchNextPage()}
                disabled={salesQuery.isFetchingNextPage}
              >
                {salesQuery.isFetchingNextPage ? 'Loading more…' : 'Load more sales'}
              </Button>
            </div>
          ) : null}

          {salesQuery.isFetching && !salesQuery.isLoading ? (
            <p className="mt-3 text-xs text-muted" aria-live="polite">
              Refreshing sales…
            </p>
          ) : null}
        </CardContent>
      </Card>

      {selectedId ? (
        <SaleDetail
          sale={detailQuery.data}
          loading={detailQuery.isLoading}
          error={
            detailQuery.isError
              ? describeReportError(detailQuery.error, 'Could not load this receipt')
              : null
          }
          onRetry={() => detailQuery.refetch()}
          onClose={() => setSelectedId(null)}
        />
      ) : null}

      <p className="flex items-start gap-2 text-xs text-muted">
        <CircleAlert aria-hidden="true" className="mt-0.5 size-4 shrink-0" />
        Reversed sales are labelled and never counted as completed in reports. This build has no web
        sale action.
      </p>
    </div>
  );
}
