//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ShiftCashMovementWrite {
  /// Returns a new [ShiftCashMovementWrite] instance.
  ShiftCashMovementWrite({
    required this.kind,
    required this.amountMinor,
    required this.reason,
  });

  ShiftCashMovementWriteKindEnum kind;

  /// Currency minor units; IDR exponent 0 in demo.
  ///
  /// Minimum value: 1
  /// Maximum value: 9007199254740991
  int amountMinor;

  String reason;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ShiftCashMovementWrite &&
    other.kind == kind &&
    other.amountMinor == amountMinor &&
    other.reason == reason;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (kind.hashCode) +
    (amountMinor.hashCode) +
    (reason.hashCode);

  @override
  String toString() => 'ShiftCashMovementWrite[kind=$kind, amountMinor=$amountMinor, reason=$reason]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'kind'] = this.kind;
      json[r'amountMinor'] = this.amountMinor;
      json[r'reason'] = this.reason;
    return json;
  }

  /// Returns a new [ShiftCashMovementWrite] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ShiftCashMovementWrite? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'kind'), 'Required key "ShiftCashMovementWrite[kind]" is missing from JSON.');
        assert(json[r'kind'] != null, 'Required key "ShiftCashMovementWrite[kind]" has a null value in JSON.');
        assert(json.containsKey(r'amountMinor'), 'Required key "ShiftCashMovementWrite[amountMinor]" is missing from JSON.');
        assert(json[r'amountMinor'] != null, 'Required key "ShiftCashMovementWrite[amountMinor]" has a null value in JSON.');
        assert(json.containsKey(r'reason'), 'Required key "ShiftCashMovementWrite[reason]" is missing from JSON.');
        assert(json[r'reason'] != null, 'Required key "ShiftCashMovementWrite[reason]" has a null value in JSON.');
        return true;
      }());

      return ShiftCashMovementWrite(
        kind: ShiftCashMovementWriteKindEnum.fromJson(json[r'kind'])!,
        amountMinor: mapValueOfType<int>(json, r'amountMinor')!,
        reason: mapValueOfType<String>(json, r'reason')!,
      );
    }
    return null;
  }

  static List<ShiftCashMovementWrite> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ShiftCashMovementWrite>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ShiftCashMovementWrite.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ShiftCashMovementWrite> mapFromJson(dynamic json) {
    final map = <String, ShiftCashMovementWrite>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ShiftCashMovementWrite.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ShiftCashMovementWrite-objects as value to a dart map
  static Map<String, List<ShiftCashMovementWrite>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ShiftCashMovementWrite>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ShiftCashMovementWrite.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'kind',
    'amountMinor',
    'reason',
  };
}


enum ShiftCashMovementWriteKindEnum {
  PAID_IN._(r'PAID_IN'),
  PAID_OUT._(r'PAID_OUT'),
  ;

  /// Instantiate a new enum with the provided value.
  const ShiftCashMovementWriteKindEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [ShiftCashMovementWriteKindEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static ShiftCashMovementWriteKindEnum? fromJson(dynamic value) => ShiftCashMovementWriteKindEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [ShiftCashMovementWriteKindEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<ShiftCashMovementWriteKindEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ShiftCashMovementWriteKindEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ShiftCashMovementWriteKindEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ShiftCashMovementWriteKindEnum] to String,
/// and [decode] dynamic data back to [ShiftCashMovementWriteKindEnum].
class ShiftCashMovementWriteKindEnumTypeTransformer {
  factory ShiftCashMovementWriteKindEnumTypeTransformer() => _instance ??= const ShiftCashMovementWriteKindEnumTypeTransformer._();

  const ShiftCashMovementWriteKindEnumTypeTransformer._();

  String encode(ShiftCashMovementWriteKindEnum data) => data._value;

  /// Returns the instance of [ShiftCashMovementWriteKindEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ShiftCashMovementWriteKindEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is ShiftCashMovementWriteKindEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'PAID_IN': return ShiftCashMovementWriteKindEnum.PAID_IN;
        case r'PAID_OUT': return ShiftCashMovementWriteKindEnum.PAID_OUT;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static ShiftCashMovementWriteKindEnumTypeTransformer? _instance;
}


