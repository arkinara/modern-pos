# modern_pos_api_client.model.Shift

## Load the model package
```dart
import 'package:modern_pos_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | 
**outletId** | **String** |  | 
**status** | **String** |  | 
**openedById** | **String** |  | 
**closedById** | **String** |  | [optional] 
**openingFloatMinor** | **int** | Currency minor units; IDR exponent 0 in demo. | 
**cashSalesMinor** | **int** | Currency minor units; IDR exponent 0 in demo. | 
**paidInMinor** | **int** | Currency minor units; IDR exponent 0 in demo. | 
**paidOutMinor** | **int** | Currency minor units; IDR exponent 0 in demo. | 
**expectedCashMinor** | **int** | Currency minor units; IDR exponent 0 in demo. | 
**countedCashMinor** | **int** | Currency minor units; IDR exponent 0 in demo. | [optional] 
**discrepancyMinor** | **int** | Counted minus expected; positive is over, negative is short. | [optional] 
**closeNote** | **String** |  | [optional] 
**version** | **int** |  | 
**openedAt** | [**DateTime**](DateTime.md) |  | 
**closedAt** | [**DateTime**](DateTime.md) |  | [optional] 
**currency** | **String** |  | 
**currencyExponent** | **int** |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


