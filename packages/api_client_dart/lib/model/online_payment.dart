//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class OnlinePayment {
  /// Returns a new [OnlinePayment] instance.
  OnlinePayment({
    required this.id,
    required this.saleId,
    required this.provider,
    this.providerRef,
    required this.status,
    required this.amountMinor,
    required this.refundedMinor,
    required this.currency,
    required this.currencyExponent,
    this.qrPayload,
    this.settledAt,
    this.failedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  String id;

  String saleId;

  OnlinePaymentProviderEnum provider;

  String? providerRef;

  OnlinePaymentStatusEnum status;

  /// Currency minor units; IDR exponent 0 in demo.
  ///
  /// Minimum value: 0
  /// Maximum value: 9007199254740991
  int amountMinor;

  /// Currency minor units; IDR exponent 0 in demo.
  ///
  /// Minimum value: 0
  /// Maximum value: 9007199254740991
  int refundedMinor;

  String currency;

  /// Minimum value: 0
  /// Maximum value: 3
  int currencyExponent;

  String? qrPayload;

  DateTime? settledAt;

  DateTime? failedAt;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is OnlinePayment &&
    other.id == id &&
    other.saleId == saleId &&
    other.provider == provider &&
    other.providerRef == providerRef &&
    other.status == status &&
    other.amountMinor == amountMinor &&
    other.refundedMinor == refundedMinor &&
    other.currency == currency &&
    other.currencyExponent == currencyExponent &&
    other.qrPayload == qrPayload &&
    other.settledAt == settledAt &&
    other.failedAt == failedAt &&
    other.createdAt == createdAt &&
    other.updatedAt == updatedAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (saleId.hashCode) +
    (provider.hashCode) +
    (providerRef == null ? 0 : providerRef!.hashCode) +
    (status.hashCode) +
    (amountMinor.hashCode) +
    (refundedMinor.hashCode) +
    (currency.hashCode) +
    (currencyExponent.hashCode) +
    (qrPayload == null ? 0 : qrPayload!.hashCode) +
    (settledAt == null ? 0 : settledAt!.hashCode) +
    (failedAt == null ? 0 : failedAt!.hashCode) +
    (createdAt.hashCode) +
    (updatedAt.hashCode);

  @override
  String toString() => 'OnlinePayment[id=$id, saleId=$saleId, provider=$provider, providerRef=$providerRef, status=$status, amountMinor=$amountMinor, refundedMinor=$refundedMinor, currency=$currency, currencyExponent=$currencyExponent, qrPayload=$qrPayload, settledAt=$settledAt, failedAt=$failedAt, createdAt=$createdAt, updatedAt=$updatedAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'saleId'] = this.saleId;
      json[r'provider'] = this.provider;
    if (this.providerRef != null) {
      json[r'providerRef'] = this.providerRef;
    } else {
      json[r'providerRef'] = null;
    }
      json[r'status'] = this.status;
      json[r'amountMinor'] = this.amountMinor;
      json[r'refundedMinor'] = this.refundedMinor;
      json[r'currency'] = this.currency;
      json[r'currencyExponent'] = this.currencyExponent;
    if (this.qrPayload != null) {
      json[r'qrPayload'] = this.qrPayload;
    } else {
      json[r'qrPayload'] = null;
    }
    if (this.settledAt != null) {
      json[r'settledAt'] = this.settledAt!.toUtc().toIso8601String();
    } else {
      json[r'settledAt'] = null;
    }
    if (this.failedAt != null) {
      json[r'failedAt'] = this.failedAt!.toUtc().toIso8601String();
    } else {
      json[r'failedAt'] = null;
    }
      json[r'createdAt'] = this.createdAt.toUtc().toIso8601String();
      json[r'updatedAt'] = this.updatedAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [OnlinePayment] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static OnlinePayment? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "OnlinePayment[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "OnlinePayment[id]" has a null value in JSON.');
        assert(json.containsKey(r'saleId'), 'Required key "OnlinePayment[saleId]" is missing from JSON.');
        assert(json[r'saleId'] != null, 'Required key "OnlinePayment[saleId]" has a null value in JSON.');
        assert(json.containsKey(r'provider'), 'Required key "OnlinePayment[provider]" is missing from JSON.');
        assert(json[r'provider'] != null, 'Required key "OnlinePayment[provider]" has a null value in JSON.');
        assert(json.containsKey(r'status'), 'Required key "OnlinePayment[status]" is missing from JSON.');
        assert(json[r'status'] != null, 'Required key "OnlinePayment[status]" has a null value in JSON.');
        assert(json.containsKey(r'amountMinor'), 'Required key "OnlinePayment[amountMinor]" is missing from JSON.');
        assert(json[r'amountMinor'] != null, 'Required key "OnlinePayment[amountMinor]" has a null value in JSON.');
        assert(json.containsKey(r'refundedMinor'), 'Required key "OnlinePayment[refundedMinor]" is missing from JSON.');
        assert(json[r'refundedMinor'] != null, 'Required key "OnlinePayment[refundedMinor]" has a null value in JSON.');
        assert(json.containsKey(r'currency'), 'Required key "OnlinePayment[currency]" is missing from JSON.');
        assert(json[r'currency'] != null, 'Required key "OnlinePayment[currency]" has a null value in JSON.');
        assert(json.containsKey(r'currencyExponent'), 'Required key "OnlinePayment[currencyExponent]" is missing from JSON.');
        assert(json[r'currencyExponent'] != null, 'Required key "OnlinePayment[currencyExponent]" has a null value in JSON.');
        assert(json.containsKey(r'createdAt'), 'Required key "OnlinePayment[createdAt]" is missing from JSON.');
        assert(json[r'createdAt'] != null, 'Required key "OnlinePayment[createdAt]" has a null value in JSON.');
        assert(json.containsKey(r'updatedAt'), 'Required key "OnlinePayment[updatedAt]" is missing from JSON.');
        assert(json[r'updatedAt'] != null, 'Required key "OnlinePayment[updatedAt]" has a null value in JSON.');
        return true;
      }());

      return OnlinePayment(
        id: mapValueOfType<String>(json, r'id')!,
        saleId: mapValueOfType<String>(json, r'saleId')!,
        provider: OnlinePaymentProviderEnum.fromJson(json[r'provider'])!,
        providerRef: mapValueOfType<String>(json, r'providerRef'),
        status: OnlinePaymentStatusEnum.fromJson(json[r'status'])!,
        amountMinor: mapValueOfType<int>(json, r'amountMinor')!,
        refundedMinor: mapValueOfType<int>(json, r'refundedMinor')!,
        currency: mapValueOfType<String>(json, r'currency')!,
        currencyExponent: mapValueOfType<int>(json, r'currencyExponent')!,
        qrPayload: mapValueOfType<String>(json, r'qrPayload'),
        settledAt: mapDateTime(json, r'settledAt', r''),
        failedAt: mapDateTime(json, r'failedAt', r''),
        createdAt: mapDateTime(json, r'createdAt', r'')!,
        updatedAt: mapDateTime(json, r'updatedAt', r'')!,
      );
    }
    return null;
  }

  static List<OnlinePayment> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <OnlinePayment>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = OnlinePayment.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, OnlinePayment> mapFromJson(dynamic json) {
    final map = <String, OnlinePayment>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = OnlinePayment.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of OnlinePayment-objects as value to a dart map
  static Map<String, List<OnlinePayment>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<OnlinePayment>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = OnlinePayment.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'saleId',
    'provider',
    'status',
    'amountMinor',
    'refundedMinor',
    'currency',
    'currencyExponent',
    'createdAt',
    'updatedAt',
  };
}


