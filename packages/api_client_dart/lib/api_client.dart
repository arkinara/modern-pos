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
        case 'AuditEntry':
          return AuditEntry.fromJson(value);
        case 'AuditPage':
          return AuditPage.fromJson(value);
        case 'AuthMobileRefreshRequest':
          return AuthMobileRefreshRequest.fromJson(value);
        case 'AuthWebLoginRequest':
          return AuthWebLoginRequest.fromJson(value);
        case 'CalculationRules':
          return CalculationRules.fromJson(value);
        case 'CatalogArchiveRequest':
          return CatalogArchiveRequest.fromJson(value);
        case 'Category':
          return Category.fromJson(value);
        case 'CategoryWrite':
          return CategoryWrite.fromJson(value);
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
        case 'Error':
          return Error.fromJson(value);
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
        case 'Order':
          return Order.fromJson(value);
        case 'OrderCancelRequest':
          return OrderCancelRequest.fromJson(value);
        case 'OrderLinesInner':
          return OrderLinesInner.fromJson(value);
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
        case 'OutletUpdate':
          return OutletUpdate.fromJson(value);
        case 'Payment':
          return Payment.fromJson(value);
        case 'PaymentInput':
          return PaymentInput.fromJson(value);
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
        case 'Quote':
          return Quote.fromJson(value);
        case 'QuoteLinesInner':
          return QuoteLinesInner.fromJson(value);
        case 'Recipe':
          return Recipe.fromJson(value);
        case 'RecipeLine':
          return RecipeLine.fromJson(value);
        case 'RecipeWrite':
          return RecipeWrite.fromJson(value);
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
        case 'Settings':
          return Settings.fromJson(value);
        case 'SettingsUpdate':
          return SettingsUpdate.fromJson(value);
        case 'SplitBill':
          return SplitBill.fromJson(value);
        case 'SplitBillLinesInner':
          return SplitBillLinesInner.fromJson(value);
        case 'SplitResult':
          return SplitResult.fromJson(value);
        case 'SplitWrite':
          return SplitWrite.fromJson(value);
        case 'Stock':
          return Stock.fromJson(value);
        case 'StockChange':
          return StockChange.fromJson(value);
        case 'StockPage':
          return StockPage.fromJson(value);
        case 'StockWrite':
          return StockWrite.fromJson(value);
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
        case 'WebSession':
          return WebSession.fromJson(value);
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
