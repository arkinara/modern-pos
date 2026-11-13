//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PaymentBreakdownEntry {
  /// Returns a new [PaymentBreakdownEntry] instance.
  PaymentBreakdownEntry({
    required this.kind,
    required this.receivedMinor,
  });

  PaymentBreakdownEntryKindEnum kind;

  /// Minimum value: 0
  /// Maximum value: 9007199254740991
  int receivedMinor;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PaymentBreakdownEntry &&
    other.kind == kind &&
    other.receivedMinor == receivedMinor;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (kind.hashCode) +
    (receivedMinor.hashCode);

  @override
  String toString() => 'PaymentBreakdownEntry[kind=$kind, receivedMinor=$receivedMinor]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'kind'] = this.kind;
      json[r'receivedMinor'] = this.receivedMinor;
    return json;
  }

  /// Returns a new [PaymentBreakdownEntry] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PaymentBreakdownEntry? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'kind'), 'Required key "PaymentBreakdownEntry[kind]" is missing from JSON.');
        assert(json[r'kind'] != null, 'Required key "PaymentBreakdownEntry[kind]" has a null value in JSON.');
        assert(json.containsKey(r'receivedMinor'), 'Required key "PaymentBreakdownEntry[receivedMinor]" is missing from JSON.');
        assert(json[r'receivedMinor'] != null, 'Required key "PaymentBreakdownEntry[receivedMinor]" has a null value in JSON.');
        return true;
      }());

      return PaymentBreakdownEntry(
        kind: PaymentBreakdownEntryKindEnum.fromJson(json[r'kind'])!,
        receivedMinor: mapValueOfType<int>(json, r'receivedMinor')!,
      );
    }
    return null;
  }

  static List<PaymentBreakdownEntry> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PaymentBreakdownEntry>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PaymentBreakdownEntry.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PaymentBreakdownEntry> mapFromJson(dynamic json) {
    final map = <String, PaymentBreakdownEntry>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PaymentBreakdownEntry.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PaymentBreakdownEntry-objects as value to a dart map
  static Map<String, List<PaymentBreakdownEntry>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PaymentBreakdownEntry>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PaymentBreakdownEntry.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'kind',
    'receivedMinor',
  };
}


enum PaymentBreakdownEntryKindEnum {
  CASH._(r'CASH'),
  MANUAL_EXTERNAL._(r'MANUAL_EXTERNAL'),
  ONLINE._(r'ONLINE'),
  ;

  /// Instantiate a new enum with the provided value.
  const PaymentBreakdownEntryKindEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [PaymentBreakdownEntryKindEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static PaymentBreakdownEntryKindEnum? fromJson(dynamic value) => PaymentBreakdownEntryKindEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [PaymentBreakdownEntryKindEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<PaymentBreakdownEntryKindEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PaymentBreakdownEntryKindEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PaymentBreakdownEntryKindEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [PaymentBreakdownEntryKindEnum] to String,
/// and [decode] dynamic data back to [PaymentBreakdownEntryKindEnum].
class PaymentBreakdownEntryKindEnumTypeTransformer {
  factory PaymentBreakdownEntryKindEnumTypeTransformer() => _instance ??= const PaymentBreakdownEntryKindEnumTypeTransformer._();

  const PaymentBreakdownEntryKindEnumTypeTransformer._();

  String encode(PaymentBreakdownEntryKindEnum data) => data._value;

  /// Returns the instance of [PaymentBreakdownEntryKindEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  PaymentBreakdownEntryKindEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is PaymentBreakdownEntryKindEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'CASH': return PaymentBreakdownEntryKindEnum.CASH;
        case r'MANUAL_EXTERNAL': return PaymentBreakdownEntryKindEnum.MANUAL_EXTERNAL;
        case r'ONLINE': return PaymentBreakdownEntryKindEnum.ONLINE;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static PaymentBreakdownEntryKindEnumTypeTransformer? _instance;
}


