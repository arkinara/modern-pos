//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class PurchasingApi {
  PurchasingApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Cancel a purchase order before any receipt
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] purchaseOrderId (required):
  Future<Response> purchaseOrderCancelWithHttpInfo(String outletId, String purchaseOrderId, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/purchase-orders/{purchaseOrderId}/cancel'
      .replaceAll('{outletId}', outletId)
      .replaceAll('{purchaseOrderId}', purchaseOrderId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Cancel a purchase order before any receipt
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] purchaseOrderId (required):
  Future<PurchaseOrder?> purchaseOrderCancel(String outletId, String purchaseOrderId, { Future<void>? abortTrigger, }) async {
    final response = await purchaseOrderCancelWithHttpInfo(outletId, purchaseOrderId, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'PurchaseOrder',) as PurchaseOrder;
    
    }
    return null;
  }

  /// Create a purchase order with supplier-unit conversion
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [PurchaseOrderWrite] purchaseOrderWrite (required):
  Future<Response> purchaseOrderCreateWithHttpInfo(String outletId, PurchaseOrderWrite purchaseOrderWrite, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/purchase-orders'
      .replaceAll('{outletId}', outletId);

    // ignore: prefer_final_locals
    Object? postBody = purchaseOrderWrite;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Create a purchase order with supplier-unit conversion
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [PurchaseOrderWrite] purchaseOrderWrite (required):
  Future<PurchaseOrder?> purchaseOrderCreate(String outletId, PurchaseOrderWrite purchaseOrderWrite, { Future<void>? abortTrigger, }) async {
    final response = await purchaseOrderCreateWithHttpInfo(outletId, purchaseOrderWrite, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'PurchaseOrder',) as PurchaseOrder;
    
    }
    return null;
  }

  /// List purchase orders for an outlet
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] cursor:
  ///
  /// * [int] limit:
  Future<Response> purchaseOrderListWithHttpInfo(String outletId, { String? cursor, int? limit, Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/purchase-orders'
      .replaceAll('{outletId}', outletId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (cursor != null) {
      queryParams.addAll(_queryParams('', 'cursor', cursor));
    }
    if (limit != null) {
      queryParams.addAll(_queryParams('', 'limit', limit));
    }

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// List purchase orders for an outlet
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] cursor:
  ///
  /// * [int] limit:
  Future<PurchaseOrderPage?> purchaseOrderList(String outletId, { String? cursor, int? limit, Future<void>? abortTrigger, }) async {
    final response = await purchaseOrderListWithHttpInfo(outletId, cursor: cursor, limit: limit, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'PurchaseOrderPage',) as PurchaseOrderPage;
    
    }
    return null;
  }

  /// Receive ordered stock partially or fully
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] purchaseOrderId (required):
  ///
  /// * [PurchaseOrderReceiptWrite] purchaseOrderReceiptWrite (required):
  Future<Response> purchaseOrderReceiveWithHttpInfo(String outletId, String purchaseOrderId, PurchaseOrderReceiptWrite purchaseOrderReceiptWrite, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/purchase-orders/{purchaseOrderId}/receipts'
      .replaceAll('{outletId}', outletId)
      .replaceAll('{purchaseOrderId}', purchaseOrderId);

    // ignore: prefer_final_locals
    Object? postBody = purchaseOrderReceiptWrite;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Receive ordered stock partially or fully
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] purchaseOrderId (required):
  ///
  /// * [PurchaseOrderReceiptWrite] purchaseOrderReceiptWrite (required):
  Future<PurchaseOrderReceipt?> purchaseOrderReceive(String outletId, String purchaseOrderId, PurchaseOrderReceiptWrite purchaseOrderReceiptWrite, { Future<void>? abortTrigger, }) async {
    final response = await purchaseOrderReceiveWithHttpInfo(outletId, purchaseOrderId, purchaseOrderReceiptWrite, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'PurchaseOrderReceipt',) as PurchaseOrderReceipt;
    
    }
    return null;
  }

  /// Count stock and post variance ledger entries
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [StockCountWrite] stockCountWrite (required):
  Future<Response> stockCountCreateWithHttpInfo(String outletId, StockCountWrite stockCountWrite, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/stock-counts'
      .replaceAll('{outletId}', outletId);

    // ignore: prefer_final_locals
    Object? postBody = stockCountWrite;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Count stock and post variance ledger entries
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [StockCountWrite] stockCountWrite (required):
  Future<StockCount?> stockCountCreate(String outletId, StockCountWrite stockCountWrite, { Future<void>? abortTrigger, }) async {
    final response = await stockCountCreateWithHttpInfo(outletId, stockCountWrite, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'StockCount',) as StockCount;
    
    }
    return null;
  }

  /// List stock counts with variance lines
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] cursor:
  ///
  /// * [int] limit:
  Future<Response> stockCountListWithHttpInfo(String outletId, { String? cursor, int? limit, Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/stock-counts'
      .replaceAll('{outletId}', outletId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (cursor != null) {
      queryParams.addAll(_queryParams('', 'cursor', cursor));
    }
    if (limit != null) {
      queryParams.addAll(_queryParams('', 'limit', limit));
    }

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// List stock counts with variance lines
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] cursor:
  ///
  /// * [int] limit:
  Future<StockCountPage?> stockCountList(String outletId, { String? cursor, int? limit, Future<void>? abortTrigger, }) async {
    final response = await stockCountListWithHttpInfo(outletId, cursor: cursor, limit: limit, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'StockCountPage',) as StockCountPage;
    
    }
    return null;
  }

  /// Create a supplier
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [SupplierWrite] supplierWrite (required):
  Future<Response> supplierCreateWithHttpInfo(String outletId, SupplierWrite supplierWrite, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/suppliers'
      .replaceAll('{outletId}', outletId);

    // ignore: prefer_final_locals
    Object? postBody = supplierWrite;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Create a supplier
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [SupplierWrite] supplierWrite (required):
  Future<Supplier?> supplierCreate(String outletId, SupplierWrite supplierWrite, { Future<void>? abortTrigger, }) async {
    final response = await supplierCreateWithHttpInfo(outletId, supplierWrite, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Supplier',) as Supplier;
    
    }
    return null;
  }

  /// Search suppliers
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] search:
  ///
  /// * [String] cursor:
  ///
  /// * [int] limit:
  Future<Response> supplierListWithHttpInfo(String outletId, { String? search, String? cursor, int? limit, Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/suppliers'
      .replaceAll('{outletId}', outletId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (search != null) {
      queryParams.addAll(_queryParams('', 'search', search));
    }
    if (cursor != null) {
      queryParams.addAll(_queryParams('', 'cursor', cursor));
    }
    if (limit != null) {
      queryParams.addAll(_queryParams('', 'limit', limit));
    }

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Search suppliers
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] search:
  ///
  /// * [String] cursor:
  ///
  /// * [int] limit:
  Future<SupplierPage?> supplierList(String outletId, { String? search, String? cursor, int? limit, Future<void>? abortTrigger, }) async {
    final response = await supplierListWithHttpInfo(outletId, search: search, cursor: cursor, limit: limit, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'SupplierPage',) as SupplierPage;
    
    }
    return null;
  }

  /// Cancel an unreceived transfer and restore source stock
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] transferId (required):
  Future<Response> transferCancelWithHttpInfo(String outletId, String transferId, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/transfers/{transferId}/cancel'
      .replaceAll('{outletId}', outletId)
      .replaceAll('{transferId}', transferId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Cancel an unreceived transfer and restore source stock
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] transferId (required):
  Future<OutletTransfer?> transferCancel(String outletId, String transferId, { Future<void>? abortTrigger, }) async {
    final response = await transferCancelWithHttpInfo(outletId, transferId, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'OutletTransfer',) as OutletTransfer;
    
    }
    return null;
  }

  /// Create a draft outlet transfer
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [OutletTransferWrite] outletTransferWrite (required):
  Future<Response> transferCreateWithHttpInfo(String outletId, OutletTransferWrite outletTransferWrite, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/transfers'
      .replaceAll('{outletId}', outletId);

    // ignore: prefer_final_locals
    Object? postBody = outletTransferWrite;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Create a draft outlet transfer
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [OutletTransferWrite] outletTransferWrite (required):
  Future<OutletTransfer?> transferCreate(String outletId, OutletTransferWrite outletTransferWrite, { Future<void>? abortTrigger, }) async {
    final response = await transferCreateWithHttpInfo(outletId, outletTransferWrite, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'OutletTransfer',) as OutletTransfer;
    
    }
    return null;
  }

  /// Dispatch a draft transfer and remove source stock
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] transferId (required):
  Future<Response> transferDispatchWithHttpInfo(String outletId, String transferId, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/transfers/{transferId}/dispatch'
      .replaceAll('{outletId}', outletId)
      .replaceAll('{transferId}', transferId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Dispatch a draft transfer and remove source stock
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] transferId (required):
  Future<OutletTransferMutation?> transferDispatch(String outletId, String transferId, { Future<void>? abortTrigger, }) async {
    final response = await transferDispatchWithHttpInfo(outletId, transferId, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'OutletTransferMutation',) as OutletTransferMutation;
    
    }
    return null;
  }

  /// List transfers involving this outlet
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] state:
  ///
  /// * [String] cursor:
  ///
  /// * [int] limit:
  Future<Response> transferListWithHttpInfo(String outletId, { String? state, String? cursor, int? limit, Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/transfers'
      .replaceAll('{outletId}', outletId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (state != null) {
      queryParams.addAll(_queryParams('', 'state', state));
    }
    if (cursor != null) {
      queryParams.addAll(_queryParams('', 'cursor', cursor));
    }
    if (limit != null) {
      queryParams.addAll(_queryParams('', 'limit', limit));
    }

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// List transfers involving this outlet
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] state:
  ///
  /// * [String] cursor:
  ///
  /// * [int] limit:
  Future<OutletTransferPage?> transferList(String outletId, { String? state, String? cursor, int? limit, Future<void>? abortTrigger, }) async {
    final response = await transferListWithHttpInfo(outletId, state: state, cursor: cursor, limit: limit, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'OutletTransferPage',) as OutletTransferPage;
    
    }
    return null;
  }

  /// Receive dispatched stock at the destination outlet
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] transferId (required):
  ///
  /// * [OutletTransferReceiveWrite] outletTransferReceiveWrite (required):
  Future<Response> transferReceiveWithHttpInfo(String outletId, String transferId, OutletTransferReceiveWrite outletTransferReceiveWrite, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/transfers/{transferId}/receive'
      .replaceAll('{outletId}', outletId)
      .replaceAll('{transferId}', transferId);

    // ignore: prefer_final_locals
    Object? postBody = outletTransferReceiveWrite;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Receive dispatched stock at the destination outlet
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] transferId (required):
  ///
  /// * [OutletTransferReceiveWrite] outletTransferReceiveWrite (required):
  Future<OutletTransferMutation?> transferReceive(String outletId, String transferId, OutletTransferReceiveWrite outletTransferReceiveWrite, { Future<void>? abortTrigger, }) async {
    final response = await transferReceiveWithHttpInfo(outletId, transferId, outletTransferReceiveWrite, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'OutletTransferMutation',) as OutletTransferMutation;
    
    }
    return null;
  }

  /// Remove stock with a mandatory waste reason
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [WasteWrite] wasteWrite (required):
  Future<Response> wasteCreateWithHttpInfo(String outletId, WasteWrite wasteWrite, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/stock-wastes'
      .replaceAll('{outletId}', outletId);

    // ignore: prefer_final_locals
    Object? postBody = wasteWrite;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Remove stock with a mandatory waste reason
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [WasteWrite] wasteWrite (required):
  Future<Waste?> wasteCreate(String outletId, WasteWrite wasteWrite, { Future<void>? abortTrigger, }) async {
    final response = await wasteCreateWithHttpInfo(outletId, wasteWrite, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Waste',) as Waste;
    
    }
    return null;
  }

  /// List recorded waste and loss
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] cursor:
  ///
  /// * [int] limit:
  Future<Response> wasteListWithHttpInfo(String outletId, { String? cursor, int? limit, Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/stock-wastes'
      .replaceAll('{outletId}', outletId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (cursor != null) {
      queryParams.addAll(_queryParams('', 'cursor', cursor));
    }
    if (limit != null) {
      queryParams.addAll(_queryParams('', 'limit', limit));
    }

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// List recorded waste and loss
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] cursor:
  ///
  /// * [int] limit:
  Future<WastePage?> wasteList(String outletId, { String? cursor, int? limit, Future<void>? abortTrigger, }) async {
    final response = await wasteListWithHttpInfo(outletId, cursor: cursor, limit: limit, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'WastePage',) as WastePage;
    
    }
    return null;
  }
}
