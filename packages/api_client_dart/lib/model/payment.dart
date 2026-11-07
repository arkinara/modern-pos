//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Payment {
  /// Returns a new [Payment] instance.
  Payment({
    required this.kind,
    required this.status,
    required this.amountMinor,
    this.tenderedMinor,
    this.changeMinor,
    this.reference,
  });

  PaymentKindEnum kind;

  PaymentStatusEnum status;

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
  int? changeMinor;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? reference;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Payment &&
    other.kind == kind &&
    other.status == status &&
    other.amountMinor == amountMinor &&
    other.tenderedMinor == tenderedMinor &&
    other.changeMinor == changeMinor &&
    other.reference == reference;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (kind.hashCode) +
    (status.hashCode) +
    (amountMinor.hashCode) +
    (tenderedMinor == null ? 0 : tenderedMinor!.hashCode) +
    (changeMinor == null ? 0 : changeMinor!.hashCode) +
    (reference == null ? 0 : reference!.hashCode);

  @override
  String toString() => 'Payment[kind=$kind, status=$status, amountMinor=$amountMinor, tenderedMinor=$tenderedMinor, changeMinor=$changeMinor, reference=$reference]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'kind'] = this.kind;
      json[r'status'] = this.status;
      json[r'amountMinor'] = this.amountMinor;
    if (this.tenderedMinor != null) {
      json[r'tenderedMinor'] = this.tenderedMinor;
    } else {
      json[r'tenderedMinor'] = null;
    }
    if (this.changeMinor != null) {
      json[r'changeMinor'] = this.changeMinor;
    } else {
      json[r'changeMinor'] = null;
    }
    if (this.reference != null) {
      json[r'reference'] = this.reference;
    } else {
      json[r'reference'] = null;
    }
    return json;
  }

  /// Returns a new [Payment] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Payment? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'kind'), 'Required key "Payment[kind]" is missing from JSON.');
        assert(json[r'kind'] != null, 'Required key "Payment[kind]" has a null value in JSON.');
        assert(json.containsKey(r'status'), 'Required key "Payment[status]" is missing from JSON.');
        assert(json[r'status'] != null, 'Required key "Payment[status]" has a null value in JSON.');
        assert(json.containsKey(r'amountMinor'), 'Required key "Payment[amountMinor]" is missing from JSON.');
        assert(json[r'amountMinor'] != null, 'Required key "Payment[amountMinor]" has a null value in JSON.');
        return true;
      }());

      return Payment(
        kind: PaymentKindEnum.fromJson(json[r'kind'])!,
        status: PaymentStatusEnum.fromJson(json[r'status'])!,
        amountMinor: mapValueOfType<int>(json, r'amountMinor')!,
        tenderedMinor: mapValueOfType<int>(json, r'tenderedMinor'),
        changeMinor: mapValueOfType<int>(json, r'changeMinor'),
        reference: mapValueOfType<String>(json, r'reference'),
      );
    }
    return null;
  }

  static List<Payment> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Payment>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Payment.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Payment> mapFromJson(dynamic json) {
    final map = <String, Payment>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Payment.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Payment-objects as value to a dart map
  static Map<String, List<Payment>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Payment>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Payment.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'kind',
    'status',
    'amountMinor',
  };
}


enum PaymentKindEnum {
  CASH._(r'CASH'),
  MANUAL_EXTERNAL._(r'MANUAL_EXTERNAL'),
  ;

  /// Instantiate a new enum with the provided value.
  const PaymentKindEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [PaymentKindEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static PaymentKindEnum? fromJson(dynamic value) => PaymentKindEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [PaymentKindEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<PaymentKindEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PaymentKindEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PaymentKindEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [PaymentKindEnum] to String,
/// and [decode] dynamic data back to [PaymentKindEnum].
class PaymentKindEnumTypeTransformer {
  factory PaymentKindEnumTypeTransformer() => _instance ??= const PaymentKindEnumTypeTransformer._();

  const PaymentKindEnumTypeTransformer._();

  String encode(PaymentKindEnum data) => data._value;

  /// Returns the instance of [PaymentKindEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  PaymentKindEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is PaymentKindEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'CASH': return PaymentKindEnum.CASH;
        case r'MANUAL_EXTERNAL': return PaymentKindEnum.MANUAL_EXTERNAL;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static PaymentKindEnumTypeTransformer? _instance;
}



enum PaymentStatusEnum {
  RECORDED._(r'RECORDED'),
  ;

  /// Instantiate a new enum with the provided value.
  const PaymentStatusEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [PaymentStatusEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static PaymentStatusEnum? fromJson(dynamic value) => PaymentStatusEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [PaymentStatusEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<PaymentStatusEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PaymentStatusEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PaymentStatusEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [PaymentStatusEnum] to String,
/// and [decode] dynamic data back to [PaymentStatusEnum].
class PaymentStatusEnumTypeTransformer {
  factory PaymentStatusEnumTypeTransformer() => _instance ??= const PaymentStatusEnumTypeTransformer._();

  const PaymentStatusEnumTypeTransformer._();

  String encode(PaymentStatusEnum data) => data._value;

  /// Returns the instance of [PaymentStatusEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  PaymentStatusEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is PaymentStatusEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'RECORDED': return PaymentStatusEnum.RECORDED;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static PaymentStatusEnumTypeTransformer? _instance;
}


