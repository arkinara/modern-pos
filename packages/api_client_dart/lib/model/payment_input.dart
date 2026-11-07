//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PaymentInput {
  /// Returns a new [PaymentInput] instance.
  PaymentInput({
    required this.kind,
    required this.amountMinor,
    this.tenderedMinor,
    this.reference,
  });

  PaymentInputKindEnum kind;

  /// Currency minor units; IDR exponent 0 in demo.
  ///
  /// Minimum value: 0
  /// Maximum value: 9007199254740991
  int amountMinor;

  /// Currency minor units; IDR exponent 0 in demo.
  ///
  /// Minimum value: 0
  /// Maximum value: 9007199254740991
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? tenderedMinor;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? reference;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PaymentInput &&
    other.kind == kind &&
    other.amountMinor == amountMinor &&
    other.tenderedMinor == tenderedMinor &&
    other.reference == reference;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (kind.hashCode) +
    (amountMinor.hashCode) +
    (tenderedMinor == null ? 0 : tenderedMinor!.hashCode) +
    (reference == null ? 0 : reference!.hashCode);

  @override
  String toString() => 'PaymentInput[kind=$kind, amountMinor=$amountMinor, tenderedMinor=$tenderedMinor, reference=$reference]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'kind'] = this.kind;
      json[r'amountMinor'] = this.amountMinor;
    if (this.tenderedMinor != null) {
      json[r'tenderedMinor'] = this.tenderedMinor;
    } else {
      json[r'tenderedMinor'] = null;
    }
    if (this.reference != null) {
      json[r'reference'] = this.reference;
    } else {
      json[r'reference'] = null;
    }
    return json;
  }

  /// Returns a new [PaymentInput] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PaymentInput? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'kind'), 'Required key "PaymentInput[kind]" is missing from JSON.');
        assert(json[r'kind'] != null, 'Required key "PaymentInput[kind]" has a null value in JSON.');
        assert(json.containsKey(r'amountMinor'), 'Required key "PaymentInput[amountMinor]" is missing from JSON.');
        assert(json[r'amountMinor'] != null, 'Required key "PaymentInput[amountMinor]" has a null value in JSON.');
        return true;
      }());

      return PaymentInput(
        kind: PaymentInputKindEnum.fromJson(json[r'kind'])!,
        amountMinor: mapValueOfType<int>(json, r'amountMinor')!,
        tenderedMinor: mapValueOfType<int>(json, r'tenderedMinor'),
        reference: mapValueOfType<String>(json, r'reference'),
      );
    }
    return null;
  }

  static List<PaymentInput> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PaymentInput>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PaymentInput.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PaymentInput> mapFromJson(dynamic json) {
    final map = <String, PaymentInput>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PaymentInput.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PaymentInput-objects as value to a dart map
  static Map<String, List<PaymentInput>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PaymentInput>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PaymentInput.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'kind',
    'amountMinor',
  };
}


enum PaymentInputKindEnum {
  CASH._(r'CASH'),
  MANUAL_EXTERNAL._(r'MANUAL_EXTERNAL'),
  ;

  /// Instantiate a new enum with the provided value.
  const PaymentInputKindEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [PaymentInputKindEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static PaymentInputKindEnum? fromJson(dynamic value) => PaymentInputKindEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [PaymentInputKindEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<PaymentInputKindEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PaymentInputKindEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PaymentInputKindEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [PaymentInputKindEnum] to String,
/// and [decode] dynamic data back to [PaymentInputKindEnum].
class PaymentInputKindEnumTypeTransformer {
  factory PaymentInputKindEnumTypeTransformer() => _instance ??= const PaymentInputKindEnumTypeTransformer._();

  const PaymentInputKindEnumTypeTransformer._();

  String encode(PaymentInputKindEnum data) => data._value;

  /// Returns the instance of [PaymentInputKindEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  PaymentInputKindEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is PaymentInputKindEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'CASH': return PaymentInputKindEnum.CASH;
        case r'MANUAL_EXTERNAL': return PaymentInputKindEnum.MANUAL_EXTERNAL;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static PaymentInputKindEnumTypeTransformer? _instance;
}


