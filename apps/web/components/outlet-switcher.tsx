'use client';

import { Building2 } from 'lucide-react';
import { useActiveOutlet } from '@/lib/active-outlet';

const selectClass =
  'h-10 w-full rounded-control border border-control bg-surface px-2 text-sm text-text';

export function OutletSwitcher() {
  const { outletId, outlets, outletsLoading, outletsError, setOutletId } = useActiveOutlet();

  if (outletsLoading && !outletId) {
    return (
      <p className="text-xs text-ink-muted" role="status">
        Loading outlets
      </p>
    );
  }

  if (outletsError) {
    return (
      <p className="text-xs text-danger-soft" role="alert">
        Outlets unavailable
      </p>
    );
  }

  if (!outletId) {
    return <p className="text-xs text-ink-muted">No outlet assigned</p>;
  }

  return (
    <label className="flex flex-col gap-1 text-xs font-medium uppercase tracking-[0.14em] text-ink-muted">
      <span className="flex items-center gap-2">
        <Building2 aria-hidden="true" className="size-4" strokeWidth={1.75} />
        Outlet
      </span>
      <select
        className={selectClass}
        value={outletId}
        onChange={(event) => setOutletId(event.target.value)}
        aria-label="Active outlet"
      >
        {outlets.length === 0 ? <option value={outletId}>Loading outlet</option> : null}
        {outlets.map((outlet) => (
          <option key={outlet.id} value={outlet.id}>
            {outlet.name}
          </option>
        ))}
      </select>
    </label>
  );
}
