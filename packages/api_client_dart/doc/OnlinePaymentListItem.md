# modern_pos_api_client.model.OnlinePaymentListItem

## Load the model package
```dart
import 'package:modern_pos_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | 
**saleId** | **String** |  | 
**provider** | **String** |  | 
**providerRef** | **String** |  | [optional] 
**status** | **String** |  | 
**amountMinor** | **int** | Currency minor units; IDR exponent 0 in demo. | 
**refundedMinor** | **int** | Currency minor units; IDR exponent 0 in demo. | 
**currency** | **String** |  | 
**currencyExponent** | **int** |  | 
**qrPayload** | **String** |  | [optional] 
**settledAt** | [**DateTime**](DateTime.md) |  | [optional] 
**failedAt** | [**DateTime**](DateTime.md) |  | [optional] 
**createdAt** | [**DateTime**](DateTime.md) |  | 
**updatedAt** | [**DateTime**](DateTime.md) |  | 
**saleReference** | **String** |  | 
**saleCompletedAt** | [**DateTime**](DateTime.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


