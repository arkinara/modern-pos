//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ChannelOrderCreateResult {
  /// Returns a new [ChannelOrderCreateResult] instance.
  ChannelOrderCreateResult({
    required this.duplicate,
    required this.order,
  });

  bool duplicate;

  ChannelOrder order;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ChannelOrderCreateResult &&
    other.duplicate == duplicate &&
    other.order == order;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (duplicate.hashCode) +
    (order.hashCode);

  @override
  String toString() => 'ChannelOrderCreateResult[duplicate=$duplicate, order=$order]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'duplicate'] = this.duplicate;
      json[r'order'] = this.order;
    return json;
  }

  /// Returns a new [ChannelOrderCreateResult] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ChannelOrderCreateResult? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'duplicate'), 'Required key "ChannelOrderCreateResult[duplicate]" is missing from JSON.');
        assert(json[r'duplicate'] != null, 'Required key "ChannelOrderCreateResult[duplicate]" has a null value in JSON.');
        assert(json.containsKey(r'order'), 'Required key "ChannelOrderCreateResult[order]" is missing from JSON.');
        assert(json[r'order'] != null, 'Required key "ChannelOrderCreateResult[order]" has a null value in JSON.');
        return true;
      }());

      return ChannelOrderCreateResult(
        duplicate: mapValueOfType<bool>(json, r'duplicate')!,
        order: ChannelOrder.fromJson(json[r'order'])!,
      );
    }
    return null;
  }

  static List<ChannelOrderCreateResult> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ChannelOrderCreateResult>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ChannelOrderCreateResult.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ChannelOrderCreateResult> mapFromJson(dynamic json) {
    final map = <String, ChannelOrderCreateResult>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ChannelOrderCreateResult.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ChannelOrderCreateResult-objects as value to a dart map
  static Map<String, List<ChannelOrderCreateResult>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ChannelOrderCreateResult>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ChannelOrderCreateResult.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'duplicate',
    'order',
  };
}

