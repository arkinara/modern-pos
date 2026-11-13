//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class OrderingApi {
  OrderingApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Accept a received order and consume stock once
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] orderId (required):
  Future<Response> channelOrderAcceptWithHttpInfo(String outletId, String orderId, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/channel-orders/{orderId}/accept'
      .replaceAll('{outletId}', outletId)
      .replaceAll('{orderId}', orderId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


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

  /// Accept a received order and consume stock once
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] orderId (required):
  Future<ChannelOrder?> channelOrderAccept(String outletId, String orderId, { Future<void>? abortTrigger, }) async {
    final response = await channelOrderAcceptWithHttpInfo(outletId, orderId, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ChannelOrder',) as ChannelOrder;
    
    }
    return null;
  }

  /// Cancel an order and restore stock when it was accepted
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] orderId (required):
  ///
  /// * [ChannelOrderCancelWrite] channelOrderCancelWrite (required):
  Future<Response> channelOrderCancelWithHttpInfo(String outletId, String orderId, ChannelOrderCancelWrite channelOrderCancelWrite, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/channel-orders/{orderId}/cancel'
      .replaceAll('{outletId}', outletId)
      .replaceAll('{orderId}', orderId);

    // ignore: prefer_final_locals
    Object? postBody = channelOrderCancelWrite;

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

  /// Cancel an order and restore stock when it was accepted
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] orderId (required):
  ///
  /// * [ChannelOrderCancelWrite] channelOrderCancelWrite (required):
  Future<ChannelOrder?> channelOrderCancel(String outletId, String orderId, ChannelOrderCancelWrite channelOrderCancelWrite, { Future<void>? abortTrigger, }) async {
    final response = await channelOrderCancelWithHttpInfo(outletId, orderId, channelOrderCancelWrite, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ChannelOrder',) as ChannelOrder;
    
    }
    return null;
  }

  /// Create a manual or phone channel order
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [ChannelOrderManualWrite] channelOrderManualWrite (required):
  Future<Response> channelOrderCreateManualWithHttpInfo(String outletId, ChannelOrderManualWrite channelOrderManualWrite, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/channel-orders'
      .replaceAll('{outletId}', outletId);

    // ignore: prefer_final_locals
    Object? postBody = channelOrderManualWrite;

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

  /// Create a manual or phone channel order
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [ChannelOrderManualWrite] channelOrderManualWrite (required):
  Future<ChannelOrderCreateResult?> channelOrderCreateManual(String outletId, ChannelOrderManualWrite channelOrderManualWrite, { Future<void>? abortTrigger, }) async {
    final response = await channelOrderCreateManualWithHttpInfo(outletId, channelOrderManualWrite, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ChannelOrderCreateResult',) as ChannelOrderCreateResult;
    
    }
    return null;
  }

  /// Fulfil an accepted cash-on-pickup order and record one payment
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] orderId (required):
  ///
  /// * [ChannelOrderFulfillWrite] channelOrderFulfillWrite (required):
  Future<Response> channelOrderFulfillWithHttpInfo(String outletId, String orderId, ChannelOrderFulfillWrite channelOrderFulfillWrite, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/channel-orders/{orderId}/fulfill'
      .replaceAll('{outletId}', outletId)
      .replaceAll('{orderId}', orderId);

    // ignore: prefer_final_locals
    Object? postBody = channelOrderFulfillWrite;

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

  /// Fulfil an accepted cash-on-pickup order and record one payment
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] orderId (required):
  ///
  /// * [ChannelOrderFulfillWrite] channelOrderFulfillWrite (required):
  Future<ChannelOrder?> channelOrderFulfill(String outletId, String orderId, ChannelOrderFulfillWrite channelOrderFulfillWrite, { Future<void>? abortTrigger, }) async {
    final response = await channelOrderFulfillWithHttpInfo(outletId, orderId, channelOrderFulfillWrite, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ChannelOrder',) as ChannelOrder;
    
    }
    return null;
  }

  /// Read one channel order
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] orderId (required):
  Future<Response> channelOrderGetWithHttpInfo(String outletId, String orderId, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/channel-orders/{orderId}'
      .replaceAll('{outletId}', outletId)
      .replaceAll('{orderId}', orderId);

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

  /// Read one channel order
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] orderId (required):
  Future<ChannelOrder?> channelOrderGet(String outletId, String orderId, { Future<void>? abortTrigger, }) async {
    final response = await channelOrderGetWithHttpInfo(outletId, orderId, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ChannelOrder',) as ChannelOrder;
    
    }
    return null;
  }

  /// List incoming channel orders
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] state:
  ///
  /// * [String] channel:
  ///
  /// * [String] search:
  ///
  /// * [int] limit:
  Future<Response> channelOrdersListWithHttpInfo(String outletId, { String? state, String? channel, String? search, int? limit, Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/channel-orders'
      .replaceAll('{outletId}', outletId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (state != null) {
      queryParams.addAll(_queryParams('', 'state', state));
    }
    if (channel != null) {
      queryParams.addAll(_queryParams('', 'channel', channel));
    }
    if (search != null) {
      queryParams.addAll(_queryParams('', 'search', search));
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

  /// List incoming channel orders
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  ///
  /// * [String] state:
  ///
  /// * [String] channel:
  ///
  /// * [String] search:
  ///
  /// * [int] limit:
  Future<ChannelOrderList?> channelOrdersList(String outletId, { String? state, String? channel, String? search, int? limit, Future<void>? abortTrigger, }) async {
    final response = await channelOrdersListWithHttpInfo(outletId, state: state, channel: channel, search: search, limit: limit, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ChannelOrderList',) as ChannelOrderList;
    
    }
    return null;
  }

  /// Receive a signed, replay-protected channel order
  ///
  /// The web channel is available with CHANNEL_WEBHOOK_SECRET. GrabFood and ShopeeFood return CHANNEL_PENDING_CREDENTIALS.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] channel (required):
  ///
  /// * [String] xChannelSignature (required):
  ///   Format t=<unix-seconds>,v1=<hex HMAC-SHA256 of t + \".\" + raw body>.
  ///
  /// * [ChannelOrderWebhookWrite] channelOrderWebhookWrite (required):
  Future<Response> channelWebhookReceiveWithHttpInfo(String channel, String xChannelSignature, ChannelOrderWebhookWrite channelOrderWebhookWrite, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/channels/{channel}/orders'
      .replaceAll('{channel}', channel);

    // ignore: prefer_final_locals
    Object? postBody = channelOrderWebhookWrite;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    headerParams[r'x-channel-signature'] = parameterToString(xChannelSignature);

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

  /// Receive a signed, replay-protected channel order
  ///
  /// The web channel is available with CHANNEL_WEBHOOK_SECRET. GrabFood and ShopeeFood return CHANNEL_PENDING_CREDENTIALS.
  ///
  /// Parameters:
  ///
  /// * [String] channel (required):
  ///
  /// * [String] xChannelSignature (required):
  ///   Format t=<unix-seconds>,v1=<hex HMAC-SHA256 of t + \".\" + raw body>.
  ///
  /// * [ChannelOrderWebhookWrite] channelOrderWebhookWrite (required):
  Future<ChannelOrderCreateResult?> channelWebhookReceive(String channel, String xChannelSignature, ChannelOrderWebhookWrite channelOrderWebhookWrite, { Future<void>? abortTrigger, }) async {
    final response = await channelWebhookReceiveWithHttpInfo(channel, xChannelSignature, channelOrderWebhookWrite, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ChannelOrderCreateResult',) as ChannelOrderCreateResult;
    
    }
    return null;
  }

  /// List supported ordering channels and availability
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  Future<Response> channelsListWithHttpInfo(String outletId, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/outlets/{outletId}/channels'
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

  /// List supported ordering channels and availability
  ///
  /// Parameters:
  ///
  /// * [String] outletId (required):
  Future<ChannelList?> channelsList(String outletId, { Future<void>? abortTrigger, }) async {
    final response = await channelsListWithHttpInfo(outletId, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ChannelList',) as ChannelList;
    
    }
    return null;
  }
}
