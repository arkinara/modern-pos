'use client';

import { zodResolver } from '@hookform/resolvers/zod';
import type { ApiSchemas } from '@modern-pos/api-client';
import { CircleAlert, CircleCheck, RotateCcw, Save } from 'lucide-react';
import { useEffect, useState } from 'react';
import { useForm } from 'react-hook-form';
import { useQueryClient } from '@tanstack/react-query';
import { z } from 'zod';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { describeApiError, isVersionConflict } from '@/lib/api-errors';
import { api } from '@/lib/api';

const settingsSchema = z.object({
  businessName: z
    .string()
    .trim()
    .min(1, 'Business name is required.')
    .max(200, 'Business name must be 200 characters or fewer.'),
  currency: z
    .string()
    .trim()
    .regex(/^[A-Za-z]{3}$/, 'Use a three-letter ISO code such as IDR or USD.'),
  timezone: z
    .string()
    .trim()
    .min(1, 'Timezone is required.')
    .max(200, 'Timezone must be 200 characters or fewer.')
    .refine((value) => {
      try {
        new Intl.DateTimeFormat('en-US', { timeZone: value }).format();
        return true;
      } catch {
        return false;
      }
    }, 'Use a valid IANA timezone such as Asia/Jakarta.'),
  receiptHeader: z.string().max(500, 'Receipt header must be 500 characters or fewer.'),
  receiptFooter: z.string().max(500, 'Receipt footer must be 500 characters or fewer.'),
  receiptAddress: z.string().max(1000, 'Receipt address must be 1000 characters or fewer.'),
  taxPercent: z
    .number({ error: 'Tax rate must be a number.' })
    .min(0, 'Tax rate cannot be negative.')
    .max(100, 'Tax rate cannot exceed 100%.'),
  servicePercent: z
    .number({ error: 'Service rate must be a number.' })
    .min(0, 'Service rate cannot be negative.')
    .max(100, 'Service rate cannot exceed 100%.'),
});

type SettingsFormValues = z.infer<typeof settingsSchema>;
type Feedback = { tone: 'success' | 'error'; message: string; action?: 'reload' };

const inputClass =
  'h-12 w-full rounded-control border border-control bg-surface px-3 text-sm text-text placeholder:text-muted disabled:cursor-not-allowed disabled:bg-surface-muted';

function defaultsFor(settings: ApiSchemas['Settings']): SettingsFormValues {
  return {
    businessName: settings.businessName,
    currency: settings.currency,
    timezone: settings.timezone,
    receiptHeader: settings.receiptHeader,
    receiptFooter: settings.receiptFooter,
    receiptAddress: settings.receiptAddress,
    taxPercent: settings.taxBps / 100,
    servicePercent: settings.serviceBps / 100,
  };
}

function FieldError({ id, message }: { id: string; message?: string }) {
  if (!message) {
    return null;
  }

  return (
    <p id={`${id}-error`} role="alert" className="text-sm text-danger">
      {message}
    </p>
  );
}

