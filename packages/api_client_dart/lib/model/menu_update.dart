//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class MenuUpdate {
  /// Returns a new [MenuUpdate] instance.
  MenuUpdate({
    required this.name,
    required this.description,
    required this.categoryId,
    required this.revision,
  });

  String name;

  String description;

  String categoryId;

  /// Minimum value: 1
  int revision;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MenuUpdate &&
    other.name == name &&
    other.description == description &&
    other.categoryId == categoryId &&
    other.revision == revision;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (name.hashCode) +
    (description.hashCode) +
    (categoryId.hashCode) +
    (revision.hashCode);

  @override
  String toString() => 'MenuUpdate[name=$name, description=$description, categoryId=$categoryId, revision=$revision]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'name'] = this.name;
      json[r'description'] = this.description;
      json[r'categoryId'] = this.categoryId;
      json[r'revision'] = this.revision;
    return json;
  }

  /// Returns a new [MenuUpdate] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static MenuUpdate? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'name'), 'Required key "MenuUpdate[name]" is missing from JSON.');
        assert(json[r'name'] != null, 'Required key "MenuUpdate[name]" has a null value in JSON.');
        assert(json.containsKey(r'description'), 'Required key "MenuUpdate[description]" is missing from JSON.');
        assert(json[r'description'] != null, 'Required key "MenuUpdate[description]" has a null value in JSON.');
        assert(json.containsKey(r'categoryId'), 'Required key "MenuUpdate[categoryId]" is missing from JSON.');
        assert(json[r'categoryId'] != null, 'Required key "MenuUpdate[categoryId]" has a null value in JSON.');
        assert(json.containsKey(r'revision'), 'Required key "MenuUpdate[revision]" is missing from JSON.');
        assert(json[r'revision'] != null, 'Required key "MenuUpdate[revision]" has a null value in JSON.');
        return true;
      }());

      return MenuUpdate(
        name: mapValueOfType<String>(json, r'name')!,
        description: mapValueOfType<String>(json, r'description')!,
        categoryId: mapValueOfType<String>(json, r'categoryId')!,
        revision: mapValueOfType<int>(json, r'revision')!,
      );
    }
    return null;
  }

  static List<MenuUpdate> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MenuUpdate>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MenuUpdate.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, MenuUpdate> mapFromJson(dynamic json) {
    final map = <String, MenuUpdate>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = MenuUpdate.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of MenuUpdate-objects as value to a dart map
  static Map<String, List<MenuUpdate>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<MenuUpdate>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = MenuUpdate.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'name',
    'description',
    'categoryId',
    'revision',
  };
}

