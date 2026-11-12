'use client';

import type { ApiSchemas } from '@modern-pos/api-client';
import { useQuery } from '@tanstack/react-query';
import { RefreshCw, Tag } from 'lucide-react';
import { useState } from 'react';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { api } from '@/lib/api';
import { apiErrorCode, describeApiError } from '@/lib/api-errors';
import { useAuth } from '@/lib/auth';
import { useActiveOutletId } from '@/lib/use-active-outlet';

type Promotion = ApiSchemas['Promotion'];
type PromotionWrite = ApiSchemas['PromotionWrite'];
type ApprovalRule = ApiSchemas['ApprovalRule'];

const inputClass =
  'h-11 w-full rounded-control border border-control bg-surface px-3 text-sm text-text';

function toLocalInput(value: string | null | undefined): string {
  if (!value) {
    return '';
  }

  const date = new Date(value);
  const offset = date.getTimezoneOffset() * 60_000;
  return new Date(date.getTime() - offset).toISOString().slice(0, 16);
}

function listText(values: string[] | undefined): string {
  return (values ?? []).join(', ');
}

function parseList(value: string): string[] {
  return value
    .split(',')
    .map((entry) => entry.trim())
    .filter((entry) => entry.length > 0);
}

function describePromotionError(error: unknown, fallback: string): string {
  const code = apiErrorCode(error);

  if (code === 'APPROVAL_REQUIRED') {
    return 'This operation needs an owner because it exceeds the configured approval threshold.';
  }

  if (code === 'PROMOTION_STACK_NOT_ALLOWED') {
    return 'The selected promotions cannot be combined under the stacking rules.';
  }

  if (code === 'PROMOTION_NOT_ELIGIBLE') {
    return 'That promotion is not eligible for this basket, outlet, customer or date window.';
  }

  return describeApiError(error, fallback);
}

