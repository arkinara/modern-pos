//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class QuoteLinesInner {
  /// Returns a new [QuoteLinesInner] instance.
  QuoteLinesInner({
    required this.variantId,
    required this.name,
    required this.variantName,
    required this.quantity,
    required this.unitPriceMinor,
    required this.lineSubtotalMinor,
    required this.recipeVersion,
  });

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

  /// Minimum value: 1
  int? recipeVersion;

  @override
  bool operator ==(Object other) => identical(this, other) || other is QuoteLinesInner &&
    other.variantId == variantId &&
    other.name == name &&
    other.variantName == variantName &&
    other.quantity == quantity &&
    other.unitPriceMinor == unitPriceMinor &&
    other.lineSubtotalMinor == lineSubtotalMinor &&
    other.recipeVersion == recipeVersion;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (variantId.hashCode) +
    (name.hashCode) +
    (variantName.hashCode) +
    (quantity.hashCode) +
    (unitPriceMinor.hashCode) +
    (lineSubtotalMinor.hashCode) +
    (recipeVersion == null ? 0 : recipeVersion!.hashCode);

  @override
  String toString() => 'QuoteLinesInner[variantId=$variantId, name=$name, variantName=$variantName, quantity=$quantity, unitPriceMinor=$unitPriceMinor, lineSubtotalMinor=$lineSubtotalMinor, recipeVersion=$recipeVersion]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'variantId'] = this.variantId;
      json[r'name'] = this.name;
      json[r'variantName'] = this.variantName;
      json[r'quantity'] = this.quantity;
      json[r'unitPriceMinor'] = this.unitPriceMinor;
      json[r'lineSubtotalMinor'] = this.lineSubtotalMinor;
    if (this.recipeVersion != null) {
      json[r'recipeVersion'] = this.recipeVersion;
    } else {
      json[r'recipeVersion'] = null;
    }
    return json;
  }

  /// Returns a new [QuoteLinesInner] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static QuoteLinesInner? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'variantId'), 'Required key "QuoteLinesInner[variantId]" is missing from JSON.');
        assert(json[r'variantId'] != null, 'Required key "QuoteLinesInner[variantId]" has a null value in JSON.');
        assert(json.containsKey(r'name'), 'Required key "QuoteLinesInner[name]" is missing from JSON.');
        assert(json[r'name'] != null, 'Required key "QuoteLinesInner[name]" has a null value in JSON.');
        assert(json.containsKey(r'variantName'), 'Required key "QuoteLinesInner[variantName]" is missing from JSON.');
        assert(json[r'variantName'] != null, 'Required key "QuoteLinesInner[variantName]" has a null value in JSON.');
        assert(json.containsKey(r'quantity'), 'Required key "QuoteLinesInner[quantity]" is missing from JSON.');
        assert(json[r'quantity'] != null, 'Required key "QuoteLinesInner[quantity]" has a null value in JSON.');
        assert(json.containsKey(r'unitPriceMinor'), 'Required key "QuoteLinesInner[unitPriceMinor]" is missing from JSON.');
        assert(json[r'unitPriceMinor'] != null, 'Required key "QuoteLinesInner[unitPriceMinor]" has a null value in JSON.');
        assert(json.containsKey(r'lineSubtotalMinor'), 'Required key "QuoteLinesInner[lineSubtotalMinor]" is missing from JSON.');
        assert(json[r'lineSubtotalMinor'] != null, 'Required key "QuoteLinesInner[lineSubtotalMinor]" has a null value in JSON.');
        assert(json.containsKey(r'recipeVersion'), 'Required key "QuoteLinesInner[recipeVersion]" is missing from JSON.');
        return true;
      }());

      return QuoteLinesInner(
        variantId: mapValueOfType<String>(json, r'variantId')!,
        name: mapValueOfType<String>(json, r'name')!,
        variantName: mapValueOfType<String>(json, r'variantName')!,
        quantity: mapValueOfType<int>(json, r'quantity')!,
        unitPriceMinor: mapValueOfType<int>(json, r'unitPriceMinor')!,
        lineSubtotalMinor: mapValueOfType<int>(json, r'lineSubtotalMinor')!,
        recipeVersion: mapValueOfType<int>(json, r'recipeVersion'),
      );
    }
    return null;
  }

  static List<QuoteLinesInner> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <QuoteLinesInner>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = QuoteLinesInner.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, QuoteLinesInner> mapFromJson(dynamic json) {
    final map = <String, QuoteLinesInner>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = QuoteLinesInner.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of QuoteLinesInner-objects as value to a dart map
  static Map<String, List<QuoteLinesInner>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<QuoteLinesInner>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = QuoteLinesInner.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'variantId',
    'name',
    'variantName',
    'quantity',
    'unitPriceMinor',
    'lineSubtotalMinor',
    'recipeVersion',
  };
}

