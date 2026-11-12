//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ShiftReport {
  /// Returns a new [ShiftReport] instance.
  ShiftReport({
    required this.shift,
    this.movements = const [],
    this.salesByTender = const [],
    required this.generatedAt,
  });

  Shift shift;

  List<ShiftMovement> movements;

  List<ShiftTenderTotal> salesByTender;

  DateTime generatedAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ShiftReport &&
    other.shift == shift &&
    _deepEquality.equals(other.movements, movements) &&
    _deepEquality.equals(other.salesByTender, salesByTender) &&
    other.generatedAt == generatedAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (shift.hashCode) +
    (movements.hashCode) +
    (salesByTender.hashCode) +
    (generatedAt.hashCode);

  @override
  String toString() => 'ShiftReport[shift=$shift, movements=$movements, salesByTender=$salesByTender, generatedAt=$generatedAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'shift'] = this.shift;
      json[r'movements'] = this.movements;
      json[r'salesByTender'] = this.salesByTender;
      json[r'generatedAt'] = this.generatedAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [ShiftReport] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ShiftReport? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'shift'), 'Required key "ShiftReport[shift]" is missing from JSON.');
        assert(json[r'shift'] != null, 'Required key "ShiftReport[shift]" has a null value in JSON.');
        assert(json.containsKey(r'movements'), 'Required key "ShiftReport[movements]" is missing from JSON.');
        assert(json[r'movements'] != null, 'Required key "ShiftReport[movements]" has a null value in JSON.');
        assert(json.containsKey(r'salesByTender'), 'Required key "ShiftReport[salesByTender]" is missing from JSON.');
        assert(json[r'salesByTender'] != null, 'Required key "ShiftReport[salesByTender]" has a null value in JSON.');
        assert(json.containsKey(r'generatedAt'), 'Required key "ShiftReport[generatedAt]" is missing from JSON.');
        assert(json[r'generatedAt'] != null, 'Required key "ShiftReport[generatedAt]" has a null value in JSON.');
        return true;
      }());

      return ShiftReport(
        shift: Shift.fromJson(json[r'shift'])!,
        movements: ShiftMovement.listFromJson(json[r'movements']),
        salesByTender: ShiftTenderTotal.listFromJson(json[r'salesByTender']),
        generatedAt: mapDateTime(json, r'generatedAt', r'')!,
      );
    }
    return null;
  }

  static List<ShiftReport> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ShiftReport>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ShiftReport.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ShiftReport> mapFromJson(dynamic json) {
    final map = <String, ShiftReport>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ShiftReport.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ShiftReport-objects as value to a dart map
  static Map<String, List<ShiftReport>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ShiftReport>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ShiftReport.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'shift',
    'movements',
    'salesByTender',
    'generatedAt',
  };
}

