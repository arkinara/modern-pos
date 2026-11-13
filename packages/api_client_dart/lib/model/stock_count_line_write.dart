//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class StockCountLineWrite {
  /// Returns a new [StockCountLineWrite] instance.
  StockCountLineWrite({
    required this.stockItemId,
    required this.countedQuantity,
  });

  String stockItemId;

  /// Nonnegative fixed-point quantity. Business validation rejects zero where a positive quantity is required.
  String countedQuantity;

  @override
  bool operator ==(Object other) => identical(this, other) || other is StockCountLineWrite &&
    other.stockItemId == stockItemId &&
    other.countedQuantity == countedQuantity;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (stockItemId.hashCode) +
    (countedQuantity.hashCode);

  @override
  String toString() => 'StockCountLineWrite[stockItemId=$stockItemId, countedQuantity=$countedQuantity]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'stockItemId'] = this.stockItemId;
      json[r'countedQuantity'] = this.countedQuantity;
    return json;
  }

  /// Returns a new [StockCountLineWrite] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static StockCountLineWrite? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'stockItemId'), 'Required key "StockCountLineWrite[stockItemId]" is missing from JSON.');
        assert(json[r'stockItemId'] != null, 'Required key "StockCountLineWrite[stockItemId]" has a null value in JSON.');
        assert(json.containsKey(r'countedQuantity'), 'Required key "StockCountLineWrite[countedQuantity]" is missing from JSON.');
        assert(json[r'countedQuantity'] != null, 'Required key "StockCountLineWrite[countedQuantity]" has a null value in JSON.');
        return true;
      }());

      return StockCountLineWrite(
        stockItemId: mapValueOfType<String>(json, r'stockItemId')!,
        countedQuantity: mapValueOfType<String>(json, r'countedQuantity')!,
      );
    }
    return null;
  }

  static List<StockCountLineWrite> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <StockCountLineWrite>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = StockCountLineWrite.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, StockCountLineWrite> mapFromJson(dynamic json) {
    final map = <String, StockCountLineWrite>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = StockCountLineWrite.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of StockCountLineWrite-objects as value to a dart map
  static Map<String, List<StockCountLineWrite>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<StockCountLineWrite>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = StockCountLineWrite.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'stockItemId',
    'countedQuantity',
  };
}

