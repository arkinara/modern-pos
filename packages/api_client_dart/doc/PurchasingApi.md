# modern_pos_api_client.api.PurchasingApi

## Load the API package
```dart
import 'package:modern_pos_api_client/api.dart';
```

All URIs are relative to */v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**purchaseOrderCancel**](PurchasingApi.md#purchaseordercancel) | **POST** /outlets/{outletId}/purchase-orders/{purchaseOrderId}/cancel | Cancel a purchase order before any receipt
[**purchaseOrderCreate**](PurchasingApi.md#purchaseordercreate) | **POST** /outlets/{outletId}/purchase-orders | Create a purchase order with supplier-unit conversion
[**purchaseOrderList**](PurchasingApi.md#purchaseorderlist) | **GET** /outlets/{outletId}/purchase-orders | List purchase orders for an outlet
[**purchaseOrderReceive**](PurchasingApi.md#purchaseorderreceive) | **POST** /outlets/{outletId}/purchase-orders/{purchaseOrderId}/receipts | Receive ordered stock partially or fully
[**stockCountCreate**](PurchasingApi.md#stockcountcreate) | **POST** /outlets/{outletId}/stock-counts | Count stock and post variance ledger entries
[**stockCountList**](PurchasingApi.md#stockcountlist) | **GET** /outlets/{outletId}/stock-counts | List stock counts with variance lines
[**supplierCreate**](PurchasingApi.md#suppliercreate) | **POST** /outlets/{outletId}/suppliers | Create a supplier
[**supplierList**](PurchasingApi.md#supplierlist) | **GET** /outlets/{outletId}/suppliers | Search suppliers
[**transferCancel**](PurchasingApi.md#transfercancel) | **POST** /outlets/{outletId}/transfers/{transferId}/cancel | Cancel an unreceived transfer and restore source stock
[**transferCreate**](PurchasingApi.md#transfercreate) | **POST** /outlets/{outletId}/transfers | Create a draft outlet transfer
[**transferDispatch**](PurchasingApi.md#transferdispatch) | **POST** /outlets/{outletId}/transfers/{transferId}/dispatch | Dispatch a draft transfer and remove source stock
[**transferList**](PurchasingApi.md#transferlist) | **GET** /outlets/{outletId}/transfers | List transfers involving this outlet
[**transferReceive**](PurchasingApi.md#transferreceive) | **POST** /outlets/{outletId}/transfers/{transferId}/receive | Receive dispatched stock at the destination outlet
[**wasteCreate**](PurchasingApi.md#wastecreate) | **POST** /outlets/{outletId}/stock-wastes | Remove stock with a mandatory waste reason
[**wasteList**](PurchasingApi.md#wastelist) | **GET** /outlets/{outletId}/stock-wastes | List recorded waste and loss


# **purchaseOrderCancel**
> PurchaseOrder purchaseOrderCancel(outletId, purchaseOrderId)

Cancel a purchase order before any receipt

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = PurchasingApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final purchaseOrderId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.purchaseOrderCancel(outletId, purchaseOrderId);
    print(result);
} catch (e) {
    print('Exception when calling PurchasingApi->purchaseOrderCancel: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **purchaseOrderId** | **String**|  | 

### Return type

[**PurchaseOrder**](PurchaseOrder.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **purchaseOrderCreate**
> PurchaseOrder purchaseOrderCreate(outletId, purchaseOrderWrite)

Create a purchase order with supplier-unit conversion

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = PurchasingApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final purchaseOrderWrite = PurchaseOrderWrite(); // PurchaseOrderWrite | 

try {
    final result = api_instance.purchaseOrderCreate(outletId, purchaseOrderWrite);
    print(result);
} catch (e) {
    print('Exception when calling PurchasingApi->purchaseOrderCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **purchaseOrderWrite** | [**PurchaseOrderWrite**](PurchaseOrderWrite.md)|  | 

### Return type

[**PurchaseOrder**](PurchaseOrder.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **purchaseOrderList**
> PurchaseOrderPage purchaseOrderList(outletId, cursor, limit)

List purchase orders for an outlet

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = PurchasingApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final cursor = cursor_example; // String | 
final limit = 56; // int | 

try {
    final result = api_instance.purchaseOrderList(outletId, cursor, limit);
    print(result);
} catch (e) {
    print('Exception when calling PurchasingApi->purchaseOrderList: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **cursor** | **String**|  | [optional] 
 **limit** | **int**|  | [optional] [default to 25]

### Return type

[**PurchaseOrderPage**](PurchaseOrderPage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **purchaseOrderReceive**
> PurchaseOrderReceipt purchaseOrderReceive(outletId, purchaseOrderId, purchaseOrderReceiptWrite)

Receive ordered stock partially or fully

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = PurchasingApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final purchaseOrderId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final purchaseOrderReceiptWrite = PurchaseOrderReceiptWrite(); // PurchaseOrderReceiptWrite | 

try {
    final result = api_instance.purchaseOrderReceive(outletId, purchaseOrderId, purchaseOrderReceiptWrite);
    print(result);
} catch (e) {
    print('Exception when calling PurchasingApi->purchaseOrderReceive: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **purchaseOrderId** | **String**|  | 
 **purchaseOrderReceiptWrite** | [**PurchaseOrderReceiptWrite**](PurchaseOrderReceiptWrite.md)|  | 

### Return type

[**PurchaseOrderReceipt**](PurchaseOrderReceipt.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **stockCountCreate**
> StockCount stockCountCreate(outletId, stockCountWrite)

Count stock and post variance ledger entries

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = PurchasingApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final stockCountWrite = StockCountWrite(); // StockCountWrite | 

try {
    final result = api_instance.stockCountCreate(outletId, stockCountWrite);
    print(result);
} catch (e) {
    print('Exception when calling PurchasingApi->stockCountCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **stockCountWrite** | [**StockCountWrite**](StockCountWrite.md)|  | 

### Return type

[**StockCount**](StockCount.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **stockCountList**
> StockCountPage stockCountList(outletId, cursor, limit)

List stock counts with variance lines

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = PurchasingApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final cursor = cursor_example; // String | 
final limit = 56; // int | 

try {
    final result = api_instance.stockCountList(outletId, cursor, limit);
    print(result);
} catch (e) {
    print('Exception when calling PurchasingApi->stockCountList: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **cursor** | **String**|  | [optional] 
 **limit** | **int**|  | [optional] [default to 25]

### Return type

[**StockCountPage**](StockCountPage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **supplierCreate**
> Supplier supplierCreate(outletId, supplierWrite)

Create a supplier

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = PurchasingApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final supplierWrite = SupplierWrite(); // SupplierWrite | 

try {
    final result = api_instance.supplierCreate(outletId, supplierWrite);
    print(result);
} catch (e) {
    print('Exception when calling PurchasingApi->supplierCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **supplierWrite** | [**SupplierWrite**](SupplierWrite.md)|  | 

### Return type

[**Supplier**](Supplier.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **supplierList**
> SupplierPage supplierList(outletId, search, cursor, limit)

Search suppliers

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = PurchasingApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final search = search_example; // String | 
final cursor = cursor_example; // String | 
final limit = 56; // int | 

try {
    final result = api_instance.supplierList(outletId, search, cursor, limit);
    print(result);
} catch (e) {
    print('Exception when calling PurchasingApi->supplierList: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **search** | **String**|  | [optional] 
 **cursor** | **String**|  | [optional] 
 **limit** | **int**|  | [optional] [default to 25]

### Return type

[**SupplierPage**](SupplierPage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **transferCancel**
> OutletTransfer transferCancel(outletId, transferId)

Cancel an unreceived transfer and restore source stock

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = PurchasingApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final transferId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.transferCancel(outletId, transferId);
    print(result);
} catch (e) {
    print('Exception when calling PurchasingApi->transferCancel: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **transferId** | **String**|  | 

### Return type

[**OutletTransfer**](OutletTransfer.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **transferCreate**
> OutletTransfer transferCreate(outletId, outletTransferWrite)

Create a draft outlet transfer

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = PurchasingApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final outletTransferWrite = OutletTransferWrite(); // OutletTransferWrite | 

try {
    final result = api_instance.transferCreate(outletId, outletTransferWrite);
    print(result);
} catch (e) {
    print('Exception when calling PurchasingApi->transferCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **outletTransferWrite** | [**OutletTransferWrite**](OutletTransferWrite.md)|  | 

### Return type

[**OutletTransfer**](OutletTransfer.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **transferDispatch**
> OutletTransferMutation transferDispatch(outletId, transferId)

Dispatch a draft transfer and remove source stock

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = PurchasingApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final transferId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.transferDispatch(outletId, transferId);
    print(result);
} catch (e) {
    print('Exception when calling PurchasingApi->transferDispatch: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **transferId** | **String**|  | 

### Return type

[**OutletTransferMutation**](OutletTransferMutation.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **transferList**
> OutletTransferPage transferList(outletId, state, cursor, limit)

List transfers involving this outlet

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = PurchasingApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final state = state_example; // String | 
final cursor = cursor_example; // String | 
final limit = 56; // int | 

try {
    final result = api_instance.transferList(outletId, state, cursor, limit);
    print(result);
} catch (e) {
    print('Exception when calling PurchasingApi->transferList: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **state** | **String**|  | [optional] 
 **cursor** | **String**|  | [optional] 
 **limit** | **int**|  | [optional] [default to 25]

### Return type

[**OutletTransferPage**](OutletTransferPage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **transferReceive**
> OutletTransferMutation transferReceive(outletId, transferId, outletTransferReceiveWrite)

Receive dispatched stock at the destination outlet

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = PurchasingApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final transferId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final outletTransferReceiveWrite = OutletTransferReceiveWrite(); // OutletTransferReceiveWrite | 

try {
    final result = api_instance.transferReceive(outletId, transferId, outletTransferReceiveWrite);
    print(result);
} catch (e) {
    print('Exception when calling PurchasingApi->transferReceive: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **transferId** | **String**|  | 
 **outletTransferReceiveWrite** | [**OutletTransferReceiveWrite**](OutletTransferReceiveWrite.md)|  | 

### Return type

[**OutletTransferMutation**](OutletTransferMutation.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **wasteCreate**
> Waste wasteCreate(outletId, wasteWrite)

Remove stock with a mandatory waste reason

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = PurchasingApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final wasteWrite = WasteWrite(); // WasteWrite | 

try {
    final result = api_instance.wasteCreate(outletId, wasteWrite);
    print(result);
} catch (e) {
    print('Exception when calling PurchasingApi->wasteCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **wasteWrite** | [**WasteWrite**](WasteWrite.md)|  | 

### Return type

[**Waste**](Waste.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **wasteList**
> WastePage wasteList(outletId, cursor, limit)

List recorded waste and loss

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = PurchasingApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final cursor = cursor_example; // String | 
final limit = 56; // int | 

try {
    final result = api_instance.wasteList(outletId, cursor, limit);
    print(result);
} catch (e) {
    print('Exception when calling PurchasingApi->wasteList: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **cursor** | **String**|  | [optional] 
 **limit** | **int**|  | [optional] [default to 25]

### Return type

[**WastePage**](WastePage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

