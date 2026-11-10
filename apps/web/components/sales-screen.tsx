'use client';

import type { ApiSchemas } from '@modern-pos/api-client';
import { useInfiniteQuery, useQuery, useQueryClient } from '@tanstack/react-query';
import { CircleAlert, ReceiptText, RefreshCw, RotateCcw, X } from 'lucide-react';
import { useEffect, useRef, useState } from 'react';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { api } from '@/lib/api';
import { describeReversalError, describeReportError } from '@/lib/api-errors';
import { useAuth } from '@/lib/auth';
import { useActiveOutletId } from '@/lib/use-active-outlet';
import {
  formatDateTimeInZone,
  formatMoney,
  formatQuantity,
  todayInTimeZone,
} from '@/lib/reporting';

type Sale = ApiSchemas['Sale'];
type Reversal = ApiSchemas['Reversal'];
type Restock = ApiSchemas['Restock'];

const FIXED_POINT_PATTERN = /^(0|[1-9][0-9]{0,12})(\.[0-9]{1,6})?$/;

function saleIsReversed(sale: Sale): boolean {
  return sale.state === 'REVERSED' || Boolean(sale.reversal);
}

function quantityText(value: number, scale: number): string {
  const fixed = value.toFixed(Math.min(Math.max(scale, 0), 6));
  return fixed.includes('.') ? fixed.replace(/0+$/, '').replace(/\.$/, '') : fixed;
}

interface IngredientOption {
  stockItemId: string;
  name: string;
  baseUnit: string;
  quantityScale: number;
  consumed: number;
}

const inputClass =
  'h-12 w-full rounded-control border border-control bg-surface px-3 text-sm text-text';

function paymentLabel(kind: Sale['payment']['kind']): string {
  return kind === 'CASH' ? 'Cash' : 'Manual external';
}

