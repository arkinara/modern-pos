import { Inject, Injectable } from '@nestjs/common';
import { apiError } from '../common/api-error';
import { AUTH_CONFIG, type AuthConfig } from './auth.config';

interface AttemptWindow {
  count: number;
  resetAt: number;
}

const MAX_TRACKED_KEYS = 10_000;

/**
 * Bounded in-process sign-in limiter. It is intentionally dependency-free.
 * Limitations: state is per API process and resets on restart; a shared store
 * is required before running multiple API replicas in production.
 */
@Injectable()
export class SignInRateLimiter {
  private readonly attempts = new Map<string, AttemptWindow>();

  constructor(@Inject(AUTH_CONFIG) private readonly config: AuthConfig) {}

  assertAllowed(key: string): void {
    this.prune();
    const window = this.attempts.get(key);

    if (window && window.resetAt > Date.now() && window.count >= this.config.signInMaxAttempts) {
      const retryAfterSeconds = Math.max(1, Math.ceil((window.resetAt - Date.now()) / 1000));
      throw apiError(429, 'RATE_LIMITED', 'Too many sign-in attempts; try again later', {
        retryable: true,
        details: {
          retryAfterSeconds,
          limit: this.config.signInMaxAttempts,
          windowSeconds: this.config.signInWindowSeconds,
        },
      });
    }
  }

  recordFailure(key: string): void {
    const now = Date.now();
    const existing = this.attempts.get(key);

    if (!existing || existing.resetAt <= now) {
      this.ensureCapacity();
      this.attempts.set(key, {
        count: 1,
        resetAt: now + this.config.signInWindowSeconds * 1000,
      });
      return;
    }

    existing.count += 1;
  }

  reset(key: string): void {
    this.attempts.delete(key);
  }

  private ensureCapacity(): void {
    if (this.attempts.size < MAX_TRACKED_KEYS) {
      return;
    }

    this.prune();
    while (this.attempts.size >= MAX_TRACKED_KEYS) {
      const oldest = this.attempts.keys().next().value as string | undefined;
      if (oldest === undefined) {
        break;
      }
      this.attempts.delete(oldest);
    }
  }

  private prune(): void {
    const now = Date.now();
    for (const [key, window] of this.attempts) {
      if (window.resetAt <= now) {
        this.attempts.delete(key);
      }
    }
  }
}
