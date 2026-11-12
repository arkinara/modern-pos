# modern_pos_api_client.api.PaymentsApi

## Load the API package
```dart
import 'package:modern_pos_api_client/api.dart';
```

All URIs are relative to */v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**paymentsCreate**](PaymentsApi.md#paymentscreate) | **POST** /outlets/{outletId}/sales/{saleId}/online-payment | Create or replay the provider payment intent for a completed online sale
[**paymentsGet**](PaymentsApi.md#paymentsget) | **GET** /outlets/{outletId}/sales/{saleId}/online-payment | Read the server-side online payment state
[**paymentsList**](PaymentsApi.md#paymentslist) | **GET** /outlets/{outletId}/online-payments | List online payments for the outlet
[**paymentsReconcile**](PaymentsApi.md#paymentsreconcile) | **POST** /outlets/{outletId}/online-payments/reconcile | Compare pending local payments with the provider and repair drift
[**paymentsRefresh**](PaymentsApi.md#paymentsrefresh) | **POST** /outlets/{outletId}/sales/{saleId}/online-payment/refresh | Resolve provider state after a lost client connection
[**paymentsSettlements**](PaymentsApi.md#paymentssettlements) | **GET** /outlets/{outletId}/online-payments/settlements | Daily and per-payment captured/refunded settlement report
[**paymentsWebhook**](PaymentsApi.md#paymentswebhook) | **POST** /payments/webhook | Receive a signed, replay-protected provider webhook


# **paymentsCreate**
> OnlinePayment paymentsCreate(outletId, saleId)

Create or replay the provider payment intent for a completed online sale

Idempotent per sale: repeated calls return the same online payment and provider reference. A failed intent is reset to pending for an explicit retry. No stock or sale is created here.

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = PaymentsApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final saleId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.paymentsCreate(outletId, saleId);
    print(result);
} catch (e) {
    print('Exception when calling PaymentsApi->paymentsCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **saleId** | **String**|  | 

### Return type

[**OnlinePayment**](OnlinePayment.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **paymentsGet**
> OnlinePayment paymentsGet(outletId, saleId)

Read the server-side online payment state

The client resolves reconnect state from the server and never assumes failure or recharges.

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = PaymentsApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final saleId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.paymentsGet(outletId, saleId);
    print(result);
} catch (e) {
    print('Exception when calling PaymentsApi->paymentsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **saleId** | **String**|  | 

### Return type

[**OnlinePayment**](OnlinePayment.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **paymentsList**
> OnlinePaymentList paymentsList(outletId, limit)

List online payments for the outlet

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = PaymentsApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final limit = 56; // int | 

try {
    final result = api_instance.paymentsList(outletId, limit);
    print(result);
} catch (e) {
    print('Exception when calling PaymentsApi->paymentsList: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **limit** | **int**|  | [optional] [default to 25]

### Return type

[**OnlinePaymentList**](OnlinePaymentList.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **paymentsReconcile**
> ReconciliationSummary paymentsReconcile(outletId)

Compare pending local payments with the provider and repair drift

Read-only toward the provider: fetches each pending provider payment and applies the reported state. It never creates a provider charge.

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = PaymentsApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.paymentsReconcile(outletId);
    print(result);
} catch (e) {
    print('Exception when calling PaymentsApi->paymentsReconcile: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 

### Return type

[**ReconciliationSummary**](ReconciliationSummary.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **paymentsRefresh**
> OnlinePayment paymentsRefresh(outletId, saleId)

Resolve provider state after a lost client connection

Fetches the provider record and applies pending/succeeded/failed without creating a second payment or stock movement.

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = PaymentsApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final saleId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.paymentsRefresh(outletId, saleId);
    print(result);
} catch (e) {
    print('Exception when calling PaymentsApi->paymentsRefresh: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **saleId** | **String**|  | 

### Return type

[**OnlinePayment**](OnlinePayment.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **paymentsSettlements**
> SettlementReport paymentsSettlements(outletId, from, to)

Daily and per-payment captured/refunded settlement report

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = PaymentsApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final from = 2013-10-20; // DateTime | 
final to = 2013-10-20; // DateTime | 

try {
    final result = api_instance.paymentsSettlements(outletId, from, to);
    print(result);
} catch (e) {
    print('Exception when calling PaymentsApi->paymentsSettlements: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **from** | **DateTime**|  | 
 **to** | **DateTime**|  | 

### Return type

[**SettlementReport**](SettlementReport.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **paymentsWebhook**
> WebhookAck paymentsWebhook(xPaymentSignature)

Receive a signed, replay-protected provider webhook

Public endpoint. Invalid signatures and timestamps outside the replay window are rejected before any state change. Provider event ids are unique per provider for concurrency-safe dedupe. A duplicate delivery is acknowledged with duplicate=true.

### Example
```dart
import 'package:modern_pos_api_client/api.dart';

final api_instance = PaymentsApi();
final xPaymentSignature = xPaymentSignature_example; // String | Format t=<unix-seconds>,v1=<hex HMAC-SHA256 of t + \".\" + raw body>.

try {
    final result = api_instance.paymentsWebhook(xPaymentSignature);
    print(result);
} catch (e) {
    print('Exception when calling PaymentsApi->paymentsWebhook: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xPaymentSignature** | **String**| Format t=<unix-seconds>,v1=<hex HMAC-SHA256 of t + \".\" + raw body>. | 

### Return type

[**WebhookAck**](WebhookAck.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

