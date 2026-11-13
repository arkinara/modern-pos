//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class StockCountLine {
  /// Returns a new [StockCountLine] instance.
  StockCountLine({
    required this.stockItemId,
    required this.stockItemName,
    required this.baseUnit,
    required this.quantityScale,
    required this.systemQuantity,
    required this.countedQuantity,
    required this.variance,
  });

  String stockItemId;

  String stockItemName;

  StockCountLineBaseUnitEnum baseUnit;

  /// Minimum value: 0
  /// Maximum value: 6
  int quantityScale;

  String systemQuantity;

  String countedQuantity;

  String variance;

  @override
  bool operator ==(Object other) => identical(this, other) || other is StockCountLine &&
    other.stockItemId == stockItemId &&
    other.stockItemName == stockItemName &&
    other.baseUnit == baseUnit &&
    other.quantityScale == quantityScale &&
    other.systemQuantity == systemQuantity &&
    other.countedQuantity == countedQuantity &&
    other.variance == variance;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (stockItemId.hashCode) +
    (stockItemName.hashCode) +
    (baseUnit.hashCode) +
    (quantityScale.hashCode) +
    (systemQuantity.hashCode) +
    (countedQuantity.hashCode) +
    (variance.hashCode);

  @override
  String toString() => 'StockCountLine[stockItemId=$stockItemId, stockItemName=$stockItemName, baseUnit=$baseUnit, quantityScale=$quantityScale, systemQuantity=$systemQuantity, countedQuantity=$countedQuantity, variance=$variance]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'stockItemId'] = this.stockItemId;
      json[r'stockItemName'] = this.stockItemName;
      json[r'baseUnit'] = this.baseUnit;
      json[r'quantityScale'] = this.quantityScale;
      json[r'systemQuantity'] = this.systemQuantity;
      json[r'countedQuantity'] = this.countedQuantity;
      json[r'variance'] = this.variance;
    return json;
  }

  /// Returns a new [StockCountLine] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static StockCountLine? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'stockItemId'), 'Required key "StockCountLine[stockItemId]" is missing from JSON.');
        assert(json[r'stockItemId'] != null, 'Required key "StockCountLine[stockItemId]" has a null value in JSON.');
        assert(json.containsKey(r'stockItemName'), 'Required key "StockCountLine[stockItemName]" is missing from JSON.');
        assert(json[r'stockItemName'] != null, 'Required key "StockCountLine[stockItemName]" has a null value in JSON.');
        assert(json.containsKey(r'baseUnit'), 'Required key "StockCountLine[baseUnit]" is missing from JSON.');
        assert(json[r'baseUnit'] != null, 'Required key "StockCountLine[baseUnit]" has a null value in JSON.');
        assert(json.containsKey(r'quantityScale'), 'Required key "StockCountLine[quantityScale]" is missing from JSON.');
        assert(json[r'quantityScale'] != null, 'Required key "StockCountLine[quantityScale]" has a null value in JSON.');
        assert(json.containsKey(r'systemQuantity'), 'Required key "StockCountLine[systemQuantity]" is missing from JSON.');
        assert(json[r'systemQuantity'] != null, 'Required key "StockCountLine[systemQuantity]" has a null value in JSON.');
        assert(json.containsKey(r'countedQuantity'), 'Required key "StockCountLine[countedQuantity]" is missing from JSON.');
        assert(json[r'countedQuantity'] != null, 'Required key "StockCountLine[countedQuantity]" has a null value in JSON.');
        assert(json.containsKey(r'variance'), 'Required key "StockCountLine[variance]" is missing from JSON.');
        assert(json[r'variance'] != null, 'Required key "StockCountLine[variance]" has a null value in JSON.');
        return true;
      }());

      return StockCountLine(
        stockItemId: mapValueOfType<String>(json, r'stockItemId')!,
        stockItemName: mapValueOfType<String>(json, r'stockItemName')!,
        baseUnit: StockCountLineBaseUnitEnum.fromJson(json[r'baseUnit'])!,
        quantityScale: mapValueOfType<int>(json, r'quantityScale')!,
        systemQuantity: mapValueOfType<String>(json, r'systemQuantity')!,
        countedQuantity: mapValueOfType<String>(json, r'countedQuantity')!,
        variance: mapValueOfType<String>(json, r'variance')!,
      );
    }
    return null;
  }

  static List<StockCountLine> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <StockCountLine>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = StockCountLine.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, StockCountLine> mapFromJson(dynamic json) {
    final map = <String, StockCountLine>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = StockCountLine.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of StockCountLine-objects as value to a dart map
  static Map<String, List<StockCountLine>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<StockCountLine>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = StockCountLine.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'stockItemId',
    'stockItemName',
    'baseUnit',
    'quantityScale',
    'systemQuantity',
    'countedQuantity',
    'variance',
  };
}


enum StockCountLineBaseUnitEnum {
  g._(r'g'),
  ml._(r'ml'),
  each._(r'each'),
  ;

  /// Instantiate a new enum with the provided value.
  const StockCountLineBaseUnitEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [StockCountLineBaseUnitEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static StockCountLineBaseUnitEnum? fromJson(dynamic value) => StockCountLineBaseUnitEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [StockCountLineBaseUnitEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<StockCountLineBaseUnitEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <StockCountLineBaseUnitEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = StockCountLineBaseUnitEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [StockCountLineBaseUnitEnum] to String,
/// and [decode] dynamic data back to [StockCountLineBaseUnitEnum].
class StockCountLineBaseUnitEnumTypeTransformer {
  factory StockCountLineBaseUnitEnumTypeTransformer() => _instance ??= const StockCountLineBaseUnitEnumTypeTransformer._();

  const StockCountLineBaseUnitEnumTypeTransformer._();

  String encode(StockCountLineBaseUnitEnum data) => data._value;

  /// Returns the instance of [StockCountLineBaseUnitEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  StockCountLineBaseUnitEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is StockCountLineBaseUnitEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'g': return StockCountLineBaseUnitEnum.g;
        case r'ml': return StockCountLineBaseUnitEnum.ml;
        case r'each': return StockCountLineBaseUnitEnum.each;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static StockCountLineBaseUnitEnumTypeTransformer? _instance;
}


