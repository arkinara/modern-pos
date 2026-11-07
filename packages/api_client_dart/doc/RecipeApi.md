# modern_pos_api_client.api.RecipeApi

## Load the API package
```dart
import 'package:modern_pos_api_client/api.dart';
```

All URIs are relative to */v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**recipeGet**](RecipeApi.md#recipeget) | **GET** /outlets/{outletId}/variants/{variantId}/recipe | Read active recipe
[**recipePublish**](RecipeApi.md#recipepublish) | **PUT** /outlets/{outletId}/variants/{variantId}/recipe | Publish a new recipe version


# **recipeGet**
> Recipe recipeGet(outletId, variantId)

Read active recipe

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = RecipeApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final variantId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.recipeGet(outletId, variantId);
    print(result);
} catch (e) {
    print('Exception when calling RecipeApi->recipeGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **variantId** | **String**|  | 

### Return type

[**Recipe**](Recipe.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **recipePublish**
> Recipe recipePublish(outletId, variantId, recipeWrite)

Publish a new recipe version

expectedVersion=0 for first recipe. Positive base-unit quantities; no incompatible units. Historical versions are immutable.

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = RecipeApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final variantId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final recipeWrite = RecipeWrite(); // RecipeWrite | 

try {
    final result = api_instance.recipePublish(outletId, variantId, recipeWrite);
    print(result);
} catch (e) {
    print('Exception when calling RecipeApi->recipePublish: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **variantId** | **String**|  | 
 **recipeWrite** | [**RecipeWrite**](RecipeWrite.md)|  | 

### Return type

[**Recipe**](Recipe.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

