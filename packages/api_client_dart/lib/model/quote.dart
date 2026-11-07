//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Quote {
  /// Returns a new [Quote] instance.
  Quote({
    required this.id,
    required this.orderId,
    required this.orderVersion,
    required this.settingsVersion,
    required this.currency,
    required this.currencyExponent,
    required this.expiresAt,
    required this.totals,
    this.lines = const [],
  });

  String id;

  String orderId;

  /// Minimum value: 1
  int orderVersion;

  /// Minimum value: 1
  int settingsVersion;

  String currency;

  /// Minimum value: 0
  /// Maximum value: 3
  int currencyExponent;

  DateTime expiresAt;

  Totals totals;

  List<QuoteLinesInner> lines;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Quote &&
    other.id == id &&
    other.orderId == orderId &&
    other.orderVersion == orderVersion &&
    other.settingsVersion == settingsVersion &&
    other.currency == currency &&
    other.currencyExponent == currencyExponent &&
    other.expiresAt == expiresAt &&
    other.totals == totals &&
    _deepEquality.equals(other.lines, lines);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (orderId.hashCode) +
    (orderVersion.hashCode) +
    (settingsVersion.hashCode) +
    (currency.hashCode) +
    (currencyExponent.hashCode) +
    (expiresAt.hashCode) +
    (totals.hashCode) +
    (lines.hashCode);

  @override
  String toString() => 'Quote[id=$id, orderId=$orderId, orderVersion=$orderVersion, settingsVersion=$settingsVersion, currency=$currency, currencyExponent=$currencyExponent, expiresAt=$expiresAt, totals=$totals, lines=$lines]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'orderId'] = this.orderId;
      json[r'orderVersion'] = this.orderVersion;
      json[r'settingsVersion'] = this.settingsVersion;
      json[r'currency'] = this.currency;
      json[r'currencyExponent'] = this.currencyExponent;
      json[r'expiresAt'] = this.expiresAt.toUtc().toIso8601String();
      json[r'totals'] = this.totals;
      json[r'lines'] = this.lines;
    return json;
  }

  /// Returns a new [Quote] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Quote? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "Quote[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "Quote[id]" has a null value in JSON.');
        assert(json.containsKey(r'orderId'), 'Required key "Quote[orderId]" is missing from JSON.');
        assert(json[r'orderId'] != null, 'Required key "Quote[orderId]" has a null value in JSON.');
        assert(json.containsKey(r'orderVersion'), 'Required key "Quote[orderVersion]" is missing from JSON.');
        assert(json[r'orderVersion'] != null, 'Required key "Quote[orderVersion]" has a null value in JSON.');
        assert(json.containsKey(r'settingsVersion'), 'Required key "Quote[settingsVersion]" is missing from JSON.');
        assert(json[r'settingsVersion'] != null, 'Required key "Quote[settingsVersion]" has a null value in JSON.');
        assert(json.containsKey(r'currency'), 'Required key "Quote[currency]" is missing from JSON.');
        assert(json[r'currency'] != null, 'Required key "Quote[currency]" has a null value in JSON.');
        assert(json.containsKey(r'currencyExponent'), 'Required key "Quote[currencyExponent]" is missing from JSON.');
        assert(json[r'currencyExponent'] != null, 'Required key "Quote[currencyExponent]" has a null value in JSON.');
        assert(json.containsKey(r'expiresAt'), 'Required key "Quote[expiresAt]" is missing from JSON.');
        assert(json[r'expiresAt'] != null, 'Required key "Quote[expiresAt]" has a null value in JSON.');
        assert(json.containsKey(r'totals'), 'Required key "Quote[totals]" is missing from JSON.');
        assert(json[r'totals'] != null, 'Required key "Quote[totals]" has a null value in JSON.');
        assert(json.containsKey(r'lines'), 'Required key "Quote[lines]" is missing from JSON.');
        assert(json[r'lines'] != null, 'Required key "Quote[lines]" has a null value in JSON.');
        return true;
      }());

      return Quote(
        id: mapValueOfType<String>(json, r'id')!,
        orderId: mapValueOfType<String>(json, r'orderId')!,
        orderVersion: mapValueOfType<int>(json, r'orderVersion')!,
        settingsVersion: mapValueOfType<int>(json, r'settingsVersion')!,
        currency: mapValueOfType<String>(json, r'currency')!,
        currencyExponent: mapValueOfType<int>(json, r'currencyExponent')!,
        expiresAt: mapDateTime(json, r'expiresAt', r'')!,
        totals: Totals.fromJson(json[r'totals'])!,
        lines: QuoteLinesInner.listFromJson(json[r'lines']),
      );
    }
    return null;
  }

  static List<Quote> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Quote>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Quote.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Quote> mapFromJson(dynamic json) {
    final map = <String, Quote>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Quote.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Quote-objects as value to a dart map
  static Map<String, List<Quote>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Quote>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Quote.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'orderId',
    'orderVersion',
    'settingsVersion',
    'currency',
    'currencyExponent',
    'expiresAt',
    'totals',
    'lines',
  };
}

