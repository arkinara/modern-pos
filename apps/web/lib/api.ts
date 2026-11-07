import { createApiClient } from '@modern-pos/api-client';

export const apiBaseUrl = process.env.NEXT_PUBLIC_API_URL ?? 'http://localhost:4000';

export const api = createApiClient({ baseUrl: apiBaseUrl });
