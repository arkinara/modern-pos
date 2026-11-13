# modern_pos_api_client.model.ProfitReport

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
**generatedAt** | [**DateTime**](DateTime.md) |  | 
**marginAvailable** | **bool** |  | 
**unavailableReasons** | **List<String>** |  | [default to const []]
**costingMethod** | **String** |  | 
**revenue** | [**ProfitReportRevenue**](ProfitReportRevenue.md) |  | 
**cogs** | [**ProfitReportCogs**](ProfitReportCogs.md) |  | 
**waste** | [**ProfitReportWaste**](ProfitReportWaste.md) |  | 
**expenses** | [**ProfitReportExpenses**](ProfitReportExpenses.md) |  | 
**grossProfitMinor** | **int** |  | 
**netProfitMinor** | **int** |  | 
**netMarginBps** | **int** |  | 
**marginBpsUnavailableReason** | **String** |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


