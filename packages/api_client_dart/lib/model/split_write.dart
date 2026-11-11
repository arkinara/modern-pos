//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class SplitWrite {
  /// Returns a new [SplitWrite] instance.
  SplitWrite({
    required this.version,
    this.bills = const [],
  });

  /// Minimum value: 1
  int version;

  List<SplitBill> bills;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SplitWrite &&
    other.version == version &&
    _deepEquality.equals(other.bills, bills);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (version.hashCode) +
    (bills.hashCode);

  @override
  String toString() => 'SplitWrite[version=$version, bills=$bills]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'version'] = this.version;
      json[r'bills'] = this.bills;
    return json;
  }

  /// Returns a new [SplitWrite] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SplitWrite? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'version'), 'Required key "SplitWrite[version]" is missing from JSON.');
        assert(json[r'version'] != null, 'Required key "SplitWrite[version]" has a null value in JSON.');
        assert(json.containsKey(r'bills'), 'Required key "SplitWrite[bills]" is missing from JSON.');
        assert(json[r'bills'] != null, 'Required key "SplitWrite[bills]" has a null value in JSON.');
        return true;
      }());

      return SplitWrite(
        version: mapValueOfType<int>(json, r'version')!,
        bills: SplitBill.listFromJson(json[r'bills']),
      );
    }
    return null;
  }

  static List<SplitWrite> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SplitWrite>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SplitWrite.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SplitWrite> mapFromJson(dynamic json) {
    final map = <String, SplitWrite>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SplitWrite.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SplitWrite-objects as value to a dart map
  static Map<String, List<SplitWrite>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SplitWrite>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SplitWrite.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'version',
    'bills',
  };
}

