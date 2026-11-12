//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ModifierWrite {
  /// Returns a new [ModifierWrite] instance.
  ModifierWrite({
    required this.menuItemId,
    required this.name,
    required this.priceDeltaMinor,
    this.stockItemId,
    this.quantityPerSaleUnit,
    this.active,
  });

  String menuItemId;

  String name;

  /// Minimum value: -9007199254740991
  /// Maximum value: 9007199254740991
  int priceDeltaMinor;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? stockItemId;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? quantityPerSaleUnit;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? active;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ModifierWrite &&
    other.menuItemId == menuItemId &&
    other.name == name &&
    other.priceDeltaMinor == priceDeltaMinor &&
    other.stockItemId == stockItemId &&
    other.quantityPerSaleUnit == quantityPerSaleUnit &&
    other.active == active;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (menuItemId.hashCode) +
    (name.hashCode) +
    (priceDeltaMinor.hashCode) +
    (stockItemId == null ? 0 : stockItemId!.hashCode) +
    (quantityPerSaleUnit == null ? 0 : quantityPerSaleUnit!.hashCode) +
    (active == null ? 0 : active!.hashCode);

  @override
  String toString() => 'ModifierWrite[menuItemId=$menuItemId, name=$name, priceDeltaMinor=$priceDeltaMinor, stockItemId=$stockItemId, quantityPerSaleUnit=$quantityPerSaleUnit, active=$active]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'menuItemId'] = this.menuItemId;
      json[r'name'] = this.name;
      json[r'priceDeltaMinor'] = this.priceDeltaMinor;
    if (this.stockItemId != null) {
      json[r'stockItemId'] = this.stockItemId;
    } else {
      json[r'stockItemId'] = null;
    }
    if (this.quantityPerSaleUnit != null) {
      json[r'quantityPerSaleUnit'] = this.quantityPerSaleUnit;
    } else {
      json[r'quantityPerSaleUnit'] = null;
    }
    if (this.active != null) {
      json[r'active'] = this.active;
    } else {
      json[r'active'] = null;
    }
    return json;
  }

  /// Returns a new [ModifierWrite] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ModifierWrite? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'menuItemId'), 'Required key "ModifierWrite[menuItemId]" is missing from JSON.');
        assert(json[r'menuItemId'] != null, 'Required key "ModifierWrite[menuItemId]" has a null value in JSON.');
        assert(json.containsKey(r'name'), 'Required key "ModifierWrite[name]" is missing from JSON.');
        assert(json[r'name'] != null, 'Required key "ModifierWrite[name]" has a null value in JSON.');
        assert(json.containsKey(r'priceDeltaMinor'), 'Required key "ModifierWrite[priceDeltaMinor]" is missing from JSON.');
        assert(json[r'priceDeltaMinor'] != null, 'Required key "ModifierWrite[priceDeltaMinor]" has a null value in JSON.');
        return true;
      }());

      return ModifierWrite(
        menuItemId: mapValueOfType<String>(json, r'menuItemId')!,
        name: mapValueOfType<String>(json, r'name')!,
        priceDeltaMinor: mapValueOfType<int>(json, r'priceDeltaMinor')!,
        stockItemId: mapValueOfType<String>(json, r'stockItemId'),
        quantityPerSaleUnit: mapValueOfType<String>(json, r'quantityPerSaleUnit'),
        active: mapValueOfType<bool>(json, r'active'),
      );
    }
    return null;
  }

  static List<ModifierWrite> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ModifierWrite>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ModifierWrite.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ModifierWrite> mapFromJson(dynamic json) {
    final map = <String, ModifierWrite>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ModifierWrite.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ModifierWrite-objects as value to a dart map
  static Map<String, List<ModifierWrite>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ModifierWrite>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ModifierWrite.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'menuItemId',
    'name',
    'priceDeltaMinor',
  };
}

