//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Movement {
  /// Returns a new [Movement] instance.
  Movement({
    required this.id,
    required this.outletId,
    required this.stockItemId,
    required this.delta,
    required this.type,
    required this.reason,
    required this.sourceId,
    required this.sourceReference,
    required this.actorId,
    required this.createdAt,
    this.supplierId,
    this.supplierName,
    this.supplierReference,
    this.purchaseOrderId,
    this.purchaseOrderReference,
    this.transferId,
    this.transferReference,
    this.stockCountId,
    this.stockCountReference,
    this.stockWasteId,
  });

  String id;

  String outletId;

  String stockItemId;

  String delta;

  MovementTypeEnum type;

  String reason;

  String sourceId;

  /// Human-readable sale or transfer reference resolved from sourceId. Null when no reference applies or the referenced row is missing. The ledger remains readable when a reference cannot be resolved.
  String? sourceReference;

  String actorId;

  DateTime createdAt;

  /// Supplier linked to this purchase receipt, when present.
  String? supplierId;

  /// Supplier display name resolved for a purchase receipt.
  String? supplierName;

  /// Supplier reference resolved for a purchase receipt.
  String? supplierReference;

  /// Purchase order linked to this receipt.
  String? purchaseOrderId;

  /// Purchase order reference resolved for a receipt.
  String? purchaseOrderReference;

  /// Outlet transfer linked to this movement.
  String? transferId;

  /// Outlet transfer reference resolved for a movement.
  String? transferReference;

  /// Stock count linked to this variance movement.
  String? stockCountId;

  /// Stock count reference resolved for a variance movement.
  String? stockCountReference;

  /// Waste record linked to this movement.
  String? stockWasteId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Movement &&
    other.id == id &&
    other.outletId == outletId &&
    other.stockItemId == stockItemId &&
    other.delta == delta &&
    other.type == type &&
    other.reason == reason &&
    other.sourceId == sourceId &&
    other.sourceReference == sourceReference &&
    other.actorId == actorId &&
    other.createdAt == createdAt &&
    other.supplierId == supplierId &&
    other.supplierName == supplierName &&
    other.supplierReference == supplierReference &&
    other.purchaseOrderId == purchaseOrderId &&
    other.purchaseOrderReference == purchaseOrderReference &&
    other.transferId == transferId &&
    other.transferReference == transferReference &&
    other.stockCountId == stockCountId &&
    other.stockCountReference == stockCountReference &&
    other.stockWasteId == stockWasteId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (outletId.hashCode) +
    (stockItemId.hashCode) +
    (delta.hashCode) +
    (type.hashCode) +
    (reason.hashCode) +
    (sourceId.hashCode) +
    (sourceReference == null ? 0 : sourceReference!.hashCode) +
    (actorId.hashCode) +
    (createdAt.hashCode) +
    (supplierId == null ? 0 : supplierId!.hashCode) +
    (supplierName == null ? 0 : supplierName!.hashCode) +
    (supplierReference == null ? 0 : supplierReference!.hashCode) +
    (purchaseOrderId == null ? 0 : purchaseOrderId!.hashCode) +
    (purchaseOrderReference == null ? 0 : purchaseOrderReference!.hashCode) +
    (transferId == null ? 0 : transferId!.hashCode) +
    (transferReference == null ? 0 : transferReference!.hashCode) +
    (stockCountId == null ? 0 : stockCountId!.hashCode) +
    (stockCountReference == null ? 0 : stockCountReference!.hashCode) +
    (stockWasteId == null ? 0 : stockWasteId!.hashCode);

  @override
  String toString() => 'Movement[id=$id, outletId=$outletId, stockItemId=$stockItemId, delta=$delta, type=$type, reason=$reason, sourceId=$sourceId, sourceReference=$sourceReference, actorId=$actorId, createdAt=$createdAt, supplierId=$supplierId, supplierName=$supplierName, supplierReference=$supplierReference, purchaseOrderId=$purchaseOrderId, purchaseOrderReference=$purchaseOrderReference, transferId=$transferId, transferReference=$transferReference, stockCountId=$stockCountId, stockCountReference=$stockCountReference, stockWasteId=$stockWasteId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'outletId'] = this.outletId;
      json[r'stockItemId'] = this.stockItemId;
      json[r'delta'] = this.delta;
      json[r'type'] = this.type;
      json[r'reason'] = this.reason;
      json[r'sourceId'] = this.sourceId;
    if (this.sourceReference != null) {
      json[r'sourceReference'] = this.sourceReference;
    } else {
      json[r'sourceReference'] = null;
    }
      json[r'actorId'] = this.actorId;
      json[r'createdAt'] = this.createdAt.toUtc().toIso8601String();
    if (this.supplierId != null) {
      json[r'supplierId'] = this.supplierId;
    } else {
      json[r'supplierId'] = null;
    }
    if (this.supplierName != null) {
      json[r'supplierName'] = this.supplierName;
    } else {
      json[r'supplierName'] = null;
    }
    if (this.supplierReference != null) {
      json[r'supplierReference'] = this.supplierReference;
    } else {
      json[r'supplierReference'] = null;
    }
    if (this.purchaseOrderId != null) {
      json[r'purchaseOrderId'] = this.purchaseOrderId;
    } else {
      json[r'purchaseOrderId'] = null;
    }
    if (this.purchaseOrderReference != null) {
      json[r'purchaseOrderReference'] = this.purchaseOrderReference;
    } else {
      json[r'purchaseOrderReference'] = null;
    }
    if (this.transferId != null) {
      json[r'transferId'] = this.transferId;
    } else {
      json[r'transferId'] = null;
    }
    if (this.transferReference != null) {
      json[r'transferReference'] = this.transferReference;
    } else {
      json[r'transferReference'] = null;
    }
    if (this.stockCountId != null) {
      json[r'stockCountId'] = this.stockCountId;
    } else {
      json[r'stockCountId'] = null;
    }
    if (this.stockCountReference != null) {
      json[r'stockCountReference'] = this.stockCountReference;
    } else {
      json[r'stockCountReference'] = null;
    }
    if (this.stockWasteId != null) {
      json[r'stockWasteId'] = this.stockWasteId;
    } else {
      json[r'stockWasteId'] = null;
    }
    return json;
  }

  /// Returns a new [Movement] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Movement? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "Movement[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "Movement[id]" has a null value in JSON.');
        assert(json.containsKey(r'outletId'), 'Required key "Movement[outletId]" is missing from JSON.');
        assert(json[r'outletId'] != null, 'Required key "Movement[outletId]" has a null value in JSON.');
        assert(json.containsKey(r'stockItemId'), 'Required key "Movement[stockItemId]" is missing from JSON.');
        assert(json[r'stockItemId'] != null, 'Required key "Movement[stockItemId]" has a null value in JSON.');
        assert(json.containsKey(r'delta'), 'Required key "Movement[delta]" is missing from JSON.');
        assert(json[r'delta'] != null, 'Required key "Movement[delta]" has a null value in JSON.');
        assert(json.containsKey(r'type'), 'Required key "Movement[type]" is missing from JSON.');
        assert(json[r'type'] != null, 'Required key "Movement[type]" has a null value in JSON.');
        assert(json.containsKey(r'reason'), 'Required key "Movement[reason]" is missing from JSON.');
        assert(json[r'reason'] != null, 'Required key "Movement[reason]" has a null value in JSON.');
        assert(json.containsKey(r'sourceId'), 'Required key "Movement[sourceId]" is missing from JSON.');
        assert(json[r'sourceId'] != null, 'Required key "Movement[sourceId]" has a null value in JSON.');
        assert(json.containsKey(r'sourceReference'), 'Required key "Movement[sourceReference]" is missing from JSON.');
        assert(json.containsKey(r'actorId'), 'Required key "Movement[actorId]" is missing from JSON.');
        assert(json[r'actorId'] != null, 'Required key "Movement[actorId]" has a null value in JSON.');
        assert(json.containsKey(r'createdAt'), 'Required key "Movement[createdAt]" is missing from JSON.');
        assert(json[r'createdAt'] != null, 'Required key "Movement[createdAt]" has a null value in JSON.');
        return true;
      }());

      return Movement(
        id: mapValueOfType<String>(json, r'id')!,
        outletId: mapValueOfType<String>(json, r'outletId')!,
        stockItemId: mapValueOfType<String>(json, r'stockItemId')!,
        delta: mapValueOfType<String>(json, r'delta')!,
        type: MovementTypeEnum.fromJson(json[r'type'])!,
        reason: mapValueOfType<String>(json, r'reason')!,
        sourceId: mapValueOfType<String>(json, r'sourceId')!,
        sourceReference: mapValueOfType<String>(json, r'sourceReference'),
        actorId: mapValueOfType<String>(json, r'actorId')!,
        createdAt: mapDateTime(json, r'createdAt', r'')!,
        supplierId: mapValueOfType<String>(json, r'supplierId'),
        supplierName: mapValueOfType<String>(json, r'supplierName'),
        supplierReference: mapValueOfType<String>(json, r'supplierReference'),
        purchaseOrderId: mapValueOfType<String>(json, r'purchaseOrderId'),
        purchaseOrderReference: mapValueOfType<String>(json, r'purchaseOrderReference'),
        transferId: mapValueOfType<String>(json, r'transferId'),
        transferReference: mapValueOfType<String>(json, r'transferReference'),
        stockCountId: mapValueOfType<String>(json, r'stockCountId'),
        stockCountReference: mapValueOfType<String>(json, r'stockCountReference'),
        stockWasteId: mapValueOfType<String>(json, r'stockWasteId'),
      );
    }
    return null;
  }

  static List<Movement> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Movement>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Movement.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Movement> mapFromJson(dynamic json) {
    final map = <String, Movement>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Movement.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Movement-objects as value to a dart map
  static Map<String, List<Movement>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Movement>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Movement.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'outletId',
    'stockItemId',
    'delta',
    'type',
    'reason',
    'sourceId',
    'sourceReference',
    'actorId',
    'createdAt',
  };
}


