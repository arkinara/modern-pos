//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PurchaseOrderLine {
  /// Returns a new [PurchaseOrderLine] instance.
  PurchaseOrderLine({
    required this.id,
    required this.stockItemId,
    required this.stockItemName,
    required this.baseUnit,
    required this.quantityScale,
    required this.supplierUnit,
    required this.unitsPerSupplierUnit,
    required this.orderedQuantity,
    required this.receivedQuantity,
    required this.remainingQuantity,
    required this.orderedBaseQuantity,
    required this.receivedBaseQuantity,
    required this.remainingBaseQuantity,
    required this.unitPrice,
    required this.version,
  });

  String id;

  String stockItemId;

  String stockItemName;

  PurchaseOrderLineBaseUnitEnum baseUnit;

  /// Minimum value: 0
  /// Maximum value: 6
  int quantityScale;

  String supplierUnit;

  String unitsPerSupplierUnit;

  String orderedQuantity;

  String receivedQuantity;

  String remainingQuantity;

  String orderedBaseQuantity;

  String receivedBaseQuantity;

  String remainingBaseQuantity;

  String unitPrice;

  /// Minimum value: 1
  int version;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PurchaseOrderLine &&
    other.id == id &&
    other.stockItemId == stockItemId &&
    other.stockItemName == stockItemName &&
    other.baseUnit == baseUnit &&
    other.quantityScale == quantityScale &&
    other.supplierUnit == supplierUnit &&
    other.unitsPerSupplierUnit == unitsPerSupplierUnit &&
    other.orderedQuantity == orderedQuantity &&
    other.receivedQuantity == receivedQuantity &&
    other.remainingQuantity == remainingQuantity &&
    other.orderedBaseQuantity == orderedBaseQuantity &&
    other.receivedBaseQuantity == receivedBaseQuantity &&
    other.remainingBaseQuantity == remainingBaseQuantity &&
    other.unitPrice == unitPrice &&
    other.version == version;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (stockItemId.hashCode) +
    (stockItemName.hashCode) +
    (baseUnit.hashCode) +
    (quantityScale.hashCode) +
    (supplierUnit.hashCode) +
    (unitsPerSupplierUnit.hashCode) +
    (orderedQuantity.hashCode) +
    (receivedQuantity.hashCode) +
    (remainingQuantity.hashCode) +
    (orderedBaseQuantity.hashCode) +
    (receivedBaseQuantity.hashCode) +
    (remainingBaseQuantity.hashCode) +
    (unitPrice.hashCode) +
    (version.hashCode);

  @override
  String toString() => 'PurchaseOrderLine[id=$id, stockItemId=$stockItemId, stockItemName=$stockItemName, baseUnit=$baseUnit, quantityScale=$quantityScale, supplierUnit=$supplierUnit, unitsPerSupplierUnit=$unitsPerSupplierUnit, orderedQuantity=$orderedQuantity, receivedQuantity=$receivedQuantity, remainingQuantity=$remainingQuantity, orderedBaseQuantity=$orderedBaseQuantity, receivedBaseQuantity=$receivedBaseQuantity, remainingBaseQuantity=$remainingBaseQuantity, unitPrice=$unitPrice, version=$version]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'stockItemId'] = this.stockItemId;
      json[r'stockItemName'] = this.stockItemName;
      json[r'baseUnit'] = this.baseUnit;
      json[r'quantityScale'] = this.quantityScale;
      json[r'supplierUnit'] = this.supplierUnit;
      json[r'unitsPerSupplierUnit'] = this.unitsPerSupplierUnit;
      json[r'orderedQuantity'] = this.orderedQuantity;
      json[r'receivedQuantity'] = this.receivedQuantity;
      json[r'remainingQuantity'] = this.remainingQuantity;
      json[r'orderedBaseQuantity'] = this.orderedBaseQuantity;
      json[r'receivedBaseQuantity'] = this.receivedBaseQuantity;
      json[r'remainingBaseQuantity'] = this.remainingBaseQuantity;
      json[r'unitPrice'] = this.unitPrice;
      json[r'version'] = this.version;
    return json;
  }

  /// Returns a new [PurchaseOrderLine] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PurchaseOrderLine? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "PurchaseOrderLine[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "PurchaseOrderLine[id]" has a null value in JSON.');
        assert(json.containsKey(r'stockItemId'), 'Required key "PurchaseOrderLine[stockItemId]" is missing from JSON.');
        assert(json[r'stockItemId'] != null, 'Required key "PurchaseOrderLine[stockItemId]" has a null value in JSON.');
        assert(json.containsKey(r'stockItemName'), 'Required key "PurchaseOrderLine[stockItemName]" is missing from JSON.');
        assert(json[r'stockItemName'] != null, 'Required key "PurchaseOrderLine[stockItemName]" has a null value in JSON.');
        assert(json.containsKey(r'baseUnit'), 'Required key "PurchaseOrderLine[baseUnit]" is missing from JSON.');
        assert(json[r'baseUnit'] != null, 'Required key "PurchaseOrderLine[baseUnit]" has a null value in JSON.');
        assert(json.containsKey(r'quantityScale'), 'Required key "PurchaseOrderLine[quantityScale]" is missing from JSON.');
        assert(json[r'quantityScale'] != null, 'Required key "PurchaseOrderLine[quantityScale]" has a null value in JSON.');
        assert(json.containsKey(r'supplierUnit'), 'Required key "PurchaseOrderLine[supplierUnit]" is missing from JSON.');
        assert(json[r'supplierUnit'] != null, 'Required key "PurchaseOrderLine[supplierUnit]" has a null value in JSON.');
        assert(json.containsKey(r'unitsPerSupplierUnit'), 'Required key "PurchaseOrderLine[unitsPerSupplierUnit]" is missing from JSON.');
        assert(json[r'unitsPerSupplierUnit'] != null, 'Required key "PurchaseOrderLine[unitsPerSupplierUnit]" has a null value in JSON.');
        assert(json.containsKey(r'orderedQuantity'), 'Required key "PurchaseOrderLine[orderedQuantity]" is missing from JSON.');
        assert(json[r'orderedQuantity'] != null, 'Required key "PurchaseOrderLine[orderedQuantity]" has a null value in JSON.');
        assert(json.containsKey(r'receivedQuantity'), 'Required key "PurchaseOrderLine[receivedQuantity]" is missing from JSON.');
        assert(json[r'receivedQuantity'] != null, 'Required key "PurchaseOrderLine[receivedQuantity]" has a null value in JSON.');
        assert(json.containsKey(r'remainingQuantity'), 'Required key "PurchaseOrderLine[remainingQuantity]" is missing from JSON.');
        assert(json[r'remainingQuantity'] != null, 'Required key "PurchaseOrderLine[remainingQuantity]" has a null value in JSON.');
        assert(json.containsKey(r'orderedBaseQuantity'), 'Required key "PurchaseOrderLine[orderedBaseQuantity]" is missing from JSON.');
        assert(json[r'orderedBaseQuantity'] != null, 'Required key "PurchaseOrderLine[orderedBaseQuantity]" has a null value in JSON.');
        assert(json.containsKey(r'receivedBaseQuantity'), 'Required key "PurchaseOrderLine[receivedBaseQuantity]" is missing from JSON.');
        assert(json[r'receivedBaseQuantity'] != null, 'Required key "PurchaseOrderLine[receivedBaseQuantity]" has a null value in JSON.');
        assert(json.containsKey(r'remainingBaseQuantity'), 'Required key "PurchaseOrderLine[remainingBaseQuantity]" is missing from JSON.');
        assert(json[r'remainingBaseQuantity'] != null, 'Required key "PurchaseOrderLine[remainingBaseQuantity]" has a null value in JSON.');
        assert(json.containsKey(r'unitPrice'), 'Required key "PurchaseOrderLine[unitPrice]" is missing from JSON.');
        assert(json[r'unitPrice'] != null, 'Required key "PurchaseOrderLine[unitPrice]" has a null value in JSON.');
        assert(json.containsKey(r'version'), 'Required key "PurchaseOrderLine[version]" is missing from JSON.');
        assert(json[r'version'] != null, 'Required key "PurchaseOrderLine[version]" has a null value in JSON.');
        return true;
      }());

      return PurchaseOrderLine(
        id: mapValueOfType<String>(json, r'id')!,
        stockItemId: mapValueOfType<String>(json, r'stockItemId')!,
        stockItemName: mapValueOfType<String>(json, r'stockItemName')!,
        baseUnit: PurchaseOrderLineBaseUnitEnum.fromJson(json[r'baseUnit'])!,
        quantityScale: mapValueOfType<int>(json, r'quantityScale')!,
        supplierUnit: mapValueOfType<String>(json, r'supplierUnit')!,
        unitsPerSupplierUnit: mapValueOfType<String>(json, r'unitsPerSupplierUnit')!,
        orderedQuantity: mapValueOfType<String>(json, r'orderedQuantity')!,
        receivedQuantity: mapValueOfType<String>(json, r'receivedQuantity')!,
        remainingQuantity: mapValueOfType<String>(json, r'remainingQuantity')!,
        orderedBaseQuantity: mapValueOfType<String>(json, r'orderedBaseQuantity')!,
        receivedBaseQuantity: mapValueOfType<String>(json, r'receivedBaseQuantity')!,
        remainingBaseQuantity: mapValueOfType<String>(json, r'remainingBaseQuantity')!,
        unitPrice: mapValueOfType<String>(json, r'unitPrice')!,
        version: mapValueOfType<int>(json, r'version')!,
      );
    }
    return null;
  }

  static List<PurchaseOrderLine> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PurchaseOrderLine>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PurchaseOrderLine.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PurchaseOrderLine> mapFromJson(dynamic json) {
    final map = <String, PurchaseOrderLine>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PurchaseOrderLine.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PurchaseOrderLine-objects as value to a dart map
  static Map<String, List<PurchaseOrderLine>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PurchaseOrderLine>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PurchaseOrderLine.listFromJson(entry.value, growable: growable,);
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
    'supplierUnit',
    'unitsPerSupplierUnit',
    'orderedQuantity',
    'receivedQuantity',
    'remainingQuantity',
    'orderedBaseQuantity',
    'receivedBaseQuantity',
    'remainingBaseQuantity',
    'unitPrice',
    'version',
  };
}


