# modern_pos_api_client.model.Sale

## Load the model package
```dart
import 'package:modern_pos_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | 
**orderId** | **String** |  | 
**reference** | **String** |  | 
**state** | **String** |  | 
**currency** | **String** |  | 
**currencyExponent** | **int** |  | 
**timezone** | **String** |  | 
**completedAt** | [**DateTime**](DateTime.md) |  | 
**calculation** | [**CalculationRules**](CalculationRules.md) |  | 
**totals** | [**Totals**](Totals.md) |  | 
**lines** | [**List<SaleLine>**](SaleLine.md) |  | [default to const []]
**payment** | [**Payment**](Payment.md) |  | 
**reversal** | [**Reversal**](Reversal.md) |  | [optional] 
**promotions** | [**List<PromotionSnapshot>**](PromotionSnapshot.md) |  | [optional] [default to const []]
**refunds** | [**List<Reversal>**](Reversal.md) | All refund records linked to this sale, including full and partial refunds. | [optional] [default to const []]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


