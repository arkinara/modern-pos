//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ProfitReport {
  /// Returns a new [ProfitReport] instance.
  ProfitReport({
    required this.from,
    required this.to,
    required this.timezone,
    required this.currency,
    required this.currencyExponent,
    required this.generatedAt,
    required this.marginAvailable,
    this.unavailableReasons = const [],
    required this.costingMethod,
    required this.revenue,
    required this.cogs,
    required this.waste,
    required this.expenses,
    required this.grossProfitMinor,
    required this.netProfitMinor,
    required this.netMarginBps,
    required this.marginBpsUnavailableReason,
  });

  DateTime from;

  DateTime to;

  String timezone;

  String currency;

  /// Minimum value: 0
  /// Maximum value: 3
  int currencyExponent;

  DateTime generatedAt;

  bool marginAvailable;

  List<ProfitReportUnavailableReasonsEnum> unavailableReasons;

  ProfitReportCostingMethodEnum? costingMethod;

  ProfitReportRevenue revenue;

  ProfitReportCogs? cogs;

  ProfitReportWaste? waste;

  ProfitReportExpenses expenses;

  /// Minimum value: -9007199254740991
  /// Maximum value: 9007199254740991
  int? grossProfitMinor;

  /// Minimum value: -9007199254740991
  /// Maximum value: 9007199254740991
  int? netProfitMinor;

  /// Minimum value: -9007199254740991
  /// Maximum value: 9007199254740991
  int? netMarginBps;

  String? marginBpsUnavailableReason;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ProfitReport &&
    other.from == from &&
    other.to == to &&
    other.timezone == timezone &&
    other.currency == currency &&
    other.currencyExponent == currencyExponent &&
    other.generatedAt == generatedAt &&
    other.marginAvailable == marginAvailable &&
    _deepEquality.equals(other.unavailableReasons, unavailableReasons) &&
    other.costingMethod == costingMethod &&
    other.revenue == revenue &&
    other.cogs == cogs &&
    other.waste == waste &&
    other.expenses == expenses &&
    other.grossProfitMinor == grossProfitMinor &&
    other.netProfitMinor == netProfitMinor &&
    other.netMarginBps == netMarginBps &&
    other.marginBpsUnavailableReason == marginBpsUnavailableReason;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (from.hashCode) +
    (to.hashCode) +
    (timezone.hashCode) +
    (currency.hashCode) +
    (currencyExponent.hashCode) +
    (generatedAt.hashCode) +
    (marginAvailable.hashCode) +
    (unavailableReasons.hashCode) +
    (costingMethod == null ? 0 : costingMethod!.hashCode) +
    (revenue.hashCode) +
    (cogs == null ? 0 : cogs!.hashCode) +
    (waste == null ? 0 : waste!.hashCode) +
    (expenses.hashCode) +
    (grossProfitMinor == null ? 0 : grossProfitMinor!.hashCode) +
    (netProfitMinor == null ? 0 : netProfitMinor!.hashCode) +
    (netMarginBps == null ? 0 : netMarginBps!.hashCode) +
    (marginBpsUnavailableReason == null ? 0 : marginBpsUnavailableReason!.hashCode);

  @override
  String toString() => 'ProfitReport[from=$from, to=$to, timezone=$timezone, currency=$currency, currencyExponent=$currencyExponent, generatedAt=$generatedAt, marginAvailable=$marginAvailable, unavailableReasons=$unavailableReasons, costingMethod=$costingMethod, revenue=$revenue, cogs=$cogs, waste=$waste, expenses=$expenses, grossProfitMinor=$grossProfitMinor, netProfitMinor=$netProfitMinor, netMarginBps=$netMarginBps, marginBpsUnavailableReason=$marginBpsUnavailableReason]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'from'] = _dateFormatter.format(this.from);
      json[r'to'] = _dateFormatter.format(this.to);
      json[r'timezone'] = this.timezone;
      json[r'currency'] = this.currency;
      json[r'currencyExponent'] = this.currencyExponent;
      json[r'generatedAt'] = this.generatedAt.toUtc().toIso8601String();
      json[r'marginAvailable'] = this.marginAvailable;
      json[r'unavailableReasons'] = this.unavailableReasons;
    if (this.costingMethod != null) {
      json[r'costingMethod'] = this.costingMethod;
    } else {
      json[r'costingMethod'] = null;
    }
      json[r'revenue'] = this.revenue;
    if (this.cogs != null) {
      json[r'cogs'] = this.cogs;
    } else {
      json[r'cogs'] = null;
    }
    if (this.waste != null) {
      json[r'waste'] = this.waste;
    } else {
      json[r'waste'] = null;
    }
      json[r'expenses'] = this.expenses;
    if (this.grossProfitMinor != null) {
      json[r'grossProfitMinor'] = this.grossProfitMinor;
    } else {
      json[r'grossProfitMinor'] = null;
    }
    if (this.netProfitMinor != null) {
      json[r'netProfitMinor'] = this.netProfitMinor;
    } else {
      json[r'netProfitMinor'] = null;
    }
    if (this.netMarginBps != null) {
      json[r'netMarginBps'] = this.netMarginBps;
    } else {
      json[r'netMarginBps'] = null;
    }
    if (this.marginBpsUnavailableReason != null) {
      json[r'marginBpsUnavailableReason'] = this.marginBpsUnavailableReason;
    } else {
      json[r'marginBpsUnavailableReason'] = null;
    }
    return json;
  }

  /// Returns a new [ProfitReport] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ProfitReport? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'from'), 'Required key "ProfitReport[from]" is missing from JSON.');
        assert(json[r'from'] != null, 'Required key "ProfitReport[from]" has a null value in JSON.');
        assert(json.containsKey(r'to'), 'Required key "ProfitReport[to]" is missing from JSON.');
        assert(json[r'to'] != null, 'Required key "ProfitReport[to]" has a null value in JSON.');
        assert(json.containsKey(r'timezone'), 'Required key "ProfitReport[timezone]" is missing from JSON.');
        assert(json[r'timezone'] != null, 'Required key "ProfitReport[timezone]" has a null value in JSON.');
        assert(json.containsKey(r'currency'), 'Required key "ProfitReport[currency]" is missing from JSON.');
        assert(json[r'currency'] != null, 'Required key "ProfitReport[currency]" has a null value in JSON.');
        assert(json.containsKey(r'currencyExponent'), 'Required key "ProfitReport[currencyExponent]" is missing from JSON.');
        assert(json[r'currencyExponent'] != null, 'Required key "ProfitReport[currencyExponent]" has a null value in JSON.');
        assert(json.containsKey(r'generatedAt'), 'Required key "ProfitReport[generatedAt]" is missing from JSON.');
        assert(json[r'generatedAt'] != null, 'Required key "ProfitReport[generatedAt]" has a null value in JSON.');
        assert(json.containsKey(r'marginAvailable'), 'Required key "ProfitReport[marginAvailable]" is missing from JSON.');
        assert(json[r'marginAvailable'] != null, 'Required key "ProfitReport[marginAvailable]" has a null value in JSON.');
        assert(json.containsKey(r'unavailableReasons'), 'Required key "ProfitReport[unavailableReasons]" is missing from JSON.');
        assert(json[r'unavailableReasons'] != null, 'Required key "ProfitReport[unavailableReasons]" has a null value in JSON.');
        assert(json.containsKey(r'costingMethod'), 'Required key "ProfitReport[costingMethod]" is missing from JSON.');
        assert(json.containsKey(r'revenue'), 'Required key "ProfitReport[revenue]" is missing from JSON.');
        assert(json[r'revenue'] != null, 'Required key "ProfitReport[revenue]" has a null value in JSON.');
        assert(json.containsKey(r'cogs'), 'Required key "ProfitReport[cogs]" is missing from JSON.');
        assert(json.containsKey(r'waste'), 'Required key "ProfitReport[waste]" is missing from JSON.');
        assert(json.containsKey(r'expenses'), 'Required key "ProfitReport[expenses]" is missing from JSON.');
        assert(json[r'expenses'] != null, 'Required key "ProfitReport[expenses]" has a null value in JSON.');
        assert(json.containsKey(r'grossProfitMinor'), 'Required key "ProfitReport[grossProfitMinor]" is missing from JSON.');
        assert(json.containsKey(r'netProfitMinor'), 'Required key "ProfitReport[netProfitMinor]" is missing from JSON.');
        assert(json.containsKey(r'netMarginBps'), 'Required key "ProfitReport[netMarginBps]" is missing from JSON.');
        assert(json.containsKey(r'marginBpsUnavailableReason'), 'Required key "ProfitReport[marginBpsUnavailableReason]" is missing from JSON.');
        return true;
      }());

      return ProfitReport(
        from: mapDateTime(json, r'from', r'')!,
        to: mapDateTime(json, r'to', r'')!,
        timezone: mapValueOfType<String>(json, r'timezone')!,
        currency: mapValueOfType<String>(json, r'currency')!,
        currencyExponent: mapValueOfType<int>(json, r'currencyExponent')!,
        generatedAt: mapDateTime(json, r'generatedAt', r'')!,
        marginAvailable: mapValueOfType<bool>(json, r'marginAvailable')!,
        unavailableReasons: ProfitReportUnavailableReasonsEnum.listFromJson(json[r'unavailableReasons']),
        costingMethod: ProfitReportCostingMethodEnum.fromJson(json[r'costingMethod']),
        revenue: ProfitReportRevenue.fromJson(json[r'revenue'])!,
        cogs: ProfitReportCogs.fromJson(json[r'cogs']),
        waste: ProfitReportWaste.fromJson(json[r'waste']),
        expenses: ProfitReportExpenses.fromJson(json[r'expenses'])!,
        grossProfitMinor: mapValueOfType<int>(json, r'grossProfitMinor'),
        netProfitMinor: mapValueOfType<int>(json, r'netProfitMinor'),
        netMarginBps: mapValueOfType<int>(json, r'netMarginBps'),
        marginBpsUnavailableReason: mapValueOfType<String>(json, r'marginBpsUnavailableReason'),
      );
    }
    return null;
  }

  static List<ProfitReport> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ProfitReport>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ProfitReport.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ProfitReport> mapFromJson(dynamic json) {
    final map = <String, ProfitReport>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ProfitReport.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ProfitReport-objects as value to a dart map
  static Map<String, List<ProfitReport>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ProfitReport>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ProfitReport.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'from',
    'to',
    'timezone',
    'currency',
    'currencyExponent',
    'generatedAt',
    'marginAvailable',
    'unavailableReasons',
    'costingMethod',
    'revenue',
    'cogs',
    'waste',
    'expenses',
    'grossProfitMinor',
    'netProfitMinor',
    'netMarginBps',
    'marginBpsUnavailableReason',
  };
}


