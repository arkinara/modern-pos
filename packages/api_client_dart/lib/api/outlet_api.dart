//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class OutletApi {
  OutletApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Read authorized outlet configuration
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  Future<Response> outletGetWithHttpInfo(String outletId, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}'
      .replaceAll('{outletId}', outletId);

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

  /// Read authorized outlet configuration
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  Future<Outlet?> outletGet(String outletId, { Future<void>? abortTrigger, }) async {
    final response = await outletGetWithHttpInfo(outletId, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Outlet',) as Outlet;
    
    }
    return null;
  }

  /// Update outlet settings
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [OutletUpdate] outletUpdate (required):
  Future<Response> outletUpdateWithHttpInfo(String outletId, OutletUpdate outletUpdate, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}'
      .replaceAll('{outletId}', outletId);

    // ignore: prefer_final_locals
    Object? postBody = outletUpdate;

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

  /// Update outlet settings
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [OutletUpdate] outletUpdate (required):
  Future<Outlet?> outletUpdate(String outletId, OutletUpdate outletUpdate, { Future<void>? abortTrigger, }) async {
    final response = await outletUpdateWithHttpInfo(outletId, outletUpdate, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Outlet',) as Outlet;
    
    }
    return null;
  }
}
