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


/// tests for OrderingApi
void main() {
  // final instance = OrderingApi();

  group('tests for OrderingApi', () {
    // Accept a received order and consume stock once
    //
    //Future<ChannelOrder> channelOrderAccept(String outletId, String orderId) async
    test('test channelOrderAccept', () async {
      // TODO
    });

    // Cancel an order and restore stock when it was accepted
    //
    //Future<ChannelOrder> channelOrderCancel(String outletId, String orderId, ChannelOrderCancelWrite channelOrderCancelWrite) async
    test('test channelOrderCancel', () async {
      // TODO
    });

    // Create a manual or phone channel order
    //
    //Future<ChannelOrderCreateResult> channelOrderCreateManual(String outletId, ChannelOrderManualWrite channelOrderManualWrite) async
    test('test channelOrderCreateManual', () async {
      // TODO
    });

    // Fulfil an accepted cash-on-pickup order and record one payment
    //
    //Future<ChannelOrder> channelOrderFulfill(String outletId, String orderId, ChannelOrderFulfillWrite channelOrderFulfillWrite) async
    test('test channelOrderFulfill', () async {
      // TODO
    });

    // Read one channel order
    //
    //Future<ChannelOrder> channelOrderGet(String outletId, String orderId) async
    test('test channelOrderGet', () async {
      // TODO
    });

    // List incoming channel orders
    //
    //Future<ChannelOrderList> channelOrdersList(String outletId, { String state, String channel, String search, int limit }) async
    test('test channelOrdersList', () async {
      // TODO
    });

    // Receive a signed, replay-protected channel order
    //
    // The web channel is available with CHANNEL_WEBHOOK_SECRET. GrabFood and ShopeeFood return CHANNEL_PENDING_CREDENTIALS.
    //
    //Future<ChannelOrderCreateResult> channelWebhookReceive(String channel, String xChannelSignature, ChannelOrderWebhookWrite channelOrderWebhookWrite) async
    test('test channelWebhookReceive', () async {
      // TODO
    });

    // List supported ordering channels and availability
    //
    //Future<ChannelList> channelsList(String outletId) async
    test('test channelsList', () async {
      // TODO
    });

  });
}
