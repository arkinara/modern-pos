//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ChannelOrderLine {
  /// Returns a new [ChannelOrderLine] instance.
  ChannelOrderLine({
    required this.id,
    required this.variantId,
    required this.name,
    required this.variantName,
    required this.quantity,
    required this.unitPriceMinor,
    required this.lineSubtotalMinor,
    required this.recipeVersion,
  });

  String id;

  String variantId;

  String name;

  String variantName;

  int quantity;

  int unitPriceMinor;

  int lineSubtotalMinor;

  int? recipeVersion;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ChannelOrderLine &&
    other.id == id &&
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
    (id.hashCode) +
    (variantId.hashCode) +
    (name.hashCode) +
    (variantName.hashCode) +
    (quantity.hashCode) +
    (unitPriceMinor.hashCode) +
    (lineSubtotalMinor.hashCode) +
    (recipeVersion == null ? 0 : recipeVersion!.hashCode);

  @override
  String toString() => 'ChannelOrderLine[id=$id, variantId=$variantId, name=$name, variantName=$variantName, quantity=$quantity, unitPriceMinor=$unitPriceMinor, lineSubtotalMinor=$lineSubtotalMinor, recipeVersion=$recipeVersion]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
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

  /// Returns a new [ChannelOrderLine] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ChannelOrderLine? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "ChannelOrderLine[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "ChannelOrderLine[id]" has a null value in JSON.');
        assert(json.containsKey(r'variantId'), 'Required key "ChannelOrderLine[variantId]" is missing from JSON.');
        assert(json[r'variantId'] != null, 'Required key "ChannelOrderLine[variantId]" has a null value in JSON.');
        assert(json.containsKey(r'name'), 'Required key "ChannelOrderLine[name]" is missing from JSON.');
        assert(json[r'name'] != null, 'Required key "ChannelOrderLine[name]" has a null value in JSON.');
        assert(json.containsKey(r'variantName'), 'Required key "ChannelOrderLine[variantName]" is missing from JSON.');
        assert(json[r'variantName'] != null, 'Required key "ChannelOrderLine[variantName]" has a null value in JSON.');
        assert(json.containsKey(r'quantity'), 'Required key "ChannelOrderLine[quantity]" is missing from JSON.');
        assert(json[r'quantity'] != null, 'Required key "ChannelOrderLine[quantity]" has a null value in JSON.');
        assert(json.containsKey(r'unitPriceMinor'), 'Required key "ChannelOrderLine[unitPriceMinor]" is missing from JSON.');
        assert(json[r'unitPriceMinor'] != null, 'Required key "ChannelOrderLine[unitPriceMinor]" has a null value in JSON.');
        assert(json.containsKey(r'lineSubtotalMinor'), 'Required key "ChannelOrderLine[lineSubtotalMinor]" is missing from JSON.');
        assert(json[r'lineSubtotalMinor'] != null, 'Required key "ChannelOrderLine[lineSubtotalMinor]" has a null value in JSON.');
        assert(json.containsKey(r'recipeVersion'), 'Required key "ChannelOrderLine[recipeVersion]" is missing from JSON.');
        return true;
      }());

      return ChannelOrderLine(
        id: mapValueOfType<String>(json, r'id')!,
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

  static List<ChannelOrderLine> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ChannelOrderLine>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ChannelOrderLine.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ChannelOrderLine> mapFromJson(dynamic json) {
    final map = <String, ChannelOrderLine>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ChannelOrderLine.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ChannelOrderLine-objects as value to a dart map
  static Map<String, List<ChannelOrderLine>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ChannelOrderLine>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ChannelOrderLine.listFromJson(entry.value, growable: growable,);
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
    'recipeVersion',
  };
}