enum PurchaseOrderLineBaseUnitEnum {
  g._(r'g'),
  ml._(r'ml'),
  each._(r'each'),
  ;

  /// Instantiate a new enum with the provided value.
  const PurchaseOrderLineBaseUnitEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [PurchaseOrderLineBaseUnitEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static PurchaseOrderLineBaseUnitEnum? fromJson(dynamic value) => PurchaseOrderLineBaseUnitEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [PurchaseOrderLineBaseUnitEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<PurchaseOrderLineBaseUnitEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PurchaseOrderLineBaseUnitEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PurchaseOrderLineBaseUnitEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [PurchaseOrderLineBaseUnitEnum] to String,
/// and [decode] dynamic data back to [PurchaseOrderLineBaseUnitEnum].
class PurchaseOrderLineBaseUnitEnumTypeTransformer {
  factory PurchaseOrderLineBaseUnitEnumTypeTransformer() => _instance ??= const PurchaseOrderLineBaseUnitEnumTypeTransformer._();

  const PurchaseOrderLineBaseUnitEnumTypeTransformer._();

  String encode(PurchaseOrderLineBaseUnitEnum data) => data._value;

  /// Returns the instance of [PurchaseOrderLineBaseUnitEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  PurchaseOrderLineBaseUnitEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is PurchaseOrderLineBaseUnitEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'g': return PurchaseOrderLineBaseUnitEnum.g;
        case r'ml': return PurchaseOrderLineBaseUnitEnum.ml;
        case r'each': return PurchaseOrderLineBaseUnitEnum.each;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static PurchaseOrderLineBaseUnitEnumTypeTransformer? _instance;
}