enum MovementTypeEnum {
  OPENING._(r'OPENING'),
  RECEIPT._(r'RECEIPT'),
  ADJUSTMENT._(r'ADJUSTMENT'),
  COUNT._(r'COUNT'),
  WASTE._(r'WASTE'),
  TRANSFER_OUT._(r'TRANSFER_OUT'),
  TRANSFER_IN._(r'TRANSFER_IN'),
  TRANSFER_CANCEL._(r'TRANSFER_CANCEL'),
  SALE._(r'SALE'),
  REVERSAL._(r'REVERSAL'),
  ;

  /// Instantiate a new enum with the provided value.
  const MovementTypeEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [MovementTypeEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static MovementTypeEnum? fromJson(dynamic value) => MovementTypeEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [MovementTypeEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<MovementTypeEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MovementTypeEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MovementTypeEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [MovementTypeEnum] to String,
/// and [decode] dynamic data back to [MovementTypeEnum].
class MovementTypeEnumTypeTransformer {
  factory MovementTypeEnumTypeTransformer() => _instance ??= const MovementTypeEnumTypeTransformer._();

  const MovementTypeEnumTypeTransformer._();

  String encode(MovementTypeEnum data) => data._value;

  /// Returns the instance of [MovementTypeEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  MovementTypeEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is MovementTypeEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'OPENING': return MovementTypeEnum.OPENING;
        case r'RECEIPT': return MovementTypeEnum.RECEIPT;
        case r'ADJUSTMENT': return MovementTypeEnum.ADJUSTMENT;
        case r'COUNT': return MovementTypeEnum.COUNT;
        case r'WASTE': return MovementTypeEnum.WASTE;
        case r'TRANSFER_OUT': return MovementTypeEnum.TRANSFER_OUT;
        case r'TRANSFER_IN': return MovementTypeEnum.TRANSFER_IN;
        case r'TRANSFER_CANCEL': return MovementTypeEnum.TRANSFER_CANCEL;
        case r'SALE': return MovementTypeEnum.SALE;
        case r'REVERSAL': return MovementTypeEnum.REVERSAL;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static MovementTypeEnumTypeTransformer? _instance;
}


