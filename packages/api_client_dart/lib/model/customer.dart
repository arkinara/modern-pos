//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Customer {
  /// Returns a new [Customer] instance.
  Customer({
    required this.id,
    required this.outletId,
    required this.name,
    required this.email,
    required this.phone,
    required this.consentAt,
    required this.consentSource,
    required this.anonymizedAt,
    required this.createdAt,
  });

  String id;

  String outletId;

  String name;

  String? email;

  String? phone;

  DateTime consentAt;

  String consentSource;

  DateTime? anonymizedAt;

  DateTime createdAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Customer &&
    other.id == id &&
    other.outletId == outletId &&
    other.name == name &&
    other.email == email &&
    other.phone == phone &&
    other.consentAt == consentAt &&
    other.consentSource == consentSource &&
    other.anonymizedAt == anonymizedAt &&
    other.createdAt == createdAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (outletId.hashCode) +
    (name.hashCode) +
    (email == null ? 0 : email!.hashCode) +
    (phone == null ? 0 : phone!.hashCode) +
    (consentAt.hashCode) +
    (consentSource.hashCode) +
    (anonymizedAt == null ? 0 : anonymizedAt!.hashCode) +
    (createdAt.hashCode);

  @override
  String toString() => 'Customer[id=$id, outletId=$outletId, name=$name, email=$email, phone=$phone, consentAt=$consentAt, consentSource=$consentSource, anonymizedAt=$anonymizedAt, createdAt=$createdAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'outletId'] = this.outletId;
      json[r'name'] = this.name;
    if (this.email != null) {
      json[r'email'] = this.email;
    } else {
      json[r'email'] = null;
    }
    if (this.phone != null) {
      json[r'phone'] = this.phone;
    } else {
      json[r'phone'] = null;
    }
      json[r'consentAt'] = this.consentAt.toUtc().toIso8601String();
      json[r'consentSource'] = this.consentSource;
    if (this.anonymizedAt != null) {
      json[r'anonymizedAt'] = this.anonymizedAt!.toUtc().toIso8601String();
    } else {
      json[r'anonymizedAt'] = null;
    }
      json[r'createdAt'] = this.createdAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [Customer] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Customer? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "Customer[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "Customer[id]" has a null value in JSON.');
        assert(json.containsKey(r'outletId'), 'Required key "Customer[outletId]" is missing from JSON.');
        assert(json[r'outletId'] != null, 'Required key "Customer[outletId]" has a null value in JSON.');
        assert(json.containsKey(r'name'), 'Required key "Customer[name]" is missing from JSON.');
        assert(json[r'name'] != null, 'Required key "Customer[name]" has a null value in JSON.');
        assert(json.containsKey(r'email'), 'Required key "Customer[email]" is missing from JSON.');
        assert(json.containsKey(r'phone'), 'Required key "Customer[phone]" is missing from JSON.');
        assert(json.containsKey(r'consentAt'), 'Required key "Customer[consentAt]" is missing from JSON.');
        assert(json[r'consentAt'] != null, 'Required key "Customer[consentAt]" has a null value in JSON.');
        assert(json.containsKey(r'consentSource'), 'Required key "Customer[consentSource]" is missing from JSON.');
        assert(json[r'consentSource'] != null, 'Required key "Customer[consentSource]" has a null value in JSON.');
        assert(json.containsKey(r'anonymizedAt'), 'Required key "Customer[anonymizedAt]" is missing from JSON.');
        assert(json.containsKey(r'createdAt'), 'Required key "Customer[createdAt]" is missing from JSON.');
        assert(json[r'createdAt'] != null, 'Required key "Customer[createdAt]" has a null value in JSON.');
        return true;
      }());

      return Customer(
        id: mapValueOfType<String>(json, r'id')!,
        outletId: mapValueOfType<String>(json, r'outletId')!,
        name: mapValueOfType<String>(json, r'name')!,
        email: mapValueOfType<String>(json, r'email'),
        phone: mapValueOfType<String>(json, r'phone'),
        consentAt: mapDateTime(json, r'consentAt', r'')!,
        consentSource: mapValueOfType<String>(json, r'consentSource')!,
        anonymizedAt: mapDateTime(json, r'anonymizedAt', r''),
        createdAt: mapDateTime(json, r'createdAt', r'')!,
      );
    }
    return null;
  }

  static List<Customer> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Customer>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Customer.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Customer> mapFromJson(dynamic json) {
    final map = <String, Customer>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Customer.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Customer-objects as value to a dart map
  static Map<String, List<Customer>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Customer>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Customer.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'outletId',
    'name',
    'email',
    'phone',
    'consentAt',
    'consentSource',
    'anonymizedAt',
    'createdAt',
  };
}

