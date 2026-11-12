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


/// tests for SandboxApi
void main() {
  // final instance = SandboxApi();

  group('tests for SandboxApi', () {
    // Create a deterministic local sandbox provider payment
    //
    // Local sandbox only; disabled unless PAYMENT_PROVIDER=mock. It performs no real provider call.
    //
    //Future<SandboxPayment> sandboxPaymentCreate(SandboxPaymentWrite sandboxPaymentWrite) async
    test('test sandboxPaymentCreate', () async {
      // TODO
    });

    // Advance the sandbox ledger and issue a correctly signed webhook event
    //
    // Returns the signed event body for the caller to deliver. Reuse the same event id to exercise duplicate delivery; send succeeded before pending to exercise out-of-order delivery.
    //
    //Future<SandboxEventResult> sandboxPaymentEvent(String providerRef, SandboxEventWrite sandboxEventWrite) async
    test('test sandboxPaymentEvent', () async {
      // TODO
    });

    // Read a local sandbox provider payment
    //
    //Future<SandboxPayment> sandboxPaymentGet(String providerRef) async
    test('test sandboxPaymentGet', () async {
      // TODO
    });

  });
}
