//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CalculationRules {
  /// Returns a new [CalculationRules] instance.
  CalculationRules({
    required this.taxBps,
    required this.serviceBps,
    required this.pricingMode,
    required this.currencyExponent,
    required this.rounding,
  });

  /// Minimum value: 0
  /// Maximum value: 10000
  int taxBps;

  /// Minimum value: 0
  /// Maximum value: 10000
  int serviceBps;

  CalculationRulesPricingModeEnum pricingMode;

  /// Minimum value: 0
  /// Maximum value: 3
  int currencyExponent;

  CalculationRulesRoundingEnum rounding;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CalculationRules &&
    other.taxBps == taxBps &&
    other.serviceBps == serviceBps &&
    other.pricingMode == pricingMode &&
    other.currencyExponent == currencyExponent &&
    other.rounding == rounding;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (taxBps.hashCode) +
    (serviceBps.hashCode) +
    (pricingMode.hashCode) +
    (currencyExponent.hashCode) +
    (rounding.hashCode);

  @override
  String toString() => 'CalculationRules[taxBps=$taxBps, serviceBps=$serviceBps, pricingMode=$pricingMode, currencyExponent=$currencyExponent, rounding=$rounding]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'taxBps'] = this.taxBps;
      json[r'serviceBps'] = this.serviceBps;
      json[r'pricingMode'] = this.pricingMode;
      json[r'currencyExponent'] = this.currencyExponent;
      json[r'rounding'] = this.rounding;
    return json;
  }

  /// Returns a new [CalculationRules] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CalculationRules? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'taxBps'), 'Required key "CalculationRules[taxBps]" is missing from JSON.');
        assert(json[r'taxBps'] != null, 'Required key "CalculationRules[taxBps]" has a null value in JSON.');
        assert(json.containsKey(r'serviceBps'), 'Required key "CalculationRules[serviceBps]" is missing from JSON.');
        assert(json[r'serviceBps'] != null, 'Required key "CalculationRules[serviceBps]" has a null value in JSON.');
        assert(json.containsKey(r'pricingMode'), 'Required key "CalculationRules[pricingMode]" is missing from JSON.');
        assert(json[r'pricingMode'] != null, 'Required key "CalculationRules[pricingMode]" has a null value in JSON.');
        assert(json.containsKey(r'currencyExponent'), 'Required key "CalculationRules[currencyExponent]" is missing from JSON.');
        assert(json[r'currencyExponent'] != null, 'Required key "CalculationRules[currencyExponent]" has a null value in JSON.');
        assert(json.containsKey(r'rounding'), 'Required key "CalculationRules[rounding]" is missing from JSON.');
        assert(json[r'rounding'] != null, 'Required key "CalculationRules[rounding]" has a null value in JSON.');
        return true;
      }());

      return CalculationRules(
        taxBps: mapValueOfType<int>(json, r'taxBps')!,
        serviceBps: mapValueOfType<int>(json, r'serviceBps')!,
        pricingMode: CalculationRulesPricingModeEnum.fromJson(json[r'pricingMode'])!,
        currencyExponent: mapValueOfType<int>(json, r'currencyExponent')!,
        rounding: CalculationRulesRoundingEnum.fromJson(json[r'rounding'])!,
      );
    }
    return null;
  }

  static List<CalculationRules> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CalculationRules>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CalculationRules.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CalculationRules> mapFromJson(dynamic json) {
    final map = <String, CalculationRules>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CalculationRules.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CalculationRules-objects as value to a dart map
  static Map<String, List<CalculationRules>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CalculationRules>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CalculationRules.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'taxBps',
    'serviceBps',
    'pricingMode',
    'currencyExponent',
    'rounding',
  };
}


enum CalculationRulesPricingModeEnum {
  EXCLUSIVE._(r'EXCLUSIVE'),
  ;

  /// Instantiate a new enum with the provided value.
  const CalculationRulesPricingModeEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [CalculationRulesPricingModeEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static CalculationRulesPricingModeEnum? fromJson(dynamic value) => CalculationRulesPricingModeEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [CalculationRulesPricingModeEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<CalculationRulesPricingModeEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CalculationRulesPricingModeEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CalculationRulesPricingModeEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [CalculationRulesPricingModeEnum] to String,
/// and [decode] dynamic data back to [CalculationRulesPricingModeEnum].
class CalculationRulesPricingModeEnumTypeTransformer {
  factory CalculationRulesPricingModeEnumTypeTransformer() => _instance ??= const CalculationRulesPricingModeEnumTypeTransformer._();

  const CalculationRulesPricingModeEnumTypeTransformer._();

  String encode(CalculationRulesPricingModeEnum data) => data._value;

  /// Returns the instance of [CalculationRulesPricingModeEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  CalculationRulesPricingModeEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is CalculationRulesPricingModeEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'EXCLUSIVE': return CalculationRulesPricingModeEnum.EXCLUSIVE;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static CalculationRulesPricingModeEnumTypeTransformer? _instance;
}



enum CalculationRulesRoundingEnum {
  HALF_UP._(r'HALF_UP'),
  ;

  /// Instantiate a new enum with the provided value.
  const CalculationRulesRoundingEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [CalculationRulesRoundingEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static CalculationRulesRoundingEnum? fromJson(dynamic value) => CalculationRulesRoundingEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [CalculationRulesRoundingEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<CalculationRulesRoundingEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CalculationRulesRoundingEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CalculationRulesRoundingEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [CalculationRulesRoundingEnum] to String,
/// and [decode] dynamic data back to [CalculationRulesRoundingEnum].
class CalculationRulesRoundingEnumTypeTransformer {
  factory CalculationRulesRoundingEnumTypeTransformer() => _instance ??= const CalculationRulesRoundingEnumTypeTransformer._();

  const CalculationRulesRoundingEnumTypeTransformer._();

  String encode(CalculationRulesRoundingEnum data) => data._value;

  /// Returns the instance of [CalculationRulesRoundingEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  CalculationRulesRoundingEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is CalculationRulesRoundingEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'HALF_UP': return CalculationRulesRoundingEnum.HALF_UP;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static CalculationRulesRoundingEnumTypeTransformer? _instance;
}


