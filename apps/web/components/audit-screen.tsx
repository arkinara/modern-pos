'use client';

import type { ApiSchemas } from '@modern-pos/api-client';
import { useQuery } from '@tanstack/react-query';
import { RefreshCw, Search } from 'lucide-react';
import { useState } from 'react';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { api } from '@/lib/api';
import { describeOperationError } from '@/lib/api-errors';
import { formatDateTimeInZone } from '@/lib/reporting';
import { useActiveOutletId } from '@/lib/use-active-outlet';

type AuditAction = ApiSchemas['OperationAuditEntry']['action'];

const ACTIONS: AuditAction[] = [
  'SHIFT_OPENED',
  'SHIFT_CLOSED',
  'CASH_PAID_IN',
  'CASH_PAID_OUT',
  'ATTENDANCE_CLOCK_IN',
  'ATTENDANCE_CLOCK_OUT',
];

const inputClass =
  'h-12 w-full rounded-control border border-control bg-surface px-3 text-sm text-text';

function toIso(value: string): string | undefined {
  if (!value) {
    return undefined;
  }
  const date = new Date(value);
  return Number.isNaN(date.getTime()) ? undefined : date.toISOString();
}

export function AuditScreen() {
  const outletId = useActiveOutletId();
  const [actorId, setActorId] = useState('');
  const [action, setAction] = useState<'' | AuditAction>('');
  const [from, setFrom] = useState('');
  const [to, setTo] = useState('');
  const [cursor, setCursor] = useState<string | undefined>(undefined);
  const [applied, setApplied] = useState({
    actorId: '',
    action: '' as '' | AuditAction,
    from: '',
    to: '',
  });

  const settingsQuery = useQuery({
    queryKey: ['settings', outletId],
    queryFn: () => api.getSettings(outletId as string),
    enabled: Boolean(outletId),
  });
  const timezone = settingsQuery.data?.timezone ?? 'UTC';

  const auditQuery = useQuery({
    queryKey: ['audit', outletId, applied, cursor],
    queryFn: () =>
      api.searchAudit(outletId as string, {
        actorId: applied.actorId || undefined,
        action: applied.action || undefined,
        from: toIso(applied.from),
        to: toIso(applied.to),
        cursor,
        limit: 25,
      }),
    enabled: Boolean(outletId),
  });

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

  const items = auditQuery.data?.items ?? [];
  const invalidRange = Boolean(from && to && from > to);

  return (
    <div className="flex w-full flex-col gap-6">
      <header>
        <h1 className="text-3xl font-semibold tracking-tight text-text">Audit search</h1>
        <p className="mt-2 max-w-3xl text-sm text-muted">
          Owner-only search over shift and attendance events. Filter by actor, action and time
          range, then page with a stable cursor. Outlet scope is enforced server-side.
        </p>
      </header>

      <Card>
        <CardHeader>
          <CardTitle>Filters</CardTitle>
          <CardDescription>
            Times are interpreted in your browser and stored in UTC.
          </CardDescription>
        </CardHeader>
        <CardContent>
          <form
            className="grid gap-4 lg:grid-cols-2"
            onSubmit={(event) => {
              event.preventDefault();
              setCursor(undefined);
              setApplied({ actorId, action, from, to });
            }}
          >
            <label className="flex flex-col gap-1 text-sm font-medium text-text">
              Actor user ID
              <input
                className={inputClass}
                value={actorId}
                onChange={(event) => setActorId(event.target.value)}
                placeholder="UUID"
              />
            </label>
            <label className="flex flex-col gap-1 text-sm font-medium text-text">
              Action
              <select
                className={inputClass}
                value={action}
                onChange={(event) => setAction(event.target.value as '' | AuditAction)}
              >
                <option value="">All actions</option>
                {ACTIONS.map((item) => (
                  <option key={item} value={item}>
                    {item.replaceAll('_', ' ')}
                  </option>
                ))}
              </select>
            </label>
            <label className="flex flex-col gap-1 text-sm font-medium text-text">
              From
              <input
                className={inputClass}
                type="datetime-local"
                value={from}
                onChange={(event) => setFrom(event.target.value)}
              />
            </label>
            <label className="flex flex-col gap-1 text-sm font-medium text-text">
              To
              <input
                className={inputClass}
                type="datetime-local"
                value={to}
                onChange={(event) => setTo(event.target.value)}
              />
            </label>
            <div className="flex flex-wrap items-center gap-3 lg:col-span-2">
              <Button type="submit" disabled={invalidRange}>
                <Search aria-hidden="true" className="size-4" />
                Search
              </Button>
              <Button variant="outline" type="button" onClick={() => void auditQuery.refetch()}>
                <RefreshCw aria-hidden="true" className="size-4" />
                Refresh
              </Button>
              {invalidRange ? (
                <span className="text-sm text-danger" role="alert">
                  The start time must be before the end time.
                </span>
              ) : null}
            </div>
          </form>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Events</CardTitle>
          <CardDescription>{items.length} event(s) on this page.</CardDescription>
        </CardHeader>
        <CardContent className="flex flex-col gap-4">
          {auditQuery.isLoading ? (
            <div className="flex flex-col gap-2" role="status" aria-busy="true">
              <div className="h-14 animate-pulse rounded-control bg-surface-muted" />
              <div className="h-14 animate-pulse rounded-control bg-surface-muted" />
              <div className="h-14 animate-pulse rounded-control bg-surface-muted" />
            </div>
          ) : auditQuery.isError ? (
            <div className="flex flex-col items-start gap-3" role="alert">
              <p className="text-sm text-danger">
                {describeOperationError(auditQuery.error, 'Could not search the audit trail')}
              </p>
              <Button variant="outline" onClick={() => void auditQuery.refetch()}>
                <RefreshCw aria-hidden="true" className="size-4" />
                Try again
              </Button>
            </div>
          ) : items.length === 0 ? (
            <p className="text-sm text-muted">No audit event matches this filter.</p>
          ) : (
            <ul className="divide-y divide-border rounded-surface border border-border">
              {items.map((item) => (
                <li key={item.id} className="flex flex-col gap-1 px-3 py-3 text-sm">
                  <div className="flex flex-wrap items-center justify-between gap-2">
                    <Badge tone="accent">{item.action.replaceAll('_', ' ')}</Badge>
                    <span className="text-xs text-muted">
                      {formatDateTimeInZone(item.createdAt, timezone)}
                    </span>
                  </div>
                  <p className="text-text">
                    {item.entityType} <span className="font-mono text-xs">{item.entityId}</span>
                  </p>
                  <p className="font-mono text-xs text-muted">Actor {item.actorId}</p>
                  {Object.keys(item.metadata).length > 0 ? (
                    <p className="break-all font-mono text-xs text-muted">
                      {JSON.stringify(item.metadata)}
                    </p>
                  ) : null}
                </li>
              ))}
            </ul>
          )}

          <div className="flex flex-wrap items-center gap-3">
            <Button variant="outline" disabled={!cursor} onClick={() => setCursor(undefined)}>
              First page
            </Button>
            <Button
              variant="outline"
              disabled={!auditQuery.data?.nextCursor}
              onClick={() => setCursor(auditQuery.data?.nextCursor ?? undefined)}
            >
              Next page
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
