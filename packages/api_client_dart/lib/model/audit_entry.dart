//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class AuditEntry {
  /// Returns a new [AuditEntry] instance.
  AuditEntry({
    required this.id,
    required this.orderId,
    required this.action,
    required this.actorId,
    this.fromTableId,
    this.toTableId,
    this.metadata = const {},
    required this.createdAt,
  });

  String id;

  String orderId;

  AuditEntryActionEnum action;

  String actorId;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? fromTableId;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? toTableId;

  Map<String, Object> metadata;

  DateTime createdAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AuditEntry &&
    other.id == id &&
    other.orderId == orderId &&
    other.action == action &&
    other.actorId == actorId &&
    other.fromTableId == fromTableId &&
    other.toTableId == toTableId &&
    _deepEquality.equals(other.metadata, metadata) &&
    other.createdAt == createdAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (orderId.hashCode) +
    (action.hashCode) +
    (actorId.hashCode) +
    (fromTableId == null ? 0 : fromTableId!.hashCode) +
    (toTableId == null ? 0 : toTableId!.hashCode) +
    (metadata.hashCode) +
    (createdAt.hashCode);

  @override
  String toString() => 'AuditEntry[id=$id, orderId=$orderId, action=$action, actorId=$actorId, fromTableId=$fromTableId, toTableId=$toTableId, metadata=$metadata, createdAt=$createdAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'orderId'] = this.orderId;
      json[r'action'] = this.action;
      json[r'actorId'] = this.actorId;
    if (this.fromTableId != null) {
      json[r'fromTableId'] = this.fromTableId;
    } else {
      json[r'fromTableId'] = null;
    }
    if (this.toTableId != null) {
      json[r'toTableId'] = this.toTableId;
    } else {
      json[r'toTableId'] = null;
    }
      json[r'metadata'] = this.metadata;
      json[r'createdAt'] = this.createdAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [AuditEntry] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static AuditEntry? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "AuditEntry[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "AuditEntry[id]" has a null value in JSON.');
        assert(json.containsKey(r'orderId'), 'Required key "AuditEntry[orderId]" is missing from JSON.');
        assert(json[r'orderId'] != null, 'Required key "AuditEntry[orderId]" has a null value in JSON.');
        assert(json.containsKey(r'action'), 'Required key "AuditEntry[action]" is missing from JSON.');
        assert(json[r'action'] != null, 'Required key "AuditEntry[action]" has a null value in JSON.');
        assert(json.containsKey(r'actorId'), 'Required key "AuditEntry[actorId]" is missing from JSON.');
        assert(json[r'actorId'] != null, 'Required key "AuditEntry[actorId]" has a null value in JSON.');
        assert(json.containsKey(r'metadata'), 'Required key "AuditEntry[metadata]" is missing from JSON.');
        assert(json[r'metadata'] != null, 'Required key "AuditEntry[metadata]" has a null value in JSON.');
        assert(json.containsKey(r'createdAt'), 'Required key "AuditEntry[createdAt]" is missing from JSON.');
        assert(json[r'createdAt'] != null, 'Required key "AuditEntry[createdAt]" has a null value in JSON.');
        return true;
      }());

      return AuditEntry(
        id: mapValueOfType<String>(json, r'id')!,
        orderId: mapValueOfType<String>(json, r'orderId')!,
        action: AuditEntryActionEnum.fromJson(json[r'action'])!,
        actorId: mapValueOfType<String>(json, r'actorId')!,
        fromTableId: mapValueOfType<String>(json, r'fromTableId'),
        toTableId: mapValueOfType<String>(json, r'toTableId'),
        metadata: mapCastOfType<String, Object>(json, r'metadata')!,
        createdAt: mapDateTime(json, r'createdAt', r'')!,
      );
    }
    return null;
  }

  static List<AuditEntry> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AuditEntry>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AuditEntry.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, AuditEntry> mapFromJson(dynamic json) {
    final map = <String, AuditEntry>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = AuditEntry.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of AuditEntry-objects as value to a dart map
  static Map<String, List<AuditEntry>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<AuditEntry>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = AuditEntry.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'orderId',
    'action',
    'actorId',
    'metadata',
    'createdAt',
  };
}


enum AuditEntryActionEnum {
  OPEN._(r'OPEN'),
  UPDATE._(r'UPDATE'),
  TRANSFER._(r'TRANSFER'),
  SPLIT._(r'SPLIT'),
  CANCEL._(r'CANCEL'),
  FINALIZE._(r'FINALIZE'),
  ;

  /// Instantiate a new enum with the provided value.
  const AuditEntryActionEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [AuditEntryActionEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static AuditEntryActionEnum? fromJson(dynamic value) => AuditEntryActionEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [AuditEntryActionEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<AuditEntryActionEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AuditEntryActionEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AuditEntryActionEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [AuditEntryActionEnum] to String,
/// and [decode] dynamic data back to [AuditEntryActionEnum].
class AuditEntryActionEnumTypeTransformer {
  factory AuditEntryActionEnumTypeTransformer() => _instance ??= const AuditEntryActionEnumTypeTransformer._();

  const AuditEntryActionEnumTypeTransformer._();

  String encode(AuditEntryActionEnum data) => data._value;

  /// Returns the instance of [AuditEntryActionEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  AuditEntryActionEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is AuditEntryActionEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'OPEN': return AuditEntryActionEnum.OPEN;
        case r'UPDATE': return AuditEntryActionEnum.UPDATE;
        case r'TRANSFER': return AuditEntryActionEnum.TRANSFER;
        case r'SPLIT': return AuditEntryActionEnum.SPLIT;
        case r'CANCEL': return AuditEntryActionEnum.CANCEL;
        case r'FINALIZE': return AuditEntryActionEnum.FINALIZE;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static AuditEntryActionEnumTypeTransformer? _instance;
}


