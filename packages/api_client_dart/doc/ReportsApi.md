# modern_pos_api_client.api.ReportsApi

## Load the API package
```dart
import 'package:modern_pos_api_client/api.dart';
```

All URIs are relative to */v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**reportsDaily**](ReportsApi.md#reportsdaily) | **GET** /outlets/{outletId}/reports/daily | Read reconciled local-date report
[**reportsExport**](ReportsApi.md#reportsexport) | **GET** /outlets/{outletId}/reports/sales.csv | Export filtered sales


# **reportsDaily**
> DailyReport reportsDaily(outletId, from, to)

Read reconciled local-date report

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ReportsApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final from = 2013-10-20; // DateTime | Inclusive outlet-local date. Maximum 366-day range.
final to = 2013-10-20; // DateTime | Inclusive outlet-local date. Maximum 366-day range.

try {
    final result = api_instance.reportsDaily(outletId, from, to);
    print(result);
} catch (e) {
    print('Exception when calling ReportsApi->reportsDaily: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **from** | **DateTime**| Inclusive outlet-local date. Maximum 366-day range. | 
 **to** | **DateTime**| Inclusive outlet-local date. Maximum 366-day range. | 

### Return type

[**DailyReport**](DailyReport.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **reportsExport**
> String reportsExport(outletId, from, to)

Export filtered sales

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ReportsApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final from = 2013-10-20; // DateTime | Inclusive outlet-local date. Maximum 366-day range.
final to = 2013-10-20; // DateTime | Inclusive outlet-local date. Maximum 366-day range.

try {
    final result = api_instance.reportsExport(outletId, from, to);
    print(result);
} catch (e) {
    print('Exception when calling ReportsApi->reportsExport: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **from** | **DateTime**| Inclusive outlet-local date. Maximum 366-day range. | 
 **to** | **DateTime**| Inclusive outlet-local date. Maximum 366-day range. | 

### Return type

**String**

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: text/csv, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

