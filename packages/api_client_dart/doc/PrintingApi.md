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
[**printingList**](PrintingApi.md#printinglist) | **GET** /outlets/{outletId}/printers | Read printer configuration; owners may list every outlet printer
[**printingState**](PrintingApi.md#printingstate) | **PATCH** /outlets/{outletId}/print-jobs/{jobId} | Update owned job delivery status
[**printingUpdate**](PrintingApi.md#printingupdate) | **PUT** /outlets/{outletId}/printers/{printerId} | Update printer config with revision
[**stationJobsCreate**](PrintingApi.md#stationjobscreate) | **POST** /outlets/{outletId}/orders/{orderId}/station-jobs | Dispatch original, amendment or cancellation station jobs
[**stationJobsList**](PrintingApi.md#stationjobslist) | **GET** /outlets/{outletId}/stations/{stationId}/jobs | List one station queue independently
[**stationJobsReprint**](PrintingApi.md#stationjobsreprint) | **POST** /outlets/{outletId}/station-jobs/{jobId}/reprints | Create an independent station job reprint copy
[**stationJobsRetry**](PrintingApi.md#stationjobsretry) | **POST** /outlets/{outletId}/station-jobs/{jobId}/retry | Requeue a failed or uncertain station job
[**stationJobsUpdateState**](PrintingApi.md#stationjobsupdatestate) | **PATCH** /outlets/{outletId}/station-jobs/{jobId} | Update station job delivery state
[**stationRoutingList**](PrintingApi.md#stationroutinglist) | **GET** /outlets/{outletId}/station-routing | List menu item to station routing
[**stationRoutingReplace**](PrintingApi.md#stationroutingreplace) | **PUT** /outlets/{outletId}/station-routing | Replace menu item to station routing for an outlet
[**stationsCreate**](PrintingApi.md#stationscreate) | **POST** /outlets/{outletId}/stations | Create an owner-managed station
[**stationsList**](PrintingApi.md#stationslist) | **GET** /outlets/{outletId}/stations | List kitchen/bar stations for an outlet
[**stationsUpdate**](PrintingApi.md#stationsupdate) | **PUT** /outlets/{outletId}/stations/{stationId} | Update a station with optimistic revision


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

Read printer configuration; owners may list every outlet printer

A deviceId scopes the read to that device. An owner may omit deviceId to read every printer configuration in the outlet. Returns non-secret metadata only.

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
final deviceId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Device-owned printer scope. Required for cashiers; optional for owners.

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
 **deviceId** | **String**| Device-owned printer scope. Required for cashiers; optional for owners. | [optional] 

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

# **stationJobsCreate**
> List<StationJob> stationJobsCreate(outletId, orderId, idempotencyKey, stationJobWrite)

Dispatch original, amendment or cancellation station jobs

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
final orderId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final idempotencyKey = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final stationJobWrite = StationJobWrite(); // StationJobWrite | 

try {
    final result = api_instance.stationJobsCreate(outletId, orderId, idempotencyKey, stationJobWrite);
    print(result);
} catch (e) {
    print('Exception when calling PrintingApi->stationJobsCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **orderId** | **String**|  | 
 **idempotencyKey** | **String**|  | 
 **stationJobWrite** | [**StationJobWrite**](StationJobWrite.md)|  | 

### Return type

[**List<StationJob>**](StationJob.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **stationJobsList**
> StationJobPage stationJobsList(outletId, stationId, state, cursor, limit)

List one station queue independently

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
final stationId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final state = state_example; // String | 
final cursor = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final limit = 56; // int | 

try {
    final result = api_instance.stationJobsList(outletId, stationId, state, cursor, limit);
    print(result);
} catch (e) {
    print('Exception when calling PrintingApi->stationJobsList: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **stationId** | **String**|  | 
 **state** | **String**|  | [optional] 
 **cursor** | **String**|  | [optional] 
 **limit** | **int**|  | [optional] 

### Return type

[**StationJobPage**](StationJobPage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **stationJobsReprint**
> StationJob stationJobsReprint(outletId, jobId, idempotencyKey)

Create an independent station job reprint copy

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
final idempotencyKey = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.stationJobsReprint(outletId, jobId, idempotencyKey);
    print(result);
} catch (e) {
    print('Exception when calling PrintingApi->stationJobsReprint: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **jobId** | **String**|  | 
 **idempotencyKey** | **String**|  | 

### Return type

[**StationJob**](StationJob.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **stationJobsRetry**
> StationJob stationJobsRetry(outletId, jobId)

Requeue a failed or uncertain station job

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

try {
    final result = api_instance.stationJobsRetry(outletId, jobId);
    print(result);
} catch (e) {
    print('Exception when calling PrintingApi->stationJobsRetry: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **jobId** | **String**|  | 

### Return type

[**StationJob**](StationJob.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **stationJobsUpdateState**
> StationJob stationJobsUpdateState(outletId, jobId, stationJobStateWrite)

Update station job delivery state

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
final stationJobStateWrite = StationJobStateWrite(); // StationJobStateWrite | 

try {
    final result = api_instance.stationJobsUpdateState(outletId, jobId, stationJobStateWrite);
    print(result);
} catch (e) {
    print('Exception when calling PrintingApi->stationJobsUpdateState: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **jobId** | **String**|  | 
 **stationJobStateWrite** | [**StationJobStateWrite**](StationJobStateWrite.md)|  | 

### Return type

[**StationJob**](StationJob.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **stationRoutingList**
> List<StationRoute> stationRoutingList(outletId)

List menu item to station routing

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

try {
    final result = api_instance.stationRoutingList(outletId);
    print(result);
} catch (e) {
    print('Exception when calling PrintingApi->stationRoutingList: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 

### Return type

[**List<StationRoute>**](StationRoute.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **stationRoutingReplace**
> List<StationRoute> stationRoutingReplace(outletId, stationRoutingWrite)

Replace menu item to station routing for an outlet

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
final stationRoutingWrite = StationRoutingWrite(); // StationRoutingWrite | 

try {
    final result = api_instance.stationRoutingReplace(outletId, stationRoutingWrite);
    print(result);
} catch (e) {
    print('Exception when calling PrintingApi->stationRoutingReplace: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **stationRoutingWrite** | [**StationRoutingWrite**](StationRoutingWrite.md)|  | 

### Return type

[**List<StationRoute>**](StationRoute.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **stationsCreate**
> Station stationsCreate(outletId, stationWrite)

Create an owner-managed station

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
final stationWrite = StationWrite(); // StationWrite | 

try {
    final result = api_instance.stationsCreate(outletId, stationWrite);
    print(result);
} catch (e) {
    print('Exception when calling PrintingApi->stationsCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **stationWrite** | [**StationWrite**](StationWrite.md)|  | 

### Return type

[**Station**](Station.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **stationsList**
> List<Station> stationsList(outletId)

List kitchen/bar stations for an outlet

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

try {
    final result = api_instance.stationsList(outletId);
    print(result);
} catch (e) {
    print('Exception when calling PrintingApi->stationsList: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 

### Return type

[**List<Station>**](Station.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **stationsUpdate**
> Station stationsUpdate(outletId, stationId, stationUpdate)

Update a station with optimistic revision

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
final stationId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final stationUpdate = StationUpdate(); // StationUpdate | 

try {
    final result = api_instance.stationsUpdate(outletId, stationId, stationUpdate);
    print(result);
} catch (e) {
    print('Exception when calling PrintingApi->stationsUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **stationId** | **String**|  | 
 **stationUpdate** | [**StationUpdate**](StationUpdate.md)|  | 

### Return type

[**Station**](Station.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

