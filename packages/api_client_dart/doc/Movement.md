# modern_pos_api_client.model.Movement

## Load the model package
```dart
import 'package:modern_pos_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | 
**outletId** | **String** |  | 
**stockItemId** | **String** |  | 
**delta** | **String** |  | 
**type** | **String** |  | 
**reason** | **String** |  | 
**sourceId** | **String** |  | 
**sourceReference** | **String** | Human-readable sale reference resolved from sourceId for SALE and REVERSAL movements. Null for non-sale movements or when the referenced sale is missing. The ledger remains readable when a reference cannot be resolved. | 
**actorId** | **String** |  | 
**createdAt** | [**DateTime**](DateTime.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


