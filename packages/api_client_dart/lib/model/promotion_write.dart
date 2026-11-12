//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PromotionWrite {
  /// Returns a new [PromotionWrite] instance.
  PromotionWrite({
    required this.name,
    required this.kind,
    this.percentageBps,
    this.amountMinor,
    this.minBasketMinor,
    this.startsAt,
    this.endsAt,
    this.active,
    this.stacking,
    this.priority,
    this.eligibility,
  });

  String name;

  PromotionWriteKindEnum kind;

  /// Minimum value: 1
  /// Maximum value: 10000
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? percentageBps;

  /// Currency minor units; IDR exponent 0 in demo.
  ///
  /// Minimum value: 0
  /// Maximum value: 9007199254740991
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? amountMinor;

  /// Currency minor units; IDR exponent 0 in demo.
  ///
  /// Minimum value: 0
  /// Maximum value: 9007199254740991
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? minBasketMinor;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  DateTime? startsAt;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  DateTime? endsAt;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? active;

  PromotionWriteStackingEnum? stacking;

  /// Minimum value: -1000
  /// Maximum value: 1000
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? priority;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  PromotionEligibility? eligibility;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PromotionWrite &&
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
    other.eligibility == eligibility;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (name.hashCode) +
    (kind.hashCode) +
    (percentageBps == null ? 0 : percentageBps!.hashCode) +
    (amountMinor == null ? 0 : amountMinor!.hashCode) +
    (minBasketMinor == null ? 0 : minBasketMinor!.hashCode) +
    (startsAt == null ? 0 : startsAt!.hashCode) +
    (endsAt == null ? 0 : endsAt!.hashCode) +
    (active == null ? 0 : active!.hashCode) +
    (stacking == null ? 0 : stacking!.hashCode) +
    (priority == null ? 0 : priority!.hashCode) +
    (eligibility == null ? 0 : eligibility!.hashCode);

  @override
  String toString() => 'PromotionWrite[name=$name, kind=$kind, percentageBps=$percentageBps, amountMinor=$amountMinor, minBasketMinor=$minBasketMinor, startsAt=$startsAt, endsAt=$endsAt, active=$active, stacking=$stacking, priority=$priority, eligibility=$eligibility]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
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
    if (this.minBasketMinor != null) {
      json[r'minBasketMinor'] = this.minBasketMinor;
    } else {
      json[r'minBasketMinor'] = null;
    }
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
    if (this.active != null) {
      json[r'active'] = this.active;
    } else {
      json[r'active'] = null;
    }
    if (this.stacking != null) {
      json[r'stacking'] = this.stacking;
    } else {
      json[r'stacking'] = null;
    }
    if (this.priority != null) {
      json[r'priority'] = this.priority;
    } else {
      json[r'priority'] = null;
    }
    if (this.eligibility != null) {
      json[r'eligibility'] = this.eligibility;
    } else {
      json[r'eligibility'] = null;
    }
    return json;
  }

  /// Returns a new [PromotionWrite] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PromotionWrite? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'name'), 'Required key "PromotionWrite[name]" is missing from JSON.');
        assert(json[r'name'] != null, 'Required key "PromotionWrite[name]" has a null value in JSON.');
        assert(json.containsKey(r'kind'), 'Required key "PromotionWrite[kind]" is missing from JSON.');
        assert(json[r'kind'] != null, 'Required key "PromotionWrite[kind]" has a null value in JSON.');
        return true;
      }());

      return PromotionWrite(
        name: mapValueOfType<String>(json, r'name')!,
        kind: PromotionWriteKindEnum.fromJson(json[r'kind'])!,
        percentageBps: mapValueOfType<int>(json, r'percentageBps'),
        amountMinor: mapValueOfType<int>(json, r'amountMinor'),
        minBasketMinor: mapValueOfType<int>(json, r'minBasketMinor'),
        startsAt: mapDateTime(json, r'startsAt', r''),
        endsAt: mapDateTime(json, r'endsAt', r''),
        active: mapValueOfType<bool>(json, r'active'),
        stacking: PromotionWriteStackingEnum.fromJson(json[r'stacking']),
        priority: mapValueOfType<int>(json, r'priority'),
        eligibility: PromotionEligibility.fromJson(json[r'eligibility']),
      );
    }
    return null;
  }

  static List<PromotionWrite> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PromotionWrite>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PromotionWrite.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PromotionWrite> mapFromJson(dynamic json) {
    final map = <String, PromotionWrite>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PromotionWrite.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PromotionWrite-objects as value to a dart map
  static Map<String, List<PromotionWrite>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PromotionWrite>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PromotionWrite.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'name',
    'kind',
  };
}


enum PromotionWriteKindEnum {
  PERCENTAGE._(r'PERCENTAGE'),
  FIXED_AMOUNT._(r'FIXED_AMOUNT'),
  ;

  /// Instantiate a new enum with the provided value.
  const PromotionWriteKindEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [PromotionWriteKindEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static PromotionWriteKindEnum? fromJson(dynamic value) => PromotionWriteKindEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [PromotionWriteKindEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<PromotionWriteKindEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PromotionWriteKindEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PromotionWriteKindEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [PromotionWriteKindEnum] to String,
/// and [decode] dynamic data back to [PromotionWriteKindEnum].
class PromotionWriteKindEnumTypeTransformer {
  factory PromotionWriteKindEnumTypeTransformer() => _instance ??= const PromotionWriteKindEnumTypeTransformer._();

  const PromotionWriteKindEnumTypeTransformer._();

  String encode(PromotionWriteKindEnum data) => data._value;

  /// Returns the instance of [PromotionWriteKindEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  PromotionWriteKindEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is PromotionWriteKindEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'PERCENTAGE': return PromotionWriteKindEnum.PERCENTAGE;
        case r'FIXED_AMOUNT': return PromotionWriteKindEnum.FIXED_AMOUNT;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static PromotionWriteKindEnumTypeTransformer? _instance;
}



enum PromotionWriteStackingEnum {
  EXCLUSIVE._(r'EXCLUSIVE'),
  STACKABLE._(r'STACKABLE'),
  ;

  /// Instantiate a new enum with the provided value.
  const PromotionWriteStackingEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [PromotionWriteStackingEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static PromotionWriteStackingEnum? fromJson(dynamic value) => PromotionWriteStackingEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [PromotionWriteStackingEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<PromotionWriteStackingEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PromotionWriteStackingEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PromotionWriteStackingEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [PromotionWriteStackingEnum] to String,
/// and [decode] dynamic data back to [PromotionWriteStackingEnum].
class PromotionWriteStackingEnumTypeTransformer {
  factory PromotionWriteStackingEnumTypeTransformer() => _instance ??= const PromotionWriteStackingEnumTypeTransformer._();

  const PromotionWriteStackingEnumTypeTransformer._();

  String encode(PromotionWriteStackingEnum data) => data._value;

  /// Returns the instance of [PromotionWriteStackingEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  PromotionWriteStackingEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is PromotionWriteStackingEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'EXCLUSIVE': return PromotionWriteStackingEnum.EXCLUSIVE;
        case r'STACKABLE': return PromotionWriteStackingEnum.STACKABLE;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static PromotionWriteStackingEnumTypeTransformer? _instance;
}