export function PromotionsScreen() {
  const outletId = useActiveOutletId();
  const { user } = useAuth();
  const canEdit = user?.role === 'OWNER';
  const [editing, setEditing] = useState<Promotion | null>(null);
  const [message, setMessage] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);

  const [name, setName] = useState('');
  const [kind, setKind] = useState<'PERCENTAGE' | 'FIXED_AMOUNT'>('PERCENTAGE');
  const [percentageBps, setPercentageBps] = useState('1000');
  const [amountMinor, setAmountMinor] = useState('0');
  const [minBasketMinor, setMinBasketMinor] = useState('0');
  const [startsAt, setStartsAt] = useState('');
  const [endsAt, setEndsAt] = useState('');
  const [stacking, setStacking] = useState<'EXCLUSIVE' | 'STACKABLE'>('EXCLUSIVE');
  const [priority, setPriority] = useState('0');
  const [active, setActive] = useState(true);
  const [variantIds, setVariantIds] = useState('');
  const [menuItemIds, setMenuItemIds] = useState('');
  const [customerEmails, setCustomerEmails] = useState('');

  const promotionsQuery = useQuery({
    queryKey: ['promotions', outletId],
    queryFn: () => api.listPromotions(outletId as string),
    enabled: Boolean(outletId),
  });
  const rulesQuery = useQuery({
    queryKey: ['approval-rules', outletId],
    queryFn: () => api.listApprovalRules(outletId as string),
    enabled: Boolean(outletId) && canEdit,
  });

  function resetForm(): void {
    setEditing(null);
    setName('');
    setKind('PERCENTAGE');
    setPercentageBps('1000');
    setAmountMinor('0');
    setMinBasketMinor('0');
    setStartsAt('');
    setEndsAt('');
    setStacking('EXCLUSIVE');
    setPriority('0');
    setActive(true);
    setVariantIds('');
    setMenuItemIds('');
    setCustomerEmails('');
  }

  function startEdit(promotion: Promotion): void {
    setEditing(promotion);
    setMessage(null);
    setError(null);
    setName(promotion.name);
    setKind(promotion.kind);
    setPercentageBps(String(promotion.percentageBps ?? 1000));
    setAmountMinor(String(promotion.amountMinor ?? 0));
    setMinBasketMinor(String(promotion.minBasketMinor));
    setStartsAt(toLocalInput(promotion.startsAt));
    setEndsAt(toLocalInput(promotion.endsAt));
    setStacking(promotion.stacking);
    setPriority(String(promotion.priority));
    setActive(promotion.active);
    setVariantIds(listText(promotion.eligibility?.variantIds));
    setMenuItemIds(listText(promotion.eligibility?.menuItemIds));
    setCustomerEmails(listText(promotion.eligibility?.customerEmails));
  }

  async function save(event: React.FormEvent<HTMLFormElement>): Promise<void> {
    event.preventDefault();
    setError(null);
    setMessage(null);

    if (!outletId) {
      return;
    }

    const payload: PromotionWrite = {
      name: name.trim(),
      kind,
      ...(kind === 'PERCENTAGE'
        ? { percentageBps: Number(percentageBps) }
        : { amountMinor: Number(amountMinor) }),
      minBasketMinor: Number(minBasketMinor),
      stacking,
      priority: Number(priority),
      active,
      ...(startsAt ? { startsAt: new Date(startsAt).toISOString() } : {}),
      ...(endsAt ? { endsAt: new Date(endsAt).toISOString() } : {}),
      eligibility: {
        ...(parseList(variantIds).length > 0 ? { variantIds: parseList(variantIds) } : {}),
        ...(parseList(menuItemIds).length > 0 ? { menuItemIds: parseList(menuItemIds) } : {}),
        ...(parseList(customerEmails).length > 0
          ? { customerEmails: parseList(customerEmails) }
          : {}),
      },
    };

    setSaving(true);

    try {
      if (editing) {
        await api.updatePromotion(outletId, editing.id, {
          ...payload,
          revision: editing.revision,
        });
        setMessage('Promotion updated. The server remains pricing authority.');
      } else {
        await api.createPromotion(outletId, payload);
        setMessage('Promotion created. Eligibility and stacking are enforced server-side.');
      }

      resetForm();
      await promotionsQuery.refetch();
    } catch (saveError) {
      setError(describePromotionError(saveError, 'Could not save this promotion'));
    } finally {
      setSaving(false);
    }
  }

  async function saveRule(action: 'DISCOUNT' | 'REFUND', threshold: string): Promise<void> {
    if (!outletId || !canEdit) {
      return;
    }

    setError(null);
    setMessage(null);

    try {
      await api.upsertApprovalRule(outletId, action, {
        thresholdMinor: Number(threshold),
        active: true,
      });
      setMessage(`${action} approval threshold saved.`);
      await rulesQuery.refetch();
    } catch (saveError) {
      setError(describePromotionError(saveError, 'Could not save the approval threshold'));
    }
  }

  if (!outletId) {
    return (
      <Card>
        <CardHeader>
          <CardTitle>No outlet assigned</CardTitle>
          <CardDescription>
            This account has no outlet scope, so promotions cannot be loaded.
          </CardDescription>
        </CardHeader>
      </Card>
    );
  }

  return (
    <div className="mx-auto flex w-full max-w-6xl flex-col gap-6">
      <header className="flex flex-wrap items-start justify-between gap-3">
        <div>
          <h1 className="text-3xl font-semibold tracking-tight text-text">Promotions</h1>
          <p className="mt-2 max-w-2xl text-sm text-muted">
            Percentage or fixed-amount promotions with explicit outlet, item, variant, customer,
            date and minimum-basket eligibility. Stacking and integer minor-unit rounding are
            enforced by the API.
          </p>
        </div>
        {promotionsQuery.isFetching ? (
          <p className="flex items-center gap-2 text-sm text-muted" role="status">
            <RefreshCw aria-hidden="true" className="size-4 animate-spin" />
            Refreshing
          </p>
        ) : null}
      </header>

      {message ? (
        <p className="rounded-control bg-success-soft p-3 text-sm text-success" role="status">
          {message}
        </p>
      ) : null}
      {error ? (
        <p className="rounded-control bg-danger-soft p-3 text-sm text-danger" role="alert">
          {error}
        </p>
      ) : null}

      <div className="grid gap-6 lg:grid-cols-[1.2fr_1fr]">
        <Card>
          <CardHeader>
            <CardTitle>Promotion list</CardTitle>
            <CardDescription>
              Rules are shown exactly as stored. The original sale snapshot never changes after
              checkout.
            </CardDescription>
          </CardHeader>
          <CardContent>
            {promotionsQuery.isPending ? (
              <p className="text-sm text-muted" role="status">
                Loading promotions…
              </p>
            ) : promotionsQuery.isError ? (
              <div className="flex flex-col items-start gap-3">
                <p className="text-sm text-danger" role="alert">
                  {describePromotionError(promotionsQuery.error, 'Could not load promotions')}
                </p>
                <Button variant="outline" onClick={() => void promotionsQuery.refetch()}>
                  <RefreshCw aria-hidden="true" className="size-4" />
                  Try again
                </Button>
              </div>
            ) : (promotionsQuery.data ?? []).length === 0 ? (
              <p className="text-sm text-muted">
                No promotions yet. Create the first percentage or fixed-amount rule.
              </p>
            ) : (
              <ul className="flex flex-col gap-3">
                {(promotionsQuery.data ?? []).map((promotion) => (
                  <li
                    key={promotion.id}
                    className="rounded-control border border-border bg-surface-tint p-4"
                  >
                    <div className="flex flex-wrap items-start justify-between gap-3">
                      <div className="min-w-0">
                        <div className="flex flex-wrap items-center gap-2">
                          <Tag aria-hidden="true" className="size-4 text-accent" />
                          <h2 className="text-base font-semibold text-text">{promotion.name}</h2>
                          <Badge>{promotion.active ? 'Active' : 'Inactive'}</Badge>
                          <Badge>{promotion.stacking}</Badge>
                        </div>
                        <dl className="mt-3 grid gap-2 text-sm sm:grid-cols-2">
                          <div>
                            <dt className="text-xs uppercase tracking-[0.12em] text-muted">
                              Value
                            </dt>
                            <dd className="tabular-nums text-text">
                              {promotion.kind === 'PERCENTAGE'
                                ? `${((promotion.percentageBps ?? 0) / 100).toFixed(2)}%`
                                : `${promotion.amountMinor ?? 0} minor units off`}
                            </dd>
                          </div>
                          <div>
                            <dt className="text-xs uppercase tracking-[0.12em] text-muted">
                              Minimum basket
                            </dt>
                            <dd className="tabular-nums text-text">
                              {promotion.minBasketMinor} minor units
                            </dd>
                          </div>
                          <div>
                            <dt className="text-xs uppercase tracking-[0.12em] text-muted">
                              Window
                            </dt>
                            <dd className="text-text">
                              {promotion.startsAt
                                ? new Date(promotion.startsAt).toLocaleString()
                                : 'Always'}{' '}
                              to{' '}
                              {promotion.endsAt
                                ? new Date(promotion.endsAt).toLocaleString()
                                : 'No end'}
                            </dd>
                          </div>
                          <div>
                            <dt className="text-xs uppercase tracking-[0.12em] text-muted">
                              Priority
                            </dt>
                            <dd className="tabular-nums text-text">{promotion.priority}</dd>
                          </div>
                          <div className="sm:col-span-2">
                            <dt className="text-xs uppercase tracking-[0.12em] text-muted">
                              Eligibility
                            </dt>
                            <dd className="break-words text-text">
                              {(promotion.eligibility?.variantIds ?? []).length > 0
                                ? `Variants: ${listText(promotion.eligibility?.variantIds)}. `
                                : ''}
                              {(promotion.eligibility?.menuItemIds ?? []).length > 0
                                ? `Menu items: ${listText(promotion.eligibility?.menuItemIds)}. `
                                : ''}
                              {(promotion.eligibility?.customerEmails ?? []).length > 0
                                ? `Customers: ${listText(promotion.eligibility?.customerEmails)}.`
                                : ''}
                              {!(promotion.eligibility?.variantIds ?? []).length &&
                              !(promotion.eligibility?.menuItemIds ?? []).length &&
                              !(promotion.eligibility?.customerEmails ?? []).length
                                ? 'All items and customers at this outlet.'
                                : ''}
                            </dd>
                          </div>
                        </dl>
                      </div>
                      {canEdit ? (
                        <Button variant="outline" onClick={() => startEdit(promotion)}>
                          Edit
                        </Button>
                      ) : null}
                    </div>
                  </li>
                ))}
              </ul>
            )}
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>{editing ? 'Edit promotion' : 'Create promotion'}</CardTitle>
            <CardDescription>
              {canEdit
                ? 'Only an owner can save promotions. Cashiers can read the same rules.'
                : 'Cashiers can read promotions but only an owner can change them.'}
            </CardDescription>
          </CardHeader>
          <CardContent>
            <form className="flex flex-col gap-4" onSubmit={save}>
              <label className="flex flex-col gap-1 text-sm font-medium text-text">
                Name
                <input
                  className={inputClass}
                  value={name}
                  required
                  maxLength={120}
                  disabled={!canEdit}
                  onChange={(event) => setName(event.target.value)}
                />
              </label>

              <label className="flex flex-col gap-1 text-sm font-medium text-text">
                Kind
                <select
                  className={inputClass}
                  value={kind}
                  disabled={!canEdit}
                  onChange={(event) => setKind(event.target.value as 'PERCENTAGE' | 'FIXED_AMOUNT')}
                >
                  <option value="PERCENTAGE">Percentage</option>
                  <option value="FIXED_AMOUNT">Fixed amount</option>
                </select>
              </label>

              {kind === 'PERCENTAGE' ? (
                <label className="flex flex-col gap-1 text-sm font-medium text-text">
                  Percentage in basis points (1000 = 10%)
                  <input
                    className={inputClass}
                    inputMode="numeric"
                    value={percentageBps}
                    disabled={!canEdit}
                    onChange={(event) =>
                      setPercentageBps(event.target.value.replace(/[^0-9]/g, ''))
                    }
                  />
                </label>
              ) : (
                <label className="flex flex-col gap-1 text-sm font-medium text-text">
                  Amount off (minor units)
                  <input
                    className={inputClass}
                    inputMode="numeric"
                    value={amountMinor}
                    disabled={!canEdit}
                    onChange={(event) => setAmountMinor(event.target.value.replace(/[^0-9]/g, ''))}
                  />
                </label>
              )}

              <label className="flex flex-col gap-1 text-sm font-medium text-text">
                Minimum basket (minor units)
                <input
                  className={inputClass}
                  inputMode="numeric"
                  value={minBasketMinor}
                  disabled={!canEdit}
                  onChange={(event) => setMinBasketMinor(event.target.value.replace(/[^0-9]/g, ''))}
                />
              </label>

              <div className="grid gap-4 sm:grid-cols-2">
                <label className="flex flex-col gap-1 text-sm font-medium text-text">
                  Starts at
                  <input
                    type="datetime-local"
                    className={inputClass}
                    value={startsAt}
                    disabled={!canEdit}
                    onChange={(event) => setStartsAt(event.target.value)}
                  />
                </label>
                <label className="flex flex-col gap-1 text-sm font-medium text-text">
                  Ends at
                  <input
                    type="datetime-local"
                    className={inputClass}
                    value={endsAt}
                    disabled={!canEdit}
                    onChange={(event) => setEndsAt(event.target.value)}
                  />
                </label>
              </div>

              <div className="grid gap-4 sm:grid-cols-2">
                <label className="flex flex-col gap-1 text-sm font-medium text-text">
                  Stacking
                  <select
                    className={inputClass}
                    value={stacking}
                    disabled={!canEdit}
                    onChange={(event) =>
                      setStacking(event.target.value as 'EXCLUSIVE' | 'STACKABLE')
                    }
                  >
                    <option value="EXCLUSIVE">Exclusive (cannot combine)</option>
                    <option value="STACKABLE">Stackable</option>
                  </select>
                </label>
                <label className="flex flex-col gap-1 text-sm font-medium text-text">
                  Priority
                  <input
                    className={inputClass}
                    inputMode="numeric"
                    value={priority}
                    disabled={!canEdit}
                    onChange={(event) => setPriority(event.target.value.replace(/[^0-9-]/g, ''))}
                  />
                </label>
              </div>

              <label className="flex items-center gap-2 text-sm font-medium text-text">
                <input
                  type="checkbox"
                  checked={active}
                  disabled={!canEdit}
                  onChange={(event) => setActive(event.target.checked)}
                />
                Active
              </label>

              <label className="flex flex-col gap-1 text-sm font-medium text-text">
                Eligible variant IDs (comma separated)
                <input
                  className={inputClass}
                  value={variantIds}
                  disabled={!canEdit}
                  onChange={(event) => setVariantIds(event.target.value)}
                />
              </label>
              <label className="flex flex-col gap-1 text-sm font-medium text-text">
                Eligible menu item IDs (comma separated)
                <input
                  className={inputClass}
                  value={menuItemIds}
                  disabled={!canEdit}
                  onChange={(event) => setMenuItemIds(event.target.value)}
                />
              </label>
              <label className="flex flex-col gap-1 text-sm font-medium text-text">
                Eligible customer emails (comma separated)
                <input
                  className={inputClass}
                  value={customerEmails}
                  disabled={!canEdit}
                  onChange={(event) => setCustomerEmails(event.target.value)}
                />
              </label>

              <div className="flex flex-wrap gap-3">
                <Button type="submit" disabled={!canEdit || saving}>
                  {saving ? 'Saving…' : editing ? 'Save changes' : 'Create promotion'}
                </Button>
                {editing ? (
                  <Button type="button" variant="outline" onClick={resetForm}>
                    Cancel edit
                  </Button>
                ) : null}
              </div>
            </form>
          </CardContent>
        </Card>
      </div>

      {canEdit ? (
        <Card>
          <CardHeader>
            <CardTitle>Approval thresholds</CardTitle>
            <CardDescription>
              Amounts above a threshold require an owner. Amounts at or below it may be performed by
              a cashier. Thresholds are enforced by the API, never by this screen alone.
            </CardDescription>
          </CardHeader>
          <CardContent>
            {rulesQuery.isPending ? (
              <p className="text-sm text-muted" role="status">
                Loading approval rules…
              </p>
            ) : rulesQuery.isError ? (
              <p className="text-sm text-danger" role="alert">
                {describePromotionError(rulesQuery.error, 'Could not load approval rules')}
              </p>
            ) : (
              <div className="grid gap-4 sm:grid-cols-2">
                {(['DISCOUNT', 'REFUND'] as const).map((action) => (
                  <ApprovalThresholdForm
                    key={action}
                    action={action}
                    rule={(rulesQuery.data ?? []).find((row) => row.action === action) ?? null}
                    onSave={saveRule}
                  />
                ))}
              </div>
            )}
          </CardContent>
        </Card>
      ) : null}
    </div>
  );
}

