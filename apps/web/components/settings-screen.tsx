'use client';

import { useQuery } from '@tanstack/react-query';
import { RefreshCw } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { SettingsForm } from '@/components/settings-form';
import { api } from '@/lib/api';
import { describeApiError } from '@/lib/api-errors';
import { useAuth } from '@/lib/auth';
import { useActiveOutletId } from '@/lib/use-active-outlet';

export function SettingsScreen() {
  const { user } = useAuth();
  const outletId = useActiveOutletId();
  const canEdit = user?.role === 'OWNER';

  const settingsQuery = useQuery({
    queryKey: ['settings', outletId],
    queryFn: () => api.getSettings(outletId as string),
    enabled: outletId !== null,
    retry: 1,
  });

  if (!outletId) {
    return (
      <div className="mx-auto w-full max-w-5xl">
        <Card>
          <CardHeader>
            <CardTitle>No outlet assigned</CardTitle>
            <CardDescription>
              This account has no outlet scope, so business settings cannot be loaded.
            </CardDescription>
          </CardHeader>
        </Card>
      </div>
    );
  }

  if (settingsQuery.isPending) {
    return (
      <div className="mx-auto w-full max-w-5xl" role="status" aria-live="polite">
        <Card>
          <CardContent className="flex min-h-48 flex-col items-center justify-center gap-3 pt-6">
            <span className="size-8 animate-spin rounded-full border-2 border-border border-t-accent" />
            <p className="text-sm text-muted">Loading business settings</p>
          </CardContent>
        </Card>
      </div>
    );
  }

  if (settingsQuery.isError) {
    return (
      <div className="mx-auto w-full max-w-5xl">
        <Card>
          <CardHeader>
            <CardTitle>Could not load settings</CardTitle>
            <CardDescription role="alert" className="text-danger">
              {describeApiError(
                settingsQuery.error,
                'The settings request failed. Nothing was changed. Check the API connection and try again.',
              )}
            </CardDescription>
          </CardHeader>
          <CardContent>
            <Button
              type="button"
              variant="outline"
              onClick={() => void settingsQuery.refetch()}
              disabled={settingsQuery.isFetching}
            >
              <RefreshCw aria-hidden="true" className="size-4" />
              {settingsQuery.isFetching ? 'Retrying' : 'Try again'}
            </Button>
          </CardContent>
        </Card>
      </div>
    );
  }

  return (
    <div className="mx-auto flex w-full max-w-5xl flex-col gap-6">
      <header className="flex flex-wrap items-start justify-between gap-3">
        <div>
          <h1 className="text-3xl font-semibold tracking-tight text-text">Settings</h1>
          <p className="mt-2 max-w-2xl text-sm text-muted">
            Business and outlet configuration for the owner back office. The API validates every
            value and remains the authoritative record.
          </p>
        </div>
        {settingsQuery.isFetching ? (
          <p className="flex items-center gap-2 text-sm text-muted" role="status">
            <RefreshCw aria-hidden="true" className="size-4 animate-spin" />
            Refreshing
          </p>
        ) : null}
      </header>

      <SettingsForm settings={settingsQuery.data} canEdit={canEdit} />
    </div>
  );
}
