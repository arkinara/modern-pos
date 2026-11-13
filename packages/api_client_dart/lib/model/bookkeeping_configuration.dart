//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class BookkeepingConfiguration {
  /// Returns a new [BookkeepingConfiguration] instance.
  BookkeepingConfiguration({
    required this.outletId,
    required this.costingMethod,
    required this.costingMethodDefined,
    required this.version,
    required this.expenseCategoryCount,
    required this.expenseCategoriesDefined,
    this.expenseCategories = const [],
  });

  String outletId;

  BookkeepingConfigurationCostingMethodEnum? costingMethod;

  bool costingMethodDefined;

  /// Minimum value: 1
  int? version;

  /// Minimum value: 0
  int expenseCategoryCount;

  bool expenseCategoriesDefined;

  List<ExpenseCategory> expenseCategories;

  @override
  bool operator ==(Object other) => identical(this, other) || other is BookkeepingConfiguration &&
    other.outletId == outletId &&
    other.costingMethod == costingMethod &&
    other.costingMethodDefined == costingMethodDefined &&
    other.version == version &&
    other.expenseCategoryCount == expenseCategoryCount &&
    other.expenseCategoriesDefined == expenseCategoriesDefined &&
    _deepEquality.equals(other.expenseCategories, expenseCategories);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (outletId.hashCode) +
    (costingMethod == null ? 0 : costingMethod!.hashCode) +
    (costingMethodDefined.hashCode) +
    (version == null ? 0 : version!.hashCode) +
    (expenseCategoryCount.hashCode) +
    (expenseCategoriesDefined.hashCode) +
    (expenseCategories.hashCode);

  @override
  String toString() => 'BookkeepingConfiguration[outletId=$outletId, costingMethod=$costingMethod, costingMethodDefined=$costingMethodDefined, version=$version, expenseCategoryCount=$expenseCategoryCount, expenseCategoriesDefined=$expenseCategoriesDefined, expenseCategories=$expenseCategories]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'outletId'] = this.outletId;
    if (this.costingMethod != null) {
      json[r'costingMethod'] = this.costingMethod;
    } else {
      json[r'costingMethod'] = null;
    }
      json[r'costingMethodDefined'] = this.costingMethodDefined;
    if (this.version != null) {
      json[r'version'] = this.version;
    } else {
      json[r'version'] = null;
    }
      json[r'expenseCategoryCount'] = this.expenseCategoryCount;
      json[r'expenseCategoriesDefined'] = this.expenseCategoriesDefined;
      json[r'expenseCategories'] = this.expenseCategories;
    return json;
  }

  /// Returns a new [BookkeepingConfiguration] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static BookkeepingConfiguration? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'outletId'), 'Required key "BookkeepingConfiguration[outletId]" is missing from JSON.');
        assert(json[r'outletId'] != null, 'Required key "BookkeepingConfiguration[outletId]" has a null value in JSON.');
        assert(json.containsKey(r'costingMethod'), 'Required key "BookkeepingConfiguration[costingMethod]" is missing from JSON.');
        assert(json.containsKey(r'costingMethodDefined'), 'Required key "BookkeepingConfiguration[costingMethodDefined]" is missing from JSON.');
        assert(json[r'costingMethodDefined'] != null, 'Required key "BookkeepingConfiguration[costingMethodDefined]" has a null value in JSON.');
        assert(json.containsKey(r'version'), 'Required key "BookkeepingConfiguration[version]" is missing from JSON.');
        assert(json.containsKey(r'expenseCategoryCount'), 'Required key "BookkeepingConfiguration[expenseCategoryCount]" is missing from JSON.');
        assert(json[r'expenseCategoryCount'] != null, 'Required key "BookkeepingConfiguration[expenseCategoryCount]" has a null value in JSON.');
        assert(json.containsKey(r'expenseCategoriesDefined'), 'Required key "BookkeepingConfiguration[expenseCategoriesDefined]" is missing from JSON.');
        assert(json[r'expenseCategoriesDefined'] != null, 'Required key "BookkeepingConfiguration[expenseCategoriesDefined]" has a null value in JSON.');
        assert(json.containsKey(r'expenseCategories'), 'Required key "BookkeepingConfiguration[expenseCategories]" is missing from JSON.');
        assert(json[r'expenseCategories'] != null, 'Required key "BookkeepingConfiguration[expenseCategories]" has a null value in JSON.');
        return true;
      }());

      return BookkeepingConfiguration(
        outletId: mapValueOfType<String>(json, r'outletId')!,
        costingMethod: BookkeepingConfigurationCostingMethodEnum.fromJson(json[r'costingMethod']),
        costingMethodDefined: mapValueOfType<bool>(json, r'costingMethodDefined')!,
        version: mapValueOfType<int>(json, r'version'),
        expenseCategoryCount: mapValueOfType<int>(json, r'expenseCategoryCount')!,
        expenseCategoriesDefined: mapValueOfType<bool>(json, r'expenseCategoriesDefined')!,
        expenseCategories: ExpenseCategory.listFromJson(json[r'expenseCategories']),
      );
    }
    return null;
  }

  static List<BookkeepingConfiguration> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <BookkeepingConfiguration>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = BookkeepingConfiguration.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, BookkeepingConfiguration> mapFromJson(dynamic json) {
    final map = <String, BookkeepingConfiguration>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = BookkeepingConfiguration.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of BookkeepingConfiguration-objects as value to a dart map
  static Map<String, List<BookkeepingConfiguration>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<BookkeepingConfiguration>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = BookkeepingConfiguration.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'outletId',
    'costingMethod',
    'costingMethodDefined',
    'version',
    'expenseCategoryCount',
    'expenseCategoriesDefined',
    'expenseCategories',
  };
}


enum BookkeepingConfigurationCostingMethodEnum {
  MOVING_AVERAGE._(r'MOVING_AVERAGE'),
  LAST_PURCHASE._(r'LAST_PURCHASE'),
  ;

  /// Instantiate a new enum with the provided value.
  const BookkeepingConfigurationCostingMethodEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [BookkeepingConfigurationCostingMethodEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static BookkeepingConfigurationCostingMethodEnum? fromJson(dynamic value) => BookkeepingConfigurationCostingMethodEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [BookkeepingConfigurationCostingMethodEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<BookkeepingConfigurationCostingMethodEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <BookkeepingConfigurationCostingMethodEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = BookkeepingConfigurationCostingMethodEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [BookkeepingConfigurationCostingMethodEnum] to String,
/// and [decode] dynamic data back to [BookkeepingConfigurationCostingMethodEnum].
class BookkeepingConfigurationCostingMethodEnumTypeTransformer {
  factory BookkeepingConfigurationCostingMethodEnumTypeTransformer() => _instance ??= const BookkeepingConfigurationCostingMethodEnumTypeTransformer._();

  const BookkeepingConfigurationCostingMethodEnumTypeTransformer._();

  String encode(BookkeepingConfigurationCostingMethodEnum data) => data._value;

  /// Returns the instance of [BookkeepingConfigurationCostingMethodEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  BookkeepingConfigurationCostingMethodEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is BookkeepingConfigurationCostingMethodEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'MOVING_AVERAGE': return BookkeepingConfigurationCostingMethodEnum.MOVING_AVERAGE;
        case r'LAST_PURCHASE': return BookkeepingConfigurationCostingMethodEnum.LAST_PURCHASE;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static BookkeepingConfigurationCostingMethodEnumTypeTransformer? _instance;
}


