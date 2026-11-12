//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class SandboxApi {
  SandboxApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Create a deterministic local sandbox provider payment
  ///
  /// Local sandbox only; disabled unless PAYMENT_PROVIDER=mock. It performs no real provider call.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [SandboxPaymentWrite] sandboxPaymentWrite (required):
  Future<Response> sandboxPaymentCreateWithHttpInfo(SandboxPaymentWrite sandboxPaymentWrite, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/sandbox/provider/payments';

    // ignore: prefer_final_locals
    Object? postBody = sandboxPaymentWrite;

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

  /// Create a deterministic local sandbox provider payment
  ///
  /// Local sandbox only; disabled unless PAYMENT_PROVIDER=mock. It performs no real provider call.
  ///
  /// Parameters:
  ///
  /// * [SandboxPaymentWrite] sandboxPaymentWrite (required):
  Future<SandboxPayment?> sandboxPaymentCreate(SandboxPaymentWrite sandboxPaymentWrite, { Future<void>? abortTrigger, }) async {
    final response = await sandboxPaymentCreateWithHttpInfo(sandboxPaymentWrite, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'SandboxPayment',) as SandboxPayment;
    
    }
    return null;
  }

  /// Advance the sandbox ledger and issue a correctly signed webhook event
  ///
  /// Returns the signed event body for the caller to deliver. Reuse the same event id to exercise duplicate delivery; send succeeded before pending to exercise out-of-order delivery.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] providerRef (required):
  ///
  /// * [SandboxEventWrite] sandboxEventWrite (required):
  Future<Response> sandboxPaymentEventWithHttpInfo(String providerRef, SandboxEventWrite sandboxEventWrite, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/sandbox/provider/payments/{providerRef}/events'
      .replaceAll('{providerRef}', providerRef);

    // ignore: prefer_final_locals
    Object? postBody = sandboxEventWrite;

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

  /// Advance the sandbox ledger and issue a correctly signed webhook event
  ///
  /// Returns the signed event body for the caller to deliver. Reuse the same event id to exercise duplicate delivery; send succeeded before pending to exercise out-of-order delivery.
  ///
  /// Parameters:
  ///
  /// * [String] providerRef (required):
  ///
  /// * [SandboxEventWrite] sandboxEventWrite (required):
  Future<SandboxEventResult?> sandboxPaymentEvent(String providerRef, SandboxEventWrite sandboxEventWrite, { Future<void>? abortTrigger, }) async {
    final response = await sandboxPaymentEventWithHttpInfo(providerRef, sandboxEventWrite, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'SandboxEventResult',) as SandboxEventResult;
    
    }
    return null;
  }

  /// Read a local sandbox provider payment
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] providerRef (required):
  Future<Response> sandboxPaymentGetWithHttpInfo(String providerRef, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/sandbox/provider/payments/{providerRef}'
      .replaceAll('{providerRef}', providerRef);

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

  /// Read a local sandbox provider payment
  ///
  /// Parameters:
  ///
  /// * [String] providerRef (required):
  Future<SandboxPayment?> sandboxPaymentGet(String providerRef, { Future<void>? abortTrigger, }) async {
    final response = await sandboxPaymentGetWithHttpInfo(providerRef, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'SandboxPayment',) as SandboxPayment;
    
    }
    return null;
  }
}
