# modern_pos_api_client.api.PromotionsApi

## Load the API package
```dart
import 'package:modern_pos_api_client/api.dart';
```

All URIs are relative to */v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**promotionsCreate**](PromotionsApi.md#promotionscreate) | **POST** /outlets/{outletId}/promotions | Create an outlet promotion
[**promotionsList**](PromotionsApi.md#promotionslist) | **GET** /outlets/{outletId}/promotions | List promotions visible to the outlet
[**promotionsUpdate**](PromotionsApi.md#promotionsupdate) | **PATCH** /outlets/{outletId}/promotions/{promotionId} | Update a promotion with optimistic revision


# **promotionsCreate**
> Promotion promotionsCreate(outletId, promotionWrite)

Create an outlet promotion

Eligibility, stacking and rounding are enforced by the server. The outlet scope is the request outlet.

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = PromotionsApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final promotionWrite = PromotionWrite(); // PromotionWrite | 

try {
    final result = api_instance.promotionsCreate(outletId, promotionWrite);
    print(result);
} catch (e) {
    print('Exception when calling PromotionsApi->promotionsCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **promotionWrite** | [**PromotionWrite**](PromotionWrite.md)|  | 

### Return type

[**Promotion**](Promotion.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **promotionsList**
> List<Promotion> promotionsList(outletId)

List promotions visible to the outlet

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = PromotionsApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.promotionsList(outletId);
    print(result);
} catch (e) {
    print('Exception when calling PromotionsApi->promotionsList: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 

### Return type

[**List<Promotion>**](Promotion.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **promotionsUpdate**
> Promotion promotionsUpdate(outletId, promotionId, promotionUpdate)

Update a promotion with optimistic revision

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = PromotionsApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final promotionId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final promotionUpdate = PromotionUpdate(); // PromotionUpdate | 

try {
    final result = api_instance.promotionsUpdate(outletId, promotionId, promotionUpdate);
    print(result);
} catch (e) {
    print('Exception when calling PromotionsApi->promotionsUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **promotionId** | **String**|  | 
 **promotionUpdate** | [**PromotionUpdate**](PromotionUpdate.md)|  | 

### Return type

[**Promotion**](Promotion.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

