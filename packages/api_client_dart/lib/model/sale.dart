//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Sale {
  /// Returns a new [Sale] instance.
  Sale({
    required this.id,
    required this.orderId,
    required this.reference,
    required this.state,
    required this.currency,
    required this.currencyExponent,
    required this.timezone,
    required this.completedAt,
    required this.totals,
    this.lines = const [],
    required this.payment,
  });

  String id;

  String orderId;

  String reference;

  SaleStateEnum state;

  String currency;

  /// Minimum value: 0
  /// Maximum value: 3
  int currencyExponent;

  String timezone;

  DateTime completedAt;

  Totals totals;

  List<SaleLine> lines;

  Payment payment;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Sale &&
    other.id == id &&
    other.orderId == orderId &&
    other.reference == reference &&
    other.state == state &&
    other.currency == currency &&
    other.currencyExponent == currencyExponent &&
    other.timezone == timezone &&
    other.completedAt == completedAt &&
    other.totals == totals &&
    _deepEquality.equals(other.lines, lines) &&
    other.payment == payment;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (orderId.hashCode) +
    (reference.hashCode) +
    (state.hashCode) +
    (currency.hashCode) +
    (currencyExponent.hashCode) +
    (timezone.hashCode) +
    (completedAt.hashCode) +
    (totals.hashCode) +
    (lines.hashCode) +
    (payment.hashCode);

  @override
  String toString() => 'Sale[id=$id, orderId=$orderId, reference=$reference, state=$state, currency=$currency, currencyExponent=$currencyExponent, timezone=$timezone, completedAt=$completedAt, totals=$totals, lines=$lines, payment=$payment]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'orderId'] = this.orderId;
      json[r'reference'] = this.reference;
      json[r'state'] = this.state;
      json[r'currency'] = this.currency;
      json[r'currencyExponent'] = this.currencyExponent;
      json[r'timezone'] = this.timezone;
      json[r'completedAt'] = this.completedAt.toUtc().toIso8601String();
      json[r'totals'] = this.totals;
      json[r'lines'] = this.lines;
      json[r'payment'] = this.payment;
    return json;
  }

  /// Returns a new [Sale] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Sale? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "Sale[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "Sale[id]" has a null value in JSON.');
        assert(json.containsKey(r'orderId'), 'Required key "Sale[orderId]" is missing from JSON.');
        assert(json[r'orderId'] != null, 'Required key "Sale[orderId]" has a null value in JSON.');
        assert(json.containsKey(r'reference'), 'Required key "Sale[reference]" is missing from JSON.');
        assert(json[r'reference'] != null, 'Required key "Sale[reference]" has a null value in JSON.');
        assert(json.containsKey(r'state'), 'Required key "Sale[state]" is missing from JSON.');
        assert(json[r'state'] != null, 'Required key "Sale[state]" has a null value in JSON.');
        assert(json.containsKey(r'currency'), 'Required key "Sale[currency]" is missing from JSON.');
        assert(json[r'currency'] != null, 'Required key "Sale[currency]" has a null value in JSON.');
        assert(json.containsKey(r'currencyExponent'), 'Required key "Sale[currencyExponent]" is missing from JSON.');
        assert(json[r'currencyExponent'] != null, 'Required key "Sale[currencyExponent]" has a null value in JSON.');
        assert(json.containsKey(r'timezone'), 'Required key "Sale[timezone]" is missing from JSON.');
        assert(json[r'timezone'] != null, 'Required key "Sale[timezone]" has a null value in JSON.');
        assert(json.containsKey(r'completedAt'), 'Required key "Sale[completedAt]" is missing from JSON.');
        assert(json[r'completedAt'] != null, 'Required key "Sale[completedAt]" has a null value in JSON.');
        assert(json.containsKey(r'totals'), 'Required key "Sale[totals]" is missing from JSON.');
        assert(json[r'totals'] != null, 'Required key "Sale[totals]" has a null value in JSON.');
        assert(json.containsKey(r'lines'), 'Required key "Sale[lines]" is missing from JSON.');
        assert(json[r'lines'] != null, 'Required key "Sale[lines]" has a null value in JSON.');
        assert(json.containsKey(r'payment'), 'Required key "Sale[payment]" is missing from JSON.');
        assert(json[r'payment'] != null, 'Required key "Sale[payment]" has a null value in JSON.');
        return true;
      }());

      return Sale(
        id: mapValueOfType<String>(json, r'id')!,
        orderId: mapValueOfType<String>(json, r'orderId')!,
        reference: mapValueOfType<String>(json, r'reference')!,
        state: SaleStateEnum.fromJson(json[r'state'])!,
        currency: mapValueOfType<String>(json, r'currency')!,
        currencyExponent: mapValueOfType<int>(json, r'currencyExponent')!,
        timezone: mapValueOfType<String>(json, r'timezone')!,
        completedAt: mapDateTime(json, r'completedAt', r'')!,
        totals: Totals.fromJson(json[r'totals'])!,
        lines: SaleLine.listFromJson(json[r'lines']),
        payment: Payment.fromJson(json[r'payment'])!,
      );
    }
    return null;
  }

  static List<Sale> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Sale>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Sale.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Sale> mapFromJson(dynamic json) {
    final map = <String, Sale>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Sale.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Sale-objects as value to a dart map
  static Map<String, List<Sale>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Sale>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Sale.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'orderId',
    'reference',
    'state',
    'currency',
    'currencyExponent',
    'timezone',
    'completedAt',
    'totals',
    'lines',
    'payment',
  };
}


enum SaleStateEnum {
  COMPLETED._(r'COMPLETED'),
  REVERSED._(r'REVERSED'),
  ;

  /// Instantiate a new enum with the provided value.
  const SaleStateEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [SaleStateEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static SaleStateEnum? fromJson(dynamic value) => SaleStateEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [SaleStateEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<SaleStateEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SaleStateEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SaleStateEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [SaleStateEnum] to String,
/// and [decode] dynamic data back to [SaleStateEnum].
class SaleStateEnumTypeTransformer {
  factory SaleStateEnumTypeTransformer() => _instance ??= const SaleStateEnumTypeTransformer._();

  const SaleStateEnumTypeTransformer._();

  String encode(SaleStateEnum data) => data._value;

  /// Returns the instance of [SaleStateEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  SaleStateEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is SaleStateEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'COMPLETED': return SaleStateEnum.COMPLETED;
        case r'REVERSED': return SaleStateEnum.REVERSED;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static SaleStateEnumTypeTransformer? _instance;
}


