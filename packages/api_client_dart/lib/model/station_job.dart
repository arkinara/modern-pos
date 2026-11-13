//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class StationJob {
  /// Returns a new [StationJob] instance.
  StationJob({
    required this.id,
    required this.stationId,
    required this.stationName,
    required this.orderId,
    required this.saleId,
    required this.orderReference,
    required this.variantId,
    required this.kind,
    required this.state,
    required this.copy,
    required this.reprintOfId,
    required this.itemName,
    required this.variantName,
    required this.quantity,
    this.modifiers = const [],
    required this.attempts,
    required this.lastError,
    required this.createdAt,
    required this.updatedAt,
  });

  String id;

  String stationId;

  String stationName;

  String orderId;

  String? saleId;

  String orderReference;

  String variantId;

  StationJobKind kind;

  StationJobStateEnum state;

  bool copy;

  String? reprintOfId;

  String itemName;

  String variantName;

  int quantity;

  List<StationJobModifier> modifiers;

  int attempts;

  String? lastError;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is StationJob &&
    other.id == id &&
    other.stationId == stationId &&
    other.stationName == stationName &&
    other.orderId == orderId &&
    other.saleId == saleId &&
    other.orderReference == orderReference &&
    other.variantId == variantId &&
    other.kind == kind &&
    other.state == state &&
    other.copy == copy &&
    other.reprintOfId == reprintOfId &&
    other.itemName == itemName &&
    other.variantName == variantName &&
    other.quantity == quantity &&
    _deepEquality.equals(other.modifiers, modifiers) &&
    other.attempts == attempts &&
    other.lastError == lastError &&
    other.createdAt == createdAt &&
    other.updatedAt == updatedAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (stationId.hashCode) +
    (stationName.hashCode) +
    (orderId.hashCode) +
    (saleId == null ? 0 : saleId!.hashCode) +
    (orderReference.hashCode) +
    (variantId.hashCode) +
    (kind.hashCode) +
    (state.hashCode) +
    (copy.hashCode) +
    (reprintOfId == null ? 0 : reprintOfId!.hashCode) +
    (itemName.hashCode) +
    (variantName.hashCode) +
    (quantity.hashCode) +
    (modifiers.hashCode) +
    (attempts.hashCode) +
    (lastError == null ? 0 : lastError!.hashCode) +
    (createdAt.hashCode) +
    (updatedAt.hashCode);

  @override
  String toString() => 'StationJob[id=$id, stationId=$stationId, stationName=$stationName, orderId=$orderId, saleId=$saleId, orderReference=$orderReference, variantId=$variantId, kind=$kind, state=$state, copy=$copy, reprintOfId=$reprintOfId, itemName=$itemName, variantName=$variantName, quantity=$quantity, modifiers=$modifiers, attempts=$attempts, lastError=$lastError, createdAt=$createdAt, updatedAt=$updatedAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'stationId'] = this.stationId;
      json[r'stationName'] = this.stationName;
      json[r'orderId'] = this.orderId;
    if (this.saleId != null) {
      json[r'saleId'] = this.saleId;
    } else {
      json[r'saleId'] = null;
    }
      json[r'orderReference'] = this.orderReference;
      json[r'variantId'] = this.variantId;
      json[r'kind'] = this.kind;
      json[r'state'] = this.state;
      json[r'copy'] = this.copy;
    if (this.reprintOfId != null) {
      json[r'reprintOfId'] = this.reprintOfId;
    } else {
      json[r'reprintOfId'] = null;
    }
      json[r'itemName'] = this.itemName;
      json[r'variantName'] = this.variantName;
      json[r'quantity'] = this.quantity;
      json[r'modifiers'] = this.modifiers;
      json[r'attempts'] = this.attempts;
    if (this.lastError != null) {
      json[r'lastError'] = this.lastError;
    } else {
      json[r'lastError'] = null;
    }
      json[r'createdAt'] = this.createdAt.toUtc().toIso8601String();
      json[r'updatedAt'] = this.updatedAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [StationJob] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static StationJob? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "StationJob[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "StationJob[id]" has a null value in JSON.');
        assert(json.containsKey(r'stationId'), 'Required key "StationJob[stationId]" is missing from JSON.');
        assert(json[r'stationId'] != null, 'Required key "StationJob[stationId]" has a null value in JSON.');
        assert(json.containsKey(r'stationName'), 'Required key "StationJob[stationName]" is missing from JSON.');
        assert(json[r'stationName'] != null, 'Required key "StationJob[stationName]" has a null value in JSON.');
        assert(json.containsKey(r'orderId'), 'Required key "StationJob[orderId]" is missing from JSON.');
        assert(json[r'orderId'] != null, 'Required key "StationJob[orderId]" has a null value in JSON.');
        assert(json.containsKey(r'saleId'), 'Required key "StationJob[saleId]" is missing from JSON.');
        assert(json.containsKey(r'orderReference'), 'Required key "StationJob[orderReference]" is missing from JSON.');
        assert(json[r'orderReference'] != null, 'Required key "StationJob[orderReference]" has a null value in JSON.');
        assert(json.containsKey(r'variantId'), 'Required key "StationJob[variantId]" is missing from JSON.');
        assert(json[r'variantId'] != null, 'Required key "StationJob[variantId]" has a null value in JSON.');
        assert(json.containsKey(r'kind'), 'Required key "StationJob[kind]" is missing from JSON.');
        assert(json[r'kind'] != null, 'Required key "StationJob[kind]" has a null value in JSON.');
        assert(json.containsKey(r'state'), 'Required key "StationJob[state]" is missing from JSON.');
        assert(json[r'state'] != null, 'Required key "StationJob[state]" has a null value in JSON.');
        assert(json.containsKey(r'copy'), 'Required key "StationJob[copy]" is missing from JSON.');
        assert(json[r'copy'] != null, 'Required key "StationJob[copy]" has a null value in JSON.');
        assert(json.containsKey(r'reprintOfId'), 'Required key "StationJob[reprintOfId]" is missing from JSON.');
        assert(json.containsKey(r'itemName'), 'Required key "StationJob[itemName]" is missing from JSON.');
        assert(json[r'itemName'] != null, 'Required key "StationJob[itemName]" has a null value in JSON.');
        assert(json.containsKey(r'variantName'), 'Required key "StationJob[variantName]" is missing from JSON.');
        assert(json[r'variantName'] != null, 'Required key "StationJob[variantName]" has a null value in JSON.');
        assert(json.containsKey(r'quantity'), 'Required key "StationJob[quantity]" is missing from JSON.');
        assert(json[r'quantity'] != null, 'Required key "StationJob[quantity]" has a null value in JSON.');
        assert(json.containsKey(r'modifiers'), 'Required key "StationJob[modifiers]" is missing from JSON.');
        assert(json[r'modifiers'] != null, 'Required key "StationJob[modifiers]" has a null value in JSON.');
        assert(json.containsKey(r'attempts'), 'Required key "StationJob[attempts]" is missing from JSON.');
        assert(json[r'attempts'] != null, 'Required key "StationJob[attempts]" has a null value in JSON.');
        assert(json.containsKey(r'lastError'), 'Required key "StationJob[lastError]" is missing from JSON.');
        assert(json.containsKey(r'createdAt'), 'Required key "StationJob[createdAt]" is missing from JSON.');
        assert(json[r'createdAt'] != null, 'Required key "StationJob[createdAt]" has a null value in JSON.');
        assert(json.containsKey(r'updatedAt'), 'Required key "StationJob[updatedAt]" is missing from JSON.');
        assert(json[r'updatedAt'] != null, 'Required key "StationJob[updatedAt]" has a null value in JSON.');
        return true;
      }());

      return StationJob(
        id: mapValueOfType<String>(json, r'id')!,
        stationId: mapValueOfType<String>(json, r'stationId')!,
        stationName: mapValueOfType<String>(json, r'stationName')!,
        orderId: mapValueOfType<String>(json, r'orderId')!,
        saleId: mapValueOfType<String>(json, r'saleId'),
        orderReference: mapValueOfType<String>(json, r'orderReference')!,
        variantId: mapValueOfType<String>(json, r'variantId')!,
        kind: StationJobKind.fromJson(json[r'kind'])!,
        state: StationJobStateEnum.fromJson(json[r'state'])!,
        copy: mapValueOfType<bool>(json, r'copy')!,
        reprintOfId: mapValueOfType<String>(json, r'reprintOfId'),
        itemName: mapValueOfType<String>(json, r'itemName')!,
        variantName: mapValueOfType<String>(json, r'variantName')!,
        quantity: mapValueOfType<int>(json, r'quantity')!,
        modifiers: StationJobModifier.listFromJson(json[r'modifiers']),
        attempts: mapValueOfType<int>(json, r'attempts')!,
        lastError: mapValueOfType<String>(json, r'lastError'),
        createdAt: mapDateTime(json, r'createdAt', r'')!,
        updatedAt: mapDateTime(json, r'updatedAt', r'')!,
      );
    }
    return null;
  }

  static List<StationJob> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <StationJob>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = StationJob.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, StationJob> mapFromJson(dynamic json) {
    final map = <String, StationJob>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = StationJob.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of StationJob-objects as value to a dart map
  static Map<String, List<StationJob>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<StationJob>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = StationJob.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'stationId',
    'stationName',
    'orderId',
    'saleId',
    'orderReference',
    'variantId',
    'kind',
    'state',
    'copy',
    'reprintOfId',
    'itemName',
    'variantName',
    'quantity',
    'modifiers',
    'attempts',
    'lastError',
    'createdAt',
    'updatedAt',
  };
}


