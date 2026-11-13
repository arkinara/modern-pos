//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ProfitReportRevenue {
  /// Returns a new [ProfitReportRevenue] instance.
  ProfitReportRevenue({
    required this.grossItemSalesMinor,
    required this.reversalItemValueMinor,
    required this.netItemSalesMinor,
    required this.saleCount,
    required this.reversalCount,
  });

  /// Minimum value: 0
  /// Maximum value: 9007199254740991
  int grossItemSalesMinor;

  /// Minimum value: 0
  /// Maximum value: 9007199254740991
  int reversalItemValueMinor;

  /// Minimum value: -9007199254740991
  /// Maximum value: 9007199254740991
  int netItemSalesMinor;

  /// Minimum value: 0
  int saleCount;

  /// Minimum value: 0
  int reversalCount;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ProfitReportRevenue &&
    other.grossItemSalesMinor == grossItemSalesMinor &&
    other.reversalItemValueMinor == reversalItemValueMinor &&
    other.netItemSalesMinor == netItemSalesMinor &&
    other.saleCount == saleCount &&
    other.reversalCount == reversalCount;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (grossItemSalesMinor.hashCode) +
    (reversalItemValueMinor.hashCode) +
    (netItemSalesMinor.hashCode) +
    (saleCount.hashCode) +
    (reversalCount.hashCode);

  @override
  String toString() => 'ProfitReportRevenue[grossItemSalesMinor=$grossItemSalesMinor, reversalItemValueMinor=$reversalItemValueMinor, netItemSalesMinor=$netItemSalesMinor, saleCount=$saleCount, reversalCount=$reversalCount]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'grossItemSalesMinor'] = this.grossItemSalesMinor;
      json[r'reversalItemValueMinor'] = this.reversalItemValueMinor;
      json[r'netItemSalesMinor'] = this.netItemSalesMinor;
      json[r'saleCount'] = this.saleCount;
      json[r'reversalCount'] = this.reversalCount;
    return json;
  }

  /// Returns a new [ProfitReportRevenue] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ProfitReportRevenue? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'grossItemSalesMinor'), 'Required key "ProfitReportRevenue[grossItemSalesMinor]" is missing from JSON.');
        assert(json[r'grossItemSalesMinor'] != null, 'Required key "ProfitReportRevenue[grossItemSalesMinor]" has a null value in JSON.');
        assert(json.containsKey(r'reversalItemValueMinor'), 'Required key "ProfitReportRevenue[reversalItemValueMinor]" is missing from JSON.');
        assert(json[r'reversalItemValueMinor'] != null, 'Required key "ProfitReportRevenue[reversalItemValueMinor]" has a null value in JSON.');
        assert(json.containsKey(r'netItemSalesMinor'), 'Required key "ProfitReportRevenue[netItemSalesMinor]" is missing from JSON.');
        assert(json[r'netItemSalesMinor'] != null, 'Required key "ProfitReportRevenue[netItemSalesMinor]" has a null value in JSON.');
        assert(json.containsKey(r'saleCount'), 'Required key "ProfitReportRevenue[saleCount]" is missing from JSON.');
        assert(json[r'saleCount'] != null, 'Required key "ProfitReportRevenue[saleCount]" has a null value in JSON.');
        assert(json.containsKey(r'reversalCount'), 'Required key "ProfitReportRevenue[reversalCount]" is missing from JSON.');
        assert(json[r'reversalCount'] != null, 'Required key "ProfitReportRevenue[reversalCount]" has a null value in JSON.');
        return true;
      }());

      return ProfitReportRevenue(
        grossItemSalesMinor: mapValueOfType<int>(json, r'grossItemSalesMinor')!,
        reversalItemValueMinor: mapValueOfType<int>(json, r'reversalItemValueMinor')!,
        netItemSalesMinor: mapValueOfType<int>(json, r'netItemSalesMinor')!,
        saleCount: mapValueOfType<int>(json, r'saleCount')!,
        reversalCount: mapValueOfType<int>(json, r'reversalCount')!,
      );
    }
    return null;
  }

  static List<ProfitReportRevenue> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ProfitReportRevenue>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ProfitReportRevenue.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ProfitReportRevenue> mapFromJson(dynamic json) {
    final map = <String, ProfitReportRevenue>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ProfitReportRevenue.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ProfitReportRevenue-objects as value to a dart map
  static Map<String, List<ProfitReportRevenue>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ProfitReportRevenue>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ProfitReportRevenue.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'grossItemSalesMinor',
    'reversalItemValueMinor',
    'netItemSalesMinor',
    'saleCount',
    'reversalCount',
  };
}

