# modern_pos_api_client.api.SalesApi

## Load the API package
```dart
import 'package:modern_pos_api_client/api.dart';
```

All URIs are relative to */v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**salesFinalize**](SalesApi.md#salesfinalize) | **POST** /outlets/{outletId}/sales/finalize | Commit sale, payment record, stock, and recovery mapping
[**salesGet**](SalesApi.md#salesget) | **GET** /outlets/{outletId}/sales/{saleId} | Read immutable receipt data
[**salesList**](SalesApi.md#saleslist) | **GET** /outlets/{outletId}/sales | List sales; cashiers see only authorized own sales
[**salesRecover**](SalesApi.md#salesrecover) | **GET** /outlets/{outletId}/checkout-requests/{key} | Resolve uncertain checkout by original key
[**salesReverse**](SalesApi.md#salesreverse) | **POST** /outlets/{outletId}/sales/{saleId}/reversals | Record a full reversal or a partial refund with explicit restock


# **salesFinalize**
> Finalized salesFinalize(outletId, idempotencyKey, finalize)

Commit sale, payment record, stock, and recovery mapping

Cash amount must equal quoted total; tender >= amount. Manual external amount equals total, no tender/change. Replay existing keys before checking expired quotes. All writes are one serializable transaction. No provider charge is made.

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = SalesApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final idempotencyKey = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Persist before submission; same key and payload on retries. Scope is outlet and device for checkout.
final finalize = Finalize(); // Finalize | 

try {
    final result = api_instance.salesFinalize(outletId, idempotencyKey, finalize);
    print(result);
} catch (e) {
    print('Exception when calling SalesApi->salesFinalize: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **idempotencyKey** | **String**| Persist before submission; same key and payload on retries. Scope is outlet and device for checkout. | 
 **finalize** | [**Finalize**](Finalize.md)|  | 

### Return type

[**Finalized**](Finalized.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **salesGet**
> Sale salesGet(outletId, saleId)

Read immutable receipt data

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = SalesApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final saleId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.salesGet(outletId, saleId);
    print(result);
} catch (e) {
    print('Exception when calling SalesApi->salesGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **saleId** | **String**|  | 

### Return type

[**Sale**](Sale.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **salesList**
> SalePage salesList(outletId, cursor, limit, from, to, reference)

List sales; cashiers see only authorized own sales

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = SalesApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final cursor = cursor_example; // String | 
final limit = 56; // int | 
final from = 2013-10-20; // DateTime | 
final to = 2013-10-20; // DateTime | 
final reference = reference_example; // String | Full or partial sale reference. A matching from/to date range is required.

try {
    final result = api_instance.salesList(outletId, cursor, limit, from, to, reference);
    print(result);
} catch (e) {
    print('Exception when calling SalesApi->salesList: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **cursor** | **String**|  | [optional] 
 **limit** | **int**|  | [optional] [default to 25]
 **from** | **DateTime**|  | [optional] 
 **to** | **DateTime**|  | [optional] 
 **reference** | **String**| Full or partial sale reference. A matching from/to date range is required. | [optional] 

### Return type

[**SalePage**](SalePage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **salesRecover**
> Finalized salesRecover(outletId, key, deviceId)

Resolve uncertain checkout by original key

404 does not prove an original request cannot still commit. Retain/resubmit the same key; never auto-create a new key.

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = SalesApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final key = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final deviceId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.salesRecover(outletId, key, deviceId);
    print(result);
} catch (e) {
    print('Exception when calling SalesApi->salesRecover: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **key** | **String**|  | 
 **deviceId** | **String**|  | 

### Return type

[**Finalized**](Finalized.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **salesReverse**
> Reversal salesReverse(outletId, saleId, idempotencyKey, reversalWrite)

Record a full reversal or a partial refund with explicit restock

A full reversal omits lines and refundMinor. A partial refund names refunded sale lines, states refundMinor independently, and may restock any explicitly selected stock items. Approval rules decide whether a non-owner may proceed. No external provider performs money movement.

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = SalesApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final saleId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final idempotencyKey = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Persist before submission; same key and payload on retries. Scope is outlet and device for checkout.
final reversalWrite = ReversalWrite(); // ReversalWrite | 

try {
    final result = api_instance.salesReverse(outletId, saleId, idempotencyKey, reversalWrite);
    print(result);
} catch (e) {
    print('Exception when calling SalesApi->salesReverse: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **saleId** | **String**|  | 
 **idempotencyKey** | **String**| Persist before submission; same key and payload on retries. Scope is outlet and device for checkout. | 
 **reversalWrite** | [**ReversalWrite**](ReversalWrite.md)|  | 

### Return type

[**Reversal**](Reversal.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