enum StationJobStateEnum {
  QUEUED._(r'QUEUED'),
  SENDING._(r'SENDING'),
  SENT._(r'SENT'),
  FAILED._(r'FAILED'),
  UNKNOWN._(r'UNKNOWN'),
  ;

  /// Instantiate a new enum with the provided value.
  const StationJobStateEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [StationJobStateEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static StationJobStateEnum? fromJson(dynamic value) => StationJobStateEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [StationJobStateEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<StationJobStateEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <StationJobStateEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = StationJobStateEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [StationJobStateEnum] to String,
/// and [decode] dynamic data back to [StationJobStateEnum].
class StationJobStateEnumTypeTransformer {
  factory StationJobStateEnumTypeTransformer() => _instance ??= const StationJobStateEnumTypeTransformer._();

  const StationJobStateEnumTypeTransformer._();

  String encode(StationJobStateEnum data) => data._value;

  /// Returns the instance of [StationJobStateEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  StationJobStateEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is StationJobStateEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'QUEUED': return StationJobStateEnum.QUEUED;
        case r'SENDING': return StationJobStateEnum.SENDING;
        case r'SENT': return StationJobStateEnum.SENT;
        case r'FAILED': return StationJobStateEnum.FAILED;
        case r'UNKNOWN': return StationJobStateEnum.UNKNOWN;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static StationJobStateEnumTypeTransformer? _instance;
}


