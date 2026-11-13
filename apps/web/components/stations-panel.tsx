'use client';

import type { ApiSchemas } from '@modern-pos/api-client';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { RefreshCw, RotateCw, Route, Send, TriangleAlert, Undo2 } from 'lucide-react';
import { useEffect, useMemo, useState } from 'react';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { api } from '@/lib/api';
import { describeApiError } from '@/lib/api-errors';
import { useAuth } from '@/lib/auth';

type Station = ApiSchemas['Station'];
type StationKind = ApiSchemas['StationKind'];
type StationJob = ApiSchemas['StationJob'];
type StationRoute = ApiSchemas['StationRoute'];

const inputClass =
  'h-11 w-full rounded-control border border-control bg-surface px-3 text-sm text-text';

const STATION_KINDS: StationKind[] = ['KITCHEN', 'BAR', 'COLD', 'HOT', 'OTHER'];

const jobStateTone: Record<
  StationJob['state'],
  'neutral' | 'accent' | 'success' | 'warning' | 'danger'
> = {
  QUEUED: 'accent',
  SENDING: 'warning',
  SENT: 'success',
  FAILED: 'danger',
  UNKNOWN: 'warning',
};

interface StationFormState {
  id: string | null;
  revision: number;
  name: string;
  kind: StationKind;
  isDefault: boolean;
  sortOrder: string;
}

const emptyForm: StationFormState = {
  id: null,
  revision: 1,
  name: '',
  kind: 'KITCHEN',
  isDefault: false,
  sortOrder: '0',
};