export function SettingsForm({
  settings,
  canEdit,
}: {
  settings: ApiSchemas['Settings'];
  canEdit: boolean;
}) {
  const queryClient = useQueryClient();
  const [feedback, setFeedback] = useState<Feedback | null>(null);
  const [reloading, setReloading] = useState(false);

  const {
    register,
    handleSubmit,
    reset,
    formState: { errors, isDirty, isSubmitting },
  } = useForm<SettingsFormValues>({
    resolver: zodResolver(settingsSchema),
    defaultValues: defaultsFor(settings),
    shouldFocusError: true,
  });

  useEffect(() => {
    reset(defaultsFor(settings));
  }, [reset, settings]);

  async function reloadLatest(): Promise<void> {
    setReloading(true);
    setFeedback(null);
    try {
      await queryClient.invalidateQueries({ queryKey: ['settings', settings.outletId] });
    } finally {
      setReloading(false);
    }
  }

  async function save(values: SettingsFormValues): Promise<void> {
    if (!canEdit) {
      return;
    }

    setFeedback(null);

    const payload: ApiSchemas['SettingsUpdate'] = {
      businessName: values.businessName.trim(),
      currency: values.currency.trim().toUpperCase(),
      timezone: values.timezone.trim(),
      receiptHeader: values.receiptHeader.trim(),
      receiptFooter: values.receiptFooter.trim(),
      receiptAddress: values.receiptAddress.trim(),
      taxBps: Math.round(values.taxPercent * 100),
      serviceBps: Math.round(values.servicePercent * 100),
      version: settings.version,
    };

    try {
      const saved = await api.updateSettings(settings.outletId, payload);
      queryClient.setQueryData(['settings', saved.outletId], saved);
      setFeedback({
        tone: 'success',
        message: 'Settings saved. The server record is now current.',
      });
    } catch (error) {
      if (isVersionConflict(error)) {
        setFeedback({
          tone: 'error',
          message:
            'Another change saved first. Reload the latest settings, then reapply your edits. Your current values stay on screen.',
          action: 'reload',
        });
        return;
      }

      setFeedback({
        tone: 'error',
        message: describeApiError(
          error,
          'Could not save settings. Your edits stay on screen; check the connection and try again.',
        ),
      });
    }
  }

  return (
    <form className="flex flex-col gap-6" onSubmit={handleSubmit(save)} noValidate>
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
          {feedback.action === 'reload' ? (
            <Button
              type="button"
              variant="outline"
              size="sm"
              onClick={reloadLatest}
              disabled={reloading}
            >
              <RotateCcw aria-hidden="true" className="size-4" />
              {reloading ? 'Reloading' : 'Reload settings'}
            </Button>
          ) : null}
        </div>
      ) : null}

      {!canEdit ? (
        <div className="rounded-control bg-warning-soft px-4 py-3 text-sm text-warning">
          Only an owner can change these settings. This view is read-only for your account.
        </div>
      ) : null}

      <Card>
        <CardHeader>
          <CardTitle>Business identity</CardTitle>
          <CardDescription>
            The business name is shared across this business. Outlet values apply to the selected
            outlet.
          </CardDescription>
        </CardHeader>
        <CardContent className="grid gap-5 md:grid-cols-2">
          <div className="flex flex-col gap-2 md:col-span-2">
            <label className="text-sm font-medium text-text" htmlFor="businessName">
              Business name
            </label>
            <input
              id="businessName"
              className={inputClass}
              disabled={!canEdit}
              aria-invalid={Boolean(errors.businessName)}
              aria-describedby={errors.businessName ? 'businessName-error' : undefined}
              {...register('businessName')}
            />
            <FieldError id="businessName" message={errors.businessName?.message} />
          </div>

          <div className="flex flex-col gap-2">
            <label className="text-sm font-medium text-text" htmlFor="currency">
              Currency
            </label>
            <input
              id="currency"
              className={inputClass}
              disabled={!canEdit}
              autoCapitalize="characters"
              maxLength={3}
              placeholder="IDR"
              aria-invalid={Boolean(errors.currency)}
              aria-describedby={errors.currency ? 'currency-error' : 'currency-hint'}
              {...register('currency')}
            />
            <p id="currency-hint" className="text-xs text-muted">
              Three-letter ISO code. The server sets the minor-unit exponent.
            </p>
            <FieldError id="currency" message={errors.currency?.message} />
          </div>

          <div className="flex flex-col gap-2">
            <label className="text-sm font-medium text-text" htmlFor="timezone">
              Timezone
            </label>
            <input
              id="timezone"
              className={inputClass}
              disabled={!canEdit}
              placeholder="Asia/Jakarta"
              aria-invalid={Boolean(errors.timezone)}
              aria-describedby={errors.timezone ? 'timezone-error' : 'timezone-hint'}
              {...register('timezone')}
            />
            <p id="timezone-hint" className="text-xs text-muted">
              IANA timezone used for outlet-local dates and reports.
            </p>
            <FieldError id="timezone" message={errors.timezone?.message} />
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Receipt identity</CardTitle>
          <CardDescription>
            Printed header, address and footer text for this outlet. Physical printing remains on
            the Android app.
          </CardDescription>
        </CardHeader>
        <CardContent className="grid gap-5 md:grid-cols-2">
          <div className="flex flex-col gap-2 md:col-span-2">
            <label className="text-sm font-medium text-text" htmlFor="receiptHeader">
              Receipt header text
            </label>
            <input
              id="receiptHeader"
              className={inputClass}
              disabled={!canEdit}
              aria-invalid={Boolean(errors.receiptHeader)}
              aria-describedby={errors.receiptHeader ? 'receiptHeader-error' : undefined}
              {...register('receiptHeader')}
            />
            <FieldError id="receiptHeader" message={errors.receiptHeader?.message} />
          </div>

          <div className="flex flex-col gap-2 md:col-span-2">
            <label className="text-sm font-medium text-text" htmlFor="receiptAddress">
              Receipt address
            </label>
            <textarea
              id="receiptAddress"
              rows={2}
              className="w-full rounded-control border border-control bg-surface px-3 py-2 text-sm text-text placeholder:text-muted disabled:cursor-not-allowed disabled:bg-surface-muted"
              disabled={!canEdit}
              aria-invalid={Boolean(errors.receiptAddress)}
              aria-describedby={errors.receiptAddress ? 'receiptAddress-error' : undefined}
              {...register('receiptAddress')}
            />
            <FieldError id="receiptAddress" message={errors.receiptAddress?.message} />
          </div>

          <div className="flex flex-col gap-2 md:col-span-2">
            <label className="text-sm font-medium text-text" htmlFor="receiptFooter">
              Receipt footer text
            </label>
            <input
              id="receiptFooter"
              className={inputClass}
              disabled={!canEdit}
              aria-invalid={Boolean(errors.receiptFooter)}
              aria-describedby={errors.receiptFooter ? 'receiptFooter-error' : undefined}
              {...register('receiptFooter')}
            />
            <FieldError id="receiptFooter" message={errors.receiptFooter?.message} />
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Tax and service rules</CardTitle>
          <CardDescription>
            Stored as basis points by the server. The web app never calculates sale totals.
          </CardDescription>
        </CardHeader>
        <CardContent className="grid gap-5 md:grid-cols-2">
          <div className="flex flex-col gap-2">
            <label className="text-sm font-medium text-text" htmlFor="taxPercent">
              Tax rate (%)
            </label>
            <input
              id="taxPercent"
              type="number"
              inputMode="decimal"
              step="0.01"
              min="0"
              max="100"
              className={inputClass}
              disabled={!canEdit}
              aria-invalid={Boolean(errors.taxPercent)}
              aria-describedby={errors.taxPercent ? 'taxPercent-error' : undefined}
              {...register('taxPercent', { valueAsNumber: true })}
            />
            <FieldError id="taxPercent" message={errors.taxPercent?.message} />
          </div>

          <div className="flex flex-col gap-2">
            <label className="text-sm font-medium text-text" htmlFor="servicePercent">
              Service rate (%)
            </label>
            <input
              id="servicePercent"
              type="number"
              inputMode="decimal"
              step="0.01"
              min="0"
              max="100"
              className={inputClass}
              disabled={!canEdit}
              aria-invalid={Boolean(errors.servicePercent)}
              aria-describedby={errors.servicePercent ? 'servicePercent-error' : undefined}
              {...register('servicePercent', { valueAsNumber: true })}
            />
            <FieldError id="servicePercent" message={errors.servicePercent?.message} />
          </div>

          <div className="flex flex-wrap items-center gap-3 md:col-span-2">
            <span className="text-sm text-muted">Pricing mode</span>
            <Badge tone="neutral">Exclusive · taxes added by the server</Badge>
            <span className="text-xs text-muted">Settings version {settings.version}</span>
          </div>
        </CardContent>
      </Card>

      <div className="flex flex-wrap items-center gap-3">
        <Button type="submit" disabled={!canEdit || isSubmitting || !isDirty}>
          <Save aria-hidden="true" className="size-4" />
          {isSubmitting ? 'Saving settings' : 'Save settings'}
        </Button>
        <p className="text-sm text-muted">
          {isDirty ? 'Unsaved changes stay on screen if saving fails.' : 'No unsaved changes.'}
        </p>
      </div>
    </form>
  );
}
