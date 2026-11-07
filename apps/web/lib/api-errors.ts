import { ApiError } from '@modern-pos/api-client';

export function describeApiError(error: unknown, fallback: string): string {
  if (!(error instanceof ApiError)) {
    return fallback;
  }

  if (error.status === 401) {
    return 'Your session expired. Sign in again.';
  }

  if (error.status === 403) {
    return 'This account is not allowed to change outlet settings.';
  }

  if (error.status === 404) {
    return 'This outlet could not be found for your account.';
  }

  if (error.status === 409) {
    return 'Another change saved first. Reload the latest settings and apply your edits again.';
  }

  if (error.status === 400 || error.status === 422) {
    return 'The server rejected these settings. Review the highlighted fields and try again.';
  }

  return `${fallback} (HTTP ${error.status})`;
}

export function isVersionConflict(error: unknown): boolean {
  return error instanceof ApiError && error.status === 409;
}
