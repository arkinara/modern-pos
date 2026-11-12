//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class StockCount {
  /// Returns a new [StockCount] instance.
  StockCount({
    required this.id,
    required this.outletId,
    required this.reference,
    required this.reason,
    required this.actorId,
    required this.createdAt,
    this.lines = const [],
    this.movements = const [],
  });

  String id;

  String outletId;

  String reference;

  String reason;

  String actorId;

  DateTime createdAt;

  List<StockCountLine> lines;

  List<Movement> movements;

  @override
  bool operator ==(Object other) => identical(this, other) || other is StockCount &&
    other.id == id &&
    other.outletId == outletId &&
    other.reference == reference &&
    other.reason == reason &&
    other.actorId == actorId &&
    other.createdAt == createdAt &&
    _deepEquality.equals(other.lines, lines) &&
    _deepEquality.equals(other.movements, movements);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (outletId.hashCode) +
    (reference.hashCode) +
    (reason.hashCode) +
    (actorId.hashCode) +
    (createdAt.hashCode) +
    (lines.hashCode) +
    (movements.hashCode);

  @override
  String toString() => 'StockCount[id=$id, outletId=$outletId, reference=$reference, reason=$reason, actorId=$actorId, createdAt=$createdAt, lines=$lines, movements=$movements]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'outletId'] = this.outletId;
      json[r'reference'] = this.reference;
      json[r'reason'] = this.reason;
      json[r'actorId'] = this.actorId;
      json[r'createdAt'] = this.createdAt.toUtc().toIso8601String();
      json[r'lines'] = this.lines;
      json[r'movements'] = this.movements;
    return json;
  }

  /// Returns a new [StockCount] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static StockCount? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "StockCount[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "StockCount[id]" has a null value in JSON.');
        assert(json.containsKey(r'outletId'), 'Required key "StockCount[outletId]" is missing from JSON.');
        assert(json[r'outletId'] != null, 'Required key "StockCount[outletId]" has a null value in JSON.');
        assert(json.containsKey(r'reference'), 'Required key "StockCount[reference]" is missing from JSON.');
        assert(json[r'reference'] != null, 'Required key "StockCount[reference]" has a null value in JSON.');
        assert(json.containsKey(r'reason'), 'Required key "StockCount[reason]" is missing from JSON.');
        assert(json[r'reason'] != null, 'Required key "StockCount[reason]" has a null value in JSON.');
        assert(json.containsKey(r'actorId'), 'Required key "StockCount[actorId]" is missing from JSON.');
        assert(json[r'actorId'] != null, 'Required key "StockCount[actorId]" has a null value in JSON.');
        assert(json.containsKey(r'createdAt'), 'Required key "StockCount[createdAt]" is missing from JSON.');
        assert(json[r'createdAt'] != null, 'Required key "StockCount[createdAt]" has a null value in JSON.');
        assert(json.containsKey(r'lines'), 'Required key "StockCount[lines]" is missing from JSON.');
        assert(json[r'lines'] != null, 'Required key "StockCount[lines]" has a null value in JSON.');
        assert(json.containsKey(r'movements'), 'Required key "StockCount[movements]" is missing from JSON.');
        assert(json[r'movements'] != null, 'Required key "StockCount[movements]" has a null value in JSON.');
        return true;
      }());

      return StockCount(
        id: mapValueOfType<String>(json, r'id')!,
        outletId: mapValueOfType<String>(json, r'outletId')!,
        reference: mapValueOfType<String>(json, r'reference')!,
        reason: mapValueOfType<String>(json, r'reason')!,
        actorId: mapValueOfType<String>(json, r'actorId')!,
        createdAt: mapDateTime(json, r'createdAt', r'')!,
        lines: StockCountLine.listFromJson(json[r'lines']),
        movements: Movement.listFromJson(json[r'movements']),
      );
    }
    return null;
  }

  static List<StockCount> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <StockCount>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = StockCount.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, StockCount> mapFromJson(dynamic json) {
    final map = <String, StockCount>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = StockCount.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of StockCount-objects as value to a dart map
  static Map<String, List<StockCount>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<StockCount>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = StockCount.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'outletId',
    'reference',
    'reason',
    'actorId',
    'createdAt',
    'lines',
    'movements',
  };
}

