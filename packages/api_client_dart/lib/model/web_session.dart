//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class WebSession {
  /// Returns a new [WebSession] instance.
  WebSession({
    required this.accessToken,
    required this.expiresInSeconds,
    required this.user,
  });

  String accessToken;

  WebSessionExpiresInSecondsEnum expiresInSeconds;

  User user;

  @override
  bool operator ==(Object other) => identical(this, other) || other is WebSession &&
    other.accessToken == accessToken &&
    other.expiresInSeconds == expiresInSeconds &&
    other.user == user;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (accessToken.hashCode) +
    (expiresInSeconds.hashCode) +
    (user.hashCode);

  @override
  String toString() => 'WebSession[accessToken=$accessToken, expiresInSeconds=$expiresInSeconds, user=$user]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'accessToken'] = this.accessToken;
      json[r'expiresInSeconds'] = this.expiresInSeconds;
      json[r'user'] = this.user;
    return json;
  }

  /// Returns a new [WebSession] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static WebSession? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'accessToken'), 'Required key "WebSession[accessToken]" is missing from JSON.');
        assert(json[r'accessToken'] != null, 'Required key "WebSession[accessToken]" has a null value in JSON.');
        assert(json.containsKey(r'expiresInSeconds'), 'Required key "WebSession[expiresInSeconds]" is missing from JSON.');
        assert(json[r'expiresInSeconds'] != null, 'Required key "WebSession[expiresInSeconds]" has a null value in JSON.');
        assert(json.containsKey(r'user'), 'Required key "WebSession[user]" is missing from JSON.');
        assert(json[r'user'] != null, 'Required key "WebSession[user]" has a null value in JSON.');
        return true;
      }());

      return WebSession(
        accessToken: mapValueOfType<String>(json, r'accessToken')!,
        expiresInSeconds: WebSessionExpiresInSecondsEnum.fromJson(json[r'expiresInSeconds'])!,
        user: User.fromJson(json[r'user'])!,
      );
    }
    return null;
  }

  static List<WebSession> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <WebSession>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = WebSession.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, WebSession> mapFromJson(dynamic json) {
    final map = <String, WebSession>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = WebSession.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of WebSession-objects as value to a dart map
  static Map<String, List<WebSession>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<WebSession>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = WebSession.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'accessToken',
    'expiresInSeconds',
    'user',
  };
}


enum WebSessionExpiresInSecondsEnum {
  number600._(600),
  ;

  /// Instantiate a new enum with the provided value.
  const WebSessionExpiresInSecondsEnum._(this._value);

  /// The underlying value of this enum member.
  final int _value;

  @override
  String toString() => _value.toString();

  /// Encodes this enum as a value suitable for JSON.
  int toJson() => _value;

  /// Returns the instance of [WebSessionExpiresInSecondsEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static WebSessionExpiresInSecondsEnum? fromJson(dynamic value) => WebSessionExpiresInSecondsEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [WebSessionExpiresInSecondsEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<WebSessionExpiresInSecondsEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <WebSessionExpiresInSecondsEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = WebSessionExpiresInSecondsEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [WebSessionExpiresInSecondsEnum] to int,
/// and [decode] dynamic data back to [WebSessionExpiresInSecondsEnum].
class WebSessionExpiresInSecondsEnumTypeTransformer {
  factory WebSessionExpiresInSecondsEnumTypeTransformer() => _instance ??= const WebSessionExpiresInSecondsEnumTypeTransformer._();

  const WebSessionExpiresInSecondsEnumTypeTransformer._();

  int encode(WebSessionExpiresInSecondsEnum data) => data._value;

  /// Returns the instance of [WebSessionExpiresInSecondsEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  WebSessionExpiresInSecondsEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is WebSessionExpiresInSecondsEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case 600: return WebSessionExpiresInSecondsEnum.number600;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static WebSessionExpiresInSecondsEnumTypeTransformer? _instance;
}


