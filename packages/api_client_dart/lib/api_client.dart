//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ApiClient {
  ApiClient({this.basePath = '/v1', this.authentication,});

  final String basePath;
  final Authentication? authentication;

  var _client = Client();
  final _defaultHeaderMap = <String, String>{};

  /// Returns the current HTTP [Client] instance to use in this class.
  ///
  /// The return value is guaranteed to never be null.
  Client get client => _client;

  /// Requests to use a new HTTP [Client] in this class.
  set client(Client newClient) {
    _client = newClient;
  }

  Map<String, String> get defaultHeaderMap => _defaultHeaderMap;

  void addDefaultHeader(String key, String value) {
     _defaultHeaderMap[key] = value;
  }

  // We don't use a Map<String, String> for queryParams.
  // If collectionFormat is 'multi', a key might appear multiple times.
  Future<Response> invokeAPI(
    String path,
    String method,
    List<QueryParam> queryParams,
    Object? body,
    Map<String, String> headerParams,
    Map<String, String> formParams,
    String? contentType, {
    Future<void>? abortTrigger,
  }) async {
    await authentication?.applyToParams(queryParams, headerParams);

    headerParams.addAll(_defaultHeaderMap);
    if (contentType != null) {
      headerParams['Content-Type'] = contentType;
    }

    final urlEncodedQueryParams = queryParams.map((param) => '$param');
    final queryString = urlEncodedQueryParams.isNotEmpty ? '?${urlEncodedQueryParams.join('&')}' : '';
    final uri = Uri.parse('$basePath$path$queryString');

    try {
      // Special case for uploading a single file which isn't a 'multipart/form-data'.
      if (
        body is MultipartFile && (contentType == null ||
        !contentType.toLowerCase().startsWith('multipart/form-data'))
      ) {
        final request = AbortableStreamedRequest(method, uri, abortTrigger: abortTrigger);
        request.headers.addAll(headerParams);
        request.contentLength = body.length;
        body.finalize().listen(
          request.sink.add,
          onDone: request.sink.close,
          // ignore: avoid_types_on_closure_parameters
          onError: (Object error, StackTrace trace) => request.sink.close(),
          cancelOnError: true,
        );
        final response = await _client.send(request);
        return Response.fromStream(response);
      }

      if (body is MultipartRequest) {
        final request = AbortableMultipartRequest(method, uri, abortTrigger: abortTrigger);
        request.fields.addAll(body.fields);
        request.files.addAll(body.files);
        request.headers.addAll(body.headers);
        request.headers.addAll(headerParams);
        final response = await _client.send(request);
        return Response.fromStream(response);
      }

      final msgBody = contentType == 'application/x-www-form-urlencoded'
        ? formParams
        : await serializeAsync(body);
      final nullableHeaderParams = headerParams.isEmpty ? null : headerParams;

      final request = AbortableRequest(method, uri, abortTrigger: abortTrigger);
      if (nullableHeaderParams != null) {
        request.headers.addAll(nullableHeaderParams);
      }
      if (msgBody is String && msgBody.isNotEmpty) {
        request.body = msgBody;
      } else if (msgBody is List<int> && msgBody.isNotEmpty) {
        request.bodyBytes = msgBody;
      } else if (msgBody is Map<String, String>) {
        request.bodyFields = msgBody;
      }
      final response = await _client.send(request);
      return Response.fromStream(response);
    } on SocketException catch (error, trace) {
      throw ApiException.withInner(
        HttpStatus.badRequest,
        'Socket operation failed: $method $path',
        error,
        trace,
      );
    } on TlsException catch (error, trace) {
      throw ApiException.withInner(
        HttpStatus.badRequest,
        'TLS/SSL communication failed: $method $path',
        error,
        trace,
      );
    } on IOException catch (error, trace) {
      throw ApiException.withInner(
        HttpStatus.badRequest,
        'I/O operation failed: $method $path',
        error,
        trace,
      );
    } on ClientException catch (error, trace) {
      throw ApiException.withInner(
        HttpStatus.badRequest,
        'HTTP connection failed: $method $path',
        error,
        trace,
      );
    } on Exception catch (error, trace) {
      throw ApiException.withInner(
        HttpStatus.badRequest,
        'Exception occurred: $method $path',
        error,
        trace,
      );
    }
  }

  Future<dynamic> deserializeAsync(String value, String targetType, {bool growable = false,}) async =>
    // ignore: deprecated_member_use_from_same_package
    deserialize(value, targetType, growable: growable);

  @Deprecated('Scheduled for removal in OpenAPI Generator 6.x. Use deserializeAsync() instead.')
  dynamic deserialize(String value, String targetType, {bool growable = false,}) {
    // Remove all spaces. Necessary for regular expressions as well.
    targetType = targetType.replaceAll(' ', ''); // ignore: parameter_assignments

    // If the expected target type is String, nothing to do...
    return targetType == 'String'
      ? value
      : fromJson(json.decode(value), targetType, growable: growable);
  }

  // ignore: deprecated_member_use_from_same_package
  Future<String> serializeAsync(Object? value) async => serialize(value);

  @Deprecated('Scheduled for removal in OpenAPI Generator 6.x. Use serializeAsync() instead.')
  String serialize(Object? value) => value == null ? '' : json.encode(value);

  /// Returns a native instance of an OpenAPI class matching the [specified type][targetType].
  static dynamic fromJson(dynamic value, String targetType, {bool growable = false,}) {
    try {
      switch (targetType) {
        case 'String':
          return value is String ? value : value.toString();
        case 'int':
          return value is int ? value : int.parse('$value');
        case 'double':
          return value is double ? value : double.parse('$value');
        case 'bool':
          if (value is bool) {
            return value;
          }
          final valueString = '$value'.toLowerCase();
          return valueString == 'true' || valueString == '1';
        case 'DateTime':
          return value is DateTime ? value : DateTime.tryParse(value);
        case 'Adjustment':
          return Adjustment.fromJson(value);
        case 'ApprovalRule':
          return ApprovalRule.fromJson(value);
        case 'ApprovalRuleWrite':
          return ApprovalRuleWrite.fromJson(value);
        case 'AttendancePage':
          return AttendancePage.fromJson(value);
        case 'AttendanceRecord':
          return AttendanceRecord.fromJson(value);
        case 'AttendanceWrite':
          return AttendanceWrite.fromJson(value);
        case 'AuditEntry':
          return AuditEntry.fromJson(value);
        case 'AuditPage':
          return AuditPage.fromJson(value);
        case 'AuthMobileRefreshRequest':
          return AuthMobileRefreshRequest.fromJson(value);
        case 'AuthWebLoginRequest':
          return AuthWebLoginRequest.fromJson(value);
        case 'BookkeepingConfiguration':
          return BookkeepingConfiguration.fromJson(value);
        case 'CalculationRules':
          return CalculationRules.fromJson(value);
        case 'CatalogArchiveRequest':
          return CatalogArchiveRequest.fromJson(value);
        case 'Category':
          return Category.fromJson(value);
        case 'CategoryWrite':
          return CategoryWrite.fromJson(value);
        case 'ChannelCustomerInput':
          return ChannelCustomerInput.fromJson(value);
        case 'ChannelDescriptor':
          return ChannelDescriptor.fromJson(value);
        case 'ChannelList':
          return ChannelList.fromJson(value);
        case 'ChannelListWebhook':
          return ChannelListWebhook.fromJson(value);
        case 'ChannelOrder':
          return ChannelOrder.fromJson(value);
        case 'ChannelOrderCancelWrite':
          return ChannelOrderCancelWrite.fromJson(value);
        case 'ChannelOrderCreateResult':
          return ChannelOrderCreateResult.fromJson(value);
        case 'ChannelOrderEvent':
          return ChannelOrderEvent.fromJson(value);
        case 'ChannelOrderFulfillWrite':
          return ChannelOrderFulfillWrite.fromJson(value);
        case 'ChannelOrderLine':
          return ChannelOrderLine.fromJson(value);
        case 'ChannelOrderLineInput':
          return ChannelOrderLineInput.fromJson(value);
        case 'ChannelOrderList':
          return ChannelOrderList.fromJson(value);
        case 'ChannelOrderManualWrite':
          return ChannelOrderManualWrite.fromJson(value);
        case 'ChannelOrderPayment':
          return ChannelOrderPayment.fromJson(value);
        case 'ChannelOrderState':
          return ChannelOrderStateTypeTransformer().decode(value);
        case 'ChannelOrderWebhookWrite':
          return ChannelOrderWebhookWrite.fromJson(value);
        case 'ChannelPaymentMode':
          return ChannelPaymentModeTypeTransformer().decode(value);
        case 'ChannelPaymentStatus':
          return ChannelPaymentStatusTypeTransformer().decode(value);
        case 'ConsolidatedOutlet':
          return ConsolidatedOutlet.fromJson(value);
        case 'ConsolidatedReport':
          return ConsolidatedReport.fromJson(value);
        case 'ConsolidatedReportConsolidated':
          return ConsolidatedReportConsolidated.fromJson(value);
        case 'CostingUpdate':
          return CostingUpdate.fromJson(value);
        case 'Customer':
          return Customer.fromJson(value);
        case 'CustomerList':
          return CustomerList.fromJson(value);
        case 'CustomerPurgeResult':
          return CustomerPurgeResult.fromJson(value);
        case 'CustomerRetentionPolicy':
          return CustomerRetentionPolicy.fromJson(value);
        case 'CustomerRetentionPolicyUpdate':
          return CustomerRetentionPolicyUpdate.fromJson(value);
        case 'CustomerWrite':
          return CustomerWrite.fromJson(value);
        case 'DailyReport':
          return DailyReport.fromJson(value);
        case 'DailyReportPaymentBreakdownInner':
          return DailyReportPaymentBreakdownInner.fromJson(value);
        case 'DailyReportTopItemsInner':
          return DailyReportTopItemsInner.fromJson(value);
        case 'Device':
          return Device.fromJson(value);
        case 'DeviceCreateRequest':
          return DeviceCreateRequest.fromJson(value);
        case 'DigitalReceipt':
          return DigitalReceipt.fromJson(value);
        case 'DigitalReceiptPublic':
          return DigitalReceiptPublic.fromJson(value);
        case 'Error':
          return Error.fromJson(value);
        case 'Expense':
          return Expense.fromJson(value);
        case 'ExpenseBreakdownEntry':
          return ExpenseBreakdownEntry.fromJson(value);
        case 'ExpenseCategory':
          return ExpenseCategory.fromJson(value);
        case 'ExpenseCategoryList':
          return ExpenseCategoryList.fromJson(value);
        case 'ExpenseCategoryWrite':
          return ExpenseCategoryWrite.fromJson(value);
        case 'ExpensePage':
          return ExpensePage.fromJson(value);
        case 'ExpenseWrite':
          return ExpenseWrite.fromJson(value);
        case 'Finalize':
          return Finalize.fromJson(value);
        case 'Finalized':
          return Finalized.fromJson(value);
        case 'LineModifier':
          return LineModifier.fromJson(value);
        case 'LineModifierWrite':
          return LineModifierWrite.fromJson(value);
        case 'Login':
          return Login.fromJson(value);
        case 'Menu':
          return Menu.fromJson(value);
        case 'MenuPage':
          return MenuPage.fromJson(value);
        case 'MenuUpdate':
          return MenuUpdate.fromJson(value);
        case 'MenuWrite':
          return MenuWrite.fromJson(value);
        case 'MobileSession':
          return MobileSession.fromJson(value);
        case 'Modifier':
          return Modifier.fromJson(value);
        case 'ModifierWrite':
          return ModifierWrite.fromJson(value);
        case 'Movement':
          return Movement.fromJson(value);
        case 'MovementPage':
          return MovementPage.fromJson(value);
        case 'OnlinePayment':
          return OnlinePayment.fromJson(value);
        case 'OnlinePaymentList':
          return OnlinePaymentList.fromJson(value);
        case 'OnlinePaymentListItem':
          return OnlinePaymentListItem.fromJson(value);
        case 'OperationAuditEntry':
          return OperationAuditEntry.fromJson(value);
        case 'OperationAuditPage':
          return OperationAuditPage.fromJson(value);
        case 'Order':
          return Order.fromJson(value);
        case 'OrderCancelRequest':
          return OrderCancelRequest.fromJson(value);
        case 'OrderChannel':
          return OrderChannelTypeTransformer().decode(value);
        case 'OrderPage':
          return OrderPage.fromJson(value);
        case 'OrderQuoteRequest':
          return OrderQuoteRequest.fromJson(value);
        case 'OrderUpdate':
          return OrderUpdate.fromJson(value);
        case 'OrderWrite':
          return OrderWrite.fromJson(value);
        case 'OrderWriteLinesInner':
          return OrderWriteLinesInner.fromJson(value);
        case 'Outlet':
          return Outlet.fromJson(value);
        case 'OutletList':
          return OutletList.fromJson(value);
        case 'OutletTransfer':
          return OutletTransfer.fromJson(value);
        case 'OutletTransferLine':
          return OutletTransferLine.fromJson(value);
        case 'OutletTransferLineWrite':
          return OutletTransferLineWrite.fromJson(value);
        case 'OutletTransferMutation':
          return OutletTransferMutation.fromJson(value);
        case 'OutletTransferPage':
          return OutletTransferPage.fromJson(value);
        case 'OutletTransferReceiveLineWrite':
          return OutletTransferReceiveLineWrite.fromJson(value);
        case 'OutletTransferReceiveWrite':
          return OutletTransferReceiveWrite.fromJson(value);
        case 'OutletTransferWrite':
          return OutletTransferWrite.fromJson(value);
        case 'OutletUpdate':
          return OutletUpdate.fromJson(value);
        case 'Payment':
          return Payment.fromJson(value);
        case 'PaymentBreakdownEntry':
          return PaymentBreakdownEntry.fromJson(value);
        case 'PaymentInput':
          return PaymentInput.fromJson(value);
        case 'PermissionMatrix':
          return PermissionMatrix.fromJson(value);
        case 'PermissionMatrixOperationsInner':
          return PermissionMatrixOperationsInner.fromJson(value);
        case 'PermissionMatrixRolesInner':
          return PermissionMatrixRolesInner.fromJson(value);
        case 'PrintJob':
          return PrintJob.fromJson(value);
        case 'PrintJobWrite':
          return PrintJobWrite.fromJson(value);
        case 'Printer':
          return Printer.fromJson(value);
        case 'PrinterWrite':
          return PrinterWrite.fromJson(value);
        case 'PrintingStateRequest':
          return PrintingStateRequest.fromJson(value);
        case 'PrintingUpdateRequest':
          return PrintingUpdateRequest.fromJson(value);
        case 'ProfitReport':
          return ProfitReport.fromJson(value);
        case 'ProfitReportCogs':
          return ProfitReportCogs.fromJson(value);
        case 'ProfitReportExpenses':
          return ProfitReportExpenses.fromJson(value);
        case 'ProfitReportRevenue':
          return ProfitReportRevenue.fromJson(value);
        case 'ProfitReportWaste':
          return ProfitReportWaste.fromJson(value);
        case 'Promotion':
          return Promotion.fromJson(value);
        case 'PromotionEligibility':
          return PromotionEligibility.fromJson(value);
        case 'PromotionSnapshot':
          return PromotionSnapshot.fromJson(value);
        case 'PromotionUpdate':
          return PromotionUpdate.fromJson(value);
        case 'PromotionWrite':
          return PromotionWrite.fromJson(value);
        case 'PurchaseOrder':
          return PurchaseOrder.fromJson(value);
        case 'PurchaseOrderLine':
          return PurchaseOrderLine.fromJson(value);
        case 'PurchaseOrderLineWrite':
          return PurchaseOrderLineWrite.fromJson(value);
        case 'PurchaseOrderPage':
          return PurchaseOrderPage.fromJson(value);
        case 'PurchaseOrderReceipt':
          return PurchaseOrderReceipt.fromJson(value);
        case 'PurchaseOrderReceiptWrite':
          return PurchaseOrderReceiptWrite.fromJson(value);
        case 'PurchaseOrderWrite':
          return PurchaseOrderWrite.fromJson(value);
        case 'Quote':
          return Quote.fromJson(value);
        case 'QuoteLinesInner':
          return QuoteLinesInner.fromJson(value);
        case 'ReceiptWrite':
          return ReceiptWrite.fromJson(value);
        case 'Recipe':
          return Recipe.fromJson(value);
        case 'RecipeLine':
          return RecipeLine.fromJson(value);
        case 'RecipeWrite':
          return RecipeWrite.fromJson(value);
        case 'ReconciliationSummary':
          return ReconciliationSummary.fromJson(value);
        case 'ReconciliationSummaryErrorsInner':
          return ReconciliationSummaryErrorsInner.fromJson(value);
        case 'RefundLine':
          return RefundLine.fromJson(value);
        case 'Restock':
          return Restock.fromJson(value);
        case 'Reversal':
          return Reversal.fromJson(value);
        case 'ReversalWrite':
          return ReversalWrite.fromJson(value);
        case 'Sale':
          return Sale.fromJson(value);
        case 'SaleLine':
          return SaleLine.fromJson(value);
        case 'SalePage':
          return SalePage.fromJson(value);
        case 'SandboxEventResult':
          return SandboxEventResult.fromJson(value);
        case 'SandboxEventWrite':
          return SandboxEventWrite.fromJson(value);
        case 'SandboxPayment':
          return SandboxPayment.fromJson(value);
        case 'SandboxPaymentWrite':
          return SandboxPaymentWrite.fromJson(value);
        case 'Settings':
          return Settings.fromJson(value);
        case 'SettingsUpdate':
          return SettingsUpdate.fromJson(value);
        case 'SettlementDay':
          return SettlementDay.fromJson(value);
        case 'SettlementPayment':
          return SettlementPayment.fromJson(value);
        case 'SettlementReport':
          return SettlementReport.fromJson(value);
        case 'Shift':
          return Shift.fromJson(value);
        case 'ShiftCashMovementWrite':
          return ShiftCashMovementWrite.fromJson(value);
        case 'ShiftCloseWrite':
          return ShiftCloseWrite.fromJson(value);
        case 'ShiftMovement':
          return ShiftMovement.fromJson(value);
        case 'ShiftPage':
          return ShiftPage.fromJson(value);
        case 'ShiftReport':
          return ShiftReport.fromJson(value);
        case 'ShiftTenderTotal':
          return ShiftTenderTotal.fromJson(value);
        case 'ShiftWrite':
          return ShiftWrite.fromJson(value);
        case 'SplitBill':
          return SplitBill.fromJson(value);
        case 'SplitResult':
          return SplitResult.fromJson(value);
        case 'SplitWrite':
          return SplitWrite.fromJson(value);
        case 'Station':
          return Station.fromJson(value);
        case 'StationJob':
          return StationJob.fromJson(value);
        case 'StationJobKind':
          return StationJobKindTypeTransformer().decode(value);
        case 'StationJobLine':
          return StationJobLine.fromJson(value);
        case 'StationJobModifier':
          return StationJobModifier.fromJson(value);
        case 'StationJobPage':
          return StationJobPage.fromJson(value);
        case 'StationJobStateWrite':
          return StationJobStateWrite.fromJson(value);
        case 'StationJobWrite':
          return StationJobWrite.fromJson(value);
        case 'StationKind':
          return StationKindTypeTransformer().decode(value);
        case 'StationRoute':
          return StationRoute.fromJson(value);
        case 'StationRouteEntry':
          return StationRouteEntry.fromJson(value);
        case 'StationRoutingWrite':
          return StationRoutingWrite.fromJson(value);
        case 'StationUpdate':
          return StationUpdate.fromJson(value);
        case 'StationWrite':
          return StationWrite.fromJson(value);
        case 'Stock':
          return Stock.fromJson(value);
        case 'StockChange':
          return StockChange.fromJson(value);
        case 'StockCount':
          return StockCount.fromJson(value);
        case 'StockCountLine':
          return StockCountLine.fromJson(value);
        case 'StockCountLineWrite':
          return StockCountLineWrite.fromJson(value);
        case 'StockCountPage':
          return StockCountPage.fromJson(value);
        case 'StockCountWrite':
          return StockCountWrite.fromJson(value);
        case 'StockPage':
          return StockPage.fromJson(value);
        case 'StockWrite':
          return StockWrite.fromJson(value);
        case 'Supplier':
          return Supplier.fromJson(value);
        case 'SupplierPage':
          return SupplierPage.fromJson(value);
        case 'SupplierWrite':
          return SupplierWrite.fromJson(value);
        case 'Table':
          return Table.fromJson(value);
        case 'TablePage':
          return TablePage.fromJson(value);
        case 'TableWrite':
          return TableWrite.fromJson(value);
        case 'Totals':
          return Totals.fromJson(value);
        case 'TransferWrite':
          return TransferWrite.fromJson(value);
        case 'User':
          return User.fromJson(value);
        case 'Variant':
          return Variant.fromJson(value);
        case 'VariantUpdate':
          return VariantUpdate.fromJson(value);
        case 'VariantWrite':
          return VariantWrite.fromJson(value);
        case 'Waste':
          return Waste.fromJson(value);
        case 'WastePage':
          return WastePage.fromJson(value);
        case 'WasteWrite':
          return WasteWrite.fromJson(value);
        case 'WebSession':
          return WebSession.fromJson(value);
        case 'WebhookAck':
          return WebhookAck.fromJson(value);
        default:
          dynamic match;
          if (value is List && (match = _regList.firstMatch(targetType)?.group(1)) != null) {
            return value
              .map<dynamic>((dynamic v) => fromJson(v, match, growable: growable,))
              .toList(growable: growable);
          }
          if (value is Set && (match = _regSet.firstMatch(targetType)?.group(1)) != null) {
            return value
              .map<dynamic>((dynamic v) => fromJson(v, match, growable: growable,))
              .toSet();
          }
          if (value is Map && (match = _regMap.firstMatch(targetType)?.group(1)) != null) {
            return Map<String, dynamic>.fromIterables(
              value.keys.cast<String>(),
              value.values.map<dynamic>((dynamic v) => fromJson(v, match, growable: growable,)),
            );
          }
      }
    } on Exception catch (error, trace) {
      throw ApiException.withInner(HttpStatus.internalServerError, 'Exception during deserialization.', error, trace,);
    }
    throw ApiException(HttpStatus.internalServerError, 'Could not find a suitable class for deserialization',);
  }
}

