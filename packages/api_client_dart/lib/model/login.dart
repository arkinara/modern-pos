//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Login {
  /// Returns a new [Login] instance.
  Login({
    required this.email,
    required this.password,
    required this.deviceId,
  });

  String email;

  String password;

  String deviceId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Login &&
    other.email == email &&
    other.password == password &&
    other.deviceId == deviceId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (email.hashCode) +
    (password.hashCode) +
    (deviceId.hashCode);

  @override
  String toString() => 'Login[email=$email, password=$password, deviceId=$deviceId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'email'] = this.email;
      json[r'password'] = this.password;
      json[r'deviceId'] = this.deviceId;
    return json;
  }

  /// Returns a new [Login] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Login? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'email'), 'Required key "Login[email]" is missing from JSON.');
        assert(json[r'email'] != null, 'Required key "Login[email]" has a null value in JSON.');
        assert(json.containsKey(r'password'), 'Required key "Login[password]" is missing from JSON.');
        assert(json[r'password'] != null, 'Required key "Login[password]" has a null value in JSON.');
        assert(json.containsKey(r'deviceId'), 'Required key "Login[deviceId]" is missing from JSON.');
        assert(json[r'deviceId'] != null, 'Required key "Login[deviceId]" has a null value in JSON.');
        return true;
      }());

      return Login(
        email: mapValueOfType<String>(json, r'email')!,
        password: mapValueOfType<String>(json, r'password')!,
        deviceId: mapValueOfType<String>(json, r'deviceId')!,
      );
    }
    return null;
  }

  static List<Login> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Login>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Login.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Login> mapFromJson(dynamic json) {
    final map = <String, Login>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Login.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Login-objects as value to a dart map
  static Map<String, List<Login>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Login>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Login.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'email',
    'password',
    'deviceId',
  };
}

