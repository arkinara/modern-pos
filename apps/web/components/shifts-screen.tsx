'use client';

import type { ApiSchemas } from '@modern-pos/api-client';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { CircleAlert, RefreshCw, Wallet } from 'lucide-react';
import { useState } from 'react';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { api } from '@/lib/api';
import { describeOperationError } from '@/lib/api-errors';
import { useAuth } from '@/lib/auth';
import { formatDateTimeInZone, formatMoney } from '@/lib/reporting';
import { useActiveOutletId } from '@/lib/use-active-outlet';

type Shift = ApiSchemas['Shift'];
type ShiftReport = ApiSchemas['ShiftReport'];

const inputClass =
  'h-12 w-full rounded-control border border-control bg-surface px-3 text-sm text-text';

function Money({
  minor,
  currency,
  exponent,
}: {
  minor: number | null | undefined;
  currency: string;
  exponent: number;
}) {
  if (minor === null || minor === undefined) {
    return <span className="text-muted">Not counted</span>;
  }
  return <span className="tabular-nums">{formatMoney(minor, currency, exponent)}</span>;
}

export function ShiftsScreen() {
  const outletId = useActiveOutletId();
  const { user } = useAuth();
  const queryClient = useQueryClient();
  const isOwner = user?.role === 'OWNER';
  const [selectedId, setSelectedId] = useState<string | null>(null);
  const [openingFloat, setOpeningFloat] = useState('0');
  const [movementKind, setMovementKind] = useState<'PAID_IN' | 'PAID_OUT'>('PAID_IN');
  const [movementAmount, setMovementAmount] = useState('');
  const [movementReason, setMovementReason] = useState('');
  const [countedCash, setCountedCash] = useState('');
  const [closeNote, setCloseNote] = useState('');

  const settingsQuery = useQuery({
    queryKey: ['settings', outletId],
    queryFn: () => api.getSettings(outletId as string),
    enabled: Boolean(outletId),
  });
  const timezone = settingsQuery.data?.timezone ?? 'UTC';
  const currency = settingsQuery.data?.currency ?? 'IDR';
  const exponent = settingsQuery.data?.currencyExponent ?? 0;

  const shiftsQuery = useQuery({
    queryKey: ['shifts', outletId],
    queryFn: () => api.listShifts(outletId as string, { limit: 50 }),
    enabled: Boolean(outletId),
  });

  const selected = shiftsQuery.data?.items.find((shift) => shift.id === selectedId) ?? null;

  const reportQuery = useQuery({
    queryKey: ['shift-report', outletId, selectedId],
    queryFn: () => api.getShiftReport(outletId as string, selectedId as string),
    enabled: Boolean(outletId && selectedId && isOwner),
  });

  const openMutation = useMutation({
    mutationFn: (openingFloatMinor: number) =>
      api.openShift(outletId as string, { openingFloatMinor }),
    onSuccess: (shift) => {
      setSelectedId(shift.id);
      setOpeningFloat('0');
      void queryClient.invalidateQueries({ queryKey: ['shifts', outletId] });
    },
  });

  const movementMutation = useMutation({
    mutationFn: (input: {
      shiftId: string;
      kind: 'PAID_IN' | 'PAID_OUT';
      amountMinor: number;
      reason: string;
    }) =>
      api.recordShiftCashMovement(outletId as string, input.shiftId, {
        kind: input.kind,
        amountMinor: input.amountMinor,
        reason: input.reason,
      }),
    onSuccess: () => {
      setMovementAmount('');
      setMovementReason('');
      void queryClient.invalidateQueries({ queryKey: ['shifts', outletId] });
      void queryClient.invalidateQueries({ queryKey: ['shift-report', outletId, selectedId] });
    },
  });

  const closeMutation = useMutation({
    mutationFn: (input: { shiftId: string; countedCashMinor: number; note?: string }) =>
      api.closeShift(outletId as string, input.shiftId, {
        countedCashMinor: input.countedCashMinor,
        note: input.note,
      }),
    onSuccess: () => {
      setCountedCash('');
      setCloseNote('');
      void queryClient.invalidateQueries({ queryKey: ['shifts', outletId] });
      void queryClient.invalidateQueries({ queryKey: ['shift-report', outletId, selectedId] });
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

  const shifts = shiftsQuery.data?.items ?? [];

  return (
    <div className="flex w-full flex-col gap-6">
      <header>
        <h1 className="text-3xl font-semibold tracking-tight text-text">Shifts</h1>
        <p className="mt-2 max-w-3xl text-sm text-muted">
          Open a drawer with an opening float, record paid-in and paid-out cash, then close with a
          counted amount. Expected cash is opening float plus cash sales plus paid-ins minus
          paid-outs.
        </p>
      </header>

      <div className="grid gap-6 lg:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle>Open a shift</CardTitle>
            <CardDescription>
              One open shift per staff member and outlet. The actor is recorded on the shift.
            </CardDescription>
          </CardHeader>
          <CardContent>
            <form
              className="flex flex-col gap-3"
              onSubmit={(event) => {
                event.preventDefault();
                openMutation.mutate(Number(openingFloat));
              }}
            >
              <label className="flex flex-col gap-1 text-sm font-medium text-text">
                Opening float (minor units)
                <input
                  className={inputClass}
                  type="number"
                  min="0"
                  step="1"
                  value={openingFloat}
                  onChange={(event) => setOpeningFloat(event.target.value)}
                  required
                />
              </label>
              <Button type="submit" disabled={openMutation.isPending}>
                <Wallet aria-hidden="true" className="size-4" />
                {openMutation.isPending ? 'Opening…' : 'Open shift'}
              </Button>
              {openMutation.isError ? (
                <p className="text-sm text-danger" role="alert">
                  {describeOperationError(openMutation.error, 'Could not open the shift')}
                </p>
              ) : null}
            </form>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Shift list</CardTitle>
            <CardDescription>
              Most recent first. Select a shift to record cash or close it.
            </CardDescription>
          </CardHeader>
          <CardContent>
            {shiftsQuery.isLoading ? (
              <div className="flex flex-col gap-2" role="status" aria-busy="true">
                <div className="h-12 animate-pulse rounded-control bg-surface-muted" />
                <div className="h-12 animate-pulse rounded-control bg-surface-muted" />
              </div>
            ) : shiftsQuery.isError ? (
              <div className="flex flex-col items-start gap-3" role="alert">
                <p className="text-sm text-danger">
                  {describeOperationError(shiftsQuery.error, 'Could not load shifts')}
                </p>
                <Button variant="outline" onClick={() => void shiftsQuery.refetch()}>
                  <RefreshCw aria-hidden="true" className="size-4" />
                  Try again
                </Button>
              </div>
            ) : shifts.length === 0 ? (
              <p className="text-sm text-muted">No shifts yet. Open one above to start a drawer.</p>
            ) : (
              <ul className="flex flex-col gap-2">
                {shifts.map((shift) => (
                  <li key={shift.id}>
                    <button
                      type="button"
                      onClick={() => setSelectedId(shift.id)}
                      className={`w-full rounded-control border px-3 py-2 text-left text-sm transition-colors ${
                        selectedId === shift.id
                          ? 'border-accent bg-accent-soft'
                          : 'border-border bg-surface hover:bg-surface-muted'
                      }`}
                    >
                      <span className="flex items-center justify-between gap-2">
                        <span className="font-medium text-text">
                          {formatDateTimeInZone(shift.openedAt, timezone)}
                        </span>
                        <Badge tone={shift.status === 'OPEN' ? 'success' : 'neutral'}>
                          {shift.status}
                        </Badge>
                      </span>
                      <span className="mt-1 block text-xs text-muted">
                        Float{' '}
                        <Money
                          minor={shift.openingFloatMinor}
                          currency={currency}
                          exponent={exponent}
                        />{' '}
                        · Expected{' '}
                        <Money
                          minor={shift.expectedCashMinor}
                          currency={currency}
                          exponent={exponent}
                        />
                      </span>
                    </button>
                  </li>
                ))}
              </ul>
            )}
          </CardContent>
        </Card>
      </div>

      {selected ? (
        <div className="grid gap-6 lg:grid-cols-2">
          <Card>
            <CardHeader>
              <CardTitle>Cash movement</CardTitle>
              <CardDescription>
                Every paid-in and paid-out records the reason and the signed-in actor.
              </CardDescription>
            </CardHeader>
            <CardContent>
              {selected.status === 'OPEN' ? (
                <form
                  className="flex flex-col gap-3"
                  onSubmit={(event) => {
                    event.preventDefault();
                    movementMutation.mutate({
                      shiftId: selected.id,
                      kind: movementKind,
                      amountMinor: Number(movementAmount),
                      reason: movementReason,
                    });
                  }}
                >
                  <label className="flex flex-col gap-1 text-sm font-medium text-text">
                    Direction
                    <select
                      className={inputClass}
                      value={movementKind}
                      onChange={(event) =>
                        setMovementKind(event.target.value as 'PAID_IN' | 'PAID_OUT')
                      }
                    >
                      <option value="PAID_IN">Paid in</option>
                      <option value="PAID_OUT">Paid out</option>
                    </select>
                  </label>
                  <label className="flex flex-col gap-1 text-sm font-medium text-text">
                    Amount (minor units)
                    <input
                      className={inputClass}
                      type="number"
                      min="1"
                      step="1"
                      value={movementAmount}
                      onChange={(event) => setMovementAmount(event.target.value)}
                      required
                    />
                  </label>
                  <label className="flex flex-col gap-1 text-sm font-medium text-text">
                    Reason
                    <input
                      className={inputClass}
                      value={movementReason}
                      maxLength={240}
                      onChange={(event) => setMovementReason(event.target.value)}
                      required
                    />
                  </label>
                  <Button type="submit" disabled={movementMutation.isPending}>
                    {movementMutation.isPending ? 'Recording…' : 'Record movement'}
                  </Button>
                  {movementMutation.isError ? (
                    <p className="text-sm text-danger" role="alert">
                      {describeOperationError(
                        movementMutation.error,
                        'Could not record the movement',
                      )}
                    </p>
                  ) : null}
                </form>
              ) : (
                <p className="text-sm text-muted">This shift is closed and cannot be changed.</p>
              )}
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Close shift</CardTitle>
              <CardDescription>
                Enter the counted drawer total. A negative discrepancy means short; a positive one
                means over.
              </CardDescription>
            </CardHeader>
            <CardContent>
              {selected.status === 'OPEN' ? (
                <form
                  className="flex flex-col gap-3"
                  onSubmit={(event) => {
                    event.preventDefault();
                    closeMutation.mutate({
                      shiftId: selected.id,
                      countedCashMinor: Number(countedCash),
                      note: closeNote || undefined,
                    });
                  }}
                >
                  <label className="flex flex-col gap-1 text-sm font-medium text-text">
                    Counted cash (minor units)
                    <input
                      className={inputClass}
                      type="number"
                      min="0"
                      step="1"
                      value={countedCash}
                      onChange={(event) => setCountedCash(event.target.value)}
                      required
                    />
                  </label>
                  <label className="flex flex-col gap-1 text-sm font-medium text-text">
                    Note (optional)
                    <input
                      className={inputClass}
                      value={closeNote}
                      maxLength={500}
                      onChange={(event) => setCloseNote(event.target.value)}
                    />
                  </label>
                  <Button type="submit" disabled={closeMutation.isPending}>
                    {closeMutation.isPending ? 'Closing…' : 'Close shift'}
                  </Button>
                  {closeMutation.isError ? (
                    <p className="text-sm text-danger" role="alert">
                      {describeOperationError(closeMutation.error, 'Could not close the shift')}
                    </p>
                  ) : null}
                </form>
              ) : (
                <dl className="grid grid-cols-2 gap-3 text-sm">
                  <div>
                    <dt className="text-muted">Expected</dt>
                    <dd className="font-medium text-text">
                      <Money
                        minor={selected.expectedCashMinor}
                        currency={currency}
                        exponent={exponent}
                      />
                    </dd>
                  </div>
                  <div>
                    <dt className="text-muted">Counted</dt>
                    <dd className="font-medium text-text">
                      <Money
                        minor={selected.countedCashMinor}
                        currency={currency}
                        exponent={exponent}
                      />
                    </dd>
                  </div>
                  <div>
                    <dt className="text-muted">Discrepancy</dt>
                    <dd className="font-medium text-text">
                      <Money
                        minor={selected.discrepancyMinor}
                        currency={currency}
                        exponent={exponent}
                      />
                    </dd>
                  </div>
                  <div>
                    <dt className="text-muted">Closed</dt>
                    <dd className="font-medium text-text">
                      {selected.closedAt ? formatDateTimeInZone(selected.closedAt, timezone) : '—'}
                    </dd>
                  </div>
                </dl>
              )}
            </CardContent>
          </Card>
        </div>
      ) : null}

      {selected && isOwner ? (
        <Card>
          <CardHeader>
            <CardTitle>Shift report</CardTitle>
            <CardDescription>
              Reconciled cash summary and settled sales by payment method for this shift window.
            </CardDescription>
          </CardHeader>
          <CardContent>
            {reportQuery.isLoading ? (
              <p className="text-sm text-muted" role="status">
                Loading shift report…
              </p>
            ) : reportQuery.isError ? (
              <div className="flex items-start gap-2" role="alert">
                <CircleAlert aria-hidden="true" className="mt-0.5 size-4 text-danger" />
                <p className="text-sm text-danger">
                  {describeOperationError(reportQuery.error, 'Could not load the shift report')}
                </p>
              </div>
            ) : reportQuery.data ? (
              <ShiftReportView
                report={reportQuery.data}
                currency={currency}
                exponent={exponent}
                timezone={timezone}
              />
            ) : null}
          </CardContent>
        </Card>
      ) : null}
    </div>
  );
}

function ShiftReportView({
  report,
  currency,
  exponent,
  timezone,
}: {
  report: ShiftReport;
  currency: string;
  exponent: number;
  timezone: string;
}) {
  return (
    <div className="flex flex-col gap-5">
      <dl className="grid gap-3 sm:grid-cols-2 lg:grid-cols-4">
        <div className="rounded-surface border border-border bg-surface-tint p-3">
          <dt className="text-xs uppercase tracking-[0.12em] text-muted">Opening float</dt>
          <dd className="mt-1 text-lg font-semibold tabular-nums text-text">
            <Money minor={report.shift.openingFloatMinor} currency={currency} exponent={exponent} />
          </dd>
        </div>
        <div className="rounded-surface border border-border bg-surface-tint p-3">
          <dt className="text-xs uppercase tracking-[0.12em] text-muted">Expected cash</dt>
          <dd className="mt-1 text-lg font-semibold tabular-nums text-text">
            <Money minor={report.shift.expectedCashMinor} currency={currency} exponent={exponent} />
          </dd>
        </div>
        <div className="rounded-surface border border-border bg-surface-tint p-3">
          <dt className="text-xs uppercase tracking-[0.12em] text-muted">Counted cash</dt>
          <dd className="mt-1 text-lg font-semibold tabular-nums text-text">
            <Money minor={report.shift.countedCashMinor} currency={currency} exponent={exponent} />
          </dd>
        </div>
        <div className="rounded-surface border border-border bg-surface-tint p-3">
          <dt className="text-xs uppercase tracking-[0.12em] text-muted">Discrepancy</dt>
          <dd className="mt-1 text-lg font-semibold tabular-nums text-text">
            <Money minor={report.shift.discrepancyMinor} currency={currency} exponent={exponent} />
          </dd>
        </div>
      </dl>

      <div>
        <h3 className="text-sm font-semibold text-text">Sales by payment method</h3>
        <ul className="mt-2 divide-y divide-border rounded-surface border border-border">
          {report.salesByTender.map((row) => (
            <li
              key={row.kind}
              className="flex items-center justify-between gap-3 px-3 py-2 text-sm"
            >
              <span className="text-muted">{row.kind.replaceAll('_', ' ')}</span>
              <span className="tabular-nums text-text">
                {formatMoney(row.amountMinor, currency, exponent)} · {row.count} sale(s)
              </span>
            </li>
          ))}
        </ul>
      </div>

      <div>
        <h3 className="text-sm font-semibold text-text">Cash movements</h3>
        {report.movements.length === 0 ? (
          <p className="mt-2 text-sm text-muted">No paid-in or paid-out was recorded.</p>
        ) : (
          <ul className="mt-2 divide-y divide-border rounded-surface border border-border">
            {report.movements.map((movement) => (
              <li
                key={movement.id}
                className="flex flex-wrap items-center justify-between gap-2 px-3 py-2 text-sm"
              >
                <span className="text-muted">
                  {movement.kind.replaceAll('_', ' ')} · {movement.reason}
                </span>
                <span className="tabular-nums text-text">
                  {formatMoney(movement.amountMinor, currency, exponent)} ·{' '}
                  {formatDateTimeInZone(movement.createdAt, timezone)}
                </span>
              </li>
            ))}
          </ul>
        )}
      </div>
    </div>
  );
}
