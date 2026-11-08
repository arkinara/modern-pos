# modern_pos_api_client.model.Variant

## Load the model package
```dart
import 'package:modern_pos_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | 
**name** | **String** |  | 
**priceMinor** | **int** | Currency minor units; IDR exponent 0 in demo. | 
**stockPolicy** | **String** |  | 
**revision** | **int** |  | 
**enabled** | **bool** |  | 
**availableUnits** | **int** | Null for UNTRACKED variants. For TRACKED variants, advisory minimum floor(balance / quantityPerSaleUnit) across the latest recipe, computed per request; finalization is authoritative. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


