//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class SaleLine {
  /// Returns a new [SaleLine] instance.
  SaleLine({
    required this.id,
    required this.variantId,
    required this.name,
    required this.variantName,
    required this.quantity,
    required this.unitPriceMinor,
    required this.lineSubtotalMinor,
    this.modifiers = const [],
  });

  String id;

  String variantId;

  String name;

  String variantName;

  /// Minimum value: 1
  /// Maximum value: 100000
  int quantity;

  /// Currency minor units; IDR exponent 0 in demo.
  ///
  /// Minimum value: 0
  /// Maximum value: 9007199254740991
  int unitPriceMinor;

  /// Currency minor units; IDR exponent 0 in demo.
  ///
  /// Minimum value: 0
  /// Maximum value: 9007199254740991
  int lineSubtotalMinor;

  List<LineModifier> modifiers;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SaleLine &&
    other.id == id &&
    other.variantId == variantId &&
    other.name == name &&
    other.variantName == variantName &&
    other.quantity == quantity &&
    other.unitPriceMinor == unitPriceMinor &&
    other.lineSubtotalMinor == lineSubtotalMinor &&
    _deepEquality.equals(other.modifiers, modifiers);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (variantId.hashCode) +
    (name.hashCode) +
    (variantName.hashCode) +
    (quantity.hashCode) +
    (unitPriceMinor.hashCode) +
    (lineSubtotalMinor.hashCode) +
    (modifiers.hashCode);

  @override
  String toString() => 'SaleLine[id=$id, variantId=$variantId, name=$name, variantName=$variantName, quantity=$quantity, unitPriceMinor=$unitPriceMinor, lineSubtotalMinor=$lineSubtotalMinor, modifiers=$modifiers]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'variantId'] = this.variantId;
      json[r'name'] = this.name;
      json[r'variantName'] = this.variantName;
      json[r'quantity'] = this.quantity;
      json[r'unitPriceMinor'] = this.unitPriceMinor;
      json[r'lineSubtotalMinor'] = this.lineSubtotalMinor;
      json[r'modifiers'] = this.modifiers;
    return json;
  }

  /// Returns a new [SaleLine] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SaleLine? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "SaleLine[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "SaleLine[id]" has a null value in JSON.');
        assert(json.containsKey(r'variantId'), 'Required key "SaleLine[variantId]" is missing from JSON.');
        assert(json[r'variantId'] != null, 'Required key "SaleLine[variantId]" has a null value in JSON.');
        assert(json.containsKey(r'name'), 'Required key "SaleLine[name]" is missing from JSON.');
        assert(json[r'name'] != null, 'Required key "SaleLine[name]" has a null value in JSON.');
        assert(json.containsKey(r'variantName'), 'Required key "SaleLine[variantName]" is missing from JSON.');
        assert(json[r'variantName'] != null, 'Required key "SaleLine[variantName]" has a null value in JSON.');
        assert(json.containsKey(r'quantity'), 'Required key "SaleLine[quantity]" is missing from JSON.');
        assert(json[r'quantity'] != null, 'Required key "SaleLine[quantity]" has a null value in JSON.');
        assert(json.containsKey(r'unitPriceMinor'), 'Required key "SaleLine[unitPriceMinor]" is missing from JSON.');
        assert(json[r'unitPriceMinor'] != null, 'Required key "SaleLine[unitPriceMinor]" has a null value in JSON.');
        assert(json.containsKey(r'lineSubtotalMinor'), 'Required key "SaleLine[lineSubtotalMinor]" is missing from JSON.');
        assert(json[r'lineSubtotalMinor'] != null, 'Required key "SaleLine[lineSubtotalMinor]" has a null value in JSON.');
        return true;
      }());

      return SaleLine(
        id: mapValueOfType<String>(json, r'id')!,
        variantId: mapValueOfType<String>(json, r'variantId')!,
        name: mapValueOfType<String>(json, r'name')!,
        variantName: mapValueOfType<String>(json, r'variantName')!,
        quantity: mapValueOfType<int>(json, r'quantity')!,
        unitPriceMinor: mapValueOfType<int>(json, r'unitPriceMinor')!,
        lineSubtotalMinor: mapValueOfType<int>(json, r'lineSubtotalMinor')!,
        modifiers: LineModifier.listFromJson(json[r'modifiers']),
      );
    }
    return null;
  }

  static List<SaleLine> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SaleLine>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SaleLine.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SaleLine> mapFromJson(dynamic json) {
    final map = <String, SaleLine>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SaleLine.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SaleLine-objects as value to a dart map
  static Map<String, List<SaleLine>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SaleLine>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SaleLine.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'variantId',
    'name',
    'variantName',
    'quantity',
    'unitPriceMinor',
    'lineSubtotalMinor',
  };
}

