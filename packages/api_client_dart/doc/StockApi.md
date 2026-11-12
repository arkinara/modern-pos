# modern_pos_api_client.api.StockApi

## Load the API package
```dart
import 'package:modern_pos_api_client/api.dart';
```

All URIs are relative to */v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**stockAdjust**](StockApi.md#stockadjust) | **POST** /outlets/{outletId}/stock/adjustments | Adjust stock with reason and balance version
[**stockCreate**](StockApi.md#stockcreate) | **POST** /outlets/{outletId}/stock | Create stock item
[**stockList**](StockApi.md#stocklist) | **GET** /outlets/{outletId}/stock | Search stock balances
[**stockMovements**](StockApi.md#stockmovements) | **GET** /outlets/{outletId}/stock/{stockItemId}/movements | Read append-only stock ledger
[**stockOpening**](StockApi.md#stockopening) | **POST** /outlets/{outletId}/stock/opening-balances | Record one opening balance
[**stockReceipt**](StockApi.md#stockreceipt) | **POST** /outlets/{outletId}/stock/receipts | Receive positive stock quantity


# **stockAdjust**
> Movement stockAdjust(outletId, idempotencyKey, adjustment)

Adjust stock with reason and balance version

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = StockApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final idempotencyKey = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Persist before submission; same key and payload on retries. Scope is outlet and device for checkout.
final adjustment = Adjustment(); // Adjustment | 

try {
    final result = api_instance.stockAdjust(outletId, idempotencyKey, adjustment);
    print(result);
} catch (e) {
    print('Exception when calling StockApi->stockAdjust: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **idempotencyKey** | **String**| Persist before submission; same key and payload on retries. Scope is outlet and device for checkout. | 
 **adjustment** | [**Adjustment**](Adjustment.md)|  | 

### Return type

[**Movement**](Movement.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **stockCreate**
> Stock stockCreate(outletId, stockWrite)

Create stock item

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = StockApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final stockWrite = StockWrite(); // StockWrite | 

try {
    final result = api_instance.stockCreate(outletId, stockWrite);
    print(result);
} catch (e) {
    print('Exception when calling StockApi->stockCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **stockWrite** | [**StockWrite**](StockWrite.md)|  | 

### Return type

[**Stock**](Stock.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **stockList**
> StockPage stockList(outletId, cursor, limit, search)

Search stock balances

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = StockApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final cursor = cursor_example; // String | 
final limit = 56; // int | 
final search = search_example; // String | 

try {
    final result = api_instance.stockList(outletId, cursor, limit, search);
    print(result);
} catch (e) {
    print('Exception when calling StockApi->stockList: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **cursor** | **String**|  | [optional] 
 **limit** | **int**|  | [optional] [default to 25]
 **search** | **String**|  | [optional] 

### Return type

[**StockPage**](StockPage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **stockMovements**
> MovementPage stockMovements(outletId, stockItemId, cursor, limit, type, reason, supplierId, supplierReference)

Read append-only stock ledger

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = StockApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final stockItemId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final cursor = cursor_example; // String | 
final limit = 56; // int | 
final type = type_example; // String | 
final reason = reason_example; // String | 
final supplierId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final supplierReference = supplierReference_example; // String | 

try {
    final result = api_instance.stockMovements(outletId, stockItemId, cursor, limit, type, reason, supplierId, supplierReference);
    print(result);
} catch (e) {
    print('Exception when calling StockApi->stockMovements: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **stockItemId** | **String**|  | 
 **cursor** | **String**|  | [optional] 
 **limit** | **int**|  | [optional] [default to 25]
 **type** | **String**|  | [optional] 
 **reason** | **String**|  | [optional] 
 **supplierId** | **String**|  | [optional] 
 **supplierReference** | **String**|  | [optional] 

### Return type

[**MovementPage**](MovementPage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **stockOpening**
> Movement stockOpening(outletId, idempotencyKey, stockChange)

Record one opening balance

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = StockApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final idempotencyKey = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Persist before submission; same key and payload on retries. Scope is outlet and device for checkout.
final stockChange = StockChange(); // StockChange | 

try {
    final result = api_instance.stockOpening(outletId, idempotencyKey, stockChange);
    print(result);
} catch (e) {
    print('Exception when calling StockApi->stockOpening: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **idempotencyKey** | **String**| Persist before submission; same key and payload on retries. Scope is outlet and device for checkout. | 
 **stockChange** | [**StockChange**](StockChange.md)|  | 

### Return type

[**Movement**](Movement.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **stockReceipt**
> Movement stockReceipt(outletId, idempotencyKey, stockChange)

Receive positive stock quantity

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = StockApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final idempotencyKey = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Persist before submission; same key and payload on retries. Scope is outlet and device for checkout.
final stockChange = StockChange(); // StockChange | 

try {
    final result = api_instance.stockReceipt(outletId, idempotencyKey, stockChange);
    print(result);
} catch (e) {
    print('Exception when calling StockApi->stockReceipt: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **idempotencyKey** | **String**| Persist before submission; same key and payload on retries. Scope is outlet and device for checkout. | 
 **stockChange** | [**StockChange**](StockChange.md)|  | 

### Return type

[**Movement**](Movement.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

