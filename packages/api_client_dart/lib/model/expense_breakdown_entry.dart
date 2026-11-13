//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ExpenseBreakdownEntry {
  /// Returns a new [ExpenseBreakdownEntry] instance.
  ExpenseBreakdownEntry({
    required this.categoryId,
    required this.name,
    required this.amountMinor,
    required this.derived,
  });

  String? categoryId;

  String name;

  /// Minimum value: 0
  /// Maximum value: 9007199254740991
  int amountMinor;

  bool derived;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ExpenseBreakdownEntry &&
    other.categoryId == categoryId &&
    other.name == name &&
    other.amountMinor == amountMinor &&
    other.derived == derived;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (categoryId == null ? 0 : categoryId!.hashCode) +
    (name.hashCode) +
    (amountMinor.hashCode) +
    (derived.hashCode);

  @override
  String toString() => 'ExpenseBreakdownEntry[categoryId=$categoryId, name=$name, amountMinor=$amountMinor, derived=$derived]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.categoryId != null) {
      json[r'categoryId'] = this.categoryId;
    } else {
      json[r'categoryId'] = null;
    }
      json[r'name'] = this.name;
      json[r'amountMinor'] = this.amountMinor;
      json[r'derived'] = this.derived;
    return json;
  }

  /// Returns a new [ExpenseBreakdownEntry] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ExpenseBreakdownEntry? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'categoryId'), 'Required key "ExpenseBreakdownEntry[categoryId]" is missing from JSON.');
        assert(json.containsKey(r'name'), 'Required key "ExpenseBreakdownEntry[name]" is missing from JSON.');
        assert(json[r'name'] != null, 'Required key "ExpenseBreakdownEntry[name]" has a null value in JSON.');
        assert(json.containsKey(r'amountMinor'), 'Required key "ExpenseBreakdownEntry[amountMinor]" is missing from JSON.');
        assert(json[r'amountMinor'] != null, 'Required key "ExpenseBreakdownEntry[amountMinor]" has a null value in JSON.');
        assert(json.containsKey(r'derived'), 'Required key "ExpenseBreakdownEntry[derived]" is missing from JSON.');
        assert(json[r'derived'] != null, 'Required key "ExpenseBreakdownEntry[derived]" has a null value in JSON.');
        return true;
      }());

      return ExpenseBreakdownEntry(
        categoryId: mapValueOfType<String>(json, r'categoryId'),
        name: mapValueOfType<String>(json, r'name')!,
        amountMinor: mapValueOfType<int>(json, r'amountMinor')!,
        derived: mapValueOfType<bool>(json, r'derived')!,
      );
    }
    return null;
  }

  static List<ExpenseBreakdownEntry> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ExpenseBreakdownEntry>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ExpenseBreakdownEntry.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ExpenseBreakdownEntry> mapFromJson(dynamic json) {
    final map = <String, ExpenseBreakdownEntry>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ExpenseBreakdownEntry.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ExpenseBreakdownEntry-objects as value to a dart map
  static Map<String, List<ExpenseBreakdownEntry>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ExpenseBreakdownEntry>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ExpenseBreakdownEntry.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'categoryId',
    'name',
    'amountMinor',
    'derived',
  };
}

