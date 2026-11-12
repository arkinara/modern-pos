# modern_pos_api_client.api.ShiftsApi

## Load the API package
```dart
import 'package:modern_pos_api_client/api.dart';
```

All URIs are relative to */v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**shiftsCashMovement**](ShiftsApi.md#shiftscashmovement) | **POST** /outlets/{outletId}/shifts/{shiftId}/cash-movements | Record a paid-in or paid-out on an open shift
[**shiftsClose**](ShiftsApi.md#shiftsclose) | **POST** /outlets/{outletId}/shifts/{shiftId}/close | Count the drawer and close the caller own shift
[**shiftsGet**](ShiftsApi.md#shiftsget) | **GET** /outlets/{outletId}/shifts/{shiftId} | Read one shift
[**shiftsList**](ShiftsApi.md#shiftslist) | **GET** /outlets/{outletId}/shifts | List cash shifts for an outlet
[**shiftsOpen**](ShiftsApi.md#shiftsopen) | **POST** /outlets/{outletId}/shifts | Open a shift with an opening float
[**shiftsReport**](ShiftsApi.md#shiftsreport) | **GET** /outlets/{outletId}/shifts/{shiftId}/report | Read the reconciled shift cash report (owner only)


# **shiftsCashMovement**
> Shift shiftsCashMovement(outletId, shiftId, shiftCashMovementWrite)

Record a paid-in or paid-out on an open shift

Paid-out above the active CASH_OUT approval threshold requires an owner and returns 403 APPROVAL_REQUIRED.

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ShiftsApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final shiftId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final shiftCashMovementWrite = ShiftCashMovementWrite(); // ShiftCashMovementWrite | 

try {
    final result = api_instance.shiftsCashMovement(outletId, shiftId, shiftCashMovementWrite);
    print(result);
} catch (e) {
    print('Exception when calling ShiftsApi->shiftsCashMovement: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **shiftId** | **String**|  | 
 **shiftCashMovementWrite** | [**ShiftCashMovementWrite**](ShiftCashMovementWrite.md)|  | 

### Return type

[**Shift**](Shift.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **shiftsClose**
> Shift shiftsClose(outletId, shiftId, shiftCloseWrite)

Count the drawer and close the caller own shift

Expected cash is opening float + cash tender sales + paid-ins - paid-outs. Closing a closed shift or someone else's shift returns 409.

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ShiftsApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final shiftId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final shiftCloseWrite = ShiftCloseWrite(); // ShiftCloseWrite | 

try {
    final result = api_instance.shiftsClose(outletId, shiftId, shiftCloseWrite);
    print(result);
} catch (e) {
    print('Exception when calling ShiftsApi->shiftsClose: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **shiftId** | **String**|  | 
 **shiftCloseWrite** | [**ShiftCloseWrite**](ShiftCloseWrite.md)|  | 

### Return type

[**Shift**](Shift.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **shiftsGet**
> Shift shiftsGet(outletId, shiftId)

Read one shift

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ShiftsApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final shiftId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.shiftsGet(outletId, shiftId);
    print(result);
} catch (e) {
    print('Exception when calling ShiftsApi->shiftsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **shiftId** | **String**|  | 

### Return type

[**Shift**](Shift.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **shiftsList**
> ShiftPage shiftsList(outletId, status, cursor, limit)

List cash shifts for an outlet

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ShiftsApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final status = status_example; // String | 
final cursor = cursor_example; // String | 
final limit = 56; // int | 

try {
    final result = api_instance.shiftsList(outletId, status, cursor, limit);
    print(result);
} catch (e) {
    print('Exception when calling ShiftsApi->shiftsList: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **status** | **String**|  | [optional] 
 **cursor** | **String**|  | [optional] 
 **limit** | **int**|  | [optional] 

### Return type

[**ShiftPage**](ShiftPage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **shiftsOpen**
> Shift shiftsOpen(outletId, shiftWrite)

Open a shift with an opening float

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ShiftsApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final shiftWrite = ShiftWrite(); // ShiftWrite | 

try {
    final result = api_instance.shiftsOpen(outletId, shiftWrite);
    print(result);
} catch (e) {
    print('Exception when calling ShiftsApi->shiftsOpen: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **shiftWrite** | [**ShiftWrite**](ShiftWrite.md)|  | 

### Return type

[**Shift**](Shift.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **shiftsReport**
> ShiftReport shiftsReport(outletId, shiftId)

Read the reconciled shift cash report (owner only)

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ShiftsApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final shiftId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.shiftsReport(outletId, shiftId);
    print(result);
} catch (e) {
    print('Exception when calling ShiftsApi->shiftsReport: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **shiftId** | **String**|  | 

### Return type

[**ShiftReport**](ShiftReport.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

