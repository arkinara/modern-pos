'use client';

import type { ApiSchemas } from '@modern-pos/api-client';
import { useInfiniteQuery, useQueryClient } from '@tanstack/react-query';
import {
  ArrowDownUp,
  Boxes,
  CircleAlert,
  CircleCheck,
  ClipboardList,
  History,
  Minus,
  PackagePlus,
  Plus,
  RefreshCw,
  Search,
} from 'lucide-react';
import { useDeferredValue, useRef, useState } from 'react';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { api } from '@/lib/api';
import { describeApiError, describeStockError, isStockConflict } from '@/lib/api-errors';
import { useAuth } from '@/lib/auth';
import { useActiveOutletId } from '@/lib/use-active-outlet';

type StockItem = ApiSchemas['Stock'];
type Movement = ApiSchemas['Movement'];

type ChangeMode = 'OPENING' | 'RECEIPT' | 'ADJUSTMENT';
type ChangeTarget = { item: StockItem; mode: ChangeMode };
type Feedback = { tone: 'success' | 'error'; message: string; reload?: boolean };

const QUANTITY_PATTERN = /^(0|[1-9][0-9]{0,12})(\.[0-9]{1,6})?$/;
const SIGNED_PATTERN = /^-?(0|[1-9][0-9]{0,12})(\.[0-9]{1,6})?$/;
const ZERO_PATTERN = /^-?0(\.0+)?$/;

const inputClass =
  'h-12 w-full rounded-control border border-control bg-surface px-3 text-sm text-text placeholder:text-muted';

const MODE_LABELS: Record<ChangeMode, string> = {
  OPENING: 'Record opening balance',
  RECEIPT: 'Record receipt',
  ADJUSTMENT: 'Record adjustment',
};

const MODE_HINTS: Record<ChangeMode, string> = {
  OPENING: 'One opening balance per stock item and outlet. Enter the counted base quantity.',
  RECEIPT: 'Positive base quantity received from a supplier or transfer.',
  ADJUSTMENT:
    'Signed base quantity. A negative delta is allowed only while the balance stays at or above zero.',
};

function decimalPlaces(value: string): number {
  const dot = value.indexOf('.');
  return dot === -1 ? 0 : value.length - dot - 1;
}

function isZero(value: string): boolean {
  return ZERO_PATTERN.test(value);
}

function movementTone(type: Movement['type']): 'accent' | 'success' | 'warning' | 'neutral' {
  if (type === 'OPENING') {
    return 'accent';
  }
  if (type === 'RECEIPT') {
    return 'success';
  }
  if (type === 'ADJUSTMENT') {
    return 'warning';
  }
  return 'neutral';
}

function shortId(value: string): string {
  return value.slice(0, 8);
}

function formatTimestamp(value: string): string {
  const parsed = new Date(value);
  return Number.isNaN(parsed.getTime()) ? value : parsed.toLocaleString();
}

