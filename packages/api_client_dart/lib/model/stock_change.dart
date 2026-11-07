//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class StockChange {
  /// Returns a new [StockChange] instance.
  StockChange({
    required this.stockItemId,
    required this.quantity,
    required this.reason,
  });

  String stockItemId;

  /// Nonnegative fixed-point base-unit quantity. Business validation rejects zero where a positive quantity is required.
  String quantity;

  String reason;

  @override
  bool operator ==(Object other) => identical(this, other) || other is StockChange &&
    other.stockItemId == stockItemId &&
    other.quantity == quantity &&
    other.reason == reason;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (stockItemId.hashCode) +
    (quantity.hashCode) +
    (reason.hashCode);

  @override
  String toString() => 'StockChange[stockItemId=$stockItemId, quantity=$quantity, reason=$reason]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'stockItemId'] = this.stockItemId;
      json[r'quantity'] = this.quantity;
      json[r'reason'] = this.reason;
    return json;
  }

  /// Returns a new [StockChange] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static StockChange? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'stockItemId'), 'Required key "StockChange[stockItemId]" is missing from JSON.');
        assert(json[r'stockItemId'] != null, 'Required key "StockChange[stockItemId]" has a null value in JSON.');
        assert(json.containsKey(r'quantity'), 'Required key "StockChange[quantity]" is missing from JSON.');
        assert(json[r'quantity'] != null, 'Required key "StockChange[quantity]" has a null value in JSON.');
        assert(json.containsKey(r'reason'), 'Required key "StockChange[reason]" is missing from JSON.');
        assert(json[r'reason'] != null, 'Required key "StockChange[reason]" has a null value in JSON.');
        return true;
      }());

      return StockChange(
        stockItemId: mapValueOfType<String>(json, r'stockItemId')!,
        quantity: mapValueOfType<String>(json, r'quantity')!,
        reason: mapValueOfType<String>(json, r'reason')!,
      );
    }
    return null;
  }

  static List<StockChange> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <StockChange>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = StockChange.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, StockChange> mapFromJson(dynamic json) {
    final map = <String, StockChange>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = StockChange.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of StockChange-objects as value to a dart map
  static Map<String, List<StockChange>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<StockChange>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = StockChange.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'stockItemId',
    'quantity',
    'reason',
  };
}