/// Primarily intended for use in an isolate.
class DeserializationMessage {
  const DeserializationMessage({
    required this.json,
    required this.targetType,
    this.growable = false,
  });

  /// The JSON value to deserialize.
  final String json;

  /// Target type to deserialize to.
  final String targetType;

  /// Whether to make deserialized lists or maps growable.
  final bool growable;
}

/// Primarily intended for use in an isolate.
Future<dynamic> decodeAsync(DeserializationMessage message) async {
  // Remove all spaces. Necessary for regular expressions as well.
  final targetType = message.targetType.replaceAll(' ', '');

  // If the expected target type is String, nothing to do...
  return targetType == 'String'
    ? message.json
    : json.decode(message.json);
}

/// Primarily intended for use in an isolate.
Future<dynamic> deserializeAsync(DeserializationMessage message) async {
  // Remove all spaces. Necessary for regular expressions as well.
  final targetType = message.targetType.replaceAll(' ', '');

  // If the expected target type is String, nothing to do...
  return targetType == 'String'
    ? message.json
    : ApiClient.fromJson(
        json.decode(message.json),
        targetType,
        growable: message.growable,
      );
}

/// Primarily intended for use in an isolate.
Future<String> serializeAsync(Object? value) async => value == null ? '' : json.encode(value);
