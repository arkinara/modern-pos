//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class ShiftsApi {
  ShiftsApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Record a paid-in or paid-out on an open shift
  ///
  /// Paid-out above the active CASH_OUT approval threshold requires an owner and returns 403 APPROVAL_REQUIRED.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] shiftId (required):
  ///
  /// * [ShiftCashMovementWrite] shiftCashMovementWrite (required):
  Future<Response> shiftsCashMovementWithHttpInfo(String outletId, String shiftId, ShiftCashMovementWrite shiftCashMovementWrite, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/shifts/{shiftId}/cash-movements'
      .replaceAll('{outletId}', outletId)
      .replaceAll('{shiftId}', shiftId);

    // ignore: prefer_final_locals
    Object? postBody = shiftCashMovementWrite;

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

  /// Record a paid-in or paid-out on an open shift
  ///
  /// Paid-out above the active CASH_OUT approval threshold requires an owner and returns 403 APPROVAL_REQUIRED.
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] shiftId (required):
  ///
  /// * [ShiftCashMovementWrite] shiftCashMovementWrite (required):
  Future<Shift?> shiftsCashMovement(String outletId, String shiftId, ShiftCashMovementWrite shiftCashMovementWrite, { Future<void>? abortTrigger, }) async {
    final response = await shiftsCashMovementWithHttpInfo(outletId, shiftId, shiftCashMovementWrite, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Shift',) as Shift;
    
    }
    return null;
  }

  /// Count the drawer and close the caller own shift
  ///
  /// Expected cash is opening float + cash tender sales + paid-ins - paid-outs. Closing a closed shift or someone else's shift returns 409.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] shiftId (required):
  ///
  /// * [ShiftCloseWrite] shiftCloseWrite (required):
  Future<Response> shiftsCloseWithHttpInfo(String outletId, String shiftId, ShiftCloseWrite shiftCloseWrite, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/shifts/{shiftId}/close'
      .replaceAll('{outletId}', outletId)
      .replaceAll('{shiftId}', shiftId);

    // ignore: prefer_final_locals
    Object? postBody = shiftCloseWrite;

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

  /// Count the drawer and close the caller own shift
  ///
  /// Expected cash is opening float + cash tender sales + paid-ins - paid-outs. Closing a closed shift or someone else's shift returns 409.
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] shiftId (required):
  ///
  /// * [ShiftCloseWrite] shiftCloseWrite (required):
  Future<Shift?> shiftsClose(String outletId, String shiftId, ShiftCloseWrite shiftCloseWrite, { Future<void>? abortTrigger, }) async {
    final response = await shiftsCloseWithHttpInfo(outletId, shiftId, shiftCloseWrite, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Shift',) as Shift;
    
    }
    return null;
  }

  /// Read one shift
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] shiftId (required):
  Future<Response> shiftsGetWithHttpInfo(String outletId, String shiftId, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/shifts/{shiftId}'
      .replaceAll('{outletId}', outletId)
      .replaceAll('{shiftId}', shiftId);

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

  /// Read one shift
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] shiftId (required):
  Future<Shift?> shiftsGet(String outletId, String shiftId, { Future<void>? abortTrigger, }) async {
    final response = await shiftsGetWithHttpInfo(outletId, shiftId, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Shift',) as Shift;
    
    }
    return null;
  }

  /// List cash shifts for an outlet
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] status:
  ///
  /// * [String] cursor:
  ///
  /// * [int] limit:
  Future<Response> shiftsListWithHttpInfo(String outletId, { String? status, String? cursor, int? limit, Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/shifts'
      .replaceAll('{outletId}', outletId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (status != null) {
      queryParams.addAll(_queryParams('', 'status', status));
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

  /// List cash shifts for an outlet
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] status:
  ///
  /// * [String] cursor:
  ///
  /// * [int] limit:
  Future<ShiftPage?> shiftsList(String outletId, { String? status, String? cursor, int? limit, Future<void>? abortTrigger, }) async {
    final response = await shiftsListWithHttpInfo(outletId, status: status, cursor: cursor, limit: limit, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ShiftPage',) as ShiftPage;
    
    }
    return null;
  }

  /// Open a shift with an opening float
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [ShiftWrite] shiftWrite (required):
  Future<Response> shiftsOpenWithHttpInfo(String outletId, ShiftWrite shiftWrite, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/shifts'
      .replaceAll('{outletId}', outletId);

    // ignore: prefer_final_locals
    Object? postBody = shiftWrite;

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

  /// Open a shift with an opening float
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [ShiftWrite] shiftWrite (required):
  Future<Shift?> shiftsOpen(String outletId, ShiftWrite shiftWrite, { Future<void>? abortTrigger, }) async {
    final response = await shiftsOpenWithHttpInfo(outletId, shiftWrite, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Shift',) as Shift;
    
    }
    return null;
  }

  /// Read the reconciled shift cash report (owner only)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] shiftId (required):
  Future<Response> shiftsReportWithHttpInfo(String outletId, String shiftId, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/shifts/{shiftId}/report'
      .replaceAll('{outletId}', outletId)
      .replaceAll('{shiftId}', shiftId);

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

  /// Read the reconciled shift cash report (owner only)
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] shiftId (required):
  Future<ShiftReport?> shiftsReport(String outletId, String shiftId, { Future<void>? abortTrigger, }) async {
    final response = await shiftsReportWithHttpInfo(outletId, shiftId, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ShiftReport',) as ShiftReport;
    
    }
    return null;
  }
}
