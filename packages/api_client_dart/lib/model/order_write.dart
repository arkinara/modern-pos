//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class OrderWrite {
  /// Returns a new [OrderWrite] instance.
  OrderWrite({
    required this.deviceId,
    this.lines = const [],
    this.tableId,
  });

  String deviceId;

  List<OrderWriteLinesInner> lines;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? tableId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is OrderWrite &&
    other.deviceId == deviceId &&
    _deepEquality.equals(other.lines, lines) &&
    other.tableId == tableId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (deviceId.hashCode) +
    (lines.hashCode) +
    (tableId == null ? 0 : tableId!.hashCode);

  @override
  String toString() => 'OrderWrite[deviceId=$deviceId, lines=$lines, tableId=$tableId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'deviceId'] = this.deviceId;
      json[r'lines'] = this.lines;
    if (this.tableId != null) {
      json[r'tableId'] = this.tableId;
    } else {
      json[r'tableId'] = null;
    }
    return json;
  }

  /// Returns a new [OrderWrite] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static OrderWrite? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'deviceId'), 'Required key "OrderWrite[deviceId]" is missing from JSON.');
        assert(json[r'deviceId'] != null, 'Required key "OrderWrite[deviceId]" has a null value in JSON.');
        assert(json.containsKey(r'lines'), 'Required key "OrderWrite[lines]" is missing from JSON.');
        assert(json[r'lines'] != null, 'Required key "OrderWrite[lines]" has a null value in JSON.');
        return true;
      }());

      return OrderWrite(
        deviceId: mapValueOfType<String>(json, r'deviceId')!,
        lines: OrderWriteLinesInner.listFromJson(json[r'lines']),
        tableId: mapValueOfType<String>(json, r'tableId'),
      );
    }
    return null;
  }

  static List<OrderWrite> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <OrderWrite>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = OrderWrite.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, OrderWrite> mapFromJson(dynamic json) {
    final map = <String, OrderWrite>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = OrderWrite.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of OrderWrite-objects as value to a dart map
  static Map<String, List<OrderWrite>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<OrderWrite>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = OrderWrite.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'deviceId',
    'lines',
  };
}

