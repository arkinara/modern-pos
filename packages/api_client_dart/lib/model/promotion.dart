//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Promotion {
  /// Returns a new [Promotion] instance.
  Promotion({
    required this.id,
    required this.name,
    required this.kind,
    required this.percentageBps,
    required this.amountMinor,
    required this.minBasketMinor,
    required this.startsAt,
    required this.endsAt,
    required this.active,
    required this.stacking,
    required this.priority,
    required this.eligibility,
    required this.revision,
    required this.createdAt,
    required this.updatedAt,
  });

  String id;

  String name;

  PromotionKindEnum kind;

  /// Minimum value: 1
  /// Maximum value: 10000
  int? percentageBps;

  /// Currency minor units; IDR exponent 0 in demo.
  ///
  /// Minimum value: 0
  /// Maximum value: 9007199254740991
  int? amountMinor;

  /// Currency minor units; IDR exponent 0 in demo.
  ///
  /// Minimum value: 0
  /// Maximum value: 9007199254740991
  int minBasketMinor;

  DateTime? startsAt;

  DateTime? endsAt;

  bool active;

  PromotionStackingEnum stacking;

  /// Minimum value: -1000
  /// Maximum value: 1000
  int priority;

  PromotionEligibility eligibility;

  /// Minimum value: 1
  int revision;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Promotion &&
    other.id == id &&
    other.name == name &&
    other.kind == kind &&
    other.percentageBps == percentageBps &&
    other.amountMinor == amountMinor &&
    other.minBasketMinor == minBasketMinor &&
    other.startsAt == startsAt &&
    other.endsAt == endsAt &&
    other.active == active &&
    other.stacking == stacking &&
    other.priority == priority &&
    other.eligibility == eligibility &&
    other.revision == revision &&
    other.createdAt == createdAt &&
    other.updatedAt == updatedAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (name.hashCode) +
    (kind.hashCode) +
    (percentageBps == null ? 0 : percentageBps!.hashCode) +
    (amountMinor == null ? 0 : amountMinor!.hashCode) +
    (minBasketMinor.hashCode) +
    (startsAt == null ? 0 : startsAt!.hashCode) +
    (endsAt == null ? 0 : endsAt!.hashCode) +
    (active.hashCode) +
    (stacking.hashCode) +
    (priority.hashCode) +
    (eligibility.hashCode) +
    (revision.hashCode) +
    (createdAt.hashCode) +
    (updatedAt.hashCode);

  @override
  String toString() => 'Promotion[id=$id, name=$name, kind=$kind, percentageBps=$percentageBps, amountMinor=$amountMinor, minBasketMinor=$minBasketMinor, startsAt=$startsAt, endsAt=$endsAt, active=$active, stacking=$stacking, priority=$priority, eligibility=$eligibility, revision=$revision, createdAt=$createdAt, updatedAt=$updatedAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'name'] = this.name;
      json[r'kind'] = this.kind;
    if (this.percentageBps != null) {
      json[r'percentageBps'] = this.percentageBps;
    } else {
      json[r'percentageBps'] = null;
    }
    if (this.amountMinor != null) {
      json[r'amountMinor'] = this.amountMinor;
    } else {
      json[r'amountMinor'] = null;
    }
      json[r'minBasketMinor'] = this.minBasketMinor;
    if (this.startsAt != null) {
      json[r'startsAt'] = this.startsAt!.toUtc().toIso8601String();
    } else {
      json[r'startsAt'] = null;
    }
    if (this.endsAt != null) {
      json[r'endsAt'] = this.endsAt!.toUtc().toIso8601String();
    } else {
      json[r'endsAt'] = null;
    }
      json[r'active'] = this.active;
      json[r'stacking'] = this.stacking;
      json[r'priority'] = this.priority;
      json[r'eligibility'] = this.eligibility;
      json[r'revision'] = this.revision;
      json[r'createdAt'] = this.createdAt.toUtc().toIso8601String();
      json[r'updatedAt'] = this.updatedAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [Promotion] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Promotion? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "Promotion[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "Promotion[id]" has a null value in JSON.');
        assert(json.containsKey(r'name'), 'Required key "Promotion[name]" is missing from JSON.');
        assert(json[r'name'] != null, 'Required key "Promotion[name]" has a null value in JSON.');
        assert(json.containsKey(r'kind'), 'Required key "Promotion[kind]" is missing from JSON.');
        assert(json[r'kind'] != null, 'Required key "Promotion[kind]" has a null value in JSON.');
        assert(json.containsKey(r'percentageBps'), 'Required key "Promotion[percentageBps]" is missing from JSON.');
        assert(json.containsKey(r'amountMinor'), 'Required key "Promotion[amountMinor]" is missing from JSON.');
        assert(json.containsKey(r'minBasketMinor'), 'Required key "Promotion[minBasketMinor]" is missing from JSON.');
        assert(json[r'minBasketMinor'] != null, 'Required key "Promotion[minBasketMinor]" has a null value in JSON.');
        assert(json.containsKey(r'startsAt'), 'Required key "Promotion[startsAt]" is missing from JSON.');
        assert(json.containsKey(r'endsAt'), 'Required key "Promotion[endsAt]" is missing from JSON.');
        assert(json.containsKey(r'active'), 'Required key "Promotion[active]" is missing from JSON.');
        assert(json[r'active'] != null, 'Required key "Promotion[active]" has a null value in JSON.');
        assert(json.containsKey(r'stacking'), 'Required key "Promotion[stacking]" is missing from JSON.');
        assert(json[r'stacking'] != null, 'Required key "Promotion[stacking]" has a null value in JSON.');
        assert(json.containsKey(r'priority'), 'Required key "Promotion[priority]" is missing from JSON.');
        assert(json[r'priority'] != null, 'Required key "Promotion[priority]" has a null value in JSON.');
        assert(json.containsKey(r'eligibility'), 'Required key "Promotion[eligibility]" is missing from JSON.');
        assert(json[r'eligibility'] != null, 'Required key "Promotion[eligibility]" has a null value in JSON.');
        assert(json.containsKey(r'revision'), 'Required key "Promotion[revision]" is missing from JSON.');
        assert(json[r'revision'] != null, 'Required key "Promotion[revision]" has a null value in JSON.');
        assert(json.containsKey(r'createdAt'), 'Required key "Promotion[createdAt]" is missing from JSON.');
        assert(json[r'createdAt'] != null, 'Required key "Promotion[createdAt]" has a null value in JSON.');
        assert(json.containsKey(r'updatedAt'), 'Required key "Promotion[updatedAt]" is missing from JSON.');
        assert(json[r'updatedAt'] != null, 'Required key "Promotion[updatedAt]" has a null value in JSON.');
        return true;
      }());

      return Promotion(
        id: mapValueOfType<String>(json, r'id')!,
        name: mapValueOfType<String>(json, r'name')!,
        kind: PromotionKindEnum.fromJson(json[r'kind'])!,
        percentageBps: mapValueOfType<int>(json, r'percentageBps'),
        amountMinor: mapValueOfType<int>(json, r'amountMinor'),
        minBasketMinor: mapValueOfType<int>(json, r'minBasketMinor')!,
        startsAt: mapDateTime(json, r'startsAt', r''),
        endsAt: mapDateTime(json, r'endsAt', r''),
        active: mapValueOfType<bool>(json, r'active')!,
        stacking: PromotionStackingEnum.fromJson(json[r'stacking'])!,
        priority: mapValueOfType<int>(json, r'priority')!,
        eligibility: PromotionEligibility.fromJson(json[r'eligibility'])!,
        revision: mapValueOfType<int>(json, r'revision')!,
        createdAt: mapDateTime(json, r'createdAt', r'')!,
        updatedAt: mapDateTime(json, r'updatedAt', r'')!,
      );
    }
    return null;
  }

  static List<Promotion> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Promotion>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Promotion.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Promotion> mapFromJson(dynamic json) {
    final map = <String, Promotion>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Promotion.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Promotion-objects as value to a dart map
  static Map<String, List<Promotion>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Promotion>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Promotion.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'name',
    'kind',
    'percentageBps',
    'amountMinor',
    'minBasketMinor',
    'startsAt',
    'endsAt',
    'active',
    'stacking',
    'priority',
    'eligibility',
    'revision',
    'createdAt',
    'updatedAt',
  };
}


