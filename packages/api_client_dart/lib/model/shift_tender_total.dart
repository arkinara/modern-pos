//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ShiftTenderTotal {
  /// Returns a new [ShiftTenderTotal] instance.
  ShiftTenderTotal({
    required this.kind,
    required this.count,
    required this.amountMinor,
  });

  ShiftTenderTotalKindEnum kind;

  /// Minimum value: 0
  int count;

  /// Currency minor units; IDR exponent 0 in demo.
  ///
  /// Minimum value: 0
  /// Maximum value: 9007199254740991
  int amountMinor;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ShiftTenderTotal &&
    other.kind == kind &&
    other.count == count &&
    other.amountMinor == amountMinor;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (kind.hashCode) +
    (count.hashCode) +
    (amountMinor.hashCode);

  @override
  String toString() => 'ShiftTenderTotal[kind=$kind, count=$count, amountMinor=$amountMinor]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'kind'] = this.kind;
      json[r'count'] = this.count;
      json[r'amountMinor'] = this.amountMinor;
    return json;
  }

  /// Returns a new [ShiftTenderTotal] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ShiftTenderTotal? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'kind'), 'Required key "ShiftTenderTotal[kind]" is missing from JSON.');
        assert(json[r'kind'] != null, 'Required key "ShiftTenderTotal[kind]" has a null value in JSON.');
        assert(json.containsKey(r'count'), 'Required key "ShiftTenderTotal[count]" is missing from JSON.');
        assert(json[r'count'] != null, 'Required key "ShiftTenderTotal[count]" has a null value in JSON.');
        assert(json.containsKey(r'amountMinor'), 'Required key "ShiftTenderTotal[amountMinor]" is missing from JSON.');
        assert(json[r'amountMinor'] != null, 'Required key "ShiftTenderTotal[amountMinor]" has a null value in JSON.');
        return true;
      }());

      return ShiftTenderTotal(
        kind: ShiftTenderTotalKindEnum.fromJson(json[r'kind'])!,
        count: mapValueOfType<int>(json, r'count')!,
        amountMinor: mapValueOfType<int>(json, r'amountMinor')!,
      );
    }
    return null;
  }

  static List<ShiftTenderTotal> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ShiftTenderTotal>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ShiftTenderTotal.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ShiftTenderTotal> mapFromJson(dynamic json) {
    final map = <String, ShiftTenderTotal>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ShiftTenderTotal.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ShiftTenderTotal-objects as value to a dart map
  static Map<String, List<ShiftTenderTotal>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ShiftTenderTotal>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ShiftTenderTotal.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'kind',
    'count',
    'amountMinor',
  };
}


enum ShiftTenderTotalKindEnum {
  CASH._(r'CASH'),
  MANUAL_EXTERNAL._(r'MANUAL_EXTERNAL'),
  ONLINE._(r'ONLINE'),
  ;

  /// Instantiate a new enum with the provided value.
  const ShiftTenderTotalKindEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [ShiftTenderTotalKindEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static ShiftTenderTotalKindEnum? fromJson(dynamic value) => ShiftTenderTotalKindEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [ShiftTenderTotalKindEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<ShiftTenderTotalKindEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ShiftTenderTotalKindEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ShiftTenderTotalKindEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ShiftTenderTotalKindEnum] to String,
/// and [decode] dynamic data back to [ShiftTenderTotalKindEnum].
class ShiftTenderTotalKindEnumTypeTransformer {
  factory ShiftTenderTotalKindEnumTypeTransformer() => _instance ??= const ShiftTenderTotalKindEnumTypeTransformer._();

  const ShiftTenderTotalKindEnumTypeTransformer._();

  String encode(ShiftTenderTotalKindEnum data) => data._value;

  /// Returns the instance of [ShiftTenderTotalKindEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ShiftTenderTotalKindEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is ShiftTenderTotalKindEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'CASH': return ShiftTenderTotalKindEnum.CASH;
        case r'MANUAL_EXTERNAL': return ShiftTenderTotalKindEnum.MANUAL_EXTERNAL;
        case r'ONLINE': return ShiftTenderTotalKindEnum.ONLINE;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static ShiftTenderTotalKindEnumTypeTransformer? _instance;
}


