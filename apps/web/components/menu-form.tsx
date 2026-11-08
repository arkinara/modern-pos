'use client';

import type { ApiSchemas } from '@modern-pos/api-client';
import { CircleAlert, Plus, Save, Trash2, X } from 'lucide-react';
import { useId, useState } from 'react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';

export type CatalogFormValues = {
  name: string;
  description: string;
  categoryId: string;
  revision?: number;
  variants: CatalogVariantValues[];
};

export type CatalogVariantValues = {
  id?: string;
  revision?: number;
  name: string;
  price: string;
  stockPolicy: ApiSchemas['Variant']['stockPolicy'];
  enabled: boolean;
};

const inputClass =
  'h-12 w-full rounded-control border border-control bg-surface px-3 text-sm text-text placeholder:text-muted disabled:cursor-not-allowed disabled:bg-surface-muted';

const MAX_PRICE_MINOR = 9_007_199_254_740_991;

function emptyVariant(): CatalogVariantValues {
  return {
    name: 'Default',
    price: '0',
    stockPolicy: 'UNTRACKED',
    enabled: true,
  };
}

function initialValues(
  categories: ApiSchemas['Category'][],
  menu?: ApiSchemas['Menu'],
): CatalogFormValues {
  if (menu) {
    return {
      name: menu.name,
      description: menu.description,
      categoryId: menu.categoryId,
      revision: menu.revision,
      variants: menu.variants.map((variant) => ({
        id: variant.id,
        revision: variant.revision,
        name: variant.name,
        price: String(variant.priceMinor),
        stockPolicy: variant.stockPolicy,
        enabled: variant.enabled,
      })),
    };
  }

  return {
    name: '',
    description: '',
    categoryId: categories[0]?.id ?? '',
    variants: [emptyVariant()],
  };
}

