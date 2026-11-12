//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PromotionUpdate {
  /// Returns a new [PromotionUpdate] instance.
  PromotionUpdate({
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
    required this.revision,
  });

  String name;

  PromotionUpdateKindEnum kind;

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

  PromotionUpdateStackingEnum? stacking;

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

  /// Minimum value: 1
  int revision;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PromotionUpdate &&
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
    other.revision == revision;

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
    (eligibility == null ? 0 : eligibility!.hashCode) +
    (revision.hashCode);

  @override
  String toString() => 'PromotionUpdate[name=$name, kind=$kind, percentageBps=$percentageBps, amountMinor=$amountMinor, minBasketMinor=$minBasketMinor, startsAt=$startsAt, endsAt=$endsAt, active=$active, stacking=$stacking, priority=$priority, eligibility=$eligibility, revision=$revision]';

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
      json[r'revision'] = this.revision;
    return json;
  }

  /// Returns a new [PromotionUpdate] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PromotionUpdate? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'name'), 'Required key "PromotionUpdate[name]" is missing from JSON.');
        assert(json[r'name'] != null, 'Required key "PromotionUpdate[name]" has a null value in JSON.');
        assert(json.containsKey(r'kind'), 'Required key "PromotionUpdate[kind]" is missing from JSON.');
        assert(json[r'kind'] != null, 'Required key "PromotionUpdate[kind]" has a null value in JSON.');
        assert(json.containsKey(r'revision'), 'Required key "PromotionUpdate[revision]" is missing from JSON.');
        assert(json[r'revision'] != null, 'Required key "PromotionUpdate[revision]" has a null value in JSON.');
        return true;
      }());

      return PromotionUpdate(
        name: mapValueOfType<String>(json, r'name')!,
        kind: PromotionUpdateKindEnum.fromJson(json[r'kind'])!,
        percentageBps: mapValueOfType<int>(json, r'percentageBps'),
        amountMinor: mapValueOfType<int>(json, r'amountMinor'),
        minBasketMinor: mapValueOfType<int>(json, r'minBasketMinor'),
        startsAt: mapDateTime(json, r'startsAt', r''),
        endsAt: mapDateTime(json, r'endsAt', r''),
        active: mapValueOfType<bool>(json, r'active'),
        stacking: PromotionUpdateStackingEnum.fromJson(json[r'stacking']),
        priority: mapValueOfType<int>(json, r'priority'),
        eligibility: PromotionEligibility.fromJson(json[r'eligibility']),
        revision: mapValueOfType<int>(json, r'revision')!,
      );
    }
    return null;
  }

  static List<PromotionUpdate> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PromotionUpdate>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PromotionUpdate.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PromotionUpdate> mapFromJson(dynamic json) {
    final map = <String, PromotionUpdate>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PromotionUpdate.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PromotionUpdate-objects as value to a dart map
  static Map<String, List<PromotionUpdate>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PromotionUpdate>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PromotionUpdate.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'name',
    'kind',
    'revision',
  };
}


enum PromotionUpdateKindEnum {
  PERCENTAGE._(r'PERCENTAGE'),
  FIXED_AMOUNT._(r'FIXED_AMOUNT'),
  ;

  /// Instantiate a new enum with the provided value.
  const PromotionUpdateKindEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [PromotionUpdateKindEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static PromotionUpdateKindEnum? fromJson(dynamic value) => PromotionUpdateKindEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [PromotionUpdateKindEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<PromotionUpdateKindEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PromotionUpdateKindEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PromotionUpdateKindEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [PromotionUpdateKindEnum] to String,
/// and [decode] dynamic data back to [PromotionUpdateKindEnum].
class PromotionUpdateKindEnumTypeTransformer {
  factory PromotionUpdateKindEnumTypeTransformer() => _instance ??= const PromotionUpdateKindEnumTypeTransformer._();

  const PromotionUpdateKindEnumTypeTransformer._();

  String encode(PromotionUpdateKindEnum data) => data._value;

  /// Returns the instance of [PromotionUpdateKindEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  PromotionUpdateKindEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is PromotionUpdateKindEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'PERCENTAGE': return PromotionUpdateKindEnum.PERCENTAGE;
        case r'FIXED_AMOUNT': return PromotionUpdateKindEnum.FIXED_AMOUNT;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static PromotionUpdateKindEnumTypeTransformer? _instance;
}



enum PromotionUpdateStackingEnum {
  EXCLUSIVE._(r'EXCLUSIVE'),
  STACKABLE._(r'STACKABLE'),
  ;

  /// Instantiate a new enum with the provided value.
  const PromotionUpdateStackingEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [PromotionUpdateStackingEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static PromotionUpdateStackingEnum? fromJson(dynamic value) => PromotionUpdateStackingEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [PromotionUpdateStackingEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<PromotionUpdateStackingEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PromotionUpdateStackingEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PromotionUpdateStackingEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [PromotionUpdateStackingEnum] to String,
/// and [decode] dynamic data back to [PromotionUpdateStackingEnum].
class PromotionUpdateStackingEnumTypeTransformer {
  factory PromotionUpdateStackingEnumTypeTransformer() => _instance ??= const PromotionUpdateStackingEnumTypeTransformer._();

  const PromotionUpdateStackingEnumTypeTransformer._();

  String encode(PromotionUpdateStackingEnum data) => data._value;

  /// Returns the instance of [PromotionUpdateStackingEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  PromotionUpdateStackingEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is PromotionUpdateStackingEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'EXCLUSIVE': return PromotionUpdateStackingEnum.EXCLUSIVE;
        case r'STACKABLE': return PromotionUpdateStackingEnum.STACKABLE;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static PromotionUpdateStackingEnumTypeTransformer? _instance;
}


