//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Modifier {
  /// Returns a new [Modifier] instance.
  Modifier({
    required this.id,
    required this.menuItemId,
    required this.name,
    required this.priceDeltaMinor,
    required this.stockItemId,
    required this.quantityPerSaleUnit,
    required this.active,
  });

  String id;

  String menuItemId;

  String name;

  /// Minimum value: -9007199254740991
  /// Maximum value: 9007199254740991
  int priceDeltaMinor;

  String? stockItemId;

  String? quantityPerSaleUnit;

  bool active;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Modifier &&
    other.id == id &&
    other.menuItemId == menuItemId &&
    other.name == name &&
    other.priceDeltaMinor == priceDeltaMinor &&
    other.stockItemId == stockItemId &&
    other.quantityPerSaleUnit == quantityPerSaleUnit &&
    other.active == active;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (menuItemId.hashCode) +
    (name.hashCode) +
    (priceDeltaMinor.hashCode) +
    (stockItemId == null ? 0 : stockItemId!.hashCode) +
    (quantityPerSaleUnit == null ? 0 : quantityPerSaleUnit!.hashCode) +
    (active.hashCode);

  @override
  String toString() => 'Modifier[id=$id, menuItemId=$menuItemId, name=$name, priceDeltaMinor=$priceDeltaMinor, stockItemId=$stockItemId, quantityPerSaleUnit=$quantityPerSaleUnit, active=$active]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
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
      json[r'active'] = this.active;
    return json;
  }

  /// Returns a new [Modifier] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Modifier? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "Modifier[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "Modifier[id]" has a null value in JSON.');
        assert(json.containsKey(r'menuItemId'), 'Required key "Modifier[menuItemId]" is missing from JSON.');
        assert(json[r'menuItemId'] != null, 'Required key "Modifier[menuItemId]" has a null value in JSON.');
        assert(json.containsKey(r'name'), 'Required key "Modifier[name]" is missing from JSON.');
        assert(json[r'name'] != null, 'Required key "Modifier[name]" has a null value in JSON.');
        assert(json.containsKey(r'priceDeltaMinor'), 'Required key "Modifier[priceDeltaMinor]" is missing from JSON.');
        assert(json[r'priceDeltaMinor'] != null, 'Required key "Modifier[priceDeltaMinor]" has a null value in JSON.');
        assert(json.containsKey(r'stockItemId'), 'Required key "Modifier[stockItemId]" is missing from JSON.');
        assert(json.containsKey(r'quantityPerSaleUnit'), 'Required key "Modifier[quantityPerSaleUnit]" is missing from JSON.');
        assert(json.containsKey(r'active'), 'Required key "Modifier[active]" is missing from JSON.');
        assert(json[r'active'] != null, 'Required key "Modifier[active]" has a null value in JSON.');
        return true;
      }());

      return Modifier(
        id: mapValueOfType<String>(json, r'id')!,
        menuItemId: mapValueOfType<String>(json, r'menuItemId')!,
        name: mapValueOfType<String>(json, r'name')!,
        priceDeltaMinor: mapValueOfType<int>(json, r'priceDeltaMinor')!,
        stockItemId: mapValueOfType<String>(json, r'stockItemId'),
        quantityPerSaleUnit: mapValueOfType<String>(json, r'quantityPerSaleUnit'),
        active: mapValueOfType<bool>(json, r'active')!,
      );
    }
    return null;
  }

  static List<Modifier> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Modifier>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Modifier.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Modifier> mapFromJson(dynamic json) {
    final map = <String, Modifier>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Modifier.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Modifier-objects as value to a dart map
  static Map<String, List<Modifier>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Modifier>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Modifier.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'menuItemId',
    'name',
    'priceDeltaMinor',
    'stockItemId',
    'quantityPerSaleUnit',
    'active',
  };
}

