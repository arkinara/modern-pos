//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class VariantUpdate {
  /// Returns a new [VariantUpdate] instance.
  VariantUpdate({
    required this.name,
    required this.priceMinor,
    required this.stockPolicy,
    required this.enabled,
    required this.revision,
  });

  String name;

  /// Currency minor units; IDR exponent 0 in demo.
  ///
  /// Minimum value: 0
  /// Maximum value: 9007199254740991
  int priceMinor;

  VariantUpdateStockPolicyEnum stockPolicy;

  bool enabled;

  /// Minimum value: 1
  int revision;

  @override
  bool operator ==(Object other) => identical(this, other) || other is VariantUpdate &&
    other.name == name &&
    other.priceMinor == priceMinor &&
    other.stockPolicy == stockPolicy &&
    other.enabled == enabled &&
    other.revision == revision;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (name.hashCode) +
    (priceMinor.hashCode) +
    (stockPolicy.hashCode) +
    (enabled.hashCode) +
    (revision.hashCode);

  @override
  String toString() => 'VariantUpdate[name=$name, priceMinor=$priceMinor, stockPolicy=$stockPolicy, enabled=$enabled, revision=$revision]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'name'] = this.name;
      json[r'priceMinor'] = this.priceMinor;
      json[r'stockPolicy'] = this.stockPolicy;
      json[r'enabled'] = this.enabled;
      json[r'revision'] = this.revision;
    return json;
  }

  /// Returns a new [VariantUpdate] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static VariantUpdate? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'name'), 'Required key "VariantUpdate[name]" is missing from JSON.');
        assert(json[r'name'] != null, 'Required key "VariantUpdate[name]" has a null value in JSON.');
        assert(json.containsKey(r'priceMinor'), 'Required key "VariantUpdate[priceMinor]" is missing from JSON.');
        assert(json[r'priceMinor'] != null, 'Required key "VariantUpdate[priceMinor]" has a null value in JSON.');
        assert(json.containsKey(r'stockPolicy'), 'Required key "VariantUpdate[stockPolicy]" is missing from JSON.');
        assert(json[r'stockPolicy'] != null, 'Required key "VariantUpdate[stockPolicy]" has a null value in JSON.');
        assert(json.containsKey(r'enabled'), 'Required key "VariantUpdate[enabled]" is missing from JSON.');
        assert(json[r'enabled'] != null, 'Required key "VariantUpdate[enabled]" has a null value in JSON.');
        assert(json.containsKey(r'revision'), 'Required key "VariantUpdate[revision]" is missing from JSON.');
        assert(json[r'revision'] != null, 'Required key "VariantUpdate[revision]" has a null value in JSON.');
        return true;
      }());

      return VariantUpdate(
        name: mapValueOfType<String>(json, r'name')!,
        priceMinor: mapValueOfType<int>(json, r'priceMinor')!,
        stockPolicy: VariantUpdateStockPolicyEnum.fromJson(json[r'stockPolicy'])!,
        enabled: mapValueOfType<bool>(json, r'enabled')!,
        revision: mapValueOfType<int>(json, r'revision')!,
      );
    }
    return null;
  }

  static List<VariantUpdate> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <VariantUpdate>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = VariantUpdate.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, VariantUpdate> mapFromJson(dynamic json) {
    final map = <String, VariantUpdate>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = VariantUpdate.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of VariantUpdate-objects as value to a dart map
  static Map<String, List<VariantUpdate>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<VariantUpdate>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = VariantUpdate.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'name',
    'priceMinor',
    'stockPolicy',
    'enabled',
    'revision',
  };
}


enum VariantUpdateStockPolicyEnum {
  TRACKED._(r'TRACKED'),
  UNTRACKED._(r'UNTRACKED'),
  ;

  /// Instantiate a new enum with the provided value.
  const VariantUpdateStockPolicyEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [VariantUpdateStockPolicyEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static VariantUpdateStockPolicyEnum? fromJson(dynamic value) => VariantUpdateStockPolicyEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [VariantUpdateStockPolicyEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<VariantUpdateStockPolicyEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <VariantUpdateStockPolicyEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = VariantUpdateStockPolicyEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [VariantUpdateStockPolicyEnum] to String,
/// and [decode] dynamic data back to [VariantUpdateStockPolicyEnum].
class VariantUpdateStockPolicyEnumTypeTransformer {
  factory VariantUpdateStockPolicyEnumTypeTransformer() => _instance ??= const VariantUpdateStockPolicyEnumTypeTransformer._();

  const VariantUpdateStockPolicyEnumTypeTransformer._();

  String encode(VariantUpdateStockPolicyEnum data) => data._value;

  /// Returns the instance of [VariantUpdateStockPolicyEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  VariantUpdateStockPolicyEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is VariantUpdateStockPolicyEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'TRACKED': return VariantUpdateStockPolicyEnum.TRACKED;
        case r'UNTRACKED': return VariantUpdateStockPolicyEnum.UNTRACKED;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static VariantUpdateStockPolicyEnumTypeTransformer? _instance;
}


