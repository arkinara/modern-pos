//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class StationRoute {
  /// Returns a new [StationRoute] instance.
  StationRoute({
    required this.id,
    required this.menuItemId,
    required this.menuItemName,
    required this.stationId,
    required this.stationName,
    required this.stationKind,
  });

  String id;

  String menuItemId;

  String menuItemName;

  String stationId;

  String stationName;

  StationKind stationKind;

  @override
  bool operator ==(Object other) => identical(this, other) || other is StationRoute &&
    other.id == id &&
    other.menuItemId == menuItemId &&
    other.menuItemName == menuItemName &&
    other.stationId == stationId &&
    other.stationName == stationName &&
    other.stationKind == stationKind;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (menuItemId.hashCode) +
    (menuItemName.hashCode) +
    (stationId.hashCode) +
    (stationName.hashCode) +
    (stationKind.hashCode);

  @override
  String toString() => 'StationRoute[id=$id, menuItemId=$menuItemId, menuItemName=$menuItemName, stationId=$stationId, stationName=$stationName, stationKind=$stationKind]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'menuItemId'] = this.menuItemId;
      json[r'menuItemName'] = this.menuItemName;
      json[r'stationId'] = this.stationId;
      json[r'stationName'] = this.stationName;
      json[r'stationKind'] = this.stationKind;
    return json;
  }

  /// Returns a new [StationRoute] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static StationRoute? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "StationRoute[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "StationRoute[id]" has a null value in JSON.');
        assert(json.containsKey(r'menuItemId'), 'Required key "StationRoute[menuItemId]" is missing from JSON.');
        assert(json[r'menuItemId'] != null, 'Required key "StationRoute[menuItemId]" has a null value in JSON.');
        assert(json.containsKey(r'menuItemName'), 'Required key "StationRoute[menuItemName]" is missing from JSON.');
        assert(json[r'menuItemName'] != null, 'Required key "StationRoute[menuItemName]" has a null value in JSON.');
        assert(json.containsKey(r'stationId'), 'Required key "StationRoute[stationId]" is missing from JSON.');
        assert(json[r'stationId'] != null, 'Required key "StationRoute[stationId]" has a null value in JSON.');
        assert(json.containsKey(r'stationName'), 'Required key "StationRoute[stationName]" is missing from JSON.');
        assert(json[r'stationName'] != null, 'Required key "StationRoute[stationName]" has a null value in JSON.');
        assert(json.containsKey(r'stationKind'), 'Required key "StationRoute[stationKind]" is missing from JSON.');
        assert(json[r'stationKind'] != null, 'Required key "StationRoute[stationKind]" has a null value in JSON.');
        return true;
      }());

      return StationRoute(
        id: mapValueOfType<String>(json, r'id')!,
        menuItemId: mapValueOfType<String>(json, r'menuItemId')!,
        menuItemName: mapValueOfType<String>(json, r'menuItemName')!,
        stationId: mapValueOfType<String>(json, r'stationId')!,
        stationName: mapValueOfType<String>(json, r'stationName')!,
        stationKind: StationKind.fromJson(json[r'stationKind'])!,
      );
    }
    return null;
  }

  static List<StationRoute> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <StationRoute>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = StationRoute.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, StationRoute> mapFromJson(dynamic json) {
    final map = <String, StationRoute>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = StationRoute.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of StationRoute-objects as value to a dart map
  static Map<String, List<StationRoute>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<StationRoute>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = StationRoute.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'menuItemId',
    'menuItemName',
    'stationId',
    'stationName',
    'stationKind',
  };
}

