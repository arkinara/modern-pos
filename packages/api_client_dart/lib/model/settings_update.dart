//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class SettingsUpdate {
  /// Returns a new [SettingsUpdate] instance.
  SettingsUpdate({
    required this.businessName,
    required this.currency,
    required this.timezone,
    required this.receiptHeader,
    required this.receiptFooter,
    required this.receiptAddress,
    required this.taxBps,
    required this.serviceBps,
    required this.version,
  });

  String businessName;

  String currency;

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

  /// Minimum value: 1
  int version;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SettingsUpdate &&
    other.businessName == businessName &&
    other.currency == currency &&
    other.timezone == timezone &&
    other.receiptHeader == receiptHeader &&
    other.receiptFooter == receiptFooter &&
    other.receiptAddress == receiptAddress &&
    other.taxBps == taxBps &&
    other.serviceBps == serviceBps &&
    other.version == version;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (businessName.hashCode) +
    (currency.hashCode) +
    (timezone.hashCode) +
    (receiptHeader.hashCode) +
    (receiptFooter.hashCode) +
    (receiptAddress.hashCode) +
    (taxBps.hashCode) +
    (serviceBps.hashCode) +
    (version.hashCode);

  @override
  String toString() => 'SettingsUpdate[businessName=$businessName, currency=$currency, timezone=$timezone, receiptHeader=$receiptHeader, receiptFooter=$receiptFooter, receiptAddress=$receiptAddress, taxBps=$taxBps, serviceBps=$serviceBps, version=$version]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'businessName'] = this.businessName;
      json[r'currency'] = this.currency;
      json[r'timezone'] = this.timezone;
      json[r'receiptHeader'] = this.receiptHeader;
      json[r'receiptFooter'] = this.receiptFooter;
      json[r'receiptAddress'] = this.receiptAddress;
      json[r'taxBps'] = this.taxBps;
      json[r'serviceBps'] = this.serviceBps;
      json[r'version'] = this.version;
    return json;
  }

  /// Returns a new [SettingsUpdate] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SettingsUpdate? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'businessName'), 'Required key "SettingsUpdate[businessName]" is missing from JSON.');
        assert(json[r'businessName'] != null, 'Required key "SettingsUpdate[businessName]" has a null value in JSON.');
        assert(json.containsKey(r'currency'), 'Required key "SettingsUpdate[currency]" is missing from JSON.');
        assert(json[r'currency'] != null, 'Required key "SettingsUpdate[currency]" has a null value in JSON.');
        assert(json.containsKey(r'timezone'), 'Required key "SettingsUpdate[timezone]" is missing from JSON.');
        assert(json[r'timezone'] != null, 'Required key "SettingsUpdate[timezone]" has a null value in JSON.');
        assert(json.containsKey(r'receiptHeader'), 'Required key "SettingsUpdate[receiptHeader]" is missing from JSON.');
        assert(json[r'receiptHeader'] != null, 'Required key "SettingsUpdate[receiptHeader]" has a null value in JSON.');
        assert(json.containsKey(r'receiptFooter'), 'Required key "SettingsUpdate[receiptFooter]" is missing from JSON.');
        assert(json[r'receiptFooter'] != null, 'Required key "SettingsUpdate[receiptFooter]" has a null value in JSON.');
        assert(json.containsKey(r'receiptAddress'), 'Required key "SettingsUpdate[receiptAddress]" is missing from JSON.');
        assert(json[r'receiptAddress'] != null, 'Required key "SettingsUpdate[receiptAddress]" has a null value in JSON.');
        assert(json.containsKey(r'taxBps'), 'Required key "SettingsUpdate[taxBps]" is missing from JSON.');
        assert(json[r'taxBps'] != null, 'Required key "SettingsUpdate[taxBps]" has a null value in JSON.');
        assert(json.containsKey(r'serviceBps'), 'Required key "SettingsUpdate[serviceBps]" is missing from JSON.');
        assert(json[r'serviceBps'] != null, 'Required key "SettingsUpdate[serviceBps]" has a null value in JSON.');
        assert(json.containsKey(r'version'), 'Required key "SettingsUpdate[version]" is missing from JSON.');
        assert(json[r'version'] != null, 'Required key "SettingsUpdate[version]" has a null value in JSON.');
        return true;
      }());

      return SettingsUpdate(
        businessName: mapValueOfType<String>(json, r'businessName')!,
        currency: mapValueOfType<String>(json, r'currency')!,
        timezone: mapValueOfType<String>(json, r'timezone')!,
        receiptHeader: mapValueOfType<String>(json, r'receiptHeader')!,
        receiptFooter: mapValueOfType<String>(json, r'receiptFooter')!,
        receiptAddress: mapValueOfType<String>(json, r'receiptAddress')!,
        taxBps: mapValueOfType<int>(json, r'taxBps')!,
        serviceBps: mapValueOfType<int>(json, r'serviceBps')!,
        version: mapValueOfType<int>(json, r'version')!,
      );
    }
    return null;
  }

  static List<SettingsUpdate> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SettingsUpdate>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SettingsUpdate.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SettingsUpdate> mapFromJson(dynamic json) {
    final map = <String, SettingsUpdate>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SettingsUpdate.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SettingsUpdate-objects as value to a dart map
  static Map<String, List<SettingsUpdate>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SettingsUpdate>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SettingsUpdate.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'businessName',
    'currency',
    'timezone',
    'receiptHeader',
    'receiptFooter',
    'receiptAddress',
    'taxBps',
    'serviceBps',
    'version',
  };
}

