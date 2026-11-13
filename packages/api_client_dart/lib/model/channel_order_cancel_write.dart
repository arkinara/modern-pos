//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ChannelOrderCancelWrite {
  /// Returns a new [ChannelOrderCancelWrite] instance.
  ChannelOrderCancelWrite({
    required this.reason,
  });

  String reason;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ChannelOrderCancelWrite &&
    other.reason == reason;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (reason.hashCode);

  @override
  String toString() => 'ChannelOrderCancelWrite[reason=$reason]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'reason'] = this.reason;
    return json;
  }

  /// Returns a new [ChannelOrderCancelWrite] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ChannelOrderCancelWrite? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'reason'), 'Required key "ChannelOrderCancelWrite[reason]" is missing from JSON.');
        assert(json[r'reason'] != null, 'Required key "ChannelOrderCancelWrite[reason]" has a null value in JSON.');
        return true;
      }());

      return ChannelOrderCancelWrite(
        reason: mapValueOfType<String>(json, r'reason')!,
      );
    }
    return null;
  }

  static List<ChannelOrderCancelWrite> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ChannelOrderCancelWrite>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ChannelOrderCancelWrite.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ChannelOrderCancelWrite> mapFromJson(dynamic json) {
    final map = <String, ChannelOrderCancelWrite>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ChannelOrderCancelWrite.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ChannelOrderCancelWrite-objects as value to a dart map
  static Map<String, List<ChannelOrderCancelWrite>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ChannelOrderCancelWrite>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ChannelOrderCancelWrite.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'reason',
  };
}

