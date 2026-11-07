//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class PrintingApi {
  PrintingApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Save verified-model printer configuration
  ///
  /// Hardware support is verified per model/transport; declared enum values do not imply all transports are shipped.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [PrinterWrite] printerWrite (required):
  Future<Response> printingCreateWithHttpInfo(String outletId, PrinterWrite printerWrite, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/printers'
      .replaceAll('{outletId}', outletId);

    // ignore: prefer_final_locals
    Object? postBody = printerWrite;

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

  /// Save verified-model printer configuration
  ///
  /// Hardware support is verified per model/transport; declared enum values do not imply all transports are shipped.
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [PrinterWrite] printerWrite (required):
  Future<Printer?> printingCreate(String outletId, PrinterWrite printerWrite, { Future<void>? abortTrigger, }) async {
    final response = await printingCreateWithHttpInfo(outletId, printerWrite, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Printer',) as Printer;
    
    }
    return null;
  }

  /// Mirror local receipt job metadata
  ///
  /// The local durable queue owns execution; API failure cannot roll back the sale or erase its local job. Server enforces device ownership.
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
  /// * [PrintJobWrite] printJobWrite (required):
  Future<Response> printingJobWithHttpInfo(String outletId, String idempotencyKey, PrintJobWrite printJobWrite, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/print-jobs'
      .replaceAll('{outletId}', outletId);

    // ignore: prefer_final_locals
    Object? postBody = printJobWrite;

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

  /// Mirror local receipt job metadata
  ///
  /// The local durable queue owns execution; API failure cannot roll back the sale or erase its local job. Server enforces device ownership.
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] idempotencyKey (required):
  ///   Persist before submission; same key and payload on retries. Scope is outlet and device for checkout.
  ///
  /// * [PrintJobWrite] printJobWrite (required):
  Future<PrintJob?> printingJob(String outletId, String idempotencyKey, PrintJobWrite printJobWrite, { Future<void>? abortTrigger, }) async {
    final response = await printingJobWithHttpInfo(outletId, idempotencyKey, printJobWrite, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'PrintJob',) as PrintJob;
    
    }
    return null;
  }

  /// Read device-owned printer configuration
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] deviceId (required):
  Future<Response> printingListWithHttpInfo(String outletId, String deviceId, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/printers'
      .replaceAll('{outletId}', outletId);

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

  /// Read device-owned printer configuration
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] deviceId (required):
  Future<List<Printer>?> printingList(String outletId, String deviceId, { Future<void>? abortTrigger, }) async {
    final response = await printingListWithHttpInfo(outletId, deviceId, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<Printer>') as List)
        .cast<Printer>()
        .toList(growable: false);

    }
    return null;
  }

  /// Update owned job delivery status
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] jobId (required):
  ///
  /// * [PrintingStateRequest] printingStateRequest (required):
  Future<Response> printingStateWithHttpInfo(String outletId, String jobId, PrintingStateRequest printingStateRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/print-jobs/{jobId}'
      .replaceAll('{outletId}', outletId)
      .replaceAll('{jobId}', jobId);

    // ignore: prefer_final_locals
    Object? postBody = printingStateRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'PATCH',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Update owned job delivery status
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] jobId (required):
  ///
  /// * [PrintingStateRequest] printingStateRequest (required):
  Future<PrintJob?> printingState(String outletId, String jobId, PrintingStateRequest printingStateRequest, { Future<void>? abortTrigger, }) async {
    final response = await printingStateWithHttpInfo(outletId, jobId, printingStateRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'PrintJob',) as PrintJob;
    
    }
    return null;
  }

  /// Update printer config with revision
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] printerId (required):
  ///
  /// * [PrintingUpdateRequest] printingUpdateRequest (required):
  Future<Response> printingUpdateWithHttpInfo(String outletId, String printerId, PrintingUpdateRequest printingUpdateRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/printers/{printerId}'
      .replaceAll('{outletId}', outletId)
      .replaceAll('{printerId}', printerId);

    // ignore: prefer_final_locals
    Object? postBody = printingUpdateRequest;

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

  /// Update printer config with revision
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] printerId (required):
  ///
  /// * [PrintingUpdateRequest] printingUpdateRequest (required):
  Future<Printer?> printingUpdate(String outletId, String printerId, PrintingUpdateRequest printingUpdateRequest, { Future<void>? abortTrigger, }) async {
    final response = await printingUpdateWithHttpInfo(outletId, printerId, printingUpdateRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Printer',) as Printer;
    
    }
    return null;
  }
}
