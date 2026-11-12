//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class OutletTransfer {
  /// Returns a new [OutletTransfer] instance.
  OutletTransfer({
    required this.id,
    required this.sourceOutletId,
    required this.sourceOutletName,
    required this.destinationOutletId,
    required this.destinationOutletName,
    required this.reference,
    required this.note,
    required this.state,
    required this.version,
    required this.createdAt,
    required this.dispatchedAt,
    required this.receivedAt,
    required this.cancelledAt,
    required this.inTransitQuantity,
    this.lines = const [],
  });

  String id;

  String sourceOutletId;

  String sourceOutletName;

  String destinationOutletId;

  String destinationOutletName;

  String reference;

  String? note;

  OutletTransferStateEnum state;

  /// Minimum value: 1
  int version;

  DateTime createdAt;

  DateTime? dispatchedAt;

  DateTime? receivedAt;

  DateTime? cancelledAt;

  String inTransitQuantity;

  List<OutletTransferLine> lines;

  @override
  bool operator ==(Object other) => identical(this, other) || other is OutletTransfer &&
    other.id == id &&
    other.sourceOutletId == sourceOutletId &&
    other.sourceOutletName == sourceOutletName &&
    other.destinationOutletId == destinationOutletId &&
    other.destinationOutletName == destinationOutletName &&
    other.reference == reference &&
    other.note == note &&
    other.state == state &&
    other.version == version &&
    other.createdAt == createdAt &&
    other.dispatchedAt == dispatchedAt &&
    other.receivedAt == receivedAt &&
    other.cancelledAt == cancelledAt &&
    other.inTransitQuantity == inTransitQuantity &&
    _deepEquality.equals(other.lines, lines);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (sourceOutletId.hashCode) +
    (sourceOutletName.hashCode) +
    (destinationOutletId.hashCode) +
    (destinationOutletName.hashCode) +
    (reference.hashCode) +
    (note == null ? 0 : note!.hashCode) +
    (state.hashCode) +
    (version.hashCode) +
    (createdAt.hashCode) +
    (dispatchedAt == null ? 0 : dispatchedAt!.hashCode) +
    (receivedAt == null ? 0 : receivedAt!.hashCode) +
    (cancelledAt == null ? 0 : cancelledAt!.hashCode) +
    (inTransitQuantity.hashCode) +
    (lines.hashCode);

  @override
  String toString() => 'OutletTransfer[id=$id, sourceOutletId=$sourceOutletId, sourceOutletName=$sourceOutletName, destinationOutletId=$destinationOutletId, destinationOutletName=$destinationOutletName, reference=$reference, note=$note, state=$state, version=$version, createdAt=$createdAt, dispatchedAt=$dispatchedAt, receivedAt=$receivedAt, cancelledAt=$cancelledAt, inTransitQuantity=$inTransitQuantity, lines=$lines]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'sourceOutletId'] = this.sourceOutletId;
      json[r'sourceOutletName'] = this.sourceOutletName;
      json[r'destinationOutletId'] = this.destinationOutletId;
      json[r'destinationOutletName'] = this.destinationOutletName;
      json[r'reference'] = this.reference;
    if (this.note != null) {
      json[r'note'] = this.note;
    } else {
      json[r'note'] = null;
    }
      json[r'state'] = this.state;
      json[r'version'] = this.version;
      json[r'createdAt'] = this.createdAt.toUtc().toIso8601String();
    if (this.dispatchedAt != null) {
      json[r'dispatchedAt'] = this.dispatchedAt!.toUtc().toIso8601String();
    } else {
      json[r'dispatchedAt'] = null;
    }
    if (this.receivedAt != null) {
      json[r'receivedAt'] = this.receivedAt!.toUtc().toIso8601String();
    } else {
      json[r'receivedAt'] = null;
    }
    if (this.cancelledAt != null) {
      json[r'cancelledAt'] = this.cancelledAt!.toUtc().toIso8601String();
    } else {
      json[r'cancelledAt'] = null;
    }
      json[r'inTransitQuantity'] = this.inTransitQuantity;
      json[r'lines'] = this.lines;
    return json;
  }

  /// Returns a new [OutletTransfer] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static OutletTransfer? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "OutletTransfer[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "OutletTransfer[id]" has a null value in JSON.');
        assert(json.containsKey(r'sourceOutletId'), 'Required key "OutletTransfer[sourceOutletId]" is missing from JSON.');
        assert(json[r'sourceOutletId'] != null, 'Required key "OutletTransfer[sourceOutletId]" has a null value in JSON.');
        assert(json.containsKey(r'sourceOutletName'), 'Required key "OutletTransfer[sourceOutletName]" is missing from JSON.');
        assert(json[r'sourceOutletName'] != null, 'Required key "OutletTransfer[sourceOutletName]" has a null value in JSON.');
        assert(json.containsKey(r'destinationOutletId'), 'Required key "OutletTransfer[destinationOutletId]" is missing from JSON.');
        assert(json[r'destinationOutletId'] != null, 'Required key "OutletTransfer[destinationOutletId]" has a null value in JSON.');
        assert(json.containsKey(r'destinationOutletName'), 'Required key "OutletTransfer[destinationOutletName]" is missing from JSON.');
        assert(json[r'destinationOutletName'] != null, 'Required key "OutletTransfer[destinationOutletName]" has a null value in JSON.');
        assert(json.containsKey(r'reference'), 'Required key "OutletTransfer[reference]" is missing from JSON.');
        assert(json[r'reference'] != null, 'Required key "OutletTransfer[reference]" has a null value in JSON.');
        assert(json.containsKey(r'note'), 'Required key "OutletTransfer[note]" is missing from JSON.');
        assert(json.containsKey(r'state'), 'Required key "OutletTransfer[state]" is missing from JSON.');
        assert(json[r'state'] != null, 'Required key "OutletTransfer[state]" has a null value in JSON.');
        assert(json.containsKey(r'version'), 'Required key "OutletTransfer[version]" is missing from JSON.');
        assert(json[r'version'] != null, 'Required key "OutletTransfer[version]" has a null value in JSON.');
        assert(json.containsKey(r'createdAt'), 'Required key "OutletTransfer[createdAt]" is missing from JSON.');
        assert(json[r'createdAt'] != null, 'Required key "OutletTransfer[createdAt]" has a null value in JSON.');
        assert(json.containsKey(r'dispatchedAt'), 'Required key "OutletTransfer[dispatchedAt]" is missing from JSON.');
        assert(json.containsKey(r'receivedAt'), 'Required key "OutletTransfer[receivedAt]" is missing from JSON.');
        assert(json.containsKey(r'cancelledAt'), 'Required key "OutletTransfer[cancelledAt]" is missing from JSON.');
        assert(json.containsKey(r'inTransitQuantity'), 'Required key "OutletTransfer[inTransitQuantity]" is missing from JSON.');
        assert(json[r'inTransitQuantity'] != null, 'Required key "OutletTransfer[inTransitQuantity]" has a null value in JSON.');
        assert(json.containsKey(r'lines'), 'Required key "OutletTransfer[lines]" is missing from JSON.');
        assert(json[r'lines'] != null, 'Required key "OutletTransfer[lines]" has a null value in JSON.');
        return true;
      }());

      return OutletTransfer(
        id: mapValueOfType<String>(json, r'id')!,
        sourceOutletId: mapValueOfType<String>(json, r'sourceOutletId')!,
        sourceOutletName: mapValueOfType<String>(json, r'sourceOutletName')!,
        destinationOutletId: mapValueOfType<String>(json, r'destinationOutletId')!,
        destinationOutletName: mapValueOfType<String>(json, r'destinationOutletName')!,
        reference: mapValueOfType<String>(json, r'reference')!,
        note: mapValueOfType<String>(json, r'note'),
        state: OutletTransferStateEnum.fromJson(json[r'state'])!,
        version: mapValueOfType<int>(json, r'version')!,
        createdAt: mapDateTime(json, r'createdAt', r'')!,
        dispatchedAt: mapDateTime(json, r'dispatchedAt', r''),
        receivedAt: mapDateTime(json, r'receivedAt', r''),
        cancelledAt: mapDateTime(json, r'cancelledAt', r''),
        inTransitQuantity: mapValueOfType<String>(json, r'inTransitQuantity')!,
        lines: OutletTransferLine.listFromJson(json[r'lines']),
      );
    }
    return null;
  }

  static List<OutletTransfer> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <OutletTransfer>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = OutletTransfer.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, OutletTransfer> mapFromJson(dynamic json) {
    final map = <String, OutletTransfer>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = OutletTransfer.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of OutletTransfer-objects as value to a dart map
  static Map<String, List<OutletTransfer>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<OutletTransfer>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = OutletTransfer.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'sourceOutletId',
    'sourceOutletName',
    'destinationOutletId',
    'destinationOutletName',
    'reference',
    'note',
    'state',
    'version',
    'createdAt',
    'dispatchedAt',
    'receivedAt',
    'cancelledAt',
    'inTransitQuantity',
    'lines',
  };
}


