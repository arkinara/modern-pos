// Live end-to-end proof for checkout, replay and uncertain-outcome recovery.
// Seed the API first, then run:
//   CHECKOUT_API_BASE_URL=http://localhost:4000 \
//     flutter test test/checkout_live_api_test.dart
// The default test run skips this file because no API base URL is provided.
// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:modern_pos_api_client/api.dart';
import 'package:modern_pos_mobile/core/device_identity.dart';

const _cashierEmail = 'cashier@example.test';
const _ownerEmail = 'owner@example.test';
const _deviceId = '00000000-0000-4000-8000-0000000000c2';

void main() {
  final baseUrl = Platform.environment['CHECKOUT_API_BASE_URL'];

  test(
    'checkout commits once, replays with the same key, recovers and deducts stock once',
    () async {
      final root = baseUrl;
      if (root == null) {
        return;
      }

      final apiClient = ApiClient(basePath: '$root/v1');
      final authApi = AuthApi(apiClient);
      final catalogApi = CatalogApi(apiClient);
      final orderApi = OrderApi(apiClient);
      final salesApi = SalesApi(apiClient);

      final password =
          Platform.environment['SEED_PASSWORD'] ?? 'modern-pos-demo-password';
      final session = await authApi.authMobileLogin(
        Login(email: _cashierEmail, password: password, deviceId: _deviceId),
      );
      expect(session, isNotNull);
      apiClient.addDefaultHeader(
        'Authorization',
        'Bearer ${session!.accessToken}',
      );
      final outletId = session.user.outletIds.first;
      print('signed in cashier outlet=$outletId device=$_deviceId');

      final ownerClient = ApiClient(basePath: '$root/v1');
      final ownerSession = await AuthApi(ownerClient).authMobileLogin(
        Login(
          email: _ownerEmail,
          password: password,
          deviceId: '00000000-0000-4000-8000-0000000000c3',
        ),
      );
      expect(ownerSession, isNotNull);
      ownerClient.addDefaultHeader(
        'Authorization',
        'Bearer ${ownerSession!.accessToken}',
      );
      final stockApi = StockApi(ownerClient);
      print('signed in owner for stock ledger verification');

      final menuPage = await catalogApi.catalogList(
        outletId,
        search: 'Chicken Rice',
        limit: 100,
      );
      final menu = menuPage!.items.firstWhere(
        (item) => item.name.contains('Chicken Rice') && !item.archived,
      );
      final variant = menu.variants.firstWhere(
        (candidate) =>
            candidate.stockPolicy == VariantStockPolicyEnum.TRACKED &&
            candidate.enabled,
      );
      print(
        'variant=${variant.id} name=${menu.name} ${variant.name} '
        'policy=${variant.stockPolicy}',
      );

      final orderKey = generateUuidV4();
      final order = await orderApi.orderCreate(
        outletId,
        orderKey,
        OrderWrite(
          deviceId: _deviceId,
          lines: [OrderWriteLinesInner(variantId: variant.id, quantity: 1)],
        ),
      );
      expect(order, isNotNull);
      print('draft order=${order!.id} version=${order.version}');

      final quote = await orderApi.orderQuote(
        outletId,
        order.id,
        OrderQuoteRequest(orderVersion: order.version),
      );
      expect(quote, isNotNull);
      final totalMinor = quote!.totals.totalMinor;
      expect(totalMinor, greaterThan(0));
      print(
        'quote=${quote.id} subtotal=${quote.totals.subtotalMinor} '
        'total=$totalMinor expires=${quote.expiresAt.toIso8601String()}',
      );

      final checkoutKey = generateUuidV4();
      final payment = PaymentInput(
        kind: PaymentInputKindEnum.CASH,
        amountMinor: totalMinor,
        tenderedMinor: totalMinor + 5000,
      );
      final payload = Finalize(
        deviceId: _deviceId,
        orderId: order.id,
        quoteId: quote.id,
        payment: payment,
      );

      final first = await salesApi.salesFinalize(
        outletId,
        checkoutKey,
        payload,
      );
      expect(first, isNotNull);
      expect(first!.replayed, isFalse);
      expect(first.sale.reference, 'SALE-${order.id}');
      expect(first.sale.totals.totalMinor, totalMinor);
      expect(first.sale.payment.changeMinor, 5000);
      print(
        'finalized sale=${first.sale.id} reference=${first.sale.reference} '
        'change=${first.sale.payment.changeMinor}',
      );

      final replay = await salesApi.salesFinalize(
        outletId,
        checkoutKey,
        payload,
      );
      expect(replay, isNotNull);
      expect(replay!.replayed, isTrue);
      expect(replay.sale.id, first.sale.id);
      print('replay sale=${replay.sale.id} replayed=${replay.replayed}');

      final recovered = await salesApi.salesRecover(
        outletId,
        checkoutKey,
        _deviceId,
      );
      expect(recovered, isNotNull);
      expect(recovered!.sale.id, first.sale.id);
      expect(recovered.replayed, isTrue);
      print(
        'recovered sale=${recovered.sale.id} '
        'reference=${recovered.sale.reference}',
      );

      final salesPage = await salesApi.salesList(outletId, limit: 100);
      expect(salesPage, isNotNull);
      final matchingSales = salesPage!.items.where(
        (sale) => sale.id == first.sale.id,
      );
      expect(matchingSales, hasLength(1));
      print('sale count for ${first.sale.id} = ${matchingSales.length}');

      final stockPage = await stockApi.stockList(outletId, limit: 100);
      expect(stockPage, isNotNull);
      var saleMovementCount = 0;
      for (final stock in stockPage!.items) {
        final movements = await stockApi.stockMovements(
          outletId,
          stock.id,
          limit: 100,
        );
        final forSale = movements!.items.where(
          (movement) =>
              movement.type == MovementTypeEnum.SALE &&
              movement.sourceId == first.sale.id,
        );
        if (forSale.isNotEmpty) {
          expect(
            forSale,
            hasLength(1),
            reason: 'duplicate SALE movement for ${stock.id}',
          );
          saleMovementCount += forSale.length;
          print(
            'stock ${stock.name}: one SALE movement delta=${forSale.first.delta}',
          );
        }
      }
      expect(saleMovementCount, 3);
      print('SALE stock movements for one sale = $saleMovementCount');

      final secondOrder = await orderApi.orderCreate(
        outletId,
        generateUuidV4(),
        OrderWrite(
          deviceId: _deviceId,
          lines: [OrderWriteLinesInner(variantId: variant.id, quantity: 1)],
        ),
      );
      final secondQuote = await orderApi.orderQuote(
        outletId,
        secondOrder!.id,
        OrderQuoteRequest(orderVersion: secondOrder.version),
      );
      final insufficientKey = generateUuidV4();
      try {
        await salesApi.salesFinalize(
          outletId,
          insufficientKey,
          Finalize(
            deviceId: _deviceId,
            orderId: secondOrder.id,
            quoteId: secondQuote!.id,
            payment: PaymentInput(
              kind: PaymentInputKindEnum.CASH,
              amountMinor: secondQuote.totals.totalMinor,
              tenderedMinor: secondQuote.totals.totalMinor - 1,
            ),
          ),
        );
        fail('Insufficient tender must be rejected');
      } on ApiException catch (error) {
        expect(error.code, 422);
        expect(error.message, contains('INSUFFICIENT_TENDER'));
        print(
          'server rejected insufficient tender with 422 INSUFFICIENT_TENDER',
        );
      }

      try {
        await salesApi.salesRecover(outletId, insufficientKey, _deviceId);
        fail('A rejected checkout must not be recoverable as a sale');
      } on ApiException catch (error) {
        expect(error.code, 404);
        print('rejected checkout key resolves 404 with no committed sale');
      }

      final afterRejection = await salesApi.salesList(outletId, limit: 100);
      expect(
        afterRejection!.items.where((sale) => sale.orderId == secondOrder.id),
        isEmpty,
      );
    },
    skip: baseUrl == null
        ? 'Set CHECKOUT_API_BASE_URL to run the live checkout proof.'
        : false,
    timeout: const Timeout(Duration(seconds: 90)),
  );
}
