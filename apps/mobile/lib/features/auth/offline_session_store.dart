import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:modern_pos_api_client/api.dart';

import '../../core/providers.dart';

/// Maximum time a previously authorized cashier session may restart and stay
/// usable without a successful server refresh. One long shift; see
/// `docs/offline-session.md` for the policy rationale.
const defaultOfflineSessionAllowance = Duration(hours: 12);

/// Last server-authorized profile. Only written after a successful login or
/// refresh; never written from an offline queue replay.
class OfflineSessionProfile {
  const OfflineSessionProfile({required this.user, required this.authorizedAt});

  final User user;
  final DateTime authorizedAt;

  bool withinAllowance(DateTime now, Duration allowance) {
    final elapsed = now.difference(authorizedAt);
    return elapsed >= Duration.zero && elapsed <= allowance;
  }

  Map<String, dynamic> toJson() => {
    'user': user.toJson(),
    'authorizedAt': authorizedAt.toUtc().toIso8601String(),
  };

  static OfflineSessionProfile? fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];
    final authorizedAt = json['authorizedAt'];
    if (userJson is! Map || authorizedAt is! String) {
      return null;
    }
    final parsedAt = DateTime.tryParse(authorizedAt);
    if (parsedAt == null) {
      return null;
    }
    try {
      final user = User.fromJson(userJson);
      if (user == null) {
        return null;
      }
      return OfflineSessionProfile(user: user, authorizedAt: parsedAt);
    } catch (_) {
      return null;
    }
  }
}

/// Identity that owns the device-local encrypted queue and catalog snapshot.
/// A missing or different scope fails closed so one account cannot read or
/// replay another account's cached data.
class OfflineQueueScope {
  const OfflineQueueScope({required this.userId, required this.outletId});

  final String userId;
  final String outletId;

  bool matches(OfflineQueueScope other) {
    return userId == other.userId && outletId == other.outletId;
  }

  Map<String, dynamic> toJson() => {'userId': userId, 'outletId': outletId};

  static OfflineQueueScope? fromJson(Map<String, dynamic> json) {
    final userId = json['userId'];
    final outletId = json['outletId'];
    if (userId is! String || outletId is! String) {
      return null;
    }
    return OfflineQueueScope(userId: userId, outletId: outletId);
  }
}

abstract interface class OfflineSessionStore {
  Future<OfflineSessionProfile?> read();

  Future<void> write(OfflineSessionProfile profile);

  Future<void> clear();
}

class SecureOfflineSessionStore implements OfflineSessionStore {
  SecureOfflineSessionStore(this._storage);

  static const storageKey = 'pos_offline_session_v1';

  final FlutterSecureStorage _storage;

  @override
  Future<OfflineSessionProfile?> read() async {
    final raw = await _storage.read(key: storageKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return null;
      }
      return OfflineSessionProfile.fromJson(decoded.cast<String, dynamic>());
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> write(OfflineSessionProfile profile) {
    return _storage.write(key: storageKey, value: jsonEncode(profile.toJson()));
  }

  @override
  Future<void> clear() => _storage.delete(key: storageKey);
}

abstract interface class OfflineQueueScopeStore {
  Future<OfflineQueueScope?> read();

  Future<void> write(OfflineQueueScope scope);

  Future<void> clear();
}

class SecureOfflineQueueScopeStore implements OfflineQueueScopeStore {
  SecureOfflineQueueScopeStore(this._storage);

  static const storageKey = 'pos_offline_queue_scope_v1';

  final FlutterSecureStorage _storage;

  @override
  Future<OfflineQueueScope?> read() async {
    final raw = await _storage.read(key: storageKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return null;
      }
      return OfflineQueueScope.fromJson(decoded.cast<String, dynamic>());
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> write(OfflineQueueScope scope) {
    return _storage.write(key: storageKey, value: jsonEncode(scope.toJson()));
  }

  @override
  Future<void> clear() => _storage.delete(key: storageKey);
}

final offlineSessionStoreProvider = Provider<OfflineSessionStore>((ref) {
  return SecureOfflineSessionStore(ref.watch(secureStorageProvider));
});

final offlineQueueScopeStoreProvider = Provider<OfflineQueueScopeStore>((ref) {
  return SecureOfflineQueueScopeStore(ref.watch(secureStorageProvider));
});
