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

part 'api/auth_api.dart';
part 'api/catalog_api.dart';
part 'api/device_api.dart';
part 'api/order_api.dart';
part 'api/outlet_api.dart';
part 'api/printing_api.dart';
part 'api/recipe_api.dart';
part 'api/reports_api.dart';
part 'api/sales_api.dart';
part 'api/settings_api.dart';
part 'api/stock_api.dart';

part 'model/adjustment.dart';
part 'model/auth_mobile_refresh_request.dart';
part 'model/auth_web_login_request.dart';
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
part 'model/login.dart';
part 'model/menu.dart';
part 'model/menu_page.dart';
part 'model/menu_update.dart';
part 'model/menu_write.dart';
part 'model/mobile_session.dart';
part 'model/movement.dart';
part 'model/movement_page.dart';
part 'model/order.dart';
part 'model/order_cancel_request.dart';
part 'model/order_quote_request.dart';
part 'model/order_update.dart';
part 'model/order_write.dart';
part 'model/order_write_lines_inner.dart';
part 'model/outlet.dart';
part 'model/outlet_update.dart';
part 'model/payment.dart';
part 'model/payment_input.dart';
part 'model/print_job.dart';
part 'model/print_job_write.dart';
part 'model/printer.dart';
part 'model/printer_write.dart';
part 'model/printing_state_request.dart';
part 'model/printing_update_request.dart';
part 'model/quote.dart';
part 'model/quote_lines_inner.dart';
part 'model/recipe.dart';
part 'model/recipe_line.dart';
part 'model/recipe_write.dart';
part 'model/restock.dart';
part 'model/reversal.dart';
part 'model/reversal_write.dart';
part 'model/sale.dart';
part 'model/sale_line.dart';
part 'model/sale_page.dart';
part 'model/settings.dart';
part 'model/settings_update.dart';
part 'model/stock.dart';
part 'model/stock_change.dart';
part 'model/stock_page.dart';
part 'model/stock_write.dart';
part 'model/totals.dart';
part 'model/user.dart';
part 'model/variant.dart';
part 'model/variant_update.dart';
part 'model/variant_write.dart';
part 'model/web_session.dart';


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
