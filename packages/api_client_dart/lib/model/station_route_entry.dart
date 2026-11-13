//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class StationRouteEntry {
  /// Returns a new [StationRouteEntry] instance.
  StationRouteEntry({
    required this.menuItemId,
    required this.stationId,
  });

  String menuItemId;

  String stationId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is StationRouteEntry &&
    other.menuItemId == menuItemId &&
    other.stationId == stationId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (menuItemId.hashCode) +
    (stationId.hashCode);

  @override
  String toString() => 'StationRouteEntry[menuItemId=$menuItemId, stationId=$stationId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'menuItemId'] = this.menuItemId;
      json[r'stationId'] = this.stationId;
    return json;
  }

  /// Returns a new [StationRouteEntry] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static StationRouteEntry? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'menuItemId'), 'Required key "StationRouteEntry[menuItemId]" is missing from JSON.');
        assert(json[r'menuItemId'] != null, 'Required key "StationRouteEntry[menuItemId]" has a null value in JSON.');
        assert(json.containsKey(r'stationId'), 'Required key "StationRouteEntry[stationId]" is missing from JSON.');
        assert(json[r'stationId'] != null, 'Required key "StationRouteEntry[stationId]" has a null value in JSON.');
        return true;
      }());

      return StationRouteEntry(
        menuItemId: mapValueOfType<String>(json, r'menuItemId')!,
        stationId: mapValueOfType<String>(json, r'stationId')!,
      );
    }
    return null;
  }

  static List<StationRouteEntry> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <StationRouteEntry>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = StationRouteEntry.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, StationRouteEntry> mapFromJson(dynamic json) {
    final map = <String, StationRouteEntry>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = StationRouteEntry.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of StationRouteEntry-objects as value to a dart map
  static Map<String, List<StationRouteEntry>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<StationRouteEntry>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = StationRouteEntry.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'menuItemId',
    'stationId',
  };
}

