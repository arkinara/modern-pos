//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class AttendanceApi {
  AttendanceApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Clock in without opening a shift
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [AttendanceWrite] attendanceWrite:
  Future<Response> attendanceClockInWithHttpInfo(String outletId, { AttendanceWrite? attendanceWrite, Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/attendance/clock-in'
      .replaceAll('{outletId}', outletId);

    // ignore: prefer_final_locals
    Object? postBody = attendanceWrite;

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

  /// Clock in without opening a shift
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [AttendanceWrite] attendanceWrite:
  Future<AttendanceRecord?> attendanceClockIn(String outletId, { AttendanceWrite? attendanceWrite, Future<void>? abortTrigger, }) async {
    final response = await attendanceClockInWithHttpInfo(outletId, attendanceWrite: attendanceWrite, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'AttendanceRecord',) as AttendanceRecord;
    
    }
    return null;
  }

  /// Clock out without closing a shift
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [AttendanceWrite] attendanceWrite:
  Future<Response> attendanceClockOutWithHttpInfo(String outletId, { AttendanceWrite? attendanceWrite, Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/attendance/clock-out'
      .replaceAll('{outletId}', outletId);

    // ignore: prefer_final_locals
    Object? postBody = attendanceWrite;

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

  /// Clock out without closing a shift
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [AttendanceWrite] attendanceWrite:
  Future<AttendanceRecord?> attendanceClockOut(String outletId, { AttendanceWrite? attendanceWrite, Future<void>? abortTrigger, }) async {
    final response = await attendanceClockOutWithHttpInfo(outletId, attendanceWrite: attendanceWrite, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'AttendanceRecord',) as AttendanceRecord;
    
    }
    return null;
  }

  /// List attendance records
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] userId:
  ///
  /// * [DateTime] from:
  ///
  /// * [DateTime] to:
  ///
  /// * [String] cursor:
  ///
  /// * [int] limit:
  Future<Response> attendanceListWithHttpInfo(String outletId, { String? userId, DateTime? from, DateTime? to, String? cursor, int? limit, Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/attendance'
      .replaceAll('{outletId}', outletId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (userId != null) {
      queryParams.addAll(_queryParams('', 'userId', userId));
    }
    if (from != null) {
      queryParams.addAll(_queryParams('', 'from', from));
    }
    if (to != null) {
      queryParams.addAll(_queryParams('', 'to', to));
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

  /// List attendance records
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] userId:
  ///
  /// * [DateTime] from:
  ///
  /// * [DateTime] to:
  ///
  /// * [String] cursor:
  ///
  /// * [int] limit:
  Future<AttendancePage?> attendanceList(String outletId, { String? userId, DateTime? from, DateTime? to, String? cursor, int? limit, Future<void>? abortTrigger, }) async {
    final response = await attendanceListWithHttpInfo(outletId, userId: userId, from: from, to: to, cursor: cursor, limit: limit, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'AttendancePage',) as AttendancePage;
    
    }
    return null;
  }
}
