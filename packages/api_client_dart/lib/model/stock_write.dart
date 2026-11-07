//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class StockWrite {
  /// Returns a new [StockWrite] instance.
  StockWrite({
    required this.name,
    required this.baseUnit,
    required this.quantityScale,
    required this.reorderThreshold,
  });

  String name;

  StockWriteBaseUnitEnum baseUnit;

  /// Minimum value: 0
  /// Maximum value: 6
  int quantityScale;

  /// Nonnegative fixed-point base-unit quantity. Business validation rejects zero where a positive quantity is required.
  String reorderThreshold;

  @override
  bool operator ==(Object other) => identical(this, other) || other is StockWrite &&
    other.name == name &&
    other.baseUnit == baseUnit &&
    other.quantityScale == quantityScale &&
    other.reorderThreshold == reorderThreshold;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (name.hashCode) +
    (baseUnit.hashCode) +
    (quantityScale.hashCode) +
    (reorderThreshold.hashCode);

  @override
  String toString() => 'StockWrite[name=$name, baseUnit=$baseUnit, quantityScale=$quantityScale, reorderThreshold=$reorderThreshold]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'name'] = this.name;
      json[r'baseUnit'] = this.baseUnit;
      json[r'quantityScale'] = this.quantityScale;
      json[r'reorderThreshold'] = this.reorderThreshold;
    return json;
  }

  /// Returns a new [StockWrite] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static StockWrite? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'name'), 'Required key "StockWrite[name]" is missing from JSON.');
        assert(json[r'name'] != null, 'Required key "StockWrite[name]" has a null value in JSON.');
        assert(json.containsKey(r'baseUnit'), 'Required key "StockWrite[baseUnit]" is missing from JSON.');
        assert(json[r'baseUnit'] != null, 'Required key "StockWrite[baseUnit]" has a null value in JSON.');
        assert(json.containsKey(r'quantityScale'), 'Required key "StockWrite[quantityScale]" is missing from JSON.');
        assert(json[r'quantityScale'] != null, 'Required key "StockWrite[quantityScale]" has a null value in JSON.');
        assert(json.containsKey(r'reorderThreshold'), 'Required key "StockWrite[reorderThreshold]" is missing from JSON.');
        assert(json[r'reorderThreshold'] != null, 'Required key "StockWrite[reorderThreshold]" has a null value in JSON.');
        return true;
      }());

      return StockWrite(
        name: mapValueOfType<String>(json, r'name')!,
        baseUnit: StockWriteBaseUnitEnum.fromJson(json[r'baseUnit'])!,
        quantityScale: mapValueOfType<int>(json, r'quantityScale')!,
        reorderThreshold: mapValueOfType<String>(json, r'reorderThreshold')!,
      );
    }
    return null;
  }

  static List<StockWrite> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <StockWrite>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = StockWrite.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, StockWrite> mapFromJson(dynamic json) {
    final map = <String, StockWrite>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = StockWrite.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of StockWrite-objects as value to a dart map
  static Map<String, List<StockWrite>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<StockWrite>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = StockWrite.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'name',
    'baseUnit',
    'quantityScale',
    'reorderThreshold',
  };
}


enum StockWriteBaseUnitEnum {
  g._(r'g'),
  ml._(r'ml'),
  each._(r'each'),
  ;

  /// Instantiate a new enum with the provided value.
  const StockWriteBaseUnitEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [StockWriteBaseUnitEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static StockWriteBaseUnitEnum? fromJson(dynamic value) => StockWriteBaseUnitEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [StockWriteBaseUnitEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<StockWriteBaseUnitEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <StockWriteBaseUnitEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = StockWriteBaseUnitEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [StockWriteBaseUnitEnum] to String,
/// and [decode] dynamic data back to [StockWriteBaseUnitEnum].
class StockWriteBaseUnitEnumTypeTransformer {
  factory StockWriteBaseUnitEnumTypeTransformer() => _instance ??= const StockWriteBaseUnitEnumTypeTransformer._();

  const StockWriteBaseUnitEnumTypeTransformer._();

  String encode(StockWriteBaseUnitEnum data) => data._value;

  /// Returns the instance of [StockWriteBaseUnitEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  StockWriteBaseUnitEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is StockWriteBaseUnitEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'g': return StockWriteBaseUnitEnum.g;
        case r'ml': return StockWriteBaseUnitEnum.ml;
        case r'each': return StockWriteBaseUnitEnum.each;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static StockWriteBaseUnitEnumTypeTransformer? _instance;
}


