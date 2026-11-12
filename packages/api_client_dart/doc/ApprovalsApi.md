# modern_pos_api_client.api.ApprovalsApi

## Load the API package
```dart
import 'package:modern_pos_api_client/api.dart';
```

All URIs are relative to */v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**approvalRulesList**](ApprovalsApi.md#approvalruleslist) | **GET** /outlets/{outletId}/approval-rules | List configured approval thresholds
[**approvalRulesUpsert**](ApprovalsApi.md#approvalrulesupsert) | **PUT** /outlets/{outletId}/approval-rules/{action} | Create or replace an approval threshold


# **approvalRulesList**
> List<ApprovalRule> approvalRulesList(outletId)

List configured approval thresholds

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ApprovalsApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.approvalRulesList(outletId);
    print(result);
} catch (e) {
    print('Exception when calling ApprovalsApi->approvalRulesList: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 

### Return type

[**List<ApprovalRule>**](ApprovalRule.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **approvalRulesUpsert**
> ApprovalRule approvalRulesUpsert(outletId, action, approvalRuleWrite)

Create or replace an approval threshold

Owner always passes. A non-owner passes only when the amount is at or below the active threshold.

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ApprovalsApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final action = action_example; // String | 
final approvalRuleWrite = ApprovalRuleWrite(); // ApprovalRuleWrite | 

try {
    final result = api_instance.approvalRulesUpsert(outletId, action, approvalRuleWrite);
    print(result);
} catch (e) {
    print('Exception when calling ApprovalsApi->approvalRulesUpsert: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **action** | **String**|  | 
 **approvalRuleWrite** | [**ApprovalRuleWrite**](ApprovalRuleWrite.md)|  | 

### Return type

[**ApprovalRule**](ApprovalRule.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

