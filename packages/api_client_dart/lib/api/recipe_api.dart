//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class RecipeApi {
  RecipeApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Read active recipe
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] variantId (required):
  Future<Response> recipeGetWithHttpInfo(String outletId, String variantId, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/variants/{variantId}/recipe'
      .replaceAll('{outletId}', outletId)
      .replaceAll('{variantId}', variantId);

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

  /// Read active recipe
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] variantId (required):
  Future<Recipe?> recipeGet(String outletId, String variantId, { Future<void>? abortTrigger, }) async {
    final response = await recipeGetWithHttpInfo(outletId, variantId, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Recipe',) as Recipe;
    
    }
    return null;
  }

  /// Publish a new recipe version
  ///
  /// expectedVersion=0 for first recipe. Positive base-unit quantities; no incompatible units. Historical versions are immutable.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] variantId (required):
  ///
  /// * [RecipeWrite] recipeWrite (required):
  Future<Response> recipePublishWithHttpInfo(String outletId, String variantId, RecipeWrite recipeWrite, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/variants/{variantId}/recipe'
      .replaceAll('{outletId}', outletId)
      .replaceAll('{variantId}', variantId);

    // ignore: prefer_final_locals
    Object? postBody = recipeWrite;

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

  /// Publish a new recipe version
  ///
  /// expectedVersion=0 for first recipe. Positive base-unit quantities; no incompatible units. Historical versions are immutable.
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] variantId (required):
  ///
  /// * [RecipeWrite] recipeWrite (required):
  Future<Recipe?> recipePublish(String outletId, String variantId, RecipeWrite recipeWrite, { Future<void>? abortTrigger, }) async {
    final response = await recipePublishWithHttpInfo(outletId, variantId, recipeWrite, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Recipe',) as Recipe;
    
    }
    return null;
  }
}