function ReverseSaleForm({
  outletId,
  sale,
  onReversed,
}: {
  outletId: string;
  sale: Sale;
  onReversed: (reversal: Reversal) => void;
}) {
  const queryClient = useQueryClient();
  const [open, setOpen] = useState(false);
  const [reason, setReason] = useState('');
  const [ingredients, setIngredients] = useState<IngredientOption[] | null>(null);
  const [ingredientsError, setIngredientsError] = useState<string | null>(null);
  const [selection, setSelection] = useState<
    Record<string, { selected: boolean; quantity: string }>
  >({});
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const idempotency = useRef<{ signature: string; key: string } | null>(null);

  useEffect(() => {
    if (!open) {
      return;
    }

    let cancelled = false;
    setIngredients(null);
    setIngredientsError(null);

    async function loadIngredients(): Promise<void> {
      try {
        const [stock, recipes] = await Promise.all([
          api.listStock(outletId, { limit: 100 }),
          Promise.all(
            sale.lines.map((line) => api.getRecipe(outletId, line.variantId).catch(() => null)),
          ),
        ]);

        if (cancelled) {
          return;
        }

        const stockById = new Map(stock.items.map((item) => [item.id, item]));
        const merged = new Map<string, IngredientOption>();

        sale.lines.forEach((line, index) => {
          const recipe = recipes[index];

          if (!recipe) {
            return;
          }

          for (const recipeLine of recipe.lines) {
            const stockItem = stockById.get(recipeLine.stockItemId);
            const amount = Number(recipeLine.quantityPerSaleUnit) * line.quantity;
            const existing = merged.get(recipeLine.stockItemId);

            if (existing) {
              existing.consumed += amount;
              continue;
            }

            merged.set(recipeLine.stockItemId, {
              stockItemId: recipeLine.stockItemId,
              name: stockItem?.name ?? recipeLine.stockItemId,
              baseUnit: stockItem?.baseUnit ?? '',
              quantityScale: stockItem?.quantityScale ?? 3,
              consumed: amount,
            });
          }
        });

        const options = [...merged.values()].sort((a, b) => a.name.localeCompare(b.name));
        setIngredients(options);
        setSelection((current) =>
          Object.fromEntries(
            options.map((option) => [
              option.stockItemId,
              current[option.stockItemId] ?? {
                selected: false,
                quantity: quantityText(option.consumed, option.quantityScale),
              },
            ]),
          ),
        );
      } catch (loadError) {
        if (!cancelled) {
          setIngredientsError(
            describeReportError(loadError, 'Could not load restock options for this sale'),
          );
        }
      }
    }

    void loadIngredients();
    return () => {
      cancelled = true;
    };
  }, [open, outletId, sale.lines]);

  const selectedRestock: Restock[] = (ingredients ?? [])
    .filter((option) => selection[option.stockItemId]?.selected)
    .map((option) => ({
      stockItemId: option.stockItemId,
      quantity: selection[option.stockItemId]?.quantity.trim() ?? '',
    }));
  const restockValid = selectedRestock.every(
    (item) => FIXED_POINT_PATTERN.test(item.quantity) && Number(item.quantity) > 0,
  );
  const canSubmit = reason.trim().length >= 3 && restockValid && !submitting;

  function signature(payload: Restock[]): string {
    return JSON.stringify({ reason: reason.trim(), restock: payload });
  }

  async function handleSubmit(event: React.FormEvent<HTMLFormElement>): Promise<void> {
    event.preventDefault();
    setError(null);
    setSuccess(null);

    if (!canSubmit) {
      return;
    }

    const payload = { reason: reason.trim(), restock: selectedRestock };
    const signed = signature(selectedRestock);

    if (!idempotency.current || idempotency.current.signature !== signed) {
      idempotency.current = { signature: signed, key: crypto.randomUUID() };
    }

    setSubmitting(true);

    try {
      const reversal = await api.reverseSale(
        outletId,
        sale.id,
        idempotency.current.key,
        payload,
      );
      setSuccess(
        'Reversal recorded. The original sale is unchanged and now linked to this reversal. No money was returned by any payment provider.',
      );
      setOpen(false);
      onReversed(reversal);
      await Promise.all([
        queryClient.invalidateQueries({ queryKey: ['sale', outletId] }),
        queryClient.invalidateQueries({ queryKey: ['sales', outletId] }),
        queryClient.invalidateQueries({ queryKey: ['daily-report', outletId] }),
      ]);
    } catch (submitError) {
      setError(describeReversalError(submitError, 'Could not record this reversal'));
    } finally {
      setSubmitting(false);
    }
  }

  if (sale.reversal) {
    const reversal = sale.reversal;
    return (
      <section className="rounded-surface border border-border bg-surface-tint p-4 sm:p-6">
        <div className="flex items-start gap-3">
          <RotateCcw aria-hidden="true" className="mt-0.5 size-5 shrink-0 text-warning" />
          <div className="min-w-0">
            <h3 className="text-base font-semibold text-text">Reversal recorded</h3>
            <p className="mt-1 text-sm text-muted">
              This sale is not deleted. Its receipt totals stay exactly as recorded, and this
              manual correction is linked separately.
            </p>
          </div>
        </div>
        <dl className="mt-4 grid gap-4 text-sm sm:grid-cols-2">
          <div>
            <dt className="text-xs uppercase tracking-[0.12em] text-muted">Reason</dt>
            <dd className="mt-1 text-text">{reversal.reason}</dd>
          </div>
          <div>
            <dt className="text-xs uppercase tracking-[0.12em] text-muted">Recorded</dt>
            <dd className="mt-1 text-text">
              {formatDateTimeInZone(reversal.createdAt, sale.timezone)}
            </dd>
          </div>
          <div className="sm:col-span-2">
            <dt className="text-xs uppercase tracking-[0.12em] text-muted">External refund</dt>
            <dd className="mt-1 text-text">
              Not performed. This record never claims that a payment provider returned money.
            </dd>
          </div>
        </dl>
        <div className="mt-4">
          <h4 className="text-sm font-medium text-text">Restocked stock items</h4>
          {reversal.restock.length === 0 ? (
            <p className="mt-1 text-sm text-muted">
              No stock was restocked. This was a financial-only reversal.
            </p>
          ) : (
            <ul className="mt-2 flex flex-col gap-1 text-sm text-text">
              {reversal.restock.map((item) => (
                <li key={item.stockItemId} className="tabular-nums">
                  Stock item {item.stockItemId} · +{item.quantity}
                </li>
              ))}
            </ul>
          )}
        </div>
      </section>
    );
  }

  return (
    <section className="rounded-surface border border-border bg-surface-tint p-4 sm:p-6">
      <div className="flex flex-col gap-2">
        <h3 className="text-base font-semibold text-text">Reverse this sale</h3>
        <p className="text-sm text-muted">
          The sale record is not deleted. Totals and items stay immutable. This is a manual
          correction record; no money is returned by any payment provider.
        </p>
      </div>

      {success ? (
        <p className="mt-4 rounded-control bg-success-soft p-3 text-sm text-success" role="status">
          {success}
        </p>
      ) : null}

      {!open ? (
        <div className="mt-4">
          <Button variant="outline" onClick={() => setOpen(true)}>
            <RotateCcw aria-hidden="true" className="size-4" />
            Start a reversal
          </Button>
        </div>
      ) : (
        <form className="mt-4 flex flex-col gap-5" onSubmit={handleSubmit}>
          <label className="flex flex-col gap-1 text-sm font-medium text-text">
            Reason (required, 3 to 500 characters)
            <textarea
              className="min-h-24 w-full rounded-control border border-control bg-surface px-3 py-2 text-sm text-text"
              value={reason}
              minLength={3}
              maxLength={500}
              required
              onChange={(event) => setReason(event.target.value)}
            />
          </label>

          <div>
            <h4 className="text-sm font-semibold text-text">Restock ingredients</h4>
            <p className="mt-1 text-sm text-muted">
              Only selected stock items are added back. Consumed ingredients are not replenished
              automatically.
            </p>

            {ingredientsError ? (
              <p className="mt-3 text-sm text-danger" role="alert">
                {ingredientsError}
              </p>
            ) : ingredients === null ? (
              <p className="mt-3 text-sm text-muted" aria-live="polite">
                Loading restock options…
              </p>
            ) : ingredients.length === 0 ? (
              <p className="mt-3 text-sm text-muted">
                No tracked ingredients were consumed by this sale. Leave everything unselected for
                a financial-only reversal.
              </p>
            ) : (
              <ul className="mt-3 flex flex-col gap-3">
                {ingredients.map((option) => {
                  const field = selection[option.stockItemId];
                  return (
                    <li
                      key={option.stockItemId}
                      className="rounded-control border border-border bg-surface p-3"
                    >
                      <label className="flex items-start gap-3 text-sm text-text">
                        <input
                          type="checkbox"
                          className="mt-0.5 size-4 shrink-0 rounded border-control"
                          checked={field?.selected ?? false}
                          onChange={(event) =>
                            setSelection((current) => ({
                              ...current,
                              [option.stockItemId]: {
                                selected: event.target.checked,
                                quantity:
                                  current[option.stockItemId]?.quantity ??
                                  quantityText(option.consumed, option.quantityScale),
                              },
                            }))
                          }
                        />
                        <span>
                          <span className="font-medium">{option.name}</span>
                          <span className="block text-xs text-muted">
                            Consumed by this sale: {quantityText(option.consumed, option.quantityScale)}{' '}
                            {option.baseUnit}
                          </span>
                        </span>
                      </label>
                      {field?.selected ? (
                        <label className="mt-3 flex flex-col gap-1 text-sm font-medium text-text">
                          Quantity to restock ({option.baseUnit})
                          <input
                            className={inputClass}
                            inputMode="decimal"
                            value={field.quantity}
                            onChange={(event) =>
                              setSelection((current) => ({
                                ...current,
                                [option.stockItemId]: {
                                  selected: true,
                                  quantity: event.target.value,
                                },
                              }))
                            }
                          />
                        </label>
                      ) : null}
                    </li>
                  );
                })}
              </ul>
            )}
          </div>

          {error ? (
            <div className="flex flex-col items-start gap-3" role="alert">
              <p className="text-sm text-danger">{error}</p>
              <span className="text-xs text-muted">
                The same retry key is reused until this form changes, so retrying does not record a
                second reversal.
              </span>
            </div>
          ) : null}

          {!restockValid ? (
            <p className="text-sm text-danger" role="alert">
              Every selected quantity must be a positive fixed-point number.
            </p>
          ) : null}

          <div className="flex flex-wrap gap-3">
            <Button type="submit" disabled={!canSubmit}>
              {submitting ? 'Recording reversal…' : 'Record reversal'}
            </Button>
            <Button
              type="button"
              variant="outline"
              onClick={() => {
                setOpen(false);
                setError(null);
                setSuccess(null);
              }}
            >
              Cancel
            </Button>
          </div>
        </form>
      )}
    </section>
  );
}

function SaleDetail({
  outletId,
  sale,
  loading,
  error,
  canReverse,
  onRetry,
  onClose,
}: {
  outletId: string;
  sale: Sale | undefined;
  loading: boolean;
  error: string | null;
  canReverse: boolean;
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
                  <Badge tone={saleIsReversed(sale) ? 'warning' : 'success'}>
                    {saleIsReversed(sale) ? 'Reversed' : 'Completed'}
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

            {sale.reversal || canReverse ? (
              <ReverseSaleForm
                outletId={outletId}
                sale={sale}
                onReversed={() => undefined}
              />
            ) : null}
          </div>
        ) : null}
      </CardContent>
    </Card>
  );
}

export function SalesScreen() {
  const outletId = useActiveOutletId();
  const { user } = useAuth();
  const canReverse = user?.role === 'OWNER';
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
                          <Badge tone={saleIsReversed(sale) ? 'warning' : 'success'}>
                            {saleIsReversed(sale) ? 'Reversed' : 'Completed'}
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

      {selectedId && outletId ? (
        <SaleDetail
          outletId={outletId}
          sale={detailQuery.data}
          loading={detailQuery.isLoading}
          canReverse={canReverse}
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
