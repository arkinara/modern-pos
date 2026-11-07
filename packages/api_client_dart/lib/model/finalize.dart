//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Finalize {
  /// Returns a new [Finalize] instance.
  Finalize({
    required this.deviceId,
    required this.orderId,
    required this.quoteId,
    required this.payment,
  });

  String deviceId;

  String orderId;

  String quoteId;

  PaymentInput payment;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Finalize &&
    other.deviceId == deviceId &&
    other.orderId == orderId &&
    other.quoteId == quoteId &&
    other.payment == payment;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (deviceId.hashCode) +
    (orderId.hashCode) +
    (quoteId.hashCode) +
    (payment.hashCode);

  @override
  String toString() => 'Finalize[deviceId=$deviceId, orderId=$orderId, quoteId=$quoteId, payment=$payment]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'deviceId'] = this.deviceId;
      json[r'orderId'] = this.orderId;
      json[r'quoteId'] = this.quoteId;
      json[r'payment'] = this.payment;
    return json;
  }

  /// Returns a new [Finalize] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Finalize? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'deviceId'), 'Required key "Finalize[deviceId]" is missing from JSON.');
        assert(json[r'deviceId'] != null, 'Required key "Finalize[deviceId]" has a null value in JSON.');
        assert(json.containsKey(r'orderId'), 'Required key "Finalize[orderId]" is missing from JSON.');
        assert(json[r'orderId'] != null, 'Required key "Finalize[orderId]" has a null value in JSON.');
        assert(json.containsKey(r'quoteId'), 'Required key "Finalize[quoteId]" is missing from JSON.');
        assert(json[r'quoteId'] != null, 'Required key "Finalize[quoteId]" has a null value in JSON.');
        assert(json.containsKey(r'payment'), 'Required key "Finalize[payment]" is missing from JSON.');
        assert(json[r'payment'] != null, 'Required key "Finalize[payment]" has a null value in JSON.');
        return true;
      }());

      return Finalize(
        deviceId: mapValueOfType<String>(json, r'deviceId')!,
        orderId: mapValueOfType<String>(json, r'orderId')!,
        quoteId: mapValueOfType<String>(json, r'quoteId')!,
        payment: PaymentInput.fromJson(json[r'payment'])!,
      );
    }
    return null;
  }

  static List<Finalize> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Finalize>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Finalize.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Finalize> mapFromJson(dynamic json) {
    final map = <String, Finalize>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Finalize.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Finalize-objects as value to a dart map
  static Map<String, List<Finalize>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Finalize>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Finalize.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'deviceId',
    'orderId',
    'quoteId',
    'payment',
  };
}

