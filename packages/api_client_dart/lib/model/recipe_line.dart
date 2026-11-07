//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class RecipeLine {
  /// Returns a new [RecipeLine] instance.
  RecipeLine({
    required this.stockItemId,
    required this.quantityPerSaleUnit,
  });

  String stockItemId;

  /// Nonnegative fixed-point base-unit quantity. Business validation rejects zero where a positive quantity is required.
  String quantityPerSaleUnit;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RecipeLine &&
    other.stockItemId == stockItemId &&
    other.quantityPerSaleUnit == quantityPerSaleUnit;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (stockItemId.hashCode) +
    (quantityPerSaleUnit.hashCode);

  @override
  String toString() => 'RecipeLine[stockItemId=$stockItemId, quantityPerSaleUnit=$quantityPerSaleUnit]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'stockItemId'] = this.stockItemId;
      json[r'quantityPerSaleUnit'] = this.quantityPerSaleUnit;
    return json;
  }

  /// Returns a new [RecipeLine] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RecipeLine? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'stockItemId'), 'Required key "RecipeLine[stockItemId]" is missing from JSON.');
        assert(json[r'stockItemId'] != null, 'Required key "RecipeLine[stockItemId]" has a null value in JSON.');
        assert(json.containsKey(r'quantityPerSaleUnit'), 'Required key "RecipeLine[quantityPerSaleUnit]" is missing from JSON.');
        assert(json[r'quantityPerSaleUnit'] != null, 'Required key "RecipeLine[quantityPerSaleUnit]" has a null value in JSON.');
        return true;
      }());

      return RecipeLine(
        stockItemId: mapValueOfType<String>(json, r'stockItemId')!,
        quantityPerSaleUnit: mapValueOfType<String>(json, r'quantityPerSaleUnit')!,
      );
    }
    return null;
  }

  static List<RecipeLine> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RecipeLine>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RecipeLine.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RecipeLine> mapFromJson(dynamic json) {
    final map = <String, RecipeLine>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RecipeLine.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RecipeLine-objects as value to a dart map
  static Map<String, List<RecipeLine>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<RecipeLine>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RecipeLine.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'stockItemId',
    'quantityPerSaleUnit',
  };
}

