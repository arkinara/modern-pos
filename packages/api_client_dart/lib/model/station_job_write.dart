//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class StationJobWrite {
  /// Returns a new [StationJobWrite] instance.
  StationJobWrite({
    required this.kind,
    this.saleId,
    this.lines = const [],
  });

  StationJobKind kind;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? saleId;

  List<StationJobLine> lines;

  @override
  bool operator ==(Object other) => identical(this, other) || other is StationJobWrite &&
    other.kind == kind &&
    other.saleId == saleId &&
    _deepEquality.equals(other.lines, lines);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (kind.hashCode) +
    (saleId == null ? 0 : saleId!.hashCode) +
    (lines.hashCode);

  @override
  String toString() => 'StationJobWrite[kind=$kind, saleId=$saleId, lines=$lines]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'kind'] = this.kind;
    if (this.saleId != null) {
      json[r'saleId'] = this.saleId;
    } else {
      json[r'saleId'] = null;
    }
      json[r'lines'] = this.lines;
    return json;
  }

  /// Returns a new [StationJobWrite] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static StationJobWrite? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'kind'), 'Required key "StationJobWrite[kind]" is missing from JSON.');
        assert(json[r'kind'] != null, 'Required key "StationJobWrite[kind]" has a null value in JSON.');
        assert(json.containsKey(r'lines'), 'Required key "StationJobWrite[lines]" is missing from JSON.');
        assert(json[r'lines'] != null, 'Required key "StationJobWrite[lines]" has a null value in JSON.');
        return true;
      }());

      return StationJobWrite(
        kind: StationJobKind.fromJson(json[r'kind'])!,
        saleId: mapValueOfType<String>(json, r'saleId'),
        lines: StationJobLine.listFromJson(json[r'lines']),
      );
    }
    return null;
  }

  static List<StationJobWrite> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <StationJobWrite>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = StationJobWrite.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, StationJobWrite> mapFromJson(dynamic json) {
    final map = <String, StationJobWrite>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = StationJobWrite.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of StationJobWrite-objects as value to a dart map
  static Map<String, List<StationJobWrite>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<StationJobWrite>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = StationJobWrite.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'kind',
    'lines',
  };
}

