//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CustomerRetentionPolicyUpdate {
  /// Returns a new [CustomerRetentionPolicyUpdate] instance.
  CustomerRetentionPolicyUpdate({
    required this.customerRetentionDays,
    required this.receiptRetentionDays,
    required this.receiptLinkTtlMinutes,
  });

  /// Minimum value: 1
  /// Maximum value: 3650
  int customerRetentionDays;

  /// Minimum value: 1
  /// Maximum value: 3650
  int receiptRetentionDays;

  /// Minimum value: 1
  /// Maximum value: 10080
  int receiptLinkTtlMinutes;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CustomerRetentionPolicyUpdate &&
    other.customerRetentionDays == customerRetentionDays &&
    other.receiptRetentionDays == receiptRetentionDays &&
    other.receiptLinkTtlMinutes == receiptLinkTtlMinutes;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (customerRetentionDays.hashCode) +
    (receiptRetentionDays.hashCode) +
    (receiptLinkTtlMinutes.hashCode);

  @override
  String toString() => 'CustomerRetentionPolicyUpdate[customerRetentionDays=$customerRetentionDays, receiptRetentionDays=$receiptRetentionDays, receiptLinkTtlMinutes=$receiptLinkTtlMinutes]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'customerRetentionDays'] = this.customerRetentionDays;
      json[r'receiptRetentionDays'] = this.receiptRetentionDays;
      json[r'receiptLinkTtlMinutes'] = this.receiptLinkTtlMinutes;
    return json;
  }

  /// Returns a new [CustomerRetentionPolicyUpdate] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CustomerRetentionPolicyUpdate? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'customerRetentionDays'), 'Required key "CustomerRetentionPolicyUpdate[customerRetentionDays]" is missing from JSON.');
        assert(json[r'customerRetentionDays'] != null, 'Required key "CustomerRetentionPolicyUpdate[customerRetentionDays]" has a null value in JSON.');
        assert(json.containsKey(r'receiptRetentionDays'), 'Required key "CustomerRetentionPolicyUpdate[receiptRetentionDays]" is missing from JSON.');
        assert(json[r'receiptRetentionDays'] != null, 'Required key "CustomerRetentionPolicyUpdate[receiptRetentionDays]" has a null value in JSON.');
        assert(json.containsKey(r'receiptLinkTtlMinutes'), 'Required key "CustomerRetentionPolicyUpdate[receiptLinkTtlMinutes]" is missing from JSON.');
        assert(json[r'receiptLinkTtlMinutes'] != null, 'Required key "CustomerRetentionPolicyUpdate[receiptLinkTtlMinutes]" has a null value in JSON.');
        return true;
      }());

      return CustomerRetentionPolicyUpdate(
        customerRetentionDays: mapValueOfType<int>(json, r'customerRetentionDays')!,
        receiptRetentionDays: mapValueOfType<int>(json, r'receiptRetentionDays')!,
        receiptLinkTtlMinutes: mapValueOfType<int>(json, r'receiptLinkTtlMinutes')!,
      );
    }
    return null;
  }

  static List<CustomerRetentionPolicyUpdate> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CustomerRetentionPolicyUpdate>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CustomerRetentionPolicyUpdate.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CustomerRetentionPolicyUpdate> mapFromJson(dynamic json) {
    final map = <String, CustomerRetentionPolicyUpdate>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CustomerRetentionPolicyUpdate.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CustomerRetentionPolicyUpdate-objects as value to a dart map
  static Map<String, List<CustomerRetentionPolicyUpdate>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CustomerRetentionPolicyUpdate>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CustomerRetentionPolicyUpdate.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'customerRetentionDays',
    'receiptRetentionDays',
    'receiptLinkTtlMinutes',
  };
}

