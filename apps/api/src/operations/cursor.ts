import { apiError } from '../common/api-error';

const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

export interface Cursor {
  at: Date;
  id: string;
}

export function encodeCursor(at: Date, id: string): string {
  return Buffer.from(JSON.stringify({ at: at.toISOString(), id }), 'utf8').toString('base64url');
}

export function decodeCursor(raw: string | undefined): Cursor | undefined {
  if (!raw) {
    return undefined;
  }

  try {
    const parsed = JSON.parse(Buffer.from(raw, 'base64url').toString('utf8')) as {
      at?: unknown;
      id?: unknown;
    };

    if (typeof parsed.at !== 'string' || typeof parsed.id !== 'string') {
      throw new Error('shape');
    }

    const at = new Date(parsed.at);
    if (Number.isNaN(at.getTime()) || !UUID_PATTERN.test(parsed.id)) {
      throw new Error('value');
    }

    return { at, id: parsed.id };
  } catch {
    throw apiError(400, 'INVALID_CURSOR', 'Cursor is not valid');
  }
}
