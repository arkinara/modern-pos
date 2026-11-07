//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Movement {
  /// Returns a new [Movement] instance.
  Movement({
    required this.id,
    required this.stockItemId,
    required this.delta,
    required this.type,
    required this.reason,
    required this.sourceId,
    required this.actorId,
    required this.createdAt,
  });

  String id;

  String stockItemId;

  String delta;

  MovementTypeEnum type;

  String reason;

  String sourceId;

  String actorId;

  DateTime createdAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Movement &&
    other.id == id &&
    other.stockItemId == stockItemId &&
    other.delta == delta &&
    other.type == type &&
    other.reason == reason &&
    other.sourceId == sourceId &&
    other.actorId == actorId &&
    other.createdAt == createdAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (stockItemId.hashCode) +
    (delta.hashCode) +
    (type.hashCode) +
    (reason.hashCode) +
    (sourceId.hashCode) +
    (actorId.hashCode) +
    (createdAt.hashCode);

  @override
  String toString() => 'Movement[id=$id, stockItemId=$stockItemId, delta=$delta, type=$type, reason=$reason, sourceId=$sourceId, actorId=$actorId, createdAt=$createdAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'stockItemId'] = this.stockItemId;
      json[r'delta'] = this.delta;
      json[r'type'] = this.type;
      json[r'reason'] = this.reason;
      json[r'sourceId'] = this.sourceId;
      json[r'actorId'] = this.actorId;
      json[r'createdAt'] = this.createdAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [Movement] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Movement? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "Movement[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "Movement[id]" has a null value in JSON.');
        assert(json.containsKey(r'stockItemId'), 'Required key "Movement[stockItemId]" is missing from JSON.');
        assert(json[r'stockItemId'] != null, 'Required key "Movement[stockItemId]" has a null value in JSON.');
        assert(json.containsKey(r'delta'), 'Required key "Movement[delta]" is missing from JSON.');
        assert(json[r'delta'] != null, 'Required key "Movement[delta]" has a null value in JSON.');
        assert(json.containsKey(r'type'), 'Required key "Movement[type]" is missing from JSON.');
        assert(json[r'type'] != null, 'Required key "Movement[type]" has a null value in JSON.');
        assert(json.containsKey(r'reason'), 'Required key "Movement[reason]" is missing from JSON.');
        assert(json[r'reason'] != null, 'Required key "Movement[reason]" has a null value in JSON.');
        assert(json.containsKey(r'sourceId'), 'Required key "Movement[sourceId]" is missing from JSON.');
        assert(json[r'sourceId'] != null, 'Required key "Movement[sourceId]" has a null value in JSON.');
        assert(json.containsKey(r'actorId'), 'Required key "Movement[actorId]" is missing from JSON.');
        assert(json[r'actorId'] != null, 'Required key "Movement[actorId]" has a null value in JSON.');
        assert(json.containsKey(r'createdAt'), 'Required key "Movement[createdAt]" is missing from JSON.');
        assert(json[r'createdAt'] != null, 'Required key "Movement[createdAt]" has a null value in JSON.');
        return true;
      }());

      return Movement(
        id: mapValueOfType<String>(json, r'id')!,
        stockItemId: mapValueOfType<String>(json, r'stockItemId')!,
        delta: mapValueOfType<String>(json, r'delta')!,
        type: MovementTypeEnum.fromJson(json[r'type'])!,
        reason: mapValueOfType<String>(json, r'reason')!,
        sourceId: mapValueOfType<String>(json, r'sourceId')!,
        actorId: mapValueOfType<String>(json, r'actorId')!,
        createdAt: mapDateTime(json, r'createdAt', r'')!,
      );
    }
    return null;
  }

  static List<Movement> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Movement>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Movement.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Movement> mapFromJson(dynamic json) {
    final map = <String, Movement>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Movement.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Movement-objects as value to a dart map
  static Map<String, List<Movement>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Movement>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Movement.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'stockItemId',
    'delta',
    'type',
    'reason',
    'sourceId',
    'actorId',
    'createdAt',
  };
}


enum MovementTypeEnum {
  OPENING._(r'OPENING'),
  RECEIPT._(r'RECEIPT'),
  ADJUSTMENT._(r'ADJUSTMENT'),
  SALE._(r'SALE'),
  REVERSAL._(r'REVERSAL'),
  ;

  /// Instantiate a new enum with the provided value.
  const MovementTypeEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [MovementTypeEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static MovementTypeEnum? fromJson(dynamic value) => MovementTypeEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [MovementTypeEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<MovementTypeEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MovementTypeEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MovementTypeEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [MovementTypeEnum] to String,
/// and [decode] dynamic data back to [MovementTypeEnum].
class MovementTypeEnumTypeTransformer {
  factory MovementTypeEnumTypeTransformer() => _instance ??= const MovementTypeEnumTypeTransformer._();

  const MovementTypeEnumTypeTransformer._();

  String encode(MovementTypeEnum data) => data._value;

  /// Returns the instance of [MovementTypeEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  MovementTypeEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is MovementTypeEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'OPENING': return MovementTypeEnum.OPENING;
        case r'RECEIPT': return MovementTypeEnum.RECEIPT;
        case r'ADJUSTMENT': return MovementTypeEnum.ADJUSTMENT;
        case r'SALE': return MovementTypeEnum.SALE;
        case r'REVERSAL': return MovementTypeEnum.REVERSAL;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static MovementTypeEnumTypeTransformer? _instance;
}


