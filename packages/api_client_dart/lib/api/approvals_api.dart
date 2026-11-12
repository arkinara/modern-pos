//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class ApprovalsApi {
  ApprovalsApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// List configured approval thresholds
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  Future<Response> approvalRulesListWithHttpInfo(String outletId, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/approval-rules'
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

  /// List configured approval thresholds
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  Future<List<ApprovalRule>?> approvalRulesList(String outletId, { Future<void>? abortTrigger, }) async {
    final response = await approvalRulesListWithHttpInfo(outletId, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<ApprovalRule>') as List)
        .cast<ApprovalRule>()
        .toList(growable: false);

    }
    return null;
  }

  /// Create or replace an approval threshold
  ///
  /// Owner always passes. A non-owner passes only when the amount is at or below the active threshold.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] action (required):
  ///
  /// * [ApprovalRuleWrite] approvalRuleWrite (required):
  Future<Response> approvalRulesUpsertWithHttpInfo(String outletId, String action, ApprovalRuleWrite approvalRuleWrite, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/approval-rules/{action}'
      .replaceAll('{outletId}', outletId)
      .replaceAll('{action}', action);

    // ignore: prefer_final_locals
    Object? postBody = approvalRuleWrite;

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

  /// Create or replace an approval threshold
  ///
  /// Owner always passes. A non-owner passes only when the amount is at or below the active threshold.
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] action (required):
  ///
  /// * [ApprovalRuleWrite] approvalRuleWrite (required):
  Future<ApprovalRule?> approvalRulesUpsert(String outletId, String action, ApprovalRuleWrite approvalRuleWrite, { Future<void>? abortTrigger, }) async {
    final response = await approvalRulesUpsertWithHttpInfo(outletId, action, approvalRuleWrite, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ApprovalRule',) as ApprovalRule;
    
    }
    return null;
  }
}
