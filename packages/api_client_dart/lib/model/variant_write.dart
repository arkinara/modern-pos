//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class VariantWrite {
  /// Returns a new [VariantWrite] instance.
  VariantWrite({
    required this.name,
    required this.priceMinor,
    required this.stockPolicy,
  });

  String name;

  /// Currency minor units; IDR exponent 0 in demo.
  ///
  /// Minimum value: 0
  /// Maximum value: 9007199254740991
  int priceMinor;

  VariantWriteStockPolicyEnum stockPolicy;

  @override
  bool operator ==(Object other) => identical(this, other) || other is VariantWrite &&
    other.name == name &&
    other.priceMinor == priceMinor &&
    other.stockPolicy == stockPolicy;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (name.hashCode) +
    (priceMinor.hashCode) +
    (stockPolicy.hashCode);

  @override
  String toString() => 'VariantWrite[name=$name, priceMinor=$priceMinor, stockPolicy=$stockPolicy]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'name'] = this.name;
      json[r'priceMinor'] = this.priceMinor;
      json[r'stockPolicy'] = this.stockPolicy;
    return json;
  }

  /// Returns a new [VariantWrite] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static VariantWrite? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'name'), 'Required key "VariantWrite[name]" is missing from JSON.');
        assert(json[r'name'] != null, 'Required key "VariantWrite[name]" has a null value in JSON.');
        assert(json.containsKey(r'priceMinor'), 'Required key "VariantWrite[priceMinor]" is missing from JSON.');
        assert(json[r'priceMinor'] != null, 'Required key "VariantWrite[priceMinor]" has a null value in JSON.');
        assert(json.containsKey(r'stockPolicy'), 'Required key "VariantWrite[stockPolicy]" is missing from JSON.');
        assert(json[r'stockPolicy'] != null, 'Required key "VariantWrite[stockPolicy]" has a null value in JSON.');
        return true;
      }());

      return VariantWrite(
        name: mapValueOfType<String>(json, r'name')!,
        priceMinor: mapValueOfType<int>(json, r'priceMinor')!,
        stockPolicy: VariantWriteStockPolicyEnum.fromJson(json[r'stockPolicy'])!,
      );
    }
    return null;
  }

  static List<VariantWrite> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <VariantWrite>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = VariantWrite.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, VariantWrite> mapFromJson(dynamic json) {
    final map = <String, VariantWrite>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = VariantWrite.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of VariantWrite-objects as value to a dart map
  static Map<String, List<VariantWrite>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<VariantWrite>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = VariantWrite.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'name',
    'priceMinor',
    'stockPolicy',
  };
}


enum VariantWriteStockPolicyEnum {
  TRACKED._(r'TRACKED'),
  UNTRACKED._(r'UNTRACKED'),
  ;

  /// Instantiate a new enum with the provided value.
  const VariantWriteStockPolicyEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [VariantWriteStockPolicyEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static VariantWriteStockPolicyEnum? fromJson(dynamic value) => VariantWriteStockPolicyEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [VariantWriteStockPolicyEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<VariantWriteStockPolicyEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <VariantWriteStockPolicyEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = VariantWriteStockPolicyEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [VariantWriteStockPolicyEnum] to String,
/// and [decode] dynamic data back to [VariantWriteStockPolicyEnum].
class VariantWriteStockPolicyEnumTypeTransformer {
  factory VariantWriteStockPolicyEnumTypeTransformer() => _instance ??= const VariantWriteStockPolicyEnumTypeTransformer._();

  const VariantWriteStockPolicyEnumTypeTransformer._();

  String encode(VariantWriteStockPolicyEnum data) => data._value;

  /// Returns the instance of [VariantWriteStockPolicyEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  VariantWriteStockPolicyEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is VariantWriteStockPolicyEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'TRACKED': return VariantWriteStockPolicyEnum.TRACKED;
        case r'UNTRACKED': return VariantWriteStockPolicyEnum.UNTRACKED;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static VariantWriteStockPolicyEnumTypeTransformer? _instance;
}


