//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class StationUpdate {
  /// Returns a new [StationUpdate] instance.
  StationUpdate({
    required this.name,
    required this.kind,
    this.printerConfigId,
    required this.isDefault,
    required this.sortOrder,
    required this.revision,
  });

  String name;

  StationKind kind;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? printerConfigId;

  bool isDefault;

  /// Minimum value: 0
  int sortOrder;

  /// Minimum value: 1
  int revision;

  @override
  bool operator ==(Object other) => identical(this, other) || other is StationUpdate &&
    other.name == name &&
    other.kind == kind &&
    other.printerConfigId == printerConfigId &&
    other.isDefault == isDefault &&
    other.sortOrder == sortOrder &&
    other.revision == revision;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (name.hashCode) +
    (kind.hashCode) +
    (printerConfigId == null ? 0 : printerConfigId!.hashCode) +
    (isDefault.hashCode) +
    (sortOrder.hashCode) +
    (revision.hashCode);

  @override
  String toString() => 'StationUpdate[name=$name, kind=$kind, printerConfigId=$printerConfigId, isDefault=$isDefault, sortOrder=$sortOrder, revision=$revision]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'name'] = this.name;
      json[r'kind'] = this.kind;
    if (this.printerConfigId != null) {
      json[r'printerConfigId'] = this.printerConfigId;
    } else {
      json[r'printerConfigId'] = null;
    }
      json[r'isDefault'] = this.isDefault;
      json[r'sortOrder'] = this.sortOrder;
      json[r'revision'] = this.revision;
    return json;
  }

  /// Returns a new [StationUpdate] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static StationUpdate? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'name'), 'Required key "StationUpdate[name]" is missing from JSON.');
        assert(json[r'name'] != null, 'Required key "StationUpdate[name]" has a null value in JSON.');
        assert(json.containsKey(r'kind'), 'Required key "StationUpdate[kind]" is missing from JSON.');
        assert(json[r'kind'] != null, 'Required key "StationUpdate[kind]" has a null value in JSON.');
        assert(json.containsKey(r'isDefault'), 'Required key "StationUpdate[isDefault]" is missing from JSON.');
        assert(json[r'isDefault'] != null, 'Required key "StationUpdate[isDefault]" has a null value in JSON.');
        assert(json.containsKey(r'sortOrder'), 'Required key "StationUpdate[sortOrder]" is missing from JSON.');
        assert(json[r'sortOrder'] != null, 'Required key "StationUpdate[sortOrder]" has a null value in JSON.');
        assert(json.containsKey(r'revision'), 'Required key "StationUpdate[revision]" is missing from JSON.');
        assert(json[r'revision'] != null, 'Required key "StationUpdate[revision]" has a null value in JSON.');
        return true;
      }());

      return StationUpdate(
        name: mapValueOfType<String>(json, r'name')!,
        kind: StationKind.fromJson(json[r'kind'])!,
        printerConfigId: mapValueOfType<String>(json, r'printerConfigId'),
        isDefault: mapValueOfType<bool>(json, r'isDefault')!,
        sortOrder: mapValueOfType<int>(json, r'sortOrder')!,
        revision: mapValueOfType<int>(json, r'revision')!,
      );
    }
    return null;
  }

  static List<StationUpdate> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <StationUpdate>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = StationUpdate.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, StationUpdate> mapFromJson(dynamic json) {
    final map = <String, StationUpdate>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = StationUpdate.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of StationUpdate-objects as value to a dart map
  static Map<String, List<StationUpdate>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<StationUpdate>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = StationUpdate.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'name',
    'kind',
    'isDefault',
    'sortOrder',
    'revision',
  };
}

