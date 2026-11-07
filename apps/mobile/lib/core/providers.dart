import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modern_pos_api_client/api.dart';

import 'database/app_database.dart';

const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:4000',
);

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
  ref.onDispose(dio.close);
  return dio;
});

final contractClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(basePath: '$apiBaseUrl/v1');
});

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final apiHealthProvider = FutureProvider<String>((ref) async {
  final response = await ref
      .watch(dioProvider)
      .get<Map<String, dynamic>>('/health');
  return response.data?['status'] as String? ?? 'unknown';
});
