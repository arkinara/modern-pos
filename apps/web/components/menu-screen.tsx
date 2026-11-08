'use client';

import type { ApiSchemas } from '@modern-pos/api-client';
import { useInfiniteQuery, useQuery, useQueryClient } from '@tanstack/react-query';
import { Archive, CircleAlert, CircleCheck, Pencil, Plus, RefreshCw, Search } from 'lucide-react';
import { useDeferredValue, useState } from 'react';
import { ConfirmDialog } from '@/components/confirm-dialog';
import { MenuForm, type CatalogFormValues } from '@/components/menu-form';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { api } from '@/lib/api';
import { describeCatalogError, describeApiError, isVersionConflict } from '@/lib/api-errors';
import { useAuth } from '@/lib/auth';
import { useActiveOutletId } from '@/lib/use-active-outlet';

type Feedback = { tone: 'success' | 'error'; message: string; reload?: boolean };

function groupWhole(whole: string): string {
  return whole.replace(/\B(?=(\d{3})+(?!\d))/g, ',');
}

function formatMoney(value: number, exponent: number, currency: string): string {
  const digits = String(value).padStart(exponent + 1, '0');
  const whole = exponent === 0 ? digits : digits.slice(0, -exponent);
  const fraction = exponent === 0 ? '' : `.${digits.slice(-exponent)}`;
  return `${currency ? `${currency} ` : ''}${groupWhole(whole)}${fraction}`;
}

function variantChanges(
  menu: ApiSchemas['Menu'],
  values: CatalogFormValues,
): { variantId: string; update: ApiSchemas['VariantUpdate'] }[] {
  const changes: { variantId: string; update: ApiSchemas['VariantUpdate'] }[] = [];

  for (const draft of values.variants) {
    const original = menu.variants.find((variant) => variant.id === draft.id);
    if (!original) {
      continue;
    }

    const priceMinor = Number(draft.price);
    if (
      original.name !== draft.name ||
      original.priceMinor !== priceMinor ||
      original.stockPolicy !== draft.stockPolicy ||
      original.enabled !== draft.enabled
    ) {
      changes.push({
        variantId: original.id,
        update: {
          name: draft.name,
          priceMinor,
          stockPolicy: draft.stockPolicy,
          enabled: draft.enabled,
          revision: original.revision,
        },
      });
    }
  }

  return changes;
}

