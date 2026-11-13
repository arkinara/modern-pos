//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CostingUpdate {
  /// Returns a new [CostingUpdate] instance.
  CostingUpdate({
    required this.costingMethod,
  });

  CostingUpdateCostingMethodEnum costingMethod;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CostingUpdate &&
    other.costingMethod == costingMethod;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (costingMethod.hashCode);

  @override
  String toString() => 'CostingUpdate[costingMethod=$costingMethod]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'costingMethod'] = this.costingMethod;
    return json;
  }

  /// Returns a new [CostingUpdate] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CostingUpdate? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'costingMethod'), 'Required key "CostingUpdate[costingMethod]" is missing from JSON.');
        assert(json[r'costingMethod'] != null, 'Required key "CostingUpdate[costingMethod]" has a null value in JSON.');
        return true;
      }());

      return CostingUpdate(
        costingMethod: CostingUpdateCostingMethodEnum.fromJson(json[r'costingMethod'])!,
      );
    }
    return null;
  }

  static List<CostingUpdate> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CostingUpdate>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CostingUpdate.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CostingUpdate> mapFromJson(dynamic json) {
    final map = <String, CostingUpdate>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CostingUpdate.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CostingUpdate-objects as value to a dart map
  static Map<String, List<CostingUpdate>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CostingUpdate>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CostingUpdate.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'costingMethod',
  };
}


enum CostingUpdateCostingMethodEnum {
  MOVING_AVERAGE._(r'MOVING_AVERAGE'),
  LAST_PURCHASE._(r'LAST_PURCHASE'),
  ;

  /// Instantiate a new enum with the provided value.
  const CostingUpdateCostingMethodEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [CostingUpdateCostingMethodEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static CostingUpdateCostingMethodEnum? fromJson(dynamic value) => CostingUpdateCostingMethodEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [CostingUpdateCostingMethodEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<CostingUpdateCostingMethodEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CostingUpdateCostingMethodEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CostingUpdateCostingMethodEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [CostingUpdateCostingMethodEnum] to String,
/// and [decode] dynamic data back to [CostingUpdateCostingMethodEnum].
class CostingUpdateCostingMethodEnumTypeTransformer {
  factory CostingUpdateCostingMethodEnumTypeTransformer() => _instance ??= const CostingUpdateCostingMethodEnumTypeTransformer._();

  const CostingUpdateCostingMethodEnumTypeTransformer._();

  String encode(CostingUpdateCostingMethodEnum data) => data._value;

  /// Returns the instance of [CostingUpdateCostingMethodEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  CostingUpdateCostingMethodEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is CostingUpdateCostingMethodEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'MOVING_AVERAGE': return CostingUpdateCostingMethodEnum.MOVING_AVERAGE;
        case r'LAST_PURCHASE': return CostingUpdateCostingMethodEnum.LAST_PURCHASE;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static CostingUpdateCostingMethodEnumTypeTransformer? _instance;
}


