//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

library openapi.api;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

part 'api_client.dart';
part 'api_helper.dart';
part 'api_exception.dart';
part 'auth/authentication.dart';
part 'auth/api_key_auth.dart';
part 'auth/oauth.dart';
part 'auth/http_basic_auth.dart';
part 'auth/http_bearer_auth.dart';

part 'api/approvals_api.dart';
part 'api/attendance_api.dart';
part 'api/audit_api.dart';
part 'api/auth_api.dart';
part 'api/catalog_api.dart';
part 'api/device_api.dart';
part 'api/order_api.dart';
part 'api/outlet_api.dart';
part 'api/payments_api.dart';
part 'api/permissions_api.dart';
part 'api/printing_api.dart';
part 'api/promotions_api.dart';
part 'api/purchasing_api.dart';
part 'api/recipe_api.dart';
part 'api/reports_api.dart';
part 'api/sales_api.dart';
part 'api/sandbox_api.dart';
part 'api/settings_api.dart';
part 'api/shifts_api.dart';
part 'api/stock_api.dart';
part 'api/table_api.dart';

part 'model/adjustment.dart';
part 'model/approval_rule.dart';
part 'model/approval_rule_write.dart';
part 'model/attendance_page.dart';
part 'model/attendance_record.dart';
part 'model/attendance_write.dart';
part 'model/audit_entry.dart';
part 'model/audit_page.dart';
part 'model/auth_mobile_refresh_request.dart';
part 'model/auth_web_login_request.dart';
part 'model/calculation_rules.dart';
part 'model/catalog_archive_request.dart';
part 'model/category.dart';
part 'model/category_write.dart';
part 'model/daily_report.dart';
part 'model/daily_report_payment_breakdown_inner.dart';
part 'model/daily_report_top_items_inner.dart';
part 'model/device.dart';
part 'model/device_create_request.dart';
part 'model/error.dart';
part 'model/finalize.dart';
part 'model/finalized.dart';
part 'model/line_modifier.dart';
part 'model/line_modifier_write.dart';
part 'model/login.dart';
part 'model/menu.dart';
part 'model/menu_page.dart';
part 'model/menu_update.dart';
part 'model/menu_write.dart';
part 'model/mobile_session.dart';
part 'model/modifier.dart';
part 'model/modifier_write.dart';
part 'model/movement.dart';
part 'model/movement_page.dart';
part 'model/online_payment.dart';
part 'model/online_payment_list.dart';
part 'model/online_payment_list_item.dart';
part 'model/operation_audit_entry.dart';
part 'model/operation_audit_page.dart';
part 'model/order.dart';
part 'model/order_cancel_request.dart';
part 'model/order_page.dart';
part 'model/order_quote_request.dart';
part 'model/order_update.dart';
part 'model/order_write.dart';
part 'model/order_write_lines_inner.dart';
part 'model/outlet.dart';
part 'model/outlet_transfer.dart';
part 'model/outlet_transfer_line.dart';
part 'model/outlet_transfer_line_write.dart';
part 'model/outlet_transfer_mutation.dart';
part 'model/outlet_transfer_page.dart';
part 'model/outlet_transfer_receive_line_write.dart';
part 'model/outlet_transfer_receive_write.dart';
part 'model/outlet_transfer_write.dart';
part 'model/outlet_update.dart';
part 'model/payment.dart';
part 'model/payment_input.dart';
part 'model/permission_matrix.dart';
part 'model/permission_matrix_operations_inner.dart';
part 'model/permission_matrix_roles_inner.dart';
part 'model/print_job.dart';
part 'model/print_job_write.dart';
part 'model/printer.dart';
part 'model/printer_write.dart';
part 'model/printing_state_request.dart';
part 'model/printing_update_request.dart';
part 'model/promotion.dart';
part 'model/promotion_eligibility.dart';
part 'model/promotion_snapshot.dart';
part 'model/promotion_update.dart';
part 'model/promotion_write.dart';
part 'model/purchase_order.dart';
part 'model/purchase_order_line.dart';
part 'model/purchase_order_line_write.dart';
part 'model/purchase_order_page.dart';
part 'model/purchase_order_receipt.dart';
part 'model/purchase_order_receipt_write.dart';
part 'model/purchase_order_write.dart';
part 'model/quote.dart';
part 'model/quote_lines_inner.dart';
part 'model/recipe.dart';
part 'model/recipe_line.dart';
part 'model/recipe_write.dart';
part 'model/reconciliation_summary.dart';
part 'model/reconciliation_summary_errors_inner.dart';
part 'model/refund_line.dart';
part 'model/restock.dart';
part 'model/reversal.dart';
part 'model/reversal_write.dart';
part 'model/sale.dart';
part 'model/sale_line.dart';
part 'model/sale_page.dart';
part 'model/sandbox_event_result.dart';
part 'model/sandbox_event_write.dart';
part 'model/sandbox_payment.dart';
part 'model/sandbox_payment_write.dart';
part 'model/settings.dart';
part 'model/settings_update.dart';
part 'model/settlement_day.dart';
part 'model/settlement_payment.dart';
part 'model/settlement_report.dart';
part 'model/shift.dart';
part 'model/shift_cash_movement_write.dart';
part 'model/shift_close_write.dart';
part 'model/shift_movement.dart';
part 'model/shift_page.dart';
part 'model/shift_report.dart';
part 'model/shift_tender_total.dart';
part 'model/shift_write.dart';
part 'model/split_bill.dart';
part 'model/split_result.dart';
part 'model/split_write.dart';
part 'model/stock.dart';
part 'model/stock_change.dart';
part 'model/stock_count.dart';
part 'model/stock_count_line.dart';
part 'model/stock_count_line_write.dart';
part 'model/stock_count_page.dart';
part 'model/stock_count_write.dart';
part 'model/stock_page.dart';
part 'model/stock_write.dart';
part 'model/supplier.dart';
part 'model/supplier_page.dart';
part 'model/supplier_write.dart';
part 'model/table.dart';
part 'model/table_page.dart';
part 'model/table_write.dart';
part 'model/totals.dart';
part 'model/transfer_write.dart';
part 'model/user.dart';
part 'model/variant.dart';
part 'model/variant_update.dart';
part 'model/variant_write.dart';
part 'model/waste.dart';
part 'model/waste_page.dart';
part 'model/waste_write.dart';
part 'model/web_session.dart';
part 'model/webhook_ack.dart';


/// An [ApiClient] instance that uses the default values obtained from
/// the OpenAPI specification file.
var defaultApiClient = ApiClient();

const _delimiters = {'csv': ',', 'ssv': ' ', 'tsv': '\t', 'pipes': '|'};
const _dateEpochMarker = 'epoch';
const _deepEquality = DeepCollectionEquality();
final _dateFormatter = DateFormat('yyyy-MM-dd');
final _regList = RegExp(r'^List<(.*)>$');
final _regSet = RegExp(r'^Set<(.*)>$');
final _regMap = RegExp(r'^Map<String,(.*)>$');

bool _isEpochMarker(String? pattern) => pattern == _dateEpochMarker || pattern == '/$_dateEpochMarker/';
