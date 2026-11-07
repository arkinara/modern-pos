//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Restock {
  /// Returns a new [Restock] instance.
  Restock({
    required this.stockItemId,
    required this.quantity,
  });

  String stockItemId;

  /// Nonnegative fixed-point base-unit quantity. Business validation rejects zero where a positive quantity is required.
  String quantity;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Restock &&
    other.stockItemId == stockItemId &&
    other.quantity == quantity;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (stockItemId.hashCode) +
    (quantity.hashCode);

  @override
  String toString() => 'Restock[stockItemId=$stockItemId, quantity=$quantity]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'stockItemId'] = this.stockItemId;
      json[r'quantity'] = this.quantity;
    return json;
  }

  /// Returns a new [Restock] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Restock? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'stockItemId'), 'Required key "Restock[stockItemId]" is missing from JSON.');
        assert(json[r'stockItemId'] != null, 'Required key "Restock[stockItemId]" has a null value in JSON.');
        assert(json.containsKey(r'quantity'), 'Required key "Restock[quantity]" is missing from JSON.');
        assert(json[r'quantity'] != null, 'Required key "Restock[quantity]" has a null value in JSON.');
        return true;
      }());

      return Restock(
        stockItemId: mapValueOfType<String>(json, r'stockItemId')!,
        quantity: mapValueOfType<String>(json, r'quantity')!,
      );
    }
    return null;
  }

  static List<Restock> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Restock>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Restock.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Restock> mapFromJson(dynamic json) {
    final map = <String, Restock>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Restock.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Restock-objects as value to a dart map
  static Map<String, List<Restock>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Restock>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Restock.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'stockItemId',
    'quantity',
  };
}

