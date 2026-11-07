//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Recipe {
  /// Returns a new [Recipe] instance.
  Recipe({
    required this.id,
    required this.variantId,
    required this.version,
    this.lines = const [],
  });

  String id;

  String variantId;

  /// Minimum value: 1
  int version;

  List<RecipeLine> lines;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Recipe &&
    other.id == id &&
    other.variantId == variantId &&
    other.version == version &&
    _deepEquality.equals(other.lines, lines);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (variantId.hashCode) +
    (version.hashCode) +
    (lines.hashCode);

  @override
  String toString() => 'Recipe[id=$id, variantId=$variantId, version=$version, lines=$lines]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'variantId'] = this.variantId;
      json[r'version'] = this.version;
      json[r'lines'] = this.lines;
    return json;
  }

  /// Returns a new [Recipe] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Recipe? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "Recipe[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "Recipe[id]" has a null value in JSON.');
        assert(json.containsKey(r'variantId'), 'Required key "Recipe[variantId]" is missing from JSON.');
        assert(json[r'variantId'] != null, 'Required key "Recipe[variantId]" has a null value in JSON.');
        assert(json.containsKey(r'version'), 'Required key "Recipe[version]" is missing from JSON.');
        assert(json[r'version'] != null, 'Required key "Recipe[version]" has a null value in JSON.');
        assert(json.containsKey(r'lines'), 'Required key "Recipe[lines]" is missing from JSON.');
        assert(json[r'lines'] != null, 'Required key "Recipe[lines]" has a null value in JSON.');
        return true;
      }());

      return Recipe(
        id: mapValueOfType<String>(json, r'id')!,
        variantId: mapValueOfType<String>(json, r'variantId')!,
        version: mapValueOfType<int>(json, r'version')!,
        lines: RecipeLine.listFromJson(json[r'lines']),
      );
    }
    return null;
  }

  static List<Recipe> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Recipe>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Recipe.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Recipe> mapFromJson(dynamic json) {
    final map = <String, Recipe>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Recipe.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Recipe-objects as value to a dart map
  static Map<String, List<Recipe>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Recipe>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Recipe.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'variantId',
    'version',
    'lines',
  };
}

