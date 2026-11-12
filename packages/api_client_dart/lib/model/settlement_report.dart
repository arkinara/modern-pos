//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class SettlementReport {
  /// Returns a new [SettlementReport] instance.
  SettlementReport({
    required this.from,
    required this.to,
    required this.timezone,
    required this.currency,
    required this.currencyExponent,
    required this.onlineSaleTotalMinor,
    required this.capturedMinor,
    required this.refundedMinor,
    required this.netMinor,
    required this.pendingMinor,
    required this.failedMinor,
    required this.driftMinor,
    required this.saleCount,
    this.days = const [],
    this.payments = const [],
    required this.generatedAt,
  });

  DateTime from;

  DateTime to;

  String timezone;

  String currency;

  /// Minimum value: 0
  /// Maximum value: 3
  int currencyExponent;

  /// Minimum value: 0
  /// Maximum value: 9007199254740991
  int onlineSaleTotalMinor;

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

  /// Minimum value: 0
  /// Maximum value: 9007199254740991
  int driftMinor;

  /// Minimum value: 0
  int saleCount;

  List<SettlementDay> days;

  List<SettlementPayment> payments;

  DateTime generatedAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SettlementReport &&
    other.from == from &&
    other.to == to &&
    other.timezone == timezone &&
    other.currency == currency &&
    other.currencyExponent == currencyExponent &&
    other.onlineSaleTotalMinor == onlineSaleTotalMinor &&
    other.capturedMinor == capturedMinor &&
    other.refundedMinor == refundedMinor &&
    other.netMinor == netMinor &&
    other.pendingMinor == pendingMinor &&
    other.failedMinor == failedMinor &&
    other.driftMinor == driftMinor &&
    other.saleCount == saleCount &&
    _deepEquality.equals(other.days, days) &&
    _deepEquality.equals(other.payments, payments) &&
    other.generatedAt == generatedAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (from.hashCode) +
    (to.hashCode) +
    (timezone.hashCode) +
    (currency.hashCode) +
    (currencyExponent.hashCode) +
    (onlineSaleTotalMinor.hashCode) +
    (capturedMinor.hashCode) +
    (refundedMinor.hashCode) +
    (netMinor.hashCode) +
    (pendingMinor.hashCode) +
    (failedMinor.hashCode) +
    (driftMinor.hashCode) +
    (saleCount.hashCode) +
    (days.hashCode) +
    (payments.hashCode) +
    (generatedAt.hashCode);

  @override
  String toString() => 'SettlementReport[from=$from, to=$to, timezone=$timezone, currency=$currency, currencyExponent=$currencyExponent, onlineSaleTotalMinor=$onlineSaleTotalMinor, capturedMinor=$capturedMinor, refundedMinor=$refundedMinor, netMinor=$netMinor, pendingMinor=$pendingMinor, failedMinor=$failedMinor, driftMinor=$driftMinor, saleCount=$saleCount, days=$days, payments=$payments, generatedAt=$generatedAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'from'] = _dateFormatter.format(this.from);
      json[r'to'] = _dateFormatter.format(this.to);
      json[r'timezone'] = this.timezone;
      json[r'currency'] = this.currency;
      json[r'currencyExponent'] = this.currencyExponent;
      json[r'onlineSaleTotalMinor'] = this.onlineSaleTotalMinor;
      json[r'capturedMinor'] = this.capturedMinor;
      json[r'refundedMinor'] = this.refundedMinor;
      json[r'netMinor'] = this.netMinor;
      json[r'pendingMinor'] = this.pendingMinor;
      json[r'failedMinor'] = this.failedMinor;
      json[r'driftMinor'] = this.driftMinor;
      json[r'saleCount'] = this.saleCount;
      json[r'days'] = this.days;
      json[r'payments'] = this.payments;
      json[r'generatedAt'] = this.generatedAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [SettlementReport] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SettlementReport? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'from'), 'Required key "SettlementReport[from]" is missing from JSON.');
        assert(json[r'from'] != null, 'Required key "SettlementReport[from]" has a null value in JSON.');
        assert(json.containsKey(r'to'), 'Required key "SettlementReport[to]" is missing from JSON.');
        assert(json[r'to'] != null, 'Required key "SettlementReport[to]" has a null value in JSON.');
        assert(json.containsKey(r'timezone'), 'Required key "SettlementReport[timezone]" is missing from JSON.');
        assert(json[r'timezone'] != null, 'Required key "SettlementReport[timezone]" has a null value in JSON.');
        assert(json.containsKey(r'currency'), 'Required key "SettlementReport[currency]" is missing from JSON.');
        assert(json[r'currency'] != null, 'Required key "SettlementReport[currency]" has a null value in JSON.');
        assert(json.containsKey(r'currencyExponent'), 'Required key "SettlementReport[currencyExponent]" is missing from JSON.');
        assert(json[r'currencyExponent'] != null, 'Required key "SettlementReport[currencyExponent]" has a null value in JSON.');
        assert(json.containsKey(r'onlineSaleTotalMinor'), 'Required key "SettlementReport[onlineSaleTotalMinor]" is missing from JSON.');
        assert(json[r'onlineSaleTotalMinor'] != null, 'Required key "SettlementReport[onlineSaleTotalMinor]" has a null value in JSON.');
        assert(json.containsKey(r'capturedMinor'), 'Required key "SettlementReport[capturedMinor]" is missing from JSON.');
        assert(json[r'capturedMinor'] != null, 'Required key "SettlementReport[capturedMinor]" has a null value in JSON.');
        assert(json.containsKey(r'refundedMinor'), 'Required key "SettlementReport[refundedMinor]" is missing from JSON.');
        assert(json[r'refundedMinor'] != null, 'Required key "SettlementReport[refundedMinor]" has a null value in JSON.');
        assert(json.containsKey(r'netMinor'), 'Required key "SettlementReport[netMinor]" is missing from JSON.');
        assert(json[r'netMinor'] != null, 'Required key "SettlementReport[netMinor]" has a null value in JSON.');
        assert(json.containsKey(r'pendingMinor'), 'Required key "SettlementReport[pendingMinor]" is missing from JSON.');
        assert(json[r'pendingMinor'] != null, 'Required key "SettlementReport[pendingMinor]" has a null value in JSON.');
        assert(json.containsKey(r'failedMinor'), 'Required key "SettlementReport[failedMinor]" is missing from JSON.');
        assert(json[r'failedMinor'] != null, 'Required key "SettlementReport[failedMinor]" has a null value in JSON.');
        assert(json.containsKey(r'driftMinor'), 'Required key "SettlementReport[driftMinor]" is missing from JSON.');
        assert(json[r'driftMinor'] != null, 'Required key "SettlementReport[driftMinor]" has a null value in JSON.');
        assert(json.containsKey(r'saleCount'), 'Required key "SettlementReport[saleCount]" is missing from JSON.');
        assert(json[r'saleCount'] != null, 'Required key "SettlementReport[saleCount]" has a null value in JSON.');
        assert(json.containsKey(r'days'), 'Required key "SettlementReport[days]" is missing from JSON.');
        assert(json[r'days'] != null, 'Required key "SettlementReport[days]" has a null value in JSON.');
        assert(json.containsKey(r'payments'), 'Required key "SettlementReport[payments]" is missing from JSON.');
        assert(json[r'payments'] != null, 'Required key "SettlementReport[payments]" has a null value in JSON.');
        assert(json.containsKey(r'generatedAt'), 'Required key "SettlementReport[generatedAt]" is missing from JSON.');
        assert(json[r'generatedAt'] != null, 'Required key "SettlementReport[generatedAt]" has a null value in JSON.');
        return true;
      }());

      return SettlementReport(
        from: mapDateTime(json, r'from', r'')!,
        to: mapDateTime(json, r'to', r'')!,
        timezone: mapValueOfType<String>(json, r'timezone')!,
        currency: mapValueOfType<String>(json, r'currency')!,
        currencyExponent: mapValueOfType<int>(json, r'currencyExponent')!,
        onlineSaleTotalMinor: mapValueOfType<int>(json, r'onlineSaleTotalMinor')!,
        capturedMinor: mapValueOfType<int>(json, r'capturedMinor')!,
        refundedMinor: mapValueOfType<int>(json, r'refundedMinor')!,
        netMinor: mapValueOfType<int>(json, r'netMinor')!,
        pendingMinor: mapValueOfType<int>(json, r'pendingMinor')!,
        failedMinor: mapValueOfType<int>(json, r'failedMinor')!,
        driftMinor: mapValueOfType<int>(json, r'driftMinor')!,
        saleCount: mapValueOfType<int>(json, r'saleCount')!,
        days: SettlementDay.listFromJson(json[r'days']),
        payments: SettlementPayment.listFromJson(json[r'payments']),
        generatedAt: mapDateTime(json, r'generatedAt', r'')!,
      );
    }
    return null;
  }

  static List<SettlementReport> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SettlementReport>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SettlementReport.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SettlementReport> mapFromJson(dynamic json) {
    final map = <String, SettlementReport>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SettlementReport.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SettlementReport-objects as value to a dart map
  static Map<String, List<SettlementReport>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SettlementReport>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SettlementReport.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'from',
    'to',
    'timezone',
    'currency',
    'currencyExponent',
    'onlineSaleTotalMinor',
    'capturedMinor',
    'refundedMinor',
    'netMinor',
    'pendingMinor',
    'failedMinor',
    'driftMinor',
    'saleCount',
    'days',
    'payments',
    'generatedAt',
  };
}

