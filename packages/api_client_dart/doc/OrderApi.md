# modern_pos_api_client.api.OrderApi

## Load the API package
```dart
import 'package:modern_pos_api_client/api.dart';
```

All URIs are relative to */v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**orderCancel**](OrderApi.md#ordercancel) | **POST** /outlets/{outletId}/orders/{orderId}/cancel | Cancel unpaid draft; do not consume stock
[**orderCreate**](OrderApi.md#ordercreate) | **POST** /outlets/{outletId}/orders | Create cashier draft order
[**orderQuote**](OrderApi.md#orderquote) | **POST** /outlets/{outletId}/orders/{orderId}/quotes | Create a 60-second immutable quote
[**orderUpdate**](OrderApi.md#orderupdate) | **PUT** /outlets/{outletId}/orders/{orderId} | Replace draft lines with revision check


# **orderCancel**
> orderCancel(outletId, orderId, orderCancelRequest)

Cancel unpaid draft; do not consume stock

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = OrderApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final orderId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final orderCancelRequest = OrderCancelRequest(); // OrderCancelRequest | 

try {
    api_instance.orderCancel(outletId, orderId, orderCancelRequest);
} catch (e) {
    print('Exception when calling OrderApi->orderCancel: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **orderId** | **String**|  | 
 **orderCancelRequest** | [**OrderCancelRequest**](OrderCancelRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **orderCreate**
> Order orderCreate(outletId, idempotencyKey, orderWrite)

Create cashier draft order

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = OrderApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final idempotencyKey = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Persist before submission; same key and payload on retries. Scope is outlet and device for checkout.
final orderWrite = OrderWrite(); // OrderWrite | 

try {
    final result = api_instance.orderCreate(outletId, idempotencyKey, orderWrite);
    print(result);
} catch (e) {
    print('Exception when calling OrderApi->orderCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **idempotencyKey** | **String**| Persist before submission; same key and payload on retries. Scope is outlet and device for checkout. | 
 **orderWrite** | [**OrderWrite**](OrderWrite.md)|  | 

### Return type

[**Order**](Order.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **orderQuote**
> Quote orderQuote(outletId, orderId, orderQuoteRequest)

Create a 60-second immutable quote

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = OrderApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final orderId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final orderQuoteRequest = OrderQuoteRequest(); // OrderQuoteRequest | 

try {
    final result = api_instance.orderQuote(outletId, orderId, orderQuoteRequest);
    print(result);
} catch (e) {
    print('Exception when calling OrderApi->orderQuote: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **orderId** | **String**|  | 
 **orderQuoteRequest** | [**OrderQuoteRequest**](OrderQuoteRequest.md)|  | 

### Return type

[**Quote**](Quote.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **orderUpdate**
> Order orderUpdate(outletId, orderId, orderUpdate)

Replace draft lines with revision check

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = OrderApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final orderId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final orderUpdate = OrderUpdate(); // OrderUpdate | 

try {
    final result = api_instance.orderUpdate(outletId, orderId, orderUpdate);
    print(result);
} catch (e) {
    print('Exception when calling OrderApi->orderUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **orderId** | **String**|  | 
 **orderUpdate** | [**OrderUpdate**](OrderUpdate.md)|  | 

### Return type

[**Order**](Order.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

