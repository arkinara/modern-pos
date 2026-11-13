//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Waste {
  /// Returns a new [Waste] instance.
  Waste({
    required this.id,
    required this.outletId,
    required this.stockItemId,
    required this.stockItemName,
    required this.quantity,
    required this.reason,
    required this.note,
    required this.actorId,
    required this.createdAt,
    required this.movement,
  });

  String id;

  String outletId;

  String stockItemId;

  String stockItemName;

  String quantity;

  WasteReasonEnum reason;

  String? note;

  String actorId;

  DateTime createdAt;

  Movement movement;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Waste &&
    other.id == id &&
    other.outletId == outletId &&
    other.stockItemId == stockItemId &&
    other.stockItemName == stockItemName &&
    other.quantity == quantity &&
    other.reason == reason &&
    other.note == note &&
    other.actorId == actorId &&
    other.createdAt == createdAt &&
    other.movement == movement;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (outletId.hashCode) +
    (stockItemId.hashCode) +
    (stockItemName.hashCode) +
    (quantity.hashCode) +
    (reason.hashCode) +
    (note == null ? 0 : note!.hashCode) +
    (actorId.hashCode) +
    (createdAt.hashCode) +
    (movement.hashCode);

  @override
  String toString() => 'Waste[id=$id, outletId=$outletId, stockItemId=$stockItemId, stockItemName=$stockItemName, quantity=$quantity, reason=$reason, note=$note, actorId=$actorId, createdAt=$createdAt, movement=$movement]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'outletId'] = this.outletId;
      json[r'stockItemId'] = this.stockItemId;
      json[r'stockItemName'] = this.stockItemName;
      json[r'quantity'] = this.quantity;
      json[r'reason'] = this.reason;
    if (this.note != null) {
      json[r'note'] = this.note;
    } else {
      json[r'note'] = null;
    }
      json[r'actorId'] = this.actorId;
      json[r'createdAt'] = this.createdAt.toUtc().toIso8601String();
      json[r'movement'] = this.movement;
    return json;
  }

  /// Returns a new [Waste] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Waste? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "Waste[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "Waste[id]" has a null value in JSON.');
        assert(json.containsKey(r'outletId'), 'Required key "Waste[outletId]" is missing from JSON.');
        assert(json[r'outletId'] != null, 'Required key "Waste[outletId]" has a null value in JSON.');
        assert(json.containsKey(r'stockItemId'), 'Required key "Waste[stockItemId]" is missing from JSON.');
        assert(json[r'stockItemId'] != null, 'Required key "Waste[stockItemId]" has a null value in JSON.');
        assert(json.containsKey(r'stockItemName'), 'Required key "Waste[stockItemName]" is missing from JSON.');
        assert(json[r'stockItemName'] != null, 'Required key "Waste[stockItemName]" has a null value in JSON.');
        assert(json.containsKey(r'quantity'), 'Required key "Waste[quantity]" is missing from JSON.');
        assert(json[r'quantity'] != null, 'Required key "Waste[quantity]" has a null value in JSON.');
        assert(json.containsKey(r'reason'), 'Required key "Waste[reason]" is missing from JSON.');
        assert(json[r'reason'] != null, 'Required key "Waste[reason]" has a null value in JSON.');
        assert(json.containsKey(r'note'), 'Required key "Waste[note]" is missing from JSON.');
        assert(json.containsKey(r'actorId'), 'Required key "Waste[actorId]" is missing from JSON.');
        assert(json[r'actorId'] != null, 'Required key "Waste[actorId]" has a null value in JSON.');
        assert(json.containsKey(r'createdAt'), 'Required key "Waste[createdAt]" is missing from JSON.');
        assert(json[r'createdAt'] != null, 'Required key "Waste[createdAt]" has a null value in JSON.');
        assert(json.containsKey(r'movement'), 'Required key "Waste[movement]" is missing from JSON.');
        assert(json[r'movement'] != null, 'Required key "Waste[movement]" has a null value in JSON.');
        return true;
      }());

      return Waste(
        id: mapValueOfType<String>(json, r'id')!,
        outletId: mapValueOfType<String>(json, r'outletId')!,
        stockItemId: mapValueOfType<String>(json, r'stockItemId')!,
        stockItemName: mapValueOfType<String>(json, r'stockItemName')!,
        quantity: mapValueOfType<String>(json, r'quantity')!,
        reason: WasteReasonEnum.fromJson(json[r'reason'])!,
        note: mapValueOfType<String>(json, r'note'),
        actorId: mapValueOfType<String>(json, r'actorId')!,
        createdAt: mapDateTime(json, r'createdAt', r'')!,
        movement: Movement.fromJson(json[r'movement'])!,
      );
    }
    return null;
  }

  static List<Waste> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Waste>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Waste.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Waste> mapFromJson(dynamic json) {
    final map = <String, Waste>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Waste.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Waste-objects as value to a dart map
  static Map<String, List<Waste>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Waste>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Waste.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'outletId',
    'stockItemId',
    'stockItemName',
    'quantity',
    'reason',
    'note',
    'actorId',
    'createdAt',
    'movement',
  };
}


enum WasteReasonEnum {
  DAMAGE._(r'DAMAGE'),
  EXPIRY._(r'EXPIRY'),
  THEFT._(r'THEFT'),
  SPOILAGE._(r'SPOILAGE'),
  OTHER._(r'OTHER'),
  ;

  /// Instantiate a new enum with the provided value.
  const WasteReasonEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [WasteReasonEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static WasteReasonEnum? fromJson(dynamic value) => WasteReasonEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [WasteReasonEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<WasteReasonEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <WasteReasonEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = WasteReasonEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [WasteReasonEnum] to String,
/// and [decode] dynamic data back to [WasteReasonEnum].
class WasteReasonEnumTypeTransformer {
  factory WasteReasonEnumTypeTransformer() => _instance ??= const WasteReasonEnumTypeTransformer._();

  const WasteReasonEnumTypeTransformer._();

  String encode(WasteReasonEnum data) => data._value;

  /// Returns the instance of [WasteReasonEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  WasteReasonEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is WasteReasonEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'DAMAGE': return WasteReasonEnum.DAMAGE;
        case r'EXPIRY': return WasteReasonEnum.EXPIRY;
        case r'THEFT': return WasteReasonEnum.THEFT;
        case r'SPOILAGE': return WasteReasonEnum.SPOILAGE;
        case r'OTHER': return WasteReasonEnum.OTHER;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static WasteReasonEnumTypeTransformer? _instance;
}


