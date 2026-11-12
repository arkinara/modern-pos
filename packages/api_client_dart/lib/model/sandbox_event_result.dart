//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class SandboxEventResult {
  /// Returns a new [SandboxEventResult] instance.
  SandboxEventResult({
    this.event = const {},
    required this.timestamp,
    required this.signature,
    required this.rawBody,
  });

  Map<String, Object> event;

  int timestamp;

  String signature;

  String rawBody;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SandboxEventResult &&
    _deepEquality.equals(other.event, event) &&
    other.timestamp == timestamp &&
    other.signature == signature &&
    other.rawBody == rawBody;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (event.hashCode) +
    (timestamp.hashCode) +
    (signature.hashCode) +
    (rawBody.hashCode);

  @override
  String toString() => 'SandboxEventResult[event=$event, timestamp=$timestamp, signature=$signature, rawBody=$rawBody]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'event'] = this.event;
      json[r'timestamp'] = this.timestamp;
      json[r'signature'] = this.signature;
      json[r'rawBody'] = this.rawBody;
    return json;
  }

  /// Returns a new [SandboxEventResult] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SandboxEventResult? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'event'), 'Required key "SandboxEventResult[event]" is missing from JSON.');
        assert(json[r'event'] != null, 'Required key "SandboxEventResult[event]" has a null value in JSON.');
        assert(json.containsKey(r'timestamp'), 'Required key "SandboxEventResult[timestamp]" is missing from JSON.');
        assert(json[r'timestamp'] != null, 'Required key "SandboxEventResult[timestamp]" has a null value in JSON.');
        assert(json.containsKey(r'signature'), 'Required key "SandboxEventResult[signature]" is missing from JSON.');
        assert(json[r'signature'] != null, 'Required key "SandboxEventResult[signature]" has a null value in JSON.');
        assert(json.containsKey(r'rawBody'), 'Required key "SandboxEventResult[rawBody]" is missing from JSON.');
        assert(json[r'rawBody'] != null, 'Required key "SandboxEventResult[rawBody]" has a null value in JSON.');
        return true;
      }());

      return SandboxEventResult(
        event: mapCastOfType<String, Object>(json, r'event')!,
        timestamp: mapValueOfType<int>(json, r'timestamp')!,
        signature: mapValueOfType<String>(json, r'signature')!,
        rawBody: mapValueOfType<String>(json, r'rawBody')!,
      );
    }
    return null;
  }

  static List<SandboxEventResult> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SandboxEventResult>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SandboxEventResult.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SandboxEventResult> mapFromJson(dynamic json) {
    final map = <String, SandboxEventResult>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SandboxEventResult.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SandboxEventResult-objects as value to a dart map
  static Map<String, List<SandboxEventResult>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SandboxEventResult>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SandboxEventResult.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'event',
    'timestamp',
    'signature',
    'rawBody',
  };
}

