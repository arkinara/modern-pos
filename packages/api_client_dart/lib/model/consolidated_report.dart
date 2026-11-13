//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ConsolidatedReport {
  /// Returns a new [ConsolidatedReport] instance.
  ConsolidatedReport({
    required this.from,
    required this.to,
    required this.generatedAt,
    required this.outletCount,
    required this.currency,
    required this.currencyExponent,
    required this.currencyConsistent,
    this.perOutlet = const [],
    required this.consolidated,
  });

  DateTime from;

  DateTime to;

  DateTime generatedAt;

  /// Minimum value: 0
  int outletCount;

  String? currency;

  /// Minimum value: 0
  /// Maximum value: 3
  int? currencyExponent;

  bool currencyConsistent;

  List<ConsolidatedOutlet> perOutlet;

  ConsolidatedReportConsolidated consolidated;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ConsolidatedReport &&
    other.from == from &&
    other.to == to &&
    other.generatedAt == generatedAt &&
    other.outletCount == outletCount &&
    other.currency == currency &&
    other.currencyExponent == currencyExponent &&
    other.currencyConsistent == currencyConsistent &&
    _deepEquality.equals(other.perOutlet, perOutlet) &&
    other.consolidated == consolidated;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (from.hashCode) +
    (to.hashCode) +
    (generatedAt.hashCode) +
    (outletCount.hashCode) +
    (currency == null ? 0 : currency!.hashCode) +
    (currencyExponent == null ? 0 : currencyExponent!.hashCode) +
    (currencyConsistent.hashCode) +
    (perOutlet.hashCode) +
    (consolidated.hashCode);

  @override
  String toString() => 'ConsolidatedReport[from=$from, to=$to, generatedAt=$generatedAt, outletCount=$outletCount, currency=$currency, currencyExponent=$currencyExponent, currencyConsistent=$currencyConsistent, perOutlet=$perOutlet, consolidated=$consolidated]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'from'] = _dateFormatter.format(this.from);
      json[r'to'] = _dateFormatter.format(this.to);
      json[r'generatedAt'] = this.generatedAt.toUtc().toIso8601String();
      json[r'outletCount'] = this.outletCount;
    if (this.currency != null) {
      json[r'currency'] = this.currency;
    } else {
      json[r'currency'] = null;
    }
    if (this.currencyExponent != null) {
      json[r'currencyExponent'] = this.currencyExponent;
    } else {
      json[r'currencyExponent'] = null;
    }
      json[r'currencyConsistent'] = this.currencyConsistent;
      json[r'perOutlet'] = this.perOutlet;
      json[r'consolidated'] = this.consolidated;
    return json;
  }

  /// Returns a new [ConsolidatedReport] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ConsolidatedReport? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'from'), 'Required key "ConsolidatedReport[from]" is missing from JSON.');
        assert(json[r'from'] != null, 'Required key "ConsolidatedReport[from]" has a null value in JSON.');
        assert(json.containsKey(r'to'), 'Required key "ConsolidatedReport[to]" is missing from JSON.');
        assert(json[r'to'] != null, 'Required key "ConsolidatedReport[to]" has a null value in JSON.');
        assert(json.containsKey(r'generatedAt'), 'Required key "ConsolidatedReport[generatedAt]" is missing from JSON.');
        assert(json[r'generatedAt'] != null, 'Required key "ConsolidatedReport[generatedAt]" has a null value in JSON.');
        assert(json.containsKey(r'outletCount'), 'Required key "ConsolidatedReport[outletCount]" is missing from JSON.');
        assert(json[r'outletCount'] != null, 'Required key "ConsolidatedReport[outletCount]" has a null value in JSON.');
        assert(json.containsKey(r'currency'), 'Required key "ConsolidatedReport[currency]" is missing from JSON.');
        assert(json.containsKey(r'currencyExponent'), 'Required key "ConsolidatedReport[currencyExponent]" is missing from JSON.');
        assert(json.containsKey(r'currencyConsistent'), 'Required key "ConsolidatedReport[currencyConsistent]" is missing from JSON.');
        assert(json[r'currencyConsistent'] != null, 'Required key "ConsolidatedReport[currencyConsistent]" has a null value in JSON.');
        assert(json.containsKey(r'perOutlet'), 'Required key "ConsolidatedReport[perOutlet]" is missing from JSON.');
        assert(json[r'perOutlet'] != null, 'Required key "ConsolidatedReport[perOutlet]" has a null value in JSON.');
        assert(json.containsKey(r'consolidated'), 'Required key "ConsolidatedReport[consolidated]" is missing from JSON.');
        assert(json[r'consolidated'] != null, 'Required key "ConsolidatedReport[consolidated]" has a null value in JSON.');
        return true;
      }());

      return ConsolidatedReport(
        from: mapDateTime(json, r'from', r'')!,
        to: mapDateTime(json, r'to', r'')!,
        generatedAt: mapDateTime(json, r'generatedAt', r'')!,
        outletCount: mapValueOfType<int>(json, r'outletCount')!,
        currency: mapValueOfType<String>(json, r'currency'),
        currencyExponent: mapValueOfType<int>(json, r'currencyExponent'),
        currencyConsistent: mapValueOfType<bool>(json, r'currencyConsistent')!,
        perOutlet: ConsolidatedOutlet.listFromJson(json[r'perOutlet']),
        consolidated: ConsolidatedReportConsolidated.fromJson(json[r'consolidated'])!,
      );
    }
    return null;
  }

  static List<ConsolidatedReport> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ConsolidatedReport>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ConsolidatedReport.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ConsolidatedReport> mapFromJson(dynamic json) {
    final map = <String, ConsolidatedReport>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ConsolidatedReport.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ConsolidatedReport-objects as value to a dart map
  static Map<String, List<ConsolidatedReport>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ConsolidatedReport>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ConsolidatedReport.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'from',
    'to',
    'generatedAt',
    'outletCount',
    'currency',
    'currencyExponent',
    'currencyConsistent',
    'perOutlet',
    'consolidated',
  };
}

