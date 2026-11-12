//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

import 'package:modern_pos_api_client/api.dart';
import 'package:test/test.dart';


/// tests for PaymentsApi
void main() {
  // final instance = PaymentsApi();

  group('tests for PaymentsApi', () {
    // Create or replay the provider payment intent for a completed online sale
    //
    // Idempotent per sale: repeated calls return the same online payment and provider reference. A failed intent is reset to pending for an explicit retry. No stock or sale is created here.
    //
    //Future<OnlinePayment> paymentsCreate(String outletId, String saleId) async
    test('test paymentsCreate', () async {
      // TODO
    });

    // Read the server-side online payment state
    //
    // The client resolves reconnect state from the server and never assumes failure or recharges.
    //
    //Future<OnlinePayment> paymentsGet(String outletId, String saleId) async
    test('test paymentsGet', () async {
      // TODO
    });

    // List online payments for the outlet
    //
    //Future<OnlinePaymentList> paymentsList(String outletId, { int limit }) async
    test('test paymentsList', () async {
      // TODO
    });

    // Compare pending local payments with the provider and repair drift
    //
    // Read-only toward the provider: fetches each pending provider payment and applies the reported state. It never creates a provider charge.
    //
    //Future<ReconciliationSummary> paymentsReconcile(String outletId) async
    test('test paymentsReconcile', () async {
      // TODO
    });

    // Resolve provider state after a lost client connection
    //
    // Fetches the provider record and applies pending/succeeded/failed without creating a second payment or stock movement.
    //
    //Future<OnlinePayment> paymentsRefresh(String outletId, String saleId) async
    test('test paymentsRefresh', () async {
      // TODO
    });

    // Daily and per-payment captured/refunded settlement report
    //
    //Future<SettlementReport> paymentsSettlements(String outletId, DateTime from, DateTime to) async
    test('test paymentsSettlements', () async {
      // TODO
    });

    // Receive a signed, replay-protected provider webhook
    //
    // Public endpoint. Invalid signatures and timestamps outside the replay window are rejected before any state change. Provider event ids are unique per provider for concurrency-safe dedupe. A duplicate delivery is acknowledged with duplicate=true.
    //
    //Future<WebhookAck> paymentsWebhook(String xPaymentSignature) async
    test('test paymentsWebhook', () async {
      // TODO
    });

  });
}
