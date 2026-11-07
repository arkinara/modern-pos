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


/// tests for SalesApi
void main() {
  // final instance = SalesApi();

  group('tests for SalesApi', () {
    // Commit sale, payment record, stock, and recovery mapping
    //
    // Cash amount must equal quoted total; tender >= amount. Manual external amount equals total, no tender/change. Replay existing keys before checking expired quotes. All writes are one serializable transaction. No provider charge is made.
    //
    //Future<Finalized> salesFinalize(String outletId, String idempotencyKey, Finalize finalize) async
    test('test salesFinalize', () async {
      // TODO
    });

    // Read immutable receipt data
    //
    //Future<Sale> salesGet(String outletId, String saleId) async
    test('test salesGet', () async {
      // TODO
    });

    // List sales; cashiers see only authorized own sales
    //
    //Future<SalePage> salesList(String outletId, { String cursor, int limit, DateTime from, DateTime to }) async
    test('test salesList', () async {
      // TODO
    });

    // Resolve uncertain checkout by original key
    //
    // 404 does not prove an original request cannot still commit. Retain/resubmit the same key; never auto-create a new key.
    //
    //Future<Finalized> salesRecover(String outletId, String key, String deviceId) async
    test('test salesRecover', () async {
      // TODO
    });

    // Record full owner reversal and explicit restock
    //
    // One reversal per sale; validate restock <= original consumed amount. Does not return money through any external provider.
    //
    //Future<Reversal> salesReverse(String outletId, String saleId, String idempotencyKey, ReversalWrite reversalWrite) async
    test('test salesReverse', () async {
      // TODO
    });

  });
}
