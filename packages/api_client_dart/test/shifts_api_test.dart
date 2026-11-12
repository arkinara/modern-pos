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


/// tests for ShiftsApi
void main() {
  // final instance = ShiftsApi();

  group('tests for ShiftsApi', () {
    // Record a paid-in or paid-out on an open shift
    //
    // Paid-out above the active CASH_OUT approval threshold requires an owner and returns 403 APPROVAL_REQUIRED.
    //
    //Future<Shift> shiftsCashMovement(String outletId, String shiftId, ShiftCashMovementWrite shiftCashMovementWrite) async
    test('test shiftsCashMovement', () async {
      // TODO
    });

    // Count the drawer and close the caller own shift
    //
    // Expected cash is opening float + cash tender sales + paid-ins - paid-outs. Closing a closed shift or someone else's shift returns 409.
    //
    //Future<Shift> shiftsClose(String outletId, String shiftId, ShiftCloseWrite shiftCloseWrite) async
    test('test shiftsClose', () async {
      // TODO
    });

    // Read one shift
    //
    //Future<Shift> shiftsGet(String outletId, String shiftId) async
    test('test shiftsGet', () async {
      // TODO
    });

    // List cash shifts for an outlet
    //
    //Future<ShiftPage> shiftsList(String outletId, { String status, String cursor, int limit }) async
    test('test shiftsList', () async {
      // TODO
    });

    // Open a shift with an opening float
    //
    //Future<Shift> shiftsOpen(String outletId, ShiftWrite shiftWrite) async
    test('test shiftsOpen', () async {
      // TODO
    });

    // Read the reconciled shift cash report (owner only)
    //
    //Future<ShiftReport> shiftsReport(String outletId, String shiftId) async
    test('test shiftsReport', () async {
      // TODO
    });

  });
}
