//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class PaymentsApi {
  PaymentsApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Create or replay the provider payment intent for a completed online sale
  ///
  /// Idempotent per sale: repeated calls return the same online payment and provider reference. A failed intent is reset to pending for an explicit retry. No stock or sale is created here.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] saleId (required):
  Future<Response> paymentsCreateWithHttpInfo(String outletId, String saleId, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/sales/{saleId}/online-payment'
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
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Create or replay the provider payment intent for a completed online sale
  ///
  /// Idempotent per sale: repeated calls return the same online payment and provider reference. A failed intent is reset to pending for an explicit retry. No stock or sale is created here.
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] saleId (required):
  Future<OnlinePayment?> paymentsCreate(String outletId, String saleId, { Future<void>? abortTrigger, }) async {
    final response = await paymentsCreateWithHttpInfo(outletId, saleId, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'OnlinePayment',) as OnlinePayment;
    
    }
    return null;
  }

  /// Read the server-side online payment state
  ///
  /// The client resolves reconnect state from the server and never assumes failure or recharges.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] saleId (required):
  Future<Response> paymentsGetWithHttpInfo(String outletId, String saleId, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/sales/{saleId}/online-payment'
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

  /// Read the server-side online payment state
  ///
  /// The client resolves reconnect state from the server and never assumes failure or recharges.
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] saleId (required):
  Future<OnlinePayment?> paymentsGet(String outletId, String saleId, { Future<void>? abortTrigger, }) async {
    final response = await paymentsGetWithHttpInfo(outletId, saleId, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'OnlinePayment',) as OnlinePayment;
    
    }
    return null;
  }

  /// List online payments for the outlet
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [int] limit:
  Future<Response> paymentsListWithHttpInfo(String outletId, { int? limit, Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/online-payments'
      .replaceAll('{outletId}', outletId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  /// List online payments for the outlet
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [int] limit:
  Future<OnlinePaymentList?> paymentsList(String outletId, { int? limit, Future<void>? abortTrigger, }) async {
    final response = await paymentsListWithHttpInfo(outletId, limit: limit, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'OnlinePaymentList',) as OnlinePaymentList;
    
    }
    return null;
  }

  /// Compare pending local payments with the provider and repair drift
  ///
  /// Read-only toward the provider: fetches each pending provider payment and applies the reported state. It never creates a provider charge.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  Future<Response> paymentsReconcileWithHttpInfo(String outletId, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/online-payments/reconcile'
      .replaceAll('{outletId}', outletId);

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

  /// Compare pending local payments with the provider and repair drift
  ///
  /// Read-only toward the provider: fetches each pending provider payment and applies the reported state. It never creates a provider charge.
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  Future<ReconciliationSummary?> paymentsReconcile(String outletId, { Future<void>? abortTrigger, }) async {
    final response = await paymentsReconcileWithHttpInfo(outletId, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ReconciliationSummary',) as ReconciliationSummary;
    
    }
    return null;
  }

  /// Resolve provider state after a lost client connection
  ///
  /// Fetches the provider record and applies pending/succeeded/failed without creating a second payment or stock movement.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] saleId (required):
  Future<Response> paymentsRefreshWithHttpInfo(String outletId, String saleId, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/sales/{saleId}/online-payment/refresh'
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
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Resolve provider state after a lost client connection
  ///
  /// Fetches the provider record and applies pending/succeeded/failed without creating a second payment or stock movement.
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] saleId (required):
  Future<OnlinePayment?> paymentsRefresh(String outletId, String saleId, { Future<void>? abortTrigger, }) async {
    final response = await paymentsRefreshWithHttpInfo(outletId, saleId, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'OnlinePayment',) as OnlinePayment;
    
    }
    return null;
  }

  /// Daily and per-payment captured/refunded settlement report
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [DateTime] from (required):
  ///
  /// * [DateTime] to (required):
  Future<Response> paymentsSettlementsWithHttpInfo(String outletId, DateTime from, DateTime to, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/online-payments/settlements'
      .replaceAll('{outletId}', outletId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

      queryParams.addAll(_queryParams('', 'from', from));
      queryParams.addAll(_queryParams('', 'to', to));

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

  /// Daily and per-payment captured/refunded settlement report
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [DateTime] from (required):
  ///
  /// * [DateTime] to (required):
  Future<SettlementReport?> paymentsSettlements(String outletId, DateTime from, DateTime to, { Future<void>? abortTrigger, }) async {
    final response = await paymentsSettlementsWithHttpInfo(outletId, from, to, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'SettlementReport',) as SettlementReport;
    
    }
    return null;
  }

  /// Receive a signed, replay-protected provider webhook
  ///
  /// Public endpoint. Invalid signatures and timestamps outside the replay window are rejected before any state change. Provider event ids are unique per provider for concurrency-safe dedupe. A duplicate delivery is acknowledged with duplicate=true.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] xPaymentSignature (required):
  ///   Format t=<unix-seconds>,v1=<hex HMAC-SHA256 of t + \".\" + raw body>.
  Future<Response> paymentsWebhookWithHttpInfo(String xPaymentSignature, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/payments/webhook';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    headerParams[r'x-payment-signature'] = parameterToString(xPaymentSignature);

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

  /// Receive a signed, replay-protected provider webhook
  ///
  /// Public endpoint. Invalid signatures and timestamps outside the replay window are rejected before any state change. Provider event ids are unique per provider for concurrency-safe dedupe. A duplicate delivery is acknowledged with duplicate=true.
  ///
  /// Parameters:
  ///
  /// * [String] xPaymentSignature (required):
  ///   Format t=<unix-seconds>,v1=<hex HMAC-SHA256 of t + \".\" + raw body>.
  Future<WebhookAck?> paymentsWebhook(String xPaymentSignature, { Future<void>? abortTrigger, }) async {
    final response = await paymentsWebhookWithHttpInfo(xPaymentSignature, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'WebhookAck',) as WebhookAck;
    
    }
    return null;
  }
}
