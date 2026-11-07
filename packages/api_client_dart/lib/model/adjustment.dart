//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Adjustment {
  /// Returns a new [Adjustment] instance.
  Adjustment({
    required this.stockItemId,
    required this.delta,
    required this.reason,
    required this.expectedBalanceVersion,
  });

  String stockItemId;

  String delta;

  String reason;

  /// Minimum value: 1
  int expectedBalanceVersion;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Adjustment &&
    other.stockItemId == stockItemId &&
    other.delta == delta &&
    other.reason == reason &&
    other.expectedBalanceVersion == expectedBalanceVersion;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (stockItemId.hashCode) +
    (delta.hashCode) +
    (reason.hashCode) +
    (expectedBalanceVersion.hashCode);

  @override
  String toString() => 'Adjustment[stockItemId=$stockItemId, delta=$delta, reason=$reason, expectedBalanceVersion=$expectedBalanceVersion]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'stockItemId'] = this.stockItemId;
      json[r'delta'] = this.delta;
      json[r'reason'] = this.reason;
      json[r'expectedBalanceVersion'] = this.expectedBalanceVersion;
    return json;
  }

  /// Returns a new [Adjustment] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Adjustment? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'stockItemId'), 'Required key "Adjustment[stockItemId]" is missing from JSON.');
        assert(json[r'stockItemId'] != null, 'Required key "Adjustment[stockItemId]" has a null value in JSON.');
        assert(json.containsKey(r'delta'), 'Required key "Adjustment[delta]" is missing from JSON.');
        assert(json[r'delta'] != null, 'Required key "Adjustment[delta]" has a null value in JSON.');
        assert(json.containsKey(r'reason'), 'Required key "Adjustment[reason]" is missing from JSON.');
        assert(json[r'reason'] != null, 'Required key "Adjustment[reason]" has a null value in JSON.');
        assert(json.containsKey(r'expectedBalanceVersion'), 'Required key "Adjustment[expectedBalanceVersion]" is missing from JSON.');
        assert(json[r'expectedBalanceVersion'] != null, 'Required key "Adjustment[expectedBalanceVersion]" has a null value in JSON.');
        return true;
      }());

      return Adjustment(
        stockItemId: mapValueOfType<String>(json, r'stockItemId')!,
        delta: mapValueOfType<String>(json, r'delta')!,
        reason: mapValueOfType<String>(json, r'reason')!,
        expectedBalanceVersion: mapValueOfType<int>(json, r'expectedBalanceVersion')!,
      );
    }
    return null;
  }

  static List<Adjustment> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Adjustment>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Adjustment.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Adjustment> mapFromJson(dynamic json) {
    final map = <String, Adjustment>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Adjustment.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Adjustment-objects as value to a dart map
  static Map<String, List<Adjustment>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Adjustment>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Adjustment.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'stockItemId',
    'delta',
    'reason',
    'expectedBalanceVersion',
  };
}

