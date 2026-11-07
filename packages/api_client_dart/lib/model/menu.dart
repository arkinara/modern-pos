//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Menu {
  /// Returns a new [Menu] instance.
  Menu({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.revision,
    required this.archived,
    this.variants = const [],
  });

  String id;

  String name;

  String description;

  String categoryId;

  /// Minimum value: 1
  int revision;

  bool archived;

  List<Variant> variants;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Menu &&
    other.id == id &&
    other.name == name &&
    other.description == description &&
    other.categoryId == categoryId &&
    other.revision == revision &&
    other.archived == archived &&
    _deepEquality.equals(other.variants, variants);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (name.hashCode) +
    (description.hashCode) +
    (categoryId.hashCode) +
    (revision.hashCode) +
    (archived.hashCode) +
    (variants.hashCode);

  @override
  String toString() => 'Menu[id=$id, name=$name, description=$description, categoryId=$categoryId, revision=$revision, archived=$archived, variants=$variants]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'name'] = this.name;
      json[r'description'] = this.description;
      json[r'categoryId'] = this.categoryId;
      json[r'revision'] = this.revision;
      json[r'archived'] = this.archived;
      json[r'variants'] = this.variants;
    return json;
  }

  /// Returns a new [Menu] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Menu? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "Menu[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "Menu[id]" has a null value in JSON.');
        assert(json.containsKey(r'name'), 'Required key "Menu[name]" is missing from JSON.');
        assert(json[r'name'] != null, 'Required key "Menu[name]" has a null value in JSON.');
        assert(json.containsKey(r'description'), 'Required key "Menu[description]" is missing from JSON.');
        assert(json[r'description'] != null, 'Required key "Menu[description]" has a null value in JSON.');
        assert(json.containsKey(r'categoryId'), 'Required key "Menu[categoryId]" is missing from JSON.');
        assert(json[r'categoryId'] != null, 'Required key "Menu[categoryId]" has a null value in JSON.');
        assert(json.containsKey(r'revision'), 'Required key "Menu[revision]" is missing from JSON.');
        assert(json[r'revision'] != null, 'Required key "Menu[revision]" has a null value in JSON.');
        assert(json.containsKey(r'archived'), 'Required key "Menu[archived]" is missing from JSON.');
        assert(json[r'archived'] != null, 'Required key "Menu[archived]" has a null value in JSON.');
        assert(json.containsKey(r'variants'), 'Required key "Menu[variants]" is missing from JSON.');
        assert(json[r'variants'] != null, 'Required key "Menu[variants]" has a null value in JSON.');
        return true;
      }());

      return Menu(
        id: mapValueOfType<String>(json, r'id')!,
        name: mapValueOfType<String>(json, r'name')!,
        description: mapValueOfType<String>(json, r'description')!,
        categoryId: mapValueOfType<String>(json, r'categoryId')!,
        revision: mapValueOfType<int>(json, r'revision')!,
        archived: mapValueOfType<bool>(json, r'archived')!,
        variants: Variant.listFromJson(json[r'variants']),
      );
    }
    return null;
  }

  static List<Menu> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Menu>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Menu.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Menu> mapFromJson(dynamic json) {
    final map = <String, Menu>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Menu.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Menu-objects as value to a dart map
  static Map<String, List<Menu>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Menu>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Menu.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'name',
    'description',
    'categoryId',
    'revision',
    'archived',
    'variants',
  };
}

