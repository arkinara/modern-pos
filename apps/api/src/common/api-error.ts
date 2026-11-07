import { HttpException } from '@nestjs/common';

export interface ApiErrorPayload {
  code: string;
  message: string;
  retryable?: boolean;
  details?: Record<string, unknown>;
}

export function apiError(
  status: number,
  code: string,
  message: string,
  options: { retryable?: boolean; details?: Record<string, unknown> } = {},
): HttpException {
  return new HttpException(
    {
      code,
      message,
      retryable: options.retryable ?? false,
      ...(options.details ? { details: options.details } : {}),
    },
    status,
  );
}
