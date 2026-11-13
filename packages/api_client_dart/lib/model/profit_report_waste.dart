//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ProfitReportWaste {
  /// Returns a new [ProfitReportWaste] instance.
  ProfitReportWaste({
    required this.costMinor,
  });

  /// Minimum value: 0
  /// Maximum value: 9007199254740991
  int costMinor;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ProfitReportWaste &&
    other.costMinor == costMinor;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (costMinor.hashCode);

  @override
  String toString() => 'ProfitReportWaste[costMinor=$costMinor]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'costMinor'] = this.costMinor;
    return json;
  }

  /// Returns a new [ProfitReportWaste] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ProfitReportWaste? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'costMinor'), 'Required key "ProfitReportWaste[costMinor]" is missing from JSON.');
        assert(json[r'costMinor'] != null, 'Required key "ProfitReportWaste[costMinor]" has a null value in JSON.');
        return true;
      }());

      return ProfitReportWaste(
        costMinor: mapValueOfType<int>(json, r'costMinor')!,
      );
    }
    return null;
  }

  static List<ProfitReportWaste> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ProfitReportWaste>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ProfitReportWaste.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ProfitReportWaste> mapFromJson(dynamic json) {
    final map = <String, ProfitReportWaste>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ProfitReportWaste.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ProfitReportWaste-objects as value to a dart map
  static Map<String, List<ProfitReportWaste>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ProfitReportWaste>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ProfitReportWaste.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'costMinor',
  };
}

