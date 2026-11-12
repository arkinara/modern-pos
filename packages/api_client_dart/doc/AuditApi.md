# modern_pos_api_client.api.AuditApi

## Load the API package
```dart
import 'package:modern_pos_api_client/api.dart';
```

All URIs are relative to */v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**auditSearch**](AuditApi.md#auditsearch) | **GET** /outlets/{outletId}/audit | Search the operational audit trail (owner only)


# **auditSearch**
> OperationAuditPage auditSearch(outletId, actorId, from, to, action, cursor, limit)

Search the operational audit trail (owner only)

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AuditApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final actorId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final from = 2013-10-20T19:20:30+01:00; // DateTime | 
final to = 2013-10-20T19:20:30+01:00; // DateTime | 
final action = action_example; // String | 
final cursor = cursor_example; // String | 
final limit = 56; // int | 

try {
    final result = api_instance.auditSearch(outletId, actorId, from, to, action, cursor, limit);
    print(result);
} catch (e) {
    print('Exception when calling AuditApi->auditSearch: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **actorId** | **String**|  | [optional] 
 **from** | **DateTime**|  | [optional] 
 **to** | **DateTime**|  | [optional] 
 **action** | **String**|  | [optional] 
 **cursor** | **String**|  | [optional] 
 **limit** | **int**|  | [optional] 

### Return type

[**OperationAuditPage**](OperationAuditPage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