function ApprovalThresholdForm({
  action,
  rule,
  onSave,
}: {
  action: 'DISCOUNT' | 'REFUND';
  rule: ApprovalRule | null;
  onSave: (action: 'DISCOUNT' | 'REFUND', threshold: string) => Promise<void>;
}) {
  const [threshold, setThreshold] = useState(String(rule?.thresholdMinor ?? 0));
  const [saving, setSaving] = useState(false);

  return (
    <form
      className="flex flex-col gap-2 rounded-control border border-border bg-surface-tint p-3"
      onSubmit={(event) => {
        event.preventDefault();
        setSaving(true);
        void onSave(action, threshold).finally(() => setSaving(false));
      }}
    >
      <p className="text-sm font-semibold text-text">{action} threshold</p>
      <p className="text-xs text-muted">
        {rule ? `Current: ${rule.thresholdMinor} minor units` : 'No rule: refunds stay owner-only.'}
      </p>
      <label className="flex flex-col gap-1 text-sm font-medium text-text">
        Threshold (minor units)
        <input
          className={inputClass}
          inputMode="numeric"
          value={threshold}
          onChange={(event) => setThreshold(event.target.value.replace(/[^0-9]/g, ''))}
        />
      </label>
      <Button type="submit" variant="outline" disabled={saving}>
        {saving ? 'Saving…' : 'Save threshold'}
      </Button>
    </form>
  );
}
