//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class StationJobLine {
  /// Returns a new [StationJobLine] instance.
  StationJobLine({
    required this.variantId,
    required this.quantity,
    this.saleLineId,
    this.modifiers = const [],
  });

  String variantId;

  /// Minimum value: 1
  /// Maximum value: 100000
  int quantity;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? saleLineId;

  List<StationJobModifier> modifiers;

  @override
  bool operator ==(Object other) => identical(this, other) || other is StationJobLine &&
    other.variantId == variantId &&
    other.quantity == quantity &&
    other.saleLineId == saleLineId &&
    _deepEquality.equals(other.modifiers, modifiers);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (variantId.hashCode) +
    (quantity.hashCode) +
    (saleLineId == null ? 0 : saleLineId!.hashCode) +
    (modifiers.hashCode);

  @override
  String toString() => 'StationJobLine[variantId=$variantId, quantity=$quantity, saleLineId=$saleLineId, modifiers=$modifiers]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'variantId'] = this.variantId;
      json[r'quantity'] = this.quantity;
    if (this.saleLineId != null) {
      json[r'saleLineId'] = this.saleLineId;
    } else {
      json[r'saleLineId'] = null;
    }
      json[r'modifiers'] = this.modifiers;
    return json;
  }

  /// Returns a new [StationJobLine] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static StationJobLine? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'variantId'), 'Required key "StationJobLine[variantId]" is missing from JSON.');
        assert(json[r'variantId'] != null, 'Required key "StationJobLine[variantId]" has a null value in JSON.');
        assert(json.containsKey(r'quantity'), 'Required key "StationJobLine[quantity]" is missing from JSON.');
        assert(json[r'quantity'] != null, 'Required key "StationJobLine[quantity]" has a null value in JSON.');
        return true;
      }());

      return StationJobLine(
        variantId: mapValueOfType<String>(json, r'variantId')!,
        quantity: mapValueOfType<int>(json, r'quantity')!,
        saleLineId: mapValueOfType<String>(json, r'saleLineId'),
        modifiers: StationJobModifier.listFromJson(json[r'modifiers']),
      );
    }
    return null;
  }

  static List<StationJobLine> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <StationJobLine>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = StationJobLine.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, StationJobLine> mapFromJson(dynamic json) {
    final map = <String, StationJobLine>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = StationJobLine.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of StationJobLine-objects as value to a dart map
  static Map<String, List<StationJobLine>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<StationJobLine>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = StationJobLine.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'variantId',
    'quantity',
  };
}