function ChangeForm({
  target,
  busy,
  error,
  onCancel,
  onSubmit,
}: {
  target: ChangeTarget;
  busy: boolean;
  error: string | null;
  onCancel: () => void;
  onSubmit: (values: { amount: string; reason: string }) => void;
}) {
  const [amount, setAmount] = useState('');
  const [reason, setReason] = useState('');
  const [localError, setLocalError] = useState<string | null>(null);
  const isAdjustment = target.mode === 'ADJUSTMENT';

  function submit(): void {
    const trimmed = amount.trim();
    const trimmedReason = reason.trim();
    const pattern = isAdjustment ? SIGNED_PATTERN : QUANTITY_PATTERN;

    if (!pattern.test(trimmed)) {
      setLocalError('Enter a decimal quantity with up to six decimal places and no leading zeros.');
      return;
    }

    if (decimalPlaces(trimmed) > target.item.quantityScale) {
      setLocalError(
        `This item accepts at most ${target.item.quantityScale} decimal place(s). Increase the precision on the item or round the quantity.`,
      );
      return;
    }

    if (isAdjustment) {
      if (isZero(trimmed)) {
        setLocalError('Enter a non-zero delta.');
        return;
      }
    } else if (isZero(trimmed) || trimmed.startsWith('-')) {
      setLocalError('Enter a positive quantity.');
      return;
    }

    if (trimmedReason.length < 3) {
      setLocalError('A reason of at least three characters is required.');
      return;
    }

    setLocalError(null);
    onSubmit({ amount: trimmed, reason: trimmedReason });
  }

  return (
    <form
      className="rounded-surface border border-border bg-surface-tint p-4"
      onSubmit={(event) => {
        event.preventDefault();
        submit();
      }}
    >
      <div className="flex flex-wrap items-start justify-between gap-2">
        <div>
          <h3 className="text-base font-semibold text-text">{MODE_LABELS[target.mode]}</h3>
          <p className="mt-1 text-sm text-muted">
            {target.item.name} · {target.item.baseUnit} · precision {target.item.quantityScale}
          </p>
        </div>
        <Badge tone="neutral">Version {target.item.version}</Badge>
      </div>
      <p className="mt-3 text-sm text-muted">{MODE_HINTS[target.mode]}</p>
      <p className="mt-1 text-sm text-muted">
        Current balance {target.item.quantity} {target.item.baseUnit}
      </p>

      <div className="mt-4 grid gap-4 md:grid-cols-2">
        <div className="flex flex-col gap-2">
          <label className="text-sm font-medium text-text" htmlFor="stock-change-amount">
            {isAdjustment
              ? `Signed delta (${target.item.baseUnit})`
              : `Quantity (${target.item.baseUnit})`}
          </label>
          <input
            id="stock-change-amount"
            className={inputClass}
            inputMode="decimal"
            placeholder={isAdjustment ? '-2.5' : '25'}
            value={amount}
            maxLength={20}
            onChange={(event) => setAmount(event.target.value)}
            aria-invalid={Boolean(localError)}
          />
        </div>
        <div className="flex flex-col gap-2">
          <label className="text-sm font-medium text-text" htmlFor="stock-change-reason">
            Reason
          </label>
          <input
            id="stock-change-reason"
            className={inputClass}
            placeholder="Stock count correction"
            value={reason}
            maxLength={500}
            onChange={(event) => setReason(event.target.value)}
            aria-invalid={Boolean(localError)}
          />
        </div>
      </div>

      {(localError ?? error) ? (
        <p role="alert" className="mt-3 text-sm text-danger">
          {localError ?? error}
        </p>
      ) : null}

      <div className="mt-4 flex flex-wrap gap-3">
        <Button type="submit" disabled={busy}>
          {busy ? 'Saving' : MODE_LABELS[target.mode]}
        </Button>
        <Button type="button" variant="outline" onClick={onCancel} disabled={busy}>
          Cancel
        </Button>
      </div>
    </form>
  );
}

