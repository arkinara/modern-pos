import type { components, paths } from './schema';

export type { components, paths };
export type ApiPaths = paths;
export type ApiSchemas = components['schemas'];

export interface HealthStatus {
  status: 'ok';
  service: 'modern-pos-api';
  version: string;
  database: 'up';
}

export class ApiError extends Error {
  constructor(
    readonly status: number,
    readonly body: unknown,
    message = `API request failed with HTTP ${status}`,
  ) {
    super(message);
    this.name = 'ApiError';
  }
}

export interface ApiClientOptions {
  baseUrl: string;
  fetchImpl?: typeof fetch;
  getAccessToken?: () => string | null;
  credentials?: RequestCredentials;
  onUnauthorized?: () => void;
}

export interface ApiClient {
  getHealth(): Promise<HealthStatus>;
  signInWeb(email: string, password: string): Promise<ApiSchemas['WebSession']>;
  refreshWeb(csrfToken: string): Promise<ApiSchemas['WebSession']>;
  signOut(): Promise<void>;
  getMe(): Promise<ApiSchemas['User']>;
  getOutlet(outletId: string): Promise<ApiSchemas['Outlet']>;
  getSettings(outletId: string): Promise<ApiSchemas['Settings']>;
  updateSettings(
    outletId: string,
    settings: ApiSchemas['SettingsUpdate'],
  ): Promise<ApiSchemas['Settings']>;
}

function parseErrorBody(text: string): unknown {
  if (text.length === 0) {
    return null;
  }

  try {
    return JSON.parse(text) as unknown;
  } catch {
    return text;
  }
}

export function createApiClient({
  baseUrl,
  fetchImpl = globalThis.fetch,
  getAccessToken,
  credentials,
  onUnauthorized,
}: ApiClientOptions): ApiClient {
  const root = baseUrl.replace(/\/$/, '');

  async function request<T>(path: string, init?: RequestInit): Promise<T> {
    const accessToken = getAccessToken?.() ?? null;
    const response = await fetchImpl(`${root}${path}`, {
      ...init,
      credentials,
      headers: {
        Accept: 'application/json',
        ...(init?.body ? { 'Content-Type': 'application/json' } : {}),
        ...(accessToken ? { Authorization: `Bearer ${accessToken}` } : {}),
        ...init?.headers,
      },
    });

    if (response.status === 401) {
      onUnauthorized?.();
    }

    if (!response.ok) {
      const body = parseErrorBody(await response.text());
      throw new ApiError(response.status, body);
    }

    if (response.status === 204) {
      return undefined as T;
    }

    return (await response.json()) as T;
  }

  return {
    getHealth: () => request<HealthStatus>('/health'),
    signInWeb: (email, password) =>
      request<ApiSchemas['WebSession']>('/v1/auth/web/login', {
        method: 'POST',
        body: JSON.stringify({ email, password }),
      }),
    refreshWeb: (csrfToken) =>
      request<ApiSchemas['WebSession']>('/v1/auth/web/refresh', {
        method: 'POST',
        headers: { 'X-CSRF-Token': csrfToken },
      }),
    signOut: () => request<void>('/v1/auth/logout', { method: 'POST' }),
    getMe: () => request<ApiSchemas['User']>('/v1/auth/me'),
    getOutlet: (outletId) =>
      request<ApiSchemas['Outlet']>(`/v1/outlets/${encodeURIComponent(outletId)}`),
    getSettings: (outletId) =>
      request<ApiSchemas['Settings']>(`/v1/outlets/${encodeURIComponent(outletId)}/settings`),
    updateSettings: (outletId, settings) =>
      request<ApiSchemas['Settings']>(`/v1/outlets/${encodeURIComponent(outletId)}/settings`, {
        method: 'PATCH',
        body: JSON.stringify(settings),
      }),
  };
}