export function MenuScreen() {
  const { user } = useAuth();
  const outletId = useActiveOutletId();
  const queryClient = useQueryClient();
  const canEdit = user?.role === 'OWNER';

  const [search, setSearch] = useState('');
  const deferredSearch = useDeferredValue(search);
  const [categoryFilter, setCategoryFilter] = useState('ALL');
  const [showCategoryForm, setShowCategoryForm] = useState(false);
  const [categoryName, setCategoryName] = useState('');
  const [categorySaving, setCategorySaving] = useState(false);
  const [categoryError, setCategoryError] = useState<string | null>(null);
  const [formOpen, setFormOpen] = useState(false);
  const [editing, setEditing] = useState<ApiSchemas['Menu'] | null>(null);
  const [saving, setSaving] = useState(false);
  const [formError, setFormError] = useState<string | null>(null);
  const [feedback, setFeedback] = useState<Feedback | null>(null);
  const [archiveTarget, setArchiveTarget] = useState<ApiSchemas['Menu'] | null>(null);
  const [archiving, setArchiving] = useState(false);

  const settingsQuery = useQuery({
    queryKey: ['settings', outletId],
    queryFn: () => api.getSettings(outletId as string),
    enabled: outletId !== null,
    retry: 1,
  });

  const categoriesQuery = useQuery({
    queryKey: ['catalog-categories', outletId],
    queryFn: () => api.getCategories(outletId as string),
    enabled: outletId !== null,
    retry: 1,
  });

  const menuQuery = useInfiniteQuery({
    queryKey: ['catalog-menu', outletId, deferredSearch],
    queryFn: ({ pageParam }) =>
      api.listMenu(outletId as string, {
        limit: 100,
        cursor: pageParam,
        search: deferredSearch.trim() || undefined,
      }),
    enabled: outletId !== null,
    initialPageParam: undefined as string | undefined,
    getNextPageParam: (lastPage) => lastPage.nextCursor ?? undefined,
    retry: 1,
  });

  const currency = settingsQuery.data?.currency ?? '';
  const exponent = settingsQuery.data?.currencyExponent ?? 0;

  if (!outletId) {
    return (
      <div className="w-full">
        <Card>
          <CardHeader>
            <CardTitle>No outlet assigned</CardTitle>
            <CardDescription>
              This account has no outlet scope, so the menu cannot be loaded.
            </CardDescription>
          </CardHeader>
        </Card>
      </div>
    );
  }

  const categories = categoriesQuery.data ?? [];
  const categoryNames = new Map(categories.map((category) => [category.id, category.name]));
  const menuItems = menuQuery.data?.pages.flatMap((page) => page.items) ?? [];
  const filteredItems =
    categoryFilter === 'ALL'
      ? menuItems
      : menuItems.filter((item) => item.categoryId === categoryFilter);
  const archivedCount = menuItems.filter((item) => item.archived).length;

  const initialLoading = categoriesQuery.isPending || menuQuery.isPending;
  const loadError = categoriesQuery.isError || menuQuery.isError;

  function reloadCatalog(): void {
    setFeedback(null);
    void queryClient.invalidateQueries({ queryKey: ['catalog-categories', outletId] });
    void queryClient.invalidateQueries({ queryKey: ['catalog-menu', outletId] });
  }

  function openCreateForm(): void {
    setEditing(null);
    setFormError(null);
    setFeedback(null);
    setFormOpen(true);
  }

  function openEditForm(menu: ApiSchemas['Menu']): void {
    setEditing(menu);
    setFormError(null);
    setFeedback(null);
    setFormOpen(true);
  }

  function closeForm(): void {
    if (saving) {
      return;
    }
    setFormOpen(false);
    setEditing(null);
    setFormError(null);
  }

  async function createCategory(): Promise<void> {
    if (!outletId) {
      return;
    }

    const name = categoryName.trim();
    if (name.length === 0) {
      setCategoryError('Category name is required.');
      return;
    }

    setCategorySaving(true);
    setCategoryError(null);
    try {
      await api.createCategory(outletId, { name });
      await queryClient.invalidateQueries({ queryKey: ['catalog-categories', outletId] });
      setCategoryName('');
      setShowCategoryForm(false);
      setFeedback({ tone: 'success', message: `Category "${name}" created.` });
    } catch (error) {
      setCategoryError(
        describeCatalogError(error, 'Could not create the category. Nothing was changed.'),
      );
    } finally {
      setCategorySaving(false);
    }
  }

  async function submitProduct(values: CatalogFormValues): Promise<void> {
    if (!outletId) {
      return;
    }

    setSaving(true);
    setFormError(null);
    setFeedback(null);

    try {
      if (editing) {
        await api.updateMenu(outletId, editing.id, {
          name: values.name,
          description: values.description,
          categoryId: values.categoryId,
          revision: editing.revision,
        });

        for (const change of variantChanges(editing, values)) {
          await api.updateVariant(outletId, change.variantId, change.update);
        }
      } else {
        await api.createMenu(outletId, {
          name: values.name,
          description: values.description,
          categoryId: values.categoryId,
          variants: values.variants.map((variant) => ({
            name: variant.name,
            priceMinor: Number(variant.price),
            stockPolicy: variant.stockPolicy,
          })),
        });
      }

      await queryClient.invalidateQueries({ queryKey: ['catalog-menu', outletId] });
      setFeedback({
        tone: 'success',
        message: editing
          ? 'Product saved. The next Android catalog refresh will show the new values.'
          : 'Product created. The next Android catalog refresh will show it.',
      });
      setFormOpen(false);
      setEditing(null);
    } catch (error) {
      const conflict = isVersionConflict(error);
      setFormError(describeCatalogError(error, 'Could not save the product. Nothing was changed.'));
      if (conflict) {
        setFeedback({
          tone: 'error',
          message:
            'Another change saved first. Reload the latest catalog, then reopen this product and reapply your edits.',
          reload: true,
        });
      }
    } finally {
      setSaving(false);
    }
  }

  async function archiveMenu(): Promise<void> {
    if (!outletId || !archiveTarget) {
      return;
    }

    setArchiving(true);
    setFeedback(null);
    try {
      await api.archiveMenu(outletId, archiveTarget.id, archiveTarget.revision);
      await queryClient.invalidateQueries({ queryKey: ['catalog-menu', outletId] });
      setFeedback({
        tone: 'success',
        message: `"${archiveTarget.name}" archived. Its record and sales history stay readable.`,
      });
      setArchiveTarget(null);
    } catch (error) {
      setFeedback({
        tone: 'error',
        message: describeCatalogError(error, 'Could not archive the product. Nothing was changed.'),
        reload: isVersionConflict(error),
      });
      setArchiveTarget(null);
    } finally {
      setArchiving(false);
    }
  }

  if (initialLoading) {
    return (
      <div className="w-full" role="status" aria-live="polite">
        <Card>
          <CardContent className="flex min-h-48 flex-col items-center justify-center gap-3 pt-6">
            <span className="size-8 animate-spin rounded-full border-2 border-border border-t-accent" />
            <p className="text-sm text-muted">Loading menu</p>
          </CardContent>
        </Card>
      </div>
    );
  }

  if (loadError) {
    return (
      <div className="w-full">
        <Card>
          <CardHeader>
            <CardTitle>Could not load the menu</CardTitle>
            <CardDescription role="alert" className="text-danger">
              {describeApiError(
                categoriesQuery.error ?? menuQuery.error,
                'The catalog request failed. Check the API connection and try again.',
              )}
            </CardDescription>
          </CardHeader>
          <CardContent>
            <Button
              type="button"
              variant="outline"
              onClick={() => {
                void categoriesQuery.refetch();
                void menuQuery.refetch();
              }}
            >
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
          <h1 className="text-3xl font-semibold tracking-tight text-text">Menu</h1>
          <p className="mt-2 max-w-3xl text-sm text-muted">
            Categories, products, variants and prices for this outlet. Server records are
            authoritative; the Android app sees catalog changes after its next refresh.
          </p>
        </div>
        <div className="flex flex-wrap items-center gap-2">
          {menuQuery.isFetching ? (
            <p className="flex items-center gap-2 text-sm text-muted" role="status">
              <RefreshCw aria-hidden="true" className="size-4 animate-spin" />
              Refreshing
            </p>
          ) : null}
          <Button type="button" variant="outline" onClick={reloadCatalog}>
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
            <Button type="button" variant="outline" size="sm" onClick={reloadCatalog}>
              <RefreshCw aria-hidden="true" className="size-4" />
              Reload catalog
            </Button>
          ) : null}
        </div>
      ) : null}

      {!canEdit ? (
        <div className="rounded-control bg-warning-soft px-4 py-3 text-sm text-warning">
          This is a read-only catalog view. Only an owner can create or change products.
        </div>
      ) : null}

      <Card>
        <CardHeader>
          <CardTitle>Catalog tools</CardTitle>
          <CardDescription>
            Search by product name or description, filter by category, and manage categories.
          </CardDescription>
        </CardHeader>
        <CardContent className="flex flex-col gap-4">
          <div className="grid gap-4 md:grid-cols-3 xl:grid-cols-4">
            <div className="flex flex-col gap-2 md:col-span-2">
              <label className="text-sm font-medium text-text" htmlFor="catalog-search">
                Search products
              </label>
              <div className="relative">
                <Search
                  aria-hidden="true"
                  className="pointer-events-none absolute left-3 top-1/2 size-4 -translate-y-1/2 text-muted"
                />
                <input
                  id="catalog-search"
                  className="h-12 w-full rounded-control border border-control bg-surface pl-9 pr-3 text-sm text-text placeholder:text-muted"
                  placeholder="Search name or description"
                  maxLength={100}
                  value={search}
                  onChange={(event) => setSearch(event.target.value)}
                />
              </div>
            </div>

            <div className="flex flex-col gap-2">
              <label className="text-sm font-medium text-text" htmlFor="catalog-category">
                Category filter
              </label>
              <select
                id="catalog-category"
                className="h-12 w-full rounded-control border border-control bg-surface px-3 text-sm text-text"
                value={categoryFilter}
                onChange={(event) => setCategoryFilter(event.target.value)}
              >
                <option value="ALL">All categories</option>
                {categories.map((category) => (
                  <option key={category.id} value={category.id}>
                    {category.name}
                    {category.archived ? ' (archived)' : ''}
                  </option>
                ))}
              </select>
            </div>
          </div>

          {canEdit ? (
            <div className="flex flex-wrap items-center gap-3">
              <Button
                type="button"
                onClick={openCreateForm}
                disabled={showCategoryForm && categories.length === 0}
              >
                <Plus aria-hidden="true" className="size-4" />
                New product
              </Button>
              <Button
                type="button"
                variant="outline"
                onClick={() => {
                  setShowCategoryForm((current) => !current);
                  setCategoryError(null);
                }}
              >
                <Plus aria-hidden="true" className="size-4" />
                {showCategoryForm ? 'Close category form' : 'New category'}
              </Button>
              <span className="text-sm text-muted">
                {menuItems.length} product{menuItems.length === 1 ? '' : 's'} · {categories.length}{' '}
                categor{categories.length === 1 ? 'y' : 'ies'}
                {archivedCount > 0 ? ` · ${archivedCount} archived` : ''}
              </span>
            </div>
          ) : null}

          {canEdit && showCategoryForm ? (
            <form
              className="rounded-surface border border-border bg-surface-tint p-4"
              onSubmit={(event) => {
                event.preventDefault();
                void createCategory();
              }}
            >
              <div className="flex flex-col gap-3 sm:flex-row sm:items-end">
                <div className="flex flex-1 flex-col gap-2">
                  <label className="text-sm font-medium text-text" htmlFor="category-name">
                    Category name
                  </label>
                  <input
                    id="category-name"
                    className="h-12 w-full rounded-control border border-control bg-surface px-3 text-sm text-text placeholder:text-muted"
                    maxLength={200}
                    placeholder="Desserts"
                    value={categoryName}
                    onChange={(event) => setCategoryName(event.target.value)}
                    aria-invalid={Boolean(categoryError)}
                  />
                </div>
                <Button type="submit" disabled={categorySaving}>
                  {categorySaving ? 'Creating category' : 'Create category'}
                </Button>
              </div>
              {categoryError ? (
                <p role="alert" className="mt-3 text-sm text-danger">
                  {categoryError}
                </p>
              ) : null}
            </form>
          ) : null}
        </CardContent>
      </Card>

      {formOpen ? (
        <MenuForm
          key={editing?.id ?? 'create'}
          categories={categories}
          menu={editing ?? undefined}
          saving={saving}
          error={formError}
          onSubmit={(values) => void submitProduct(values)}
          onCancel={closeForm}
        />
      ) : null}

      {filteredItems.length === 0 ? (
        <Card>
          <CardHeader>
            <CardTitle>
              {search.trim() || categoryFilter !== 'ALL'
                ? 'No matching products'
                : 'No products yet'}
            </CardTitle>
            <CardDescription>
              {search.trim() || categoryFilter !== 'ALL'
                ? 'Adjust the search text or category filter. An empty result is not an error.'
                : canEdit
                  ? 'Create a category first, then add a product with at least one variant.'
                  : 'No menu products are available for this outlet.'}
            </CardDescription>
          </CardHeader>
          {canEdit && categories.length > 0 ? (
            <CardContent>
              <Button type="button" onClick={openCreateForm}>
                <Plus aria-hidden="true" className="size-4" />
                New product
              </Button>
            </CardContent>
          ) : null}
        </Card>
      ) : (
        <ul className="grid gap-4 xl:grid-cols-2">
          {filteredItems.map((item) => (
            <li key={item.id}>
              <Card className="flex h-full flex-col">
                <CardHeader className="gap-3">
                  <div className="flex flex-wrap items-start justify-between gap-2">
                    <div className="min-w-0">
                      <CardTitle className="break-words">{item.name}</CardTitle>
                      <CardDescription className="mt-1 break-words">
                        {item.description || 'No description.'}
                      </CardDescription>
                    </div>
                    <div className="flex shrink-0 flex-wrap items-center gap-2">
                      {item.archived ? <Badge tone="warning">Archived</Badge> : null}
                      <Badge tone="neutral">
                        {categoryNames.get(item.categoryId) ?? 'Unknown category'}
                      </Badge>
                    </div>
                  </div>
                  <p className="text-xs text-muted">
                    Revision {item.revision} · ID {item.id.slice(0, 8)}
                  </p>
                </CardHeader>
                <CardContent className="flex flex-1 flex-col gap-4">
                  <ul className="flex flex-col divide-y divide-border rounded-surface border border-border">
                    {item.variants.map((variant) => (
                      <li
                        key={variant.id}
                        className="flex flex-wrap items-center justify-between gap-3 px-4 py-3"
                      >
                        <div className="min-w-0">
                          <p className="break-words text-sm font-medium text-text">
                            {variant.name}
                          </p>
                          <p className="text-xs text-muted">
                            ID {variant.id.slice(0, 8)} · revision {variant.revision}
                          </p>
                        </div>
                        <div className="flex flex-wrap items-center gap-2">
                          <span className="text-sm font-semibold text-text">
                            {formatMoney(variant.priceMinor, exponent, currency)}
                          </span>
                          <Badge tone={variant.stockPolicy === 'TRACKED' ? 'accent' : 'neutral'}>
                            {variant.stockPolicy === 'TRACKED' ? 'Tracked' : 'Untracked'}
                          </Badge>
                          <Badge tone={variant.enabled ? 'success' : 'danger'}>
                            {variant.enabled ? 'Enabled' : 'Disabled'}
                          </Badge>
                        </div>
                        {variant.stockPolicy === 'TRACKED' && variant.availableUnits === null ? (
                          <p className="w-full text-xs text-muted">
                            Availability unknown until the stock ledger arrives in ticket #7.
                          </p>
                        ) : null}
                      </li>
                    ))}
                  </ul>

                  {item.archived ? (
                    <p className="text-sm text-muted">
                      Archived products stay readable with historical sales but are excluded from
                      the saleable catalog.
                    </p>
                  ) : canEdit ? (
                    <div className="mt-auto flex flex-wrap gap-3">
                      <Button type="button" variant="outline" onClick={() => openEditForm(item)}>
                        <Pencil aria-hidden="true" className="size-4" />
                        Edit
                      </Button>
                      <Button
                        type="button"
                        variant="outline"
                        onClick={() => {
                          setFeedback(null);
                          setArchiveTarget(item);
                        }}
                      >
                        <Archive aria-hidden="true" className="size-4" />
                        Archive
                      </Button>
                    </div>
                  ) : null}
                </CardContent>
              </Card>
            </li>
          ))}
        </ul>
      )}

      {menuQuery.hasNextPage ? (
        <div className="flex justify-center">
          <Button
            type="button"
            variant="outline"
            onClick={() => void menuQuery.fetchNextPage()}
            disabled={menuQuery.isFetchingNextPage}
          >
            {menuQuery.isFetchingNextPage ? 'Loading more products' : 'Load more products'}
          </Button>
        </div>
      ) : null}

      <ConfirmDialog
        open={archiveTarget !== null}
        title="Archive product?"
        description={
          archiveTarget
            ? `"${archiveTarget.name}" will stop appearing as saleable. The record is preserved and stays readable with its sales history.`
            : ''
        }
        confirmLabel="Archive product"
        busy={archiving}
        onConfirm={() => void archiveMenu()}
        onCancel={() => {
          if (!archiving) {
            setArchiveTarget(null);
          }
        }}
      />
    </div>
  );
}
