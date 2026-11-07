'use client';

import type { ApiSchemas } from '@modern-pos/api-client';
import { createContext, useCallback, useContext, useEffect, useRef, useState } from 'react';
import { api, readCsrfToken, setAccessToken, setUnauthorizedHandler } from './api';

type AuthUser = ApiSchemas['User'];
type AuthStatus = 'loading' | 'authenticated' | 'unauthenticated';

interface AuthContextValue {
  status: AuthStatus;
  user: AuthUser | null;
  signIn: (email: string, password: string) => Promise<void>;
  signOut: () => Promise<void>;
}

const AuthContext = createContext<AuthContextValue | null>(null);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [status, setStatus] = useState<AuthStatus>('loading');
  const [user, setUser] = useState<AuthUser | null>(null);
  const [expiresAt, setExpiresAt] = useState<number | null>(null);
  const refreshInFlight = useRef<Promise<string | null> | null>(null);

  const clearSession = useCallback(() => {
    setAccessToken(null);
    setUser(null);
    setStatus('unauthenticated');
    setExpiresAt(null);
  }, []);

  const applySession = useCallback((session: ApiSchemas['WebSession']) => {
    setAccessToken(session.accessToken);
    setUser(session.user);
    setStatus('authenticated');
    setExpiresAt(Date.now() + session.expiresInSeconds * 1000);
  }, []);

  const refresh = useCallback(async (): Promise<string | null> => {
    if (refreshInFlight.current) {
      return refreshInFlight.current;
    }

    const csrfToken = readCsrfToken();
    if (!csrfToken) {
      clearSession();
      return null;
    }

    const pending = (async () => {
      try {
        const session = await api.refreshWeb(csrfToken);
        applySession(session);
        return session.accessToken;
      } catch {
        clearSession();
        return null;
      } finally {
        refreshInFlight.current = null;
      }
    })();

    refreshInFlight.current = pending;
    return pending;
  }, [applySession, clearSession]);

  useEffect(() => {
    setUnauthorizedHandler(clearSession);
    return () => setUnauthorizedHandler(null);
  }, [clearSession]);

  useEffect(() => {
    void refresh();
  }, [refresh]);

  useEffect(() => {
    if (status !== 'authenticated' || expiresAt === null) {
      return;
    }

    const delay = Math.max(5_000, expiresAt - Date.now() - 60_000);
    const timer = setTimeout(() => {
      void refresh();
    }, delay);

    return () => clearTimeout(timer);
  }, [expiresAt, refresh, status]);

  const signIn = useCallback(
    async (email: string, password: string) => {
      const session = await api.signInWeb(email, password);
      applySession(session);
    },
    [applySession],
  );

  const signOut = useCallback(async () => {
    try {
      await api.signOut();
    } catch {
      // If the access token already expired, rotate first so the HttpOnly
      // refresh cookie cannot silently restore the session after sign-out.
      try {
        const csrfToken = readCsrfToken();
        if (csrfToken) {
          const session = await api.refreshWeb(csrfToken);
          setAccessToken(session.accessToken);
          await api.signOut();
        }
      } catch {
        // Local sign-out still completes when the server session is unusable.
      }
    } finally {
      clearSession();
    }
  }, [clearSession]);

  return (
    <AuthContext.Provider value={{ status, user, signIn, signOut }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth(): AuthContextValue {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used inside AuthProvider');
  }
  return context;
}
