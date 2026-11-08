//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Variant {
  /// Returns a new [Variant] instance.
  Variant({
    required this.id,
    required this.name,
    required this.priceMinor,
    required this.stockPolicy,
    required this.revision,
    required this.enabled,
    required this.availableUnits,
  });

  String id;

  String name;

  /// Currency minor units; IDR exponent 0 in demo.
  ///
  /// Minimum value: 0
  /// Maximum value: 9007199254740991
  int priceMinor;

  VariantStockPolicyEnum stockPolicy;

  /// Minimum value: 1
  int revision;

  bool enabled;

  /// Null for UNTRACKED variants. For TRACKED variants, advisory minimum floor(balance / quantityPerSaleUnit) across the latest recipe, computed per request; finalization is authoritative.
  ///
  /// Minimum value: 0
  int? availableUnits;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Variant &&
    other.id == id &&
    other.name == name &&
    other.priceMinor == priceMinor &&
    other.stockPolicy == stockPolicy &&
    other.revision == revision &&
    other.enabled == enabled &&
    other.availableUnits == availableUnits;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (name.hashCode) +
    (priceMinor.hashCode) +
    (stockPolicy.hashCode) +
    (revision.hashCode) +
    (enabled.hashCode) +
    (availableUnits == null ? 0 : availableUnits!.hashCode);

  @override
  String toString() => 'Variant[id=$id, name=$name, priceMinor=$priceMinor, stockPolicy=$stockPolicy, revision=$revision, enabled=$enabled, availableUnits=$availableUnits]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'name'] = this.name;
      json[r'priceMinor'] = this.priceMinor;
      json[r'stockPolicy'] = this.stockPolicy;
      json[r'revision'] = this.revision;
      json[r'enabled'] = this.enabled;
    if (this.availableUnits != null) {
      json[r'availableUnits'] = this.availableUnits;
    } else {
      json[r'availableUnits'] = null;
    }
    return json;
  }

  /// Returns a new [Variant] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Variant? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "Variant[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "Variant[id]" has a null value in JSON.');
        assert(json.containsKey(r'name'), 'Required key "Variant[name]" is missing from JSON.');
        assert(json[r'name'] != null, 'Required key "Variant[name]" has a null value in JSON.');
        assert(json.containsKey(r'priceMinor'), 'Required key "Variant[priceMinor]" is missing from JSON.');
        assert(json[r'priceMinor'] != null, 'Required key "Variant[priceMinor]" has a null value in JSON.');
        assert(json.containsKey(r'stockPolicy'), 'Required key "Variant[stockPolicy]" is missing from JSON.');
        assert(json[r'stockPolicy'] != null, 'Required key "Variant[stockPolicy]" has a null value in JSON.');
        assert(json.containsKey(r'revision'), 'Required key "Variant[revision]" is missing from JSON.');
        assert(json[r'revision'] != null, 'Required key "Variant[revision]" has a null value in JSON.');
        assert(json.containsKey(r'enabled'), 'Required key "Variant[enabled]" is missing from JSON.');
        assert(json[r'enabled'] != null, 'Required key "Variant[enabled]" has a null value in JSON.');
        assert(json.containsKey(r'availableUnits'), 'Required key "Variant[availableUnits]" is missing from JSON.');
        return true;
      }());

      return Variant(
        id: mapValueOfType<String>(json, r'id')!,
        name: mapValueOfType<String>(json, r'name')!,
        priceMinor: mapValueOfType<int>(json, r'priceMinor')!,
        stockPolicy: VariantStockPolicyEnum.fromJson(json[r'stockPolicy'])!,
        revision: mapValueOfType<int>(json, r'revision')!,
        enabled: mapValueOfType<bool>(json, r'enabled')!,
        availableUnits: mapValueOfType<int>(json, r'availableUnits'),
      );
    }
    return null;
  }

  static List<Variant> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Variant>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Variant.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Variant> mapFromJson(dynamic json) {
    final map = <String, Variant>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Variant.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Variant-objects as value to a dart map
  static Map<String, List<Variant>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Variant>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Variant.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'name',
    'priceMinor',
    'stockPolicy',
    'revision',
    'enabled',
    'availableUnits',
  };
}


enum VariantStockPolicyEnum {
  TRACKED._(r'TRACKED'),
  UNTRACKED._(r'UNTRACKED'),
  ;

  /// Instantiate a new enum with the provided value.
  const VariantStockPolicyEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [VariantStockPolicyEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static VariantStockPolicyEnum? fromJson(dynamic value) => VariantStockPolicyEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [VariantStockPolicyEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<VariantStockPolicyEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <VariantStockPolicyEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = VariantStockPolicyEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [VariantStockPolicyEnum] to String,
/// and [decode] dynamic data back to [VariantStockPolicyEnum].
class VariantStockPolicyEnumTypeTransformer {
  factory VariantStockPolicyEnumTypeTransformer() => _instance ??= const VariantStockPolicyEnumTypeTransformer._();

  const VariantStockPolicyEnumTypeTransformer._();

  String encode(VariantStockPolicyEnum data) => data._value;

  /// Returns the instance of [VariantStockPolicyEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  VariantStockPolicyEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is VariantStockPolicyEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'TRACKED': return VariantStockPolicyEnum.TRACKED;
        case r'UNTRACKED': return VariantStockPolicyEnum.UNTRACKED;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static VariantStockPolicyEnumTypeTransformer? _instance;
}


