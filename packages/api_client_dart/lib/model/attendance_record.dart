//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class AttendanceRecord {
  /// Returns a new [AttendanceRecord] instance.
  AttendanceRecord({
    required this.id,
    required this.outletId,
    required this.userId,
    required this.clockInAt,
    this.clockOutAt,
    this.clockInNote,
    this.clockOutNote,
  });

  String id;

  String outletId;

  String userId;

  DateTime clockInAt;

  DateTime? clockOutAt;

  String? clockInNote;

  String? clockOutNote;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AttendanceRecord &&
    other.id == id &&
    other.outletId == outletId &&
    other.userId == userId &&
    other.clockInAt == clockInAt &&
    other.clockOutAt == clockOutAt &&
    other.clockInNote == clockInNote &&
    other.clockOutNote == clockOutNote;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (outletId.hashCode) +
    (userId.hashCode) +
    (clockInAt.hashCode) +
    (clockOutAt == null ? 0 : clockOutAt!.hashCode) +
    (clockInNote == null ? 0 : clockInNote!.hashCode) +
    (clockOutNote == null ? 0 : clockOutNote!.hashCode);

  @override
  String toString() => 'AttendanceRecord[id=$id, outletId=$outletId, userId=$userId, clockInAt=$clockInAt, clockOutAt=$clockOutAt, clockInNote=$clockInNote, clockOutNote=$clockOutNote]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'outletId'] = this.outletId;
      json[r'userId'] = this.userId;
      json[r'clockInAt'] = this.clockInAt.toUtc().toIso8601String();
    if (this.clockOutAt != null) {
      json[r'clockOutAt'] = this.clockOutAt!.toUtc().toIso8601String();
    } else {
      json[r'clockOutAt'] = null;
    }
    if (this.clockInNote != null) {
      json[r'clockInNote'] = this.clockInNote;
    } else {
      json[r'clockInNote'] = null;
    }
    if (this.clockOutNote != null) {
      json[r'clockOutNote'] = this.clockOutNote;
    } else {
      json[r'clockOutNote'] = null;
    }
    return json;
  }

  /// Returns a new [AttendanceRecord] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static AttendanceRecord? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "AttendanceRecord[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "AttendanceRecord[id]" has a null value in JSON.');
        assert(json.containsKey(r'outletId'), 'Required key "AttendanceRecord[outletId]" is missing from JSON.');
        assert(json[r'outletId'] != null, 'Required key "AttendanceRecord[outletId]" has a null value in JSON.');
        assert(json.containsKey(r'userId'), 'Required key "AttendanceRecord[userId]" is missing from JSON.');
        assert(json[r'userId'] != null, 'Required key "AttendanceRecord[userId]" has a null value in JSON.');
        assert(json.containsKey(r'clockInAt'), 'Required key "AttendanceRecord[clockInAt]" is missing from JSON.');
        assert(json[r'clockInAt'] != null, 'Required key "AttendanceRecord[clockInAt]" has a null value in JSON.');
        return true;
      }());

      return AttendanceRecord(
        id: mapValueOfType<String>(json, r'id')!,
        outletId: mapValueOfType<String>(json, r'outletId')!,
        userId: mapValueOfType<String>(json, r'userId')!,
        clockInAt: mapDateTime(json, r'clockInAt', r'')!,
        clockOutAt: mapDateTime(json, r'clockOutAt', r''),
        clockInNote: mapValueOfType<String>(json, r'clockInNote'),
        clockOutNote: mapValueOfType<String>(json, r'clockOutNote'),
      );
    }
    return null;
  }

  static List<AttendanceRecord> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AttendanceRecord>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AttendanceRecord.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, AttendanceRecord> mapFromJson(dynamic json) {
    final map = <String, AttendanceRecord>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = AttendanceRecord.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of AttendanceRecord-objects as value to a dart map
  static Map<String, List<AttendanceRecord>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<AttendanceRecord>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = AttendanceRecord.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'outletId',
    'userId',
    'clockInAt',
  };
}

