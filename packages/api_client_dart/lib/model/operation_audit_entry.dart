//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class OperationAuditEntry {
  /// Returns a new [OperationAuditEntry] instance.
  OperationAuditEntry({
    required this.id,
    required this.actorId,
    required this.action,
    required this.entityType,
    required this.entityId,
    this.metadata = const {},
    required this.createdAt,
  });

  String id;

  String actorId;

  OperationAuditEntryActionEnum action;

  String entityType;

  String entityId;

  Map<String, Object> metadata;

  DateTime createdAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is OperationAuditEntry &&
    other.id == id &&
    other.actorId == actorId &&
    other.action == action &&
    other.entityType == entityType &&
    other.entityId == entityId &&
    _deepEquality.equals(other.metadata, metadata) &&
    other.createdAt == createdAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (actorId.hashCode) +
    (action.hashCode) +
    (entityType.hashCode) +
    (entityId.hashCode) +
    (metadata.hashCode) +
    (createdAt.hashCode);

  @override
  String toString() => 'OperationAuditEntry[id=$id, actorId=$actorId, action=$action, entityType=$entityType, entityId=$entityId, metadata=$metadata, createdAt=$createdAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'actorId'] = this.actorId;
      json[r'action'] = this.action;
      json[r'entityType'] = this.entityType;
      json[r'entityId'] = this.entityId;
      json[r'metadata'] = this.metadata;
      json[r'createdAt'] = this.createdAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [OperationAuditEntry] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static OperationAuditEntry? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "OperationAuditEntry[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "OperationAuditEntry[id]" has a null value in JSON.');
        assert(json.containsKey(r'actorId'), 'Required key "OperationAuditEntry[actorId]" is missing from JSON.');
        assert(json[r'actorId'] != null, 'Required key "OperationAuditEntry[actorId]" has a null value in JSON.');
        assert(json.containsKey(r'action'), 'Required key "OperationAuditEntry[action]" is missing from JSON.');
        assert(json[r'action'] != null, 'Required key "OperationAuditEntry[action]" has a null value in JSON.');
        assert(json.containsKey(r'entityType'), 'Required key "OperationAuditEntry[entityType]" is missing from JSON.');
        assert(json[r'entityType'] != null, 'Required key "OperationAuditEntry[entityType]" has a null value in JSON.');
        assert(json.containsKey(r'entityId'), 'Required key "OperationAuditEntry[entityId]" is missing from JSON.');
        assert(json[r'entityId'] != null, 'Required key "OperationAuditEntry[entityId]" has a null value in JSON.');
        assert(json.containsKey(r'metadata'), 'Required key "OperationAuditEntry[metadata]" is missing from JSON.');
        assert(json[r'metadata'] != null, 'Required key "OperationAuditEntry[metadata]" has a null value in JSON.');
        assert(json.containsKey(r'createdAt'), 'Required key "OperationAuditEntry[createdAt]" is missing from JSON.');
        assert(json[r'createdAt'] != null, 'Required key "OperationAuditEntry[createdAt]" has a null value in JSON.');
        return true;
      }());

      return OperationAuditEntry(
        id: mapValueOfType<String>(json, r'id')!,
        actorId: mapValueOfType<String>(json, r'actorId')!,
        action: OperationAuditEntryActionEnum.fromJson(json[r'action'])!,
        entityType: mapValueOfType<String>(json, r'entityType')!,
        entityId: mapValueOfType<String>(json, r'entityId')!,
        metadata: mapCastOfType<String, Object>(json, r'metadata')!,
        createdAt: mapDateTime(json, r'createdAt', r'')!,
      );
    }
    return null;
  }

  static List<OperationAuditEntry> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <OperationAuditEntry>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = OperationAuditEntry.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, OperationAuditEntry> mapFromJson(dynamic json) {
    final map = <String, OperationAuditEntry>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = OperationAuditEntry.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of OperationAuditEntry-objects as value to a dart map
  static Map<String, List<OperationAuditEntry>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<OperationAuditEntry>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = OperationAuditEntry.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'actorId',
    'action',
    'entityType',
    'entityId',
    'metadata',
    'createdAt',
  };
}


enum OperationAuditEntryActionEnum {
  SHIFT_OPENED._(r'SHIFT_OPENED'),
  SHIFT_CLOSED._(r'SHIFT_CLOSED'),
  CASH_PAID_IN._(r'CASH_PAID_IN'),
  CASH_PAID_OUT._(r'CASH_PAID_OUT'),
  ATTENDANCE_CLOCK_IN._(r'ATTENDANCE_CLOCK_IN'),
  ATTENDANCE_CLOCK_OUT._(r'ATTENDANCE_CLOCK_OUT'),
  ;

  /// Instantiate a new enum with the provided value.
  const OperationAuditEntryActionEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [OperationAuditEntryActionEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static OperationAuditEntryActionEnum? fromJson(dynamic value) => OperationAuditEntryActionEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [OperationAuditEntryActionEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<OperationAuditEntryActionEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <OperationAuditEntryActionEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = OperationAuditEntryActionEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [OperationAuditEntryActionEnum] to String,
/// and [decode] dynamic data back to [OperationAuditEntryActionEnum].
class OperationAuditEntryActionEnumTypeTransformer {
  factory OperationAuditEntryActionEnumTypeTransformer() => _instance ??= const OperationAuditEntryActionEnumTypeTransformer._();

  const OperationAuditEntryActionEnumTypeTransformer._();

  String encode(OperationAuditEntryActionEnum data) => data._value;

  /// Returns the instance of [OperationAuditEntryActionEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  OperationAuditEntryActionEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is OperationAuditEntryActionEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'SHIFT_OPENED': return OperationAuditEntryActionEnum.SHIFT_OPENED;
        case r'SHIFT_CLOSED': return OperationAuditEntryActionEnum.SHIFT_CLOSED;
        case r'CASH_PAID_IN': return OperationAuditEntryActionEnum.CASH_PAID_IN;
        case r'CASH_PAID_OUT': return OperationAuditEntryActionEnum.CASH_PAID_OUT;
        case r'ATTENDANCE_CLOCK_IN': return OperationAuditEntryActionEnum.ATTENDANCE_CLOCK_IN;
        case r'ATTENDANCE_CLOCK_OUT': return OperationAuditEntryActionEnum.ATTENDANCE_CLOCK_OUT;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static OperationAuditEntryActionEnumTypeTransformer? _instance;
}


