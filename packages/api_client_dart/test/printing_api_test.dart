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


/// tests for PrintingApi
void main() {
  // final instance = PrintingApi();

  group('tests for PrintingApi', () {
    // Save verified-model printer configuration
    //
    // Hardware support is verified per model/transport; declared enum values do not imply all transports are shipped.
    //
    //Future<Printer> printingCreate(String outletId, PrinterWrite printerWrite) async
    test('test printingCreate', () async {
      // TODO
    });

    // Mirror local receipt job metadata
    //
    // The local durable queue owns execution; API failure cannot roll back the sale or erase its local job. Server enforces device ownership.
    //
    //Future<PrintJob> printingJob(String outletId, String idempotencyKey, PrintJobWrite printJobWrite) async
    test('test printingJob', () async {
      // TODO
    });

    // Read device-owned printer configuration
    //
    //Future<List<Printer>> printingList(String outletId, String deviceId) async
    test('test printingList', () async {
      // TODO
    });

    // Update owned job delivery status
    //
    //Future<PrintJob> printingState(String outletId, String jobId, PrintingStateRequest printingStateRequest) async
    test('test printingState', () async {
      // TODO
    });

    // Update printer config with revision
    //
    //Future<Printer> printingUpdate(String outletId, String printerId, PrintingUpdateRequest printingUpdateRequest) async
    test('test printingUpdate', () async {
      // TODO
    });

  });
}
