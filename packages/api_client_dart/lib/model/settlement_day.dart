//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class SettlementDay {
  /// Returns a new [SettlementDay] instance.
  SettlementDay({
    required this.date,
    required this.paymentCount,
    required this.capturedMinor,
    required this.refundedMinor,
    required this.netMinor,
    required this.pendingMinor,
    required this.failedMinor,
  });

  DateTime date;

  /// Minimum value: 0
  int paymentCount;

  /// Minimum value: 0
  /// Maximum value: 9007199254740991
  int capturedMinor;

  /// Minimum value: 0
  /// Maximum value: 9007199254740991
  int refundedMinor;

  /// Minimum value: 0
  /// Maximum value: 9007199254740991
  int netMinor;

  /// Minimum value: 0
  /// Maximum value: 9007199254740991
  int pendingMinor;

  /// Minimum value: 0
  /// Maximum value: 9007199254740991
  int failedMinor;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SettlementDay &&
    other.date == date &&
    other.paymentCount == paymentCount &&
    other.capturedMinor == capturedMinor &&
    other.refundedMinor == refundedMinor &&
    other.netMinor == netMinor &&
    other.pendingMinor == pendingMinor &&
    other.failedMinor == failedMinor;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (date.hashCode) +
    (paymentCount.hashCode) +
    (capturedMinor.hashCode) +
    (refundedMinor.hashCode) +
    (netMinor.hashCode) +
    (pendingMinor.hashCode) +
    (failedMinor.hashCode);

  @override
  String toString() => 'SettlementDay[date=$date, paymentCount=$paymentCount, capturedMinor=$capturedMinor, refundedMinor=$refundedMinor, netMinor=$netMinor, pendingMinor=$pendingMinor, failedMinor=$failedMinor]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'date'] = _dateFormatter.format(this.date);
      json[r'paymentCount'] = this.paymentCount;
      json[r'capturedMinor'] = this.capturedMinor;
      json[r'refundedMinor'] = this.refundedMinor;
      json[r'netMinor'] = this.netMinor;
      json[r'pendingMinor'] = this.pendingMinor;
      json[r'failedMinor'] = this.failedMinor;
    return json;
  }

  /// Returns a new [SettlementDay] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SettlementDay? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'date'), 'Required key "SettlementDay[date]" is missing from JSON.');
        assert(json[r'date'] != null, 'Required key "SettlementDay[date]" has a null value in JSON.');
        assert(json.containsKey(r'paymentCount'), 'Required key "SettlementDay[paymentCount]" is missing from JSON.');
        assert(json[r'paymentCount'] != null, 'Required key "SettlementDay[paymentCount]" has a null value in JSON.');
        assert(json.containsKey(r'capturedMinor'), 'Required key "SettlementDay[capturedMinor]" is missing from JSON.');
        assert(json[r'capturedMinor'] != null, 'Required key "SettlementDay[capturedMinor]" has a null value in JSON.');
        assert(json.containsKey(r'refundedMinor'), 'Required key "SettlementDay[refundedMinor]" is missing from JSON.');
        assert(json[r'refundedMinor'] != null, 'Required key "SettlementDay[refundedMinor]" has a null value in JSON.');
        assert(json.containsKey(r'netMinor'), 'Required key "SettlementDay[netMinor]" is missing from JSON.');
        assert(json[r'netMinor'] != null, 'Required key "SettlementDay[netMinor]" has a null value in JSON.');
        assert(json.containsKey(r'pendingMinor'), 'Required key "SettlementDay[pendingMinor]" is missing from JSON.');
        assert(json[r'pendingMinor'] != null, 'Required key "SettlementDay[pendingMinor]" has a null value in JSON.');
        assert(json.containsKey(r'failedMinor'), 'Required key "SettlementDay[failedMinor]" is missing from JSON.');
        assert(json[r'failedMinor'] != null, 'Required key "SettlementDay[failedMinor]" has a null value in JSON.');
        return true;
      }());

      return SettlementDay(
        date: mapDateTime(json, r'date', r'')!,
        paymentCount: mapValueOfType<int>(json, r'paymentCount')!,
        capturedMinor: mapValueOfType<int>(json, r'capturedMinor')!,
        refundedMinor: mapValueOfType<int>(json, r'refundedMinor')!,
        netMinor: mapValueOfType<int>(json, r'netMinor')!,
        pendingMinor: mapValueOfType<int>(json, r'pendingMinor')!,
        failedMinor: mapValueOfType<int>(json, r'failedMinor')!,
      );
    }
    return null;
  }

  static List<SettlementDay> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SettlementDay>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SettlementDay.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SettlementDay> mapFromJson(dynamic json) {
    final map = <String, SettlementDay>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SettlementDay.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SettlementDay-objects as value to a dart map
  static Map<String, List<SettlementDay>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SettlementDay>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SettlementDay.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'date',
    'paymentCount',
    'capturedMinor',
    'refundedMinor',
    'netMinor',
    'pendingMinor',
    'failedMinor',
  };
}

