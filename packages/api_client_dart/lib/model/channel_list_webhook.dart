//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ChannelListWebhook {
  /// Returns a new [ChannelListWebhook] instance.
  ChannelListWebhook({
    required this.configured,
    required this.replayWindowSeconds,
  });

  bool configured;

  int replayWindowSeconds;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ChannelListWebhook &&
    other.configured == configured &&
    other.replayWindowSeconds == replayWindowSeconds;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (configured.hashCode) +
    (replayWindowSeconds.hashCode);

  @override
  String toString() => 'ChannelListWebhook[configured=$configured, replayWindowSeconds=$replayWindowSeconds]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'configured'] = this.configured;
      json[r'replayWindowSeconds'] = this.replayWindowSeconds;
    return json;
  }

  /// Returns a new [ChannelListWebhook] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ChannelListWebhook? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'configured'), 'Required key "ChannelListWebhook[configured]" is missing from JSON.');
        assert(json[r'configured'] != null, 'Required key "ChannelListWebhook[configured]" has a null value in JSON.');
        assert(json.containsKey(r'replayWindowSeconds'), 'Required key "ChannelListWebhook[replayWindowSeconds]" is missing from JSON.');
        assert(json[r'replayWindowSeconds'] != null, 'Required key "ChannelListWebhook[replayWindowSeconds]" has a null value in JSON.');
        return true;
      }());

      return ChannelListWebhook(
        configured: mapValueOfType<bool>(json, r'configured')!,
        replayWindowSeconds: mapValueOfType<int>(json, r'replayWindowSeconds')!,
      );
    }
    return null;
  }

  static List<ChannelListWebhook> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ChannelListWebhook>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ChannelListWebhook.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ChannelListWebhook> mapFromJson(dynamic json) {
    final map = <String, ChannelListWebhook>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ChannelListWebhook.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ChannelListWebhook-objects as value to a dart map
  static Map<String, List<ChannelListWebhook>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ChannelListWebhook>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ChannelListWebhook.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'configured',
    'replayWindowSeconds',
  };
}

