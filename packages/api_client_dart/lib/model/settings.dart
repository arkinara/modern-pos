//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Settings {
  /// Returns a new [Settings] instance.
  Settings({
    required this.outletId,
    required this.outletName,
    required this.businessName,
    required this.currency,
    required this.currencyExponent,
    required this.timezone,
    required this.receiptHeader,
    required this.receiptFooter,
    required this.receiptAddress,
    required this.taxBps,
    required this.serviceBps,
    required this.pricingMode,
    required this.version,
  });

  String outletId;

  String outletName;

  String businessName;

  String currency;

  /// Minimum value: 0
  /// Maximum value: 3
  int currencyExponent;

  String timezone;

  String receiptHeader;

  String receiptFooter;

  String receiptAddress;

  /// Minimum value: 0
  /// Maximum value: 10000
  int taxBps;

  /// Minimum value: 0
  /// Maximum value: 10000
  int serviceBps;

  SettingsPricingModeEnum pricingMode;

  /// Minimum value: 1
  int version;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Settings &&
    other.outletId == outletId &&
    other.outletName == outletName &&
    other.businessName == businessName &&
    other.currency == currency &&
    other.currencyExponent == currencyExponent &&
    other.timezone == timezone &&
    other.receiptHeader == receiptHeader &&
    other.receiptFooter == receiptFooter &&
    other.receiptAddress == receiptAddress &&
    other.taxBps == taxBps &&
    other.serviceBps == serviceBps &&
    other.pricingMode == pricingMode &&
    other.version == version;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (outletId.hashCode) +
    (outletName.hashCode) +
    (businessName.hashCode) +
    (currency.hashCode) +
    (currencyExponent.hashCode) +
    (timezone.hashCode) +
    (receiptHeader.hashCode) +
    (receiptFooter.hashCode) +
    (receiptAddress.hashCode) +
    (taxBps.hashCode) +
    (serviceBps.hashCode) +
    (pricingMode.hashCode) +
    (version.hashCode);

  @override
  String toString() => 'Settings[outletId=$outletId, outletName=$outletName, businessName=$businessName, currency=$currency, currencyExponent=$currencyExponent, timezone=$timezone, receiptHeader=$receiptHeader, receiptFooter=$receiptFooter, receiptAddress=$receiptAddress, taxBps=$taxBps, serviceBps=$serviceBps, pricingMode=$pricingMode, version=$version]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'outletId'] = this.outletId;
      json[r'outletName'] = this.outletName;
      json[r'businessName'] = this.businessName;
      json[r'currency'] = this.currency;
      json[r'currencyExponent'] = this.currencyExponent;
      json[r'timezone'] = this.timezone;
      json[r'receiptHeader'] = this.receiptHeader;
      json[r'receiptFooter'] = this.receiptFooter;
      json[r'receiptAddress'] = this.receiptAddress;
      json[r'taxBps'] = this.taxBps;
      json[r'serviceBps'] = this.serviceBps;
      json[r'pricingMode'] = this.pricingMode;
      json[r'version'] = this.version;
    return json;
  }

  /// Returns a new [Settings] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Settings? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'outletId'), 'Required key "Settings[outletId]" is missing from JSON.');
        assert(json[r'outletId'] != null, 'Required key "Settings[outletId]" has a null value in JSON.');
        assert(json.containsKey(r'outletName'), 'Required key "Settings[outletName]" is missing from JSON.');
        assert(json[r'outletName'] != null, 'Required key "Settings[outletName]" has a null value in JSON.');
        assert(json.containsKey(r'businessName'), 'Required key "Settings[businessName]" is missing from JSON.');
        assert(json[r'businessName'] != null, 'Required key "Settings[businessName]" has a null value in JSON.');
        assert(json.containsKey(r'currency'), 'Required key "Settings[currency]" is missing from JSON.');
        assert(json[r'currency'] != null, 'Required key "Settings[currency]" has a null value in JSON.');
        assert(json.containsKey(r'currencyExponent'), 'Required key "Settings[currencyExponent]" is missing from JSON.');
        assert(json[r'currencyExponent'] != null, 'Required key "Settings[currencyExponent]" has a null value in JSON.');
        assert(json.containsKey(r'timezone'), 'Required key "Settings[timezone]" is missing from JSON.');
        assert(json[r'timezone'] != null, 'Required key "Settings[timezone]" has a null value in JSON.');
        assert(json.containsKey(r'receiptHeader'), 'Required key "Settings[receiptHeader]" is missing from JSON.');
        assert(json[r'receiptHeader'] != null, 'Required key "Settings[receiptHeader]" has a null value in JSON.');
        assert(json.containsKey(r'receiptFooter'), 'Required key "Settings[receiptFooter]" is missing from JSON.');
        assert(json[r'receiptFooter'] != null, 'Required key "Settings[receiptFooter]" has a null value in JSON.');
        assert(json.containsKey(r'receiptAddress'), 'Required key "Settings[receiptAddress]" is missing from JSON.');
        assert(json[r'receiptAddress'] != null, 'Required key "Settings[receiptAddress]" has a null value in JSON.');
        assert(json.containsKey(r'taxBps'), 'Required key "Settings[taxBps]" is missing from JSON.');
        assert(json[r'taxBps'] != null, 'Required key "Settings[taxBps]" has a null value in JSON.');
        assert(json.containsKey(r'serviceBps'), 'Required key "Settings[serviceBps]" is missing from JSON.');
        assert(json[r'serviceBps'] != null, 'Required key "Settings[serviceBps]" has a null value in JSON.');
        assert(json.containsKey(r'pricingMode'), 'Required key "Settings[pricingMode]" is missing from JSON.');
        assert(json[r'pricingMode'] != null, 'Required key "Settings[pricingMode]" has a null value in JSON.');
        assert(json.containsKey(r'version'), 'Required key "Settings[version]" is missing from JSON.');
        assert(json[r'version'] != null, 'Required key "Settings[version]" has a null value in JSON.');
        return true;
      }());

      return Settings(
        outletId: mapValueOfType<String>(json, r'outletId')!,
        outletName: mapValueOfType<String>(json, r'outletName')!,
        businessName: mapValueOfType<String>(json, r'businessName')!,
        currency: mapValueOfType<String>(json, r'currency')!,
        currencyExponent: mapValueOfType<int>(json, r'currencyExponent')!,
        timezone: mapValueOfType<String>(json, r'timezone')!,
        receiptHeader: mapValueOfType<String>(json, r'receiptHeader')!,
        receiptFooter: mapValueOfType<String>(json, r'receiptFooter')!,
        receiptAddress: mapValueOfType<String>(json, r'receiptAddress')!,
        taxBps: mapValueOfType<int>(json, r'taxBps')!,
        serviceBps: mapValueOfType<int>(json, r'serviceBps')!,
        pricingMode: SettingsPricingModeEnum.fromJson(json[r'pricingMode'])!,
        version: mapValueOfType<int>(json, r'version')!,
      );
    }
    return null;
  }

  static List<Settings> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Settings>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Settings.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Settings> mapFromJson(dynamic json) {
    final map = <String, Settings>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Settings.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Settings-objects as value to a dart map
  static Map<String, List<Settings>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Settings>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Settings.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'outletId',
    'outletName',
    'businessName',
    'currency',
    'currencyExponent',
    'timezone',
    'receiptHeader',
    'receiptFooter',
    'receiptAddress',
    'taxBps',
    'serviceBps',
    'pricingMode',
    'version',
  };
}


enum SettingsPricingModeEnum {
  EXCLUSIVE._(r'EXCLUSIVE'),
  ;

  /// Instantiate a new enum with the provided value.
  const SettingsPricingModeEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [SettingsPricingModeEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static SettingsPricingModeEnum? fromJson(dynamic value) => SettingsPricingModeEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [SettingsPricingModeEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<SettingsPricingModeEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SettingsPricingModeEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SettingsPricingModeEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [SettingsPricingModeEnum] to String,
/// and [decode] dynamic data back to [SettingsPricingModeEnum].
class SettingsPricingModeEnumTypeTransformer {
  factory SettingsPricingModeEnumTypeTransformer() => _instance ??= const SettingsPricingModeEnumTypeTransformer._();

  const SettingsPricingModeEnumTypeTransformer._();

  String encode(SettingsPricingModeEnum data) => data._value;

  /// Returns the instance of [SettingsPricingModeEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  SettingsPricingModeEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is SettingsPricingModeEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'EXCLUSIVE': return SettingsPricingModeEnum.EXCLUSIVE;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static SettingsPricingModeEnumTypeTransformer? _instance;
}


