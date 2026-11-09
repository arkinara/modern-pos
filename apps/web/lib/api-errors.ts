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

export function describeCatalogError(error: unknown, fallback: string): string {
  if (!(error instanceof ApiError)) {
    return fallback;
  }

  if (error.status === 401) {
    return 'Your session expired. Sign in again.';
  }

  if (error.status === 403) {
    return 'Only an owner can change the menu.';
  }

  if (error.status === 404) {
    return 'That catalog record could not be found for this outlet. Reload and try again.';
  }

  if (error.status === 409) {
    return 'Another change saved first. Reload the latest menu, then apply your edits again.';
  }

  if (error.status === 400 || error.status === 422) {
    return 'The server rejected these catalog values. Review the fields and try again.';
  }

  return `${fallback} (HTTP ${error.status})`;
}

export function isVersionConflict(error: unknown): boolean {
  return error instanceof ApiError && error.status === 409;
}

export function apiErrorCode(error: unknown): string | null {
  if (!(error instanceof ApiError)) {
    return null;
  }

  const body = error.body;
  if (typeof body === 'object' && body !== null && 'code' in body) {
    const code = (body as { code: unknown }).code;
    return typeof code === 'string' ? code : null;
  }

  return null;
}

export function describeStockError(error: unknown, fallback: string): string {
  if (!(error instanceof ApiError)) {
    return fallback;
  }

  const code = apiErrorCode(error);

  if (error.status === 401) {
    return 'Your session expired. Sign in again.';
  }

  if (error.status === 403) {
    return 'Only an owner can change stock records.';
  }

  if (error.status === 404) {
    return 'That stock item could not be found for this outlet. Reload and try again.';
  }

  if (error.status === 409) {
    if (code === 'OPENING_ALREADY_RECORDED') {
      return 'An opening balance already exists for this item. Record a receipt or adjustment instead.';
    }

    if (code === 'IDEMPOTENCY_IN_PROGRESS') {
      return 'That stock request is still being processed. Retry in a moment.';
    }

    if (code === 'IDEMPOTENCY_CONFLICT') {
      return 'This retry reused an idempotency key with different values. Reload and submit again.';
    }

    return 'Another change saved first. Reload the stock item and reapply your change.';
  }

  if (error.status === 422) {
    return 'That change would make the stock balance negative. Reduce the quantity and try again.';
  }

  if (error.status === 400) {
    return 'The server rejected these stock values. Check the quantity precision, unit and reason.';
  }

  return `${fallback} (HTTP ${error.status})`;
}

export function isStockConflict(error: unknown): boolean {
  return error instanceof ApiError && (error.status === 409 || error.status === 422);
}

export function describeReportError(error: unknown, fallback: string): string {
  if (!(error instanceof ApiError)) {
    return fallback;
  }

  if (error.status === 401) {
    return 'Your session expired. Sign in again.';
  }

  if (error.status === 403) {
    return 'Only an owner can read sales reports for this outlet.';
  }

  if (error.status === 404) {
    return 'That outlet could not be found for your account.';
  }

  if (error.status === 400 || error.status === 422) {
    return 'The server rejected that date range. Use valid dates within 366 days.';
  }

  return `${fallback} (HTTP ${error.status})`;
}
