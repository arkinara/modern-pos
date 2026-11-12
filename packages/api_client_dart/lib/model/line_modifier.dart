//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class LineModifier {
  /// Returns a new [LineModifier] instance.
  LineModifier({
    required this.modifierId,
    required this.name,
    required this.quantity,
    required this.priceDeltaMinor,
    required this.lineDeltaMinor,
    required this.stockItemId,
  });

  String modifierId;

  String name;

  /// Minimum value: 1
  /// Maximum value: 100
  int quantity;

  int priceDeltaMinor;

  int lineDeltaMinor;

  String? stockItemId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is LineModifier &&
    other.modifierId == modifierId &&
    other.name == name &&
    other.quantity == quantity &&
    other.priceDeltaMinor == priceDeltaMinor &&
    other.lineDeltaMinor == lineDeltaMinor &&
    other.stockItemId == stockItemId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (modifierId.hashCode) +
    (name.hashCode) +
    (quantity.hashCode) +
    (priceDeltaMinor.hashCode) +
    (lineDeltaMinor.hashCode) +
    (stockItemId == null ? 0 : stockItemId!.hashCode);

  @override
  String toString() => 'LineModifier[modifierId=$modifierId, name=$name, quantity=$quantity, priceDeltaMinor=$priceDeltaMinor, lineDeltaMinor=$lineDeltaMinor, stockItemId=$stockItemId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'modifierId'] = this.modifierId;
      json[r'name'] = this.name;
      json[r'quantity'] = this.quantity;
      json[r'priceDeltaMinor'] = this.priceDeltaMinor;
      json[r'lineDeltaMinor'] = this.lineDeltaMinor;
    if (this.stockItemId != null) {
      json[r'stockItemId'] = this.stockItemId;
    } else {
      json[r'stockItemId'] = null;
    }
    return json;
  }

  /// Returns a new [LineModifier] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static LineModifier? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'modifierId'), 'Required key "LineModifier[modifierId]" is missing from JSON.');
        assert(json[r'modifierId'] != null, 'Required key "LineModifier[modifierId]" has a null value in JSON.');
        assert(json.containsKey(r'name'), 'Required key "LineModifier[name]" is missing from JSON.');
        assert(json[r'name'] != null, 'Required key "LineModifier[name]" has a null value in JSON.');
        assert(json.containsKey(r'quantity'), 'Required key "LineModifier[quantity]" is missing from JSON.');
        assert(json[r'quantity'] != null, 'Required key "LineModifier[quantity]" has a null value in JSON.');
        assert(json.containsKey(r'priceDeltaMinor'), 'Required key "LineModifier[priceDeltaMinor]" is missing from JSON.');
        assert(json[r'priceDeltaMinor'] != null, 'Required key "LineModifier[priceDeltaMinor]" has a null value in JSON.');
        assert(json.containsKey(r'lineDeltaMinor'), 'Required key "LineModifier[lineDeltaMinor]" is missing from JSON.');
        assert(json[r'lineDeltaMinor'] != null, 'Required key "LineModifier[lineDeltaMinor]" has a null value in JSON.');
        assert(json.containsKey(r'stockItemId'), 'Required key "LineModifier[stockItemId]" is missing from JSON.');
        return true;
      }());

      return LineModifier(
        modifierId: mapValueOfType<String>(json, r'modifierId')!,
        name: mapValueOfType<String>(json, r'name')!,
        quantity: mapValueOfType<int>(json, r'quantity')!,
        priceDeltaMinor: mapValueOfType<int>(json, r'priceDeltaMinor')!,
        lineDeltaMinor: mapValueOfType<int>(json, r'lineDeltaMinor')!,
        stockItemId: mapValueOfType<String>(json, r'stockItemId'),
      );
    }
    return null;
  }

  static List<LineModifier> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <LineModifier>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = LineModifier.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, LineModifier> mapFromJson(dynamic json) {
    final map = <String, LineModifier>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = LineModifier.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of LineModifier-objects as value to a dart map
  static Map<String, List<LineModifier>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<LineModifier>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = LineModifier.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'modifierId',
    'name',
    'quantity',
    'priceDeltaMinor',
    'lineDeltaMinor',
    'stockItemId',
  };
}

