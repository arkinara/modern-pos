import assert from 'node:assert/strict';
import { test } from 'node:test';
import { signWebhookPayload, verifyWebhookSignature } from './webhook-signature';

const SECRET = 'unit-test-webhook-secret';
const BODY = JSON.stringify({ id: 'evt_1', type: 'payment.succeeded' });
const NOW = new Date('2026-11-12T12:00:00.000Z');
const TIMESTAMP = Math.floor(NOW.getTime() / 1000);

function header(timestamp: number, secret = SECRET): string {
  return `t=${timestamp},v1=${signWebhookPayload(secret, timestamp, BODY)}`;
}

test('a correctly signed fresh payload is accepted', () => {
  const result = verifyWebhookSignature({
    secret: SECRET,
    header: header(TIMESTAMP),
    rawBody: BODY,
    now: NOW,
    windowSeconds: 300,
  });

  assert.equal(result.ok, true);
  assert.equal(result.reason, 'VALID');
});

test('a wrong signature is rejected without throwing', () => {
  const result = verifyWebhookSignature({
    secret: SECRET,
    header: `t=${TIMESTAMP},v1=${'0'.repeat(64)}`,
    rawBody: BODY,
    now: NOW,
    windowSeconds: 300,
  });

  assert.equal(result.ok, false);
  assert.equal(result.reason, 'MISMATCH');
});

test('a replayed old timestamp is rejected even with a valid HMAC', () => {
  const old = TIMESTAMP - 301;
  const result = verifyWebhookSignature({
    secret: SECRET,
    header: header(old),
    rawBody: BODY,
    now: NOW,
    windowSeconds: 300,
  });

  assert.equal(result.ok, false);
  assert.equal(result.reason, 'STALE');
});

test('missing and malformed signature headers are rejected', () => {
  const missing = verifyWebhookSignature({
    secret: SECRET,
    header: undefined,
    rawBody: BODY,
    now: NOW,
    windowSeconds: 300,
  });
  const malformed = verifyWebhookSignature({
    secret: SECRET,
    header: 'v1=abc',
    rawBody: BODY,
    now: NOW,
    windowSeconds: 300,
  });

  assert.equal(missing.reason, 'MISSING');
  assert.equal(malformed.reason, 'MALFORMED');
});

test('the body is covered by the signature', () => {
  const result = verifyWebhookSignature({
    secret: SECRET,
    header: header(TIMESTAMP),
    rawBody: `${BODY} `,
    now: NOW,
    windowSeconds: 300,
  });

  assert.equal(result.ok, false);
});