enum ProfitReportUnavailableReasonsEnum {
  COSTING_METHOD_UNDEFINED._(r'COSTING_METHOD_UNDEFINED'),
  EXPENSE_CATEGORIES_UNDEFINED._(r'EXPENSE_CATEGORIES_UNDEFINED'),
  INVENTORY_COST_UNDEFINED._(r'INVENTORY_COST_UNDEFINED'),
  ;

  /// Instantiate a new enum with the provided value.
  const ProfitReportUnavailableReasonsEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [ProfitReportUnavailableReasonsEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static ProfitReportUnavailableReasonsEnum? fromJson(dynamic value) => ProfitReportUnavailableReasonsEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [ProfitReportUnavailableReasonsEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<ProfitReportUnavailableReasonsEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ProfitReportUnavailableReasonsEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ProfitReportUnavailableReasonsEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ProfitReportUnavailableReasonsEnum] to String,
/// and [decode] dynamic data back to [ProfitReportUnavailableReasonsEnum].
class ProfitReportUnavailableReasonsEnumTypeTransformer {
  factory ProfitReportUnavailableReasonsEnumTypeTransformer() => _instance ??= const ProfitReportUnavailableReasonsEnumTypeTransformer._();

  const ProfitReportUnavailableReasonsEnumTypeTransformer._();

  String encode(ProfitReportUnavailableReasonsEnum data) => data._value;

  /// Returns the instance of [ProfitReportUnavailableReasonsEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ProfitReportUnavailableReasonsEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is ProfitReportUnavailableReasonsEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'COSTING_METHOD_UNDEFINED': return ProfitReportUnavailableReasonsEnum.COSTING_METHOD_UNDEFINED;
        case r'EXPENSE_CATEGORIES_UNDEFINED': return ProfitReportUnavailableReasonsEnum.EXPENSE_CATEGORIES_UNDEFINED;
        case r'INVENTORY_COST_UNDEFINED': return ProfitReportUnavailableReasonsEnum.INVENTORY_COST_UNDEFINED;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static ProfitReportUnavailableReasonsEnumTypeTransformer? _instance;
}



enum ProfitReportCostingMethodEnum {
  MOVING_AVERAGE._(r'MOVING_AVERAGE'),
  LAST_PURCHASE._(r'LAST_PURCHASE'),
  ;

  /// Instantiate a new enum with the provided value.
  const ProfitReportCostingMethodEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [ProfitReportCostingMethodEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static ProfitReportCostingMethodEnum? fromJson(dynamic value) => ProfitReportCostingMethodEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [ProfitReportCostingMethodEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<ProfitReportCostingMethodEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ProfitReportCostingMethodEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ProfitReportCostingMethodEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ProfitReportCostingMethodEnum] to String,
/// and [decode] dynamic data back to [ProfitReportCostingMethodEnum].
class ProfitReportCostingMethodEnumTypeTransformer {
  factory ProfitReportCostingMethodEnumTypeTransformer() => _instance ??= const ProfitReportCostingMethodEnumTypeTransformer._();

  const ProfitReportCostingMethodEnumTypeTransformer._();

  String encode(ProfitReportCostingMethodEnum data) => data._value;

  /// Returns the instance of [ProfitReportCostingMethodEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ProfitReportCostingMethodEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is ProfitReportCostingMethodEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'MOVING_AVERAGE': return ProfitReportCostingMethodEnum.MOVING_AVERAGE;
        case r'LAST_PURCHASE': return ProfitReportCostingMethodEnum.LAST_PURCHASE;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static ProfitReportCostingMethodEnumTypeTransformer? _instance;
}


