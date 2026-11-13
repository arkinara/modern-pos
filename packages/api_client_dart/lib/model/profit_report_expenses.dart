//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ProfitReportExpenses {
  /// Returns a new [ProfitReportExpenses] instance.
  ProfitReportExpenses({
    required this.manualMinor,
    required this.wasteMinor,
    required this.totalMinor,
    this.breakdown = const [],
  });

  /// Minimum value: 0
  /// Maximum value: 9007199254740991
  int manualMinor;

  /// Minimum value: 0
  /// Maximum value: 9007199254740991
  int wasteMinor;

  /// Minimum value: 0
  /// Maximum value: 9007199254740991
  int totalMinor;

  List<ExpenseBreakdownEntry> breakdown;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ProfitReportExpenses &&
    other.manualMinor == manualMinor &&
    other.wasteMinor == wasteMinor &&
    other.totalMinor == totalMinor &&
    _deepEquality.equals(other.breakdown, breakdown);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (manualMinor.hashCode) +
    (wasteMinor.hashCode) +
    (totalMinor.hashCode) +
    (breakdown.hashCode);

  @override
  String toString() => 'ProfitReportExpenses[manualMinor=$manualMinor, wasteMinor=$wasteMinor, totalMinor=$totalMinor, breakdown=$breakdown]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'manualMinor'] = this.manualMinor;
      json[r'wasteMinor'] = this.wasteMinor;
      json[r'totalMinor'] = this.totalMinor;
      json[r'breakdown'] = this.breakdown;
    return json;
  }

  /// Returns a new [ProfitReportExpenses] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ProfitReportExpenses? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'manualMinor'), 'Required key "ProfitReportExpenses[manualMinor]" is missing from JSON.');
        assert(json[r'manualMinor'] != null, 'Required key "ProfitReportExpenses[manualMinor]" has a null value in JSON.');
        assert(json.containsKey(r'wasteMinor'), 'Required key "ProfitReportExpenses[wasteMinor]" is missing from JSON.');
        assert(json[r'wasteMinor'] != null, 'Required key "ProfitReportExpenses[wasteMinor]" has a null value in JSON.');
        assert(json.containsKey(r'totalMinor'), 'Required key "ProfitReportExpenses[totalMinor]" is missing from JSON.');
        assert(json[r'totalMinor'] != null, 'Required key "ProfitReportExpenses[totalMinor]" has a null value in JSON.');
        assert(json.containsKey(r'breakdown'), 'Required key "ProfitReportExpenses[breakdown]" is missing from JSON.');
        assert(json[r'breakdown'] != null, 'Required key "ProfitReportExpenses[breakdown]" has a null value in JSON.');
        return true;
      }());

      return ProfitReportExpenses(
        manualMinor: mapValueOfType<int>(json, r'manualMinor')!,
        wasteMinor: mapValueOfType<int>(json, r'wasteMinor')!,
        totalMinor: mapValueOfType<int>(json, r'totalMinor')!,
        breakdown: ExpenseBreakdownEntry.listFromJson(json[r'breakdown']),
      );
    }
    return null;
  }

  static List<ProfitReportExpenses> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ProfitReportExpenses>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ProfitReportExpenses.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ProfitReportExpenses> mapFromJson(dynamic json) {
    final map = <String, ProfitReportExpenses>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ProfitReportExpenses.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ProfitReportExpenses-objects as value to a dart map
  static Map<String, List<ProfitReportExpenses>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ProfitReportExpenses>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ProfitReportExpenses.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'manualMinor',
    'wasteMinor',
    'totalMinor',
    'breakdown',
  };
}

