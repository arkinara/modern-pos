//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ShiftMovement {
  /// Returns a new [ShiftMovement] instance.
  ShiftMovement({
    required this.id,
    required this.actorId,
    required this.kind,
    required this.amountMinor,
    required this.reason,
    required this.createdAt,
  });

  String id;

  String actorId;

  ShiftMovementKindEnum kind;

  /// Currency minor units; IDR exponent 0 in demo.
  ///
  /// Minimum value: 0
  /// Maximum value: 9007199254740991
  int amountMinor;

  String reason;

  DateTime createdAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ShiftMovement &&
    other.id == id &&
    other.actorId == actorId &&
    other.kind == kind &&
    other.amountMinor == amountMinor &&
    other.reason == reason &&
    other.createdAt == createdAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (actorId.hashCode) +
    (kind.hashCode) +
    (amountMinor.hashCode) +
    (reason.hashCode) +
    (createdAt.hashCode);

  @override
  String toString() => 'ShiftMovement[id=$id, actorId=$actorId, kind=$kind, amountMinor=$amountMinor, reason=$reason, createdAt=$createdAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'actorId'] = this.actorId;
      json[r'kind'] = this.kind;
      json[r'amountMinor'] = this.amountMinor;
      json[r'reason'] = this.reason;
      json[r'createdAt'] = this.createdAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [ShiftMovement] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ShiftMovement? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "ShiftMovement[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "ShiftMovement[id]" has a null value in JSON.');
        assert(json.containsKey(r'actorId'), 'Required key "ShiftMovement[actorId]" is missing from JSON.');
        assert(json[r'actorId'] != null, 'Required key "ShiftMovement[actorId]" has a null value in JSON.');
        assert(json.containsKey(r'kind'), 'Required key "ShiftMovement[kind]" is missing from JSON.');
        assert(json[r'kind'] != null, 'Required key "ShiftMovement[kind]" has a null value in JSON.');
        assert(json.containsKey(r'amountMinor'), 'Required key "ShiftMovement[amountMinor]" is missing from JSON.');
        assert(json[r'amountMinor'] != null, 'Required key "ShiftMovement[amountMinor]" has a null value in JSON.');
        assert(json.containsKey(r'reason'), 'Required key "ShiftMovement[reason]" is missing from JSON.');
        assert(json[r'reason'] != null, 'Required key "ShiftMovement[reason]" has a null value in JSON.');
        assert(json.containsKey(r'createdAt'), 'Required key "ShiftMovement[createdAt]" is missing from JSON.');
        assert(json[r'createdAt'] != null, 'Required key "ShiftMovement[createdAt]" has a null value in JSON.');
        return true;
      }());

      return ShiftMovement(
        id: mapValueOfType<String>(json, r'id')!,
        actorId: mapValueOfType<String>(json, r'actorId')!,
        kind: ShiftMovementKindEnum.fromJson(json[r'kind'])!,
        amountMinor: mapValueOfType<int>(json, r'amountMinor')!,
        reason: mapValueOfType<String>(json, r'reason')!,
        createdAt: mapDateTime(json, r'createdAt', r'')!,
      );
    }
    return null;
  }

  static List<ShiftMovement> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ShiftMovement>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ShiftMovement.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ShiftMovement> mapFromJson(dynamic json) {
    final map = <String, ShiftMovement>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ShiftMovement.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ShiftMovement-objects as value to a dart map
  static Map<String, List<ShiftMovement>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ShiftMovement>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ShiftMovement.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'actorId',
    'kind',
    'amountMinor',
    'reason',
    'createdAt',
  };
}


enum ShiftMovementKindEnum {
  PAID_IN._(r'PAID_IN'),
  PAID_OUT._(r'PAID_OUT'),
  ;

  /// Instantiate a new enum with the provided value.
  const ShiftMovementKindEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [ShiftMovementKindEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static ShiftMovementKindEnum? fromJson(dynamic value) => ShiftMovementKindEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [ShiftMovementKindEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<ShiftMovementKindEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ShiftMovementKindEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ShiftMovementKindEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ShiftMovementKindEnum] to String,
/// and [decode] dynamic data back to [ShiftMovementKindEnum].
class ShiftMovementKindEnumTypeTransformer {
  factory ShiftMovementKindEnumTypeTransformer() => _instance ??= const ShiftMovementKindEnumTypeTransformer._();

  const ShiftMovementKindEnumTypeTransformer._();

  String encode(ShiftMovementKindEnum data) => data._value;

  /// Returns the instance of [ShiftMovementKindEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ShiftMovementKindEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is ShiftMovementKindEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'PAID_IN': return ShiftMovementKindEnum.PAID_IN;
        case r'PAID_OUT': return ShiftMovementKindEnum.PAID_OUT;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static ShiftMovementKindEnumTypeTransformer? _instance;
}


