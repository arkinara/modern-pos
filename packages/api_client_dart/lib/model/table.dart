//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Table {
  /// Returns a new [Table] instance.
  Table({
    required this.id,
    required this.label,
    required this.seatCount,
    required this.active,
  });

  String id;

  String label;

  int seatCount;

  bool active;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Table &&
    other.id == id &&
    other.label == label &&
    other.seatCount == seatCount &&
    other.active == active;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (label.hashCode) +
    (seatCount.hashCode) +
    (active.hashCode);

  @override
  String toString() => 'Table[id=$id, label=$label, seatCount=$seatCount, active=$active]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'label'] = this.label;
      json[r'seatCount'] = this.seatCount;
      json[r'active'] = this.active;
    return json;
  }

  /// Returns a new [Table] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Table? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "Table[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "Table[id]" has a null value in JSON.');
        assert(json.containsKey(r'label'), 'Required key "Table[label]" is missing from JSON.');
        assert(json[r'label'] != null, 'Required key "Table[label]" has a null value in JSON.');
        assert(json.containsKey(r'seatCount'), 'Required key "Table[seatCount]" is missing from JSON.');
        assert(json[r'seatCount'] != null, 'Required key "Table[seatCount]" has a null value in JSON.');
        assert(json.containsKey(r'active'), 'Required key "Table[active]" is missing from JSON.');
        assert(json[r'active'] != null, 'Required key "Table[active]" has a null value in JSON.');
        return true;
      }());

      return Table(
        id: mapValueOfType<String>(json, r'id')!,
        label: mapValueOfType<String>(json, r'label')!,
        seatCount: mapValueOfType<int>(json, r'seatCount')!,
        active: mapValueOfType<bool>(json, r'active')!,
      );
    }
    return null;
  }

  static List<Table> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Table>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Table.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Table> mapFromJson(dynamic json) {
    final map = <String, Table>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Table.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Table-objects as value to a dart map
  static Map<String, List<Table>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Table>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Table.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'label',
    'seatCount',
    'active',
  };
}