enum PromotionKindEnum {
  PERCENTAGE._(r'PERCENTAGE'),
  FIXED_AMOUNT._(r'FIXED_AMOUNT'),
  ;

  /// Instantiate a new enum with the provided value.
  const PromotionKindEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [PromotionKindEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static PromotionKindEnum? fromJson(dynamic value) => PromotionKindEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [PromotionKindEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<PromotionKindEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PromotionKindEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PromotionKindEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [PromotionKindEnum] to String,
/// and [decode] dynamic data back to [PromotionKindEnum].
class PromotionKindEnumTypeTransformer {
  factory PromotionKindEnumTypeTransformer() => _instance ??= const PromotionKindEnumTypeTransformer._();

  const PromotionKindEnumTypeTransformer._();

  String encode(PromotionKindEnum data) => data._value;

  /// Returns the instance of [PromotionKindEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  PromotionKindEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is PromotionKindEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'PERCENTAGE': return PromotionKindEnum.PERCENTAGE;
        case r'FIXED_AMOUNT': return PromotionKindEnum.FIXED_AMOUNT;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static PromotionKindEnumTypeTransformer? _instance;
}



enum PromotionStackingEnum {
  EXCLUSIVE._(r'EXCLUSIVE'),
  STACKABLE._(r'STACKABLE'),
  ;

  /// Instantiate a new enum with the provided value.
  const PromotionStackingEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [PromotionStackingEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static PromotionStackingEnum? fromJson(dynamic value) => PromotionStackingEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [PromotionStackingEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<PromotionStackingEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PromotionStackingEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PromotionStackingEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [PromotionStackingEnum] to String,
/// and [decode] dynamic data back to [PromotionStackingEnum].
class PromotionStackingEnumTypeTransformer {
  factory PromotionStackingEnumTypeTransformer() => _instance ??= const PromotionStackingEnumTypeTransformer._();

  const PromotionStackingEnumTypeTransformer._();

  String encode(PromotionStackingEnum data) => data._value;

  /// Returns the instance of [PromotionStackingEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  PromotionStackingEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is PromotionStackingEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'EXCLUSIVE': return PromotionStackingEnum.EXCLUSIVE;
        case r'STACKABLE': return PromotionStackingEnum.STACKABLE;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static PromotionStackingEnumTypeTransformer? _instance;
}


