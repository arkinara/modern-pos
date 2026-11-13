# modern_pos_api_client.api.BookkeepingApi

## Load the API package
```dart
import 'package:modern_pos_api_client/api.dart';
```

All URIs are relative to */v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**bookkeepingConsolidated**](BookkeepingApi.md#bookkeepingconsolidated) | **GET** /outlets/{outletId}/bookkeeping/consolidated | Read consolidated owner view across all scoped outlets
[**bookkeepingCostingUpdate**](BookkeepingApi.md#bookkeepingcostingupdate) | **PUT** /outlets/{outletId}/bookkeeping/costing | Set the outlet inventory costing method
[**bookkeepingExportAccounting**](BookkeepingApi.md#bookkeepingexportaccounting) | **GET** /outlets/{outletId}/bookkeeping/exports/accounting.csv | One summary row per outlet and period. Profit fields are blank when unavailable.
[**bookkeepingExportPayments**](BookkeepingApi.md#bookkeepingexportpayments) | **GET** /outlets/{outletId}/bookkeeping/exports/payments.csv | One row per payment on a completed sale in the outlet-local period.
[**bookkeepingExportReversals**](BookkeepingApi.md#bookkeepingexportreversals) | **GET** /outlets/{outletId}/bookkeeping/exports/reversals.csv | One row per reversal in the outlet-local period.
[**bookkeepingExportSales**](BookkeepingApi.md#bookkeepingexportsales) | **GET** /outlets/{outletId}/bookkeeping/exports/sales.csv | Completed sale and reversal rows; same query and money rules as the daily report.
[**bookkeepingGet**](BookkeepingApi.md#bookkeepingget) | **GET** /outlets/{outletId}/bookkeeping | Read costing and expense category configuration
[**bookkeepingProfit**](BookkeepingApi.md#bookkeepingprofit) | **GET** /outlets/{outletId}/bookkeeping/profit | Read profit and margin with explicit availability gate
[**expenseCategoriesCreate**](BookkeepingApi.md#expensecategoriescreate) | **POST** /outlets/{outletId}/bookkeeping/expense-categories | Create an expense category
[**expenseCategoriesList**](BookkeepingApi.md#expensecategorieslist) | **GET** /outlets/{outletId}/bookkeeping/expense-categories | List active expense categories
[**expensesCreate**](BookkeepingApi.md#expensescreate) | **POST** /outlets/{outletId}/bookkeeping/expenses | Record a manual operating expense
[**expensesList**](BookkeepingApi.md#expenseslist) | **GET** /outlets/{outletId}/bookkeeping/expenses | List manual operating expenses


# **bookkeepingConsolidated**
> ConsolidatedReport bookkeepingConsolidated(outletId, from, to)

Read consolidated owner view across all scoped outlets

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = BookkeepingApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final from = 2013-10-20; // DateTime | Inclusive outlet-local date. Maximum 366-day range.
final to = 2013-10-20; // DateTime | Inclusive outlet-local date. Maximum 366-day range.

try {
    final result = api_instance.bookkeepingConsolidated(outletId, from, to);
    print(result);
} catch (e) {
    print('Exception when calling BookkeepingApi->bookkeepingConsolidated: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **from** | **DateTime**| Inclusive outlet-local date. Maximum 366-day range. | 
 **to** | **DateTime**| Inclusive outlet-local date. Maximum 366-day range. | 

### Return type

[**ConsolidatedReport**](ConsolidatedReport.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **bookkeepingCostingUpdate**
> BookkeepingConfiguration bookkeepingCostingUpdate(outletId, costingUpdate)

Set the outlet inventory costing method

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = BookkeepingApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final costingUpdate = CostingUpdate(); // CostingUpdate | 

try {
    final result = api_instance.bookkeepingCostingUpdate(outletId, costingUpdate);
    print(result);
} catch (e) {
    print('Exception when calling BookkeepingApi->bookkeepingCostingUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **costingUpdate** | [**CostingUpdate**](CostingUpdate.md)|  | 

### Return type

[**BookkeepingConfiguration**](BookkeepingConfiguration.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **bookkeepingExportAccounting**
> String bookkeepingExportAccounting(outletId, from, to)

One summary row per outlet and period. Profit fields are blank when unavailable.

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = BookkeepingApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final from = 2013-10-20; // DateTime | Inclusive outlet-local date. Maximum 366-day range.
final to = 2013-10-20; // DateTime | Inclusive outlet-local date. Maximum 366-day range.

try {
    final result = api_instance.bookkeepingExportAccounting(outletId, from, to);
    print(result);
} catch (e) {
    print('Exception when calling BookkeepingApi->bookkeepingExportAccounting: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **from** | **DateTime**| Inclusive outlet-local date. Maximum 366-day range. | 
 **to** | **DateTime**| Inclusive outlet-local date. Maximum 366-day range. | 

### Return type

**String**

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: text/csv, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **bookkeepingExportPayments**
> String bookkeepingExportPayments(outletId, from, to)

One row per payment on a completed sale in the outlet-local period.

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = BookkeepingApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final from = 2013-10-20; // DateTime | Inclusive outlet-local date. Maximum 366-day range.
final to = 2013-10-20; // DateTime | Inclusive outlet-local date. Maximum 366-day range.

try {
    final result = api_instance.bookkeepingExportPayments(outletId, from, to);
    print(result);
} catch (e) {
    print('Exception when calling BookkeepingApi->bookkeepingExportPayments: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **from** | **DateTime**| Inclusive outlet-local date. Maximum 366-day range. | 
 **to** | **DateTime**| Inclusive outlet-local date. Maximum 366-day range. | 

### Return type

**String**

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: text/csv, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **bookkeepingExportReversals**
> String bookkeepingExportReversals(outletId, from, to)

One row per reversal in the outlet-local period.

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = BookkeepingApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final from = 2013-10-20; // DateTime | Inclusive outlet-local date. Maximum 366-day range.
final to = 2013-10-20; // DateTime | Inclusive outlet-local date. Maximum 366-day range.

try {
    final result = api_instance.bookkeepingExportReversals(outletId, from, to);
    print(result);
} catch (e) {
    print('Exception when calling BookkeepingApi->bookkeepingExportReversals: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **from** | **DateTime**| Inclusive outlet-local date. Maximum 366-day range. | 
 **to** | **DateTime**| Inclusive outlet-local date. Maximum 366-day range. | 

### Return type

**String**

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: text/csv, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **bookkeepingExportSales**
> String bookkeepingExportSales(outletId, from, to)

Completed sale and reversal rows; same query and money rules as the daily report.

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = BookkeepingApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final from = 2013-10-20; // DateTime | Inclusive outlet-local date. Maximum 366-day range.
final to = 2013-10-20; // DateTime | Inclusive outlet-local date. Maximum 366-day range.

try {
    final result = api_instance.bookkeepingExportSales(outletId, from, to);
    print(result);
} catch (e) {
    print('Exception when calling BookkeepingApi->bookkeepingExportSales: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **from** | **DateTime**| Inclusive outlet-local date. Maximum 366-day range. | 
 **to** | **DateTime**| Inclusive outlet-local date. Maximum 366-day range. | 

### Return type

**String**

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: text/csv, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **bookkeepingGet**
> BookkeepingConfiguration bookkeepingGet(outletId)

Read costing and expense category configuration

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = BookkeepingApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.bookkeepingGet(outletId);
    print(result);
} catch (e) {
    print('Exception when calling BookkeepingApi->bookkeepingGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 

### Return type

[**BookkeepingConfiguration**](BookkeepingConfiguration.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **bookkeepingProfit**
> ProfitReport bookkeepingProfit(outletId, from, to)

Read profit and margin with explicit availability gate

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = BookkeepingApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final from = 2013-10-20; // DateTime | Inclusive outlet-local date. Maximum 366-day range.
final to = 2013-10-20; // DateTime | Inclusive outlet-local date. Maximum 366-day range.

try {
    final result = api_instance.bookkeepingProfit(outletId, from, to);
    print(result);
} catch (e) {
    print('Exception when calling BookkeepingApi->bookkeepingProfit: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **from** | **DateTime**| Inclusive outlet-local date. Maximum 366-day range. | 
 **to** | **DateTime**| Inclusive outlet-local date. Maximum 366-day range. | 

### Return type

[**ProfitReport**](ProfitReport.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **expenseCategoriesCreate**
> ExpenseCategory expenseCategoriesCreate(outletId, expenseCategoryWrite)

Create an expense category

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = BookkeepingApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final expenseCategoryWrite = ExpenseCategoryWrite(); // ExpenseCategoryWrite | 

try {
    final result = api_instance.expenseCategoriesCreate(outletId, expenseCategoryWrite);
    print(result);
} catch (e) {
    print('Exception when calling BookkeepingApi->expenseCategoriesCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **expenseCategoryWrite** | [**ExpenseCategoryWrite**](ExpenseCategoryWrite.md)|  | 

### Return type

[**ExpenseCategory**](ExpenseCategory.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **expenseCategoriesList**
> ExpenseCategoryList expenseCategoriesList(outletId)

List active expense categories

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = BookkeepingApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.expenseCategoriesList(outletId);
    print(result);
} catch (e) {
    print('Exception when calling BookkeepingApi->expenseCategoriesList: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 

### Return type

[**ExpenseCategoryList**](ExpenseCategoryList.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **expensesCreate**
> Expense expensesCreate(outletId, expenseWrite)

Record a manual operating expense

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = BookkeepingApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final expenseWrite = ExpenseWrite(); // ExpenseWrite | 

try {
    final result = api_instance.expensesCreate(outletId, expenseWrite);
    print(result);
} catch (e) {
    print('Exception when calling BookkeepingApi->expensesCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **expenseWrite** | [**ExpenseWrite**](ExpenseWrite.md)|  | 

### Return type

[**Expense**](Expense.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **expensesList**
> ExpensePage expensesList(outletId, from, to, limit)

List manual operating expenses

### Example
```dart
import 'package:modern_pos_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = BookkeepingApi();
final outletId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final from = 2013-10-20; // DateTime | 
final to = 2013-10-20; // DateTime | 
final limit = 56; // int | 

try {
    final result = api_instance.expensesList(outletId, from, to, limit);
    print(result);
} catch (e) {
    print('Exception when calling BookkeepingApi->expensesList: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **outletId** | **String**|  | 
 **from** | **DateTime**|  | [optional] 
 **to** | **DateTime**|  | [optional] 
 **limit** | **int**|  | [optional] 

### Return type

[**ExpensePage**](ExpensePage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

