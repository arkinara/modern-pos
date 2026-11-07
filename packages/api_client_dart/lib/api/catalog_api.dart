//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class CatalogApi {
  CatalogApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Archive menu and preserve history
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] menuId (required):
  ///
  /// * [CatalogArchiveRequest] catalogArchiveRequest (required):
  Future<Response> catalogArchiveWithHttpInfo(String outletId, String menuId, CatalogArchiveRequest catalogArchiveRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/menu/{menuId}/archive'
      .replaceAll('{outletId}', outletId)
      .replaceAll('{menuId}', menuId);

    // ignore: prefer_final_locals
    Object? postBody = catalogArchiveRequest;

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

  /// Archive menu and preserve history
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] menuId (required):
  ///
  /// * [CatalogArchiveRequest] catalogArchiveRequest (required):
  Future<void> catalogArchive(String outletId, String menuId, CatalogArchiveRequest catalogArchiveRequest, { Future<void>? abortTrigger, }) async {
    final response = await catalogArchiveWithHttpInfo(outletId, menuId, catalogArchiveRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// List categories
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  Future<Response> catalogCategoriesWithHttpInfo(String outletId, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/categories'
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

  /// List categories
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  Future<List<Category>?> catalogCategories(String outletId, { Future<void>? abortTrigger, }) async {
    final response = await catalogCategoriesWithHttpInfo(outletId, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<Category>') as List)
        .cast<Category>()
        .toList(growable: false);

    }
    return null;
  }

  /// Create menu with variants
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [MenuWrite] menuWrite (required):
  Future<Response> catalogCreateWithHttpInfo(String outletId, MenuWrite menuWrite, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/menu'
      .replaceAll('{outletId}', outletId);

    // ignore: prefer_final_locals
    Object? postBody = menuWrite;

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

  /// Create menu with variants
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [MenuWrite] menuWrite (required):
  Future<Menu?> catalogCreate(String outletId, MenuWrite menuWrite, { Future<void>? abortTrigger, }) async {
    final response = await catalogCreateWithHttpInfo(outletId, menuWrite, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Menu',) as Menu;
    
    }
    return null;
  }

  /// Create category
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [CategoryWrite] categoryWrite (required):
  Future<Response> catalogCreateCategoryWithHttpInfo(String outletId, CategoryWrite categoryWrite, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/categories'
      .replaceAll('{outletId}', outletId);

    // ignore: prefer_final_locals
    Object? postBody = categoryWrite;

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

  /// Create category
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [CategoryWrite] categoryWrite (required):
  Future<Category?> catalogCreateCategory(String outletId, CategoryWrite categoryWrite, { Future<void>? abortTrigger, }) async {
    final response = await catalogCreateCategoryWithHttpInfo(outletId, categoryWrite, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Category',) as Category;
    
    }
    return null;
  }

  /// Search catalog with advisory availability
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] cursor:
  ///
  /// * [int] limit:
  ///
  /// * [String] search:
  Future<Response> catalogListWithHttpInfo(String outletId, { String? cursor, int? limit, String? search, Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/menu'
      .replaceAll('{outletId}', outletId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (cursor != null) {
      queryParams.addAll(_queryParams('', 'cursor', cursor));
    }
    if (limit != null) {
      queryParams.addAll(_queryParams('', 'limit', limit));
    }
    if (search != null) {
      queryParams.addAll(_queryParams('', 'search', search));
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

  /// Search catalog with advisory availability
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] cursor:
  ///
  /// * [int] limit:
  ///
  /// * [String] search:
  Future<MenuPage?> catalogList(String outletId, { String? cursor, int? limit, String? search, Future<void>? abortTrigger, }) async {
    final response = await catalogListWithHttpInfo(outletId, cursor: cursor, limit: limit, search: search, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'MenuPage',) as MenuPage;
    
    }
    return null;
  }

  /// Update menu using revision
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] menuId (required):
  ///
  /// * [MenuUpdate] menuUpdate (required):
  Future<Response> catalogUpdateWithHttpInfo(String outletId, String menuId, MenuUpdate menuUpdate, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/menu/{menuId}'
      .replaceAll('{outletId}', outletId)
      .replaceAll('{menuId}', menuId);

    // ignore: prefer_final_locals
    Object? postBody = menuUpdate;

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

  /// Update menu using revision
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] menuId (required):
  ///
  /// * [MenuUpdate] menuUpdate (required):
  Future<Menu?> catalogUpdate(String outletId, String menuId, MenuUpdate menuUpdate, { Future<void>? abortTrigger, }) async {
    final response = await catalogUpdateWithHttpInfo(outletId, menuId, menuUpdate, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Menu',) as Menu;
    
    }
    return null;
  }

  /// Update price and stock policy
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] variantId (required):
  ///
  /// * [VariantUpdate] variantUpdate (required):
  Future<Response> catalogUpdateVariantWithHttpInfo(String outletId, String variantId, VariantUpdate variantUpdate, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/variants/{variantId}'
      .replaceAll('{outletId}', outletId)
      .replaceAll('{variantId}', variantId);

    // ignore: prefer_final_locals
    Object? postBody = variantUpdate;

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

  /// Update price and stock policy
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] variantId (required):
  ///
  /// * [VariantUpdate] variantUpdate (required):
  Future<Variant?> catalogUpdateVariant(String outletId, String variantId, VariantUpdate variantUpdate, { Future<void>? abortTrigger, }) async {
    final response = await catalogUpdateVariantWithHttpInfo(outletId, variantId, variantUpdate, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Variant',) as Variant;
    
    }
    return null;
  }
}
