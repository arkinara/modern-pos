import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'providers.dart';

/// Stable device identity shared by authentication, draft orders and checkout
/// recovery. The server scopes idempotency keys by `(outletId, deviceId, key)`,
/// so the value must survive app restarts and session refreshes.
abstract interface class DeviceIdentity {
  Future<String> deviceId();
}

class SecureDeviceIdentity implements DeviceIdentity {
  SecureDeviceIdentity(this._storage);

  static const storageKey = 'pos_device_id';

  final FlutterSecureStorage _storage;

  @override
  Future<String> deviceId() async {
    final existing = await _storage.read(key: storageKey);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final generated = generateUuidV4();
    await _storage.write(key: storageKey, value: generated);
    return generated;
  }
}

final deviceIdentityProvider = Provider<DeviceIdentity>((ref) {
  return SecureDeviceIdentity(ref.watch(secureStorageProvider));
});

/// RFC 4122 version 4 UUID built from a secure random source.
String generateUuidV4() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final hex = bytes
      .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
      .join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}