export function MenuForm({
  categories,
  menu,
  saving,
  error,
  onSubmit,
  onCancel,
}: {
  categories: ApiSchemas['Category'][];
  menu?: ApiSchemas['Menu'];
  saving: boolean;
  error: string | null;
  onSubmit: (values: CatalogFormValues) => void;
  onCancel: () => void;
}) {
  const fieldId = useId();
  const isEdit = Boolean(menu);
  const [values, setValues] = useState<CatalogFormValues>(() => initialValues(categories, menu));
  const [issues, setIssues] = useState<string[]>([]);

  const archivedCategories = categories.filter((category) => !category.archived);

  function updateVariant(index: number, patch: Partial<CatalogVariantValues>): void {
    setValues((current) => ({
      ...current,
      variants: current.variants.map((variant, itemIndex) =>
        itemIndex === index ? { ...variant, ...patch } : variant,
      ),
    }));
  }

  function validate(): string[] {
    const found: string[] = [];

    if (values.name.trim().length === 0) {
      found.push('Product name is required.');
    }

    if (values.name.trim().length > 200) {
      found.push('Product name must be 200 characters or fewer.');
    }

    if (values.description.length > 2000) {
      found.push('Description must be 2000 characters or fewer.');
    }

    if (!values.categoryId) {
      found.push('Choose a category.');
    }

    if (values.variants.length === 0) {
      found.push('Add at least one variant.');
    }

    if (values.variants.length > 50) {
      found.push('A product can have at most 50 variants.');
    }

    for (const [index, variant] of values.variants.entries()) {
      const label = `Variant ${index + 1}`;
      if (variant.name.trim().length === 0) {
        found.push(`${label}: name is required.`);
      }
      if (!/^\d+$/.test(variant.price.trim())) {
        found.push(`${label}: price must be a whole nonnegative number of minor units.`);
        continue;
      }
      const price = Number(variant.price);
      if (!Number.isSafeInteger(price) || price < 0 || price > MAX_PRICE_MINOR) {
        found.push(`${label}: price is outside the supported range.`);
      }
    }

    return found;
  }

  function submit(): void {
    const found = validate();
    setIssues(found);
    if (found.length > 0) {
      return;
    }

    onSubmit({
      ...values,
      name: values.name.trim(),
      description: values.description.trim(),
      variants: values.variants.map((variant) => ({
        ...variant,
        name: variant.name.trim(),
        price: variant.price.trim(),
      })),
    });
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>{isEdit ? `Edit ${menu?.name}` : 'New product'}</CardTitle>
        <CardDescription>
          {isEdit
            ? `Editing revision ${menu?.revision}. Variant IDs stay stable; saved changes are picked up by the next Android catalog refresh.`
            : 'Create a product with one or more purchasable variants. Prices are integer minor units.'}
        </CardDescription>
      </CardHeader>
      <CardContent className="flex flex-col gap-5">
        {error ? (
          <div
            role="alert"
            className="flex items-start gap-3 rounded-control bg-danger-soft px-4 py-3 text-sm text-danger"
          >
            <CircleAlert aria-hidden="true" className="mt-0.5 size-5 shrink-0" />
            <span>{error}</span>
          </div>
        ) : null}

        {issues.length > 0 ? (
          <div
            role="alert"
            className="rounded-control bg-danger-soft px-4 py-3 text-sm text-danger"
          >
            <p className="font-medium">Check these fields before saving.</p>
            <ul className="mt-2 list-disc space-y-1 pl-5">
              {issues.map((issue) => (
                <li key={issue}>{issue}</li>
              ))}
            </ul>
          </div>
        ) : null}

        <div className="grid gap-5 md:grid-cols-2">
          <div className="flex flex-col gap-2">
            <label className="text-sm font-medium text-text" htmlFor={`${fieldId}-name`}>
              Product name
            </label>
            <input
              id={`${fieldId}-name`}
              className={inputClass}
              maxLength={200}
              value={values.name}
              onChange={(event) => setValues({ ...values, name: event.target.value })}
            />
          </div>

          <div className="flex flex-col gap-2">
            <label className="text-sm font-medium text-text" htmlFor={`${fieldId}-category`}>
              Category
            </label>
            <select
              id={`${fieldId}-category`}
              className={inputClass}
              value={values.categoryId}
              onChange={(event) => setValues({ ...values, categoryId: event.target.value })}
            >
              <option value="">Select a category</option>
              {archivedCategories.map((category) => (
                <option key={category.id} value={category.id}>
                  {category.name}
                </option>
              ))}
            </select>
          </div>

          <div className="flex flex-col gap-2 md:col-span-2">
            <label className="text-sm font-medium text-text" htmlFor={`${fieldId}-description`}>
              Description
            </label>
            <textarea
              id={`${fieldId}-description`}
              rows={3}
              className="w-full rounded-control border border-control bg-surface px-3 py-2 text-sm text-text placeholder:text-muted"
              maxLength={2000}
              value={values.description}
              onChange={(event) => setValues({ ...values, description: event.target.value })}
            />
            <p className="text-xs text-muted">{values.description.length} of 2000 characters.</p>
          </div>
        </div>

        <div className="flex flex-col gap-4">
          <div className="flex flex-wrap items-center justify-between gap-3">
            <div>
              <h3 className="text-base font-semibold text-text">Variants</h3>
              <p className="text-sm text-muted">
                Every variant keeps a stable ID and an explicit stock policy.
              </p>
            </div>
            {!isEdit ? (
              <Button
                type="button"
                variant="outline"
                size="sm"
                onClick={() =>
                  setValues({ ...values, variants: [...values.variants, emptyVariant()] })
                }
                disabled={values.variants.length >= 50}
              >
                <Plus aria-hidden="true" className="size-4" />
                Add variant
              </Button>
            ) : null}
          </div>

          <div className="flex flex-col gap-4">
            {values.variants.map((variant, index) => (
              <fieldset
                key={variant.id ?? `new-${index}`}
                className="rounded-surface border border-border bg-surface-tint p-4"
              >
                <legend className="px-1 text-sm font-medium text-text">
                  {variant.name || `Variant ${index + 1}`}
                  {variant.id ? (
                    <span className="ml-2 text-xs font-normal text-muted">
                      ID {variant.id.slice(0, 8)}
                    </span>
                  ) : null}
                </legend>

                <div className="mt-3 grid gap-4 md:grid-cols-2 xl:grid-cols-4">
                  <div className="flex flex-col gap-2">
                    <label
                      className="text-sm font-medium text-text"
                      htmlFor={`${fieldId}-variant-${index}-name`}
                    >
                      Variant name
                    </label>
                    <input
                      id={`${fieldId}-variant-${index}-name`}
                      className={inputClass}
                      maxLength={200}
                      value={variant.name}
                      onChange={(event) => updateVariant(index, { name: event.target.value })}
                    />
                  </div>

                  <div className="flex flex-col gap-2">
                    <label
                      className="text-sm font-medium text-text"
                      htmlFor={`${fieldId}-variant-${index}-price`}
                    >
                      Price (minor units)
                    </label>
                    <input
                      id={`${fieldId}-variant-${index}-price`}
                      className={inputClass}
                      type="number"
                      inputMode="numeric"
                      min={0}
                      step={1}
                      value={variant.price}
                      onChange={(event) => updateVariant(index, { price: event.target.value })}
                    />
                  </div>

                  <div className="flex flex-col gap-2">
                    <label
                      className="text-sm font-medium text-text"
                      htmlFor={`${fieldId}-variant-${index}-policy`}
                    >
                      Stock policy
                    </label>
                    <select
                      id={`${fieldId}-variant-${index}-policy`}
                      className={inputClass}
                      value={variant.stockPolicy}
                      onChange={(event) =>
                        updateVariant(index, {
                          stockPolicy: event.target.value as ApiSchemas['Variant']['stockPolicy'],
                        })
                      }
                    >
                      <option value="UNTRACKED">Untracked</option>
                      <option value="TRACKED">Tracked</option>
                    </select>
                  </div>

                  <div className="flex flex-col justify-end gap-3">
                    <label className="flex min-h-12 items-center gap-3 text-sm text-text">
                      <input
                        type="checkbox"
                        className="size-5 rounded border-control text-accent"
                        checked={variant.enabled}
                        onChange={(event) =>
                          updateVariant(index, { enabled: event.target.checked })
                        }
                      />
                      Enabled for sale
                    </label>
                    {!isEdit && values.variants.length > 1 ? (
                      <Button
                        type="button"
                        variant="ghost"
                        size="sm"
                        onClick={() =>
                          setValues({
                            ...values,
                            variants: values.variants.filter(
                              (_item, itemIndex) => itemIndex !== index,
                            ),
                          })
                        }
                      >
                        <Trash2 aria-hidden="true" className="size-4" />
                        Remove variant
                      </Button>
                    ) : null}
                  </div>
                </div>
              </fieldset>
            ))}
          </div>
        </div>

        <div className="flex flex-wrap items-center gap-3">
          <Button
            type="button"
            onClick={submit}
            disabled={saving || archivedCategories.length === 0}
          >
            <Save aria-hidden="true" className="size-4" />
            {saving ? 'Saving product' : isEdit ? 'Save product' : 'Create product'}
          </Button>
          <Button type="button" variant="outline" onClick={onCancel} disabled={saving}>
            <X aria-hidden="true" className="size-4" />
            Cancel
          </Button>
          {archivedCategories.length === 0 ? (
            <p className="text-sm text-warning">Create a category before adding a product.</p>
          ) : null}
        </div>
      </CardContent>
    </Card>
  );
}
