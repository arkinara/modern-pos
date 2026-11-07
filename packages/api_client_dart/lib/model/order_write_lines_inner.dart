//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class OrderWriteLinesInner {
  /// Returns a new [OrderWriteLinesInner] instance.
  OrderWriteLinesInner({
    required this.variantId,
    required this.quantity,
  });

  String variantId;

  /// Minimum value: 1
  /// Maximum value: 100000
  int quantity;

  @override
  bool operator ==(Object other) => identical(this, other) || other is OrderWriteLinesInner &&
    other.variantId == variantId &&
    other.quantity == quantity;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (variantId.hashCode) +
    (quantity.hashCode);

  @override
  String toString() => 'OrderWriteLinesInner[variantId=$variantId, quantity=$quantity]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'variantId'] = this.variantId;
      json[r'quantity'] = this.quantity;
    return json;
  }

  /// Returns a new [OrderWriteLinesInner] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static OrderWriteLinesInner? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'variantId'), 'Required key "OrderWriteLinesInner[variantId]" is missing from JSON.');
        assert(json[r'variantId'] != null, 'Required key "OrderWriteLinesInner[variantId]" has a null value in JSON.');
        assert(json.containsKey(r'quantity'), 'Required key "OrderWriteLinesInner[quantity]" is missing from JSON.');
        assert(json[r'quantity'] != null, 'Required key "OrderWriteLinesInner[quantity]" has a null value in JSON.');
        return true;
      }());

      return OrderWriteLinesInner(
        variantId: mapValueOfType<String>(json, r'variantId')!,
        quantity: mapValueOfType<int>(json, r'quantity')!,
      );
    }
    return null;
  }

  static List<OrderWriteLinesInner> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <OrderWriteLinesInner>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = OrderWriteLinesInner.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, OrderWriteLinesInner> mapFromJson(dynamic json) {
    final map = <String, OrderWriteLinesInner>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = OrderWriteLinesInner.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of OrderWriteLinesInner-objects as value to a dart map
  static Map<String, List<OrderWriteLinesInner>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<OrderWriteLinesInner>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = OrderWriteLinesInner.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'variantId',
    'quantity',
  };
}

