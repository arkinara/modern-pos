# modern_pos_api_client.api.OrderingApi

## Load the API package
```dart
import 'package:modern_pos_api_client/api.dart';
```

All URIs are relative to */v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**channelOrderAccept**](OrderingApi.md#channelorderaccept) | **POST** /outlets/{outletId}/channel-orders/{orderId}/accept | Accept a received order and consume stock once
[**channelOrderCancel**](OrderingApi.md#channelordercancel) | **POST** /outlets/{outletId}/channel-orders/{orderId}/cancel | Cancel an order and restore stock when it was accepted
[**channelOrderCreateManual**](OrderingApi.md#channelordercreatemanual) | **POST** /outlets/{outletId}/channel-orders | Create a manual or phone channel order
[**channelOrderFulfill**](OrderingApi.md#channelorderfulfill) | **POST** /outlets/{outletId}/channel-orders/{orderId}/fulfill | Fulfil an accepted cash-on-pickup order and record one payment
[**channelOrderGet**](OrderingApi.md#channelorderget) | **GET** /outlets/{outletId}/channel-orders/{orderId} | Read one channel order
[**channelOrdersList**](OrderingApi.md#channelorderslist) | **GET** /outlets/{outletId}/channel-orders | List incoming channel orders
[**channelWebhookReceive**](OrderingApi.md#channelwebhookreceive) | **POST** /channels/{channel}/orders | Receive a signed, replay-protected channel order
[**channelsList**](OrderingApi.md#channelslist) | **GET** /outlets/{outletId}/channels | List supported ordering channels and availability


# **channelOrderAccept**
> ChannelOrder channelOrderAccept(outletId, orderId)

Accept a received order and consume stock once

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = OrderingApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final orderId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.channelOrderAccept(outletId, orderId);
    print(result);
} catch (e) {
    print('Exception when calling OrderingApi->channelOrderAccept: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **orderId** | **String**|  | 

### Return type

[**ChannelOrder**](ChannelOrder.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **channelOrderCancel**
> ChannelOrder channelOrderCancel(outletId, orderId, channelOrderCancelWrite)

Cancel an order and restore stock when it was accepted

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = OrderingApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final orderId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final channelOrderCancelWrite = ChannelOrderCancelWrite(); // ChannelOrderCancelWrite | 

try {
    final result = api_instance.channelOrderCancel(outletId, orderId, channelOrderCancelWrite);
    print(result);
} catch (e) {
    print('Exception when calling OrderingApi->channelOrderCancel: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **orderId** | **String**|  | 
 **channelOrderCancelWrite** | [**ChannelOrderCancelWrite**](ChannelOrderCancelWrite.md)|  | 

### Return type

[**ChannelOrder**](ChannelOrder.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **channelOrderCreateManual**
> ChannelOrderCreateResult channelOrderCreateManual(outletId, channelOrderManualWrite)

Create a manual or phone channel order

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = OrderingApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final channelOrderManualWrite = ChannelOrderManualWrite(); // ChannelOrderManualWrite | 

try {
    final result = api_instance.channelOrderCreateManual(outletId, channelOrderManualWrite);
    print(result);
} catch (e) {
    print('Exception when calling OrderingApi->channelOrderCreateManual: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **channelOrderManualWrite** | [**ChannelOrderManualWrite**](ChannelOrderManualWrite.md)|  | 

### Return type

[**ChannelOrderCreateResult**](ChannelOrderCreateResult.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **channelOrderFulfill**
> ChannelOrder channelOrderFulfill(outletId, orderId, channelOrderFulfillWrite)

Fulfil an accepted cash-on-pickup order and record one payment

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = OrderingApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final orderId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final channelOrderFulfillWrite = ChannelOrderFulfillWrite(); // ChannelOrderFulfillWrite | 

try {
    final result = api_instance.channelOrderFulfill(outletId, orderId, channelOrderFulfillWrite);
    print(result);
} catch (e) {
    print('Exception when calling OrderingApi->channelOrderFulfill: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **orderId** | **String**|  | 
 **channelOrderFulfillWrite** | [**ChannelOrderFulfillWrite**](ChannelOrderFulfillWrite.md)|  | 

### Return type

[**ChannelOrder**](ChannelOrder.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **channelOrderGet**
> ChannelOrder channelOrderGet(outletId, orderId)

Read one channel order

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = OrderingApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final orderId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.channelOrderGet(outletId, orderId);
    print(result);
} catch (e) {
    print('Exception when calling OrderingApi->channelOrderGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **orderId** | **String**|  | 

### Return type

[**ChannelOrder**](ChannelOrder.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **channelOrdersList**
> ChannelOrderList channelOrdersList(outletId, state, channel, search, limit)

List incoming channel orders

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = OrderingApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final state = state_example; // String | 
final channel = channel_example; // String | 
final search = search_example; // String | 
final limit = 56; // int | 

try {
    final result = api_instance.channelOrdersList(outletId, state, channel, search, limit);
    print(result);
} catch (e) {
    print('Exception when calling OrderingApi->channelOrdersList: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **state** | **String**|  | [optional] 
 **channel** | **String**|  | [optional] 
 **search** | **String**|  | [optional] 
 **limit** | **int**|  | [optional] [default to 50]

### Return type

[**ChannelOrderList**](ChannelOrderList.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **channelWebhookReceive**
> ChannelOrderCreateResult channelWebhookReceive(channel, xChannelSignature, channelOrderWebhookWrite)

Receive a signed, replay-protected channel order

The web channel is available with CHANNEL_WEBHOOK_SECRET. GrabFood and ShopeeFood return CHANNEL_PENDING_CREDENTIALS.

### Example
```dart
import 'package:modern_pos_api_client/api.dart';

final api_instance = OrderingApi();
final channel = channel_example; // String | 
final xChannelSignature = xChannelSignature_example; // String | Format t=<unix-seconds>,v1=<hex HMAC-SHA256 of t + \".\" + raw body>.
final channelOrderWebhookWrite = ChannelOrderWebhookWrite(); // ChannelOrderWebhookWrite | 

try {
    final result = api_instance.channelWebhookReceive(channel, xChannelSignature, channelOrderWebhookWrite);
    print(result);
} catch (e) {
    print('Exception when calling OrderingApi->channelWebhookReceive: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **channel** | **String**|  | 
 **xChannelSignature** | **String**| Format t=<unix-seconds>,v1=<hex HMAC-SHA256 of t + \".\" + raw body>. | 
 **channelOrderWebhookWrite** | [**ChannelOrderWebhookWrite**](ChannelOrderWebhookWrite.md)|  | 

### Return type

[**ChannelOrderCreateResult**](ChannelOrderCreateResult.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **channelsList**
> ChannelList channelsList(outletId)

List supported ordering channels and availability

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = OrderingApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.channelsList(outletId);
    print(result);
} catch (e) {
    print('Exception when calling OrderingApi->channelsList: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 

### Return type

[**ChannelList**](ChannelList.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

