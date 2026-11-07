//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class StockApi {
  StockApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Adjust stock with reason and balance version
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
  /// * [Adjustment] adjustment (required):
  Future<Response> stockAdjustWithHttpInfo(String outletId, String idempotencyKey, Adjustment adjustment, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/stock/adjustments'
      .replaceAll('{outletId}', outletId);

    // ignore: prefer_final_locals
    Object? postBody = adjustment;

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

  /// Adjust stock with reason and balance version
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] idempotencyKey (required):
  ///   Persist before submission; same key and payload on retries. Scope is outlet and device for checkout.
  ///
  /// * [Adjustment] adjustment (required):
  Future<Movement?> stockAdjust(String outletId, String idempotencyKey, Adjustment adjustment, { Future<void>? abortTrigger, }) async {
    final response = await stockAdjustWithHttpInfo(outletId, idempotencyKey, adjustment, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Movement',) as Movement;
    
    }
    return null;
  }

  /// Create stock item
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [StockWrite] stockWrite (required):
  Future<Response> stockCreateWithHttpInfo(String outletId, StockWrite stockWrite, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/stock'
      .replaceAll('{outletId}', outletId);

    // ignore: prefer_final_locals
    Object? postBody = stockWrite;

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

  /// Create stock item
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [StockWrite] stockWrite (required):
  Future<Stock?> stockCreate(String outletId, StockWrite stockWrite, { Future<void>? abortTrigger, }) async {
    final response = await stockCreateWithHttpInfo(outletId, stockWrite, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Stock',) as Stock;
    
    }
    return null;
  }

  /// Search stock balances
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
  ///
  /// * [String] search:
  Future<Response> stockListWithHttpInfo(String outletId, { String? cursor, int? limit, String? search, Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/stock'
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
    if (search != null) {
      queryParams.addAll(_queryParams('', 'search', search));
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

  /// Search stock balances
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] cursor:
  ///
  /// * [int] limit:
  ///
  /// * [String] search:
  Future<StockPage?> stockList(String outletId, { String? cursor, int? limit, String? search, Future<void>? abortTrigger, }) async {
    final response = await stockListWithHttpInfo(outletId, cursor: cursor, limit: limit, search: search, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'StockPage',) as StockPage;
    
    }
    return null;
  }

  /// Read append-only stock ledger
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] stockItemId (required):
  ///
  /// * [String] cursor:
  ///
  /// * [int] limit:
  Future<Response> stockMovementsWithHttpInfo(String outletId, String stockItemId, { String? cursor, int? limit, Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/stock/{stockItemId}/movements'
      .replaceAll('{outletId}', outletId)
      .replaceAll('{stockItemId}', stockItemId);

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

  /// Read append-only stock ledger
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] stockItemId (required):
  ///
  /// * [String] cursor:
  ///
  /// * [int] limit:
  Future<MovementPage?> stockMovements(String outletId, String stockItemId, { String? cursor, int? limit, Future<void>? abortTrigger, }) async {
    final response = await stockMovementsWithHttpInfo(outletId, stockItemId, cursor: cursor, limit: limit, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'MovementPage',) as MovementPage;
    
    }
    return null;
  }

  /// Record one opening balance
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
  /// * [StockChange] stockChange (required):
  Future<Response> stockOpeningWithHttpInfo(String outletId, String idempotencyKey, StockChange stockChange, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/stock/opening-balances'
      .replaceAll('{outletId}', outletId);

    // ignore: prefer_final_locals
    Object? postBody = stockChange;

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

  /// Record one opening balance
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] idempotencyKey (required):
  ///   Persist before submission; same key and payload on retries. Scope is outlet and device for checkout.
  ///
  /// * [StockChange] stockChange (required):
  Future<Movement?> stockOpening(String outletId, String idempotencyKey, StockChange stockChange, { Future<void>? abortTrigger, }) async {
    final response = await stockOpeningWithHttpInfo(outletId, idempotencyKey, stockChange, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Movement',) as Movement;
    
    }
    return null;
  }

  /// Receive positive stock quantity
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
  /// * [StockChange] stockChange (required):
  Future<Response> stockReceiptWithHttpInfo(String outletId, String idempotencyKey, StockChange stockChange, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/stock/receipts'
      .replaceAll('{outletId}', outletId);

    // ignore: prefer_final_locals
    Object? postBody = stockChange;

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

  /// Receive positive stock quantity
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] idempotencyKey (required):
  ///   Persist before submission; same key and payload on retries. Scope is outlet and device for checkout.
  ///
  /// * [StockChange] stockChange (required):
  Future<Movement?> stockReceipt(String outletId, String idempotencyKey, StockChange stockChange, { Future<void>? abortTrigger, }) async {
    final response = await stockReceiptWithHttpInfo(outletId, idempotencyKey, stockChange, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Movement',) as Movement;
    
    }
    return null;
  }
}
