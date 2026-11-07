import { randomUUID } from 'node:crypto';
import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import type { Response } from 'express';
import type { RequestWithId } from './request-id.middleware';

interface ErrorBody {
  code: string;
  message: string;
  retryable: boolean;
  details?: unknown;
}

const STATUS_CODES: Record<number, string> = {
  [HttpStatus.BAD_REQUEST]: 'BAD_REQUEST',
  [HttpStatus.UNAUTHORIZED]: 'UNAUTHENTICATED',
  [HttpStatus.FORBIDDEN]: 'FORBIDDEN',
  [HttpStatus.NOT_FOUND]: 'NOT_FOUND',
  [HttpStatus.CONFLICT]: 'CONFLICT',
  [HttpStatus.UNPROCESSABLE_ENTITY]: 'UNPROCESSABLE_ENTITY',
  [HttpStatus.TOO_MANY_REQUESTS]: 'RATE_LIMITED',
  [HttpStatus.SERVICE_UNAVAILABLE]: 'SERVICE_UNAVAILABLE',
};

function fromHttpException(exception: HttpException): {
  status: number;
  body: ErrorBody;
} {
  const status = exception.getStatus();
  const response = exception.getResponse();

  if (typeof response === 'object' && response !== null) {
    const record = response as Record<string, unknown>;
    if (typeof record.code === 'string') {
      return {
        status,
        body: {
          code: record.code,
          message: typeof record.message === 'string' ? record.message : exception.message,
          retryable: record.retryable === true,
          ...(record.details !== undefined ? { details: record.details } : {}),
        },
      };
    }

    const validationMessages = Array.isArray(record.message)
      ? record.message.filter((item): item is string => typeof item === 'string')
      : [];

    return {
      status,
      body: {
        code:
          status === HttpStatus.BAD_REQUEST && validationMessages.length > 0
            ? 'VALIDATION_ERROR'
            : (STATUS_CODES[status] ?? 'HTTP_ERROR'),
        message:
          validationMessages.length > 0
            ? 'Request validation failed'
            : typeof record.message === 'string'
              ? record.message
              : exception.message,
        retryable: status === HttpStatus.SERVICE_UNAVAILABLE,
        ...(validationMessages.length > 0 ? { details: { issues: validationMessages } } : {}),
      },
    };
  }

  return {
    status,
    body: {
      code: STATUS_CODES[status] ?? 'HTTP_ERROR',
      message: typeof response === 'string' ? response : exception.message,
      retryable: status === HttpStatus.SERVICE_UNAVAILABLE,
    },
  };
}

@Catch()
export class ApiExceptionFilter implements ExceptionFilter {
  private readonly logger = new Logger(ApiExceptionFilter.name);

  catch(exception: unknown, host: ArgumentsHost): void {
    const context = host.switchToHttp();
    const response = context.getResponse<Response>();
    const request = context.getRequest<RequestWithId>();
    const requestId = request.requestId ?? randomUUID();

    let status = HttpStatus.INTERNAL_SERVER_ERROR;
    let body: ErrorBody = {
      code: 'INTERNAL_ERROR',
      message: 'An unexpected error occurred',
      retryable: false,
    };

    if (exception instanceof HttpException) {
      const mapped = fromHttpException(exception);
      status = mapped.status;
      body = mapped.body;
    } else {
      this.logger.error(
        `Unhandled error for request ${requestId}`,
        exception instanceof Error ? exception.stack : String(exception),
      );
    }

    const retryAfterSeconds =
      body.details && typeof body.details === 'object'
        ? (body.details as { retryAfterSeconds?: unknown }).retryAfterSeconds
        : undefined;

    if (typeof retryAfterSeconds === 'number' && retryAfterSeconds > 0) {
      response.setHeader('Retry-After', Math.ceil(retryAfterSeconds).toString());
    }

    response.status(status).json({
      code: body.code,
      message: body.message,
      requestId,
      retryable: body.retryable,
      ...(body.details !== undefined ? { details: body.details } : {}),
    });
  }
}
