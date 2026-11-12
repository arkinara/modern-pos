# modern_pos_api_client.model.Reversal

## Load the model package
```dart
import 'package:modern_pos_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | 
**saleId** | **String** |  | 
**reason** | **String** |  | 
**createdAt** | [**DateTime**](DateTime.md) |  | 
**restock** | [**List<Restock>**](Restock.md) |  | [default to const []]
**externalRefundPerformed** | **bool** | True only when the configured provider adapter performed the refund. Cash and manual reversals stay false. | 
**kind** | **String** |  | [optional] 
**refundMinor** | **int** | Currency minor units; IDR exponent 0 in demo. | [optional] 
**lines** | [**List<RefundLine>**](RefundLine.md) |  | [optional] [default to const []]
**providerRefundRef** | **String** | Provider refund reference when a provider movement was performed. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


