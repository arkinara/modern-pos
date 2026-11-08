'use client';

import { ApiError, type ApiSchemas } from '@modern-pos/api-client';
import { useQuery, useQueryClient } from '@tanstack/react-query';
import { CircleAlert, CircleCheck, Link2, Plus, RefreshCw, Trash2, X } from 'lucide-react';
import { useEffect, useId, useRef, useState } from 'react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { api } from '@/lib/api';
import { describeCatalogError, isVersionConflict } from '@/lib/api-errors';

const inputClass =
  'h-12 w-full min-w-0 rounded-control border border-control bg-surface px-3 text-sm text-text placeholder:text-muted disabled:cursor-not-allowed disabled:bg-surface-muted';

const QUANTITY_PATTERN = /^(0|[1-9]\d*)(\.\d{1,6})?$/;

type Variant = ApiSchemas['Variant'];
type StockItem = ApiSchemas['Stock'];

interface DraftLine {
  key: string;
  stockItemId: string;
  quantity: string;
  unit: string;
}

type Feedback = { tone: 'success' | 'error'; message: string; reload?: boolean };

function baseUnitOf(item: StockItem | undefined): 'g' | 'ml' | 'each' {
  if (item?.baseUnit === 'g' || item?.baseUnit === 'ml') {
    return item.baseUnit;
  }
  return 'each';
}

function unitOptions(item: StockItem | undefined): { value: string; label: string }[] {
  const base = baseUnitOf(item);
  if (base === 'g') {
    return [
      { value: 'g', label: 'g' },
      { value: 'kg', label: 'kg' },
    ];
  }
  if (base === 'ml') {
    return [
      { value: 'ml', label: 'ml' },
      { value: 'l', label: 'l' },
    ];
  }
  return [{ value: 'each', label: 'each' }];
}

function shiftDecimal(value: string, places: number): string {
  const [whole, fraction = ''] = value.split('.');
  const digits = `${whole}${fraction}`;
  const point = whole.length + places;

  if (point >= digits.length) {
    return `${digits}${'0'.repeat(point - digits.length)}`;
  }

  return `${digits.slice(0, point)}.${digits.slice(point)}`;
}

function normalizeDecimal(value: string): string {
  const [whole, fraction = ''] = value.split('.');
  const normalizedWhole = whole.replace(/^0+(?=\d)/, '');
  const normalizedFraction = fraction.replace(/0+$/, '');
  return normalizedFraction.length > 0
    ? `${normalizedWhole}.${normalizedFraction}`
    : normalizedWhole;
}

function fractionDigits(value: string): number {
  const dot = value.indexOf('.');
  return dot === -1 ? 0 : value.length - dot - 1;
}

function toBaseQuantity(value: string, unit: string): string {
  const factor = unit === 'kg' || unit === 'l' ? 3 : 0;
  return normalizeDecimal(factor === 0 ? value : shiftDecimal(value, factor));
}

function rateLabel(item: StockItem | undefined): string {
  if (!item) {
    return 'Choose a stock item to see its base unit.';
  }
  return `Base unit ${item.baseUnit}; up to ${item.quantityScale} decimal place(s).`;
}

function blankLine(): DraftLine {
  return {
    key: Math.random().toString(36).slice(2),
    stockItemId: '',
    quantity: '',
    unit: '',
  };
}

function fromRecipe(recipe: ApiSchemas['Recipe'], stock: StockItem[]): DraftLine[] {
  return recipe.lines.map((line) => {
    const item = stock.find((stockItem) => stockItem.id === line.stockItemId);
    return {
      key: Math.random().toString(36).slice(2),
      stockItemId: line.stockItemId,
      quantity: line.quantityPerSaleUnit,
      unit: baseUnitOf(item),
    };
  });
}

function isMissingRecipe(error: unknown): boolean {
  return error instanceof ApiError && error.status === 404;
}

function describeRecipeError(error: unknown, fallback: string): string {
  if (!(error instanceof ApiError)) {
    return fallback;
  }

  if (error.status === 400 || error.status === 422) {
    const body = error.body;
    if (typeof body === 'object' && body !== null && 'message' in body) {
      const message = (body as { message: unknown }).message;
      if (typeof message === 'string') {
        return message;
      }
    }
    return 'The server rejected these recipe values. Check quantities, precision and stock items.';
  }

  return describeCatalogError(error, fallback);
}

