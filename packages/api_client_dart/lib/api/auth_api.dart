//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class AuthApi {
  AuthApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Revoke the current session
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> authLogoutWithHttpInfo({ Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/auth/logout';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


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

  /// Revoke the current session
  Future<void> authLogout({ Future<void>? abortTrigger, }) async {
    final response = await authLogoutWithHttpInfo(abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Read active user and memberships
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> authMeWithHttpInfo({ Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/auth/me';

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

  /// Read active user and memberships
  Future<User?> authMe({ Future<void>? abortTrigger, }) async {
    final response = await authMeWithHttpInfo(abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'User',) as User;
    
    }
    return null;
  }

  /// Sign in Android device
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [Login] login (required):
  Future<Response> authMobileLoginWithHttpInfo(Login login, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/auth/mobile/login';

    // ignore: prefer_final_locals
    Object? postBody = login;

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

  /// Sign in Android device
  ///
  /// Parameters:
  ///
  /// * [Login] login (required):
  Future<MobileSession?> authMobileLogin(Login login, { Future<void>? abortTrigger, }) async {
    final response = await authMobileLoginWithHttpInfo(login, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'MobileSession',) as MobileSession;
    
    }
    return null;
  }

  /// Rotate mobile refresh token
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [AuthMobileRefreshRequest] authMobileRefreshRequest (required):
  Future<Response> authMobileRefreshWithHttpInfo(AuthMobileRefreshRequest authMobileRefreshRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/auth/mobile/refresh';

    // ignore: prefer_final_locals
    Object? postBody = authMobileRefreshRequest;

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

  /// Rotate mobile refresh token
  ///
  /// Parameters:
  ///
  /// * [AuthMobileRefreshRequest] authMobileRefreshRequest (required):
  Future<MobileSession?> authMobileRefresh(AuthMobileRefreshRequest authMobileRefreshRequest, { Future<void>? abortTrigger, }) async {
    final response = await authMobileRefreshWithHttpInfo(authMobileRefreshRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'MobileSession',) as MobileSession;
    
    }
    return null;
  }

  /// Sign in web owner session
  ///
  /// Sets HttpOnly Secure SameSite=Lax refresh cookie; access token is held in memory. Same-origin/CSRF protections apply.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [AuthWebLoginRequest] authWebLoginRequest (required):
  Future<Response> authWebLoginWithHttpInfo(AuthWebLoginRequest authWebLoginRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/auth/web/login';

    // ignore: prefer_final_locals
    Object? postBody = authWebLoginRequest;

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

  /// Sign in web owner session
  ///
  /// Sets HttpOnly Secure SameSite=Lax refresh cookie; access token is held in memory. Same-origin/CSRF protections apply.
  ///
  /// Parameters:
  ///
  /// * [AuthWebLoginRequest] authWebLoginRequest (required):
  Future<WebSession?> authWebLogin(AuthWebLoginRequest authWebLoginRequest, { Future<void>? abortTrigger, }) async {
    final response = await authWebLoginWithHttpInfo(authWebLoginRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'WebSession',) as WebSession;
    
    }
    return null;
  }

  /// Rotate cookie-backed web session
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] xCSRFToken (required):
  Future<Response> authWebRefreshWithHttpInfo(String xCSRFToken, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/auth/web/refresh';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    headerParams[r'X-CSRF-Token'] = parameterToString(xCSRFToken);

    const contentTypes = <String>[];


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

  /// Rotate cookie-backed web session
  ///
  /// Parameters:
  ///
  /// * [String] xCSRFToken (required):
  Future<WebSession?> authWebRefresh(String xCSRFToken, { Future<void>? abortTrigger, }) async {
    final response = await authWebRefreshWithHttpInfo(xCSRFToken, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'WebSession',) as WebSession;
    
    }
    return null;
  }
}
