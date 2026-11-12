//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ShiftWrite {
  /// Returns a new [ShiftWrite] instance.
  ShiftWrite({
    required this.openingFloatMinor,
  });

  /// Currency minor units; IDR exponent 0 in demo.
  ///
  /// Minimum value: 0
  /// Maximum value: 9007199254740991
  int openingFloatMinor;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ShiftWrite &&
    other.openingFloatMinor == openingFloatMinor;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (openingFloatMinor.hashCode);

  @override
  String toString() => 'ShiftWrite[openingFloatMinor=$openingFloatMinor]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'openingFloatMinor'] = this.openingFloatMinor;
    return json;
  }

  /// Returns a new [ShiftWrite] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ShiftWrite? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'openingFloatMinor'), 'Required key "ShiftWrite[openingFloatMinor]" is missing from JSON.');
        assert(json[r'openingFloatMinor'] != null, 'Required key "ShiftWrite[openingFloatMinor]" has a null value in JSON.');
        return true;
      }());

      return ShiftWrite(
        openingFloatMinor: mapValueOfType<int>(json, r'openingFloatMinor')!,
      );
    }
    return null;
  }

  static List<ShiftWrite> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ShiftWrite>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ShiftWrite.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ShiftWrite> mapFromJson(dynamic json) {
    final map = <String, ShiftWrite>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ShiftWrite.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ShiftWrite-objects as value to a dart map
  static Map<String, List<ShiftWrite>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ShiftWrite>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ShiftWrite.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'openingFloatMinor',
  };
}

