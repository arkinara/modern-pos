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
}

export interface ApiClient {
  getHealth(): Promise<HealthStatus>;
  getOutlet(outletId: string): Promise<ApiSchemas['Outlet']>;
}

export function createApiClient({
  baseUrl,
  fetchImpl = globalThis.fetch,
}: ApiClientOptions): ApiClient {
  const root = baseUrl.replace(/\/$/, '');

  async function request<T>(path: string, init?: RequestInit): Promise<T> {
    const response = await fetchImpl(`${root}${path}`, {
      ...init,
      headers: {
        Accept: 'application/json',
        ...init?.headers,
      },
    });

    if (!response.ok) {
      const body = await response.text();
      throw new ApiError(response.status, body);
    }

    return (await response.json()) as T;
  }

  return {
    getHealth: () => request<HealthStatus>('/health'),
    getOutlet: (outletId) =>
      request<ApiSchemas['Outlet']>(`/v1/outlets/${encodeURIComponent(outletId)}`),
  };
}
