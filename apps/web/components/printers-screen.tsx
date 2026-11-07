'use client';

import { useQuery } from '@tanstack/react-query';
import Link from 'next/link';
import { RefreshCw } from 'lucide-react';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { api } from '@/lib/api';
import { describeApiError } from '@/lib/api-errors';
import { useActiveOutletId } from '@/lib/use-active-outlet';

export function PrintersScreen() {
  const outletId = useActiveOutletId();

  const settingsQuery = useQuery({
    queryKey: ['settings', outletId],
    queryFn: () => api.getSettings(outletId as string),
    enabled: outletId !== null,
    retry: 1,
  });

  return (
    <div className="mx-auto flex w-full max-w-5xl flex-col gap-6">
      <header>
        <h1 className="text-3xl font-semibold tracking-tight text-text">Printers</h1>
        <p className="mt-2 max-w-2xl text-sm text-muted">
          Receipt identity and printer status for this outlet. Device discovery, pairing and
          physical printing stay on the Android app.
        </p>
      </header>

      {!outletId ? (
        <Card>
          <CardHeader>
            <CardTitle>No outlet assigned</CardTitle>
            <CardDescription>
              This account has no outlet scope, so printer configuration cannot be loaded.
            </CardDescription>
          </CardHeader>
        </Card>
      ) : settingsQuery.isPending ? (
        <Card>
          <CardContent
            className="flex min-h-40 flex-col items-center justify-center gap-3 pt-6"
            role="status"
          >
            <span className="size-8 animate-spin rounded-full border-2 border-border border-t-accent" />
            <p className="text-sm text-muted">Loading printer configuration</p>
          </CardContent>
        </Card>
      ) : settingsQuery.isError ? (
        <Card>
          <CardHeader>
            <CardTitle>Could not load printer configuration</CardTitle>
            <CardDescription role="alert" className="text-danger">
              {describeApiError(
                settingsQuery.error,
                'The configuration request failed. Nothing was changed. Check the API connection and try again.',
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
      ) : (
        <>
          <Card>
            <CardHeader className="flex-row flex-wrap items-start justify-between gap-3">
              <div className="flex flex-col gap-1">
                <CardTitle>Receipt identity</CardTitle>
                <CardDescription>
                  Text sent to the Android printing surface for mobile-recorded sales.
                </CardDescription>
              </div>
              <Button asChild variant="outline" size="sm">
                <Link href="/settings">Edit in Settings</Link>
              </Button>
            </CardHeader>
            <CardContent>
              <dl className="grid gap-4 md:grid-cols-2">
                <div className="md:col-span-2">
                  <dt className="text-xs font-medium uppercase tracking-[0.16em] text-muted">
                    Business
                  </dt>
                  <dd className="mt-1 break-words text-sm text-text">
                    {settingsQuery.data.businessName}
                  </dd>
                </div>
                <div>
                  <dt className="text-xs font-medium uppercase tracking-[0.16em] text-muted">
                    Receipt header
                  </dt>
                  <dd className="mt-1 whitespace-pre-wrap break-words text-sm text-text">
                    {settingsQuery.data.receiptHeader || 'Not set'}
                  </dd>
                </div>
                <div>
                  <dt className="text-xs font-medium uppercase tracking-[0.16em] text-muted">
                    Receipt footer
                  </dt>
                  <dd className="mt-1 whitespace-pre-wrap break-words text-sm text-text">
                    {settingsQuery.data.receiptFooter || 'Not set'}
                  </dd>
                </div>
                <div className="md:col-span-2">
                  <dt className="text-xs font-medium uppercase tracking-[0.16em] text-muted">
                    Receipt address
                  </dt>
                  <dd className="mt-1 whitespace-pre-wrap break-words text-sm text-text">
                    {settingsQuery.data.receiptAddress || 'Not set'}
                  </dd>
                </div>
              </dl>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Printer status</CardTitle>
              <CardDescription>
                This back office displays status only. It does not discover or pair devices.
              </CardDescription>
            </CardHeader>
            <CardContent className="flex flex-wrap items-center gap-3 rounded-control border border-dashed border-control bg-surface-tint p-6">
              <Badge tone="neutral">No printer registered</Badge>
              <p className="text-sm text-muted">
                Pairing, runtime permissions and physical printing arrive with tickets #15 and #16
                on Android.
              </p>
            </CardContent>
          </Card>
        </>
      )}
    </div>
  );
}
