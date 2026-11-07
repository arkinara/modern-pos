import assert from 'node:assert/strict';
import { test } from 'node:test';
import { PasswordService } from './password.service';

test('passwords use Argon2id and verify only the original value', async () => {
  const passwords = new PasswordService();
  await passwords.onModuleInit();

  const hash = await passwords.hash('correct horse battery staple');

  assert.match(hash, /^\$argon2id\$/);
  assert.equal(await passwords.verify(hash, 'correct horse battery staple'), true);
  assert.equal(await passwords.verify(hash, 'wrong password'), false);
});

test('malformed and empty password hashes fail closed', async () => {
  const passwords = new PasswordService();

  assert.equal(await passwords.verify('', 'anything'), false);
  assert.equal(await passwords.verify('not-an-argon2-hash', 'anything'), false);
  await assert.doesNotReject(() => passwords.verifyDummy('anything'));
});
