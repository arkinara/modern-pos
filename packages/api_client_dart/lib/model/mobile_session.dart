//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class MobileSession {
  /// Returns a new [MobileSession] instance.
  MobileSession({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresInSeconds,
    required this.user,
  });

  String accessToken;

  String refreshToken;

  MobileSessionExpiresInSecondsEnum expiresInSeconds;

  User user;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MobileSession &&
    other.accessToken == accessToken &&
    other.refreshToken == refreshToken &&
    other.expiresInSeconds == expiresInSeconds &&
    other.user == user;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (accessToken.hashCode) +
    (refreshToken.hashCode) +
    (expiresInSeconds.hashCode) +
    (user.hashCode);

  @override
  String toString() => 'MobileSession[accessToken=$accessToken, refreshToken=$refreshToken, expiresInSeconds=$expiresInSeconds, user=$user]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'accessToken'] = this.accessToken;
      json[r'refreshToken'] = this.refreshToken;
      json[r'expiresInSeconds'] = this.expiresInSeconds;
      json[r'user'] = this.user;
    return json;
  }

  /// Returns a new [MobileSession] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static MobileSession? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'accessToken'), 'Required key "MobileSession[accessToken]" is missing from JSON.');
        assert(json[r'accessToken'] != null, 'Required key "MobileSession[accessToken]" has a null value in JSON.');
        assert(json.containsKey(r'refreshToken'), 'Required key "MobileSession[refreshToken]" is missing from JSON.');
        assert(json[r'refreshToken'] != null, 'Required key "MobileSession[refreshToken]" has a null value in JSON.');
        assert(json.containsKey(r'expiresInSeconds'), 'Required key "MobileSession[expiresInSeconds]" is missing from JSON.');
        assert(json[r'expiresInSeconds'] != null, 'Required key "MobileSession[expiresInSeconds]" has a null value in JSON.');
        assert(json.containsKey(r'user'), 'Required key "MobileSession[user]" is missing from JSON.');
        assert(json[r'user'] != null, 'Required key "MobileSession[user]" has a null value in JSON.');
        return true;
      }());

      return MobileSession(
        accessToken: mapValueOfType<String>(json, r'accessToken')!,
        refreshToken: mapValueOfType<String>(json, r'refreshToken')!,
        expiresInSeconds: MobileSessionExpiresInSecondsEnum.fromJson(json[r'expiresInSeconds'])!,
        user: User.fromJson(json[r'user'])!,
      );
    }
    return null;
  }

  static List<MobileSession> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MobileSession>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MobileSession.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, MobileSession> mapFromJson(dynamic json) {
    final map = <String, MobileSession>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = MobileSession.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of MobileSession-objects as value to a dart map
  static Map<String, List<MobileSession>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<MobileSession>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = MobileSession.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'accessToken',
    'refreshToken',
    'expiresInSeconds',
    'user',
  };
}


enum MobileSessionExpiresInSecondsEnum {
  number600._(600),
  ;

  /// Instantiate a new enum with the provided value.
  const MobileSessionExpiresInSecondsEnum._(this._value);

  /// The underlying value of this enum member.
  final int _value;

  @override
  String toString() => _value.toString();

  /// Encodes this enum as a value suitable for JSON.
  int toJson() => _value;

  /// Returns the instance of [MobileSessionExpiresInSecondsEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static MobileSessionExpiresInSecondsEnum? fromJson(dynamic value) => MobileSessionExpiresInSecondsEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [MobileSessionExpiresInSecondsEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<MobileSessionExpiresInSecondsEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MobileSessionExpiresInSecondsEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MobileSessionExpiresInSecondsEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [MobileSessionExpiresInSecondsEnum] to int,
/// and [decode] dynamic data back to [MobileSessionExpiresInSecondsEnum].
class MobileSessionExpiresInSecondsEnumTypeTransformer {
  factory MobileSessionExpiresInSecondsEnumTypeTransformer() => _instance ??= const MobileSessionExpiresInSecondsEnumTypeTransformer._();

  const MobileSessionExpiresInSecondsEnumTypeTransformer._();

  int encode(MobileSessionExpiresInSecondsEnum data) => data._value;

  /// Returns the instance of [MobileSessionExpiresInSecondsEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  MobileSessionExpiresInSecondsEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is MobileSessionExpiresInSecondsEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case 600: return MobileSessionExpiresInSecondsEnum.number600;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static MobileSessionExpiresInSecondsEnumTypeTransformer? _instance;
}


