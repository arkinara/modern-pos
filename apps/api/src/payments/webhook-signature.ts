import { createHmac, timingSafeEqual } from 'node:crypto';

export const PAYMENT_SIGNATURE_HEADER = 'x-payment-signature';
export const PAYMENT_EVENT_ID_HEADER = 'x-payment-event-id';

export interface SignatureVerification {
  ok: boolean;
  timestamp: number | null;
  reason: 'VALID' | 'MISSING' | 'MALFORMED' | 'STALE' | 'MISMATCH';
}

/** Stripe-style signed payload: HMAC-SHA256(`${timestamp}.${rawBody}`). */
export function signWebhookPayload(secret: string, timestamp: number, rawBody: string): string {
  return createHmac('sha256', secret).update(`${timestamp}.${rawBody}`).digest('hex');
}

function parseSignatureHeader(header: string | undefined): {
  timestamp: string;
  signatures: string[];
} {
  if (!header) {
    return { timestamp: '', signatures: [] };
  }

  const parts = header.split(',').map((part) => part.trim());
  const timestamp = parts.find((part) => part.startsWith('t='))?.slice(2) ?? '';
  const signatures = parts
    .filter((part) => part.startsWith('v1='))
    .map((part) => part.slice(3).trim())
    .filter(Boolean);

  return { timestamp, signatures };
}

/**
 * Constant-time signature check with an explicit timestamp/replay window.
 * A malformed or stale header is rejected before any state transition.
 */
export function verifyWebhookSignature(input: {
  secret: string;
  header: string | undefined;
  rawBody: string;
  now?: Date;
  windowSeconds: number;
}): SignatureVerification {
  const { timestamp, signatures } = parseSignatureHeader(input.header);

  if (!input.header) {
    return { ok: false, timestamp: null, reason: 'MISSING' };
  }

  if (!/^\d{1,12}$/.test(timestamp) || signatures.length === 0) {
    return { ok: false, timestamp: null, reason: 'MALFORMED' };
  }

  const parsedTimestamp = Number(timestamp);
  const nowSeconds = Math.floor((input.now ?? new Date()).getTime() / 1000);

  if (Math.abs(nowSeconds - parsedTimestamp) > input.windowSeconds) {
    return { ok: false, timestamp: parsedTimestamp, reason: 'STALE' };
  }

  const expected = Buffer.from(
    signWebhookPayload(input.secret, parsedTimestamp, input.rawBody),
    'utf8',
  );
  const valid = signatures.some((signature) => {
    const candidate = Buffer.from(signature, 'utf8');
    return candidate.length === expected.length && timingSafeEqual(candidate, expected);
  });

  return {
    ok: valid,
    timestamp: parsedTimestamp,
    reason: valid ? 'VALID' : 'MISMATCH',
  };
}
