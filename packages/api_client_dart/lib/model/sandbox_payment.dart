//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class SandboxPayment {
  /// Returns a new [SandboxPayment] instance.
  SandboxPayment({
    required this.providerRef,
    required this.status,
    required this.amountMinor,
    required this.currency,
    this.qrPayload,
    required this.refundedMinor,
  });

  String providerRef;

  SandboxPaymentStatusEnum status;

  String amountMinor;

  String currency;

  String? qrPayload;

  String refundedMinor;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SandboxPayment &&
    other.providerRef == providerRef &&
    other.status == status &&
    other.amountMinor == amountMinor &&
    other.currency == currency &&
    other.qrPayload == qrPayload &&
    other.refundedMinor == refundedMinor;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (providerRef.hashCode) +
    (status.hashCode) +
    (amountMinor.hashCode) +
    (currency.hashCode) +
    (qrPayload == null ? 0 : qrPayload!.hashCode) +
    (refundedMinor.hashCode);

  @override
  String toString() => 'SandboxPayment[providerRef=$providerRef, status=$status, amountMinor=$amountMinor, currency=$currency, qrPayload=$qrPayload, refundedMinor=$refundedMinor]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'providerRef'] = this.providerRef;
      json[r'status'] = this.status;
      json[r'amountMinor'] = this.amountMinor;
      json[r'currency'] = this.currency;
    if (this.qrPayload != null) {
      json[r'qrPayload'] = this.qrPayload;
    } else {
      json[r'qrPayload'] = null;
    }
      json[r'refundedMinor'] = this.refundedMinor;
    return json;
  }

  /// Returns a new [SandboxPayment] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SandboxPayment? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'providerRef'), 'Required key "SandboxPayment[providerRef]" is missing from JSON.');
        assert(json[r'providerRef'] != null, 'Required key "SandboxPayment[providerRef]" has a null value in JSON.');
        assert(json.containsKey(r'status'), 'Required key "SandboxPayment[status]" is missing from JSON.');
        assert(json[r'status'] != null, 'Required key "SandboxPayment[status]" has a null value in JSON.');
        assert(json.containsKey(r'amountMinor'), 'Required key "SandboxPayment[amountMinor]" is missing from JSON.');
        assert(json[r'amountMinor'] != null, 'Required key "SandboxPayment[amountMinor]" has a null value in JSON.');
        assert(json.containsKey(r'currency'), 'Required key "SandboxPayment[currency]" is missing from JSON.');
        assert(json[r'currency'] != null, 'Required key "SandboxPayment[currency]" has a null value in JSON.');
        assert(json.containsKey(r'refundedMinor'), 'Required key "SandboxPayment[refundedMinor]" is missing from JSON.');
        assert(json[r'refundedMinor'] != null, 'Required key "SandboxPayment[refundedMinor]" has a null value in JSON.');
        return true;
      }());

      return SandboxPayment(
        providerRef: mapValueOfType<String>(json, r'providerRef')!,
        status: SandboxPaymentStatusEnum.fromJson(json[r'status'])!,
        amountMinor: mapValueOfType<String>(json, r'amountMinor')!,
        currency: mapValueOfType<String>(json, r'currency')!,
        qrPayload: mapValueOfType<String>(json, r'qrPayload'),
        refundedMinor: mapValueOfType<String>(json, r'refundedMinor')!,
      );
    }
    return null;
  }

  static List<SandboxPayment> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SandboxPayment>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SandboxPayment.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SandboxPayment> mapFromJson(dynamic json) {
    final map = <String, SandboxPayment>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SandboxPayment.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SandboxPayment-objects as value to a dart map
  static Map<String, List<SandboxPayment>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SandboxPayment>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SandboxPayment.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'providerRef',
    'status',
    'amountMinor',
    'currency',
    'refundedMinor',
  };
}


enum SandboxPaymentStatusEnum {
  PENDING._(r'PENDING'),
  SUCCEEDED._(r'SUCCEEDED'),
  FAILED._(r'FAILED'),
  REFUNDED._(r'REFUNDED'),
  PARTIALLY_REFUNDED._(r'PARTIALLY_REFUNDED'),
  ;

  /// Instantiate a new enum with the provided value.
  const SandboxPaymentStatusEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [SandboxPaymentStatusEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static SandboxPaymentStatusEnum? fromJson(dynamic value) => SandboxPaymentStatusEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [SandboxPaymentStatusEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<SandboxPaymentStatusEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SandboxPaymentStatusEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SandboxPaymentStatusEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [SandboxPaymentStatusEnum] to String,
/// and [decode] dynamic data back to [SandboxPaymentStatusEnum].
class SandboxPaymentStatusEnumTypeTransformer {
  factory SandboxPaymentStatusEnumTypeTransformer() => _instance ??= const SandboxPaymentStatusEnumTypeTransformer._();

  const SandboxPaymentStatusEnumTypeTransformer._();

  String encode(SandboxPaymentStatusEnum data) => data._value;

  /// Returns the instance of [SandboxPaymentStatusEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  SandboxPaymentStatusEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is SandboxPaymentStatusEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'PENDING': return SandboxPaymentStatusEnum.PENDING;
        case r'SUCCEEDED': return SandboxPaymentStatusEnum.SUCCEEDED;
        case r'FAILED': return SandboxPaymentStatusEnum.FAILED;
        case r'REFUNDED': return SandboxPaymentStatusEnum.REFUNDED;
        case r'PARTIALLY_REFUNDED': return SandboxPaymentStatusEnum.PARTIALLY_REFUNDED;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static SandboxPaymentStatusEnumTypeTransformer? _instance;
}


