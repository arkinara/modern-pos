// Live HTTP transcript for the refresh retry policy.
// The local loopback server returns real 503/401/200 status codes so the
// bounded retry and revocation branches are exercised through Dio and the real
// AuthRepository, not a mocked status code.
// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modern_pos_mobile/core/device_identity.dart';
import 'package:modern_pos_mobile/core/providers.dart';
import 'package:modern_pos_mobile/features/auth/auth_controller.dart';
import 'package:modern_pos_mobile/features/auth/offline_session_store.dart';
import 'package:modern_pos_mobile/features/cart/cart_controller.dart';
import 'package:modern_pos_mobile/features/catalog/catalog_snapshot_store.dart';
import 'package:modern_pos_mobile/features/offline/offline_sale_store.dart';

import 'support/checkout_fakes.dart';
import 'support/fakes.dart';
import 'support/offline_fakes.dart';

Map<String, dynamic> _sessionBody({
  String accessToken = 'access-live',
  String refreshToken = 'refresh-live',
}) {
  return {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'expiresInSeconds': 600,
    'user': {
      'id': 'user-1',
      'email': 'cashier@example.test',
      'role': 'CASHIER',
      'outletIds': ['outlet-1'],
    },
  };
}

Future<HttpServer> _server(
  Future<void> Function(HttpRequest request) handler,
) async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  server.listen((request) async {
    await handler(request);
  });
  return server;
}

void _json(HttpRequest request, int status, Map<String, dynamic> body) {
  request.response
    ..statusCode = status
    ..headers.contentType = ContentType.json
    ..write(jsonEncode(body));
  request.response.close();
}

class _TranscriptHarness {
  _TranscriptHarness(Uri baseUri) {
    final dio = Dio(BaseOptions(baseUrl: baseUri.toString()));
    container = ProviderContainer(
      overrides: [
        dioProvider.overrideWithValue(dio),
        secureStorageProvider.overrideWithValue(storage),
        deviceIdentityProvider.overrideWithValue(
          FixedDeviceIdentity('device-1'),
        ),
        offlineSessionStoreProvider.overrideWithValue(offlineStore),
        offlineQueueScopeStoreProvider.overrideWithValue(scopeStore),
        offlineSaleStoreProvider.overrideWithValue(queueStore),
        cartRepositoryProvider.overrideWithValue(cart),
        catalogSnapshotStoreProvider.overrideWithValue(snapshotStore),
        authRefreshPolicyProvider.overrideWithValue(
          const AuthRefreshPolicy(
            baseRetryDelay: Duration(milliseconds: 5),
            maxRetryAttempts: 4,
          ),
        ),
      ],
    );
    addTearDown(() {
      container.dispose();
      dio.close();
    });
  }

  final InMemorySecureStorage storage = InMemorySecureStorage();
  final InMemoryOfflineSessionStore offlineStore =
      InMemoryOfflineSessionStore();
  final InMemoryOfflineQueueScopeStore scopeStore =
      InMemoryOfflineQueueScopeStore();
  final InMemoryOfflineSaleStore queueStore = InMemoryOfflineSaleStore();
  final InMemoryCartRepository cart = InMemoryCartRepository();
  final InMemoryCatalogSnapshotStore snapshotStore =
      InMemoryCatalogSnapshotStore();
  late final ProviderContainer container;

  AuthSession? get session => container.read(authControllerProvider).value;
}

Future<void> _waitFor(bool Function() condition) async {
  final deadline = DateTime.now().add(const Duration(seconds: 4));
  while (!condition() && DateTime.now().isBefore(deadline)) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

void main() {
  test(
    'live refresh transcript: 503, 503, 200 retries then recovers',
    () async {
      final statuses = <int>[];
      var calls = 0;
      final server = await _server((request) async {
        await request.drain<void>();
        calls++;
        if (calls <= 2) {
          statuses.add(503);
          _json(request, 503, {
            'code': 'UNAVAILABLE',
            'message': 'temporary outage',
          });
          return;
        }
        statuses.add(200);
        _json(request, 200, _sessionBody());
      });
      addTearDown(() => server.close(force: true));

      final h = _TranscriptHarness(
        Uri.parse('http://${server.address.address}:${server.port}'),
      );
      h.storage.values['pos_refresh_token'] = 'refresh-live';
      await h.offlineStore.write(
        OfflineSessionProfile(
          user: testMobileSession().user,
          authorizedAt: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
      );

      final first = await h.container.read(authControllerProvider.future);
      expect(first?.offline, isTrue);
      await _waitFor(() => h.session?.canSyncOnline ?? false);

      print('refresh status sequence: ${statuses.join(', ')}');
      expect(statuses, [503, 503, 200]);
      expect(h.session?.offline, isFalse);
      expect(h.session?.accessToken, 'access-live');
    },
  );

  test('live refresh transcript: 401 requires sign-in', () async {
    final statuses = <int>[];
    final server = await _server((request) async {
      await request.drain<void>();
      statuses.add(401);
      _json(request, 401, {
        'code': 'INVALID_REFRESH_TOKEN',
        'message': 'revoked',
      });
    });
    addTearDown(() => server.close(force: true));

    final h = _TranscriptHarness(
      Uri.parse('http://${server.address.address}:${server.port}'),
    );
    h.storage.values['pos_refresh_token'] = 'refresh-live';
    await h.offlineStore.write(
      OfflineSessionProfile(
        user: testMobileSession().user,
        authorizedAt: DateTime.now(),
      ),
    );

    final session = await h.container.read(authControllerProvider.future);

    print('refresh status sequence: ${statuses.join(', ')}');
    expect(statuses, [401]);
    expect(session, isNull);
    expect(h.storage.values.containsKey('pos_refresh_token'), isFalse);
  });
}
