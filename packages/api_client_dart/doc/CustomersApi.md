# modern_pos_api_client.api.CustomersApi

## Load the API package
```dart
import 'package:modern_pos_api_client/api.dart';
```

All URIs are relative to */v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**customerCreate**](CustomersApi.md#customercreate) | **POST** /outlets/{outletId}/customers | Create an opt-in customer record
[**customerGet**](CustomersApi.md#customerget) | **GET** /outlets/{outletId}/customers/{customerId} | Read one opt-in customer record
[**customerPurge**](CustomersApi.md#customerpurge) | **POST** /outlets/{outletId}/customers/purge | Anonymise expired customers and remove expired receipts
[**customerRetentionGet**](CustomersApi.md#customerretentionget) | **GET** /outlets/{outletId}/customers/retention-policy | Read the customer and receipt retention policy
[**customerRetentionUpdate**](CustomersApi.md#customerretentionupdate) | **PUT** /outlets/{outletId}/customers/retention-policy | Update the customer and receipt retention policy
[**customersList**](CustomersApi.md#customerslist) | **GET** /outlets/{outletId}/customers | List opt-in customer records


# **customerCreate**
> Customer customerCreate(outletId, customerWrite)

Create an opt-in customer record

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = CustomersApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final customerWrite = CustomerWrite(); // CustomerWrite | 

try {
    final result = api_instance.customerCreate(outletId, customerWrite);
    print(result);
} catch (e) {
    print('Exception when calling CustomersApi->customerCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **customerWrite** | [**CustomerWrite**](CustomerWrite.md)|  | 

### Return type

[**Customer**](Customer.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **customerGet**
> Customer customerGet(outletId, customerId)

Read one opt-in customer record

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = CustomersApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final customerId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.customerGet(outletId, customerId);
    print(result);
} catch (e) {
    print('Exception when calling CustomersApi->customerGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **customerId** | **String**|  | 

### Return type

[**Customer**](Customer.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **customerPurge**
> CustomerPurgeResult customerPurge(outletId)

Anonymise expired customers and remove expired receipts

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = CustomersApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.customerPurge(outletId);
    print(result);
} catch (e) {
    print('Exception when calling CustomersApi->customerPurge: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 

### Return type

[**CustomerPurgeResult**](CustomerPurgeResult.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **customerRetentionGet**
> CustomerRetentionPolicy customerRetentionGet(outletId)

Read the customer and receipt retention policy

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = CustomersApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.customerRetentionGet(outletId);
    print(result);
} catch (e) {
    print('Exception when calling CustomersApi->customerRetentionGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 

### Return type

[**CustomerRetentionPolicy**](CustomerRetentionPolicy.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **customerRetentionUpdate**
> CustomerRetentionPolicy customerRetentionUpdate(outletId, customerRetentionPolicyUpdate)

Update the customer and receipt retention policy

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = CustomersApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final customerRetentionPolicyUpdate = CustomerRetentionPolicyUpdate(); // CustomerRetentionPolicyUpdate | 

try {
    final result = api_instance.customerRetentionUpdate(outletId, customerRetentionPolicyUpdate);
    print(result);
} catch (e) {
    print('Exception when calling CustomersApi->customerRetentionUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **customerRetentionPolicyUpdate** | [**CustomerRetentionPolicyUpdate**](CustomerRetentionPolicyUpdate.md)|  | 

### Return type

[**CustomerRetentionPolicy**](CustomerRetentionPolicy.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **customersList**
> CustomerList customersList(outletId, search, limit)

List opt-in customer records

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = CustomersApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final search = search_example; // String | 
final limit = 56; // int | 

try {
    final result = api_instance.customersList(outletId, search, limit);
    print(result);
} catch (e) {
    print('Exception when calling CustomersApi->customersList: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **search** | **String**|  | [optional] 
 **limit** | **int**|  | [optional] [default to 50]

### Return type

[**CustomerList**](CustomerList.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

