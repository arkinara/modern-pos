//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class OutletTransferLine {
  /// Returns a new [OutletTransferLine] instance.
  OutletTransferLine({
    required this.id,
    required this.stockItemId,
    required this.stockItemName,
    required this.baseUnit,
    required this.quantityScale,
    required this.dispatchedQuantity,
    required this.receivedQuantity,
    required this.inTransitQuantity,
  });

  String id;

  String stockItemId;

  String stockItemName;

  OutletTransferLineBaseUnitEnum baseUnit;

  /// Minimum value: 0
  /// Maximum value: 6
  int quantityScale;

  String dispatchedQuantity;

  String receivedQuantity;

  String inTransitQuantity;

  @override
  bool operator ==(Object other) => identical(this, other) || other is OutletTransferLine &&
    other.id == id &&
    other.stockItemId == stockItemId &&
    other.stockItemName == stockItemName &&
    other.baseUnit == baseUnit &&
    other.quantityScale == quantityScale &&
    other.dispatchedQuantity == dispatchedQuantity &&
    other.receivedQuantity == receivedQuantity &&
    other.inTransitQuantity == inTransitQuantity;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (stockItemId.hashCode) +
    (stockItemName.hashCode) +
    (baseUnit.hashCode) +
    (quantityScale.hashCode) +
    (dispatchedQuantity.hashCode) +
    (receivedQuantity.hashCode) +
    (inTransitQuantity.hashCode);

  @override
  String toString() => 'OutletTransferLine[id=$id, stockItemId=$stockItemId, stockItemName=$stockItemName, baseUnit=$baseUnit, quantityScale=$quantityScale, dispatchedQuantity=$dispatchedQuantity, receivedQuantity=$receivedQuantity, inTransitQuantity=$inTransitQuantity]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'stockItemId'] = this.stockItemId;
      json[r'stockItemName'] = this.stockItemName;
      json[r'baseUnit'] = this.baseUnit;
      json[r'quantityScale'] = this.quantityScale;
      json[r'dispatchedQuantity'] = this.dispatchedQuantity;
      json[r'receivedQuantity'] = this.receivedQuantity;
      json[r'inTransitQuantity'] = this.inTransitQuantity;
    return json;
  }

  /// Returns a new [OutletTransferLine] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static OutletTransferLine? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "OutletTransferLine[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "OutletTransferLine[id]" has a null value in JSON.');
        assert(json.containsKey(r'stockItemId'), 'Required key "OutletTransferLine[stockItemId]" is missing from JSON.');
        assert(json[r'stockItemId'] != null, 'Required key "OutletTransferLine[stockItemId]" has a null value in JSON.');
        assert(json.containsKey(r'stockItemName'), 'Required key "OutletTransferLine[stockItemName]" is missing from JSON.');
        assert(json[r'stockItemName'] != null, 'Required key "OutletTransferLine[stockItemName]" has a null value in JSON.');
        assert(json.containsKey(r'baseUnit'), 'Required key "OutletTransferLine[baseUnit]" is missing from JSON.');
        assert(json[r'baseUnit'] != null, 'Required key "OutletTransferLine[baseUnit]" has a null value in JSON.');
        assert(json.containsKey(r'quantityScale'), 'Required key "OutletTransferLine[quantityScale]" is missing from JSON.');
        assert(json[r'quantityScale'] != null, 'Required key "OutletTransferLine[quantityScale]" has a null value in JSON.');
        assert(json.containsKey(r'dispatchedQuantity'), 'Required key "OutletTransferLine[dispatchedQuantity]" is missing from JSON.');
        assert(json[r'dispatchedQuantity'] != null, 'Required key "OutletTransferLine[dispatchedQuantity]" has a null value in JSON.');
        assert(json.containsKey(r'receivedQuantity'), 'Required key "OutletTransferLine[receivedQuantity]" is missing from JSON.');
        assert(json[r'receivedQuantity'] != null, 'Required key "OutletTransferLine[receivedQuantity]" has a null value in JSON.');
        assert(json.containsKey(r'inTransitQuantity'), 'Required key "OutletTransferLine[inTransitQuantity]" is missing from JSON.');
        assert(json[r'inTransitQuantity'] != null, 'Required key "OutletTransferLine[inTransitQuantity]" has a null value in JSON.');
        return true;
      }());

      return OutletTransferLine(
        id: mapValueOfType<String>(json, r'id')!,
        stockItemId: mapValueOfType<String>(json, r'stockItemId')!,
        stockItemName: mapValueOfType<String>(json, r'stockItemName')!,
        baseUnit: OutletTransferLineBaseUnitEnum.fromJson(json[r'baseUnit'])!,
        quantityScale: mapValueOfType<int>(json, r'quantityScale')!,
        dispatchedQuantity: mapValueOfType<String>(json, r'dispatchedQuantity')!,
        receivedQuantity: mapValueOfType<String>(json, r'receivedQuantity')!,
        inTransitQuantity: mapValueOfType<String>(json, r'inTransitQuantity')!,
      );
    }
    return null;
  }

  static List<OutletTransferLine> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <OutletTransferLine>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = OutletTransferLine.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, OutletTransferLine> mapFromJson(dynamic json) {
    final map = <String, OutletTransferLine>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = OutletTransferLine.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of OutletTransferLine-objects as value to a dart map
  static Map<String, List<OutletTransferLine>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<OutletTransferLine>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = OutletTransferLine.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'stockItemId',
    'stockItemName',
    'baseUnit',
    'quantityScale',
    'dispatchedQuantity',
    'receivedQuantity',
    'inTransitQuantity',
  };
}


enum OutletTransferLineBaseUnitEnum {
  g._(r'g'),
  ml._(r'ml'),
  each._(r'each'),
  ;

  /// Instantiate a new enum with the provided value.
  const OutletTransferLineBaseUnitEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [OutletTransferLineBaseUnitEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static OutletTransferLineBaseUnitEnum? fromJson(dynamic value) => OutletTransferLineBaseUnitEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [OutletTransferLineBaseUnitEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<OutletTransferLineBaseUnitEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <OutletTransferLineBaseUnitEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = OutletTransferLineBaseUnitEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [OutletTransferLineBaseUnitEnum] to String,
/// and [decode] dynamic data back to [OutletTransferLineBaseUnitEnum].
class OutletTransferLineBaseUnitEnumTypeTransformer {
  factory OutletTransferLineBaseUnitEnumTypeTransformer() => _instance ??= const OutletTransferLineBaseUnitEnumTypeTransformer._();

  const OutletTransferLineBaseUnitEnumTypeTransformer._();

  String encode(OutletTransferLineBaseUnitEnum data) => data._value;

  /// Returns the instance of [OutletTransferLineBaseUnitEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  OutletTransferLineBaseUnitEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is OutletTransferLineBaseUnitEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'g': return OutletTransferLineBaseUnitEnum.g;
        case r'ml': return OutletTransferLineBaseUnitEnum.ml;
        case r'each': return OutletTransferLineBaseUnitEnum.each;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static OutletTransferLineBaseUnitEnumTypeTransformer? _instance;
}


