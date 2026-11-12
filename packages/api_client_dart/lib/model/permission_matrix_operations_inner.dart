//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PermissionMatrixOperationsInner {
  /// Returns a new [PermissionMatrixOperationsInner] instance.
  PermissionMatrixOperationsInner({
    required this.key,
    required this.label,
    required this.description,
  });

  String key;

  String label;

  String description;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PermissionMatrixOperationsInner &&
    other.key == key &&
    other.label == label &&
    other.description == description;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (key.hashCode) +
    (label.hashCode) +
    (description.hashCode);

  @override
  String toString() => 'PermissionMatrixOperationsInner[key=$key, label=$label, description=$description]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'key'] = this.key;
      json[r'label'] = this.label;
      json[r'description'] = this.description;
    return json;
  }

  /// Returns a new [PermissionMatrixOperationsInner] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PermissionMatrixOperationsInner? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'key'), 'Required key "PermissionMatrixOperationsInner[key]" is missing from JSON.');
        assert(json[r'key'] != null, 'Required key "PermissionMatrixOperationsInner[key]" has a null value in JSON.');
        assert(json.containsKey(r'label'), 'Required key "PermissionMatrixOperationsInner[label]" is missing from JSON.');
        assert(json[r'label'] != null, 'Required key "PermissionMatrixOperationsInner[label]" has a null value in JSON.');
        assert(json.containsKey(r'description'), 'Required key "PermissionMatrixOperationsInner[description]" is missing from JSON.');
        assert(json[r'description'] != null, 'Required key "PermissionMatrixOperationsInner[description]" has a null value in JSON.');
        return true;
      }());

      return PermissionMatrixOperationsInner(
        key: mapValueOfType<String>(json, r'key')!,
        label: mapValueOfType<String>(json, r'label')!,
        description: mapValueOfType<String>(json, r'description')!,
      );
    }
    return null;
  }

  static List<PermissionMatrixOperationsInner> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PermissionMatrixOperationsInner>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PermissionMatrixOperationsInner.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PermissionMatrixOperationsInner> mapFromJson(dynamic json) {
    final map = <String, PermissionMatrixOperationsInner>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PermissionMatrixOperationsInner.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PermissionMatrixOperationsInner-objects as value to a dart map
  static Map<String, List<PermissionMatrixOperationsInner>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PermissionMatrixOperationsInner>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PermissionMatrixOperationsInner.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'key',
    'label',
    'description',
  };
}

