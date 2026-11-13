//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CustomerWrite {
  /// Returns a new [CustomerWrite] instance.
  CustomerWrite({
    required this.name,
    required this.contact,
    required this.contactType,
    required this.consent,
    required this.consentSource,
  });

  String name;

  String contact;

  CustomerWriteContactTypeEnum contactType;

  bool consent;

  CustomerWriteConsentSourceEnum consentSource;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CustomerWrite &&
    other.name == name &&
    other.contact == contact &&
    other.contactType == contactType &&
    other.consent == consent &&
    other.consentSource == consentSource;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (name.hashCode) +
    (contact.hashCode) +
    (contactType.hashCode) +
    (consent.hashCode) +
    (consentSource.hashCode);

  @override
  String toString() => 'CustomerWrite[name=$name, contact=$contact, contactType=$contactType, consent=$consent, consentSource=$consentSource]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'name'] = this.name;
      json[r'contact'] = this.contact;
      json[r'contactType'] = this.contactType;
      json[r'consent'] = this.consent;
      json[r'consentSource'] = this.consentSource;
    return json;
  }

  /// Returns a new [CustomerWrite] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CustomerWrite? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'name'), 'Required key "CustomerWrite[name]" is missing from JSON.');
        assert(json[r'name'] != null, 'Required key "CustomerWrite[name]" has a null value in JSON.');
        assert(json.containsKey(r'contact'), 'Required key "CustomerWrite[contact]" is missing from JSON.');
        assert(json[r'contact'] != null, 'Required key "CustomerWrite[contact]" has a null value in JSON.');
        assert(json.containsKey(r'contactType'), 'Required key "CustomerWrite[contactType]" is missing from JSON.');
        assert(json[r'contactType'] != null, 'Required key "CustomerWrite[contactType]" has a null value in JSON.');
        assert(json.containsKey(r'consent'), 'Required key "CustomerWrite[consent]" is missing from JSON.');
        assert(json[r'consent'] != null, 'Required key "CustomerWrite[consent]" has a null value in JSON.');
        assert(json.containsKey(r'consentSource'), 'Required key "CustomerWrite[consentSource]" is missing from JSON.');
        assert(json[r'consentSource'] != null, 'Required key "CustomerWrite[consentSource]" has a null value in JSON.');
        return true;
      }());

      return CustomerWrite(
        name: mapValueOfType<String>(json, r'name')!,
        contact: mapValueOfType<String>(json, r'contact')!,
        contactType: CustomerWriteContactTypeEnum.fromJson(json[r'contactType'])!,
        consent: mapValueOfType<bool>(json, r'consent')!,
        consentSource: CustomerWriteConsentSourceEnum.fromJson(json[r'consentSource'])!,
      );
    }
    return null;
  }

  static List<CustomerWrite> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CustomerWrite>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CustomerWrite.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CustomerWrite> mapFromJson(dynamic json) {
    final map = <String, CustomerWrite>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CustomerWrite.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CustomerWrite-objects as value to a dart map
  static Map<String, List<CustomerWrite>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CustomerWrite>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CustomerWrite.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'name',
    'contact',
    'contactType',
    'consent',
    'consentSource',
  };
}


enum CustomerWriteContactTypeEnum {
  EMAIL._(r'EMAIL'),
  PHONE._(r'PHONE'),
  ;

  /// Instantiate a new enum with the provided value.
  const CustomerWriteContactTypeEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [CustomerWriteContactTypeEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static CustomerWriteContactTypeEnum? fromJson(dynamic value) => CustomerWriteContactTypeEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [CustomerWriteContactTypeEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<CustomerWriteContactTypeEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CustomerWriteContactTypeEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CustomerWriteContactTypeEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [CustomerWriteContactTypeEnum] to String,
/// and [decode] dynamic data back to [CustomerWriteContactTypeEnum].
class CustomerWriteContactTypeEnumTypeTransformer {
  factory CustomerWriteContactTypeEnumTypeTransformer() => _instance ??= const CustomerWriteContactTypeEnumTypeTransformer._();

  const CustomerWriteContactTypeEnumTypeTransformer._();

  String encode(CustomerWriteContactTypeEnum data) => data._value;

  /// Returns the instance of [CustomerWriteContactTypeEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  CustomerWriteContactTypeEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is CustomerWriteContactTypeEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'EMAIL': return CustomerWriteContactTypeEnum.EMAIL;
        case r'PHONE': return CustomerWriteContactTypeEnum.PHONE;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static CustomerWriteContactTypeEnumTypeTransformer? _instance;
}



enum CustomerWriteConsentSourceEnum {
  WEB_CHECKOUT._(r'WEB_CHECKOUT'),
  STAFF_ENTRY._(r'STAFF_ENTRY'),
  IMPORT._(r'IMPORT'),
  ;

  /// Instantiate a new enum with the provided value.
  const CustomerWriteConsentSourceEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [CustomerWriteConsentSourceEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static CustomerWriteConsentSourceEnum? fromJson(dynamic value) => CustomerWriteConsentSourceEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [CustomerWriteConsentSourceEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<CustomerWriteConsentSourceEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CustomerWriteConsentSourceEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CustomerWriteConsentSourceEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [CustomerWriteConsentSourceEnum] to String,
/// and [decode] dynamic data back to [CustomerWriteConsentSourceEnum].
class CustomerWriteConsentSourceEnumTypeTransformer {
  factory CustomerWriteConsentSourceEnumTypeTransformer() => _instance ??= const CustomerWriteConsentSourceEnumTypeTransformer._();

  const CustomerWriteConsentSourceEnumTypeTransformer._();

  String encode(CustomerWriteConsentSourceEnum data) => data._value;

  /// Returns the instance of [CustomerWriteConsentSourceEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  CustomerWriteConsentSourceEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is CustomerWriteConsentSourceEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'WEB_CHECKOUT': return CustomerWriteConsentSourceEnum.WEB_CHECKOUT;
        case r'STAFF_ENTRY': return CustomerWriteConsentSourceEnum.STAFF_ENTRY;
        case r'IMPORT': return CustomerWriteConsentSourceEnum.IMPORT;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static CustomerWriteConsentSourceEnumTypeTransformer? _instance;
}


