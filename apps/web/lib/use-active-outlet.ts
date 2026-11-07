'use client';

import { useAuth } from './auth';

/**
 * Single-outlet MVP: use the first outlet returned by the server session.
 * The settings screen and API keep the outlet ID explicit so a later outlet
 * switcher can replace this hook without changing the screens.
 */
export function useActiveOutletId(): string | null {
  const { user } = useAuth();
  return user?.outletIds[0] ?? null;
}
