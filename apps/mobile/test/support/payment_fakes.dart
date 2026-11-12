import 'package:modern_pos_api_client/api.dart';
import 'package:modern_pos_mobile/features/payments/payments_gateway.dart';

OnlinePaymentListItem testOnlinePayment({
  String saleId = '00000000-0000-4000-8000-000000000096',
  String saleReference = 'SALE-ONLINE-1',
  OnlinePaymentListItemStatusEnum status =
      OnlinePaymentListItemStatusEnum.SUCCEEDED,
  int amountMinor = 35000,
}) {
  return OnlinePaymentListItem(
    id: '00000000-0000-4000-8000-0000000000f0',
    saleId: saleId,
    provider: OnlinePaymentListItemProviderEnum.MOCK,
    providerRef: 'mock_ref_1',
    status: status,
    amountMinor: amountMinor,
    refundedMinor: 0,
    currency: 'IDR',
    currencyExponent: 0,
    createdAt: DateTime.utc(2026, 11, 12),
    updatedAt: DateTime.utc(2026, 11, 12),
    saleReference: saleReference,
    saleCompletedAt: DateTime.utc(2026, 11, 12),
  );
}

class FakePaymentsGateway implements PaymentsGateway {
  FakePaymentsGateway({List<OnlinePaymentListItem>? payments})
    : payments = payments ?? [testOnlinePayment()];

  final List<OnlinePaymentListItem> payments;
  int listCalls = 0;
  int refreshCalls = 0;

  @override
  Future<List<OnlinePaymentListItem>> listPayments(String outletId) async {
    listCalls += 1;
    return payments;
  }

  @override
  Future<OnlinePayment> refreshPayment({
    required String outletId,
    required String saleId,
  }) async {
    refreshCalls += 1;
    final payment = payments.firstWhere((row) => row.saleId == saleId);
    payment.status = OnlinePaymentListItemStatusEnum.SUCCEEDED;
    return OnlinePayment(
      id: payment.id,
      saleId: payment.saleId,
      provider: OnlinePaymentProviderEnum.MOCK,
      providerRef: payment.providerRef,
      status: OnlinePaymentStatusEnum.SUCCEEDED,
      amountMinor: payment.amountMinor,
      refundedMinor: 0,
      currency: payment.currency,
      currencyExponent: payment.currencyExponent,
      createdAt: payment.createdAt,
      updatedAt: payment.updatedAt,
    );
  }
}
