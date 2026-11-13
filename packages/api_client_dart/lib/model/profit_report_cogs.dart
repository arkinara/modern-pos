//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ProfitReportCogs {
  /// Returns a new [ProfitReportCogs] instance.
  ProfitReportCogs({
    required this.saleCostMinor,
    required this.reversalRestockCreditMinor,
    required this.netCogsMinor,
  });

  /// Minimum value: 0
  /// Maximum value: 9007199254740991
  int saleCostMinor;

  /// Minimum value: 0
  /// Maximum value: 9007199254740991
  int reversalRestockCreditMinor;

  /// Minimum value: -9007199254740991
  /// Maximum value: 9007199254740991
  int netCogsMinor;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ProfitReportCogs &&
    other.saleCostMinor == saleCostMinor &&
    other.reversalRestockCreditMinor == reversalRestockCreditMinor &&
    other.netCogsMinor == netCogsMinor;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (saleCostMinor.hashCode) +
    (reversalRestockCreditMinor.hashCode) +
    (netCogsMinor.hashCode);

  @override
  String toString() => 'ProfitReportCogs[saleCostMinor=$saleCostMinor, reversalRestockCreditMinor=$reversalRestockCreditMinor, netCogsMinor=$netCogsMinor]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'saleCostMinor'] = this.saleCostMinor;
      json[r'reversalRestockCreditMinor'] = this.reversalRestockCreditMinor;
      json[r'netCogsMinor'] = this.netCogsMinor;
    return json;
  }

  /// Returns a new [ProfitReportCogs] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ProfitReportCogs? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'saleCostMinor'), 'Required key "ProfitReportCogs[saleCostMinor]" is missing from JSON.');
        assert(json[r'saleCostMinor'] != null, 'Required key "ProfitReportCogs[saleCostMinor]" has a null value in JSON.');
        assert(json.containsKey(r'reversalRestockCreditMinor'), 'Required key "ProfitReportCogs[reversalRestockCreditMinor]" is missing from JSON.');
        assert(json[r'reversalRestockCreditMinor'] != null, 'Required key "ProfitReportCogs[reversalRestockCreditMinor]" has a null value in JSON.');
        assert(json.containsKey(r'netCogsMinor'), 'Required key "ProfitReportCogs[netCogsMinor]" is missing from JSON.');
        assert(json[r'netCogsMinor'] != null, 'Required key "ProfitReportCogs[netCogsMinor]" has a null value in JSON.');
        return true;
      }());

      return ProfitReportCogs(
        saleCostMinor: mapValueOfType<int>(json, r'saleCostMinor')!,
        reversalRestockCreditMinor: mapValueOfType<int>(json, r'reversalRestockCreditMinor')!,
        netCogsMinor: mapValueOfType<int>(json, r'netCogsMinor')!,
      );
    }
    return null;
  }

  static List<ProfitReportCogs> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ProfitReportCogs>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ProfitReportCogs.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ProfitReportCogs> mapFromJson(dynamic json) {
    final map = <String, ProfitReportCogs>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ProfitReportCogs.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ProfitReportCogs-objects as value to a dart map
  static Map<String, List<ProfitReportCogs>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ProfitReportCogs>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ProfitReportCogs.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'saleCostMinor',
    'reversalRestockCreditMinor',
    'netCogsMinor',
  };
}

