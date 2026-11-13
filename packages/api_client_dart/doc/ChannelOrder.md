# modern_pos_api_client.model.ChannelOrder

## Load the model package
```dart
import 'package:modern_pos_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | 
**outletId** | **String** |  | 
**channel** | [**OrderChannel**](OrderChannel.md) |  | 
**channelReference** | **String** |  | 
**state** | [**ChannelOrderState**](ChannelOrderState.md) |  | 
**paymentMode** | [**ChannelPaymentMode**](ChannelPaymentMode.md) |  | 
**paymentStatus** | [**ChannelPaymentStatus**](ChannelPaymentStatus.md) |  | 
**currency** | **String** |  | 
**currencyExponent** | **int** |  | 
**subtotalMinor** | **int** |  | 
**serviceMinor** | **int** |  | 
**taxMinor** | **int** |  | 
**totalMinor** | **int** |  | 
**note** | **String** |  | 
**customerId** | **String** |  | 
**acceptedAt** | [**DateTime**](DateTime.md) |  | 
**fulfilledAt** | [**DateTime**](DateTime.md) |  | 
**cancelledAt** | [**DateTime**](DateTime.md) |  | 
**cancellationReason** | **String** |  | 
**createdAt** | [**DateTime**](DateTime.md) |  | 
**updatedAt** | [**DateTime**](DateTime.md) |  | 
**version** | **int** |  | 
**lines** | [**List<ChannelOrderLine>**](ChannelOrderLine.md) |  | [default to const []]
**payments** | [**List<ChannelOrderPayment>**](ChannelOrderPayment.md) |  | [default to const []]
**events** | [**List<ChannelOrderEvent>**](ChannelOrderEvent.md) |  | [default to const []]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