enum OnlinePaymentProviderEnum {
  MOCK._(r'MOCK'),
  QRIS._(r'QRIS'),
  ;

  /// Instantiate a new enum with the provided value.
  const OnlinePaymentProviderEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [OnlinePaymentProviderEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static OnlinePaymentProviderEnum? fromJson(dynamic value) => OnlinePaymentProviderEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [OnlinePaymentProviderEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<OnlinePaymentProviderEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <OnlinePaymentProviderEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = OnlinePaymentProviderEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [OnlinePaymentProviderEnum] to String,
/// and [decode] dynamic data back to [OnlinePaymentProviderEnum].
class OnlinePaymentProviderEnumTypeTransformer {
  factory OnlinePaymentProviderEnumTypeTransformer() => _instance ??= const OnlinePaymentProviderEnumTypeTransformer._();

  const OnlinePaymentProviderEnumTypeTransformer._();

  String encode(OnlinePaymentProviderEnum data) => data._value;

  /// Returns the instance of [OnlinePaymentProviderEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  OnlinePaymentProviderEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is OnlinePaymentProviderEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'MOCK': return OnlinePaymentProviderEnum.MOCK;
        case r'QRIS': return OnlinePaymentProviderEnum.QRIS;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static OnlinePaymentProviderEnumTypeTransformer? _instance;
}



enum OnlinePaymentStatusEnum {
  PENDING._(r'PENDING'),
  SUCCEEDED._(r'SUCCEEDED'),
  FAILED._(r'FAILED'),
  REFUNDED._(r'REFUNDED'),
  PARTIALLY_REFUNDED._(r'PARTIALLY_REFUNDED'),
  ;

  /// Instantiate a new enum with the provided value.
  const OnlinePaymentStatusEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [OnlinePaymentStatusEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static OnlinePaymentStatusEnum? fromJson(dynamic value) => OnlinePaymentStatusEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [OnlinePaymentStatusEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<OnlinePaymentStatusEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <OnlinePaymentStatusEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = OnlinePaymentStatusEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [OnlinePaymentStatusEnum] to String,
/// and [decode] dynamic data back to [OnlinePaymentStatusEnum].
class OnlinePaymentStatusEnumTypeTransformer {
  factory OnlinePaymentStatusEnumTypeTransformer() => _instance ??= const OnlinePaymentStatusEnumTypeTransformer._();

  const OnlinePaymentStatusEnumTypeTransformer._();

  String encode(OnlinePaymentStatusEnum data) => data._value;

  /// Returns the instance of [OnlinePaymentStatusEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  OnlinePaymentStatusEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is OnlinePaymentStatusEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'PENDING': return OnlinePaymentStatusEnum.PENDING;
        case r'SUCCEEDED': return OnlinePaymentStatusEnum.SUCCEEDED;
        case r'FAILED': return OnlinePaymentStatusEnum.FAILED;
        case r'REFUNDED': return OnlinePaymentStatusEnum.REFUNDED;
        case r'PARTIALLY_REFUNDED': return OnlinePaymentStatusEnum.PARTIALLY_REFUNDED;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static OnlinePaymentStatusEnumTypeTransformer? _instance;
}


