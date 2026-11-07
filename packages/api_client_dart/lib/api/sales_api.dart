//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class SalesApi {
  SalesApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Commit sale, payment record, stock, and recovery mapping
  ///
  /// Cash amount must equal quoted total; tender >= amount. Manual external amount equals total, no tender/change. Replay existing keys before checking expired quotes. All writes are one serializable transaction. No provider charge is made.
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
  /// * [Finalize] finalize (required):
  Future<Response> salesFinalizeWithHttpInfo(String outletId, String idempotencyKey, Finalize finalize, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/sales/finalize'
      .replaceAll('{outletId}', outletId);

    // ignore: prefer_final_locals
    Object? postBody = finalize;

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

  /// Commit sale, payment record, stock, and recovery mapping
  ///
  /// Cash amount must equal quoted total; tender >= amount. Manual external amount equals total, no tender/change. Replay existing keys before checking expired quotes. All writes are one serializable transaction. No provider charge is made.
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] idempotencyKey (required):
  ///   Persist before submission; same key and payload on retries. Scope is outlet and device for checkout.
  ///
  /// * [Finalize] finalize (required):
  Future<Finalized?> salesFinalize(String outletId, String idempotencyKey, Finalize finalize, { Future<void>? abortTrigger, }) async {
    final response = await salesFinalizeWithHttpInfo(outletId, idempotencyKey, finalize, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Finalized',) as Finalized;
    
    }
    return null;
  }

  /// Read immutable receipt data
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] saleId (required):
  Future<Response> salesGetWithHttpInfo(String outletId, String saleId, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/sales/{saleId}'
      .replaceAll('{outletId}', outletId)
      .replaceAll('{saleId}', saleId);

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

  /// Read immutable receipt data
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] saleId (required):
  Future<Sale?> salesGet(String outletId, String saleId, { Future<void>? abortTrigger, }) async {
    final response = await salesGetWithHttpInfo(outletId, saleId, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Sale',) as Sale;
    
    }
    return null;
  }

  /// List sales; cashiers see only authorized own sales
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
  /// * [DateTime] from:
  ///
  /// * [DateTime] to:
  Future<Response> salesListWithHttpInfo(String outletId, { String? cursor, int? limit, DateTime? from, DateTime? to, Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/sales'
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
    if (from != null) {
      queryParams.addAll(_queryParams('', 'from', from));
    }
    if (to != null) {
      queryParams.addAll(_queryParams('', 'to', to));
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

  /// List sales; cashiers see only authorized own sales
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] cursor:
  ///
  /// * [int] limit:
  ///
  /// * [DateTime] from:
  ///
  /// * [DateTime] to:
  Future<SalePage?> salesList(String outletId, { String? cursor, int? limit, DateTime? from, DateTime? to, Future<void>? abortTrigger, }) async {
    final response = await salesListWithHttpInfo(outletId, cursor: cursor, limit: limit, from: from, to: to, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'SalePage',) as SalePage;
    
    }
    return null;
  }

  /// Resolve uncertain checkout by original key
  ///
  /// 404 does not prove an original request cannot still commit. Retain/resubmit the same key; never auto-create a new key.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] key (required):
  ///
  /// * [String] deviceId (required):
  Future<Response> salesRecoverWithHttpInfo(String outletId, String key, String deviceId, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/checkout-requests/{key}'
      .replaceAll('{outletId}', outletId)
      .replaceAll('{key}', key);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

      queryParams.addAll(_queryParams('', 'deviceId', deviceId));

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

  /// Resolve uncertain checkout by original key
  ///
  /// 404 does not prove an original request cannot still commit. Retain/resubmit the same key; never auto-create a new key.
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] key (required):
  ///
  /// * [String] deviceId (required):
  Future<Finalized?> salesRecover(String outletId, String key, String deviceId, { Future<void>? abortTrigger, }) async {
    final response = await salesRecoverWithHttpInfo(outletId, key, deviceId, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Finalized',) as Finalized;
    
    }
    return null;
  }

  /// Record full owner reversal and explicit restock
  ///
  /// One reversal per sale; validate restock <= original consumed amount. Does not return money through any external provider.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] saleId (required):
  ///
  /// * [String] idempotencyKey (required):
  ///   Persist before submission; same key and payload on retries. Scope is outlet and device for checkout.
  ///
  /// * [ReversalWrite] reversalWrite (required):
  Future<Response> salesReverseWithHttpInfo(String outletId, String saleId, String idempotencyKey, ReversalWrite reversalWrite, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/sales/{saleId}/reversals'
      .replaceAll('{outletId}', outletId)
      .replaceAll('{saleId}', saleId);

    // ignore: prefer_final_locals
    Object? postBody = reversalWrite;

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

  /// Record full owner reversal and explicit restock
  ///
  /// One reversal per sale; validate restock <= original consumed amount. Does not return money through any external provider.
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] saleId (required):
  ///
  /// * [String] idempotencyKey (required):
  ///   Persist before submission; same key and payload on retries. Scope is outlet and device for checkout.
  ///
  /// * [ReversalWrite] reversalWrite (required):
  Future<Reversal?> salesReverse(String outletId, String saleId, String idempotencyKey, ReversalWrite reversalWrite, { Future<void>? abortTrigger, }) async {
    final response = await salesReverseWithHttpInfo(outletId, saleId, idempotencyKey, reversalWrite, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Reversal',) as Reversal;
    
    }
    return null;
  }
}
