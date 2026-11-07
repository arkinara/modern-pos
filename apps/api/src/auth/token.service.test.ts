import assert from 'node:assert/strict';
import { test } from 'node:test';
import { TokenService } from './token.service';

test('opaque tokens are random and hashed deterministically', () => {
  const tokens = new TokenService();

  const first = tokens.createOpaqueToken();
  const second = tokens.createOpaqueToken();

  assert.notEqual(first, second);
  assert.ok(first.length >= 43);
  assert.match(tokens.hashToken(first), /^[a-f0-9]{64}$/);
  assert.equal(tokens.hashToken(first), tokens.hashToken(first));
  assert.notEqual(tokens.hashToken(first), tokens.hashToken(second));
});

test('session ids are UUID v4 values', () => {
  const tokens = new TokenService();
  assert.match(
    tokens.createId(),
    /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/,
  );
});
