//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ReconciliationSummary {
  /// Returns a new [ReconciliationSummary] instance.
  ReconciliationSummary({
    required this.checked,
    required this.settled,
    required this.failed,
    required this.unchanged,
    this.errors = const [],
    this.items = const [],
  });

  /// Minimum value: 0
  int checked;

  /// Minimum value: 0
  int settled;

  /// Minimum value: 0
  int failed;

  /// Minimum value: 0
  int unchanged;

  List<ReconciliationSummaryErrorsInner> errors;

  List<OnlinePayment> items;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ReconciliationSummary &&
    other.checked == checked &&
    other.settled == settled &&
    other.failed == failed &&
    other.unchanged == unchanged &&
    _deepEquality.equals(other.errors, errors) &&
    _deepEquality.equals(other.items, items);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (checked.hashCode) +
    (settled.hashCode) +
    (failed.hashCode) +
    (unchanged.hashCode) +
    (errors.hashCode) +
    (items.hashCode);

  @override
  String toString() => 'ReconciliationSummary[checked=$checked, settled=$settled, failed=$failed, unchanged=$unchanged, errors=$errors, items=$items]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'checked'] = this.checked;
      json[r'settled'] = this.settled;
      json[r'failed'] = this.failed;
      json[r'unchanged'] = this.unchanged;
      json[r'errors'] = this.errors;
      json[r'items'] = this.items;
    return json;
  }

  /// Returns a new [ReconciliationSummary] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ReconciliationSummary? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'checked'), 'Required key "ReconciliationSummary[checked]" is missing from JSON.');
        assert(json[r'checked'] != null, 'Required key "ReconciliationSummary[checked]" has a null value in JSON.');
        assert(json.containsKey(r'settled'), 'Required key "ReconciliationSummary[settled]" is missing from JSON.');
        assert(json[r'settled'] != null, 'Required key "ReconciliationSummary[settled]" has a null value in JSON.');
        assert(json.containsKey(r'failed'), 'Required key "ReconciliationSummary[failed]" is missing from JSON.');
        assert(json[r'failed'] != null, 'Required key "ReconciliationSummary[failed]" has a null value in JSON.');
        assert(json.containsKey(r'unchanged'), 'Required key "ReconciliationSummary[unchanged]" is missing from JSON.');
        assert(json[r'unchanged'] != null, 'Required key "ReconciliationSummary[unchanged]" has a null value in JSON.');
        assert(json.containsKey(r'errors'), 'Required key "ReconciliationSummary[errors]" is missing from JSON.');
        assert(json[r'errors'] != null, 'Required key "ReconciliationSummary[errors]" has a null value in JSON.');
        assert(json.containsKey(r'items'), 'Required key "ReconciliationSummary[items]" is missing from JSON.');
        assert(json[r'items'] != null, 'Required key "ReconciliationSummary[items]" has a null value in JSON.');
        return true;
      }());

      return ReconciliationSummary(
        checked: mapValueOfType<int>(json, r'checked')!,
        settled: mapValueOfType<int>(json, r'settled')!,
        failed: mapValueOfType<int>(json, r'failed')!,
        unchanged: mapValueOfType<int>(json, r'unchanged')!,
        errors: ReconciliationSummaryErrorsInner.listFromJson(json[r'errors']),
        items: OnlinePayment.listFromJson(json[r'items']),
      );
    }
    return null;
  }

  static List<ReconciliationSummary> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ReconciliationSummary>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ReconciliationSummary.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ReconciliationSummary> mapFromJson(dynamic json) {
    final map = <String, ReconciliationSummary>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ReconciliationSummary.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ReconciliationSummary-objects as value to a dart map
  static Map<String, List<ReconciliationSummary>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ReconciliationSummary>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ReconciliationSummary.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'checked',
    'settled',
    'failed',
    'unchanged',
    'errors',
    'items',
  };
}

