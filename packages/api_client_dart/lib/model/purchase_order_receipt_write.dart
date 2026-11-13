//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PurchaseOrderReceiptWrite {
  /// Returns a new [PurchaseOrderReceiptWrite] instance.
  PurchaseOrderReceiptWrite({
    required this.lineId,
    required this.quantity,
    required this.unit,
    this.note,
  });

  String lineId;

  /// Nonnegative fixed-point quantity. Business validation rejects zero where a positive quantity is required.
  String quantity;

  PurchaseOrderReceiptWriteUnitEnum unit;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? note;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PurchaseOrderReceiptWrite &&
    other.lineId == lineId &&
    other.quantity == quantity &&
    other.unit == unit &&
    other.note == note;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (lineId.hashCode) +
    (quantity.hashCode) +
    (unit.hashCode) +
    (note == null ? 0 : note!.hashCode);

  @override
  String toString() => 'PurchaseOrderReceiptWrite[lineId=$lineId, quantity=$quantity, unit=$unit, note=$note]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'lineId'] = this.lineId;
      json[r'quantity'] = this.quantity;
      json[r'unit'] = this.unit;
    if (this.note != null) {
      json[r'note'] = this.note;
    } else {
      json[r'note'] = null;
    }
    return json;
  }

  /// Returns a new [PurchaseOrderReceiptWrite] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PurchaseOrderReceiptWrite? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'lineId'), 'Required key "PurchaseOrderReceiptWrite[lineId]" is missing from JSON.');
        assert(json[r'lineId'] != null, 'Required key "PurchaseOrderReceiptWrite[lineId]" has a null value in JSON.');
        assert(json.containsKey(r'quantity'), 'Required key "PurchaseOrderReceiptWrite[quantity]" is missing from JSON.');
        assert(json[r'quantity'] != null, 'Required key "PurchaseOrderReceiptWrite[quantity]" has a null value in JSON.');
        assert(json.containsKey(r'unit'), 'Required key "PurchaseOrderReceiptWrite[unit]" is missing from JSON.');
        assert(json[r'unit'] != null, 'Required key "PurchaseOrderReceiptWrite[unit]" has a null value in JSON.');
        return true;
      }());

      return PurchaseOrderReceiptWrite(
        lineId: mapValueOfType<String>(json, r'lineId')!,
        quantity: mapValueOfType<String>(json, r'quantity')!,
        unit: PurchaseOrderReceiptWriteUnitEnum.fromJson(json[r'unit'])!,
        note: mapValueOfType<String>(json, r'note'),
      );
    }
    return null;
  }

  static List<PurchaseOrderReceiptWrite> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PurchaseOrderReceiptWrite>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PurchaseOrderReceiptWrite.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PurchaseOrderReceiptWrite> mapFromJson(dynamic json) {
    final map = <String, PurchaseOrderReceiptWrite>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PurchaseOrderReceiptWrite.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PurchaseOrderReceiptWrite-objects as value to a dart map
  static Map<String, List<PurchaseOrderReceiptWrite>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PurchaseOrderReceiptWrite>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PurchaseOrderReceiptWrite.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'lineId',
    'quantity',
    'unit',
  };
}


enum PurchaseOrderReceiptWriteUnitEnum {
  SUPPLIER._(r'SUPPLIER'),
  BASE._(r'BASE'),
  ;

  /// Instantiate a new enum with the provided value.
  const PurchaseOrderReceiptWriteUnitEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [PurchaseOrderReceiptWriteUnitEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static PurchaseOrderReceiptWriteUnitEnum? fromJson(dynamic value) => PurchaseOrderReceiptWriteUnitEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [PurchaseOrderReceiptWriteUnitEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<PurchaseOrderReceiptWriteUnitEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PurchaseOrderReceiptWriteUnitEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PurchaseOrderReceiptWriteUnitEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [PurchaseOrderReceiptWriteUnitEnum] to String,
/// and [decode] dynamic data back to [PurchaseOrderReceiptWriteUnitEnum].
class PurchaseOrderReceiptWriteUnitEnumTypeTransformer {
  factory PurchaseOrderReceiptWriteUnitEnumTypeTransformer() => _instance ??= const PurchaseOrderReceiptWriteUnitEnumTypeTransformer._();

  const PurchaseOrderReceiptWriteUnitEnumTypeTransformer._();

  String encode(PurchaseOrderReceiptWriteUnitEnum data) => data._value;

  /// Returns the instance of [PurchaseOrderReceiptWriteUnitEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  PurchaseOrderReceiptWriteUnitEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is PurchaseOrderReceiptWriteUnitEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'SUPPLIER': return PurchaseOrderReceiptWriteUnitEnum.SUPPLIER;
        case r'BASE': return PurchaseOrderReceiptWriteUnitEnum.BASE;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static PurchaseOrderReceiptWriteUnitEnumTypeTransformer? _instance;
}


