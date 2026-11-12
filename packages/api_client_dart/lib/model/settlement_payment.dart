//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class SettlementPayment {
  /// Returns a new [SettlementPayment] instance.
  SettlementPayment({
    required this.paymentId,
    required this.saleId,
    required this.saleReference,
    required this.completedAt,
    required this.status,
    required this.capturedMinor,
    required this.refundedMinor,
    required this.netMinor,
    this.settledAt,
  });

  String paymentId;

  String saleId;

  String saleReference;

  DateTime completedAt;

  SettlementPaymentStatusEnum status;

  /// Minimum value: 0
  /// Maximum value: 9007199254740991
  int capturedMinor;

  /// Minimum value: 0
  /// Maximum value: 9007199254740991
  int refundedMinor;

  /// Minimum value: 0
  /// Maximum value: 9007199254740991
  int netMinor;

  DateTime? settledAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SettlementPayment &&
    other.paymentId == paymentId &&
    other.saleId == saleId &&
    other.saleReference == saleReference &&
    other.completedAt == completedAt &&
    other.status == status &&
    other.capturedMinor == capturedMinor &&
    other.refundedMinor == refundedMinor &&
    other.netMinor == netMinor &&
    other.settledAt == settledAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (paymentId.hashCode) +
    (saleId.hashCode) +
    (saleReference.hashCode) +
    (completedAt.hashCode) +
    (status.hashCode) +
    (capturedMinor.hashCode) +
    (refundedMinor.hashCode) +
    (netMinor.hashCode) +
    (settledAt == null ? 0 : settledAt!.hashCode);

  @override
  String toString() => 'SettlementPayment[paymentId=$paymentId, saleId=$saleId, saleReference=$saleReference, completedAt=$completedAt, status=$status, capturedMinor=$capturedMinor, refundedMinor=$refundedMinor, netMinor=$netMinor, settledAt=$settledAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'paymentId'] = this.paymentId;
      json[r'saleId'] = this.saleId;
      json[r'saleReference'] = this.saleReference;
      json[r'completedAt'] = this.completedAt.toUtc().toIso8601String();
      json[r'status'] = this.status;
      json[r'capturedMinor'] = this.capturedMinor;
      json[r'refundedMinor'] = this.refundedMinor;
      json[r'netMinor'] = this.netMinor;
    if (this.settledAt != null) {
      json[r'settledAt'] = this.settledAt!.toUtc().toIso8601String();
    } else {
      json[r'settledAt'] = null;
    }
    return json;
  }

  /// Returns a new [SettlementPayment] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SettlementPayment? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'paymentId'), 'Required key "SettlementPayment[paymentId]" is missing from JSON.');
        assert(json[r'paymentId'] != null, 'Required key "SettlementPayment[paymentId]" has a null value in JSON.');
        assert(json.containsKey(r'saleId'), 'Required key "SettlementPayment[saleId]" is missing from JSON.');
        assert(json[r'saleId'] != null, 'Required key "SettlementPayment[saleId]" has a null value in JSON.');
        assert(json.containsKey(r'saleReference'), 'Required key "SettlementPayment[saleReference]" is missing from JSON.');
        assert(json[r'saleReference'] != null, 'Required key "SettlementPayment[saleReference]" has a null value in JSON.');
        assert(json.containsKey(r'completedAt'), 'Required key "SettlementPayment[completedAt]" is missing from JSON.');
        assert(json[r'completedAt'] != null, 'Required key "SettlementPayment[completedAt]" has a null value in JSON.');
        assert(json.containsKey(r'status'), 'Required key "SettlementPayment[status]" is missing from JSON.');
        assert(json[r'status'] != null, 'Required key "SettlementPayment[status]" has a null value in JSON.');
        assert(json.containsKey(r'capturedMinor'), 'Required key "SettlementPayment[capturedMinor]" is missing from JSON.');
        assert(json[r'capturedMinor'] != null, 'Required key "SettlementPayment[capturedMinor]" has a null value in JSON.');
        assert(json.containsKey(r'refundedMinor'), 'Required key "SettlementPayment[refundedMinor]" is missing from JSON.');
        assert(json[r'refundedMinor'] != null, 'Required key "SettlementPayment[refundedMinor]" has a null value in JSON.');
        assert(json.containsKey(r'netMinor'), 'Required key "SettlementPayment[netMinor]" is missing from JSON.');
        assert(json[r'netMinor'] != null, 'Required key "SettlementPayment[netMinor]" has a null value in JSON.');
        return true;
      }());

      return SettlementPayment(
        paymentId: mapValueOfType<String>(json, r'paymentId')!,
        saleId: mapValueOfType<String>(json, r'saleId')!,
        saleReference: mapValueOfType<String>(json, r'saleReference')!,
        completedAt: mapDateTime(json, r'completedAt', r'')!,
        status: SettlementPaymentStatusEnum.fromJson(json[r'status'])!,
        capturedMinor: mapValueOfType<int>(json, r'capturedMinor')!,
        refundedMinor: mapValueOfType<int>(json, r'refundedMinor')!,
        netMinor: mapValueOfType<int>(json, r'netMinor')!,
        settledAt: mapDateTime(json, r'settledAt', r''),
      );
    }
    return null;
  }

  static List<SettlementPayment> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SettlementPayment>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SettlementPayment.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SettlementPayment> mapFromJson(dynamic json) {
    final map = <String, SettlementPayment>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SettlementPayment.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SettlementPayment-objects as value to a dart map
  static Map<String, List<SettlementPayment>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SettlementPayment>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SettlementPayment.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'paymentId',
    'saleId',
    'saleReference',
    'completedAt',
    'status',
    'capturedMinor',
    'refundedMinor',
    'netMinor',
  };
}


enum SettlementPaymentStatusEnum {
  PENDING._(r'PENDING'),
  SUCCEEDED._(r'SUCCEEDED'),
  FAILED._(r'FAILED'),
  REFUNDED._(r'REFUNDED'),
  PARTIALLY_REFUNDED._(r'PARTIALLY_REFUNDED'),
  ;

  /// Instantiate a new enum with the provided value.
  const SettlementPaymentStatusEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [SettlementPaymentStatusEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static SettlementPaymentStatusEnum? fromJson(dynamic value) => SettlementPaymentStatusEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [SettlementPaymentStatusEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<SettlementPaymentStatusEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SettlementPaymentStatusEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SettlementPaymentStatusEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [SettlementPaymentStatusEnum] to String,
/// and [decode] dynamic data back to [SettlementPaymentStatusEnum].
class SettlementPaymentStatusEnumTypeTransformer {
  factory SettlementPaymentStatusEnumTypeTransformer() => _instance ??= const SettlementPaymentStatusEnumTypeTransformer._();

  const SettlementPaymentStatusEnumTypeTransformer._();

  String encode(SettlementPaymentStatusEnum data) => data._value;

  /// Returns the instance of [SettlementPaymentStatusEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  SettlementPaymentStatusEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is SettlementPaymentStatusEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'PENDING': return SettlementPaymentStatusEnum.PENDING;
        case r'SUCCEEDED': return SettlementPaymentStatusEnum.SUCCEEDED;
        case r'FAILED': return SettlementPaymentStatusEnum.FAILED;
        case r'REFUNDED': return SettlementPaymentStatusEnum.REFUNDED;
        case r'PARTIALLY_REFUNDED': return SettlementPaymentStatusEnum.PARTIALLY_REFUNDED;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static SettlementPaymentStatusEnumTypeTransformer? _instance;
}