export function RecipeDialog({
  open,
  outletId,
  variant,
  onClose,
  onSaved,
}: {
  open: boolean;
  outletId: string;
  variant: Variant;
  onClose: () => void;
  onSaved: (message: string) => void;
}) {
  const fieldId = useId();
  const dialogRef = useRef<HTMLDialogElement>(null);
  const queryClient = useQueryClient();
  const [lines, setLines] = useState<DraftLine[]>([blankLine()]);
  const [loadedVersion, setLoadedVersion] = useState<number | undefined>(undefined);
  const [saving, setSaving] = useState(false);
  const [feedback, setFeedback] = useState<Feedback | null>(null);

  const stockQuery = useQuery({
    queryKey: ['recipe-stock', outletId],
    queryFn: () => api.listStock(outletId, { limit: 100 }),
    enabled: open,
    retry: 1,
  });

  const recipeQuery = useQuery({
    queryKey: ['recipe', outletId, variant.id],
    queryFn: () => api.getRecipe(outletId, variant.id),
    enabled: open,
    retry: 1,
  });

  const stock = stockQuery.data?.items ?? [];

  useEffect(() => {
    const dialog = dialogRef.current;
    if (!dialog) {
      return;
    }

    if (open && !dialog.open) {
      dialog.showModal();
    }

    if (!open && dialog.open) {
      dialog.close();
    }
  }, [open]);

  useEffect(() => {
    if (!open) {
      return;
    }

    if (recipeQuery.isSuccess && stockQuery.isSuccess) {
      if (loadedVersion !== recipeQuery.data.version) {
        setLines(fromRecipe(recipeQuery.data, stock));
        setLoadedVersion(recipeQuery.data.version);
      }
      return;
    }

    if (
      recipeQuery.isError &&
      isMissingRecipe(recipeQuery.error) &&
      stockQuery.isSuccess &&
      loadedVersion !== 0
    ) {
      setLines([blankLine()]);
      setLoadedVersion(0);
    }
  }, [
    open,
    recipeQuery.isSuccess,
    recipeQuery.isError,
    recipeQuery.data,
    recipeQuery.error,
    stockQuery.isSuccess,
    stock,
    loadedVersion,
  ]);

  if (!open) {
    return null;
  }

  const currentVersion = recipeQuery.isSuccess ? recipeQuery.data.version : 0;
  const nextVersion = currentVersion + 1;
  const loading = recipeQuery.isPending || stockQuery.isPending;
  const loadFailed = recipeQuery.isError && !isMissingRecipe(recipeQuery.error);
  const stockFailed = stockQuery.isError;

  function updateLine(key: string, patch: Partial<DraftLine>): void {
    setLines((current) => current.map((line) => (line.key === key ? { ...line, ...patch } : line)));
    setFeedback(null);
  }

  function changeStockItem(key: string, stockItemId: string): void {
    const item = stock.find((stockItem) => stockItem.id === stockItemId);
    updateLine(key, { stockItemId, unit: baseUnitOf(item) });
  }

  function addLine(): void {
    if (lines.length >= 100) {
      setFeedback({ tone: 'error', message: 'A recipe can have at most 100 lines.' });
      return;
    }
    setLines((current) => [...current, blankLine()]);
  }

  function removeLine(key: string): void {
    setLines((current) =>
      current.length === 1 ? [blankLine()] : current.filter((line) => line.key !== key),
    );
    setFeedback(null);
  }

  async function reloadLatest(): Promise<void> {
    setFeedback(null);
    setLoadedVersion(undefined);
    const result = await recipeQuery.refetch();
    if (result.data) {
      setLines(fromRecipe(result.data, stock));
      setLoadedVersion(result.data.version);
    }
  }

  async function submit(): Promise<void> {
    const converted: ApiSchemas['RecipeWrite']['lines'] = [];
    const seen = new Set<string>();

    for (const [index, line] of lines.entries()) {
      const label = `Line ${index + 1}`;
      if (!line.stockItemId) {
        setFeedback({ tone: 'error', message: `${label}: choose a stock item.` });
        return;
      }

      if (seen.has(line.stockItemId)) {
        setFeedback({
          tone: 'error',
          message: `${label}: each stock item can appear only once per recipe.`,
        });
        return;
      }
      seen.add(line.stockItemId);

      const item = stock.find((stockItem) => stockItem.id === line.stockItemId);
      if (!item) {
        setFeedback({
          tone: 'error',
          message: `${label}: that stock item is no longer available.`,
        });
        return;
      }

      const trimmed = line.quantity.trim();
      if (!QUANTITY_PATTERN.test(trimmed)) {
        setFeedback({
          tone: 'error',
          message: `${label}: enter a positive decimal with up to six places (for example 0.25).`,
        });
        return;
      }

      const baseQuantity = toBaseQuantity(trimmed, line.unit || item.baseUnit);

      if (baseQuantity === '0') {
        setFeedback({ tone: 'error', message: `${label}: quantity must be greater than zero.` });
        return;
      }

      if (fractionDigits(baseQuantity) > item.quantityScale) {
        setFeedback({
          tone: 'error',
          message: `${label}: ${trimmed} ${line.unit || item.baseUnit} becomes ${baseQuantity} ${item.baseUnit}, which has more decimals than this item allows (${item.quantityScale}).`,
        });
        return;
      }

      converted.push({ stockItemId: line.stockItemId, quantityPerSaleUnit: baseQuantity });
    }

    setSaving(true);
    setFeedback(null);
    try {
      const saved = await api.publishRecipe(outletId, variant.id, {
        expectedVersion: currentVersion,
        lines: converted,
      });
      await queryClient.invalidateQueries({ queryKey: ['recipe', outletId, variant.id] });
      setLines(fromRecipe(saved, stock));
      setLoadedVersion(saved.version);
      const message =
        converted.length === 1
          ? `Recipe version ${saved.version} published. This variant is linked directly to one stock item.`
          : `Recipe version ${saved.version} published with ${converted.length} ingredient lines.`;
      setFeedback({ tone: 'success', message });
      onSaved(message);
    } catch (error) {
      if (isVersionConflict(error)) {
        setFeedback({
          tone: 'error',
          message:
            'Another recipe version was published first. Reload the latest version, review the lines, then publish again.',
          reload: true,
        });
      } else {
        setFeedback({
          tone: 'error',
          message: describeRecipeError(error, 'Could not publish the recipe. Nothing was changed.'),
        });
      }
    } finally {
      setSaving(false);
    }
  }

  return (
    <dialog
      ref={dialogRef}
      aria-labelledby={`${fieldId}-title`}
      onClose={onClose}
      className="m-auto w-[calc(100vw-1rem)] max-w-[calc(100vw-1rem)] rounded-panel border border-border bg-surface p-0 text-text shadow-xl backdrop:bg-ink/40 sm:w-[36rem] lg:w-[42rem]"
    >
      <div className="max-h-[85vh] overflow-y-auto p-4 sm:p-6">
        <div className="flex items-start justify-between gap-3">
          <div className="min-w-0">
            <h2 id={`${fieldId}-title`} className="text-xl font-semibold tracking-tight text-text">
              Recipe for {variant.name}
            </h2>
            <p className="mt-1 text-sm text-muted">
              {currentVersion > 0
                ? `Current version ${currentVersion} is immutable. Publishing writes version ${nextVersion}.`
                : `No recipe yet. Publishing writes version ${nextVersion}.`}
            </p>
          </div>
          <Button type="button" variant="outline" size="sm" onClick={onClose} disabled={saving}>
            <X aria-hidden="true" className="size-4" />
            Close
          </Button>
        </div>

        {loading ? (
          <div className="flex min-h-40 flex-col items-center justify-center gap-3" role="status">
            <span className="size-8 animate-spin rounded-full border-2 border-border border-t-accent" />
            <p className="text-sm text-muted">Loading recipe</p>
          </div>
        ) : loadFailed ? (
          <Card className="mt-4">
            <CardHeader>
              <CardTitle>Could not load the recipe</CardTitle>
              <CardDescription role="alert" className="text-danger">
                {describeCatalogError(
                  recipeQuery.error,
                  'The recipe request failed. Check the API connection and try again.',
                )}
              </CardDescription>
            </CardHeader>
            <CardContent>
              <Button
                type="button"
                variant="outline"
                onClick={() => {
                  void recipeQuery.refetch();
                  void stockQuery.refetch();
                }}
              >
                <RefreshCw aria-hidden="true" className="size-4" />
                Try again
              </Button>
            </CardContent>
          </Card>
        ) : (
          <div className="mt-4 flex flex-col gap-4">
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
                  <Button
                    type="button"
                    variant="outline"
                    size="sm"
                    onClick={() => void reloadLatest()}
                  >
                    <RefreshCw aria-hidden="true" className="size-4" />
                    Reload latest
                  </Button>
                ) : null}
              </div>
            ) : null}

            {variant.stockPolicy === 'UNTRACKED' ? (
              <p className="rounded-control bg-warning-soft px-4 py-3 text-sm text-warning">
                This variant is untracked, so the recipe is stored but stock is not consumed at
                sale. Set the variant stock policy to Tracked in Edit product to make this recipe
                drive stock.
              </p>
            ) : null}

            {stockFailed ? (
              <p
                className="rounded-control bg-danger-soft px-4 py-3 text-sm text-danger"
                role="alert"
              >
                Could not load stock items. Recipe editing needs the stock list; try again.
              </p>
            ) : null}

            {stockQuery.isSuccess && stock.length === 0 ? (
              <p className="rounded-control bg-warning-soft px-4 py-3 text-sm text-warning">
                No stock items exist yet. Create a stock item on the Stock page before linking this
                variant.
              </p>
            ) : null}

            <div className="flex items-center gap-2 text-sm text-muted">
              <Link2 aria-hidden="true" className="size-4" />
              <span>
                One line links the variant directly to a finished goods item. Multiple lines define
                ingredient quantities per sold unit.
              </span>
            </div>

            <div className="flex flex-col gap-3">
              {lines.map((line, index) => {
                const item = stock.find((stockItem) => stockItem.id === line.stockItemId);
                return (
                  <div
                    key={line.key}
                    className="flex flex-col gap-3 rounded-surface border border-border bg-surface-tint p-3 sm:flex-row sm:items-end"
                  >
                    <div className="flex min-w-0 flex-1 flex-col gap-2">
                      <label
                        className="text-sm font-medium text-text"
                        htmlFor={`${fieldId}-item-${line.key}`}
                      >
                        Stock item {index + 1}
                      </label>
                      <select
                        id={`${fieldId}-item-${line.key}`}
                        className={inputClass}
                        value={line.stockItemId}
                        onChange={(event) => changeStockItem(line.key, event.target.value)}
                        disabled={stock.length === 0}
                      >
                        <option value="">Choose a stock item</option>
                        {stock.map((stockItem) => (
                          <option key={stockItem.id} value={stockItem.id}>
                            {stockItem.name} ({stockItem.baseUnit})
                          </option>
                        ))}
                      </select>
                    </div>
                    <div className="flex min-w-0 gap-2 sm:flex-none">
                      <div className="flex min-w-0 flex-1 flex-col gap-2 sm:w-28">
                        <label
                          className="text-sm font-medium text-text"
                          htmlFor={`${fieldId}-quantity-${line.key}`}
                        >
                          Quantity per sold unit
                        </label>
                        <input
                          id={`${fieldId}-quantity-${line.key}`}
                          className={inputClass}
                          inputMode="decimal"
                          placeholder="1"
                          value={line.quantity}
                          maxLength={20}
                          onChange={(event) =>
                            updateLine(line.key, { quantity: event.target.value })
                          }
                        />
                      </div>
                      <div className="flex w-24 flex-col gap-2">
                        <label
                          className="text-sm font-medium text-text"
                          htmlFor={`${fieldId}-unit-${line.key}`}
                        >
                          Unit
                        </label>
                        <select
                          id={`${fieldId}-unit-${line.key}`}
                          className={inputClass}
                          value={line.unit || baseUnitOf(item)}
                          onChange={(event) => updateLine(line.key, { unit: event.target.value })}
                        >
                          {unitOptions(item).map((option) => (
                            <option key={option.value} value={option.value}>
                              {option.label}
                            </option>
                          ))}
                        </select>
                      </div>
                    </div>
                    <Button
                      type="button"
                      variant="outline"
                      size="sm"
                      onClick={() => removeLine(line.key)}
                      disabled={saving}
                      aria-label={`Remove line ${index + 1}`}
                    >
                      <Trash2 aria-hidden="true" className="size-4" />
                      Remove
                    </Button>
                    <p className="w-full text-xs text-muted sm:w-auto">{rateLabel(item)}</p>
                  </div>
                );
              })}
            </div>

            <div className="flex flex-wrap items-center gap-3">
              <Button type="button" variant="outline" onClick={addLine} disabled={saving}>
                <Plus aria-hidden="true" className="size-4" />
                Add ingredient
              </Button>
              <Button
                type="button"
                onClick={() => void submit()}
                disabled={saving || stock.length === 0 || stockFailed}
              >
                {saving ? 'Publishing' : `Publish recipe version ${nextVersion}`}
              </Button>
            </div>
            <p className="text-xs text-muted">
              Quantities are converted to the stock item base unit before saving. kg multiplies
              grams by 1000, l multiplies millilitres by 1000, and each is sent unchanged.
            </p>
          </div>
        )}
      </div>
    </dialog>
  );
}
