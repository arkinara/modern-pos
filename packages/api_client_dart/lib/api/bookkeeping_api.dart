//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class BookkeepingApi {
  BookkeepingApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Read consolidated owner view across all scoped outlets
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [DateTime] from (required):
  ///   Inclusive outlet-local date. Maximum 366-day range.
  ///
  /// * [DateTime] to (required):
  ///   Inclusive outlet-local date. Maximum 366-day range.
  Future<Response> bookkeepingConsolidatedWithHttpInfo(String outletId, DateTime from, DateTime to, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/bookkeeping/consolidated'
      .replaceAll('{outletId}', outletId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

      queryParams.addAll(_queryParams('', 'from', from));
      queryParams.addAll(_queryParams('', 'to', to));

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Read consolidated owner view across all scoped outlets
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [DateTime] from (required):
  ///   Inclusive outlet-local date. Maximum 366-day range.
  ///
  /// * [DateTime] to (required):
  ///   Inclusive outlet-local date. Maximum 366-day range.
  Future<ConsolidatedReport?> bookkeepingConsolidated(String outletId, DateTime from, DateTime to, { Future<void>? abortTrigger, }) async {
    final response = await bookkeepingConsolidatedWithHttpInfo(outletId, from, to, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ConsolidatedReport',) as ConsolidatedReport;
    
    }
    return null;
  }

  /// Set the outlet inventory costing method
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [CostingUpdate] costingUpdate (required):
  Future<Response> bookkeepingCostingUpdateWithHttpInfo(String outletId, CostingUpdate costingUpdate, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/bookkeeping/costing'
      .replaceAll('{outletId}', outletId);

    // ignore: prefer_final_locals
    Object? postBody = costingUpdate;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'PUT',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Set the outlet inventory costing method
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [CostingUpdate] costingUpdate (required):
  Future<BookkeepingConfiguration?> bookkeepingCostingUpdate(String outletId, CostingUpdate costingUpdate, { Future<void>? abortTrigger, }) async {
    final response = await bookkeepingCostingUpdateWithHttpInfo(outletId, costingUpdate, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'BookkeepingConfiguration',) as BookkeepingConfiguration;
    
    }
    return null;
  }

  /// One summary row per outlet and period. Profit fields are blank when unavailable.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [DateTime] from (required):
  ///   Inclusive outlet-local date. Maximum 366-day range.
  ///
  /// * [DateTime] to (required):
  ///   Inclusive outlet-local date. Maximum 366-day range.
  Future<Response> bookkeepingExportAccountingWithHttpInfo(String outletId, DateTime from, DateTime to, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/bookkeeping/exports/accounting.csv'
      .replaceAll('{outletId}', outletId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

      queryParams.addAll(_queryParams('', 'from', from));
      queryParams.addAll(_queryParams('', 'to', to));

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// One summary row per outlet and period. Profit fields are blank when unavailable.
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [DateTime] from (required):
  ///   Inclusive outlet-local date. Maximum 366-day range.
  ///
  /// * [DateTime] to (required):
  ///   Inclusive outlet-local date. Maximum 366-day range.
  Future<String?> bookkeepingExportAccounting(String outletId, DateTime from, DateTime to, { Future<void>? abortTrigger, }) async {
    final response = await bookkeepingExportAccountingWithHttpInfo(outletId, from, to, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'String',) as String;
    
    }
    return null;
  }

  /// One row per payment on a completed sale in the outlet-local period.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [DateTime] from (required):
  ///   Inclusive outlet-local date. Maximum 366-day range.
  ///
  /// * [DateTime] to (required):
  ///   Inclusive outlet-local date. Maximum 366-day range.
  Future<Response> bookkeepingExportPaymentsWithHttpInfo(String outletId, DateTime from, DateTime to, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/bookkeeping/exports/payments.csv'
      .replaceAll('{outletId}', outletId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

      queryParams.addAll(_queryParams('', 'from', from));
      queryParams.addAll(_queryParams('', 'to', to));

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// One row per payment on a completed sale in the outlet-local period.
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [DateTime] from (required):
  ///   Inclusive outlet-local date. Maximum 366-day range.
  ///
  /// * [DateTime] to (required):
  ///   Inclusive outlet-local date. Maximum 366-day range.
  Future<String?> bookkeepingExportPayments(String outletId, DateTime from, DateTime to, { Future<void>? abortTrigger, }) async {
    final response = await bookkeepingExportPaymentsWithHttpInfo(outletId, from, to, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'String',) as String;
    
    }
    return null;
  }

  /// One row per reversal in the outlet-local period.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [DateTime] from (required):
  ///   Inclusive outlet-local date. Maximum 366-day range.
  ///
  /// * [DateTime] to (required):
  ///   Inclusive outlet-local date. Maximum 366-day range.
  Future<Response> bookkeepingExportReversalsWithHttpInfo(String outletId, DateTime from, DateTime to, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/bookkeeping/exports/reversals.csv'
      .replaceAll('{outletId}', outletId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

      queryParams.addAll(_queryParams('', 'from', from));
      queryParams.addAll(_queryParams('', 'to', to));

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// One row per reversal in the outlet-local period.
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [DateTime] from (required):
  ///   Inclusive outlet-local date. Maximum 366-day range.
  ///
  /// * [DateTime] to (required):
  ///   Inclusive outlet-local date. Maximum 366-day range.
  Future<String?> bookkeepingExportReversals(String outletId, DateTime from, DateTime to, { Future<void>? abortTrigger, }) async {
    final response = await bookkeepingExportReversalsWithHttpInfo(outletId, from, to, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'String',) as String;
    
    }
    return null;
  }

  /// Completed sale and reversal rows; same query and money rules as the daily report.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [DateTime] from (required):
  ///   Inclusive outlet-local date. Maximum 366-day range.
  ///
  /// * [DateTime] to (required):
  ///   Inclusive outlet-local date. Maximum 366-day range.
  Future<Response> bookkeepingExportSalesWithHttpInfo(String outletId, DateTime from, DateTime to, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/bookkeeping/exports/sales.csv'
      .replaceAll('{outletId}', outletId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

      queryParams.addAll(_queryParams('', 'from', from));
      queryParams.addAll(_queryParams('', 'to', to));

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Completed sale and reversal rows; same query and money rules as the daily report.
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [DateTime] from (required):
  ///   Inclusive outlet-local date. Maximum 366-day range.
  ///
  /// * [DateTime] to (required):
  ///   Inclusive outlet-local date. Maximum 366-day range.
  Future<String?> bookkeepingExportSales(String outletId, DateTime from, DateTime to, { Future<void>? abortTrigger, }) async {
    final response = await bookkeepingExportSalesWithHttpInfo(outletId, from, to, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'String',) as String;
    
    }
    return null;
  }

  /// Read costing and expense category configuration
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  Future<Response> bookkeepingGetWithHttpInfo(String outletId, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/bookkeeping'
      .replaceAll('{outletId}', outletId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Read costing and expense category configuration
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  Future<BookkeepingConfiguration?> bookkeepingGet(String outletId, { Future<void>? abortTrigger, }) async {
    final response = await bookkeepingGetWithHttpInfo(outletId, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'BookkeepingConfiguration',) as BookkeepingConfiguration;
    
    }
    return null;
  }

  /// Read profit and margin with explicit availability gate
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [DateTime] from (required):
  ///   Inclusive outlet-local date. Maximum 366-day range.
  ///
  /// * [DateTime] to (required):
  ///   Inclusive outlet-local date. Maximum 366-day range.
  Future<Response> bookkeepingProfitWithHttpInfo(String outletId, DateTime from, DateTime to, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/bookkeeping/profit'
      .replaceAll('{outletId}', outletId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

      queryParams.addAll(_queryParams('', 'from', from));
      queryParams.addAll(_queryParams('', 'to', to));

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Read profit and margin with explicit availability gate
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [DateTime] from (required):
  ///   Inclusive outlet-local date. Maximum 366-day range.
  ///
  /// * [DateTime] to (required):
  ///   Inclusive outlet-local date. Maximum 366-day range.
  Future<ProfitReport?> bookkeepingProfit(String outletId, DateTime from, DateTime to, { Future<void>? abortTrigger, }) async {
    final response = await bookkeepingProfitWithHttpInfo(outletId, from, to, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ProfitReport',) as ProfitReport;
    
    }
    return null;
  }

  /// Create an expense category
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [ExpenseCategoryWrite] expenseCategoryWrite (required):
  Future<Response> expenseCategoriesCreateWithHttpInfo(String outletId, ExpenseCategoryWrite expenseCategoryWrite, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/bookkeeping/expense-categories'
      .replaceAll('{outletId}', outletId);

    // ignore: prefer_final_locals
    Object? postBody = expenseCategoryWrite;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Create an expense category
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [ExpenseCategoryWrite] expenseCategoryWrite (required):
  Future<ExpenseCategory?> expenseCategoriesCreate(String outletId, ExpenseCategoryWrite expenseCategoryWrite, { Future<void>? abortTrigger, }) async {
    final response = await expenseCategoriesCreateWithHttpInfo(outletId, expenseCategoryWrite, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ExpenseCategory',) as ExpenseCategory;
    
    }
    return null;
  }

  /// List active expense categories
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  Future<Response> expenseCategoriesListWithHttpInfo(String outletId, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/bookkeeping/expense-categories'
      .replaceAll('{outletId}', outletId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// List active expense categories
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  Future<ExpenseCategoryList?> expenseCategoriesList(String outletId, { Future<void>? abortTrigger, }) async {
    final response = await expenseCategoriesListWithHttpInfo(outletId, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ExpenseCategoryList',) as ExpenseCategoryList;
    
    }
    return null;
  }

  /// Record a manual operating expense
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [ExpenseWrite] expenseWrite (required):
  Future<Response> expensesCreateWithHttpInfo(String outletId, ExpenseWrite expenseWrite, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/bookkeeping/expenses'
      .replaceAll('{outletId}', outletId);

    // ignore: prefer_final_locals
    Object? postBody = expenseWrite;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Record a manual operating expense
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [ExpenseWrite] expenseWrite (required):
  Future<Expense?> expensesCreate(String outletId, ExpenseWrite expenseWrite, { Future<void>? abortTrigger, }) async {
    final response = await expensesCreateWithHttpInfo(outletId, expenseWrite, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Expense',) as Expense;
    
    }
    return null;
  }

  /// List manual operating expenses
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [DateTime] from:
  ///
  /// * [DateTime] to:
  ///
  /// * [int] limit:
  Future<Response> expensesListWithHttpInfo(String outletId, { DateTime? from, DateTime? to, int? limit, Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/bookkeeping/expenses'
      .replaceAll('{outletId}', outletId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (from != null) {
      queryParams.addAll(_queryParams('', 'from', from));
    }
    if (to != null) {
      queryParams.addAll(_queryParams('', 'to', to));
    }
    if (limit != null) {
      queryParams.addAll(_queryParams('', 'limit', limit));
    }

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// List manual operating expenses
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [DateTime] from:
  ///
  /// * [DateTime] to:
  ///
  /// * [int] limit:
  Future<ExpensePage?> expensesList(String outletId, { DateTime? from, DateTime? to, int? limit, Future<void>? abortTrigger, }) async {
    final response = await expensesListWithHttpInfo(outletId, from: from, to: to, limit: limit, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ExpensePage',) as ExpensePage;
    
    }
    return null;
  }
}
