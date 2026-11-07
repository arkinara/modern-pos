//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class User {
  /// Returns a new [User] instance.
  User({
    required this.id,
    required this.email,
    required this.role,
    this.outletIds = const [],
  });

  String id;

  String email;

  UserRoleEnum role;

  List<String> outletIds;

  @override
  bool operator ==(Object other) => identical(this, other) || other is User &&
    other.id == id &&
    other.email == email &&
    other.role == role &&
    _deepEquality.equals(other.outletIds, outletIds);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (email.hashCode) +
    (role.hashCode) +
    (outletIds.hashCode);

  @override
  String toString() => 'User[id=$id, email=$email, role=$role, outletIds=$outletIds]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'email'] = this.email;
      json[r'role'] = this.role;
      json[r'outletIds'] = this.outletIds;
    return json;
  }

  /// Returns a new [User] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static User? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "User[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "User[id]" has a null value in JSON.');
        assert(json.containsKey(r'email'), 'Required key "User[email]" is missing from JSON.');
        assert(json[r'email'] != null, 'Required key "User[email]" has a null value in JSON.');
        assert(json.containsKey(r'role'), 'Required key "User[role]" is missing from JSON.');
        assert(json[r'role'] != null, 'Required key "User[role]" has a null value in JSON.');
        assert(json.containsKey(r'outletIds'), 'Required key "User[outletIds]" is missing from JSON.');
        assert(json[r'outletIds'] != null, 'Required key "User[outletIds]" has a null value in JSON.');
        return true;
      }());

      return User(
        id: mapValueOfType<String>(json, r'id')!,
        email: mapValueOfType<String>(json, r'email')!,
        role: UserRoleEnum.fromJson(json[r'role'])!,
        outletIds: json[r'outletIds'] is Iterable
            ? (json[r'outletIds'] as Iterable).cast<String>().toList(growable: false)
            : const [],
      );
    }
    return null;
  }

  static List<User> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <User>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = User.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, User> mapFromJson(dynamic json) {
    final map = <String, User>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = User.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of User-objects as value to a dart map
  static Map<String, List<User>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<User>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = User.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'email',
    'role',
    'outletIds',
  };
}


enum UserRoleEnum {
  OWNER._(r'OWNER'),
  CASHIER._(r'CASHIER'),
  ;

  /// Instantiate a new enum with the provided value.
  const UserRoleEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [UserRoleEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static UserRoleEnum? fromJson(dynamic value) => UserRoleEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [UserRoleEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<UserRoleEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <UserRoleEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = UserRoleEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [UserRoleEnum] to String,
/// and [decode] dynamic data back to [UserRoleEnum].
class UserRoleEnumTypeTransformer {
  factory UserRoleEnumTypeTransformer() => _instance ??= const UserRoleEnumTypeTransformer._();

  const UserRoleEnumTypeTransformer._();

  String encode(UserRoleEnum data) => data._value;

  /// Returns the instance of [UserRoleEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  UserRoleEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is UserRoleEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'OWNER': return UserRoleEnum.OWNER;
        case r'CASHIER': return UserRoleEnum.CASHIER;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static UserRoleEnumTypeTransformer? _instance;
}


