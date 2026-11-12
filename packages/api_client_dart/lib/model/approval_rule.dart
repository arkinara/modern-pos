//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ApprovalRule {
  /// Returns a new [ApprovalRule] instance.
  ApprovalRule({
    required this.id,
    required this.action,
    required this.thresholdMinor,
    required this.active,
  });

  String id;

  ApprovalRuleActionEnum action;

  /// Currency minor units; IDR exponent 0 in demo.
  ///
  /// Minimum value: 0
  /// Maximum value: 9007199254740991
  int thresholdMinor;

  bool active;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ApprovalRule &&
    other.id == id &&
    other.action == action &&
    other.thresholdMinor == thresholdMinor &&
    other.active == active;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (action.hashCode) +
    (thresholdMinor.hashCode) +
    (active.hashCode);

  @override
  String toString() => 'ApprovalRule[id=$id, action=$action, thresholdMinor=$thresholdMinor, active=$active]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'action'] = this.action;
      json[r'thresholdMinor'] = this.thresholdMinor;
      json[r'active'] = this.active;
    return json;
  }

  /// Returns a new [ApprovalRule] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ApprovalRule? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "ApprovalRule[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "ApprovalRule[id]" has a null value in JSON.');
        assert(json.containsKey(r'action'), 'Required key "ApprovalRule[action]" is missing from JSON.');
        assert(json[r'action'] != null, 'Required key "ApprovalRule[action]" has a null value in JSON.');
        assert(json.containsKey(r'thresholdMinor'), 'Required key "ApprovalRule[thresholdMinor]" is missing from JSON.');
        assert(json[r'thresholdMinor'] != null, 'Required key "ApprovalRule[thresholdMinor]" has a null value in JSON.');
        assert(json.containsKey(r'active'), 'Required key "ApprovalRule[active]" is missing from JSON.');
        assert(json[r'active'] != null, 'Required key "ApprovalRule[active]" has a null value in JSON.');
        return true;
      }());

      return ApprovalRule(
        id: mapValueOfType<String>(json, r'id')!,
        action: ApprovalRuleActionEnum.fromJson(json[r'action'])!,
        thresholdMinor: mapValueOfType<int>(json, r'thresholdMinor')!,
        active: mapValueOfType<bool>(json, r'active')!,
      );
    }
    return null;
  }

  static List<ApprovalRule> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ApprovalRule>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ApprovalRule.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ApprovalRule> mapFromJson(dynamic json) {
    final map = <String, ApprovalRule>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ApprovalRule.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ApprovalRule-objects as value to a dart map
  static Map<String, List<ApprovalRule>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ApprovalRule>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ApprovalRule.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'action',
    'thresholdMinor',
    'active',
  };
}


enum ApprovalRuleActionEnum {
  DISCOUNT._(r'DISCOUNT'),
  REFUND._(r'REFUND'),
  CASH_OUT._(r'CASH_OUT'),
  ;

  /// Instantiate a new enum with the provided value.
  const ApprovalRuleActionEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [ApprovalRuleActionEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static ApprovalRuleActionEnum? fromJson(dynamic value) => ApprovalRuleActionEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [ApprovalRuleActionEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<ApprovalRuleActionEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ApprovalRuleActionEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ApprovalRuleActionEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ApprovalRuleActionEnum] to String,
/// and [decode] dynamic data back to [ApprovalRuleActionEnum].
class ApprovalRuleActionEnumTypeTransformer {
  factory ApprovalRuleActionEnumTypeTransformer() => _instance ??= const ApprovalRuleActionEnumTypeTransformer._();

  const ApprovalRuleActionEnumTypeTransformer._();

  String encode(ApprovalRuleActionEnum data) => data._value;

  /// Returns the instance of [ApprovalRuleActionEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ApprovalRuleActionEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is ApprovalRuleActionEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'DISCOUNT': return ApprovalRuleActionEnum.DISCOUNT;
        case r'REFUND': return ApprovalRuleActionEnum.REFUND;
        case r'CASH_OUT': return ApprovalRuleActionEnum.CASH_OUT;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static ApprovalRuleActionEnumTypeTransformer? _instance;
}


