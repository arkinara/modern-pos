//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Station {
  /// Returns a new [Station] instance.
  Station({
    required this.id,
    required this.name,
    required this.kind,
    required this.isDefault,
    required this.printerConfigId,
    required this.printerModel,
    required this.sortOrder,
    required this.revision,
    required this.routeCount,
  });

  String id;

  String name;

  StationKind kind;

  bool isDefault;

  String? printerConfigId;

  String? printerModel;

  int sortOrder;

  int revision;

  int routeCount;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Station &&
    other.id == id &&
    other.name == name &&
    other.kind == kind &&
    other.isDefault == isDefault &&
    other.printerConfigId == printerConfigId &&
    other.printerModel == printerModel &&
    other.sortOrder == sortOrder &&
    other.revision == revision &&
    other.routeCount == routeCount;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (name.hashCode) +
    (kind.hashCode) +
    (isDefault.hashCode) +
    (printerConfigId == null ? 0 : printerConfigId!.hashCode) +
    (printerModel == null ? 0 : printerModel!.hashCode) +
    (sortOrder.hashCode) +
    (revision.hashCode) +
    (routeCount.hashCode);

  @override
  String toString() => 'Station[id=$id, name=$name, kind=$kind, isDefault=$isDefault, printerConfigId=$printerConfigId, printerModel=$printerModel, sortOrder=$sortOrder, revision=$revision, routeCount=$routeCount]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'name'] = this.name;
      json[r'kind'] = this.kind;
      json[r'isDefault'] = this.isDefault;
    if (this.printerConfigId != null) {
      json[r'printerConfigId'] = this.printerConfigId;
    } else {
      json[r'printerConfigId'] = null;
    }
    if (this.printerModel != null) {
      json[r'printerModel'] = this.printerModel;
    } else {
      json[r'printerModel'] = null;
    }
      json[r'sortOrder'] = this.sortOrder;
      json[r'revision'] = this.revision;
      json[r'routeCount'] = this.routeCount;
    return json;
  }

  /// Returns a new [Station] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Station? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "Station[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "Station[id]" has a null value in JSON.');
        assert(json.containsKey(r'name'), 'Required key "Station[name]" is missing from JSON.');
        assert(json[r'name'] != null, 'Required key "Station[name]" has a null value in JSON.');
        assert(json.containsKey(r'kind'), 'Required key "Station[kind]" is missing from JSON.');
        assert(json[r'kind'] != null, 'Required key "Station[kind]" has a null value in JSON.');
        assert(json.containsKey(r'isDefault'), 'Required key "Station[isDefault]" is missing from JSON.');
        assert(json[r'isDefault'] != null, 'Required key "Station[isDefault]" has a null value in JSON.');
        assert(json.containsKey(r'printerConfigId'), 'Required key "Station[printerConfigId]" is missing from JSON.');
        assert(json.containsKey(r'printerModel'), 'Required key "Station[printerModel]" is missing from JSON.');
        assert(json.containsKey(r'sortOrder'), 'Required key "Station[sortOrder]" is missing from JSON.');
        assert(json[r'sortOrder'] != null, 'Required key "Station[sortOrder]" has a null value in JSON.');
        assert(json.containsKey(r'revision'), 'Required key "Station[revision]" is missing from JSON.');
        assert(json[r'revision'] != null, 'Required key "Station[revision]" has a null value in JSON.');
        assert(json.containsKey(r'routeCount'), 'Required key "Station[routeCount]" is missing from JSON.');
        assert(json[r'routeCount'] != null, 'Required key "Station[routeCount]" has a null value in JSON.');
        return true;
      }());

      return Station(
        id: mapValueOfType<String>(json, r'id')!,
        name: mapValueOfType<String>(json, r'name')!,
        kind: StationKind.fromJson(json[r'kind'])!,
        isDefault: mapValueOfType<bool>(json, r'isDefault')!,
        printerConfigId: mapValueOfType<String>(json, r'printerConfigId'),
        printerModel: mapValueOfType<String>(json, r'printerModel'),
        sortOrder: mapValueOfType<int>(json, r'sortOrder')!,
        revision: mapValueOfType<int>(json, r'revision')!,
        routeCount: mapValueOfType<int>(json, r'routeCount')!,
      );
    }
    return null;
  }

  static List<Station> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Station>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Station.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Station> mapFromJson(dynamic json) {
    final map = <String, Station>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Station.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Station-objects as value to a dart map
  static Map<String, List<Station>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Station>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Station.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'name',
    'kind',
    'isDefault',
    'printerConfigId',
    'printerModel',
    'sortOrder',
    'revision',
    'routeCount',
  };
}

