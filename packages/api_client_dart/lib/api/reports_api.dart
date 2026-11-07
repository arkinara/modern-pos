//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class ReportsApi {
  ReportsApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Read reconciled local-date report
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [DateTime] from (required):
  ///   Inclusive outlet-local date. Maximum 366-day range.
  ///
  /// * [DateTime] to (required):
  ///   Inclusive outlet-local date. Maximum 366-day range.
  Future<Response> reportsDailyWithHttpInfo(String outletId, DateTime from, DateTime to, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/reports/daily'
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

  /// Read reconciled local-date report
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [DateTime] from (required):
  ///   Inclusive outlet-local date. Maximum 366-day range.
  ///
  /// * [DateTime] to (required):
  ///   Inclusive outlet-local date. Maximum 366-day range.
  Future<DailyReport?> reportsDaily(String outletId, DateTime from, DateTime to, { Future<void>? abortTrigger, }) async {
    final response = await reportsDailyWithHttpInfo(outletId, from, to, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'DailyReport',) as DailyReport;
    
    }
    return null;
  }

  /// Export filtered sales
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [DateTime] from (required):
  ///   Inclusive outlet-local date. Maximum 366-day range.
  ///
  /// * [DateTime] to (required):
  ///   Inclusive outlet-local date. Maximum 366-day range.
  Future<Response> reportsExportWithHttpInfo(String outletId, DateTime from, DateTime to, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/reports/sales.csv'
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

  /// Export filtered sales
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [DateTime] from (required):
  ///   Inclusive outlet-local date. Maximum 366-day range.
  ///
  /// * [DateTime] to (required):
  ///   Inclusive outlet-local date. Maximum 366-day range.
  Future<String?> reportsExport(String outletId, DateTime from, DateTime to, { Future<void>? abortTrigger, }) async {
    final response = await reportsExportWithHttpInfo(outletId, from, to, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'String',) as String;
    
    }
    return null;
  }
}
