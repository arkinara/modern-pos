# modern_pos_api_client.api.AuthApi

## Load the API package
```dart
import 'package:modern_pos_api_client/api.dart';
```

All URIs are relative to */v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**authLogout**](AuthApi.md#authlogout) | **POST** /auth/logout | Revoke the current session
[**authMe**](AuthApi.md#authme) | **GET** /auth/me | Read active user and memberships
[**authMobileLogin**](AuthApi.md#authmobilelogin) | **POST** /auth/mobile/login | Sign in Android device
[**authMobileRefresh**](AuthApi.md#authmobilerefresh) | **POST** /auth/mobile/refresh | Rotate mobile refresh token
[**authWebLogin**](AuthApi.md#authweblogin) | **POST** /auth/web/login | Sign in web owner session
[**authWebRefresh**](AuthApi.md#authwebrefresh) | **POST** /auth/web/refresh | Rotate cookie-backed web session


# **authLogout**
> authLogout()

Revoke the current session

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AuthApi();

try {
    api_instance.authLogout();
} catch (e) {
    print('Exception when calling AuthApi->authLogout: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authMe**
> User authMe()

Read active user and memberships

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AuthApi();

try {
    final result = api_instance.authMe();
    print(result);
} catch (e) {
    print('Exception when calling AuthApi->authMe: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**User**](User.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authMobileLogin**
> MobileSession authMobileLogin(login)

Sign in Android device

### Example
```dart
import 'package:modern_pos_api_client/api.dart';

final api_instance = AuthApi();
final login = Login(); // Login | 

try {
    final result = api_instance.authMobileLogin(login);
    print(result);
} catch (e) {
    print('Exception when calling AuthApi->authMobileLogin: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **login** | [**Login**](Login.md)|  | 

### Return type

[**MobileSession**](MobileSession.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authMobileRefresh**
> MobileSession authMobileRefresh(authMobileRefreshRequest)

Rotate mobile refresh token

### Example
```dart
import 'package:modern_pos_api_client/api.dart';

final api_instance = AuthApi();
final authMobileRefreshRequest = AuthMobileRefreshRequest(); // AuthMobileRefreshRequest | 

try {
    final result = api_instance.authMobileRefresh(authMobileRefreshRequest);
    print(result);
} catch (e) {
    print('Exception when calling AuthApi->authMobileRefresh: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **authMobileRefreshRequest** | [**AuthMobileRefreshRequest**](AuthMobileRefreshRequest.md)|  | 

### Return type

[**MobileSession**](MobileSession.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authWebLogin**
> WebSession authWebLogin(authWebLoginRequest)

Sign in web owner session

Sets HttpOnly Secure SameSite=Lax refresh cookie; access token is held in memory. Same-origin/CSRF protections apply.

### Example
```dart
import 'package:modern_pos_api_client/api.dart';

final api_instance = AuthApi();
final authWebLoginRequest = AuthWebLoginRequest(); // AuthWebLoginRequest | 

try {
    final result = api_instance.authWebLogin(authWebLoginRequest);
    print(result);
} catch (e) {
    print('Exception when calling AuthApi->authWebLogin: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **authWebLoginRequest** | [**AuthWebLoginRequest**](AuthWebLoginRequest.md)|  | 

### Return type

[**WebSession**](WebSession.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authWebRefresh**
> WebSession authWebRefresh(xCSRFToken)

Rotate cookie-backed web session

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure API key authorization: refreshCookie
//defaultApiClient.getAuthentication<ApiKeyAuth>('refreshCookie').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('refreshCookie').apiKeyPrefix = 'Bearer';

final api_instance = AuthApi();
final xCSRFToken = xCSRFToken_example; // String | 

try {
    final result = api_instance.authWebRefresh(xCSRFToken);
    print(result);
} catch (e) {
    print('Exception when calling AuthApi->authWebRefresh: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xCSRFToken** | **String**|  | 

### Return type

[**WebSession**](WebSession.md)

### Authorization

[refreshCookie](../README.md#refreshCookie)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

