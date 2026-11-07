//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class AuthMobileRefreshRequest {
  /// Returns a new [AuthMobileRefreshRequest] instance.
  AuthMobileRefreshRequest({
    required this.refreshToken,
    required this.deviceId,
  });

  String refreshToken;

  String deviceId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AuthMobileRefreshRequest &&
    other.refreshToken == refreshToken &&
    other.deviceId == deviceId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (refreshToken.hashCode) +
    (deviceId.hashCode);

  @override
  String toString() => 'AuthMobileRefreshRequest[refreshToken=$refreshToken, deviceId=$deviceId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'refreshToken'] = this.refreshToken;
      json[r'deviceId'] = this.deviceId;
    return json;
  }

  /// Returns a new [AuthMobileRefreshRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static AuthMobileRefreshRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'refreshToken'), 'Required key "AuthMobileRefreshRequest[refreshToken]" is missing from JSON.');
        assert(json[r'refreshToken'] != null, 'Required key "AuthMobileRefreshRequest[refreshToken]" has a null value in JSON.');
        assert(json.containsKey(r'deviceId'), 'Required key "AuthMobileRefreshRequest[deviceId]" is missing from JSON.');
        assert(json[r'deviceId'] != null, 'Required key "AuthMobileRefreshRequest[deviceId]" has a null value in JSON.');
        return true;
      }());

      return AuthMobileRefreshRequest(
        refreshToken: mapValueOfType<String>(json, r'refreshToken')!,
        deviceId: mapValueOfType<String>(json, r'deviceId')!,
      );
    }
    return null;
  }

  static List<AuthMobileRefreshRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AuthMobileRefreshRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AuthMobileRefreshRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, AuthMobileRefreshRequest> mapFromJson(dynamic json) {
    final map = <String, AuthMobileRefreshRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = AuthMobileRefreshRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of AuthMobileRefreshRequest-objects as value to a dart map
  static Map<String, List<AuthMobileRefreshRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<AuthMobileRefreshRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = AuthMobileRefreshRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'refreshToken',
    'deviceId',
  };
}

