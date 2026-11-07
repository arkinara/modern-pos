//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class SettingsApi {
  SettingsApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Read business and outlet settings
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  Future<Response> settingsGetWithHttpInfo(String outletId, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/settings'
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

  /// Read business and outlet settings
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  Future<Settings?> settingsGet(String outletId, { Future<void>? abortTrigger, }) async {
    final response = await settingsGetWithHttpInfo(outletId, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Settings',) as Settings;
    
    }
    return null;
  }

  /// Update business and outlet settings
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [SettingsUpdate] settingsUpdate (required):
  Future<Response> settingsUpdateWithHttpInfo(String outletId, SettingsUpdate settingsUpdate, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/settings'
      .replaceAll('{outletId}', outletId);

    // ignore: prefer_final_locals
    Object? postBody = settingsUpdate;

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

  /// Update business and outlet settings
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [SettingsUpdate] settingsUpdate (required):
  Future<Settings?> settingsUpdate(String outletId, SettingsUpdate settingsUpdate, { Future<void>? abortTrigger, }) async {
    final response = await settingsUpdateWithHttpInfo(outletId, settingsUpdate, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Settings',) as Settings;
    
    }
    return null;
  }
}
