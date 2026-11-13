//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class WasteWrite {
  /// Returns a new [WasteWrite] instance.
  WasteWrite({
    required this.stockItemId,
    required this.quantity,
    required this.reason,
    this.note,
  });

  String stockItemId;

  /// Nonnegative fixed-point quantity. Business validation rejects zero where a positive quantity is required.
  String quantity;

  WasteWriteReasonEnum reason;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? note;

  @override
  bool operator ==(Object other) => identical(this, other) || other is WasteWrite &&
    other.stockItemId == stockItemId &&
    other.quantity == quantity &&
    other.reason == reason &&
    other.note == note;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (stockItemId.hashCode) +
    (quantity.hashCode) +
    (reason.hashCode) +
    (note == null ? 0 : note!.hashCode);

  @override
  String toString() => 'WasteWrite[stockItemId=$stockItemId, quantity=$quantity, reason=$reason, note=$note]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'stockItemId'] = this.stockItemId;
      json[r'quantity'] = this.quantity;
      json[r'reason'] = this.reason;
    if (this.note != null) {
      json[r'note'] = this.note;
    } else {
      json[r'note'] = null;
    }
    return json;
  }

  /// Returns a new [WasteWrite] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static WasteWrite? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'stockItemId'), 'Required key "WasteWrite[stockItemId]" is missing from JSON.');
        assert(json[r'stockItemId'] != null, 'Required key "WasteWrite[stockItemId]" has a null value in JSON.');
        assert(json.containsKey(r'quantity'), 'Required key "WasteWrite[quantity]" is missing from JSON.');
        assert(json[r'quantity'] != null, 'Required key "WasteWrite[quantity]" has a null value in JSON.');
        assert(json.containsKey(r'reason'), 'Required key "WasteWrite[reason]" is missing from JSON.');
        assert(json[r'reason'] != null, 'Required key "WasteWrite[reason]" has a null value in JSON.');
        return true;
      }());

      return WasteWrite(
        stockItemId: mapValueOfType<String>(json, r'stockItemId')!,
        quantity: mapValueOfType<String>(json, r'quantity')!,
        reason: WasteWriteReasonEnum.fromJson(json[r'reason'])!,
        note: mapValueOfType<String>(json, r'note'),
      );
    }
    return null;
  }

  static List<WasteWrite> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <WasteWrite>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = WasteWrite.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, WasteWrite> mapFromJson(dynamic json) {
    final map = <String, WasteWrite>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = WasteWrite.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of WasteWrite-objects as value to a dart map
  static Map<String, List<WasteWrite>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<WasteWrite>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = WasteWrite.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'stockItemId',
    'quantity',
    'reason',
  };
}


enum WasteWriteReasonEnum {
  DAMAGE._(r'DAMAGE'),
  EXPIRY._(r'EXPIRY'),
  THEFT._(r'THEFT'),
  SPOILAGE._(r'SPOILAGE'),
  OTHER._(r'OTHER'),
  ;

  /// Instantiate a new enum with the provided value.
  const WasteWriteReasonEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [WasteWriteReasonEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static WasteWriteReasonEnum? fromJson(dynamic value) => WasteWriteReasonEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [WasteWriteReasonEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<WasteWriteReasonEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <WasteWriteReasonEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = WasteWriteReasonEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [WasteWriteReasonEnum] to String,
/// and [decode] dynamic data back to [WasteWriteReasonEnum].
class WasteWriteReasonEnumTypeTransformer {
  factory WasteWriteReasonEnumTypeTransformer() => _instance ??= const WasteWriteReasonEnumTypeTransformer._();

  const WasteWriteReasonEnumTypeTransformer._();

  String encode(WasteWriteReasonEnum data) => data._value;

  /// Returns the instance of [WasteWriteReasonEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  WasteWriteReasonEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is WasteWriteReasonEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'DAMAGE': return WasteWriteReasonEnum.DAMAGE;
        case r'EXPIRY': return WasteWriteReasonEnum.EXPIRY;
        case r'THEFT': return WasteWriteReasonEnum.THEFT;
        case r'SPOILAGE': return WasteWriteReasonEnum.SPOILAGE;
        case r'OTHER': return WasteWriteReasonEnum.OTHER;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static WasteWriteReasonEnumTypeTransformer? _instance;
}


