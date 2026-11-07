# modern_pos_api_client.api.DeviceApi

## Load the API package
```dart
import 'package:modern_pos_api_client/api.dart';
```

All URIs are relative to */v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**deviceCreate**](DeviceApi.md#devicecreate) | **POST** /outlets/{outletId}/devices | Register cashier device


# **deviceCreate**
> Device deviceCreate(outletId, deviceCreateRequest)

Register cashier device

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = DeviceApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final deviceCreateRequest = DeviceCreateRequest(); // DeviceCreateRequest | 

try {
    final result = api_instance.deviceCreate(outletId, deviceCreateRequest);
    print(result);
} catch (e) {
    print('Exception when calling DeviceApi->deviceCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **deviceCreateRequest** | [**DeviceCreateRequest**](DeviceCreateRequest.md)|  | 

### Return type

[**Device**](Device.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

