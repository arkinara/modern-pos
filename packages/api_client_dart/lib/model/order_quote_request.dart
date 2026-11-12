//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class OrderQuoteRequest {
  /// Returns a new [OrderQuoteRequest] instance.
  OrderQuoteRequest({
    required this.orderVersion,
    this.promotionIds = const [],
    this.customerEmail,
  });

  /// Minimum value: 1
  int orderVersion;

  List<String> promotionIds;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? customerEmail;

  @override
  bool operator ==(Object other) => identical(this, other) || other is OrderQuoteRequest &&
    other.orderVersion == orderVersion &&
    _deepEquality.equals(other.promotionIds, promotionIds) &&
    other.customerEmail == customerEmail;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (orderVersion.hashCode) +
    (promotionIds.hashCode) +
    (customerEmail == null ? 0 : customerEmail!.hashCode);

  @override
  String toString() => 'OrderQuoteRequest[orderVersion=$orderVersion, promotionIds=$promotionIds, customerEmail=$customerEmail]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'orderVersion'] = this.orderVersion;
      json[r'promotionIds'] = this.promotionIds;
    if (this.customerEmail != null) {
      json[r'customerEmail'] = this.customerEmail;
    } else {
      json[r'customerEmail'] = null;
    }
    return json;
  }

  /// Returns a new [OrderQuoteRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static OrderQuoteRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'orderVersion'), 'Required key "OrderQuoteRequest[orderVersion]" is missing from JSON.');
        assert(json[r'orderVersion'] != null, 'Required key "OrderQuoteRequest[orderVersion]" has a null value in JSON.');
        return true;
      }());

      return OrderQuoteRequest(
        orderVersion: mapValueOfType<int>(json, r'orderVersion')!,
        promotionIds: json[r'promotionIds'] is Iterable
            ? (json[r'promotionIds'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        customerEmail: mapValueOfType<String>(json, r'customerEmail'),
      );
    }
    return null;
  }

  static List<OrderQuoteRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <OrderQuoteRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = OrderQuoteRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, OrderQuoteRequest> mapFromJson(dynamic json) {
    final map = <String, OrderQuoteRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = OrderQuoteRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of OrderQuoteRequest-objects as value to a dart map
  static Map<String, List<OrderQuoteRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<OrderQuoteRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = OrderQuoteRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'orderVersion',
  };
}

