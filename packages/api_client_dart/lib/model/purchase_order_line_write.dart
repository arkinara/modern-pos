//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PurchaseOrderLineWrite {
  /// Returns a new [PurchaseOrderLineWrite] instance.
  PurchaseOrderLineWrite({
    required this.stockItemId,
    required this.supplierUnit,
    required this.unitsPerSupplierUnit,
    required this.orderedQuantity,
    required this.unitPrice,
  });

  String stockItemId;

  String supplierUnit;

  /// Nonnegative fixed-point quantity. Business validation rejects zero where a positive quantity is required.
  String unitsPerSupplierUnit;

  /// Nonnegative fixed-point quantity. Business validation rejects zero where a positive quantity is required.
  String orderedQuantity;

  /// Nonnegative fixed-point quantity. Business validation rejects zero where a positive quantity is required.
  String unitPrice;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PurchaseOrderLineWrite &&
    other.stockItemId == stockItemId &&
    other.supplierUnit == supplierUnit &&
    other.unitsPerSupplierUnit == unitsPerSupplierUnit &&
    other.orderedQuantity == orderedQuantity &&
    other.unitPrice == unitPrice;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (stockItemId.hashCode) +
    (supplierUnit.hashCode) +
    (unitsPerSupplierUnit.hashCode) +
    (orderedQuantity.hashCode) +
    (unitPrice.hashCode);

  @override
  String toString() => 'PurchaseOrderLineWrite[stockItemId=$stockItemId, supplierUnit=$supplierUnit, unitsPerSupplierUnit=$unitsPerSupplierUnit, orderedQuantity=$orderedQuantity, unitPrice=$unitPrice]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'stockItemId'] = this.stockItemId;
      json[r'supplierUnit'] = this.supplierUnit;
      json[r'unitsPerSupplierUnit'] = this.unitsPerSupplierUnit;
      json[r'orderedQuantity'] = this.orderedQuantity;
      json[r'unitPrice'] = this.unitPrice;
    return json;
  }

  /// Returns a new [PurchaseOrderLineWrite] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PurchaseOrderLineWrite? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'stockItemId'), 'Required key "PurchaseOrderLineWrite[stockItemId]" is missing from JSON.');
        assert(json[r'stockItemId'] != null, 'Required key "PurchaseOrderLineWrite[stockItemId]" has a null value in JSON.');
        assert(json.containsKey(r'supplierUnit'), 'Required key "PurchaseOrderLineWrite[supplierUnit]" is missing from JSON.');
        assert(json[r'supplierUnit'] != null, 'Required key "PurchaseOrderLineWrite[supplierUnit]" has a null value in JSON.');
        assert(json.containsKey(r'unitsPerSupplierUnit'), 'Required key "PurchaseOrderLineWrite[unitsPerSupplierUnit]" is missing from JSON.');
        assert(json[r'unitsPerSupplierUnit'] != null, 'Required key "PurchaseOrderLineWrite[unitsPerSupplierUnit]" has a null value in JSON.');
        assert(json.containsKey(r'orderedQuantity'), 'Required key "PurchaseOrderLineWrite[orderedQuantity]" is missing from JSON.');
        assert(json[r'orderedQuantity'] != null, 'Required key "PurchaseOrderLineWrite[orderedQuantity]" has a null value in JSON.');
        assert(json.containsKey(r'unitPrice'), 'Required key "PurchaseOrderLineWrite[unitPrice]" is missing from JSON.');
        assert(json[r'unitPrice'] != null, 'Required key "PurchaseOrderLineWrite[unitPrice]" has a null value in JSON.');
        return true;
      }());

      return PurchaseOrderLineWrite(
        stockItemId: mapValueOfType<String>(json, r'stockItemId')!,
        supplierUnit: mapValueOfType<String>(json, r'supplierUnit')!,
        unitsPerSupplierUnit: mapValueOfType<String>(json, r'unitsPerSupplierUnit')!,
        orderedQuantity: mapValueOfType<String>(json, r'orderedQuantity')!,
        unitPrice: mapValueOfType<String>(json, r'unitPrice')!,
      );
    }
    return null;
  }

  static List<PurchaseOrderLineWrite> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PurchaseOrderLineWrite>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PurchaseOrderLineWrite.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PurchaseOrderLineWrite> mapFromJson(dynamic json) {
    final map = <String, PurchaseOrderLineWrite>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PurchaseOrderLineWrite.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PurchaseOrderLineWrite-objects as value to a dart map
  static Map<String, List<PurchaseOrderLineWrite>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PurchaseOrderLineWrite>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PurchaseOrderLineWrite.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'stockItemId',
    'supplierUnit',
    'unitsPerSupplierUnit',
    'orderedQuantity',
    'unitPrice',
  };
}

