//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class OrderUpdate {
  /// Returns a new [OrderUpdate] instance.
  OrderUpdate({
    required this.version,
    this.lines = const [],
  });

  /// Minimum value: 1
  int version;

  List<OrderWriteLinesInner> lines;

  @override
  bool operator ==(Object other) => identical(this, other) || other is OrderUpdate &&
    other.version == version &&
    _deepEquality.equals(other.lines, lines);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (version.hashCode) +
    (lines.hashCode);

  @override
  String toString() => 'OrderUpdate[version=$version, lines=$lines]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'version'] = this.version;
      json[r'lines'] = this.lines;
    return json;
  }

  /// Returns a new [OrderUpdate] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static OrderUpdate? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'version'), 'Required key "OrderUpdate[version]" is missing from JSON.');
        assert(json[r'version'] != null, 'Required key "OrderUpdate[version]" has a null value in JSON.');
        assert(json.containsKey(r'lines'), 'Required key "OrderUpdate[lines]" is missing from JSON.');
        assert(json[r'lines'] != null, 'Required key "OrderUpdate[lines]" has a null value in JSON.');
        return true;
      }());

      return OrderUpdate(
        version: mapValueOfType<int>(json, r'version')!,
        lines: OrderWriteLinesInner.listFromJson(json[r'lines']),
      );
    }
    return null;
  }

  static List<OrderUpdate> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <OrderUpdate>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = OrderUpdate.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, OrderUpdate> mapFromJson(dynamic json) {
    final map = <String, OrderUpdate>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = OrderUpdate.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of OrderUpdate-objects as value to a dart map
  static Map<String, List<OrderUpdate>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<OrderUpdate>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = OrderUpdate.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'version',
    'lines',
  };
}

