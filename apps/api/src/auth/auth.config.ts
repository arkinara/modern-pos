const DEFAULT_ACCESS_TOKEN_TTL_SECONDS = 600;
const DEFAULT_REFRESH_TOKEN_TTL_SECONDS = 7 * 24 * 60 * 60;
const DEFAULT_SIGN_IN_MAX_ATTEMPTS = 5;
const DEFAULT_SIGN_IN_WINDOW_SECONDS = 15 * 60;

function positiveInteger(value: string | undefined, fallback: number): number {
  if (value === undefined || value.trim() === '') {
    return fallback;
  }

  const parsed = Number(value);
  return Number.isSafeInteger(parsed) && parsed >= 0 ? parsed : fallback;
}

function booleanValue(value: string | undefined, fallback: boolean): boolean {
  if (value === undefined || value.trim() === '') {
    return fallback;
  }

  return value === '1' || value.toLowerCase() === 'true';
}

export interface AuthConfig {
  accessTokenTtlSeconds: number;
  refreshTokenTtlSeconds: number;
  jwtSecret: string;
  jwtIssuer: string;
  refreshCookieName: string;
  csrfCookieName: string;
  cookieSecure: boolean;
  cookieDomain: string | undefined;
  signInMaxAttempts: number;
  signInWindowSeconds: number;
}

export function loadAuthConfig(): AuthConfig {
  return {
    accessTokenTtlSeconds: positiveInteger(
      process.env.ACCESS_TOKEN_TTL_SECONDS,
      DEFAULT_ACCESS_TOKEN_TTL_SECONDS,
    ),
    refreshTokenTtlSeconds: positiveInteger(
      process.env.REFRESH_TOKEN_TTL_SECONDS,
      DEFAULT_REFRESH_TOKEN_TTL_SECONDS,
    ),
    jwtSecret: process.env.JWT_SECRET ?? 'modern-pos-local-development-secret',
    jwtIssuer: process.env.JWT_ISSUER ?? 'modern-pos-api',
    refreshCookieName: process.env.REFRESH_COOKIE_NAME ?? 'pos_refresh',
    csrfCookieName: process.env.CSRF_COOKIE_NAME ?? 'pos_csrf',
    cookieSecure: booleanValue(process.env.COOKIE_SECURE, false),
    cookieDomain: process.env.COOKIE_DOMAIN,
    signInMaxAttempts: positiveInteger(
      process.env.SIGN_IN_MAX_ATTEMPTS,
      DEFAULT_SIGN_IN_MAX_ATTEMPTS,
    ),
    signInWindowSeconds: positiveInteger(
      process.env.SIGN_IN_WINDOW_SECONDS,
      DEFAULT_SIGN_IN_WINDOW_SECONDS,
    ),
  };
}

export const AUTH_CONFIG = Symbol('AUTH_CONFIG');
