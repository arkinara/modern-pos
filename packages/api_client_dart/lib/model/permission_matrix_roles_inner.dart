//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PermissionMatrixRolesInner {
  /// Returns a new [PermissionMatrixRolesInner] instance.
  PermissionMatrixRolesInner({
    required this.role,
    this.permissions = const [],
  });

  PermissionMatrixRolesInnerRoleEnum role;

  List<String> permissions;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PermissionMatrixRolesInner &&
    other.role == role &&
    _deepEquality.equals(other.permissions, permissions);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (role.hashCode) +
    (permissions.hashCode);

  @override
  String toString() => 'PermissionMatrixRolesInner[role=$role, permissions=$permissions]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'role'] = this.role;
      json[r'permissions'] = this.permissions;
    return json;
  }

  /// Returns a new [PermissionMatrixRolesInner] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PermissionMatrixRolesInner? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'role'), 'Required key "PermissionMatrixRolesInner[role]" is missing from JSON.');
        assert(json[r'role'] != null, 'Required key "PermissionMatrixRolesInner[role]" has a null value in JSON.');
        assert(json.containsKey(r'permissions'), 'Required key "PermissionMatrixRolesInner[permissions]" is missing from JSON.');
        assert(json[r'permissions'] != null, 'Required key "PermissionMatrixRolesInner[permissions]" has a null value in JSON.');
        return true;
      }());

      return PermissionMatrixRolesInner(
        role: PermissionMatrixRolesInnerRoleEnum.fromJson(json[r'role'])!,
        permissions: json[r'permissions'] is Iterable
            ? (json[r'permissions'] as Iterable).cast<String>().toList(growable: false)
            : const [],
      );
    }
    return null;
  }

  static List<PermissionMatrixRolesInner> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PermissionMatrixRolesInner>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PermissionMatrixRolesInner.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PermissionMatrixRolesInner> mapFromJson(dynamic json) {
    final map = <String, PermissionMatrixRolesInner>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PermissionMatrixRolesInner.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PermissionMatrixRolesInner-objects as value to a dart map
  static Map<String, List<PermissionMatrixRolesInner>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PermissionMatrixRolesInner>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PermissionMatrixRolesInner.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'role',
    'permissions',
  };
}


enum PermissionMatrixRolesInnerRoleEnum {
  OWNER._(r'OWNER'),
  CASHIER._(r'CASHIER'),
  ;

  /// Instantiate a new enum with the provided value.
  const PermissionMatrixRolesInnerRoleEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [PermissionMatrixRolesInnerRoleEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static PermissionMatrixRolesInnerRoleEnum? fromJson(dynamic value) => PermissionMatrixRolesInnerRoleEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [PermissionMatrixRolesInnerRoleEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<PermissionMatrixRolesInnerRoleEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PermissionMatrixRolesInnerRoleEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PermissionMatrixRolesInnerRoleEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [PermissionMatrixRolesInnerRoleEnum] to String,
/// and [decode] dynamic data back to [PermissionMatrixRolesInnerRoleEnum].
class PermissionMatrixRolesInnerRoleEnumTypeTransformer {
  factory PermissionMatrixRolesInnerRoleEnumTypeTransformer() => _instance ??= const PermissionMatrixRolesInnerRoleEnumTypeTransformer._();

  const PermissionMatrixRolesInnerRoleEnumTypeTransformer._();

  String encode(PermissionMatrixRolesInnerRoleEnum data) => data._value;

  /// Returns the instance of [PermissionMatrixRolesInnerRoleEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  PermissionMatrixRolesInnerRoleEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is PermissionMatrixRolesInnerRoleEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'OWNER': return PermissionMatrixRolesInnerRoleEnum.OWNER;
        case r'CASHIER': return PermissionMatrixRolesInnerRoleEnum.CASHIER;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static PermissionMatrixRolesInnerRoleEnumTypeTransformer? _instance;
}


