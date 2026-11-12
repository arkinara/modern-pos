'use client';

import { useQuery } from '@tanstack/react-query';
import { RefreshCw } from 'lucide-react';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { api } from '@/lib/api';
import { describeOperationError } from '@/lib/api-errors';
import { formatMoney } from '@/lib/reporting';
import { useActiveOutletId } from '@/lib/use-active-outlet';

export function PermissionsScreen() {
  const outletId = useActiveOutletId();

  const settingsQuery = useQuery({
    queryKey: ['settings', outletId],
    queryFn: () => api.getSettings(outletId as string),
    enabled: Boolean(outletId),
  });
  const currency = settingsQuery.data?.currency ?? 'IDR';
  const exponent = settingsQuery.data?.currencyExponent ?? 0;

  const matrixQuery = useQuery({
    queryKey: ['permission-matrix', outletId],
    queryFn: () => api.getPermissionMatrix(outletId as string),
    enabled: Boolean(outletId),
  });
  const rulesQuery = useQuery({
    queryKey: ['approval-rules', outletId],
    queryFn: () => api.listApprovalRules(outletId as string),
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

  return (
    <div className="flex w-full flex-col gap-6">
      <header>
        <h1 className="text-3xl font-semibold tracking-tight text-text">Permissions</h1>
        <p className="mt-2 max-w-3xl text-sm text-muted">
          The server permission matrix is the single source used by route guards. Approval limits
          compose with the existing approval-rule table instead of a second approval system.
        </p>
      </header>

      <Card>
        <CardHeader>
          <CardTitle>Role matrix</CardTitle>
          <CardDescription>Operations each role may perform on this outlet.</CardDescription>
        </CardHeader>
        <CardContent>
          {matrixQuery.isLoading ? (
            <div className="flex flex-col gap-2" role="status" aria-busy="true">
              <div className="h-16 animate-pulse rounded-control bg-surface-muted" />
              <div className="h-16 animate-pulse rounded-control bg-surface-muted" />
            </div>
          ) : matrixQuery.isError ? (
            <div className="flex flex-col items-start gap-3" role="alert">
              <p className="text-sm text-danger">
                {describeOperationError(matrixQuery.error, 'Could not load the permission matrix')}
              </p>
              <Button variant="outline" onClick={() => void matrixQuery.refetch()}>
                <RefreshCw aria-hidden="true" className="size-4" />
                Try again
              </Button>
            </div>
          ) : matrixQuery.data ? (
            <div className="overflow-x-auto">
              <table className="w-full min-w-[560px] text-left text-sm">
                <thead>
                  <tr className="border-b border-border text-xs uppercase tracking-[0.12em] text-muted">
                    <th className="py-2 pr-3 font-medium">Operation</th>
                    {matrixQuery.data.roles.map((role) => (
                      <th key={role.role} className="py-2 px-3 font-medium">
                        {role.role}
                      </th>
                    ))}
                  </tr>
                </thead>
                <tbody className="divide-y divide-border">
                  {matrixQuery.data.operations.map((operation) => (
                    <tr key={operation.key}>
                      <td className="py-2 pr-3">
                        <p className="font-medium text-text">{operation.label}</p>
                        <p className="text-xs text-muted">{operation.description}</p>
                      </td>
                      {matrixQuery.data.roles.map((role) => (
                        <td key={`${operation.key}-${role.role}`} className="py-2 px-3">
                          {role.permissions.includes(operation.key) ? (
                            <Badge tone="success">Allowed</Badge>
                          ) : (
                            <Badge tone="neutral">Denied</Badge>
                          )}
                        </td>
                      ))}
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          ) : null}
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Approval limits</CardTitle>
          <CardDescription>
            Amounts above an active threshold need an owner. Paid-out cash uses the CASH_OUT rule;
            discounts and refunds keep their existing rules.
          </CardDescription>
        </CardHeader>
        <CardContent>
          {rulesQuery.isLoading ? (
            <p className="text-sm text-muted" role="status">
              Loading approval limits…
            </p>
          ) : rulesQuery.isError ? (
            <div className="flex flex-col items-start gap-3" role="alert">
              <p className="text-sm text-danger">
                {describeOperationError(rulesQuery.error, 'Could not load approval limits')}
              </p>
              <Button variant="outline" onClick={() => void rulesQuery.refetch()}>
                <RefreshCw aria-hidden="true" className="size-4" />
                Try again
              </Button>
            </div>
          ) : (rulesQuery.data ?? []).length === 0 ? (
            <p className="text-sm text-muted">
              No approval rule is configured. Sensitive actions default to owner-only.
            </p>
          ) : (
            <ul className="divide-y divide-border rounded-surface border border-border">
              {(rulesQuery.data ?? []).map((rule) => (
                <li
                  key={rule.id}
                  className="flex flex-wrap items-center justify-between gap-2 px-3 py-3 text-sm"
                >
                  <span className="flex items-center gap-2">
                    <span className="font-medium text-text">{rule.action}</span>
                    <Badge tone={rule.active ? 'success' : 'neutral'}>
                      {rule.active ? 'Active' : 'Inactive'}
                    </Badge>
                  </span>
                  <span className="tabular-nums text-text">
                    {formatMoney(rule.thresholdMinor, currency, exponent)} and below
                  </span>
                </li>
              ))}
            </ul>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
