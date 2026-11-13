//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ChannelOrderWebhookWrite {
  /// Returns a new [ChannelOrderWebhookWrite] instance.
  ChannelOrderWebhookWrite({
    required this.outletId,
    required this.reference,
    this.items = const [],
    this.customer,
    this.note,
    this.paymentMode,
  });

  String outletId;

  String reference;

  List<ChannelOrderLineInput> items;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  ChannelCustomerInput? customer;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? note;

  ChannelOrderWebhookWritePaymentModeEnum? paymentMode;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ChannelOrderWebhookWrite &&
    other.outletId == outletId &&
    other.reference == reference &&
    _deepEquality.equals(other.items, items) &&
    other.customer == customer &&
    other.note == note &&
    other.paymentMode == paymentMode;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (outletId.hashCode) +
    (reference.hashCode) +
    (items.hashCode) +
    (customer == null ? 0 : customer!.hashCode) +
    (note == null ? 0 : note!.hashCode) +
    (paymentMode == null ? 0 : paymentMode!.hashCode);

  @override
  String toString() => 'ChannelOrderWebhookWrite[outletId=$outletId, reference=$reference, items=$items, customer=$customer, note=$note, paymentMode=$paymentMode]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'outletId'] = this.outletId;
      json[r'reference'] = this.reference;
      json[r'items'] = this.items;
    if (this.customer != null) {
      json[r'customer'] = this.customer;
    } else {
      json[r'customer'] = null;
    }
    if (this.note != null) {
      json[r'note'] = this.note;
    } else {
      json[r'note'] = null;
    }
    if (this.paymentMode != null) {
      json[r'paymentMode'] = this.paymentMode;
    } else {
      json[r'paymentMode'] = null;
    }
    return json;
  }

  /// Returns a new [ChannelOrderWebhookWrite] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ChannelOrderWebhookWrite? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'outletId'), 'Required key "ChannelOrderWebhookWrite[outletId]" is missing from JSON.');
        assert(json[r'outletId'] != null, 'Required key "ChannelOrderWebhookWrite[outletId]" has a null value in JSON.');
        assert(json.containsKey(r'reference'), 'Required key "ChannelOrderWebhookWrite[reference]" is missing from JSON.');
        assert(json[r'reference'] != null, 'Required key "ChannelOrderWebhookWrite[reference]" has a null value in JSON.');
        assert(json.containsKey(r'items'), 'Required key "ChannelOrderWebhookWrite[items]" is missing from JSON.');
        assert(json[r'items'] != null, 'Required key "ChannelOrderWebhookWrite[items]" has a null value in JSON.');
        return true;
      }());

      return ChannelOrderWebhookWrite(
        outletId: mapValueOfType<String>(json, r'outletId')!,
        reference: mapValueOfType<String>(json, r'reference')!,
        items: ChannelOrderLineInput.listFromJson(json[r'items']),
        customer: ChannelCustomerInput.fromJson(json[r'customer']),
        note: mapValueOfType<String>(json, r'note'),
        paymentMode: ChannelOrderWebhookWritePaymentModeEnum.fromJson(json[r'paymentMode']),
      );
    }
    return null;
  }

  static List<ChannelOrderWebhookWrite> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ChannelOrderWebhookWrite>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ChannelOrderWebhookWrite.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ChannelOrderWebhookWrite> mapFromJson(dynamic json) {
    final map = <String, ChannelOrderWebhookWrite>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ChannelOrderWebhookWrite.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ChannelOrderWebhookWrite-objects as value to a dart map
  static Map<String, List<ChannelOrderWebhookWrite>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ChannelOrderWebhookWrite>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ChannelOrderWebhookWrite.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'outletId',
    'reference',
    'items',
  };
}


enum ChannelOrderWebhookWritePaymentModeEnum {
  CASH_ON_PICKUP._(r'CASH_ON_PICKUP'),
  PREPAID_PROVIDER._(r'PREPAID_PROVIDER'),
  ;

  /// Instantiate a new enum with the provided value.
  const ChannelOrderWebhookWritePaymentModeEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [ChannelOrderWebhookWritePaymentModeEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static ChannelOrderWebhookWritePaymentModeEnum? fromJson(dynamic value) => ChannelOrderWebhookWritePaymentModeEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [ChannelOrderWebhookWritePaymentModeEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<ChannelOrderWebhookWritePaymentModeEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ChannelOrderWebhookWritePaymentModeEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ChannelOrderWebhookWritePaymentModeEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ChannelOrderWebhookWritePaymentModeEnum] to String,
/// and [decode] dynamic data back to [ChannelOrderWebhookWritePaymentModeEnum].
class ChannelOrderWebhookWritePaymentModeEnumTypeTransformer {
  factory ChannelOrderWebhookWritePaymentModeEnumTypeTransformer() => _instance ??= const ChannelOrderWebhookWritePaymentModeEnumTypeTransformer._();

  const ChannelOrderWebhookWritePaymentModeEnumTypeTransformer._();

  String encode(ChannelOrderWebhookWritePaymentModeEnum data) => data._value;

  /// Returns the instance of [ChannelOrderWebhookWritePaymentModeEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ChannelOrderWebhookWritePaymentModeEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is ChannelOrderWebhookWritePaymentModeEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'CASH_ON_PICKUP': return ChannelOrderWebhookWritePaymentModeEnum.CASH_ON_PICKUP;
        case r'PREPAID_PROVIDER': return ChannelOrderWebhookWritePaymentModeEnum.PREPAID_PROVIDER;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static ChannelOrderWebhookWritePaymentModeEnumTypeTransformer? _instance;
}