enum OutletTransferStateEnum {
  DRAFT._(r'DRAFT'),
  DISPATCHED._(r'DISPATCHED'),
  RECEIVED._(r'RECEIVED'),
  CANCELLED._(r'CANCELLED'),
  ;

  /// Instantiate a new enum with the provided value.
  const OutletTransferStateEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [OutletTransferStateEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static OutletTransferStateEnum? fromJson(dynamic value) => OutletTransferStateEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [OutletTransferStateEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<OutletTransferStateEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <OutletTransferStateEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = OutletTransferStateEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [OutletTransferStateEnum] to String,
/// and [decode] dynamic data back to [OutletTransferStateEnum].
class OutletTransferStateEnumTypeTransformer {
  factory OutletTransferStateEnumTypeTransformer() => _instance ??= const OutletTransferStateEnumTypeTransformer._();

  const OutletTransferStateEnumTypeTransformer._();

  String encode(OutletTransferStateEnum data) => data._value;

  /// Returns the instance of [OutletTransferStateEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  OutletTransferStateEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is OutletTransferStateEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'DRAFT': return OutletTransferStateEnum.DRAFT;
        case r'DISPATCHED': return OutletTransferStateEnum.DISPATCHED;
        case r'RECEIVED': return OutletTransferStateEnum.RECEIVED;
        case r'CANCELLED': return OutletTransferStateEnum.CANCELLED;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static OutletTransferStateEnumTypeTransformer? _instance;
}


