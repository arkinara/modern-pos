//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class DailyReportPaymentBreakdownInner {
  /// Returns a new [DailyReportPaymentBreakdownInner] instance.
  DailyReportPaymentBreakdownInner({
    required this.kind,
    required this.receivedMinor,
  });

  DailyReportPaymentBreakdownInnerKindEnum kind;

  /// Currency minor units; IDR exponent 0 in demo.
  ///
  /// Minimum value: 0
  /// Maximum value: 9007199254740991
  int receivedMinor;

  @override
  bool operator ==(Object other) => identical(this, other) || other is DailyReportPaymentBreakdownInner &&
    other.kind == kind &&
    other.receivedMinor == receivedMinor;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (kind.hashCode) +
    (receivedMinor.hashCode);

  @override
  String toString() => 'DailyReportPaymentBreakdownInner[kind=$kind, receivedMinor=$receivedMinor]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'kind'] = this.kind;
      json[r'receivedMinor'] = this.receivedMinor;
    return json;
  }

  /// Returns a new [DailyReportPaymentBreakdownInner] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static DailyReportPaymentBreakdownInner? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'kind'), 'Required key "DailyReportPaymentBreakdownInner[kind]" is missing from JSON.');
        assert(json[r'kind'] != null, 'Required key "DailyReportPaymentBreakdownInner[kind]" has a null value in JSON.');
        assert(json.containsKey(r'receivedMinor'), 'Required key "DailyReportPaymentBreakdownInner[receivedMinor]" is missing from JSON.');
        assert(json[r'receivedMinor'] != null, 'Required key "DailyReportPaymentBreakdownInner[receivedMinor]" has a null value in JSON.');
        return true;
      }());

      return DailyReportPaymentBreakdownInner(
        kind: DailyReportPaymentBreakdownInnerKindEnum.fromJson(json[r'kind'])!,
        receivedMinor: mapValueOfType<int>(json, r'receivedMinor')!,
      );
    }
    return null;
  }

  static List<DailyReportPaymentBreakdownInner> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DailyReportPaymentBreakdownInner>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DailyReportPaymentBreakdownInner.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, DailyReportPaymentBreakdownInner> mapFromJson(dynamic json) {
    final map = <String, DailyReportPaymentBreakdownInner>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = DailyReportPaymentBreakdownInner.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of DailyReportPaymentBreakdownInner-objects as value to a dart map
  static Map<String, List<DailyReportPaymentBreakdownInner>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<DailyReportPaymentBreakdownInner>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = DailyReportPaymentBreakdownInner.listFromJson(entry.value, growable: growable,);
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


enum DailyReportPaymentBreakdownInnerKindEnum {
  CASH._(r'CASH'),
  MANUAL_EXTERNAL._(r'MANUAL_EXTERNAL'),
  ;

  /// Instantiate a new enum with the provided value.
  const DailyReportPaymentBreakdownInnerKindEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [DailyReportPaymentBreakdownInnerKindEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static DailyReportPaymentBreakdownInnerKindEnum? fromJson(dynamic value) => DailyReportPaymentBreakdownInnerKindEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [DailyReportPaymentBreakdownInnerKindEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<DailyReportPaymentBreakdownInnerKindEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DailyReportPaymentBreakdownInnerKindEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DailyReportPaymentBreakdownInnerKindEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [DailyReportPaymentBreakdownInnerKindEnum] to String,
/// and [decode] dynamic data back to [DailyReportPaymentBreakdownInnerKindEnum].
class DailyReportPaymentBreakdownInnerKindEnumTypeTransformer {
  factory DailyReportPaymentBreakdownInnerKindEnumTypeTransformer() => _instance ??= const DailyReportPaymentBreakdownInnerKindEnumTypeTransformer._();

  const DailyReportPaymentBreakdownInnerKindEnumTypeTransformer._();

  String encode(DailyReportPaymentBreakdownInnerKindEnum data) => data._value;

  /// Returns the instance of [DailyReportPaymentBreakdownInnerKindEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  DailyReportPaymentBreakdownInnerKindEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is DailyReportPaymentBreakdownInnerKindEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'CASH': return DailyReportPaymentBreakdownInnerKindEnum.CASH;
        case r'MANUAL_EXTERNAL': return DailyReportPaymentBreakdownInnerKindEnum.MANUAL_EXTERNAL;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static DailyReportPaymentBreakdownInnerKindEnumTypeTransformer? _instance;
}


