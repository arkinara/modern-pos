import { createApiClient } from '@modern-pos/api-client';

export const apiBaseUrl = process.env.NEXT_PUBLIC_API_URL ?? 'http://localhost:4000';

let accessToken: string | null = null;
let unauthorizedHandler: (() => void) | null = null;

export function setAccessToken(token: string | null): void {
  accessToken = token;
}

export function setUnauthorizedHandler(handler: (() => void) | null): void {
  unauthorizedHandler = handler;
}

export const api = createApiClient({
  baseUrl: apiBaseUrl,
  credentials: 'include',
  getAccessToken: () => accessToken,
  onUnauthorized: () => unauthorizedHandler?.(),
});

/** Reads the double-submit CSRF cookie set by the web refresh flow. */
export function readCsrfToken(): string | null {
  if (typeof document === 'undefined') {
    return null;
  }

  const prefix = 'pos_csrf=';
  const match = document.cookie
    .split(';')
    .map((part) => part.trim())
    .find((part) => part.startsWith(prefix));

  if (!match) {
    return null;
  }

  return decodeURIComponent(match.slice(prefix.length));
}
