//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Stock {
  /// Returns a new [Stock] instance.
  Stock({
    required this.id,
    required this.name,
    required this.baseUnit,
    required this.quantityScale,
    required this.reorderThreshold,
    required this.quantity,
    required this.version,
  });

  String id;

  String name;

  StockBaseUnitEnum baseUnit;

  /// Minimum value: 0
  /// Maximum value: 6
  int quantityScale;

  /// Nonnegative fixed-point base-unit quantity. Business validation rejects zero where a positive quantity is required.
  String reorderThreshold;

  /// Nonnegative fixed-point base-unit quantity. Business validation rejects zero where a positive quantity is required.
  String quantity;

  /// Minimum value: 1
  int version;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Stock &&
    other.id == id &&
    other.name == name &&
    other.baseUnit == baseUnit &&
    other.quantityScale == quantityScale &&
    other.reorderThreshold == reorderThreshold &&
    other.quantity == quantity &&
    other.version == version;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (name.hashCode) +
    (baseUnit.hashCode) +
    (quantityScale.hashCode) +
    (reorderThreshold.hashCode) +
    (quantity.hashCode) +
    (version.hashCode);

  @override
  String toString() => 'Stock[id=$id, name=$name, baseUnit=$baseUnit, quantityScale=$quantityScale, reorderThreshold=$reorderThreshold, quantity=$quantity, version=$version]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'name'] = this.name;
      json[r'baseUnit'] = this.baseUnit;
      json[r'quantityScale'] = this.quantityScale;
      json[r'reorderThreshold'] = this.reorderThreshold;
      json[r'quantity'] = this.quantity;
      json[r'version'] = this.version;
    return json;
  }

  /// Returns a new [Stock] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Stock? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "Stock[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "Stock[id]" has a null value in JSON.');
        assert(json.containsKey(r'name'), 'Required key "Stock[name]" is missing from JSON.');
        assert(json[r'name'] != null, 'Required key "Stock[name]" has a null value in JSON.');
        assert(json.containsKey(r'baseUnit'), 'Required key "Stock[baseUnit]" is missing from JSON.');
        assert(json[r'baseUnit'] != null, 'Required key "Stock[baseUnit]" has a null value in JSON.');
        assert(json.containsKey(r'quantityScale'), 'Required key "Stock[quantityScale]" is missing from JSON.');
        assert(json[r'quantityScale'] != null, 'Required key "Stock[quantityScale]" has a null value in JSON.');
        assert(json.containsKey(r'reorderThreshold'), 'Required key "Stock[reorderThreshold]" is missing from JSON.');
        assert(json[r'reorderThreshold'] != null, 'Required key "Stock[reorderThreshold]" has a null value in JSON.');
        assert(json.containsKey(r'quantity'), 'Required key "Stock[quantity]" is missing from JSON.');
        assert(json[r'quantity'] != null, 'Required key "Stock[quantity]" has a null value in JSON.');
        assert(json.containsKey(r'version'), 'Required key "Stock[version]" is missing from JSON.');
        assert(json[r'version'] != null, 'Required key "Stock[version]" has a null value in JSON.');
        return true;
      }());

      return Stock(
        id: mapValueOfType<String>(json, r'id')!,
        name: mapValueOfType<String>(json, r'name')!,
        baseUnit: StockBaseUnitEnum.fromJson(json[r'baseUnit'])!,
        quantityScale: mapValueOfType<int>(json, r'quantityScale')!,
        reorderThreshold: mapValueOfType<String>(json, r'reorderThreshold')!,
        quantity: mapValueOfType<String>(json, r'quantity')!,
        version: mapValueOfType<int>(json, r'version')!,
      );
    }
    return null;
  }

  static List<Stock> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Stock>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Stock.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Stock> mapFromJson(dynamic json) {
    final map = <String, Stock>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Stock.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Stock-objects as value to a dart map
  static Map<String, List<Stock>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Stock>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Stock.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'name',
    'baseUnit',
    'quantityScale',
    'reorderThreshold',
    'quantity',
    'version',
  };
}


enum StockBaseUnitEnum {
  g._(r'g'),
  ml._(r'ml'),
  each._(r'each'),
  ;

  /// Instantiate a new enum with the provided value.
  const StockBaseUnitEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [StockBaseUnitEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static StockBaseUnitEnum? fromJson(dynamic value) => StockBaseUnitEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [StockBaseUnitEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<StockBaseUnitEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <StockBaseUnitEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = StockBaseUnitEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [StockBaseUnitEnum] to String,
/// and [decode] dynamic data back to [StockBaseUnitEnum].
class StockBaseUnitEnumTypeTransformer {
  factory StockBaseUnitEnumTypeTransformer() => _instance ??= const StockBaseUnitEnumTypeTransformer._();

  const StockBaseUnitEnumTypeTransformer._();

  String encode(StockBaseUnitEnum data) => data._value;

  /// Returns the instance of [StockBaseUnitEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  StockBaseUnitEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is StockBaseUnitEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'g': return StockBaseUnitEnum.g;
        case r'ml': return StockBaseUnitEnum.ml;
        case r'each': return StockBaseUnitEnum.each;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static StockBaseUnitEnumTypeTransformer? _instance;
}


