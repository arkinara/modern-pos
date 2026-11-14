'use client';

import { useQuery } from '@tanstack/react-query';
import Link from 'next/link';
import { RefreshCw } from 'lucide-react';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { api } from '@/lib/api';
import { describeApiError } from '@/lib/api-errors';
import { useAuth } from '@/lib/auth';
import { StationsPanel } from '@/components/stations-panel';
import { useActiveOutletId } from '@/lib/use-active-outlet';

export function PrintersScreen() {
  const outletId = useActiveOutletId();
  const { user } = useAuth();
  const isOwner = user?.role === 'OWNER';

  const settingsQuery = useQuery({
    queryKey: ['settings', outletId],
    queryFn: () => api.getSettings(outletId as string),
    enabled: outletId !== null && isOwner,
    retry: 1,
  });

  const printersQuery = useQuery({
    queryKey: ['printers', outletId],
    queryFn: () => api.listPrinters(outletId as string),
    enabled: outletId !== null && isOwner,
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

      {!isOwner ? (
        <Card>
          <CardHeader>
            <CardTitle>Owner-only printer configuration</CardTitle>
            <CardDescription role="alert">
              Printer configuration is visible to owners. Pairing, discovery and physical printing
              stay on the Android app.
            </CardDescription>
          </CardHeader>
        </Card>
      ) : !outletId ? (
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
              <CardTitle>Registered printer configuration</CardTitle>
              <CardDescription>
                Read-only metadata from the API. A listed printer is not proof that it is online,
                connected or physically tested. Discovery, pairing and printing stay on the Android
                app.
              </CardDescription>
            </CardHeader>
            <CardContent>
              {printersQuery.isPending ? (
                <p className="flex items-center gap-2 text-sm text-muted" role="status">
                  <span className="size-5 animate-spin rounded-full border-2 border-border border-t-accent" />
                  Loading printer configuration
                </p>
              ) : printersQuery.isError ? (
                <div className="flex flex-col items-start gap-3" role="alert">
                  <p className="text-sm text-danger">
                    {describeApiError(
                      printersQuery.error,
                      'Could not load registered printers. Nothing was changed.',
                    )}
                  </p>
                  <Button
                    type="button"
                    variant="outline"
                    size="sm"
                    onClick={() => void printersQuery.refetch()}
                    disabled={printersQuery.isFetching}
                  >
                    <RefreshCw aria-hidden="true" className="size-4" />
                    {printersQuery.isFetching ? 'Retrying' : 'Try again'}
                  </Button>
                </div>
              ) : printersQuery.data.length === 0 ? (
                <div className="rounded-control border border-dashed border-control bg-surface-tint p-6">
                  <Badge tone="neutral">No printer configuration registered</Badge>
                  <p className="mt-3 text-sm text-muted">
                    This outlet has no registered printer metadata yet. This is an empty state, not
                    a connection failure. Register a printer through the authenticated API before
                    pairing it on an Android device.
                  </p>
                </div>
              ) : (
                <ul className="flex flex-col gap-3">
                  {(printersQuery.data ?? []).map((printer) => (
                    <li
                      key={printer.id}
                      className="rounded-control border border-border bg-surface-tint p-4"
                    >
                      <dl className="grid gap-3 sm:grid-cols-2 lg:grid-cols-4">
                        <div className="sm:col-span-2">
                          <dt className="text-xs font-medium uppercase tracking-[0.12em] text-muted">
                            Name
                          </dt>
                          <dd className="mt-1 break-words text-sm font-medium text-text">
                            {printer.name}
                          </dd>
                        </div>
                        <div>
                          <dt className="text-xs font-medium uppercase tracking-[0.12em] text-muted">
                            Model
                          </dt>
                          <dd className="mt-1 break-words text-sm text-text">{printer.model}</dd>
                        </div>
                        <div>
                          <dt className="text-xs font-medium uppercase tracking-[0.12em] text-muted">
                            Transport
                          </dt>
                          <dd className="mt-1 text-sm text-text">{printer.transport}</dd>
                        </div>
                        <div>
                          <dt className="text-xs font-medium uppercase tracking-[0.12em] text-muted">
                            Paper width
                          </dt>
                          <dd className="mt-1 text-sm text-text">{printer.paperWidthMm} mm</dd>
                        </div>
                        <div>
                          <dt className="text-xs font-medium uppercase tracking-[0.12em] text-muted">
                            Encoding
                          </dt>
                          <dd className="mt-1 break-words text-sm text-text">{printer.encoding}</dd>
                        </div>
                      </dl>
                    </li>
                  ))}
                </ul>
              )}
            </CardContent>
          </Card>

          <StationsPanel outletId={outletId} />
        </>
      )}
    </div>
  );
}
