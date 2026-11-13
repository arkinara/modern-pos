//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


enum ChannelOrderState {
  RECEIVED._(r'RECEIVED'),
  ACCEPTED._(r'ACCEPTED'),
  FULFILLED._(r'FULFILLED'),
  CANCELLED._(r'CANCELLED'),
  ;

  /// Instantiate a new enum with the provided value.
  const ChannelOrderState._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [ChannelOrderState] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static ChannelOrderState? fromJson(dynamic value) => ChannelOrderStateTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [ChannelOrderState]
  /// that were successfully decoded from the passed [JSON][json].
  static List<ChannelOrderState> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ChannelOrderState>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ChannelOrderState.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ChannelOrderState] to String,
/// and [decode] dynamic data back to [ChannelOrderState].
class ChannelOrderStateTypeTransformer {
  factory ChannelOrderStateTypeTransformer() => _instance ??= const ChannelOrderStateTypeTransformer._();

  const ChannelOrderStateTypeTransformer._();

  /// Encodes this enum as a value suitable for JSON.
  String encode(ChannelOrderState data) => data._value;

  /// Returns the instance of [ChannelOrderState] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ChannelOrderState? decode(dynamic data, {bool allowNull = true}) {
    if (data is ChannelOrderState) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'RECEIVED': return ChannelOrderState.RECEIVED;
        case r'ACCEPTED': return ChannelOrderState.ACCEPTED;
        case r'FULFILLED': return ChannelOrderState.FULFILLED;
        case r'CANCELLED': return ChannelOrderState.CANCELLED;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static ChannelOrderStateTypeTransformer? _instance;
}

