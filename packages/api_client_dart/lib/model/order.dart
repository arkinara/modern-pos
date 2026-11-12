//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Order {
  /// Returns a new [Order] instance.
  Order({
    required this.id,
    required this.deviceId,
    required this.state,
    required this.version,
    this.lines = const [],
    this.tableId,
    this.tableLabel,
    this.splitGroupId,
    this.parentOrderId,
  });

  String id;

  String deviceId;

  OrderStateEnum state;

  /// Minimum value: 1
  int version;

  List<OrderLinesInner> lines;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? tableId;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? tableLabel;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? splitGroupId;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? parentOrderId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Order &&
    other.id == id &&
    other.deviceId == deviceId &&
    other.state == state &&
    other.version == version &&
    _deepEquality.equals(other.lines, lines) &&
    other.tableId == tableId &&
    other.tableLabel == tableLabel &&
    other.splitGroupId == splitGroupId &&
    other.parentOrderId == parentOrderId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (deviceId.hashCode) +
    (state.hashCode) +
    (version.hashCode) +
    (lines.hashCode) +
    (tableId == null ? 0 : tableId!.hashCode) +
    (tableLabel == null ? 0 : tableLabel!.hashCode) +
    (splitGroupId == null ? 0 : splitGroupId!.hashCode) +
    (parentOrderId == null ? 0 : parentOrderId!.hashCode);

  @override
  String toString() => 'Order[id=$id, deviceId=$deviceId, state=$state, version=$version, lines=$lines, tableId=$tableId, tableLabel=$tableLabel, splitGroupId=$splitGroupId, parentOrderId=$parentOrderId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'deviceId'] = this.deviceId;
      json[r'state'] = this.state;
      json[r'version'] = this.version;
      json[r'lines'] = this.lines;
    if (this.tableId != null) {
      json[r'tableId'] = this.tableId;
    } else {
      json[r'tableId'] = null;
    }
    if (this.tableLabel != null) {
      json[r'tableLabel'] = this.tableLabel;
    } else {
      json[r'tableLabel'] = null;
    }
    if (this.splitGroupId != null) {
      json[r'splitGroupId'] = this.splitGroupId;
    } else {
      json[r'splitGroupId'] = null;
    }
    if (this.parentOrderId != null) {
      json[r'parentOrderId'] = this.parentOrderId;
    } else {
      json[r'parentOrderId'] = null;
    }
    return json;
  }

  /// Returns a new [Order] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Order? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "Order[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "Order[id]" has a null value in JSON.');
        assert(json.containsKey(r'deviceId'), 'Required key "Order[deviceId]" is missing from JSON.');
        assert(json[r'deviceId'] != null, 'Required key "Order[deviceId]" has a null value in JSON.');
        assert(json.containsKey(r'state'), 'Required key "Order[state]" is missing from JSON.');
        assert(json[r'state'] != null, 'Required key "Order[state]" has a null value in JSON.');
        assert(json.containsKey(r'version'), 'Required key "Order[version]" is missing from JSON.');
        assert(json[r'version'] != null, 'Required key "Order[version]" has a null value in JSON.');
        assert(json.containsKey(r'lines'), 'Required key "Order[lines]" is missing from JSON.');
        assert(json[r'lines'] != null, 'Required key "Order[lines]" has a null value in JSON.');
        return true;
      }());

      return Order(
        id: mapValueOfType<String>(json, r'id')!,
        deviceId: mapValueOfType<String>(json, r'deviceId')!,
        state: OrderStateEnum.fromJson(json[r'state'])!,
        version: mapValueOfType<int>(json, r'version')!,
        lines: OrderLinesInner.listFromJson(json[r'lines']),
        tableId: mapValueOfType<String>(json, r'tableId'),
        tableLabel: mapValueOfType<String>(json, r'tableLabel'),
        splitGroupId: mapValueOfType<String>(json, r'splitGroupId'),
        parentOrderId: mapValueOfType<String>(json, r'parentOrderId'),
      );
    }
    return null;
  }

  static List<Order> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Order>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Order.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Order> mapFromJson(dynamic json) {
    final map = <String, Order>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Order.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Order-objects as value to a dart map
  static Map<String, List<Order>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Order>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Order.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'deviceId',
    'state',
    'version',
    'lines',
  };
}


enum OrderStateEnum {
  DRAFT._(r'DRAFT'),
  COMPLETED._(r'COMPLETED'),
  CANCELLED._(r'CANCELLED'),
  SPLIT._(r'SPLIT'),
  ;

  /// Instantiate a new enum with the provided value.
  const OrderStateEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [OrderStateEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static OrderStateEnum? fromJson(dynamic value) => OrderStateEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [OrderStateEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<OrderStateEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <OrderStateEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = OrderStateEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [OrderStateEnum] to String,
/// and [decode] dynamic data back to [OrderStateEnum].
class OrderStateEnumTypeTransformer {
  factory OrderStateEnumTypeTransformer() => _instance ??= const OrderStateEnumTypeTransformer._();

  const OrderStateEnumTypeTransformer._();

  String encode(OrderStateEnum data) => data._value;

  /// Returns the instance of [OrderStateEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  OrderStateEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is OrderStateEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'DRAFT': return OrderStateEnum.DRAFT;
        case r'COMPLETED': return OrderStateEnum.COMPLETED;
        case r'CANCELLED': return OrderStateEnum.CANCELLED;
        case r'SPLIT': return OrderStateEnum.SPLIT;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static OrderStateEnumTypeTransformer? _instance;
}


