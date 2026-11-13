//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ExpenseCategory {
  /// Returns a new [ExpenseCategory] instance.
  ExpenseCategory({
    required this.id,
    required this.name,
    required this.active,
    required this.createdAt,
  });

  String id;

  String name;

  bool active;

  DateTime createdAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ExpenseCategory &&
    other.id == id &&
    other.name == name &&
    other.active == active &&
    other.createdAt == createdAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (name.hashCode) +
    (active.hashCode) +
    (createdAt.hashCode);

  @override
  String toString() => 'ExpenseCategory[id=$id, name=$name, active=$active, createdAt=$createdAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'name'] = this.name;
      json[r'active'] = this.active;
      json[r'createdAt'] = this.createdAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [ExpenseCategory] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ExpenseCategory? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "ExpenseCategory[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "ExpenseCategory[id]" has a null value in JSON.');
        assert(json.containsKey(r'name'), 'Required key "ExpenseCategory[name]" is missing from JSON.');
        assert(json[r'name'] != null, 'Required key "ExpenseCategory[name]" has a null value in JSON.');
        assert(json.containsKey(r'active'), 'Required key "ExpenseCategory[active]" is missing from JSON.');
        assert(json[r'active'] != null, 'Required key "ExpenseCategory[active]" has a null value in JSON.');
        assert(json.containsKey(r'createdAt'), 'Required key "ExpenseCategory[createdAt]" is missing from JSON.');
        assert(json[r'createdAt'] != null, 'Required key "ExpenseCategory[createdAt]" has a null value in JSON.');
        return true;
      }());

      return ExpenseCategory(
        id: mapValueOfType<String>(json, r'id')!,
        name: mapValueOfType<String>(json, r'name')!,
        active: mapValueOfType<bool>(json, r'active')!,
        createdAt: mapDateTime(json, r'createdAt', r'')!,
      );
    }
    return null;
  }

  static List<ExpenseCategory> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ExpenseCategory>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ExpenseCategory.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ExpenseCategory> mapFromJson(dynamic json) {
    final map = <String, ExpenseCategory>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ExpenseCategory.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ExpenseCategory-objects as value to a dart map
  static Map<String, List<ExpenseCategory>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ExpenseCategory>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ExpenseCategory.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'name',
    'active',
    'createdAt',
  };
}