export function StockScreen() {
  const { user } = useAuth();
  const outletId = useActiveOutletId();
  const queryClient = useQueryClient();
  const canEdit = user?.role === 'OWNER';

  const [search, setSearch] = useState('');
  const deferredSearch = useDeferredValue(search);
  const [showCreateForm, setShowCreateForm] = useState(false);
  const [name, setName] = useState('');
  const [baseUnit, setBaseUnit] = useState<'g' | 'ml' | 'each'>('g');
  const [quantityScale, setQuantityScale] = useState(0);
  const [reorderThreshold, setReorderThreshold] = useState('');
  const [createBusy, setCreateBusy] = useState(false);
  const [createError, setCreateError] = useState<string | null>(null);
  const [feedback, setFeedback] = useState<Feedback | null>(null);

  const [changeTarget, setChangeTarget] = useState<ChangeTarget | null>(null);
  const [changeBusy, setChangeBusy] = useState(false);
  const [changeError, setChangeError] = useState<string | null>(null);
  const [historyItem, setHistoryItem] = useState<StockItem | null>(null);

  const pendingKeyRef = useRef<{ signature: string; key: string } | null>(null);

  const stockQuery = useInfiniteQuery({
    queryKey: ['stock', outletId, deferredSearch],
    queryFn: ({ pageParam }) =>
      api.listStock(outletId as string, {
        limit: 100,
        cursor: pageParam,
        search: deferredSearch.trim() || undefined,
      }),
    enabled: outletId !== null,
    initialPageParam: undefined as string | undefined,
    getNextPageParam: (lastPage) => lastPage.nextCursor ?? undefined,
    retry: 1,
  });

  const movementsQuery = useInfiniteQuery({
    queryKey: ['stock-movements', outletId, historyItem?.id],
    queryFn: ({ pageParam }) =>
      api.listStockMovements(outletId as string, historyItem?.id as string, {
        limit: 50,
        cursor: pageParam,
      }),
    enabled: outletId !== null && historyItem !== null,
    initialPageParam: undefined as string | undefined,
    getNextPageParam: (lastPage) => lastPage.nextCursor ?? undefined,
    retry: 1,
  });

  if (!outletId) {
    return (
      <div className="w-full">
        <Card>
          <CardHeader>
            <CardTitle>No outlet assigned</CardTitle>
            <CardDescription>
              This account has no outlet scope, so stock cannot be loaded.
            </CardDescription>
          </CardHeader>
        </Card>
      </div>
    );
  }

  const items = stockQuery.data?.pages.flatMap((page) => page.items) ?? [];
  const movements = movementsQuery.data?.pages.flatMap((page) => page.items) ?? [];

  function reloadStock(): void {
    setFeedback(null);
    void queryClient.invalidateQueries({ queryKey: ['stock', outletId] });
    void queryClient.invalidateQueries({ queryKey: ['stock-movements', outletId] });
  }

  function idempotencyKey(signature: string): string {
    const current = pendingKeyRef.current;
    if (current && current.signature === signature) {
      return current.key;
    }

    const key = globalThis.crypto.randomUUID();
    pendingKeyRef.current = { signature, key };
    return key;
  }

  function clearPendingKey(): void {
    pendingKeyRef.current = null;
  }

  async function submitCreate(): Promise<void> {
    if (!outletId) {
      return;
    }

    const trimmedName = name.trim();
    if (trimmedName.length === 0) {
      setCreateError('A stock item name is required.');
      return;
    }

    const threshold = reorderThreshold.trim();
    if (!QUANTITY_PATTERN.test(threshold)) {
      setCreateError('Reorder threshold must be a nonnegative decimal with up to six places.');
      return;
    }

    if (decimalPlaces(threshold) > quantityScale) {
      setCreateError('Reorder threshold has more decimals than the selected precision allows.');
      return;
    }

    setCreateBusy(true);
    setCreateError(null);
    try {
      await api.createStock(outletId, {
        name: trimmedName,
        baseUnit,
        quantityScale,
        reorderThreshold: threshold,
      });
      await queryClient.invalidateQueries({ queryKey: ['stock', outletId] });
      setFeedback({ tone: 'success', message: `Stock item "${trimmedName}" created.` });
      setName('');
      setReorderThreshold('');
      setQuantityScale(0);
      setShowCreateForm(false);
    } catch (error) {
      setCreateError(
        describeStockError(error, 'Could not create the stock item. Nothing was changed.'),
      );
    } finally {
      setCreateBusy(false);
    }
  }

  async function submitChange(values: { amount: string; reason: string }): Promise<void> {
    if (!outletId || !changeTarget) {
      return;
    }

    const item = changeTarget.item;
    const body =
      changeTarget.mode === 'ADJUSTMENT'
        ? {
            stockItemId: item.id,
            delta: values.amount,
            reason: values.reason,
            expectedBalanceVersion: item.version,
          }
        : {
            stockItemId: item.id,
            quantity: values.amount,
            reason: values.reason,
          };

    const signature = JSON.stringify({ mode: changeTarget.mode, outletId, body });
    const key = idempotencyKey(signature);

    setChangeBusy(true);
    setChangeError(null);
    try {
      if (changeTarget.mode === 'OPENING') {
        await api.recordOpeningBalance(outletId, key, body as ApiSchemas['StockChange']);
      } else if (changeTarget.mode === 'RECEIPT') {
        await api.recordStockReceipt(outletId, key, body as ApiSchemas['StockChange']);
      } else {
        await api.recordStockAdjustment(outletId, key, body as ApiSchemas['Adjustment']);
      }

      clearPendingKey();
      await queryClient.invalidateQueries({ queryKey: ['stock', outletId] });
      await queryClient.invalidateQueries({ queryKey: ['stock-movements', outletId, item.id] });
      setFeedback({
        tone: 'success',
        message: `${MODE_LABELS[changeTarget.mode]} saved for ${item.name}.`,
      });
      setChangeTarget(null);
    } catch (error) {
      setChangeError(
        describeStockError(error, 'Could not save the stock movement. Nothing was changed.'),
      );
      if (isStockConflict(error)) {
        setFeedback({
          tone: 'error',
          message:
            'The server kept the ledger authoritative. Reload the latest balances, then retry with the fresh version.',
          reload: true,
        });
      }
    } finally {
      setChangeBusy(false);
    }
  }

  if (stockQuery.isPending) {
    return (
      <div className="w-full" role="status" aria-live="polite">
        <Card>
          <CardContent className="flex min-h-48 flex-col items-center justify-center gap-3 pt-6">
            <span className="size-8 animate-spin rounded-full border-2 border-border border-t-accent" />
            <p className="text-sm text-muted">Loading stock</p>
          </CardContent>
        </Card>
      </div>
    );
  }

  if (stockQuery.isError) {
    return (
      <div className="w-full">
        <Card>
          <CardHeader>
            <CardTitle>Could not load stock</CardTitle>
            <CardDescription role="alert" className="text-danger">
              {describeApiError(
                stockQuery.error,
                'The stock request failed. Check the API connection and try again.',
              )}
            </CardDescription>
          </CardHeader>
          <CardContent>
            <Button type="button" variant="outline" onClick={() => void stockQuery.refetch()}>
              <RefreshCw aria-hidden="true" className="size-4" />
              Try again
            </Button>
          </CardContent>
        </Card>
      </div>
    );
  }

  return (
    <div className="flex w-full flex-col gap-6">
      <header className="flex flex-wrap items-start justify-between gap-3">
        <div>
          <h1 className="text-3xl font-semibold tracking-tight text-text">Stock</h1>
          <p className="mt-2 max-w-3xl text-sm text-muted">
            Stock items, opening balances and the append-only movement ledger for this outlet. The
            server derives every balance from recorded movements; write actions are owner-only.
          </p>
        </div>
        <div className="flex flex-wrap items-center gap-2">
          {stockQuery.isFetching ? (
            <p className="flex items-center gap-2 text-sm text-muted" role="status">
              <RefreshCw aria-hidden="true" className="size-4 animate-spin" />
              Refreshing
            </p>
          ) : null}
          <Button type="button" variant="outline" onClick={reloadStock}>
            <RefreshCw aria-hidden="true" className="size-4" />
            Reload
          </Button>
        </div>
      </header>

      {feedback ? (
        <div
          role={feedback.tone === 'error' ? 'alert' : 'status'}
          className={
            feedback.tone === 'success'
              ? 'flex flex-wrap items-center gap-3 rounded-control bg-success-soft px-4 py-3 text-sm text-success'
              : 'flex flex-wrap items-center gap-3 rounded-control bg-danger-soft px-4 py-3 text-sm text-danger'
          }
        >
          {feedback.tone === 'success' ? (
            <CircleCheck aria-hidden="true" className="size-5 shrink-0" />
          ) : (
            <CircleAlert aria-hidden="true" className="size-5 shrink-0" />
          )}
          <span className="min-w-0 flex-1">{feedback.message}</span>
          {feedback.reload ? (
            <Button type="button" variant="outline" size="sm" onClick={reloadStock}>
              <RefreshCw aria-hidden="true" className="size-4" />
              Reload stock
            </Button>
          ) : null}
        </div>
      ) : null}

      {!canEdit ? (
        <div className="rounded-control bg-warning-soft px-4 py-3 text-sm text-warning">
          This is a read-only stock view. Only an owner can create items or record movements.
        </div>
      ) : null}

      <Card>
        <CardHeader>
          <CardTitle>Stock tools</CardTitle>
          <CardDescription>
            Search balances by item name. Opening balances are recorded once per item and outlet.
          </CardDescription>
        </CardHeader>
        <CardContent className="flex flex-col gap-4">
          <div className="grid gap-4 md:grid-cols-2">
            <div className="flex flex-col gap-2">
              <label className="text-sm font-medium text-text" htmlFor="stock-search">
                Search stock items
              </label>
              <div className="relative">
                <Search
                  aria-hidden="true"
                  className="pointer-events-none absolute left-3 top-1/2 size-4 -translate-y-1/2 text-muted"
                />
                <input
                  id="stock-search"
                  className="h-12 w-full rounded-control border border-control bg-surface pl-9 pr-3 text-sm text-text placeholder:text-muted"
                  placeholder="Search by item name"
                  maxLength={100}
                  value={search}
                  onChange={(event) => setSearch(event.target.value)}
                />
              </div>
            </div>
            <div className="flex items-end justify-between gap-3">
              <p className="text-sm text-muted">
                {items.length} stock item{items.length === 1 ? '' : 's'}
                {deferredSearch.trim() ? ' matching search' : ''}
              </p>
              {canEdit ? (
                <Button
                  type="button"
                  onClick={() => {
                    setShowCreateForm((current) => !current);
                    setCreateError(null);
                  }}
                >
                  <Plus aria-hidden="true" className="size-4" />
                  {showCreateForm ? 'Close item form' : 'New stock item'}
                </Button>
              ) : null}
            </div>
          </div>

          {canEdit && showCreateForm ? (
            <form
              className="rounded-surface border border-border bg-surface-tint p-4"
              onSubmit={(event) => {
                event.preventDefault();
                void submitCreate();
              }}
            >
              <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
                <div className="flex flex-col gap-2 xl:col-span-2">
                  <label className="text-sm font-medium text-text" htmlFor="stock-name">
                    Item name
                  </label>
                  <input
                    id="stock-name"
                    className={inputClass}
                    placeholder="Coffee Beans"
                    maxLength={200}
                    value={name}
                    onChange={(event) => setName(event.target.value)}
                    aria-invalid={Boolean(createError)}
                  />
                </div>
                <div className="flex flex-col gap-2">
                  <label className="text-sm font-medium text-text" htmlFor="stock-base-unit">
                    Base unit
                  </label>
                  <select
                    id="stock-base-unit"
                    className={inputClass}
                    value={baseUnit}
                    onChange={(event) => setBaseUnit(event.target.value as 'g' | 'ml' | 'each')}
                  >
                    <option value="g">g (grams)</option>
                    <option value="ml">ml (millilitres)</option>
                    <option value="each">each (count)</option>
                  </select>
                </div>
                <div className="flex flex-col gap-2">
                  <label className="text-sm font-medium text-text" htmlFor="stock-scale">
                    Quantity precision
                  </label>
                  <select
                    id="stock-scale"
                    className={inputClass}
                    value={quantityScale}
                    onChange={(event) => setQuantityScale(Number(event.target.value))}
                  >
                    {[0, 1, 2, 3, 4, 5, 6].map((scale) => (
                      <option key={scale} value={scale}>
                        {scale} decimal{scale === 1 ? '' : 's'}
                      </option>
                    ))}
                  </select>
                </div>
                <div className="flex flex-col gap-2 xl:col-span-2">
                  <label className="text-sm font-medium text-text" htmlFor="stock-threshold">
                    Reorder threshold ({baseUnit})
                  </label>
                  <input
                    id="stock-threshold"
                    className={inputClass}
                    inputMode="decimal"
                    placeholder="5000"
                    maxLength={20}
                    value={reorderThreshold}
                    onChange={(event) => setReorderThreshold(event.target.value)}
                    aria-invalid={Boolean(createError)}
                  />
                </div>
              </div>

              {createError ? (
                <p role="alert" className="mt-3 text-sm text-danger">
                  {createError}
                </p>
              ) : null}

              <div className="mt-4 flex flex-wrap gap-3">
                <Button type="submit" disabled={createBusy}>
                  {createBusy ? 'Creating item' : 'Create stock item'}
                </Button>
                <Button
                  type="button"
                  variant="outline"
                  disabled={createBusy}
                  onClick={() => {
                    setShowCreateForm(false);
                    setCreateError(null);
                  }}
                >
                  Cancel
                </Button>
              </div>
            </form>
          ) : null}
        </CardContent>
      </Card>

      {changeTarget && canEdit ? (
        <ChangeForm
          key={`${changeTarget.item.id}-${changeTarget.mode}`}
          target={changeTarget}
          busy={changeBusy}
          error={changeError}
          onCancel={() => {
            if (!changeBusy) {
              setChangeTarget(null);
              setChangeError(null);
            }
          }}
          onSubmit={(values) => void submitChange(values)}
        />
      ) : null}

      {items.length === 0 ? (
        <Card>
          <CardHeader>
            <CardTitle>
              {deferredSearch.trim() ? 'No matching stock items' : 'No stock items yet'}
            </CardTitle>
            <CardDescription>
              {deferredSearch.trim()
                ? 'Adjust the search text. An empty result is not an error.'
                : canEdit
                  ? 'Create a stock item, then record its opening balance to start the ledger.'
                  : 'No stock items are available for this outlet.'}
            </CardDescription>
          </CardHeader>
          {canEdit && !deferredSearch.trim() ? (
            <CardContent>
              <Button type="button" onClick={() => setShowCreateForm(true)}>
                <Plus aria-hidden="true" className="size-4" />
                New stock item
              </Button>
            </CardContent>
          ) : null}
        </Card>
      ) : (
        <ul className="grid gap-4 xl:grid-cols-2">
          {items.map((item) => (
            <li key={item.id}>
              <Card className="flex h-full flex-col">
                <CardHeader className="gap-3">
                  <div className="flex flex-wrap items-start justify-between gap-2">
                    <div className="min-w-0">
                      <CardTitle className="break-words">{item.name}</CardTitle>
                      <CardDescription className="mt-1">
                        Reorder at {item.reorderThreshold} {item.baseUnit} · ID {shortId(item.id)}
                      </CardDescription>
                    </div>
                    <div className="flex shrink-0 flex-wrap items-center gap-2">
                      <Badge tone="accent">{item.baseUnit}</Badge>
                      <Badge tone="neutral">Precision {item.quantityScale}</Badge>
                      <Badge tone="neutral">Version {item.version}</Badge>
                    </div>
                  </div>
                </CardHeader>
                <CardContent className="flex flex-1 flex-col gap-4">
                  <div className="flex flex-wrap items-end justify-between gap-3 rounded-surface border border-border px-4 py-3">
                    <div className="flex items-center gap-2 text-muted">
                      <Boxes aria-hidden="true" className="size-5" />
                      <span className="text-sm">Current balance</span>
                    </div>
                    <p className="text-2xl font-semibold text-text">
                      {item.quantity}{' '}
                      <span className="text-base font-medium text-muted">{item.baseUnit}</span>
                    </p>
                  </div>

                  <div className="mt-auto flex flex-wrap gap-2">
                    <Button
                      type="button"
                      variant="outline"
                      size="sm"
                      onClick={() => setHistoryItem(item)}
                    >
                      <History aria-hidden="true" className="size-4" />
                      History
                    </Button>
                    {canEdit ? (
                      <>
                        <Button
                          type="button"
                          variant="outline"
                          size="sm"
                          onClick={() => {
                            setChangeError(null);
                            setChangeTarget({ item, mode: 'OPENING' });
                          }}
                        >
                          <ClipboardList aria-hidden="true" className="size-4" />
                          Opening
                        </Button>
                        <Button
                          type="button"
                          variant="outline"
                          size="sm"
                          onClick={() => {
                            setChangeError(null);
                            setChangeTarget({ item, mode: 'RECEIPT' });
                          }}
                        >
                          <PackagePlus aria-hidden="true" className="size-4" />
                          Receipt
                        </Button>
                        <Button
                          type="button"
                          variant="outline"
                          size="sm"
                          onClick={() => {
                            setChangeError(null);
                            setChangeTarget({ item, mode: 'ADJUSTMENT' });
                          }}
                        >
                          <ArrowDownUp aria-hidden="true" className="size-4" />
                          Adjust
                        </Button>
                      </>
                    ) : null}
                  </div>
                </CardContent>
              </Card>
            </li>
          ))}
        </ul>
      )}

      {stockQuery.hasNextPage ? (
        <div className="flex justify-center">
          <Button
            type="button"
            variant="outline"
            onClick={() => void stockQuery.fetchNextPage()}
            disabled={stockQuery.isFetchingNextPage}
          >
            {stockQuery.isFetchingNextPage ? 'Loading more items' : 'Load more items'}
          </Button>
        </div>
      ) : null}

      {historyItem ? (
        <Card>
          <CardHeader>
            <div className="flex flex-wrap items-start justify-between gap-3">
              <div>
                <CardTitle>Movement history · {historyItem.name}</CardTitle>
                <CardDescription>
                  Append-only ledger in {historyItem.baseUnit}. Newest entries appear first.
                </CardDescription>
              </div>
              <Button
                type="button"
                variant="outline"
                size="sm"
                onClick={() => setHistoryItem(null)}
              >
                <Minus aria-hidden="true" className="size-4" />
                Close history
              </Button>
            </div>
          </CardHeader>
          <CardContent>
            {movementsQuery.isPending ? (
              <p className="flex items-center gap-2 text-sm text-muted" role="status">
                <span className="size-5 animate-spin rounded-full border-2 border-border border-t-accent" />
                Loading movements
              </p>
            ) : movementsQuery.isError ? (
              <div>
                <p role="alert" className="text-sm text-danger">
                  {describeApiError(movementsQuery.error, 'Could not load the movement history.')}
                </p>
                <Button
                  type="button"
                  variant="outline"
                  size="sm"
                  className="mt-3"
                  onClick={() => void movementsQuery.refetch()}
                >
                  <RefreshCw aria-hidden="true" className="size-4" />
                  Try again
                </Button>
              </div>
            ) : movements.length === 0 ? (
              <p className="text-sm text-muted">
                No movements yet. Record an opening balance to start the ledger.
              </p>
            ) : (
              <>
                <div className="overflow-x-auto rounded-surface border border-border">
                  <table className="w-full min-w-[640px] text-left text-sm">
                    <thead className="bg-surface-muted text-xs uppercase tracking-wide text-muted">
                      <tr>
                        <th scope="col" className="px-4 py-3 font-medium">
                          Type
                        </th>
                        <th scope="col" className="px-4 py-3 font-medium">
                          Delta
                        </th>
                        <th scope="col" className="px-4 py-3 font-medium">
                          Reason
                        </th>
                        <th scope="col" className="px-4 py-3 font-medium">
                          Reference
                        </th>
                        <th scope="col" className="px-4 py-3 font-medium">
                          Recorded
                        </th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-border">
                      {movements.map((movement) => (
                        <tr key={movement.id}>
                          <td className="px-4 py-3">
                            <Badge tone={movementTone(movement.type)}>{movement.type}</Badge>
                          </td>
                          <td className="px-4 py-3 font-semibold text-text">
                            {movement.delta} {historyItem.baseUnit}
                          </td>
                          <td className="max-w-[280px] break-words px-4 py-3 text-muted">
                            {movement.reason}
                          </td>
                          <td className="px-4 py-3 text-muted">
                            <span className="block">Ref {shortId(movement.sourceId)}</span>
                            <span className="block">Actor {shortId(movement.actorId)}</span>
                          </td>
                          <td className="px-4 py-3 text-muted">
                            {formatTimestamp(movement.createdAt)}
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
                {movementsQuery.hasNextPage ? (
                  <Button
                    type="button"
                    variant="outline"
                    size="sm"
                    className="mt-4"
                    onClick={() => void movementsQuery.fetchNextPage()}
                    disabled={movementsQuery.isFetchingNextPage}
                  >
                    {movementsQuery.isFetchingNextPage
                      ? 'Loading more movements'
                      : 'Load more movements'}
                  </Button>
                ) : null}
              </>
            )}
          </CardContent>
        </Card>
      ) : null}
    </div>
  );
}
