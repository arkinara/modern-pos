//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PurchaseOrder {
  /// Returns a new [PurchaseOrder] instance.
  PurchaseOrder({
    required this.id,
    required this.outletId,
    required this.supplierId,
    required this.supplierName,
    required this.supplierReference,
    required this.reference,
    required this.state,
    required this.createdAt,
    required this.closedAt,
    this.lines = const [],
  });

  String id;

  String outletId;

  String supplierId;

  String supplierName;

  String? supplierReference;

  String reference;

  PurchaseOrderStateEnum state;

  DateTime createdAt;

  DateTime? closedAt;

  List<PurchaseOrderLine> lines;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PurchaseOrder &&
    other.id == id &&
    other.outletId == outletId &&
    other.supplierId == supplierId &&
    other.supplierName == supplierName &&
    other.supplierReference == supplierReference &&
    other.reference == reference &&
    other.state == state &&
    other.createdAt == createdAt &&
    other.closedAt == closedAt &&
    _deepEquality.equals(other.lines, lines);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (outletId.hashCode) +
    (supplierId.hashCode) +
    (supplierName.hashCode) +
    (supplierReference == null ? 0 : supplierReference!.hashCode) +
    (reference.hashCode) +
    (state.hashCode) +
    (createdAt.hashCode) +
    (closedAt == null ? 0 : closedAt!.hashCode) +
    (lines.hashCode);

  @override
  String toString() => 'PurchaseOrder[id=$id, outletId=$outletId, supplierId=$supplierId, supplierName=$supplierName, supplierReference=$supplierReference, reference=$reference, state=$state, createdAt=$createdAt, closedAt=$closedAt, lines=$lines]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'outletId'] = this.outletId;
      json[r'supplierId'] = this.supplierId;
      json[r'supplierName'] = this.supplierName;
    if (this.supplierReference != null) {
      json[r'supplierReference'] = this.supplierReference;
    } else {
      json[r'supplierReference'] = null;
    }
      json[r'reference'] = this.reference;
      json[r'state'] = this.state;
      json[r'createdAt'] = this.createdAt.toUtc().toIso8601String();
    if (this.closedAt != null) {
      json[r'closedAt'] = this.closedAt!.toUtc().toIso8601String();
    } else {
      json[r'closedAt'] = null;
    }
      json[r'lines'] = this.lines;
    return json;
  }

  /// Returns a new [PurchaseOrder] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PurchaseOrder? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "PurchaseOrder[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "PurchaseOrder[id]" has a null value in JSON.');
        assert(json.containsKey(r'outletId'), 'Required key "PurchaseOrder[outletId]" is missing from JSON.');
        assert(json[r'outletId'] != null, 'Required key "PurchaseOrder[outletId]" has a null value in JSON.');
        assert(json.containsKey(r'supplierId'), 'Required key "PurchaseOrder[supplierId]" is missing from JSON.');
        assert(json[r'supplierId'] != null, 'Required key "PurchaseOrder[supplierId]" has a null value in JSON.');
        assert(json.containsKey(r'supplierName'), 'Required key "PurchaseOrder[supplierName]" is missing from JSON.');
        assert(json[r'supplierName'] != null, 'Required key "PurchaseOrder[supplierName]" has a null value in JSON.');
        assert(json.containsKey(r'supplierReference'), 'Required key "PurchaseOrder[supplierReference]" is missing from JSON.');
        assert(json.containsKey(r'reference'), 'Required key "PurchaseOrder[reference]" is missing from JSON.');
        assert(json[r'reference'] != null, 'Required key "PurchaseOrder[reference]" has a null value in JSON.');
        assert(json.containsKey(r'state'), 'Required key "PurchaseOrder[state]" is missing from JSON.');
        assert(json[r'state'] != null, 'Required key "PurchaseOrder[state]" has a null value in JSON.');
        assert(json.containsKey(r'createdAt'), 'Required key "PurchaseOrder[createdAt]" is missing from JSON.');
        assert(json[r'createdAt'] != null, 'Required key "PurchaseOrder[createdAt]" has a null value in JSON.');
        assert(json.containsKey(r'closedAt'), 'Required key "PurchaseOrder[closedAt]" is missing from JSON.');
        assert(json.containsKey(r'lines'), 'Required key "PurchaseOrder[lines]" is missing from JSON.');
        assert(json[r'lines'] != null, 'Required key "PurchaseOrder[lines]" has a null value in JSON.');
        return true;
      }());

      return PurchaseOrder(
        id: mapValueOfType<String>(json, r'id')!,
        outletId: mapValueOfType<String>(json, r'outletId')!,
        supplierId: mapValueOfType<String>(json, r'supplierId')!,
        supplierName: mapValueOfType<String>(json, r'supplierName')!,
        supplierReference: mapValueOfType<String>(json, r'supplierReference'),
        reference: mapValueOfType<String>(json, r'reference')!,
        state: PurchaseOrderStateEnum.fromJson(json[r'state'])!,
        createdAt: mapDateTime(json, r'createdAt', r'')!,
        closedAt: mapDateTime(json, r'closedAt', r''),
        lines: PurchaseOrderLine.listFromJson(json[r'lines']),
      );
    }
    return null;
  }

  static List<PurchaseOrder> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PurchaseOrder>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PurchaseOrder.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PurchaseOrder> mapFromJson(dynamic json) {
    final map = <String, PurchaseOrder>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PurchaseOrder.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PurchaseOrder-objects as value to a dart map
  static Map<String, List<PurchaseOrder>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PurchaseOrder>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PurchaseOrder.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'outletId',
    'supplierId',
    'supplierName',
    'supplierReference',
    'reference',
    'state',
    'createdAt',
    'closedAt',
    'lines',
  };
}


enum PurchaseOrderStateEnum {
  OPEN._(r'OPEN'),
  PARTIALLY_RECEIVED._(r'PARTIALLY_RECEIVED'),
  RECEIVED._(r'RECEIVED'),
  CANCELLED._(r'CANCELLED'),
  ;

  /// Instantiate a new enum with the provided value.
  const PurchaseOrderStateEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [PurchaseOrderStateEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static PurchaseOrderStateEnum? fromJson(dynamic value) => PurchaseOrderStateEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [PurchaseOrderStateEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<PurchaseOrderStateEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PurchaseOrderStateEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PurchaseOrderStateEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [PurchaseOrderStateEnum] to String,
/// and [decode] dynamic data back to [PurchaseOrderStateEnum].
class PurchaseOrderStateEnumTypeTransformer {
  factory PurchaseOrderStateEnumTypeTransformer() => _instance ??= const PurchaseOrderStateEnumTypeTransformer._();

  const PurchaseOrderStateEnumTypeTransformer._();

  String encode(PurchaseOrderStateEnum data) => data._value;

  /// Returns the instance of [PurchaseOrderStateEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  PurchaseOrderStateEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is PurchaseOrderStateEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'OPEN': return PurchaseOrderStateEnum.OPEN;
        case r'PARTIALLY_RECEIVED': return PurchaseOrderStateEnum.PARTIALLY_RECEIVED;
        case r'RECEIVED': return PurchaseOrderStateEnum.RECEIVED;
        case r'CANCELLED': return PurchaseOrderStateEnum.CANCELLED;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static PurchaseOrderStateEnumTypeTransformer? _instance;
}


