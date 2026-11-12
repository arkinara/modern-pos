//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class PromotionsApi {
  PromotionsApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Create an outlet promotion
  ///
  /// Eligibility, stacking and rounding are enforced by the server. The outlet scope is the request outlet.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [PromotionWrite] promotionWrite (required):
  Future<Response> promotionsCreateWithHttpInfo(String outletId, PromotionWrite promotionWrite, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/promotions'
      .replaceAll('{outletId}', outletId);

    // ignore: prefer_final_locals
    Object? postBody = promotionWrite;

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

  /// Create an outlet promotion
  ///
  /// Eligibility, stacking and rounding are enforced by the server. The outlet scope is the request outlet.
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [PromotionWrite] promotionWrite (required):
  Future<Promotion?> promotionsCreate(String outletId, PromotionWrite promotionWrite, { Future<void>? abortTrigger, }) async {
    final response = await promotionsCreateWithHttpInfo(outletId, promotionWrite, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Promotion',) as Promotion;
    
    }
    return null;
  }

  /// List promotions visible to the outlet
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  Future<Response> promotionsListWithHttpInfo(String outletId, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/promotions'
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

  /// List promotions visible to the outlet
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  Future<List<Promotion>?> promotionsList(String outletId, { Future<void>? abortTrigger, }) async {
    final response = await promotionsListWithHttpInfo(outletId, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<Promotion>') as List)
        .cast<Promotion>()
        .toList(growable: false);

    }
    return null;
  }

  /// Update a promotion with optimistic revision
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] promotionId (required):
  ///
  /// * [PromotionUpdate] promotionUpdate (required):
  Future<Response> promotionsUpdateWithHttpInfo(String outletId, String promotionId, PromotionUpdate promotionUpdate, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/promotions/{promotionId}'
      .replaceAll('{outletId}', outletId)
      .replaceAll('{promotionId}', promotionId);

    // ignore: prefer_final_locals
    Object? postBody = promotionUpdate;

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

  /// Update a promotion with optimistic revision
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] promotionId (required):
  ///
  /// * [PromotionUpdate] promotionUpdate (required):
  Future<Promotion?> promotionsUpdate(String outletId, String promotionId, PromotionUpdate promotionUpdate, { Future<void>? abortTrigger, }) async {
    final response = await promotionsUpdateWithHttpInfo(outletId, promotionId, promotionUpdate, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Promotion',) as Promotion;
    
    }
    return null;
  }
}
