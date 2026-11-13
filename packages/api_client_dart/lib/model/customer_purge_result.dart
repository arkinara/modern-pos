//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CustomerPurgeResult {
  /// Returns a new [CustomerPurgeResult] instance.
  CustomerPurgeResult({
    required this.ranAt,
    required this.customersAnonymised,
    required this.receiptsPurged,
    required this.policy,
  });

  DateTime ranAt;

  int customersAnonymised;

  int receiptsPurged;

  CustomerRetentionPolicy policy;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CustomerPurgeResult &&
    other.ranAt == ranAt &&
    other.customersAnonymised == customersAnonymised &&
    other.receiptsPurged == receiptsPurged &&
    other.policy == policy;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (ranAt.hashCode) +
    (customersAnonymised.hashCode) +
    (receiptsPurged.hashCode) +
    (policy.hashCode);

  @override
  String toString() => 'CustomerPurgeResult[ranAt=$ranAt, customersAnonymised=$customersAnonymised, receiptsPurged=$receiptsPurged, policy=$policy]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'ranAt'] = this.ranAt.toUtc().toIso8601String();
      json[r'customersAnonymised'] = this.customersAnonymised;
      json[r'receiptsPurged'] = this.receiptsPurged;
      json[r'policy'] = this.policy;
    return json;
  }

  /// Returns a new [CustomerPurgeResult] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CustomerPurgeResult? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'ranAt'), 'Required key "CustomerPurgeResult[ranAt]" is missing from JSON.');
        assert(json[r'ranAt'] != null, 'Required key "CustomerPurgeResult[ranAt]" has a null value in JSON.');
        assert(json.containsKey(r'customersAnonymised'), 'Required key "CustomerPurgeResult[customersAnonymised]" is missing from JSON.');
        assert(json[r'customersAnonymised'] != null, 'Required key "CustomerPurgeResult[customersAnonymised]" has a null value in JSON.');
        assert(json.containsKey(r'receiptsPurged'), 'Required key "CustomerPurgeResult[receiptsPurged]" is missing from JSON.');
        assert(json[r'receiptsPurged'] != null, 'Required key "CustomerPurgeResult[receiptsPurged]" has a null value in JSON.');
        assert(json.containsKey(r'policy'), 'Required key "CustomerPurgeResult[policy]" is missing from JSON.');
        assert(json[r'policy'] != null, 'Required key "CustomerPurgeResult[policy]" has a null value in JSON.');
        return true;
      }());

      return CustomerPurgeResult(
        ranAt: mapDateTime(json, r'ranAt', r'')!,
        customersAnonymised: mapValueOfType<int>(json, r'customersAnonymised')!,
        receiptsPurged: mapValueOfType<int>(json, r'receiptsPurged')!,
        policy: CustomerRetentionPolicy.fromJson(json[r'policy'])!,
      );
    }
    return null;
  }

  static List<CustomerPurgeResult> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CustomerPurgeResult>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CustomerPurgeResult.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CustomerPurgeResult> mapFromJson(dynamic json) {
    final map = <String, CustomerPurgeResult>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CustomerPurgeResult.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CustomerPurgeResult-objects as value to a dart map
  static Map<String, List<CustomerPurgeResult>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CustomerPurgeResult>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CustomerPurgeResult.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'ranAt',
    'customersAnonymised',
    'receiptsPurged',
    'policy',
  };
}

