//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Outlet {
  /// Returns a new [Outlet] instance.
  Outlet({
    required this.id,
    required this.name,
    required this.currency,
    required this.currencyExponent,
    required this.timezone,
    required this.receiptAddress,
    required this.taxBps,
    required this.serviceBps,
    required this.pricingMode,
    required this.version,
  });

  String id;

  String name;

  String currency;

  /// Minimum value: 0
  /// Maximum value: 3
  int currencyExponent;

  String timezone;

  String receiptAddress;

  /// Minimum value: 0
  /// Maximum value: 10000
  int taxBps;

  /// Minimum value: 0
  /// Maximum value: 10000
  int serviceBps;

  OutletPricingModeEnum pricingMode;

  /// Minimum value: 1
  int version;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Outlet &&
    other.id == id &&
    other.name == name &&
    other.currency == currency &&
    other.currencyExponent == currencyExponent &&
    other.timezone == timezone &&
    other.receiptAddress == receiptAddress &&
    other.taxBps == taxBps &&
    other.serviceBps == serviceBps &&
    other.pricingMode == pricingMode &&
    other.version == version;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (name.hashCode) +
    (currency.hashCode) +
    (currencyExponent.hashCode) +
    (timezone.hashCode) +
    (receiptAddress.hashCode) +
    (taxBps.hashCode) +
    (serviceBps.hashCode) +
    (pricingMode.hashCode) +
    (version.hashCode);

  @override
  String toString() => 'Outlet[id=$id, name=$name, currency=$currency, currencyExponent=$currencyExponent, timezone=$timezone, receiptAddress=$receiptAddress, taxBps=$taxBps, serviceBps=$serviceBps, pricingMode=$pricingMode, version=$version]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'name'] = this.name;
      json[r'currency'] = this.currency;
      json[r'currencyExponent'] = this.currencyExponent;
      json[r'timezone'] = this.timezone;
      json[r'receiptAddress'] = this.receiptAddress;
      json[r'taxBps'] = this.taxBps;
      json[r'serviceBps'] = this.serviceBps;
      json[r'pricingMode'] = this.pricingMode;
      json[r'version'] = this.version;
    return json;
  }

  /// Returns a new [Outlet] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Outlet? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "Outlet[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "Outlet[id]" has a null value in JSON.');
        assert(json.containsKey(r'name'), 'Required key "Outlet[name]" is missing from JSON.');
        assert(json[r'name'] != null, 'Required key "Outlet[name]" has a null value in JSON.');
        assert(json.containsKey(r'currency'), 'Required key "Outlet[currency]" is missing from JSON.');
        assert(json[r'currency'] != null, 'Required key "Outlet[currency]" has a null value in JSON.');
        assert(json.containsKey(r'currencyExponent'), 'Required key "Outlet[currencyExponent]" is missing from JSON.');
        assert(json[r'currencyExponent'] != null, 'Required key "Outlet[currencyExponent]" has a null value in JSON.');
        assert(json.containsKey(r'timezone'), 'Required key "Outlet[timezone]" is missing from JSON.');
        assert(json[r'timezone'] != null, 'Required key "Outlet[timezone]" has a null value in JSON.');
        assert(json.containsKey(r'receiptAddress'), 'Required key "Outlet[receiptAddress]" is missing from JSON.');
        assert(json[r'receiptAddress'] != null, 'Required key "Outlet[receiptAddress]" has a null value in JSON.');
        assert(json.containsKey(r'taxBps'), 'Required key "Outlet[taxBps]" is missing from JSON.');
        assert(json[r'taxBps'] != null, 'Required key "Outlet[taxBps]" has a null value in JSON.');
        assert(json.containsKey(r'serviceBps'), 'Required key "Outlet[serviceBps]" is missing from JSON.');
        assert(json[r'serviceBps'] != null, 'Required key "Outlet[serviceBps]" has a null value in JSON.');
        assert(json.containsKey(r'pricingMode'), 'Required key "Outlet[pricingMode]" is missing from JSON.');
        assert(json[r'pricingMode'] != null, 'Required key "Outlet[pricingMode]" has a null value in JSON.');
        assert(json.containsKey(r'version'), 'Required key "Outlet[version]" is missing from JSON.');
        assert(json[r'version'] != null, 'Required key "Outlet[version]" has a null value in JSON.');
        return true;
      }());

      return Outlet(
        id: mapValueOfType<String>(json, r'id')!,
        name: mapValueOfType<String>(json, r'name')!,
        currency: mapValueOfType<String>(json, r'currency')!,
        currencyExponent: mapValueOfType<int>(json, r'currencyExponent')!,
        timezone: mapValueOfType<String>(json, r'timezone')!,
        receiptAddress: mapValueOfType<String>(json, r'receiptAddress')!,
        taxBps: mapValueOfType<int>(json, r'taxBps')!,
        serviceBps: mapValueOfType<int>(json, r'serviceBps')!,
        pricingMode: OutletPricingModeEnum.fromJson(json[r'pricingMode'])!,
        version: mapValueOfType<int>(json, r'version')!,
      );
    }
    return null;
  }

  static List<Outlet> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Outlet>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Outlet.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Outlet> mapFromJson(dynamic json) {
    final map = <String, Outlet>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Outlet.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Outlet-objects as value to a dart map
  static Map<String, List<Outlet>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Outlet>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Outlet.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'name',
    'currency',
    'currencyExponent',
    'timezone',
    'receiptAddress',
    'taxBps',
    'serviceBps',
    'pricingMode',
    'version',
  };
}


enum OutletPricingModeEnum {
  EXCLUSIVE._(r'EXCLUSIVE'),
  ;

  /// Instantiate a new enum with the provided value.
  const OutletPricingModeEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [OutletPricingModeEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static OutletPricingModeEnum? fromJson(dynamic value) => OutletPricingModeEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [OutletPricingModeEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<OutletPricingModeEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <OutletPricingModeEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = OutletPricingModeEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [OutletPricingModeEnum] to String,
/// and [decode] dynamic data back to [OutletPricingModeEnum].
class OutletPricingModeEnumTypeTransformer {
  factory OutletPricingModeEnumTypeTransformer() => _instance ??= const OutletPricingModeEnumTypeTransformer._();

  const OutletPricingModeEnumTypeTransformer._();

  String encode(OutletPricingModeEnum data) => data._value;

  /// Returns the instance of [OutletPricingModeEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  OutletPricingModeEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is OutletPricingModeEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'EXCLUSIVE': return OutletPricingModeEnum.EXCLUSIVE;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static OutletPricingModeEnumTypeTransformer? _instance;
}


