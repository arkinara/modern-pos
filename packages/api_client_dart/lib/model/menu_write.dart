//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class MenuWrite {
  /// Returns a new [MenuWrite] instance.
  MenuWrite({
    required this.name,
    required this.description,
    required this.categoryId,
    this.variants = const [],
  });

  String name;

  String description;

  String categoryId;

  List<VariantWrite> variants;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MenuWrite &&
    other.name == name &&
    other.description == description &&
    other.categoryId == categoryId &&
    _deepEquality.equals(other.variants, variants);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (name.hashCode) +
    (description.hashCode) +
    (categoryId.hashCode) +
    (variants.hashCode);

  @override
  String toString() => 'MenuWrite[name=$name, description=$description, categoryId=$categoryId, variants=$variants]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'name'] = this.name;
      json[r'description'] = this.description;
      json[r'categoryId'] = this.categoryId;
      json[r'variants'] = this.variants;
    return json;
  }

  /// Returns a new [MenuWrite] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static MenuWrite? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'name'), 'Required key "MenuWrite[name]" is missing from JSON.');
        assert(json[r'name'] != null, 'Required key "MenuWrite[name]" has a null value in JSON.');
        assert(json.containsKey(r'description'), 'Required key "MenuWrite[description]" is missing from JSON.');
        assert(json[r'description'] != null, 'Required key "MenuWrite[description]" has a null value in JSON.');
        assert(json.containsKey(r'categoryId'), 'Required key "MenuWrite[categoryId]" is missing from JSON.');
        assert(json[r'categoryId'] != null, 'Required key "MenuWrite[categoryId]" has a null value in JSON.');
        assert(json.containsKey(r'variants'), 'Required key "MenuWrite[variants]" is missing from JSON.');
        assert(json[r'variants'] != null, 'Required key "MenuWrite[variants]" has a null value in JSON.');
        return true;
      }());

      return MenuWrite(
        name: mapValueOfType<String>(json, r'name')!,
        description: mapValueOfType<String>(json, r'description')!,
        categoryId: mapValueOfType<String>(json, r'categoryId')!,
        variants: VariantWrite.listFromJson(json[r'variants']),
      );
    }
    return null;
  }

  static List<MenuWrite> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MenuWrite>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MenuWrite.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, MenuWrite> mapFromJson(dynamic json) {
    final map = <String, MenuWrite>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = MenuWrite.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of MenuWrite-objects as value to a dart map
  static Map<String, List<MenuWrite>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<MenuWrite>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = MenuWrite.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'name',
    'description',
    'categoryId',
    'variants',
  };
}

