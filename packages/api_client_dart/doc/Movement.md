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
**sourceReference** | **String** | Human-readable sale or transfer reference resolved from sourceId. Null when no reference applies or the referenced row is missing. The ledger remains readable when a reference cannot be resolved. | 
**actorId** | **String** |  | 
**createdAt** | [**DateTime**](DateTime.md) |  | 
**supplierId** | **String** | Supplier linked to this purchase receipt, when present. | [optional] 
**supplierName** | **String** | Supplier display name resolved for a purchase receipt. | [optional] 
**supplierReference** | **String** | Supplier reference resolved for a purchase receipt. | [optional] 
**purchaseOrderId** | **String** | Purchase order linked to this receipt. | [optional] 
**purchaseOrderReference** | **String** | Purchase order reference resolved for a receipt. | [optional] 
**transferId** | **String** | Outlet transfer linked to this movement. | [optional] 
**transferReference** | **String** | Outlet transfer reference resolved for a movement. | [optional] 
**stockCountId** | **String** | Stock count linked to this variance movement. | [optional] 
**stockCountReference** | **String** | Stock count reference resolved for a variance movement. | [optional] 
**stockWasteId** | **String** | Waste record linked to this movement. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


