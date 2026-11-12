# modern_pos_api_client.api.AttendanceApi

## Load the API package
```dart
import 'package:modern_pos_api_client/api.dart';
```

All URIs are relative to */v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**attendanceClockIn**](AttendanceApi.md#attendanceclockin) | **POST** /outlets/{outletId}/attendance/clock-in | Clock in without opening a shift
[**attendanceClockOut**](AttendanceApi.md#attendanceclockout) | **POST** /outlets/{outletId}/attendance/clock-out | Clock out without closing a shift
[**attendanceList**](AttendanceApi.md#attendancelist) | **GET** /outlets/{outletId}/attendance | List attendance records


# **attendanceClockIn**
> AttendanceRecord attendanceClockIn(outletId, attendanceWrite)

Clock in without opening a shift

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AttendanceApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final attendanceWrite = AttendanceWrite(); // AttendanceWrite | 

try {
    final result = api_instance.attendanceClockIn(outletId, attendanceWrite);
    print(result);
} catch (e) {
    print('Exception when calling AttendanceApi->attendanceClockIn: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **attendanceWrite** | [**AttendanceWrite**](AttendanceWrite.md)|  | [optional] 

### Return type

[**AttendanceRecord**](AttendanceRecord.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **attendanceClockOut**
> AttendanceRecord attendanceClockOut(outletId, attendanceWrite)

Clock out without closing a shift

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AttendanceApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final attendanceWrite = AttendanceWrite(); // AttendanceWrite | 

try {
    final result = api_instance.attendanceClockOut(outletId, attendanceWrite);
    print(result);
} catch (e) {
    print('Exception when calling AttendanceApi->attendanceClockOut: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **attendanceWrite** | [**AttendanceWrite**](AttendanceWrite.md)|  | [optional] 

### Return type

[**AttendanceRecord**](AttendanceRecord.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **attendanceList**
> AttendancePage attendanceList(outletId, userId, from, to, cursor, limit)

List attendance records

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AttendanceApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final userId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final from = 2013-10-20T19:20:30+01:00; // DateTime | 
final to = 2013-10-20T19:20:30+01:00; // DateTime | 
final cursor = cursor_example; // String | 
final limit = 56; // int | 

try {
    final result = api_instance.attendanceList(outletId, userId, from, to, cursor, limit);
    print(result);
} catch (e) {
    print('Exception when calling AttendanceApi->attendanceList: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **userId** | **String**|  | [optional] 
 **from** | **DateTime**|  | [optional] 
 **to** | **DateTime**|  | [optional] 
 **cursor** | **String**|  | [optional] 
 **limit** | **int**|  | [optional] 

### Return type

[**AttendancePage**](AttendancePage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

