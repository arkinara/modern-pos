//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ChannelCustomerInput {
  /// Returns a new [ChannelCustomerInput] instance.
  ChannelCustomerInput({
    this.name,
    required this.contact,
    required this.contactType,
    required this.consent,
    this.consentSource,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? name;

  String contact;

  ChannelCustomerInputContactTypeEnum contactType;

  bool consent;

  ChannelCustomerInputConsentSourceEnum? consentSource;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ChannelCustomerInput &&
    other.name == name &&
    other.contact == contact &&
    other.contactType == contactType &&
    other.consent == consent &&
    other.consentSource == consentSource;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (name == null ? 0 : name!.hashCode) +
    (contact.hashCode) +
    (contactType.hashCode) +
    (consent.hashCode) +
    (consentSource == null ? 0 : consentSource!.hashCode);

  @override
  String toString() => 'ChannelCustomerInput[name=$name, contact=$contact, contactType=$contactType, consent=$consent, consentSource=$consentSource]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.name != null) {
      json[r'name'] = this.name;
    } else {
      json[r'name'] = null;
    }
      json[r'contact'] = this.contact;
      json[r'contactType'] = this.contactType;
      json[r'consent'] = this.consent;
    if (this.consentSource != null) {
      json[r'consentSource'] = this.consentSource;
    } else {
      json[r'consentSource'] = null;
    }
    return json;
  }

  /// Returns a new [ChannelCustomerInput] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ChannelCustomerInput? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'contact'), 'Required key "ChannelCustomerInput[contact]" is missing from JSON.');
        assert(json[r'contact'] != null, 'Required key "ChannelCustomerInput[contact]" has a null value in JSON.');
        assert(json.containsKey(r'contactType'), 'Required key "ChannelCustomerInput[contactType]" is missing from JSON.');
        assert(json[r'contactType'] != null, 'Required key "ChannelCustomerInput[contactType]" has a null value in JSON.');
        assert(json.containsKey(r'consent'), 'Required key "ChannelCustomerInput[consent]" is missing from JSON.');
        assert(json[r'consent'] != null, 'Required key "ChannelCustomerInput[consent]" has a null value in JSON.');
        return true;
      }());

      return ChannelCustomerInput(
        name: mapValueOfType<String>(json, r'name'),
        contact: mapValueOfType<String>(json, r'contact')!,
        contactType: ChannelCustomerInputContactTypeEnum.fromJson(json[r'contactType'])!,
        consent: mapValueOfType<bool>(json, r'consent')!,
        consentSource: ChannelCustomerInputConsentSourceEnum.fromJson(json[r'consentSource']),
      );
    }
    return null;
  }

  static List<ChannelCustomerInput> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ChannelCustomerInput>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ChannelCustomerInput.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ChannelCustomerInput> mapFromJson(dynamic json) {
    final map = <String, ChannelCustomerInput>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ChannelCustomerInput.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ChannelCustomerInput-objects as value to a dart map
  static Map<String, List<ChannelCustomerInput>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ChannelCustomerInput>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ChannelCustomerInput.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'contact',
    'contactType',
    'consent',
  };
}


enum ChannelCustomerInputContactTypeEnum {
  EMAIL._(r'EMAIL'),
  PHONE._(r'PHONE'),
  ;

  /// Instantiate a new enum with the provided value.
  const ChannelCustomerInputContactTypeEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [ChannelCustomerInputContactTypeEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static ChannelCustomerInputContactTypeEnum? fromJson(dynamic value) => ChannelCustomerInputContactTypeEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [ChannelCustomerInputContactTypeEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<ChannelCustomerInputContactTypeEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ChannelCustomerInputContactTypeEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ChannelCustomerInputContactTypeEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ChannelCustomerInputContactTypeEnum] to String,
/// and [decode] dynamic data back to [ChannelCustomerInputContactTypeEnum].
class ChannelCustomerInputContactTypeEnumTypeTransformer {
  factory ChannelCustomerInputContactTypeEnumTypeTransformer() => _instance ??= const ChannelCustomerInputContactTypeEnumTypeTransformer._();

  const ChannelCustomerInputContactTypeEnumTypeTransformer._();

  String encode(ChannelCustomerInputContactTypeEnum data) => data._value;

  /// Returns the instance of [ChannelCustomerInputContactTypeEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ChannelCustomerInputContactTypeEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is ChannelCustomerInputContactTypeEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'EMAIL': return ChannelCustomerInputContactTypeEnum.EMAIL;
        case r'PHONE': return ChannelCustomerInputContactTypeEnum.PHONE;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static ChannelCustomerInputContactTypeEnumTypeTransformer? _instance;
}



enum ChannelCustomerInputConsentSourceEnum {
  WEB_CHECKOUT._(r'WEB_CHECKOUT'),
  STAFF_ENTRY._(r'STAFF_ENTRY'),
  IMPORT._(r'IMPORT'),
  ;

  /// Instantiate a new enum with the provided value.
  const ChannelCustomerInputConsentSourceEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [ChannelCustomerInputConsentSourceEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static ChannelCustomerInputConsentSourceEnum? fromJson(dynamic value) => ChannelCustomerInputConsentSourceEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [ChannelCustomerInputConsentSourceEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<ChannelCustomerInputConsentSourceEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ChannelCustomerInputConsentSourceEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ChannelCustomerInputConsentSourceEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ChannelCustomerInputConsentSourceEnum] to String,
/// and [decode] dynamic data back to [ChannelCustomerInputConsentSourceEnum].
class ChannelCustomerInputConsentSourceEnumTypeTransformer {
  factory ChannelCustomerInputConsentSourceEnumTypeTransformer() => _instance ??= const ChannelCustomerInputConsentSourceEnumTypeTransformer._();

  const ChannelCustomerInputConsentSourceEnumTypeTransformer._();

  String encode(ChannelCustomerInputConsentSourceEnum data) => data._value;

  /// Returns the instance of [ChannelCustomerInputConsentSourceEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ChannelCustomerInputConsentSourceEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is ChannelCustomerInputConsentSourceEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'WEB_CHECKOUT': return ChannelCustomerInputConsentSourceEnum.WEB_CHECKOUT;
        case r'STAFF_ENTRY': return ChannelCustomerInputConsentSourceEnum.STAFF_ENTRY;
        case r'IMPORT': return ChannelCustomerInputConsentSourceEnum.IMPORT;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static ChannelCustomerInputConsentSourceEnumTypeTransformer? _instance;
}


