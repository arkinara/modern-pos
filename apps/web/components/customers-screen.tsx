'use client';

import { useQuery, useQueryClient } from '@tanstack/react-query';
import { AlertTriangle, RefreshCw, Save, ShieldCheck, Trash2 } from 'lucide-react';
import { useEffect, useState } from 'react';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { api } from '@/lib/api';
import { apiErrorCode, describeOperationError } from '@/lib/api-errors';
import { formatDateTimeInZone } from '@/lib/reporting';
import { useActiveOutletId } from '@/lib/use-active-outlet';

const inputClass =
  'h-11 w-full rounded-control border border-control bg-surface px-3 text-sm text-text';
const selectClass =
  'h-11 w-full rounded-control border border-control bg-surface px-3 text-sm text-text';

export function CustomersScreen() {
  const outletId = useActiveOutletId();
  const queryClient = useQueryClient();
  const [name, setName] = useState('');
  const [contact, setContact] = useState('');
  const [contactType, setContactType] = useState<'EMAIL' | 'PHONE'>('EMAIL');
  const [consent, setConsent] = useState(false);
  const [policy, setPolicy] = useState({
    customerRetentionDays: '365',
    receiptRetentionDays: '90',
    receiptLinkTtlMinutes: '1440',
  });
  const [pending, setPending] = useState<string | null>(null);
  const [message, setMessage] = useState<string | null>(null);
  const [actionError, setActionError] = useState<string | null>(null);

  const customersQuery = useQuery({
    queryKey: ['customers', outletId],
    queryFn: () => api.listCustomers(outletId as string, { limit: 100 }),
    enabled: Boolean(outletId),
  });
  const policyQuery = useQuery({
    queryKey: ['customer-retention', outletId],
    queryFn: () => api.getCustomerRetentionPolicy(outletId as string),
    enabled: Boolean(outletId),
  });
  const settingsQuery = useQuery({
    queryKey: ['settings', outletId],
    queryFn: () => api.getSettings(outletId as string),
    enabled: Boolean(outletId),
  });

  useEffect(() => {
    if (!policyQuery.data) {
      return;
    }
    setPolicy({
      customerRetentionDays: String(policyQuery.data.customerRetentionDays),
      receiptRetentionDays: String(policyQuery.data.receiptRetentionDays),
      receiptLinkTtlMinutes: String(policyQuery.data.receiptLinkTtlMinutes),
    });
  }, [policyQuery.data]);

  const timezone = settingsQuery.data?.timezone ?? 'UTC';

  function clearFeedback(): void {
    setMessage(null);
    setActionError(null);
  }

  async function refresh(): Promise<void> {
    await queryClient.invalidateQueries({ queryKey: ['customers', outletId] });
    await queryClient.invalidateQueries({ queryKey: ['customer-retention', outletId] });
  }

  async function createCustomer(): Promise<void> {
    if (!outletId || !name.trim() || !contact.trim() || !consent) {
      return;
    }
    clearFeedback();
    setPending('create');
    try {
      await api.createCustomer(outletId, {
        name: name.trim(),
        contact: contact.trim(),
        contactType,
        consent: true,
        consentSource: 'STAFF_ENTRY',
      });
      setName('');
      setContact('');
      setConsent(false);
      await refresh();
      setMessage('Customer saved with recorded consent.');
    } catch (error) {
      const code = apiErrorCode(error);
      setActionError(
        code === 'CUSTOMER_EXISTS'
          ? 'A customer with this contact already exists in this outlet.'
          : code === 'CUSTOMER_CONSENT_REQUIRED'
            ? 'A customer record cannot be created without explicit consent.'
            : describeOperationError(error, 'Could not create the customer'),
      );
    } finally {
      setPending(null);
    }
  }

  async function savePolicy(): Promise<void> {
    if (!outletId) {
      return;
    }
    clearFeedback();
    setPending('policy');
    try {
      await api.updateCustomerRetentionPolicy(outletId, {
        customerRetentionDays: Number(policy.customerRetentionDays),
        receiptRetentionDays: Number(policy.receiptRetentionDays),
        receiptLinkTtlMinutes: Number(policy.receiptLinkTtlMinutes),
      });
      await refresh();
      setMessage('Retention policy saved.');
    } catch (error) {
      setActionError(describeOperationError(error, 'Could not save the retention policy'));
    } finally {
      setPending(null);
    }
  }

  async function purgeExpired(): Promise<void> {
    if (!outletId) {
      return;
    }
    clearFeedback();
    setPending('purge');
    try {
      const result = await api.purgeCustomers(outletId);
      await refresh();
      setMessage(
        `Purge complete: ${result.customersAnonymised} customer record(s) anonymised, ${result.receiptsPurged} receipt(s) removed.`,
      );
    } catch (error) {
      setActionError(describeOperationError(error, 'Could not purge expired records'));
    } finally {
      setPending(null);
    }
  }

  if (!outletId) {
    return (
      <Card>
        <CardHeader>
          <CardTitle>No outlet assigned</CardTitle>
          <CardDescription>This account has no outlet scope.</CardDescription>
        </CardHeader>
      </Card>
    );
  }

  return (
    <div className="flex w-full flex-col gap-6">
      <header>
        <h1 className="text-3xl font-semibold tracking-tight text-text">Customers</h1>
        <p className="mt-2 max-w-3xl text-sm text-muted">
          Customer records are opt-in. Consent, source and time are stored with the record. Owner
          accounts see the records for this outlet only; cashier accounts have no customer access.
        </p>
      </header>

      <Card>
        <CardHeader>
          <CardTitle>Add an opt-in customer</CardTitle>
          <CardDescription>
            The record is never created without an explicit consent checkbox.
          </CardDescription>
        </CardHeader>
        <CardContent className="flex flex-col gap-4">
          <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-4">
            <label className="flex flex-col gap-1 text-sm font-medium text-text">
              Name
              <input
                className={inputClass}
                value={name}
                maxLength={120}
                onChange={(event) => setName(event.target.value)}
              />
            </label>
            <label className="flex flex-col gap-1 text-sm font-medium text-text">
              Contact type
              <select
                className={selectClass}
                value={contactType}
                onChange={(event) => setContactType(event.target.value as 'EMAIL' | 'PHONE')}
              >
                <option value="EMAIL">Email</option>
                <option value="PHONE">Phone</option>
              </select>
            </label>
            <label className="flex flex-col gap-1 text-sm font-medium text-text">
              Contact
              <input
                className={inputClass}
                value={contact}
                maxLength={200}
                onChange={(event) => setContact(event.target.value)}
              />
            </label>
            <label className="flex min-h-11 items-end gap-2 text-sm font-medium text-text">
              <input
                type="checkbox"
                className="size-4 rounded border-control"
                checked={consent}
                onChange={(event) => setConsent(event.target.checked)}
              />
              Explicit consent
            </label>
          </div>
          <div className="flex flex-wrap items-center gap-3">
            <Button
              onClick={() => void createCustomer()}
              disabled={pending === 'create' || !name.trim() || !contact.trim() || !consent}
            >
              <ShieldCheck aria-hidden="true" className="size-4" />
              Save customer
            </Button>
            {message ? (
              <p className="text-sm text-success" role="status">
                {message}
              </p>
            ) : null}
            {actionError ? (
              <p className="flex items-center gap-2 text-sm text-danger" role="alert">
                <AlertTriangle aria-hidden="true" className="size-4" />
                {actionError}
              </p>
            ) : null}
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Retention and digital receipts</CardTitle>
          <CardDescription>
            Expired customers are anonymised and receipt artifacts older than the receipt window are
            removed by the on-demand purge. Receipt links also expire independently.
          </CardDescription>
        </CardHeader>
        <CardContent className="flex flex-col gap-4">
          {policyQuery.isLoading ? (
            <div
              className="h-20 animate-pulse rounded-control bg-surface-muted"
              role="status"
              aria-busy="true"
            />
          ) : policyQuery.isError ? (
            <div className="flex flex-col items-start gap-3" role="alert">
              <p className="text-sm text-danger">
                {describeOperationError(policyQuery.error, 'Could not load the retention policy')}
              </p>
              <Button variant="outline" onClick={() => void policyQuery.refetch()}>
                <RefreshCw aria-hidden="true" className="size-4" />
                Try again
              </Button>
            </div>
          ) : (
            <>
              <div className="grid gap-3 sm:grid-cols-3">
                <label className="flex flex-col gap-1 text-sm font-medium text-text">
                  Customer retention (days)
                  <input
                    className={inputClass}
                    type="number"
                    min={1}
                    max={3650}
                    value={policy.customerRetentionDays}
                    onChange={(event) =>
                      setPolicy((current) => ({
                        ...current,
                        customerRetentionDays: event.target.value,
                      }))
                    }
                  />
                </label>
                <label className="flex flex-col gap-1 text-sm font-medium text-text">
                  Receipt retention (days)
                  <input
                    className={inputClass}
                    type="number"
                    min={1}
                    max={3650}
                    value={policy.receiptRetentionDays}
                    onChange={(event) =>
                      setPolicy((current) => ({
                        ...current,
                        receiptRetentionDays: event.target.value,
                      }))
                    }
                  />
                </label>
                <label className="flex flex-col gap-1 text-sm font-medium text-text">
                  Receipt link lifetime (minutes)
                  <input
                    className={inputClass}
                    type="number"
                    min={1}
                    max={10080}
                    value={policy.receiptLinkTtlMinutes}
                    onChange={(event) =>
                      setPolicy((current) => ({
                        ...current,
                        receiptLinkTtlMinutes: event.target.value,
                      }))
                    }
                  />
                </label>
              </div>
              <div className="flex flex-wrap gap-3">
                <Button
                  variant="outline"
                  onClick={() => void savePolicy()}
                  disabled={pending === 'policy'}
                >
                  <Save aria-hidden="true" className="size-4" />
                  Save policy
                </Button>
                <Button
                  variant="outline"
                  onClick={() => void purgeExpired()}
                  disabled={pending === 'purge'}
                >
                  <Trash2 aria-hidden="true" className="size-4" />
                  Purge expired records
                </Button>
              </div>
              <p className="text-xs text-muted">
                {policyQuery.data?.defaults
                  ? 'Defaults are active until this policy is saved.'
                  : `Policy version ${policyQuery.data?.version ?? 0} updated ${
                      policyQuery.data?.updatedAt
                        ? formatDateTimeInZone(policyQuery.data.updatedAt, timezone)
                        : 'unknown'
                    }.`}
              </p>
            </>
          )}
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Customer list</CardTitle>
          <CardDescription>
            Consent source and record age are visible for retention review.
          </CardDescription>
        </CardHeader>
        <CardContent>
          {customersQuery.isLoading ? (
            <div className="flex flex-col gap-2" role="status" aria-busy="true">
              <div className="h-16 animate-pulse rounded-control bg-surface-muted" />
              <div className="h-16 animate-pulse rounded-control bg-surface-muted" />
            </div>
          ) : customersQuery.isError ? (
            <div className="flex flex-col items-start gap-3" role="alert">
              <p className="text-sm text-danger">
                {describeOperationError(customersQuery.error, 'Could not load customers')}
              </p>
              <Button variant="outline" onClick={() => void customersQuery.refetch()}>
                <RefreshCw aria-hidden="true" className="size-4" />
                Try again
              </Button>
            </div>
          ) : (customersQuery.data?.items.length ?? 0) === 0 ? (
            <p className="rounded-surface border border-dashed border-border bg-surface-tint p-6 text-sm text-muted">
              No opt-in customers yet.
            </p>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full min-w-[640px] text-left text-sm">
                <thead>
                  <tr className="border-b border-border text-xs uppercase tracking-[0.12em] text-muted">
                    <th className="py-2 pr-3 font-medium">Name</th>
                    <th className="py-2 pr-3 font-medium">Contact</th>
                    <th className="py-2 pr-3 font-medium">Consent</th>
                    <th className="py-2 pr-3 font-medium">Created</th>
                    <th className="py-2 font-medium">Status</th>
                  </tr>
                </thead>
                <tbody>
                  {(customersQuery.data?.items ?? []).map((customer) => (
                    <tr key={customer.id} className="border-b border-border/60">
                      <td className="py-2 pr-3 font-medium text-text">{customer.name}</td>
                      <td className="py-2 pr-3 text-muted">
                        {customer.email ?? customer.phone ?? 'Removed'}
                      </td>
                      <td className="py-2 pr-3 text-muted">
                        {customer.consentSource}
                        <span className="block text-xs">
                          {formatDateTimeInZone(customer.consentAt, timezone)}
                        </span>
                      </td>
                      <td className="py-2 pr-3 text-muted">
                        {formatDateTimeInZone(customer.createdAt, timezone)}
                      </td>
                      <td className="py-2">
                        {customer.anonymizedAt ? (
                          <Badge tone="warning">Anonymised</Badge>
                        ) : (
                          <Badge tone="success">Active</Badge>
                        )}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
