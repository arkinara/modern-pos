//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PermissionMatrix {
  /// Returns a new [PermissionMatrix] instance.
  PermissionMatrix({
    this.roles = const [],
    this.operations = const [],
  });

  List<PermissionMatrixRolesInner> roles;

  List<PermissionMatrixOperationsInner> operations;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PermissionMatrix &&
    _deepEquality.equals(other.roles, roles) &&
    _deepEquality.equals(other.operations, operations);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (roles.hashCode) +
    (operations.hashCode);

  @override
  String toString() => 'PermissionMatrix[roles=$roles, operations=$operations]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'roles'] = this.roles;
      json[r'operations'] = this.operations;
    return json;
  }

  /// Returns a new [PermissionMatrix] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PermissionMatrix? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'roles'), 'Required key "PermissionMatrix[roles]" is missing from JSON.');
        assert(json[r'roles'] != null, 'Required key "PermissionMatrix[roles]" has a null value in JSON.');
        assert(json.containsKey(r'operations'), 'Required key "PermissionMatrix[operations]" is missing from JSON.');
        assert(json[r'operations'] != null, 'Required key "PermissionMatrix[operations]" has a null value in JSON.');
        return true;
      }());

      return PermissionMatrix(
        roles: PermissionMatrixRolesInner.listFromJson(json[r'roles']),
        operations: PermissionMatrixOperationsInner.listFromJson(json[r'operations']),
      );
    }
    return null;
  }

  static List<PermissionMatrix> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PermissionMatrix>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PermissionMatrix.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PermissionMatrix> mapFromJson(dynamic json) {
    final map = <String, PermissionMatrix>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PermissionMatrix.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PermissionMatrix-objects as value to a dart map
  static Map<String, List<PermissionMatrix>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PermissionMatrix>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PermissionMatrix.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'roles',
    'operations',
  };
}