export function StationsPanel({ outletId }: { outletId: string }) {
  const { user } = useAuth();
  const canEdit = user?.role === 'OWNER';
  const queryClient = useQueryClient();

  const [message, setMessage] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [form, setForm] = useState<StationFormState>(emptyForm);
  const [routingDraft, setRoutingDraft] = useState<Record<string, string>>({});
  const [selectedStationId, setSelectedStationId] = useState<string | null>(null);

  const stationsQuery = useQuery({
    queryKey: ['stations', outletId],
    queryFn: () => api.listStations(outletId),
  });
  const routesQuery = useQuery({
    queryKey: ['station-routes', outletId],
    queryFn: () => api.listStationRoutes(outletId),
  });
  const menuQuery = useQuery({
    queryKey: ['menu', outletId, 'station-routing'],
    queryFn: () => api.listMenu(outletId, { limit: 100 }),
  });

  const stations = stationsQuery.data ?? [];
  const routes = routesQuery.data ?? [];
  const menuItems = menuQuery.data?.items ?? [];

  useEffect(() => {
    const next: Record<string, string> = {};
    for (const route of routes) {
      next[route.menuItemId] = route.stationId;
    }
    setRoutingDraft(next);
  }, [routes]);

  useEffect(() => {
    if (selectedStationId && stations.some((station) => station.id === selectedStationId)) {
      return;
    }
    setSelectedStationId(stations[0]?.id ?? null);
  }, [selectedStationId, stations]);

  const jobsQuery = useQuery({
    queryKey: ['station-jobs', outletId, selectedStationId],
    queryFn: () => api.listStationJobs(outletId, selectedStationId as string, { limit: 50 }),
    enabled: selectedStationId !== null,
  });

  const saveStation = useMutation({
    mutationFn: async () => {
      const payload = {
        name: form.name.trim(),
        kind: form.kind,
        isDefault: form.isDefault,
        sortOrder: Number(form.sortOrder),
      };
      if (form.id) {
        return api.updateStation(outletId, form.id, { ...payload, revision: form.revision });
      }
      return api.createStation(outletId, payload);
    },
    onSuccess: async (station) => {
      setMessage(form.id ? `Station ${station.name} updated.` : `Station ${station.name} created.`);
      setError(null);
      setForm(emptyForm);
      await queryClient.invalidateQueries({ queryKey: ['stations', outletId] });
    },
    onError: (mutationError) => {
      setError(describeApiError(mutationError, 'Could not save the station'));
    },
  });

  const saveRouting = useMutation({
    mutationFn: () =>
      api.replaceStationRoutes(outletId, {
        routes: Object.entries(routingDraft)
          .filter(([, stationId]) => stationId.length > 0)
          .map(([menuItemId, stationId]) => ({ menuItemId, stationId })),
      }),
    onSuccess: async (saved) => {
      setMessage(`Routing saved for ${saved.length} menu item${saved.length === 1 ? '' : 's'}.`);
      setError(null);
      await queryClient.invalidateQueries({ queryKey: ['station-routes', outletId] });
      await queryClient.invalidateQueries({ queryKey: ['stations', outletId] });
    },
    onError: (mutationError) => {
      setError(describeApiError(mutationError, 'Could not save station routing'));
    },
  });

  const retryJob = useMutation({
    mutationFn: (job: StationJob) => api.retryStationJob(outletId, job.id),
    onSuccess: async (job) => {
      setMessage(`Job for ${job.itemName} requeued at ${job.stationName}.`);
      setError(null);
      await refreshJobs();
    },
    onError: (mutationError) => {
      setError(describeApiError(mutationError, 'Could not retry the station job'));
    },
  });

  const reprintJob = useMutation({
    mutationFn: (job: StationJob) => api.reprintStationJob(outletId, job.id, crypto.randomUUID()),
    onSuccess: async (job) => {
      setMessage(`Reprint copy queued for ${job.itemName} at ${job.stationName}.`);
      setError(null);
      await refreshJobs();
    },
    onError: (mutationError) => {
      setError(describeApiError(mutationError, 'Could not queue the station reprint'));
    },
  });

  const recordState = useMutation({
    mutationFn: (input: { job: StationJob; state: StationJob['state'] }) =>
      api.updateStationJobState(outletId, input.job.id, {
        state: input.state,
        attempts: input.job.attempts + (input.state === 'QUEUED' ? 0 : 1),
        lastError: input.state === 'FAILED' ? 'Recorded from back office' : null,
      }),
    onSuccess: async (job) => {
      setMessage(`Delivery state for ${job.itemName} recorded as ${job.state.toLowerCase()}.`);
      setError(null);
      await refreshJobs();
    },
    onError: (mutationError) => {
      setError(describeApiError(mutationError, 'Could not update the station job state'));
    },
  });

  async function refreshJobs(): Promise<void> {
    if (!selectedStationId) {
      return;
    }
    await queryClient.invalidateQueries({
      queryKey: ['station-jobs', outletId, selectedStationId],
    });
  }

  function startEdit(station: Station): void {
    setForm({
      id: station.id,
      revision: station.revision,
      name: station.name,
      kind: station.kind,
      isDefault: station.isDefault,
      sortOrder: String(station.sortOrder),
    });
    setMessage(null);
    setError(null);
  }

  const routeByMenuItem = useMemo(() => {
    const map = new Map<string, StationRoute>();
    for (const route of routes) {
      map.set(route.menuItemId, route);
    }
    return map;
  }, [routes]);

  const jobs = jobsQuery.data?.items ?? [];
  const selectedStation = stations.find((station) => station.id === selectedStationId) ?? null;
  const busy =
    saveStation.isPending ||
    saveRouting.isPending ||
    retryJob.isPending ||
    reprintJob.isPending ||
    recordState.isPending;

  return (
    <div className="flex flex-col gap-6">
      <header>
        <h2 className="text-2xl font-semibold tracking-tight text-text">Kitchen stations</h2>
        <p className="mt-2 max-w-3xl text-sm text-muted">
          Menu items route to kitchen, bar or other stations. Each station owns an independent job
          queue. Amendments and cancellations carry the same order reference, and reprints never
          change sale or stock records.
        </p>
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

      <div className="grid gap-6 lg:grid-cols-[1.1fr_1fr]">
        <Card>
          <CardHeader>
            <CardTitle>Station list</CardTitle>
            <CardDescription>
              Only an owner can create or edit stations. One station per outlet may be the fallback
              for unrouted menu items.
            </CardDescription>
          </CardHeader>
          <CardContent>
            {stationsQuery.isPending ? (
              <p className="text-sm text-muted" role="status">
                Loading stations
              </p>
            ) : stationsQuery.isError ? (
              <div className="flex flex-col items-start gap-3">
                <p className="text-sm text-danger" role="alert">
                  {describeApiError(stationsQuery.error, 'Could not load stations')}
                </p>
                <Button variant="outline" onClick={() => void stationsQuery.refetch()}>
                  <RefreshCw aria-hidden="true" className="size-4" />
                  Try again
                </Button>
              </div>
            ) : stations.length === 0 ? (
              <div className="rounded-control border border-dashed border-control bg-surface-tint p-6">
                <p className="text-sm font-medium text-text">No stations configured</p>
                <p className="mt-1 text-sm text-muted">
                  Create a station first, then route menu items and inspect its queue.
                </p>
              </div>
            ) : (
              <ul className="flex flex-col gap-3">
                {stations.map((station) => (
                  <li
                    key={station.id}
                    className="rounded-control border border-border bg-surface-tint p-4"
                  >
                    <div className="flex flex-wrap items-start justify-between gap-3">
                      <div className="min-w-0">
                        <div className="flex flex-wrap items-center gap-2">
                          <h3 className="text-base font-semibold text-text">{station.name}</h3>
                          <Badge tone="accent">{station.kind}</Badge>
                          {station.isDefault ? <Badge tone="success">Fallback</Badge> : null}
                          <Badge>{station.routeCount} routed</Badge>
                        </div>
                        <p className="mt-2 text-sm text-muted">
                          {station.printerModel
                            ? `Printer model ${station.printerModel}`
                            : 'No printer configuration linked'}
                          {' · '}
                          Sort {station.sortOrder}
                        </p>
                      </div>
                      <div className="flex flex-wrap gap-2">
                        <Button
                          variant="outline"
                          size="sm"
                          onClick={() => setSelectedStationId(station.id)}
                        >
                          View queue
                        </Button>
                        {canEdit ? (
                          <Button variant="ghost" size="sm" onClick={() => startEdit(station)}>
                            Edit
                          </Button>
                        ) : null}
                      </div>
                    </div>
                  </li>
                ))}
              </ul>
            )}
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>{form.id ? 'Edit station' : 'Create station'}</CardTitle>
            <CardDescription>
              {canEdit
                ? 'Station names are unique per outlet. Setting a fallback clears the previous one.'
                : 'This account can read stations but not change them.'}
            </CardDescription>
          </CardHeader>
          <CardContent>
            <form
              className="flex flex-col gap-4"
              onSubmit={(event) => {
                event.preventDefault();
                saveStation.mutate();
              }}
            >
              <label className="flex flex-col gap-1 text-sm font-medium text-text">
                Name
                <input
                  className={inputClass}
                  value={form.name}
                  required
                  maxLength={120}
                  disabled={!canEdit || busy}
                  onChange={(event) => setForm({ ...form, name: event.target.value })}
                />
              </label>
              <label className="flex flex-col gap-1 text-sm font-medium text-text">
                Kind
                <select
                  className={inputClass}
                  value={form.kind}
                  disabled={!canEdit || busy}
                  onChange={(event) =>
                    setForm({ ...form, kind: event.target.value as StationKind })
                  }
                >
                  {STATION_KINDS.map((kind) => (
                    <option key={kind} value={kind}>
                      {kind}
                    </option>
                  ))}
                </select>
              </label>
              <label className="flex flex-col gap-1 text-sm font-medium text-text">
                Sort order
                <input
                  className={inputClass}
                  inputMode="numeric"
                  value={form.sortOrder}
                  disabled={!canEdit || busy}
                  onChange={(event) =>
                    setForm({
                      ...form,
                      sortOrder: event.target.value.replace(/[^0-9]/g, ''),
                    })
                  }
                />
              </label>
              <label className="flex items-center gap-2 text-sm font-medium text-text">
                <input
                  type="checkbox"
                  checked={form.isDefault}
                  disabled={!canEdit || busy}
                  onChange={(event) => setForm({ ...form, isDefault: event.target.checked })}
                />
                Use as fallback for unrouted menu items
              </label>
              <div className="flex flex-wrap gap-2">
                <Button type="submit" disabled={!canEdit || busy}>
                  {form.id ? 'Save station' : 'Create station'}
                </Button>
                {form.id ? (
                  <Button
                    type="button"
                    variant="outline"
                    disabled={busy}
                    onClick={() => setForm(emptyForm)}
                  >
                    Cancel edit
                  </Button>
                ) : null}
              </div>
            </form>
          </CardContent>
        </Card>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Menu item routing</CardTitle>
          <CardDescription>
            Each menu item sends tickets to one station. Unrouted items use the fallback station, or
            the first station by sort order when no fallback is set.
          </CardDescription>
        </CardHeader>
        <CardContent>
          {menuQuery.isPending || routesQuery.isPending ? (
            <p className="text-sm text-muted" role="status">
              Loading menu and routing
            </p>
          ) : menuQuery.isError || routesQuery.isError ? (
            <div className="flex flex-col items-start gap-3">
              <p className="text-sm text-danger" role="alert">
                {describeApiError(
                  menuQuery.error ?? routesQuery.error,
                  'Could not load menu routing',
                )}
              </p>
              <Button
                variant="outline"
                onClick={() => {
                  void menuQuery.refetch();
                  void routesQuery.refetch();
                }}
              >
                <RefreshCw aria-hidden="true" className="size-4" />
                Try again
              </Button>
            </div>
          ) : menuItems.length === 0 ? (
            <p className="text-sm text-muted">No menu items available for routing yet.</p>
          ) : (
            <div className="flex flex-col gap-4">
              <ul className="grid gap-3 md:grid-cols-2">
                {menuItems.map((item) => {
                  const route = routeByMenuItem.get(item.id);
                  return (
                    <li
                      key={item.id}
                      className="rounded-control border border-border bg-surface-tint p-4"
                    >
                      <div className="flex items-start gap-2">
                        <Route aria-hidden="true" className="mt-0.5 size-4 text-accent" />
                        <div className="min-w-0 flex-1">
                          <p className="text-sm font-medium text-text">{item.name}</p>
                          <p className="mt-1 break-words text-xs text-muted">
                            {route
                              ? `${route.stationName} (${route.stationKind})`
                              : 'Fallback station'}
                          </p>
                          <label className="mt-2 flex flex-col gap-1 text-xs font-medium text-muted">
                            Station
                            <select
                              className={inputClass}
                              value={routingDraft[item.id] ?? ''}
                              disabled={!canEdit || busy}
                              onChange={(event) =>
                                setRoutingDraft({
                                  ...routingDraft,
                                  [item.id]: event.target.value,
                                })
                              }
                            >
                              <option value="">Use fallback</option>
                              {stations.map((station) => (
                                <option key={station.id} value={station.id}>
                                  {station.name} ({station.kind})
                                </option>
                              ))}
                            </select>
                          </label>
                        </div>
                      </div>
                    </li>
                  );
                })}
              </ul>
              <div className="flex flex-wrap items-center gap-3">
                <Button
                  type="button"
                  disabled={!canEdit || busy}
                  onClick={() => saveRouting.mutate()}
                >
                  Save routing
                </Button>
                <p className="text-xs text-muted">
                  {Object.values(routingDraft).filter(Boolean).length} explicit route
                  {Object.values(routingDraft).filter(Boolean).length === 1 ? '' : 's'}. Saving
                  replaces the outlet routing table.
                </p>
              </div>
            </div>
          )}
        </CardContent>
      </Card>

      <Card>
        <CardHeader className="flex-row flex-wrap items-start justify-between gap-3">
          <div className="flex flex-col gap-1">
            <CardTitle>Station queue</CardTitle>
            <CardDescription>
              Queues are independent per station. A failed ticket never stalls another station, and
              retry or reprint only touches station jobs.
            </CardDescription>
          </div>
          <div className="flex flex-wrap items-center gap-2">
            <label className="flex items-center gap-2 text-sm text-muted">
              Station
              <select
                className={inputClass}
                value={selectedStationId ?? ''}
                disabled={stations.length === 0}
                onChange={(event) => setSelectedStationId(event.target.value || null)}
              >
                {stations.length === 0 ? <option value="">No stations</option> : null}
                {stations.map((station) => (
                  <option key={station.id} value={station.id}>
                    {station.name}
                  </option>
                ))}
              </select>
            </label>
            <Button
              variant="outline"
              onClick={() => void jobsQuery.refetch()}
              disabled={!selectedStationId || jobsQuery.isFetching}
            >
              <RefreshCw aria-hidden="true" className="size-4" />
              Refresh
            </Button>
          </div>
        </CardHeader>
        <CardContent>
          {!selectedStation ? (
            <p className="text-sm text-muted">Create and select a station to view its queue.</p>
          ) : jobsQuery.isPending ? (
            <p className="text-sm text-muted" role="status">
              Loading {selectedStation.name} queue
            </p>
          ) : jobsQuery.isError ? (
            <div className="flex flex-col items-start gap-3">
              <p className="text-sm text-danger" role="alert">
                {describeApiError(jobsQuery.error, 'Could not load the station queue')}
              </p>
              <Button variant="outline" onClick={() => void jobsQuery.refetch()}>
                <RefreshCw aria-hidden="true" className="size-4" />
                Try again
              </Button>
            </div>
          ) : jobs.length === 0 ? (
            <div className="rounded-control border border-dashed border-control bg-surface-tint p-6">
              <p className="text-sm font-medium text-text">Queue is empty</p>
              <p className="mt-1 text-sm text-muted">
                {selectedStation.name} has no station tickets in the latest page.
              </p>
            </div>
          ) : (
            <ul className="flex flex-col gap-3">
              {jobs.map((job) => (
                <li
                  key={job.id}
                  className="rounded-control border border-border bg-surface-tint p-4"
                >
                  <div className="flex flex-wrap items-start justify-between gap-3">
                    <div className="min-w-0">
                      <div className="flex flex-wrap items-center gap-2">
                        <Badge tone={jobStateTone[job.state]}>{job.state}</Badge>
                        <Badge tone={job.kind === 'CANCEL' ? 'danger' : 'neutral'}>
                          {job.kind}
                        </Badge>
                        {job.copy ? <Badge tone="warning">Reprint</Badge> : null}
                        <p className="text-sm font-semibold text-text">
                          {job.itemName} · {job.variantName} × {job.quantity}
                        </p>
                      </div>
                      <p className="mt-2 break-all text-xs text-muted">
                        Order {job.orderReference} · station {job.stationName} · attempts{' '}
                        {job.attempts}
                      </p>
                      {job.modifiers.length > 0 ? (
                        <p className="mt-1 break-words text-xs text-muted">
                          Modifiers:{' '}
                          {job.modifiers
                            .map((modifier) => String(modifier.name ?? modifier.modifierId ?? ''))
                            .filter(Boolean)
                            .join(', ')}
                        </p>
                      ) : null}
                      {job.lastError ? (
                        <p className="mt-2 flex items-start gap-1 text-xs text-danger">
                          <TriangleAlert aria-hidden="true" className="mt-0.5 size-3.5" />
                          {job.lastError}
                        </p>
                      ) : null}
                    </div>
                    <div className="flex flex-wrap gap-2">
                      {job.state === 'FAILED' || job.state === 'UNKNOWN' ? (
                        <Button
                          variant="outline"
                          size="sm"
                          disabled={busy}
                          onClick={() => retryJob.mutate(job)}
                        >
                          <Undo2 aria-hidden="true" className="size-4" />
                          Retry
                        </Button>
                      ) : null}
                      <Button
                        variant="outline"
                        size="sm"
                        disabled={busy}
                        onClick={() => reprintJob.mutate(job)}
                      >
                        <RotateCw aria-hidden="true" className="size-4" />
                        Reprint
                      </Button>
                      <Button
                        variant="ghost"
                        size="sm"
                        disabled={busy}
                        onClick={() => recordState.mutate({ job, state: 'SENT' })}
                      >
                        <Send aria-hidden="true" className="size-4" />
                        Mark sent
                      </Button>
                      <Button
                        variant="ghost"
                        size="sm"
                        disabled={busy}
                        onClick={() => recordState.mutate({ job, state: 'FAILED' })}
                      >
                        Mark failed
                      </Button>
                    </div>
                  </div>
                </li>
              ))}
            </ul>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
