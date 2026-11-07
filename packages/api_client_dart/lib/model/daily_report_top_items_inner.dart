//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class DailyReportTopItemsInner {
  /// Returns a new [DailyReportTopItemsInner] instance.
  DailyReportTopItemsInner({
    required this.name,
    required this.quantity,
  });

  String name;

  /// Minimum value: 0
  int quantity;

  @override
  bool operator ==(Object other) => identical(this, other) || other is DailyReportTopItemsInner &&
    other.name == name &&
    other.quantity == quantity;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (name.hashCode) +
    (quantity.hashCode);

  @override
  String toString() => 'DailyReportTopItemsInner[name=$name, quantity=$quantity]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'name'] = this.name;
      json[r'quantity'] = this.quantity;
    return json;
  }

  /// Returns a new [DailyReportTopItemsInner] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static DailyReportTopItemsInner? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'name'), 'Required key "DailyReportTopItemsInner[name]" is missing from JSON.');
        assert(json[r'name'] != null, 'Required key "DailyReportTopItemsInner[name]" has a null value in JSON.');
        assert(json.containsKey(r'quantity'), 'Required key "DailyReportTopItemsInner[quantity]" is missing from JSON.');
        assert(json[r'quantity'] != null, 'Required key "DailyReportTopItemsInner[quantity]" has a null value in JSON.');
        return true;
      }());

      return DailyReportTopItemsInner(
        name: mapValueOfType<String>(json, r'name')!,
        quantity: mapValueOfType<int>(json, r'quantity')!,
      );
    }
    return null;
  }

  static List<DailyReportTopItemsInner> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DailyReportTopItemsInner>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DailyReportTopItemsInner.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, DailyReportTopItemsInner> mapFromJson(dynamic json) {
    final map = <String, DailyReportTopItemsInner>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = DailyReportTopItemsInner.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of DailyReportTopItemsInner-objects as value to a dart map
  static Map<String, List<DailyReportTopItemsInner>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<DailyReportTopItemsInner>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = DailyReportTopItemsInner.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'name',
    'quantity',
  };
}

