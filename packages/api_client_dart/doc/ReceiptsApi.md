# modern_pos_api_client.api.ReceiptsApi

## Load the API package
```dart
import 'package:modern_pos_api_client/api.dart';
```

All URIs are relative to */v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**receiptCreate**](ReceiptsApi.md#receiptcreate) | **POST** /outlets/{outletId}/sales/{saleId}/receipt | Create a signed digital receipt artifact for a sale
[**receiptPublicGet**](ReceiptsApi.md#receiptpublicget) | **GET** /receipts/{token} | Read a digital receipt by unguessable token
[**receiptPublicHtml**](ReceiptsApi.md#receiptpublichtml) | **GET** /receipts/{token}/html | Read a digital receipt as HTML by unguessable token


# **receiptCreate**
> DigitalReceipt receiptCreate(outletId, saleId, receiptWrite)

Create a signed digital receipt artifact for a sale

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ReceiptsApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final saleId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final receiptWrite = ReceiptWrite(); // ReceiptWrite | 

try {
    final result = api_instance.receiptCreate(outletId, saleId, receiptWrite);
    print(result);
} catch (e) {
    print('Exception when calling ReceiptsApi->receiptCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **saleId** | **String**|  | 
 **receiptWrite** | [**ReceiptWrite**](ReceiptWrite.md)|  | 

### Return type

[**DigitalReceipt**](DigitalReceipt.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **receiptPublicGet**
> DigitalReceiptPublic receiptPublicGet(token)

Read a digital receipt by unguessable token

### Example
```dart
import 'package:modern_pos_api_client/api.dart';

final api_instance = ReceiptsApi();
final token = token_example; // String | 

try {
    final result = api_instance.receiptPublicGet(token);
    print(result);
} catch (e) {
    print('Exception when calling ReceiptsApi->receiptPublicGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **token** | **String**|  | 

### Return type

[**DigitalReceiptPublic**](DigitalReceiptPublic.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **receiptPublicHtml**
> String receiptPublicHtml(token)

Read a digital receipt as HTML by unguessable token

### Example
```dart
import 'package:modern_pos_api_client/api.dart';

final api_instance = ReceiptsApi();
final token = token_example; // String | 

try {
    final result = api_instance.receiptPublicHtml(token);
    print(result);
} catch (e) {
    print('Exception when calling ReceiptsApi->receiptPublicHtml: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **token** | **String**|  | 

### Return type

**String**

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: text/html, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

