//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CustomerRetentionPolicy {
  /// Returns a new [CustomerRetentionPolicy] instance.
  CustomerRetentionPolicy({
    required this.outletId,
    required this.customerRetentionDays,
    required this.receiptRetentionDays,
    required this.receiptLinkTtlMinutes,
    required this.version,
    required this.updatedAt,
    required this.defaults,
  });

  String outletId;

  int customerRetentionDays;

  int receiptRetentionDays;

  int receiptLinkTtlMinutes;

  int version;

  DateTime? updatedAt;

  bool defaults;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CustomerRetentionPolicy &&
    other.outletId == outletId &&
    other.customerRetentionDays == customerRetentionDays &&
    other.receiptRetentionDays == receiptRetentionDays &&
    other.receiptLinkTtlMinutes == receiptLinkTtlMinutes &&
    other.version == version &&
    other.updatedAt == updatedAt &&
    other.defaults == defaults;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (outletId.hashCode) +
    (customerRetentionDays.hashCode) +
    (receiptRetentionDays.hashCode) +
    (receiptLinkTtlMinutes.hashCode) +
    (version.hashCode) +
    (updatedAt == null ? 0 : updatedAt!.hashCode) +
    (defaults.hashCode);

  @override
  String toString() => 'CustomerRetentionPolicy[outletId=$outletId, customerRetentionDays=$customerRetentionDays, receiptRetentionDays=$receiptRetentionDays, receiptLinkTtlMinutes=$receiptLinkTtlMinutes, version=$version, updatedAt=$updatedAt, defaults=$defaults]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'outletId'] = this.outletId;
      json[r'customerRetentionDays'] = this.customerRetentionDays;
      json[r'receiptRetentionDays'] = this.receiptRetentionDays;
      json[r'receiptLinkTtlMinutes'] = this.receiptLinkTtlMinutes;
      json[r'version'] = this.version;
    if (this.updatedAt != null) {
      json[r'updatedAt'] = this.updatedAt!.toUtc().toIso8601String();
    } else {
      json[r'updatedAt'] = null;
    }
      json[r'defaults'] = this.defaults;
    return json;
  }

  /// Returns a new [CustomerRetentionPolicy] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CustomerRetentionPolicy? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'outletId'), 'Required key "CustomerRetentionPolicy[outletId]" is missing from JSON.');
        assert(json[r'outletId'] != null, 'Required key "CustomerRetentionPolicy[outletId]" has a null value in JSON.');
        assert(json.containsKey(r'customerRetentionDays'), 'Required key "CustomerRetentionPolicy[customerRetentionDays]" is missing from JSON.');
        assert(json[r'customerRetentionDays'] != null, 'Required key "CustomerRetentionPolicy[customerRetentionDays]" has a null value in JSON.');
        assert(json.containsKey(r'receiptRetentionDays'), 'Required key "CustomerRetentionPolicy[receiptRetentionDays]" is missing from JSON.');
        assert(json[r'receiptRetentionDays'] != null, 'Required key "CustomerRetentionPolicy[receiptRetentionDays]" has a null value in JSON.');
        assert(json.containsKey(r'receiptLinkTtlMinutes'), 'Required key "CustomerRetentionPolicy[receiptLinkTtlMinutes]" is missing from JSON.');
        assert(json[r'receiptLinkTtlMinutes'] != null, 'Required key "CustomerRetentionPolicy[receiptLinkTtlMinutes]" has a null value in JSON.');
        assert(json.containsKey(r'version'), 'Required key "CustomerRetentionPolicy[version]" is missing from JSON.');
        assert(json[r'version'] != null, 'Required key "CustomerRetentionPolicy[version]" has a null value in JSON.');
        assert(json.containsKey(r'updatedAt'), 'Required key "CustomerRetentionPolicy[updatedAt]" is missing from JSON.');
        assert(json.containsKey(r'defaults'), 'Required key "CustomerRetentionPolicy[defaults]" is missing from JSON.');
        assert(json[r'defaults'] != null, 'Required key "CustomerRetentionPolicy[defaults]" has a null value in JSON.');
        return true;
      }());

      return CustomerRetentionPolicy(
        outletId: mapValueOfType<String>(json, r'outletId')!,
        customerRetentionDays: mapValueOfType<int>(json, r'customerRetentionDays')!,
        receiptRetentionDays: mapValueOfType<int>(json, r'receiptRetentionDays')!,
        receiptLinkTtlMinutes: mapValueOfType<int>(json, r'receiptLinkTtlMinutes')!,
        version: mapValueOfType<int>(json, r'version')!,
        updatedAt: mapDateTime(json, r'updatedAt', r''),
        defaults: mapValueOfType<bool>(json, r'defaults')!,
      );
    }
    return null;
  }

  static List<CustomerRetentionPolicy> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CustomerRetentionPolicy>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CustomerRetentionPolicy.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CustomerRetentionPolicy> mapFromJson(dynamic json) {
    final map = <String, CustomerRetentionPolicy>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CustomerRetentionPolicy.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CustomerRetentionPolicy-objects as value to a dart map
  static Map<String, List<CustomerRetentionPolicy>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CustomerRetentionPolicy>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CustomerRetentionPolicy.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'outletId',
    'customerRetentionDays',
    'receiptRetentionDays',
    'receiptLinkTtlMinutes',
    'version',
    'updatedAt',
    'defaults',
  };
}

