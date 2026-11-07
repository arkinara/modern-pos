# modern_pos_api_client.api.PrintingApi

## Load the API package
```dart
import 'package:modern_pos_api_client/api.dart';
```

All URIs are relative to */v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**printingCreate**](PrintingApi.md#printingcreate) | **POST** /outlets/{outletId}/printers | Save verified-model printer configuration
[**printingJob**](PrintingApi.md#printingjob) | **POST** /outlets/{outletId}/print-jobs | Mirror local receipt job metadata
[**printingList**](PrintingApi.md#printinglist) | **GET** /outlets/{outletId}/printers | Read device-owned printer configuration
[**printingState**](PrintingApi.md#printingstate) | **PATCH** /outlets/{outletId}/print-jobs/{jobId} | Update owned job delivery status
[**printingUpdate**](PrintingApi.md#printingupdate) | **PUT** /outlets/{outletId}/printers/{printerId} | Update printer config with revision


# **printingCreate**
> Printer printingCreate(outletId, printerWrite)

Save verified-model printer configuration

Hardware support is verified per model/transport; declared enum values do not imply all transports are shipped.

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = PrintingApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final printerWrite = PrinterWrite(); // PrinterWrite | 

try {
    final result = api_instance.printingCreate(outletId, printerWrite);
    print(result);
} catch (e) {
    print('Exception when calling PrintingApi->printingCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **printerWrite** | [**PrinterWrite**](PrinterWrite.md)|  | 

### Return type

[**Printer**](Printer.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **printingJob**
> PrintJob printingJob(outletId, idempotencyKey, printJobWrite)

Mirror local receipt job metadata

The local durable queue owns execution; API failure cannot roll back the sale or erase its local job. Server enforces device ownership.

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = PrintingApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final idempotencyKey = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Persist before submission; same key and payload on retries. Scope is outlet and device for checkout.
final printJobWrite = PrintJobWrite(); // PrintJobWrite | 

try {
    final result = api_instance.printingJob(outletId, idempotencyKey, printJobWrite);
    print(result);
} catch (e) {
    print('Exception when calling PrintingApi->printingJob: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **idempotencyKey** | **String**| Persist before submission; same key and payload on retries. Scope is outlet and device for checkout. | 
 **printJobWrite** | [**PrintJobWrite**](PrintJobWrite.md)|  | 

### Return type

[**PrintJob**](PrintJob.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **printingList**
> List<Printer> printingList(outletId, deviceId)

Read device-owned printer configuration

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = PrintingApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final deviceId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.printingList(outletId, deviceId);
    print(result);
} catch (e) {
    print('Exception when calling PrintingApi->printingList: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **deviceId** | **String**|  | 

### Return type

[**List<Printer>**](Printer.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **printingState**
> PrintJob printingState(outletId, jobId, printingStateRequest)

Update owned job delivery status

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = PrintingApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final jobId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final printingStateRequest = PrintingStateRequest(); // PrintingStateRequest | 

try {
    final result = api_instance.printingState(outletId, jobId, printingStateRequest);
    print(result);
} catch (e) {
    print('Exception when calling PrintingApi->printingState: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **jobId** | **String**|  | 
 **printingStateRequest** | [**PrintingStateRequest**](PrintingStateRequest.md)|  | 

### Return type

[**PrintJob**](PrintJob.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **printingUpdate**
> Printer printingUpdate(outletId, printerId, printingUpdateRequest)

Update printer config with revision

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = PrintingApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final printerId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final printingUpdateRequest = PrintingUpdateRequest(); // PrintingUpdateRequest | 

try {
    final result = api_instance.printingUpdate(outletId, printerId, printingUpdateRequest);
    print(result);
} catch (e) {
    print('Exception when calling PrintingApi->printingUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **printerId** | **String**|  | 
 **printingUpdateRequest** | [**PrintingUpdateRequest**](PrintingUpdateRequest.md)|  | 

### Return type

[**Printer**](Printer.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

