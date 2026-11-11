import 'package:flutter_test/flutter_test.dart';
import 'package:modern_pos_mobile/features/offline/offline_crypto.dart';

import 'support/offline_fakes.dart';

void main() {
  const marker = 'SUPER_SECRET_PLAINTEXT_MARKER_12345';

  test(
    'AES-GCM round-trips an offline sale payload without plaintext',
    () async {
      final secrets = InMemoryOfflineSecretStore();
      final cipher = OfflineCipher(secrets);
      final value = <String, dynamic>{
        'reference': marker,
        'amountMinor': 50000,
        'lines': [
          {'variantId': 'variant-1', 'quantity': 2},
        ],
      };

      final envelope = await cipher.encryptJson(value);

      expect(secrets.key, isNotNull);
      expect(envelope.ciphertext, isNot(contains(marker)));
      expect(envelope.nonce, isNot(contains(marker)));
      expect(envelope.mac, isNot(contains(marker)));
      expect(envelope.plaintextSha256, isNot(contains(secrets.key!)));
      expect(await cipher.decryptJson(envelope), value);
    },
  );

  test('tampered ciphertext or MAC fails loud', () async {
    final secrets = InMemoryOfflineSecretStore();
    final cipher = OfflineCipher(secrets);
    final envelope = await cipher.encryptJson({'reference': marker});

    final tamperedCipher = OfflineCipherEnvelope(
      ciphertext: _flipBase64(envelope.ciphertext),
      nonce: envelope.nonce,
      mac: envelope.mac,
      keyVersion: envelope.keyVersion,
      plaintextSha256: envelope.plaintextSha256,
    );
    await expectLater(
      () => cipher.decryptJson(tamperedCipher),
      throwsA(isA<OfflineDecryptionException>()),
    );

    final tamperedMac = OfflineCipherEnvelope(
      ciphertext: envelope.ciphertext,
      nonce: envelope.nonce,
      mac: _flipBase64(envelope.mac),
      keyVersion: envelope.keyVersion,
      plaintextSha256: envelope.plaintextSha256,
    );
    await expectLater(
      () => cipher.decryptJson(tamperedMac),
      throwsA(isA<OfflineDecryptionException>()),
    );
  });

  test('missing key never falls back to plaintext', () async {
    final secrets = InMemoryOfflineSecretStore();
    final writer = OfflineCipher(secrets);
    final envelope = await writer.encryptJson({'reference': marker});
    final reader = OfflineCipher(InMemoryOfflineSecretStore());

    await expectLater(
      () => reader.decryptJson(envelope),
      throwsA(isA<OfflineKeyMissingException>()),
    );
  });

  test('wrong key is an authentication failure, not a silent decode', () async {
    final writer = OfflineCipher(InMemoryOfflineSecretStore());
    final envelope = await writer.encryptJson({'reference': marker});
    final otherSecrets = InMemoryOfflineSecretStore();
    final other = OfflineCipher(otherSecrets);
    // Force a different key without ever exposing it in the envelope.
    await other.encryptJson({'unrelated': true});

    await expectLater(
      () => other.decryptJson(envelope),
      throwsA(isA<OfflineDecryptionException>()),
    );
  });
}

String _flipBase64(String value) {
  final chars = value.split('');
  final index = chars.length ~/ 2;
  chars[index] = chars[index] == 'A' ? 'B' : 'A';
  return chars.join();
}
