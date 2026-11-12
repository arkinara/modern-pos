# modern_pos_api_client.api.SandboxApi

## Load the API package
```dart
import 'package:modern_pos_api_client/api.dart';
```

All URIs are relative to */v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**sandboxPaymentCreate**](SandboxApi.md#sandboxpaymentcreate) | **POST** /sandbox/provider/payments | Create a deterministic local sandbox provider payment
[**sandboxPaymentEvent**](SandboxApi.md#sandboxpaymentevent) | **POST** /sandbox/provider/payments/{providerRef}/events | Advance the sandbox ledger and issue a correctly signed webhook event
[**sandboxPaymentGet**](SandboxApi.md#sandboxpaymentget) | **GET** /sandbox/provider/payments/{providerRef} | Read a local sandbox provider payment


# **sandboxPaymentCreate**
> SandboxPayment sandboxPaymentCreate(sandboxPaymentWrite)

Create a deterministic local sandbox provider payment

Local sandbox only; disabled unless PAYMENT_PROVIDER=mock. It performs no real provider call.

### Example
```dart
import 'package:modern_pos_api_client/api.dart';

final api_instance = SandboxApi();
final sandboxPaymentWrite = SandboxPaymentWrite(); // SandboxPaymentWrite | 

try {
    final result = api_instance.sandboxPaymentCreate(sandboxPaymentWrite);
    print(result);
} catch (e) {
    print('Exception when calling SandboxApi->sandboxPaymentCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sandboxPaymentWrite** | [**SandboxPaymentWrite**](SandboxPaymentWrite.md)|  | 

### Return type

[**SandboxPayment**](SandboxPayment.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **sandboxPaymentEvent**
> SandboxEventResult sandboxPaymentEvent(providerRef, sandboxEventWrite)

Advance the sandbox ledger and issue a correctly signed webhook event

Returns the signed event body for the caller to deliver. Reuse the same event id to exercise duplicate delivery; send succeeded before pending to exercise out-of-order delivery.

### Example
```dart
import 'package:modern_pos_api_client/api.dart';

final api_instance = SandboxApi();
final providerRef = providerRef_example; // String | 
final sandboxEventWrite = SandboxEventWrite(); // SandboxEventWrite | 

try {
    final result = api_instance.sandboxPaymentEvent(providerRef, sandboxEventWrite);
    print(result);
} catch (e) {
    print('Exception when calling SandboxApi->sandboxPaymentEvent: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **providerRef** | **String**|  | 
 **sandboxEventWrite** | [**SandboxEventWrite**](SandboxEventWrite.md)|  | 

### Return type

[**SandboxEventResult**](SandboxEventResult.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **sandboxPaymentGet**
> SandboxPayment sandboxPaymentGet(providerRef)

Read a local sandbox provider payment

### Example
```dart
import 'package:modern_pos_api_client/api.dart';

final api_instance = SandboxApi();
final providerRef = providerRef_example; // String | 

try {
    final result = api_instance.sandboxPaymentGet(providerRef);
    print(result);
} catch (e) {
    print('Exception when calling SandboxApi->sandboxPaymentGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **providerRef** | **String**|  | 

### Return type

[**SandboxPayment**](SandboxPayment.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

