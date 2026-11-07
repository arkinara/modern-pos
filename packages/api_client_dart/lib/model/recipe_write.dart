//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class RecipeWrite {
  /// Returns a new [RecipeWrite] instance.
  RecipeWrite({
    required this.expectedVersion,
    this.lines = const [],
  });

  /// Minimum value: 0
  int expectedVersion;

  List<RecipeLine> lines;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RecipeWrite &&
    other.expectedVersion == expectedVersion &&
    _deepEquality.equals(other.lines, lines);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (expectedVersion.hashCode) +
    (lines.hashCode);

  @override
  String toString() => 'RecipeWrite[expectedVersion=$expectedVersion, lines=$lines]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'expectedVersion'] = this.expectedVersion;
      json[r'lines'] = this.lines;
    return json;
  }

  /// Returns a new [RecipeWrite] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RecipeWrite? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'expectedVersion'), 'Required key "RecipeWrite[expectedVersion]" is missing from JSON.');
        assert(json[r'expectedVersion'] != null, 'Required key "RecipeWrite[expectedVersion]" has a null value in JSON.');
        assert(json.containsKey(r'lines'), 'Required key "RecipeWrite[lines]" is missing from JSON.');
        assert(json[r'lines'] != null, 'Required key "RecipeWrite[lines]" has a null value in JSON.');
        return true;
      }());

      return RecipeWrite(
        expectedVersion: mapValueOfType<int>(json, r'expectedVersion')!,
        lines: RecipeLine.listFromJson(json[r'lines']),
      );
    }
    return null;
  }

  static List<RecipeWrite> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RecipeWrite>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RecipeWrite.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RecipeWrite> mapFromJson(dynamic json) {
    final map = <String, RecipeWrite>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RecipeWrite.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RecipeWrite-objects as value to a dart map
  static Map<String, List<RecipeWrite>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<RecipeWrite>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RecipeWrite.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'expectedVersion',
    'lines',
  };
}

