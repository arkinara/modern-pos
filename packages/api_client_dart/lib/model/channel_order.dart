//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ChannelOrder {
  /// Returns a new [ChannelOrder] instance.
  ChannelOrder({
    required this.id,
    required this.outletId,
    required this.channel,
    required this.channelReference,
    required this.state,
    required this.paymentMode,
    required this.paymentStatus,
    required this.currency,
    required this.currencyExponent,
    required this.subtotalMinor,
    required this.serviceMinor,
    required this.taxMinor,
    required this.totalMinor,
    required this.note,
    required this.customerId,
    required this.acceptedAt,
    required this.fulfilledAt,
    required this.cancelledAt,
    required this.cancellationReason,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    this.lines = const [],
    this.payments = const [],
    this.events = const [],
  });

  String id;

  String outletId;

  OrderChannel channel;

  String channelReference;

  ChannelOrderState state;

  ChannelPaymentMode paymentMode;

  ChannelPaymentStatus paymentStatus;

  String currency;

  int currencyExponent;

  int subtotalMinor;

  int serviceMinor;

  int taxMinor;

  int totalMinor;

  String note;

  String? customerId;

  DateTime? acceptedAt;

  DateTime? fulfilledAt;

  DateTime? cancelledAt;

  String? cancellationReason;

  DateTime createdAt;

  DateTime updatedAt;

  int version;

  List<ChannelOrderLine> lines;

  List<ChannelOrderPayment> payments;

  List<ChannelOrderEvent> events;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ChannelOrder &&
    other.id == id &&
    other.outletId == outletId &&
    other.channel == channel &&
    other.channelReference == channelReference &&
    other.state == state &&
    other.paymentMode == paymentMode &&
    other.paymentStatus == paymentStatus &&
    other.currency == currency &&
    other.currencyExponent == currencyExponent &&
    other.subtotalMinor == subtotalMinor &&
    other.serviceMinor == serviceMinor &&
    other.taxMinor == taxMinor &&
    other.totalMinor == totalMinor &&
    other.note == note &&
    other.customerId == customerId &&
    other.acceptedAt == acceptedAt &&
    other.fulfilledAt == fulfilledAt &&
    other.cancelledAt == cancelledAt &&
    other.cancellationReason == cancellationReason &&
    other.createdAt == createdAt &&
    other.updatedAt == updatedAt &&
    other.version == version &&
    _deepEquality.equals(other.lines, lines) &&
    _deepEquality.equals(other.payments, payments) &&
    _deepEquality.equals(other.events, events);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (outletId.hashCode) +
    (channel.hashCode) +
    (channelReference.hashCode) +
    (state.hashCode) +
    (paymentMode.hashCode) +
    (paymentStatus.hashCode) +
    (currency.hashCode) +
    (currencyExponent.hashCode) +
    (subtotalMinor.hashCode) +
    (serviceMinor.hashCode) +
    (taxMinor.hashCode) +
    (totalMinor.hashCode) +
    (note.hashCode) +
    (customerId == null ? 0 : customerId!.hashCode) +
    (acceptedAt == null ? 0 : acceptedAt!.hashCode) +
    (fulfilledAt == null ? 0 : fulfilledAt!.hashCode) +
    (cancelledAt == null ? 0 : cancelledAt!.hashCode) +
    (cancellationReason == null ? 0 : cancellationReason!.hashCode) +
    (createdAt.hashCode) +
    (updatedAt.hashCode) +
    (version.hashCode) +
    (lines.hashCode) +
    (payments.hashCode) +
    (events.hashCode);

  @override
  String toString() => 'ChannelOrder[id=$id, outletId=$outletId, channel=$channel, channelReference=$channelReference, state=$state, paymentMode=$paymentMode, paymentStatus=$paymentStatus, currency=$currency, currencyExponent=$currencyExponent, subtotalMinor=$subtotalMinor, serviceMinor=$serviceMinor, taxMinor=$taxMinor, totalMinor=$totalMinor, note=$note, customerId=$customerId, acceptedAt=$acceptedAt, fulfilledAt=$fulfilledAt, cancelledAt=$cancelledAt, cancellationReason=$cancellationReason, createdAt=$createdAt, updatedAt=$updatedAt, version=$version, lines=$lines, payments=$payments, events=$events]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'outletId'] = this.outletId;
      json[r'channel'] = this.channel;
      json[r'channelReference'] = this.channelReference;
      json[r'state'] = this.state;
      json[r'paymentMode'] = this.paymentMode;
      json[r'paymentStatus'] = this.paymentStatus;
      json[r'currency'] = this.currency;
      json[r'currencyExponent'] = this.currencyExponent;
      json[r'subtotalMinor'] = this.subtotalMinor;
      json[r'serviceMinor'] = this.serviceMinor;
      json[r'taxMinor'] = this.taxMinor;
      json[r'totalMinor'] = this.totalMinor;
      json[r'note'] = this.note;
    if (this.customerId != null) {
      json[r'customerId'] = this.customerId;
    } else {
      json[r'customerId'] = null;
    }
    if (this.acceptedAt != null) {
      json[r'acceptedAt'] = this.acceptedAt!.toUtc().toIso8601String();
    } else {
      json[r'acceptedAt'] = null;
    }
    if (this.fulfilledAt != null) {
      json[r'fulfilledAt'] = this.fulfilledAt!.toUtc().toIso8601String();
    } else {
      json[r'fulfilledAt'] = null;
    }
    if (this.cancelledAt != null) {
      json[r'cancelledAt'] = this.cancelledAt!.toUtc().toIso8601String();
    } else {
      json[r'cancelledAt'] = null;
    }
    if (this.cancellationReason != null) {
      json[r'cancellationReason'] = this.cancellationReason;
    } else {
      json[r'cancellationReason'] = null;
    }
      json[r'createdAt'] = this.createdAt.toUtc().toIso8601String();
      json[r'updatedAt'] = this.updatedAt.toUtc().toIso8601String();
      json[r'version'] = this.version;
      json[r'lines'] = this.lines;
      json[r'payments'] = this.payments;
      json[r'events'] = this.events;
    return json;
  }

  /// Returns a new [ChannelOrder] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ChannelOrder? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "ChannelOrder[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "ChannelOrder[id]" has a null value in JSON.');
        assert(json.containsKey(r'outletId'), 'Required key "ChannelOrder[outletId]" is missing from JSON.');
        assert(json[r'outletId'] != null, 'Required key "ChannelOrder[outletId]" has a null value in JSON.');
        assert(json.containsKey(r'channel'), 'Required key "ChannelOrder[channel]" is missing from JSON.');
        assert(json[r'channel'] != null, 'Required key "ChannelOrder[channel]" has a null value in JSON.');
        assert(json.containsKey(r'channelReference'), 'Required key "ChannelOrder[channelReference]" is missing from JSON.');
        assert(json[r'channelReference'] != null, 'Required key "ChannelOrder[channelReference]" has a null value in JSON.');
        assert(json.containsKey(r'state'), 'Required key "ChannelOrder[state]" is missing from JSON.');
        assert(json[r'state'] != null, 'Required key "ChannelOrder[state]" has a null value in JSON.');
        assert(json.containsKey(r'paymentMode'), 'Required key "ChannelOrder[paymentMode]" is missing from JSON.');
        assert(json[r'paymentMode'] != null, 'Required key "ChannelOrder[paymentMode]" has a null value in JSON.');
        assert(json.containsKey(r'paymentStatus'), 'Required key "ChannelOrder[paymentStatus]" is missing from JSON.');
        assert(json[r'paymentStatus'] != null, 'Required key "ChannelOrder[paymentStatus]" has a null value in JSON.');
        assert(json.containsKey(r'currency'), 'Required key "ChannelOrder[currency]" is missing from JSON.');
        assert(json[r'currency'] != null, 'Required key "ChannelOrder[currency]" has a null value in JSON.');
        assert(json.containsKey(r'currencyExponent'), 'Required key "ChannelOrder[currencyExponent]" is missing from JSON.');
        assert(json[r'currencyExponent'] != null, 'Required key "ChannelOrder[currencyExponent]" has a null value in JSON.');
        assert(json.containsKey(r'subtotalMinor'), 'Required key "ChannelOrder[subtotalMinor]" is missing from JSON.');
        assert(json[r'subtotalMinor'] != null, 'Required key "ChannelOrder[subtotalMinor]" has a null value in JSON.');
        assert(json.containsKey(r'serviceMinor'), 'Required key "ChannelOrder[serviceMinor]" is missing from JSON.');
        assert(json[r'serviceMinor'] != null, 'Required key "ChannelOrder[serviceMinor]" has a null value in JSON.');
        assert(json.containsKey(r'taxMinor'), 'Required key "ChannelOrder[taxMinor]" is missing from JSON.');
        assert(json[r'taxMinor'] != null, 'Required key "ChannelOrder[taxMinor]" has a null value in JSON.');
        assert(json.containsKey(r'totalMinor'), 'Required key "ChannelOrder[totalMinor]" is missing from JSON.');
        assert(json[r'totalMinor'] != null, 'Required key "ChannelOrder[totalMinor]" has a null value in JSON.');
        assert(json.containsKey(r'note'), 'Required key "ChannelOrder[note]" is missing from JSON.');
        assert(json[r'note'] != null, 'Required key "ChannelOrder[note]" has a null value in JSON.');
        assert(json.containsKey(r'customerId'), 'Required key "ChannelOrder[customerId]" is missing from JSON.');
        assert(json.containsKey(r'acceptedAt'), 'Required key "ChannelOrder[acceptedAt]" is missing from JSON.');
        assert(json.containsKey(r'fulfilledAt'), 'Required key "ChannelOrder[fulfilledAt]" is missing from JSON.');
        assert(json.containsKey(r'cancelledAt'), 'Required key "ChannelOrder[cancelledAt]" is missing from JSON.');
        assert(json.containsKey(r'cancellationReason'), 'Required key "ChannelOrder[cancellationReason]" is missing from JSON.');
        assert(json.containsKey(r'createdAt'), 'Required key "ChannelOrder[createdAt]" is missing from JSON.');
        assert(json[r'createdAt'] != null, 'Required key "ChannelOrder[createdAt]" has a null value in JSON.');
        assert(json.containsKey(r'updatedAt'), 'Required key "ChannelOrder[updatedAt]" is missing from JSON.');
        assert(json[r'updatedAt'] != null, 'Required key "ChannelOrder[updatedAt]" has a null value in JSON.');
        assert(json.containsKey(r'version'), 'Required key "ChannelOrder[version]" is missing from JSON.');
        assert(json[r'version'] != null, 'Required key "ChannelOrder[version]" has a null value in JSON.');
        assert(json.containsKey(r'lines'), 'Required key "ChannelOrder[lines]" is missing from JSON.');
        assert(json[r'lines'] != null, 'Required key "ChannelOrder[lines]" has a null value in JSON.');
        assert(json.containsKey(r'payments'), 'Required key "ChannelOrder[payments]" is missing from JSON.');
        assert(json[r'payments'] != null, 'Required key "ChannelOrder[payments]" has a null value in JSON.');
        assert(json.containsKey(r'events'), 'Required key "ChannelOrder[events]" is missing from JSON.');
        assert(json[r'events'] != null, 'Required key "ChannelOrder[events]" has a null value in JSON.');
        return true;
      }());

      return ChannelOrder(
        id: mapValueOfType<String>(json, r'id')!,
        outletId: mapValueOfType<String>(json, r'outletId')!,
        channel: OrderChannel.fromJson(json[r'channel'])!,
        channelReference: mapValueOfType<String>(json, r'channelReference')!,
        state: ChannelOrderState.fromJson(json[r'state'])!,
        paymentMode: ChannelPaymentMode.fromJson(json[r'paymentMode'])!,
        paymentStatus: ChannelPaymentStatus.fromJson(json[r'paymentStatus'])!,
        currency: mapValueOfType<String>(json, r'currency')!,
        currencyExponent: mapValueOfType<int>(json, r'currencyExponent')!,
        subtotalMinor: mapValueOfType<int>(json, r'subtotalMinor')!,
        serviceMinor: mapValueOfType<int>(json, r'serviceMinor')!,
        taxMinor: mapValueOfType<int>(json, r'taxMinor')!,
        totalMinor: mapValueOfType<int>(json, r'totalMinor')!,
        note: mapValueOfType<String>(json, r'note')!,
        customerId: mapValueOfType<String>(json, r'customerId'),
        acceptedAt: mapDateTime(json, r'acceptedAt', r''),
        fulfilledAt: mapDateTime(json, r'fulfilledAt', r''),
        cancelledAt: mapDateTime(json, r'cancelledAt', r''),
        cancellationReason: mapValueOfType<String>(json, r'cancellationReason'),
        createdAt: mapDateTime(json, r'createdAt', r'')!,
        updatedAt: mapDateTime(json, r'updatedAt', r'')!,
        version: mapValueOfType<int>(json, r'version')!,
        lines: ChannelOrderLine.listFromJson(json[r'lines']),
        payments: ChannelOrderPayment.listFromJson(json[r'payments']),
        events: ChannelOrderEvent.listFromJson(json[r'events']),
      );
    }
    return null;
  }

  static List<ChannelOrder> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ChannelOrder>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ChannelOrder.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ChannelOrder> mapFromJson(dynamic json) {
    final map = <String, ChannelOrder>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ChannelOrder.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ChannelOrder-objects as value to a dart map
  static Map<String, List<ChannelOrder>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ChannelOrder>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ChannelOrder.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'outletId',
    'channel',
    'channelReference',
    'state',
    'paymentMode',
    'paymentStatus',
    'currency',
    'currencyExponent',
    'subtotalMinor',
    'serviceMinor',
    'taxMinor',
    'totalMinor',
    'note',
    'customerId',
    'acceptedAt',
    'fulfilledAt',
    'cancelledAt',
    'cancellationReason',
    'createdAt',
    'updatedAt',
    'version',
    'lines',
    'payments',
    'events',
  };
}

