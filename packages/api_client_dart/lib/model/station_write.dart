//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class StationWrite {
  /// Returns a new [StationWrite] instance.
  StationWrite({
    required this.name,
    required this.kind,
    this.printerConfigId,
    required this.isDefault,
    required this.sortOrder,
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

  @override
  bool operator ==(Object other) => identical(this, other) || other is StationWrite &&
    other.name == name &&
    other.kind == kind &&
    other.printerConfigId == printerConfigId &&
    other.isDefault == isDefault &&
    other.sortOrder == sortOrder;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (name.hashCode) +
    (kind.hashCode) +
    (printerConfigId == null ? 0 : printerConfigId!.hashCode) +
    (isDefault.hashCode) +
    (sortOrder.hashCode);

  @override
  String toString() => 'StationWrite[name=$name, kind=$kind, printerConfigId=$printerConfigId, isDefault=$isDefault, sortOrder=$sortOrder]';

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
    return json;
  }

  /// Returns a new [StationWrite] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static StationWrite? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'name'), 'Required key "StationWrite[name]" is missing from JSON.');
        assert(json[r'name'] != null, 'Required key "StationWrite[name]" has a null value in JSON.');
        assert(json.containsKey(r'kind'), 'Required key "StationWrite[kind]" is missing from JSON.');
        assert(json[r'kind'] != null, 'Required key "StationWrite[kind]" has a null value in JSON.');
        assert(json.containsKey(r'isDefault'), 'Required key "StationWrite[isDefault]" is missing from JSON.');
        assert(json[r'isDefault'] != null, 'Required key "StationWrite[isDefault]" has a null value in JSON.');
        assert(json.containsKey(r'sortOrder'), 'Required key "StationWrite[sortOrder]" is missing from JSON.');
        assert(json[r'sortOrder'] != null, 'Required key "StationWrite[sortOrder]" has a null value in JSON.');
        return true;
      }());

      return StationWrite(
        name: mapValueOfType<String>(json, r'name')!,
        kind: StationKind.fromJson(json[r'kind'])!,
        printerConfigId: mapValueOfType<String>(json, r'printerConfigId'),
        isDefault: mapValueOfType<bool>(json, r'isDefault')!,
        sortOrder: mapValueOfType<int>(json, r'sortOrder')!,
      );
    }
    return null;
  }

  static List<StationWrite> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <StationWrite>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = StationWrite.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, StationWrite> mapFromJson(dynamic json) {
    final map = <String, StationWrite>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = StationWrite.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of StationWrite-objects as value to a dart map
  static Map<String, List<StationWrite>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<StationWrite>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = StationWrite.listFromJson(entry.value, growable: growable,);
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
  };
}

