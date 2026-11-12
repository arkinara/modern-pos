# modern_pos_api_client.api.CatalogApi

## Load the API package
```dart
import 'package:modern_pos_api_client/api.dart';
```

All URIs are relative to */v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**catalogArchive**](CatalogApi.md#catalogarchive) | **POST** /outlets/{outletId}/menu/{menuId}/archive | Archive menu and preserve history
[**catalogCategories**](CatalogApi.md#catalogcategories) | **GET** /outlets/{outletId}/categories | List categories
[**catalogCreate**](CatalogApi.md#catalogcreate) | **POST** /outlets/{outletId}/menu | Create menu with variants
[**catalogCreateCategory**](CatalogApi.md#catalogcreatecategory) | **POST** /outlets/{outletId}/categories | Create category
[**catalogList**](CatalogApi.md#cataloglist) | **GET** /outlets/{outletId}/menu | Search catalog with advisory availability
[**catalogUpdate**](CatalogApi.md#catalogupdate) | **PATCH** /outlets/{outletId}/menu/{menuId} | Update menu using revision
[**catalogUpdateVariant**](CatalogApi.md#catalogupdatevariant) | **PATCH** /outlets/{outletId}/variants/{variantId} | Update price and stock policy
[**modifiersCreate**](CatalogApi.md#modifierscreate) | **POST** /outlets/{outletId}/modifiers | Create an item modifier
[**modifiersList**](CatalogApi.md#modifierslist) | **GET** /outlets/{outletId}/modifiers | List item modifiers visible to the outlet


# **catalogArchive**
> catalogArchive(outletId, menuId, catalogArchiveRequest)

Archive menu and preserve history

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = CatalogApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final menuId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final catalogArchiveRequest = CatalogArchiveRequest(); // CatalogArchiveRequest | 

try {
    api_instance.catalogArchive(outletId, menuId, catalogArchiveRequest);
} catch (e) {
    print('Exception when calling CatalogApi->catalogArchive: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **menuId** | **String**|  | 
 **catalogArchiveRequest** | [**CatalogArchiveRequest**](CatalogArchiveRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **catalogCategories**
> List<Category> catalogCategories(outletId)

List categories

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = CatalogApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.catalogCategories(outletId);
    print(result);
} catch (e) {
    print('Exception when calling CatalogApi->catalogCategories: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 

### Return type

[**List<Category>**](Category.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **catalogCreate**
> Menu catalogCreate(outletId, menuWrite)

Create menu with variants

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = CatalogApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final menuWrite = MenuWrite(); // MenuWrite | 

try {
    final result = api_instance.catalogCreate(outletId, menuWrite);
    print(result);
} catch (e) {
    print('Exception when calling CatalogApi->catalogCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **menuWrite** | [**MenuWrite**](MenuWrite.md)|  | 

### Return type

[**Menu**](Menu.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **catalogCreateCategory**
> Category catalogCreateCategory(outletId, categoryWrite)

Create category

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = CatalogApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final categoryWrite = CategoryWrite(); // CategoryWrite | 

try {
    final result = api_instance.catalogCreateCategory(outletId, categoryWrite);
    print(result);
} catch (e) {
    print('Exception when calling CatalogApi->catalogCreateCategory: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **categoryWrite** | [**CategoryWrite**](CategoryWrite.md)|  | 

### Return type

[**Category**](Category.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **catalogList**
> MenuPage catalogList(outletId, cursor, limit, search)

Search catalog with advisory availability

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = CatalogApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final cursor = cursor_example; // String | 
final limit = 56; // int | 
final search = search_example; // String | 

try {
    final result = api_instance.catalogList(outletId, cursor, limit, search);
    print(result);
} catch (e) {
    print('Exception when calling CatalogApi->catalogList: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **cursor** | **String**|  | [optional] 
 **limit** | **int**|  | [optional] [default to 25]
 **search** | **String**|  | [optional] 

### Return type

[**MenuPage**](MenuPage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **catalogUpdate**
> Menu catalogUpdate(outletId, menuId, menuUpdate)

Update menu using revision

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = CatalogApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final menuId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final menuUpdate = MenuUpdate(); // MenuUpdate | 

try {
    final result = api_instance.catalogUpdate(outletId, menuId, menuUpdate);
    print(result);
} catch (e) {
    print('Exception when calling CatalogApi->catalogUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **menuId** | **String**|  | 
 **menuUpdate** | [**MenuUpdate**](MenuUpdate.md)|  | 

### Return type

[**Menu**](Menu.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **catalogUpdateVariant**
> Variant catalogUpdateVariant(outletId, variantId, variantUpdate)

Update price and stock policy

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = CatalogApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final variantId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final variantUpdate = VariantUpdate(); // VariantUpdate | 

try {
    final result = api_instance.catalogUpdateVariant(outletId, variantId, variantUpdate);
    print(result);
} catch (e) {
    print('Exception when calling CatalogApi->catalogUpdateVariant: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **variantId** | **String**|  | 
 **variantUpdate** | [**VariantUpdate**](VariantUpdate.md)|  | 

### Return type

[**Variant**](Variant.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **modifiersCreate**
> Modifier modifiersCreate(outletId, modifierWrite)

Create an item modifier

A modifier changes the unit price and may consume one stock item per selected modifier quantity.

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = CatalogApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final modifierWrite = ModifierWrite(); // ModifierWrite | 

try {
    final result = api_instance.modifiersCreate(outletId, modifierWrite);
    print(result);
} catch (e) {
    print('Exception when calling CatalogApi->modifiersCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **modifierWrite** | [**ModifierWrite**](ModifierWrite.md)|  | 

### Return type

[**Modifier**](Modifier.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **modifiersList**
> List<Modifier> modifiersList(outletId)

List item modifiers visible to the outlet

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = CatalogApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.modifiersList(outletId);
    print(result);
} catch (e) {
    print('Exception when calling CatalogApi->modifiersList: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 

### Return type

[**List<Modifier>**](Modifier.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

