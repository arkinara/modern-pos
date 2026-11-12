//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Totals {
  /// Returns a new [Totals] instance.
  Totals({
    required this.subtotalMinor,
    required this.serviceMinor,
    required this.taxMinor,
    required this.totalMinor,
    this.discountMinor,
  });

  /// Currency minor units; IDR exponent 0 in demo.
  ///
  /// Minimum value: 0
  /// Maximum value: 9007199254740991
  int subtotalMinor;

  /// Currency minor units; IDR exponent 0 in demo.
  ///
  /// Minimum value: 0
  /// Maximum value: 9007199254740991
  int serviceMinor;

  /// Currency minor units; IDR exponent 0 in demo.
  ///
  /// Minimum value: 0
  /// Maximum value: 9007199254740991
  int taxMinor;

  /// Currency minor units; IDR exponent 0 in demo.
  ///
  /// Minimum value: 0
  /// Maximum value: 9007199254740991
  int totalMinor;

  /// Currency minor units; IDR exponent 0 in demo.
  ///
  /// Minimum value: 0
  /// Maximum value: 9007199254740991
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? discountMinor;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Totals &&
    other.subtotalMinor == subtotalMinor &&
    other.serviceMinor == serviceMinor &&
    other.taxMinor == taxMinor &&
    other.totalMinor == totalMinor &&
    other.discountMinor == discountMinor;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (subtotalMinor.hashCode) +
    (serviceMinor.hashCode) +
    (taxMinor.hashCode) +
    (totalMinor.hashCode) +
    (discountMinor == null ? 0 : discountMinor!.hashCode);

  @override
  String toString() => 'Totals[subtotalMinor=$subtotalMinor, serviceMinor=$serviceMinor, taxMinor=$taxMinor, totalMinor=$totalMinor, discountMinor=$discountMinor]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'subtotalMinor'] = this.subtotalMinor;
      json[r'serviceMinor'] = this.serviceMinor;
      json[r'taxMinor'] = this.taxMinor;
      json[r'totalMinor'] = this.totalMinor;
    if (this.discountMinor != null) {
      json[r'discountMinor'] = this.discountMinor;
    } else {
      json[r'discountMinor'] = null;
    }
    return json;
  }

  /// Returns a new [Totals] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Totals? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'subtotalMinor'), 'Required key "Totals[subtotalMinor]" is missing from JSON.');
        assert(json[r'subtotalMinor'] != null, 'Required key "Totals[subtotalMinor]" has a null value in JSON.');
        assert(json.containsKey(r'serviceMinor'), 'Required key "Totals[serviceMinor]" is missing from JSON.');
        assert(json[r'serviceMinor'] != null, 'Required key "Totals[serviceMinor]" has a null value in JSON.');
        assert(json.containsKey(r'taxMinor'), 'Required key "Totals[taxMinor]" is missing from JSON.');
        assert(json[r'taxMinor'] != null, 'Required key "Totals[taxMinor]" has a null value in JSON.');
        assert(json.containsKey(r'totalMinor'), 'Required key "Totals[totalMinor]" is missing from JSON.');
        assert(json[r'totalMinor'] != null, 'Required key "Totals[totalMinor]" has a null value in JSON.');
        return true;
      }());

      return Totals(
        subtotalMinor: mapValueOfType<int>(json, r'subtotalMinor')!,
        serviceMinor: mapValueOfType<int>(json, r'serviceMinor')!,
        taxMinor: mapValueOfType<int>(json, r'taxMinor')!,
        totalMinor: mapValueOfType<int>(json, r'totalMinor')!,
        discountMinor: mapValueOfType<int>(json, r'discountMinor'),
      );
    }
    return null;
  }

  static List<Totals> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Totals>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Totals.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Totals> mapFromJson(dynamic json) {
    final map = <String, Totals>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Totals.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Totals-objects as value to a dart map
  static Map<String, List<Totals>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Totals>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Totals.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'subtotalMinor',
    'serviceMinor',
    'taxMinor',
    'totalMinor',
  };
}

