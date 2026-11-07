//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class OutletUpdate {
  /// Returns a new [OutletUpdate] instance.
  OutletUpdate({
    required this.name,
    required this.timezone,
    required this.receiptAddress,
    required this.taxBps,
    required this.serviceBps,
    required this.version,
  });

  String name;

  String timezone;

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
  bool operator ==(Object other) => identical(this, other) || other is OutletUpdate &&
    other.name == name &&
    other.timezone == timezone &&
    other.receiptAddress == receiptAddress &&
    other.taxBps == taxBps &&
    other.serviceBps == serviceBps &&
    other.version == version;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (name.hashCode) +
    (timezone.hashCode) +
    (receiptAddress.hashCode) +
    (taxBps.hashCode) +
    (serviceBps.hashCode) +
    (version.hashCode);

  @override
  String toString() => 'OutletUpdate[name=$name, timezone=$timezone, receiptAddress=$receiptAddress, taxBps=$taxBps, serviceBps=$serviceBps, version=$version]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'name'] = this.name;
      json[r'timezone'] = this.timezone;
      json[r'receiptAddress'] = this.receiptAddress;
      json[r'taxBps'] = this.taxBps;
      json[r'serviceBps'] = this.serviceBps;
      json[r'version'] = this.version;
    return json;
  }

  /// Returns a new [OutletUpdate] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static OutletUpdate? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'name'), 'Required key "OutletUpdate[name]" is missing from JSON.');
        assert(json[r'name'] != null, 'Required key "OutletUpdate[name]" has a null value in JSON.');
        assert(json.containsKey(r'timezone'), 'Required key "OutletUpdate[timezone]" is missing from JSON.');
        assert(json[r'timezone'] != null, 'Required key "OutletUpdate[timezone]" has a null value in JSON.');
        assert(json.containsKey(r'receiptAddress'), 'Required key "OutletUpdate[receiptAddress]" is missing from JSON.');
        assert(json[r'receiptAddress'] != null, 'Required key "OutletUpdate[receiptAddress]" has a null value in JSON.');
        assert(json.containsKey(r'taxBps'), 'Required key "OutletUpdate[taxBps]" is missing from JSON.');
        assert(json[r'taxBps'] != null, 'Required key "OutletUpdate[taxBps]" has a null value in JSON.');
        assert(json.containsKey(r'serviceBps'), 'Required key "OutletUpdate[serviceBps]" is missing from JSON.');
        assert(json[r'serviceBps'] != null, 'Required key "OutletUpdate[serviceBps]" has a null value in JSON.');
        assert(json.containsKey(r'version'), 'Required key "OutletUpdate[version]" is missing from JSON.');
        assert(json[r'version'] != null, 'Required key "OutletUpdate[version]" has a null value in JSON.');
        return true;
      }());

      return OutletUpdate(
        name: mapValueOfType<String>(json, r'name')!,
        timezone: mapValueOfType<String>(json, r'timezone')!,
        receiptAddress: mapValueOfType<String>(json, r'receiptAddress')!,
        taxBps: mapValueOfType<int>(json, r'taxBps')!,
        serviceBps: mapValueOfType<int>(json, r'serviceBps')!,
        version: mapValueOfType<int>(json, r'version')!,
      );
    }
    return null;
  }

  static List<OutletUpdate> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <OutletUpdate>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = OutletUpdate.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, OutletUpdate> mapFromJson(dynamic json) {
    final map = <String, OutletUpdate>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = OutletUpdate.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of OutletUpdate-objects as value to a dart map
  static Map<String, List<OutletUpdate>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<OutletUpdate>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = OutletUpdate.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'name',
    'timezone',
    'receiptAddress',
    'taxBps',
    'serviceBps',
    'version',
  };
}

