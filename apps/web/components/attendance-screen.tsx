'use client';

import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { Clock, RefreshCw } from 'lucide-react';
import { useState } from 'react';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { api } from '@/lib/api';
import { describeOperationError } from '@/lib/api-errors';
import { useAuth } from '@/lib/auth';
import { formatDateTimeInZone } from '@/lib/reporting';
import { useActiveOutletId } from '@/lib/use-active-outlet';

const inputClass =
  'h-12 w-full rounded-control border border-control bg-surface px-3 text-sm text-text';

export function AttendanceScreen() {
  const outletId = useActiveOutletId();
  const { user } = useAuth();
  const queryClient = useQueryClient();
  const isOwner = user?.role === 'OWNER';
  const [clockNote, setClockNote] = useState('');
  const [userIdFilter, setUserIdFilter] = useState('');

  const settingsQuery = useQuery({
    queryKey: ['settings', outletId],
    queryFn: () => api.getSettings(outletId as string),
    enabled: Boolean(outletId),
  });
  const timezone = settingsQuery.data?.timezone ?? 'UTC';

  const attendanceQuery = useQuery({
    queryKey: ['attendance', outletId, userIdFilter],
    queryFn: () =>
      api.listAttendance(outletId as string, {
        limit: 50,
        userId: isOwner && userIdFilter ? userIdFilter : undefined,
      }),
    enabled: Boolean(outletId),
  });

  const clockIn = useMutation({
    mutationFn: () => api.clockInAttendance(outletId as string, { note: clockNote || undefined }),
    onSuccess: () => {
      setClockNote('');
      void queryClient.invalidateQueries({ queryKey: ['attendance', outletId] });
    },
  });

  const clockOut = useMutation({
    mutationFn: () => api.clockOutAttendance(outletId as string, { note: clockNote || undefined }),
    onSuccess: () => {
      setClockNote('');
      void queryClient.invalidateQueries({ queryKey: ['attendance', outletId] });
    },
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

  const items = attendanceQuery.data?.items ?? [];

  return (
    <div className="flex w-full flex-col gap-6">
      <header>
        <h1 className="text-3xl font-semibold tracking-tight text-text">Attendance</h1>
        <p className="mt-2 max-w-3xl text-sm text-muted">
          Attendance is independent from drawer shifts. Clocking in or out never opens, changes or
          closes a shift.
        </p>
      </header>

      <Card>
        <CardHeader>
          <CardTitle>Clock</CardTitle>
          <CardDescription>
            Each clock record keeps the signed-in actor and an optional note.
          </CardDescription>
        </CardHeader>
        <CardContent className="flex flex-col gap-3">
          <label className="flex max-w-xl flex-col gap-1 text-sm font-medium text-text">
            Note (optional)
            <input
              className={inputClass}
              value={clockNote}
              maxLength={240}
              onChange={(event) => setClockNote(event.target.value)}
            />
          </label>
          <div className="flex flex-wrap gap-3">
            <Button onClick={() => clockIn.mutate()} disabled={clockIn.isPending}>
              <Clock aria-hidden="true" className="size-4" />
              {clockIn.isPending ? 'Clocking in…' : 'Clock in'}
            </Button>
            <Button
              variant="outline"
              onClick={() => clockOut.mutate()}
              disabled={clockOut.isPending}
            >
              {clockOut.isPending ? 'Clocking out…' : 'Clock out'}
            </Button>
          </div>
          {clockIn.isError || clockOut.isError ? (
            <p className="text-sm text-danger" role="alert">
              {describeOperationError(
                clockIn.error ?? clockOut.error,
                'Could not save the attendance record',
              )}
            </p>
          ) : null}
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Records</CardTitle>
          <CardDescription>
            {isOwner
              ? 'Owners can filter by staff user ID and read every outlet record.'
              : 'Staff see only their own attendance records.'}
          </CardDescription>
        </CardHeader>
        <CardContent className="flex flex-col gap-4">
          {isOwner ? (
            <label className="flex max-w-xl flex-col gap-1 text-sm font-medium text-text">
              Staff user ID (optional)
              <input
                className={inputClass}
                value={userIdFilter}
                onChange={(event) => setUserIdFilter(event.target.value)}
                placeholder="UUID"
              />
            </label>
          ) : null}

          {attendanceQuery.isLoading ? (
            <div className="flex flex-col gap-2" role="status" aria-busy="true">
              <div className="h-12 animate-pulse rounded-control bg-surface-muted" />
              <div className="h-12 animate-pulse rounded-control bg-surface-muted" />
              <div className="h-12 animate-pulse rounded-control bg-surface-muted" />
            </div>
          ) : attendanceQuery.isError ? (
            <div className="flex flex-col items-start gap-3" role="alert">
              <p className="text-sm text-danger">
                {describeOperationError(attendanceQuery.error, 'Could not load attendance')}
              </p>
              <Button variant="outline" onClick={() => void attendanceQuery.refetch()}>
                <RefreshCw aria-hidden="true" className="size-4" />
                Try again
              </Button>
            </div>
          ) : items.length === 0 ? (
            <p className="text-sm text-muted">No attendance records for this filter.</p>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full min-w-[640px] text-left text-sm">
                <thead>
                  <tr className="border-b border-border text-xs uppercase tracking-[0.12em] text-muted">
                    <th className="py-2 pr-3 font-medium">Staff</th>
                    <th className="py-2 pr-3 font-medium">Clock in</th>
                    <th className="py-2 pr-3 font-medium">Clock out</th>
                    <th className="py-2 font-medium">State</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-border">
                  {items.map((item) => (
                    <tr key={item.id}>
                      <td className="py-2 pr-3 font-mono text-xs text-muted">{item.userId}</td>
                      <td className="py-2 pr-3 text-text">
                        {formatDateTimeInZone(item.clockInAt, timezone)}
                      </td>
                      <td className="py-2 pr-3 text-text">
                        {item.clockOutAt ? formatDateTimeInZone(item.clockOutAt, timezone) : 'Open'}
                      </td>
                      <td className="py-2">
                        <Badge tone={item.clockOutAt ? 'neutral' : 'success'}>
                          {item.clockOutAt ? 'Closed' : 'Clocked in'}
                        </Badge>
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
