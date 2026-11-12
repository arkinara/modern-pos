//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PromotionSnapshot {
  /// Returns a new [PromotionSnapshot] instance.
  PromotionSnapshot({
    required this.promotionId,
    required this.name,
    required this.kind,
    required this.discountMinor,
  });

  String promotionId;

  String name;

  PromotionSnapshotKindEnum kind;

  /// Currency minor units; IDR exponent 0 in demo.
  ///
  /// Minimum value: 0
  /// Maximum value: 9007199254740991
  int discountMinor;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PromotionSnapshot &&
    other.promotionId == promotionId &&
    other.name == name &&
    other.kind == kind &&
    other.discountMinor == discountMinor;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (promotionId.hashCode) +
    (name.hashCode) +
    (kind.hashCode) +
    (discountMinor.hashCode);

  @override
  String toString() => 'PromotionSnapshot[promotionId=$promotionId, name=$name, kind=$kind, discountMinor=$discountMinor]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'promotionId'] = this.promotionId;
      json[r'name'] = this.name;
      json[r'kind'] = this.kind;
      json[r'discountMinor'] = this.discountMinor;
    return json;
  }

  /// Returns a new [PromotionSnapshot] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PromotionSnapshot? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'promotionId'), 'Required key "PromotionSnapshot[promotionId]" is missing from JSON.');
        assert(json[r'promotionId'] != null, 'Required key "PromotionSnapshot[promotionId]" has a null value in JSON.');
        assert(json.containsKey(r'name'), 'Required key "PromotionSnapshot[name]" is missing from JSON.');
        assert(json[r'name'] != null, 'Required key "PromotionSnapshot[name]" has a null value in JSON.');
        assert(json.containsKey(r'kind'), 'Required key "PromotionSnapshot[kind]" is missing from JSON.');
        assert(json[r'kind'] != null, 'Required key "PromotionSnapshot[kind]" has a null value in JSON.');
        assert(json.containsKey(r'discountMinor'), 'Required key "PromotionSnapshot[discountMinor]" is missing from JSON.');
        assert(json[r'discountMinor'] != null, 'Required key "PromotionSnapshot[discountMinor]" has a null value in JSON.');
        return true;
      }());

      return PromotionSnapshot(
        promotionId: mapValueOfType<String>(json, r'promotionId')!,
        name: mapValueOfType<String>(json, r'name')!,
        kind: PromotionSnapshotKindEnum.fromJson(json[r'kind'])!,
        discountMinor: mapValueOfType<int>(json, r'discountMinor')!,
      );
    }
    return null;
  }

  static List<PromotionSnapshot> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PromotionSnapshot>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PromotionSnapshot.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PromotionSnapshot> mapFromJson(dynamic json) {
    final map = <String, PromotionSnapshot>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PromotionSnapshot.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PromotionSnapshot-objects as value to a dart map
  static Map<String, List<PromotionSnapshot>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PromotionSnapshot>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PromotionSnapshot.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'promotionId',
    'name',
    'kind',
    'discountMinor',
  };
}


enum PromotionSnapshotKindEnum {
  PERCENTAGE._(r'PERCENTAGE'),
  FIXED_AMOUNT._(r'FIXED_AMOUNT'),
  ;

  /// Instantiate a new enum with the provided value.
  const PromotionSnapshotKindEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [PromotionSnapshotKindEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static PromotionSnapshotKindEnum? fromJson(dynamic value) => PromotionSnapshotKindEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [PromotionSnapshotKindEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<PromotionSnapshotKindEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PromotionSnapshotKindEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PromotionSnapshotKindEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [PromotionSnapshotKindEnum] to String,
/// and [decode] dynamic data back to [PromotionSnapshotKindEnum].
class PromotionSnapshotKindEnumTypeTransformer {
  factory PromotionSnapshotKindEnumTypeTransformer() => _instance ??= const PromotionSnapshotKindEnumTypeTransformer._();

  const PromotionSnapshotKindEnumTypeTransformer._();

  String encode(PromotionSnapshotKindEnum data) => data._value;

  /// Returns the instance of [PromotionSnapshotKindEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  PromotionSnapshotKindEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is PromotionSnapshotKindEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'PERCENTAGE': return PromotionSnapshotKindEnum.PERCENTAGE;
        case r'FIXED_AMOUNT': return PromotionSnapshotKindEnum.FIXED_AMOUNT;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static PromotionSnapshotKindEnumTypeTransformer? _instance;
}


