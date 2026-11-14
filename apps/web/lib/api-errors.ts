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

export function describeStockHistoryError(error: unknown, fallback: string): string {
  if (!(error instanceof ApiError)) {
    return fallback;
  }

  if (error.status === 401) {
    return 'Your session expired. Sign in again.';
  }

  if (error.status === 403) {
    return 'Only an owner can view stock movement history.';
  }

  if (error.status === 404) {
    return 'That stock item could not be found for this outlet. Reload and try again.';
  }

  if (error.status === 400 || error.status === 422) {
    return 'The server rejected this movement-history request. Reload and try again.';
  }

  return `${fallback} (HTTP ${error.status})`;
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

export function describeReversalError(error: unknown, fallback: string): string {
  if (!(error instanceof ApiError)) {
    return fallback;
  }

  const code = apiErrorCode(error);

  if (error.status === 401) {
    return 'Your session expired. Sign in again.';
  }

  if (error.status === 403) {
    return 'Only an owner can reverse a sale.';
  }

  if (error.status === 404) {
    return 'That sale could not be found for this outlet. Reload and try again.';
  }

  if (error.status === 409) {
    if (code === 'SALE_ALREADY_REVERSED') {
      return 'This sale was already reversed. Reload the receipt to see the recorded reversal.';
    }

    if (code === 'IDEMPOTENCY_CONFLICT') {
      return 'This retry reused a key with different values. Change the form, then submit again.';
    }

    if (code === 'IDEMPOTENCY_IN_PROGRESS') {
      return 'This reversal is still being processed. Retry the same request in a moment.';
    }

    return 'Another change saved first. Reload the receipt and try again.';
  }

  if (error.status === 422) {
    if (code === 'RESTOCK_ITEM_NOT_SOLD') {
      return 'Only stock items consumed by this sale can be restocked.';
    }

    if (code === 'RESTOCK_EXCEEDS_SOLD') {
      return 'A restock quantity is higher than the amount this sale consumed.';
    }

    if (code === 'INVALID_RESTOCK_QUANTITY') {
      return 'A restock quantity is invalid for that stock item.';
    }

    return 'The server rejected these reversal values. Review the reason and quantities.';
  }

  if (error.status === 400) {
    return 'The server rejected this reversal. Use a reason of 3 to 500 characters and valid quantities.';
  }

  return `${fallback} (HTTP ${error.status})`;
}

export function describeOperationError(error: unknown, fallback: string): string {
  if (!(error instanceof ApiError)) {
    return fallback;
  }

  const code = apiErrorCode(error);

  if (error.status === 401) {
    return 'Your session expired. Sign in again.';
  }

  if (error.status === 403) {
    if (code === 'APPROVAL_REQUIRED') {
      return 'This cash payout is above your approval limit. An owner must record it.';
    }
    return 'This account is not allowed to perform that operation.';
  }

  if (error.status === 404) {
    return 'That record could not be found for this outlet. Reload and try again.';
  }

  if (error.status === 409) {
    if (code === 'SHIFT_ALREADY_OPEN') {
      return 'You already have an open shift in this outlet. Close it before opening another.';
    }
    if (code === 'SHIFT_ALREADY_CLOSED' || code === 'SHIFT_CLOSE_CONFLICT') {
      return 'This shift was already closed. Reload the list to see the final count.';
    }
    if (code === 'SHIFT_NOT_YOURS') {
      return 'Only the staff member who opened this shift can close it.';
    }
    if (code === 'ATTENDANCE_ALREADY_OPEN') {
      return 'You are already clocked in. Clock out before starting another record.';
    }
    if (code === 'ATTENDANCE_NOT_OPEN') {
      return 'There is no open attendance record to close.';
    }
    return 'Another change saved first. Reload and try again.';
  }

  if (error.status === 400 || error.status === 422) {
    return 'The server rejected these values. Check the amount, count and reason.';
  }

  return `${fallback} (HTTP ${error.status})`;
}
