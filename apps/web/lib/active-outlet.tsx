'use client';

import type { ApiSchemas } from '@modern-pos/api-client';
import { useQuery } from '@tanstack/react-query';
import { createContext, useContext, useEffect, useMemo, useState } from 'react';
import { api } from './api';
import { useAuth } from './auth';

const STORAGE_KEY = 'modern-pos.active-outlet';

interface ActiveOutletValue {
  outletId: string | null;
  outlets: ApiSchemas['Outlet'][];
  outletsLoading: boolean;
  outletsError: boolean;
  setOutletId: (outletId: string) => void;
}

const ActiveOutletContext = createContext<ActiveOutletValue | null>(null);

export function ActiveOutletProvider({ children }: { children: React.ReactNode }) {
  const { user } = useAuth();
  const [selected, setSelected] = useState<string | null>(null);
  const outletIds = useMemo(() => user?.outletIds ?? [], [user?.outletIds]);

  useEffect(() => {
    if (outletIds.length === 0) {
      setSelected(null);
      return;
    }

    const stored = window.localStorage.getItem(STORAGE_KEY);
    setSelected((current) => {
      if (current && outletIds.includes(current)) {
        return current;
      }
      return stored && outletIds.includes(stored) ? stored : outletIds[0]!;
    });
  }, [outletIds]);

  const outletsQuery = useQuery({
    queryKey: ['outlets'],
    queryFn: () => api.listOutlets(),
    enabled: Boolean(user),
  });

  const outlets = useMemo(() => {
    const rows = outletsQuery.data?.items ?? [];
    return rows.filter((outlet) => outletIds.includes(outlet.id));
  }, [outletIds, outletsQuery.data?.items]);

  const outletId =
    selected !== null && outletIds.includes(selected) ? selected : (outletIds[0] ?? null);

  function selectOutlet(next: string): void {
    if (!outletIds.includes(next)) {
      return;
    }
    window.localStorage.setItem(STORAGE_KEY, next);
    setSelected(next);
  }

  return (
    <ActiveOutletContext.Provider
      value={{
        outletId,
        outlets,
        outletsLoading: outletsQuery.isPending,
        outletsError: outletsQuery.isError,
        setOutletId: selectOutlet,
      }}
    >
      {children}
    </ActiveOutletContext.Provider>
  );
}

export function useActiveOutlet(): ActiveOutletValue {
  const context = useContext(ActiveOutletContext);
  if (!context) {
    throw new Error('useActiveOutlet must be used inside ActiveOutletProvider');
  }
  return context;
}

export function useActiveOutletId(): string | null {
  return useActiveOutlet().outletId;
}
