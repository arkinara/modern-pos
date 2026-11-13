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


/// tests for PurchasingApi
void main() {
  // final instance = PurchasingApi();

  group('tests for PurchasingApi', () {
    // Create a purchase order with supplier-unit conversion
    //
    //Future<PurchaseOrder> purchaseOrderCreate(String outletId, PurchaseOrderWrite purchaseOrderWrite) async
    test('test purchaseOrderCreate', () async {
      // TODO
    });

    // List purchase orders for an outlet
    //
    //Future<PurchaseOrderPage> purchaseOrderList(String outletId, { String cursor, int limit }) async
    test('test purchaseOrderList', () async {
      // TODO
    });

    // Receive ordered stock partially or fully
    //
    //Future<PurchaseOrderReceipt> purchaseOrderReceive(String outletId, String purchaseOrderId, PurchaseOrderReceiptWrite purchaseOrderReceiptWrite) async
    test('test purchaseOrderReceive', () async {
      // TODO
    });

    // Count stock and post variance ledger entries
    //
    //Future<StockCount> stockCountCreate(String outletId, StockCountWrite stockCountWrite) async
    test('test stockCountCreate', () async {
      // TODO
    });

    // List stock counts with variance lines
    //
    //Future<StockCountPage> stockCountList(String outletId, { String cursor, int limit }) async
    test('test stockCountList', () async {
      // TODO
    });

    // Create a supplier
    //
    //Future<Supplier> supplierCreate(String outletId, SupplierWrite supplierWrite) async
    test('test supplierCreate', () async {
      // TODO
    });

    // Search suppliers
    //
    //Future<SupplierPage> supplierList(String outletId, { String search, String cursor, int limit }) async
    test('test supplierList', () async {
      // TODO
    });

    // Cancel an unreceived transfer and restore source stock
    //
    //Future<Transfer> transferCancel(String outletId, String transferId) async
    test('test transferCancel', () async {
      // TODO
    });

    // Create a draft outlet transfer
    //
    //Future<Transfer> transferCreate(String outletId, TransferWrite transferWrite) async
    test('test transferCreate', () async {
      // TODO
    });

    // Dispatch a draft transfer and remove source stock
    //
    //Future<TransferMutation> transferDispatch(String outletId, String transferId) async
    test('test transferDispatch', () async {
      // TODO
    });

    // List transfers involving this outlet
    //
    //Future<TransferPage> transferList(String outletId, { String state, String cursor, int limit }) async
    test('test transferList', () async {
      // TODO
    });

    // Receive dispatched stock at the destination outlet
    //
    //Future<TransferMutation> transferReceive(String outletId, String transferId, TransferReceiveWrite transferReceiveWrite) async
    test('test transferReceive', () async {
      // TODO
    });

    // Remove stock with a mandatory waste reason
    //
    //Future<Waste> wasteCreate(String outletId, WasteWrite wasteWrite) async
    test('test wasteCreate', () async {
      // TODO
    });

    // List recorded waste and loss
    //
    //Future<WastePage> wasteList(String outletId, { String cursor, int limit }) async
    test('test wasteList', () async {
      // TODO
    });

  });
}
