import type { AuthConfig } from './auth.config';

export function testAuthConfig(overrides: Partial<AuthConfig> = {}): AuthConfig {
  return {
    accessTokenTtlSeconds: 600,
    refreshTokenTtlSeconds: 7 * 24 * 60 * 60,
    jwtSecret: 'test-secret',
    jwtIssuer: 'modern-pos-test',
    refreshCookieName: 'pos_refresh',
    csrfCookieName: 'pos_csrf',
    cookieSecure: false,
    cookieDomain: undefined,
    signInMaxAttempts: 5,
    signInWindowSeconds: 900,
    ...overrides,
  };
}
