//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class TransferWrite {
  /// Returns a new [TransferWrite] instance.
  TransferWrite({
    required this.version,
    required this.tableId,
  });

  /// Minimum value: 1
  int version;

  String tableId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is TransferWrite &&
    other.version == version &&
    other.tableId == tableId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (version.hashCode) +
    (tableId.hashCode);

  @override
  String toString() => 'TransferWrite[version=$version, tableId=$tableId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'version'] = this.version;
      json[r'tableId'] = this.tableId;
    return json;
  }

  /// Returns a new [TransferWrite] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static TransferWrite? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'version'), 'Required key "TransferWrite[version]" is missing from JSON.');
        assert(json[r'version'] != null, 'Required key "TransferWrite[version]" has a null value in JSON.');
        assert(json.containsKey(r'tableId'), 'Required key "TransferWrite[tableId]" is missing from JSON.');
        assert(json[r'tableId'] != null, 'Required key "TransferWrite[tableId]" has a null value in JSON.');
        return true;
      }());

      return TransferWrite(
        version: mapValueOfType<int>(json, r'version')!,
        tableId: mapValueOfType<String>(json, r'tableId')!,
      );
    }
    return null;
  }

  static List<TransferWrite> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <TransferWrite>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = TransferWrite.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, TransferWrite> mapFromJson(dynamic json) {
    final map = <String, TransferWrite>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = TransferWrite.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of TransferWrite-objects as value to a dart map
  static Map<String, List<TransferWrite>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<TransferWrite>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = TransferWrite.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'version',
    'tableId',
  };
}

