//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class OrderApi {
  OrderApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Read the append-only order audit trail (owner only)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] orderId (required):
  Future<Response> orderAuditListWithHttpInfo(String outletId, String orderId, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/orders/{orderId}/audit'
      .replaceAll('{outletId}', outletId)
      .replaceAll('{orderId}', orderId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  /// Read the append-only order audit trail (owner only)
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] orderId (required):
  Future<AuditPage?> orderAuditList(String outletId, String orderId, { Future<void>? abortTrigger, }) async {
    final response = await orderAuditListWithHttpInfo(outletId, orderId, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'AuditPage',) as AuditPage;
    
    }
    return null;
  }

  /// Cancel unpaid draft; do not consume stock
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] orderId (required):
  ///
  /// * [OrderCancelRequest] orderCancelRequest (required):
  Future<Response> orderCancelWithHttpInfo(String outletId, String orderId, OrderCancelRequest orderCancelRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/orders/{orderId}/cancel'
      .replaceAll('{outletId}', outletId)
      .replaceAll('{orderId}', orderId);

    // ignore: prefer_final_locals
    Object? postBody = orderCancelRequest;

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

  /// Cancel unpaid draft; do not consume stock
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] orderId (required):
  ///
  /// * [OrderCancelRequest] orderCancelRequest (required):
  Future<void> orderCancel(String outletId, String orderId, OrderCancelRequest orderCancelRequest, { Future<void>? abortTrigger, }) async {
    final response = await orderCancelWithHttpInfo(outletId, orderId, orderCancelRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Create cashier draft order
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] idempotencyKey (required):
  ///   Persist before submission; same key and payload on retries. Scope is outlet and device for checkout.
  ///
  /// * [OrderWrite] orderWrite (required):
  Future<Response> orderCreateWithHttpInfo(String outletId, String idempotencyKey, OrderWrite orderWrite, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/orders'
      .replaceAll('{outletId}', outletId);

    // ignore: prefer_final_locals
    Object? postBody = orderWrite;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    headerParams[r'Idempotency-Key'] = parameterToString(idempotencyKey);

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

  /// Create cashier draft order
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] idempotencyKey (required):
  ///   Persist before submission; same key and payload on retries. Scope is outlet and device for checkout.
  ///
  /// * [OrderWrite] orderWrite (required):
  Future<Order?> orderCreate(String outletId, String idempotencyKey, OrderWrite orderWrite, { Future<void>? abortTrigger, }) async {
    final response = await orderCreateWithHttpInfo(outletId, idempotencyKey, orderWrite, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Order',) as Order;
    
    }
    return null;
  }

  /// Read one order and its table assignment
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] orderId (required):
  Future<Response> orderGetWithHttpInfo(String outletId, String orderId, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/orders/{orderId}'
      .replaceAll('{outletId}', outletId)
      .replaceAll('{orderId}', orderId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  /// Read one order and its table assignment
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] orderId (required):
  Future<Order?> orderGet(String outletId, String orderId, { Future<void>? abortTrigger, }) async {
    final response = await orderGetWithHttpInfo(outletId, orderId, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Order',) as Order;
    
    }
    return null;
  }

  /// List open draft orders with table state
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [int] limit:
  ///
  /// * [String] cursor:
  Future<Response> orderListOpenWithHttpInfo(String outletId, { int? limit, String? cursor, Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/orders'
      .replaceAll('{outletId}', outletId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (limit != null) {
      queryParams.addAll(_queryParams('', 'limit', limit));
    }
    if (cursor != null) {
      queryParams.addAll(_queryParams('', 'cursor', cursor));
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

  /// List open draft orders with table state
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [int] limit:
  ///
  /// * [String] cursor:
  Future<OrderPage?> orderListOpen(String outletId, { int? limit, String? cursor, Future<void>? abortTrigger, }) async {
    final response = await orderListOpenWithHttpInfo(outletId, limit: limit, cursor: cursor, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'OrderPage',) as OrderPage;
    
    }
    return null;
  }

  /// Create a 60-second immutable quote
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] orderId (required):
  ///
  /// * [OrderQuoteRequest] orderQuoteRequest (required):
  Future<Response> orderQuoteWithHttpInfo(String outletId, String orderId, OrderQuoteRequest orderQuoteRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/orders/{orderId}/quotes'
      .replaceAll('{outletId}', outletId)
      .replaceAll('{orderId}', orderId);

    // ignore: prefer_final_locals
    Object? postBody = orderQuoteRequest;

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

  /// Create a 60-second immutable quote
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] orderId (required):
  ///
  /// * [OrderQuoteRequest] orderQuoteRequest (required):
  Future<Quote?> orderQuote(String outletId, String orderId, OrderQuoteRequest orderQuoteRequest, { Future<void>? abortTrigger, }) async {
    final response = await orderQuoteWithHttpInfo(outletId, orderId, orderQuoteRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Quote',) as Quote;
    
    }
    return null;
  }

  /// Split a draft order into independently settled bills
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] orderId (required):
  ///
  /// * [String] idempotencyKey (required):
  ///   Persist before submission; same key and payload on retries.
  ///
  /// * [SplitWrite] splitWrite (required):
  Future<Response> orderSplitWithHttpInfo(String outletId, String orderId, String idempotencyKey, SplitWrite splitWrite, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/orders/{orderId}/splits'
      .replaceAll('{outletId}', outletId)
      .replaceAll('{orderId}', orderId);

    // ignore: prefer_final_locals
    Object? postBody = splitWrite;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    headerParams[r'Idempotency-Key'] = parameterToString(idempotencyKey);

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

  /// Split a draft order into independently settled bills
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] orderId (required):
  ///
  /// * [String] idempotencyKey (required):
  ///   Persist before submission; same key and payload on retries.
  ///
  /// * [SplitWrite] splitWrite (required):
  Future<SplitResult?> orderSplit(String outletId, String orderId, String idempotencyKey, SplitWrite splitWrite, { Future<void>? abortTrigger, }) async {
    final response = await orderSplitWithHttpInfo(outletId, orderId, idempotencyKey, splitWrite, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'SplitResult',) as SplitResult;
    
    }
    return null;
  }

  /// Transfer a table order to another table (owner only)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] orderId (required):
  ///
  /// * [TransferWrite] transferWrite (required):
  Future<Response> orderTransferWithHttpInfo(String outletId, String orderId, TransferWrite transferWrite, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/orders/{orderId}/transfer'
      .replaceAll('{outletId}', outletId)
      .replaceAll('{orderId}', orderId);

    // ignore: prefer_final_locals
    Object? postBody = transferWrite;

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

  /// Transfer a table order to another table (owner only)
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] orderId (required):
  ///
  /// * [TransferWrite] transferWrite (required):
  Future<Order?> orderTransfer(String outletId, String orderId, TransferWrite transferWrite, { Future<void>? abortTrigger, }) async {
    final response = await orderTransferWithHttpInfo(outletId, orderId, transferWrite, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Order',) as Order;
    
    }
    return null;
  }

  /// Replace draft lines with revision check
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] orderId (required):
  ///
  /// * [OrderUpdate] orderUpdate (required):
  Future<Response> orderUpdateWithHttpInfo(String outletId, String orderId, OrderUpdate orderUpdate, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/orders/{orderId}'
      .replaceAll('{outletId}', outletId)
      .replaceAll('{orderId}', orderId);

    // ignore: prefer_final_locals
    Object? postBody = orderUpdate;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'PUT',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Replace draft lines with revision check
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] orderId (required):
  ///
  /// * [OrderUpdate] orderUpdate (required):
  Future<Order?> orderUpdate(String outletId, String orderId, OrderUpdate orderUpdate, { Future<void>? abortTrigger, }) async {
    final response = await orderUpdateWithHttpInfo(outletId, orderId, orderUpdate, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Order',) as Order;
    
    }
    return null;
  }
}
