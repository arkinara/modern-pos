//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

import 'package:modern_pos_api_client/api.dart';
import 'package:test/test.dart';


/// tests for BookkeepingApi
void main() {
  // final instance = BookkeepingApi();

  group('tests for BookkeepingApi', () {
    // Read consolidated owner view across all scoped outlets
    //
    //Future<ConsolidatedReport> bookkeepingConsolidated(String outletId, DateTime from, DateTime to) async
    test('test bookkeepingConsolidated', () async {
      // TODO
    });

    // Set the outlet inventory costing method
    //
    //Future<BookkeepingConfiguration> bookkeepingCostingUpdate(String outletId, CostingUpdate costingUpdate) async
    test('test bookkeepingCostingUpdate', () async {
      // TODO
    });

    // One summary row per outlet and period. Profit fields are blank when unavailable.
    //
    //Future<String> bookkeepingExportAccounting(String outletId, DateTime from, DateTime to) async
    test('test bookkeepingExportAccounting', () async {
      // TODO
    });

    // One row per payment on a completed sale in the outlet-local period.
    //
    //Future<String> bookkeepingExportPayments(String outletId, DateTime from, DateTime to) async
    test('test bookkeepingExportPayments', () async {
      // TODO
    });

    // One row per reversal in the outlet-local period.
    //
    //Future<String> bookkeepingExportReversals(String outletId, DateTime from, DateTime to) async
    test('test bookkeepingExportReversals', () async {
      // TODO
    });

    // Completed sale and reversal rows; same query and money rules as the daily report.
    //
    //Future<String> bookkeepingExportSales(String outletId, DateTime from, DateTime to) async
    test('test bookkeepingExportSales', () async {
      // TODO
    });

    // Read costing and expense category configuration
    //
    //Future<BookkeepingConfiguration> bookkeepingGet(String outletId) async
    test('test bookkeepingGet', () async {
      // TODO
    });

    // Read profit and margin with explicit availability gate
    //
    //Future<ProfitReport> bookkeepingProfit(String outletId, DateTime from, DateTime to) async
    test('test bookkeepingProfit', () async {
      // TODO
    });

    // Create an expense category
    //
    //Future<ExpenseCategory> expenseCategoriesCreate(String outletId, ExpenseCategoryWrite expenseCategoryWrite) async
    test('test expenseCategoriesCreate', () async {
      // TODO
    });

    // List active expense categories
    //
    //Future<ExpenseCategoryList> expenseCategoriesList(String outletId) async
    test('test expenseCategoriesList', () async {
      // TODO
    });

    // Record a manual operating expense
    //
    //Future<Expense> expensesCreate(String outletId, ExpenseWrite expenseWrite) async
    test('test expensesCreate', () async {
      // TODO
    });

    // List manual operating expenses
    //
    //Future<ExpensePage> expensesList(String outletId, { DateTime from, DateTime to, int limit }) async
    test('test expensesList', () async {
      // TODO
    });

  });
}
