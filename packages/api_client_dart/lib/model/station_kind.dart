//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


enum StationKind {
  KITCHEN._(r'KITCHEN'),
  BAR._(r'BAR'),
  COLD._(r'COLD'),
  HOT._(r'HOT'),
  OTHER._(r'OTHER'),
  ;

  /// Instantiate a new enum with the provided value.
  const StationKind._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [StationKind] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static StationKind? fromJson(dynamic value) => StationKindTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [StationKind]
  /// that were successfully decoded from the passed [JSON][json].
  static List<StationKind> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <StationKind>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = StationKind.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [StationKind] to String,
/// and [decode] dynamic data back to [StationKind].
class StationKindTypeTransformer {
  factory StationKindTypeTransformer() => _instance ??= const StationKindTypeTransformer._();

  const StationKindTypeTransformer._();

  /// Encodes this enum as a value suitable for JSON.
  String encode(StationKind data) => data._value;

  /// Returns the instance of [StationKind] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  StationKind? decode(dynamic data, {bool allowNull = true}) {
    if (data is StationKind) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'KITCHEN': return StationKind.KITCHEN;
        case r'BAR': return StationKind.BAR;
        case r'COLD': return StationKind.COLD;
        case r'HOT': return StationKind.HOT;
        case r'OTHER': return StationKind.OTHER;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static StationKindTypeTransformer? _instance;
}

