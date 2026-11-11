import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Durable secret storage for the offline-queue data key. The key never enters
/// SQLite or application logs; only the secure-storage adapter can read it.
abstract interface class OfflineSecretStore {
  Future<String?> readKey();

  Future<void> writeKey(String base64Key);
}

class SecureOfflineSecretStore implements OfflineSecretStore {
  SecureOfflineSecretStore(this._storage, {this.storageKey = _defaultKey});

  static const _defaultKey = 'pos_offline_queue_key_v1';

  final FlutterSecureStorage _storage;
  final String storageKey;

  @override
  Future<String?> readKey() => _storage.read(key: storageKey);

  @override
  Future<void> writeKey(String base64Key) =>
      _storage.write(key: storageKey, value: base64Key);
}

class OfflineKeyMissingException implements Exception {
  const OfflineKeyMissingException();

  @override
  String toString() =>
      'Offline encryption key is missing. The queue cannot be decrypted and '
      'will not fall back to plaintext.';
}

class OfflineDecryptionException implements Exception {
  const OfflineDecryptionException(this.reason);

  final String reason;

  @override
  String toString() =>
      'Offline queue ciphertext failed authentication: $reason';
}

/// AES-256-GCM envelope stored as three base64 fields.
class OfflineCipherEnvelope {
  const OfflineCipherEnvelope({
    required this.ciphertext,
    required this.nonce,
    required this.mac,
    required this.keyVersion,
    required this.plaintextSha256,
  });

  final String ciphertext;
  final String nonce;
  final String mac;
  final String keyVersion;
  final String plaintextSha256;
}

class OfflineCipher {
  OfflineCipher(
    this._secrets, {
    AesGcm? algorithm,
    Random? random,
    this.keyVersion = 'v1',
  }) : _algorithm = algorithm ?? AesGcm.with256bits(),
       _random = random ?? Random.secure();

  static const _nonceLength = 12;
  static const _keyLength = 32;

  final OfflineSecretStore _secrets;
  final AesGcm _algorithm;
  final Random _random;
  final String keyVersion;

  Future<OfflineCipherEnvelope> encryptJson(Map<String, dynamic> value) async {
    final key = await _loadOrCreateKey();
    final clearText = utf8.encode(jsonEncode(value));
    final nonce = List<int>.generate(
      _nonceLength,
      (_) => _random.nextInt(256),
      growable: false,
    );
    final box = await _algorithm.encrypt(
      clearText,
      secretKey: key,
      nonce: nonce,
    );
    final digest = await Sha256().hash(clearText);
    return OfflineCipherEnvelope(
      ciphertext: base64Encode(box.cipherText),
      nonce: base64Encode(box.nonce),
      mac: base64Encode(box.mac.bytes),
      keyVersion: keyVersion,
      plaintextSha256: base64Encode(digest.bytes),
    );
  }

  Future<Map<String, dynamic>> decryptJson(
    OfflineCipherEnvelope envelope,
  ) async {
    if (envelope.keyVersion != keyVersion) {
      throw OfflineDecryptionException(
        'unsupported key version ${envelope.keyVersion}',
      );
    }
    final key = await _readKey();
    try {
      final clearText = await _algorithm.decrypt(
        SecretBox(
          base64Decode(envelope.ciphertext),
          nonce: base64Decode(envelope.nonce),
          mac: Mac(base64Decode(envelope.mac)),
        ),
        secretKey: key,
      );
      final digest = await Sha256().hash(clearText);
      if (base64Encode(digest.bytes) != envelope.plaintextSha256) {
        throw const OfflineDecryptionException('plaintext digest mismatch');
      }
      final decoded = jsonDecode(utf8.decode(clearText));
      if (decoded is! Map) {
        throw const OfflineDecryptionException('payload is not a JSON object');
      }
      return decoded.cast<String, dynamic>();
    } on OfflineKeyMissingException {
      rethrow;
    } on OfflineDecryptionException {
      rethrow;
    } catch (error) {
      throw OfflineDecryptionException(error.runtimeType.toString());
    }
  }

  Future<SecretKey> _loadOrCreateKey() async {
    final existing = await _secrets.readKey();
    if (existing != null && existing.isNotEmpty) {
      return _decodeKey(existing);
    }
    final generated = List<int>.generate(
      _keyLength,
      (_) => _random.nextInt(256),
      growable: false,
    );
    await _secrets.writeKey(base64Encode(generated));
    return SecretKey(generated);
  }

  Future<SecretKey> _readKey() async {
    final existing = await _secrets.readKey();
    if (existing == null || existing.isEmpty) {
      throw const OfflineKeyMissingException();
    }
    return _decodeKey(existing);
  }

  SecretKey _decodeKey(String value) {
    final bytes = base64Decode(value);
    if (bytes.length != _keyLength) {
      throw const OfflineDecryptionException('invalid key length');
    }
    return SecretKey(bytes);
  }
}
