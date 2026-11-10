import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_controller.dart';
import '../../core/providers.dart';

/// Receipt identity text owned by the outlet settings. A cached copy is not
/// used: a missing fetch falls back to explicitly generic text instead of
/// inventing an outlet name.
class ReceiptIdentity {
  const ReceiptIdentity({
    required this.businessName,
    required this.outletName,
    this.address = '',
    this.receiptHeader = '',
    this.receiptFooter = '',
  });

  final String businessName;
  final String outletName;
  final String address;
  final String receiptHeader;
  final String receiptFooter;

  static const fallback = ReceiptIdentity(
    businessName: 'Modern POS',
    outletName: 'Modern POS',
  );
}

abstract interface class ReceiptIdentityRepository {
  Future<ReceiptIdentity?> load(String outletId);
}

class HttpReceiptIdentityRepository implements ReceiptIdentityRepository {
  HttpReceiptIdentityRepository(this._dio, this._accessToken);

  final Dio _dio;
  final String _accessToken;

  @override
  Future<ReceiptIdentity?> load(String outletId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/v1/outlets/${Uri.encodeComponent(outletId)}/settings',
        options: Options(headers: {'Authorization': 'Bearer $_accessToken'}),
      );
      final data = response.data;
      if (data == null) {
        return null;
      }
      final outletName = data['outletName'];
      final businessName = data['businessName'];
      if (outletName is! String || businessName is! String) {
        return null;
      }
      return ReceiptIdentity(
        businessName: businessName,
        outletName: outletName,
        address: data['receiptAddress'] as String? ?? '',
        receiptHeader: data['receiptHeader'] as String? ?? '',
        receiptFooter: data['receiptFooter'] as String? ?? '',
      );
    } on DioException {
      return null;
    }
  }
}

final receiptIdentityRepositoryProvider = Provider<ReceiptIdentityRepository?>((
  ref,
) {
  final session = ref.watch(authControllerProvider).value;
  if (session == null) {
    return null;
  }
  return HttpReceiptIdentityRepository(
    ref.watch(dioProvider),
    session.accessToken,
  );
});
