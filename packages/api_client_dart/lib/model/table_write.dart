//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class TableWrite {
  /// Returns a new [TableWrite] instance.
  TableWrite({
    required this.label,
    this.seatCount,
  });

  String label;

  /// Minimum value: 0
  /// Maximum value: 100
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? seatCount;

  @override
  bool operator ==(Object other) => identical(this, other) || other is TableWrite &&
    other.label == label &&
    other.seatCount == seatCount;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (label.hashCode) +
    (seatCount == null ? 0 : seatCount!.hashCode);

  @override
  String toString() => 'TableWrite[label=$label, seatCount=$seatCount]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'label'] = this.label;
    if (this.seatCount != null) {
      json[r'seatCount'] = this.seatCount;
    } else {
      json[r'seatCount'] = null;
    }
    return json;
  }

  /// Returns a new [TableWrite] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static TableWrite? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'label'), 'Required key "TableWrite[label]" is missing from JSON.');
        assert(json[r'label'] != null, 'Required key "TableWrite[label]" has a null value in JSON.');
        return true;
      }());

      return TableWrite(
        label: mapValueOfType<String>(json, r'label')!,
        seatCount: mapValueOfType<int>(json, r'seatCount'),
      );
    }
    return null;
  }

  static List<TableWrite> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <TableWrite>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = TableWrite.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, TableWrite> mapFromJson(dynamic json) {
    final map = <String, TableWrite>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = TableWrite.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of TableWrite-objects as value to a dart map
  static Map<String, List<TableWrite>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<TableWrite>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = TableWrite.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'label',
  };
}

