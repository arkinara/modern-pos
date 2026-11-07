# modern_pos_api_client.model.DailyReport

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
**grossItemSalesMinor** | **int** | Currency minor units; IDR exponent 0 in demo. | 
**reversalItemValueMinor** | **int** | Currency minor units; IDR exponent 0 in demo. | 
**netItemSalesMinor** | **int** |  | 
**saleCount** | **int** |  | 
**reversalCount** | **int** |  | 
**averageBillMinor** | **int** | Currency minor units; IDR exponent 0 in demo. | 
**paymentBreakdown** | [**List<DailyReportPaymentBreakdownInner>**](DailyReportPaymentBreakdownInner.md) |  | [default to const []]
**topItems** | [**List<DailyReportTopItemsInner>**](DailyReportTopItemsInner.md) |  | [default to const []]
**generatedAt** | [**DateTime**](DateTime.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


