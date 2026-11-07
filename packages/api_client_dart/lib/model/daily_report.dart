//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class DailyReport {
  /// Returns a new [DailyReport] instance.
  DailyReport({
    required this.from,
    required this.to,
    required this.timezone,
    required this.currency,
    required this.currencyExponent,
    required this.grossItemSalesMinor,
    required this.reversalItemValueMinor,
    required this.netItemSalesMinor,
    required this.saleCount,
    required this.reversalCount,
    required this.averageBillMinor,
    this.paymentBreakdown = const [],
    this.topItems = const [],
    required this.generatedAt,
  });

  DateTime from;

  DateTime to;

  String timezone;

  String currency;

  /// Minimum value: 0
  /// Maximum value: 3
  int currencyExponent;

  /// Currency minor units; IDR exponent 0 in demo.
  ///
  /// Minimum value: 0
  /// Maximum value: 9007199254740991
  int grossItemSalesMinor;

  /// Currency minor units; IDR exponent 0 in demo.
  ///
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

  /// Currency minor units; IDR exponent 0 in demo.
  ///
  /// Minimum value: 0
  /// Maximum value: 9007199254740991
  int averageBillMinor;

  List<DailyReportPaymentBreakdownInner> paymentBreakdown;

  List<DailyReportTopItemsInner> topItems;

  DateTime generatedAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is DailyReport &&
    other.from == from &&
    other.to == to &&
    other.timezone == timezone &&
    other.currency == currency &&
    other.currencyExponent == currencyExponent &&
    other.grossItemSalesMinor == grossItemSalesMinor &&
    other.reversalItemValueMinor == reversalItemValueMinor &&
    other.netItemSalesMinor == netItemSalesMinor &&
    other.saleCount == saleCount &&
    other.reversalCount == reversalCount &&
    other.averageBillMinor == averageBillMinor &&
    _deepEquality.equals(other.paymentBreakdown, paymentBreakdown) &&
    _deepEquality.equals(other.topItems, topItems) &&
    other.generatedAt == generatedAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (from.hashCode) +
    (to.hashCode) +
    (timezone.hashCode) +
    (currency.hashCode) +
    (currencyExponent.hashCode) +
    (grossItemSalesMinor.hashCode) +
    (reversalItemValueMinor.hashCode) +
    (netItemSalesMinor.hashCode) +
    (saleCount.hashCode) +
    (reversalCount.hashCode) +
    (averageBillMinor.hashCode) +
    (paymentBreakdown.hashCode) +
    (topItems.hashCode) +
    (generatedAt.hashCode);

  @override
  String toString() => 'DailyReport[from=$from, to=$to, timezone=$timezone, currency=$currency, currencyExponent=$currencyExponent, grossItemSalesMinor=$grossItemSalesMinor, reversalItemValueMinor=$reversalItemValueMinor, netItemSalesMinor=$netItemSalesMinor, saleCount=$saleCount, reversalCount=$reversalCount, averageBillMinor=$averageBillMinor, paymentBreakdown=$paymentBreakdown, topItems=$topItems, generatedAt=$generatedAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'from'] = _dateFormatter.format(this.from);
      json[r'to'] = _dateFormatter.format(this.to);
      json[r'timezone'] = this.timezone;
      json[r'currency'] = this.currency;
      json[r'currencyExponent'] = this.currencyExponent;
      json[r'grossItemSalesMinor'] = this.grossItemSalesMinor;
      json[r'reversalItemValueMinor'] = this.reversalItemValueMinor;
      json[r'netItemSalesMinor'] = this.netItemSalesMinor;
      json[r'saleCount'] = this.saleCount;
      json[r'reversalCount'] = this.reversalCount;
      json[r'averageBillMinor'] = this.averageBillMinor;
      json[r'paymentBreakdown'] = this.paymentBreakdown;
      json[r'topItems'] = this.topItems;
      json[r'generatedAt'] = this.generatedAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [DailyReport] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static DailyReport? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'from'), 'Required key "DailyReport[from]" is missing from JSON.');
        assert(json[r'from'] != null, 'Required key "DailyReport[from]" has a null value in JSON.');
        assert(json.containsKey(r'to'), 'Required key "DailyReport[to]" is missing from JSON.');
        assert(json[r'to'] != null, 'Required key "DailyReport[to]" has a null value in JSON.');
        assert(json.containsKey(r'timezone'), 'Required key "DailyReport[timezone]" is missing from JSON.');
        assert(json[r'timezone'] != null, 'Required key "DailyReport[timezone]" has a null value in JSON.');
        assert(json.containsKey(r'currency'), 'Required key "DailyReport[currency]" is missing from JSON.');
        assert(json[r'currency'] != null, 'Required key "DailyReport[currency]" has a null value in JSON.');
        assert(json.containsKey(r'currencyExponent'), 'Required key "DailyReport[currencyExponent]" is missing from JSON.');
        assert(json[r'currencyExponent'] != null, 'Required key "DailyReport[currencyExponent]" has a null value in JSON.');
        assert(json.containsKey(r'grossItemSalesMinor'), 'Required key "DailyReport[grossItemSalesMinor]" is missing from JSON.');
        assert(json[r'grossItemSalesMinor'] != null, 'Required key "DailyReport[grossItemSalesMinor]" has a null value in JSON.');
        assert(json.containsKey(r'reversalItemValueMinor'), 'Required key "DailyReport[reversalItemValueMinor]" is missing from JSON.');
        assert(json[r'reversalItemValueMinor'] != null, 'Required key "DailyReport[reversalItemValueMinor]" has a null value in JSON.');
        assert(json.containsKey(r'netItemSalesMinor'), 'Required key "DailyReport[netItemSalesMinor]" is missing from JSON.');
        assert(json[r'netItemSalesMinor'] != null, 'Required key "DailyReport[netItemSalesMinor]" has a null value in JSON.');
        assert(json.containsKey(r'saleCount'), 'Required key "DailyReport[saleCount]" is missing from JSON.');
        assert(json[r'saleCount'] != null, 'Required key "DailyReport[saleCount]" has a null value in JSON.');
        assert(json.containsKey(r'reversalCount'), 'Required key "DailyReport[reversalCount]" is missing from JSON.');
        assert(json[r'reversalCount'] != null, 'Required key "DailyReport[reversalCount]" has a null value in JSON.');
        assert(json.containsKey(r'averageBillMinor'), 'Required key "DailyReport[averageBillMinor]" is missing from JSON.');
        assert(json[r'averageBillMinor'] != null, 'Required key "DailyReport[averageBillMinor]" has a null value in JSON.');
        assert(json.containsKey(r'paymentBreakdown'), 'Required key "DailyReport[paymentBreakdown]" is missing from JSON.');
        assert(json[r'paymentBreakdown'] != null, 'Required key "DailyReport[paymentBreakdown]" has a null value in JSON.');
        assert(json.containsKey(r'topItems'), 'Required key "DailyReport[topItems]" is missing from JSON.');
        assert(json[r'topItems'] != null, 'Required key "DailyReport[topItems]" has a null value in JSON.');
        assert(json.containsKey(r'generatedAt'), 'Required key "DailyReport[generatedAt]" is missing from JSON.');
        assert(json[r'generatedAt'] != null, 'Required key "DailyReport[generatedAt]" has a null value in JSON.');
        return true;
      }());

      return DailyReport(
        from: mapDateTime(json, r'from', r'')!,
        to: mapDateTime(json, r'to', r'')!,
        timezone: mapValueOfType<String>(json, r'timezone')!,
        currency: mapValueOfType<String>(json, r'currency')!,
        currencyExponent: mapValueOfType<int>(json, r'currencyExponent')!,
        grossItemSalesMinor: mapValueOfType<int>(json, r'grossItemSalesMinor')!,
        reversalItemValueMinor: mapValueOfType<int>(json, r'reversalItemValueMinor')!,
        netItemSalesMinor: mapValueOfType<int>(json, r'netItemSalesMinor')!,
        saleCount: mapValueOfType<int>(json, r'saleCount')!,
        reversalCount: mapValueOfType<int>(json, r'reversalCount')!,
        averageBillMinor: mapValueOfType<int>(json, r'averageBillMinor')!,
        paymentBreakdown: DailyReportPaymentBreakdownInner.listFromJson(json[r'paymentBreakdown']),
        topItems: DailyReportTopItemsInner.listFromJson(json[r'topItems']),
        generatedAt: mapDateTime(json, r'generatedAt', r'')!,
      );
    }
    return null;
  }

  static List<DailyReport> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DailyReport>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DailyReport.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, DailyReport> mapFromJson(dynamic json) {
    final map = <String, DailyReport>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = DailyReport.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of DailyReport-objects as value to a dart map
  static Map<String, List<DailyReport>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<DailyReport>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = DailyReport.listFromJson(entry.value, growable: growable,);
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
    'grossItemSalesMinor',
    'reversalItemValueMinor',
    'netItemSalesMinor',
    'saleCount',
    'reversalCount',
    'averageBillMinor',
    'paymentBreakdown',
    'topItems',
    'generatedAt',
  };
}

