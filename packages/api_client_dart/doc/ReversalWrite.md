# modern_pos_api_client.model.ReversalWrite

## Load the model package
```dart
import 'package:modern_pos_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**reason** | **String** |  | 
**restock** | [**List<Restock>**](Restock.md) |  | [default to const []]
**refundMinor** | **int** | Currency minor units; IDR exponent 0 in demo. | [optional] 
**lines** | [**List<RefundLine>**](RefundLine.md) | Omit for a full reversal; provide one or more lines for a partial refund. | [optional] [default to const []]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


