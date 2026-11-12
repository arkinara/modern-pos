//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class SplitBillLinesInner {
  /// Returns a new [SplitBillLinesInner] instance.
  SplitBillLinesInner({
    required this.variantId,
    required this.quantity,
  });

  String variantId;

  /// Minimum value: 1
  /// Maximum value: 100000
  int quantity;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SplitBillLinesInner &&
    other.variantId == variantId &&
    other.quantity == quantity;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (variantId.hashCode) +
    (quantity.hashCode);

  @override
  String toString() => 'SplitBillLinesInner[variantId=$variantId, quantity=$quantity]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'variantId'] = this.variantId;
      json[r'quantity'] = this.quantity;
    return json;
  }

  /// Returns a new [SplitBillLinesInner] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SplitBillLinesInner? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'variantId'), 'Required key "SplitBillLinesInner[variantId]" is missing from JSON.');
        assert(json[r'variantId'] != null, 'Required key "SplitBillLinesInner[variantId]" has a null value in JSON.');
        assert(json.containsKey(r'quantity'), 'Required key "SplitBillLinesInner[quantity]" is missing from JSON.');
        assert(json[r'quantity'] != null, 'Required key "SplitBillLinesInner[quantity]" has a null value in JSON.');
        return true;
      }());

      return SplitBillLinesInner(
        variantId: mapValueOfType<String>(json, r'variantId')!,
        quantity: mapValueOfType<int>(json, r'quantity')!,
      );
    }
    return null;
  }

  static List<SplitBillLinesInner> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SplitBillLinesInner>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SplitBillLinesInner.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SplitBillLinesInner> mapFromJson(dynamic json) {
    final map = <String, SplitBillLinesInner>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SplitBillLinesInner.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SplitBillLinesInner-objects as value to a dart map
  static Map<String, List<SplitBillLinesInner>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SplitBillLinesInner>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SplitBillLinesInner.listFromJson(entry.value, growable: growable,);
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

