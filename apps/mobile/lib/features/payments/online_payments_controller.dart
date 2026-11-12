import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modern_pos_api_client/api.dart';

import '../auth/auth_controller.dart';
import 'payments_gateway.dart';

final onlinePaymentsControllerProvider =
    AsyncNotifierProvider.autoDispose<
      OnlinePaymentsController,
      List<OnlinePaymentListItem>
    >(OnlinePaymentsController.new);

class OnlinePaymentsController
    extends AsyncNotifier<List<OnlinePaymentListItem>> {
  PaymentsGateway get _gateway => ref.read(paymentsGatewayProvider);

  String? get _outletId {
    final session = ref.read(authControllerProvider).value;
    if (session == null || session.user.outletIds.isEmpty) {
      return null;
    }
    return session.user.outletIds.first;
  }

  @override
  Future<List<OnlinePaymentListItem>> build() async {
    final outletId = _outletId;
    if (outletId == null) {
      return const [];
    }
    return _gateway.listPayments(outletId);
  }

  Future<void> load() async {
    final outletId = _outletId;
    if (outletId == null) {
      state = const AsyncData([]);
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _gateway.listPayments(outletId));
  }

  Future<void> refreshSale(String saleId) async {
    final outletId = _outletId;
    if (outletId == null) {
      return;
    }
    try {
      await _gateway.refreshPayment(outletId: outletId, saleId: saleId);
    } on PaymentsApiException catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return;
    }
    await load();
  }
}
