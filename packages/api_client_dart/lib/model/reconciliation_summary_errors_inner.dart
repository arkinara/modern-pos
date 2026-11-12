//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ReconciliationSummaryErrorsInner {
  /// Returns a new [ReconciliationSummaryErrorsInner] instance.
  ReconciliationSummaryErrorsInner({
    required this.paymentId,
    required this.code,
  });

  String paymentId;

  String code;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ReconciliationSummaryErrorsInner &&
    other.paymentId == paymentId &&
    other.code == code;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (paymentId.hashCode) +
    (code.hashCode);

  @override
  String toString() => 'ReconciliationSummaryErrorsInner[paymentId=$paymentId, code=$code]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'paymentId'] = this.paymentId;
      json[r'code'] = this.code;
    return json;
  }

  /// Returns a new [ReconciliationSummaryErrorsInner] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ReconciliationSummaryErrorsInner? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'paymentId'), 'Required key "ReconciliationSummaryErrorsInner[paymentId]" is missing from JSON.');
        assert(json[r'paymentId'] != null, 'Required key "ReconciliationSummaryErrorsInner[paymentId]" has a null value in JSON.');
        assert(json.containsKey(r'code'), 'Required key "ReconciliationSummaryErrorsInner[code]" is missing from JSON.');
        assert(json[r'code'] != null, 'Required key "ReconciliationSummaryErrorsInner[code]" has a null value in JSON.');
        return true;
      }());

      return ReconciliationSummaryErrorsInner(
        paymentId: mapValueOfType<String>(json, r'paymentId')!,
        code: mapValueOfType<String>(json, r'code')!,
      );
    }
    return null;
  }

  static List<ReconciliationSummaryErrorsInner> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ReconciliationSummaryErrorsInner>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ReconciliationSummaryErrorsInner.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ReconciliationSummaryErrorsInner> mapFromJson(dynamic json) {
    final map = <String, ReconciliationSummaryErrorsInner>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ReconciliationSummaryErrorsInner.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ReconciliationSummaryErrorsInner-objects as value to a dart map
  static Map<String, List<ReconciliationSummaryErrorsInner>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ReconciliationSummaryErrorsInner>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ReconciliationSummaryErrorsInner.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'paymentId',
    'code',
  };
}

