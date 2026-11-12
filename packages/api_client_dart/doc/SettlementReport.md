# modern_pos_api_client.model.SettlementReport

## Load the model package
```dart
import 'package:modern_pos_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**from** | [**DateTime**](DateTime.md) |  | 
**to** | [**DateTime**](DateTime.md) |  | 
**timezone** | **String** |  | 
**currency** | **String** |  | 
**currencyExponent** | **int** |  | 
**onlineSaleTotalMinor** | **int** |  | 
**capturedMinor** | **int** |  | 
**refundedMinor** | **int** |  | 
**netMinor** | **int** |  | 
**pendingMinor** | **int** |  | 
**failedMinor** | **int** |  | 
**driftMinor** | **int** |  | 
**saleCount** | **int** |  | 
**days** | [**List<SettlementDay>**](SettlementDay.md) |  | [default to const []]
**payments** | [**List<SettlementPayment>**](SettlementPayment.md) |  | [default to const []]
**generatedAt** | [**DateTime**](DateTime.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


