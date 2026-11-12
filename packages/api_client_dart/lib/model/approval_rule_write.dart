//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ApprovalRuleWrite {
  /// Returns a new [ApprovalRuleWrite] instance.
  ApprovalRuleWrite({
    required this.thresholdMinor,
    this.active,
  });

  /// Currency minor units; IDR exponent 0 in demo.
  ///
  /// Minimum value: 0
  /// Maximum value: 9007199254740991
  int thresholdMinor;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? active;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ApprovalRuleWrite &&
    other.thresholdMinor == thresholdMinor &&
    other.active == active;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (thresholdMinor.hashCode) +
    (active == null ? 0 : active!.hashCode);

  @override
  String toString() => 'ApprovalRuleWrite[thresholdMinor=$thresholdMinor, active=$active]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'thresholdMinor'] = this.thresholdMinor;
    if (this.active != null) {
      json[r'active'] = this.active;
    } else {
      json[r'active'] = null;
    }
    return json;
  }

  /// Returns a new [ApprovalRuleWrite] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ApprovalRuleWrite? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'thresholdMinor'), 'Required key "ApprovalRuleWrite[thresholdMinor]" is missing from JSON.');
        assert(json[r'thresholdMinor'] != null, 'Required key "ApprovalRuleWrite[thresholdMinor]" has a null value in JSON.');
        return true;
      }());

      return ApprovalRuleWrite(
        thresholdMinor: mapValueOfType<int>(json, r'thresholdMinor')!,
        active: mapValueOfType<bool>(json, r'active'),
      );
    }
    return null;
  }

  static List<ApprovalRuleWrite> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ApprovalRuleWrite>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ApprovalRuleWrite.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ApprovalRuleWrite> mapFromJson(dynamic json) {
    final map = <String, ApprovalRuleWrite>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ApprovalRuleWrite.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ApprovalRuleWrite-objects as value to a dart map
  static Map<String, List<ApprovalRuleWrite>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ApprovalRuleWrite>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ApprovalRuleWrite.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'thresholdMinor',
  };
}

