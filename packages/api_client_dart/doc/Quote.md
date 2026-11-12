# modern_pos_api_client.model.Quote

## Load the model package
```dart
import 'package:modern_pos_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | 
**orderId** | **String** |  | 
**orderVersion** | **int** |  | 
**settingsVersion** | **int** |  | 
**currency** | **String** |  | 
**currencyExponent** | **int** |  | 
**calculation** | [**CalculationRules**](CalculationRules.md) |  | 
**expiresAt** | [**DateTime**](DateTime.md) |  | 
**totals** | [**Totals**](Totals.md) |  | 
**lines** | [**List<QuoteLinesInner>**](QuoteLinesInner.md) |  | [default to const []]
**promotions** | [**List<PromotionSnapshot>**](PromotionSnapshot.md) |  | [optional] [default to const []]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


