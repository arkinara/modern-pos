//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Shift {
  /// Returns a new [Shift] instance.
  Shift({
    required this.id,
    required this.outletId,
    required this.status,
    required this.openedById,
    this.closedById,
    required this.openingFloatMinor,
    required this.cashSalesMinor,
    required this.paidInMinor,
    required this.paidOutMinor,
    required this.expectedCashMinor,
    this.countedCashMinor,
    this.discrepancyMinor,
    this.closeNote,
    required this.version,
    required this.openedAt,
    this.closedAt,
    required this.currency,
    required this.currencyExponent,
  });

  String id;

  String outletId;

  ShiftStatusEnum status;

  String openedById;

  String? closedById;

  /// Currency minor units; IDR exponent 0 in demo.
  ///
  /// Minimum value: 0
  /// Maximum value: 9007199254740991
  int openingFloatMinor;

  /// Currency minor units; IDR exponent 0 in demo.
  ///
  /// Minimum value: 0
  /// Maximum value: 9007199254740991
  int cashSalesMinor;

  /// Currency minor units; IDR exponent 0 in demo.
  ///
  /// Minimum value: 0
  /// Maximum value: 9007199254740991
  int paidInMinor;

  /// Currency minor units; IDR exponent 0 in demo.
  ///
  /// Minimum value: 0
  /// Maximum value: 9007199254740991
  int paidOutMinor;

  /// Currency minor units; IDR exponent 0 in demo.
  ///
  /// Minimum value: 0
  /// Maximum value: 9007199254740991
  int expectedCashMinor;

  /// Currency minor units; IDR exponent 0 in demo.
  ///
  /// Minimum value: 0
  /// Maximum value: 9007199254740991
  int? countedCashMinor;

  /// Counted minus expected; positive is over, negative is short.
  ///
  /// Minimum value: -9007199254740991
  /// Maximum value: 9007199254740991
  int? discrepancyMinor;

  String? closeNote;

  /// Minimum value: 1
  int version;

  DateTime openedAt;

  DateTime? closedAt;

  String currency;

  /// Minimum value: 0
  /// Maximum value: 3
  int currencyExponent;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Shift &&
    other.id == id &&
    other.outletId == outletId &&
    other.status == status &&
    other.openedById == openedById &&
    other.closedById == closedById &&
    other.openingFloatMinor == openingFloatMinor &&
    other.cashSalesMinor == cashSalesMinor &&
    other.paidInMinor == paidInMinor &&
    other.paidOutMinor == paidOutMinor &&
    other.expectedCashMinor == expectedCashMinor &&
    other.countedCashMinor == countedCashMinor &&
    other.discrepancyMinor == discrepancyMinor &&
    other.closeNote == closeNote &&
    other.version == version &&
    other.openedAt == openedAt &&
    other.closedAt == closedAt &&
    other.currency == currency &&
    other.currencyExponent == currencyExponent;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (outletId.hashCode) +
    (status.hashCode) +
    (openedById.hashCode) +
    (closedById == null ? 0 : closedById!.hashCode) +
    (openingFloatMinor.hashCode) +
    (cashSalesMinor.hashCode) +
    (paidInMinor.hashCode) +
    (paidOutMinor.hashCode) +
    (expectedCashMinor.hashCode) +
    (countedCashMinor == null ? 0 : countedCashMinor!.hashCode) +
    (discrepancyMinor == null ? 0 : discrepancyMinor!.hashCode) +
    (closeNote == null ? 0 : closeNote!.hashCode) +
    (version.hashCode) +
    (openedAt.hashCode) +
    (closedAt == null ? 0 : closedAt!.hashCode) +
    (currency.hashCode) +
    (currencyExponent.hashCode);

  @override
  String toString() => 'Shift[id=$id, outletId=$outletId, status=$status, openedById=$openedById, closedById=$closedById, openingFloatMinor=$openingFloatMinor, cashSalesMinor=$cashSalesMinor, paidInMinor=$paidInMinor, paidOutMinor=$paidOutMinor, expectedCashMinor=$expectedCashMinor, countedCashMinor=$countedCashMinor, discrepancyMinor=$discrepancyMinor, closeNote=$closeNote, version=$version, openedAt=$openedAt, closedAt=$closedAt, currency=$currency, currencyExponent=$currencyExponent]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'outletId'] = this.outletId;
      json[r'status'] = this.status;
      json[r'openedById'] = this.openedById;
    if (this.closedById != null) {
      json[r'closedById'] = this.closedById;
    } else {
      json[r'closedById'] = null;
    }
      json[r'openingFloatMinor'] = this.openingFloatMinor;
      json[r'cashSalesMinor'] = this.cashSalesMinor;
      json[r'paidInMinor'] = this.paidInMinor;
      json[r'paidOutMinor'] = this.paidOutMinor;
      json[r'expectedCashMinor'] = this.expectedCashMinor;
    if (this.countedCashMinor != null) {
      json[r'countedCashMinor'] = this.countedCashMinor;
    } else {
      json[r'countedCashMinor'] = null;
    }
    if (this.discrepancyMinor != null) {
      json[r'discrepancyMinor'] = this.discrepancyMinor;
    } else {
      json[r'discrepancyMinor'] = null;
    }
    if (this.closeNote != null) {
      json[r'closeNote'] = this.closeNote;
    } else {
      json[r'closeNote'] = null;
    }
      json[r'version'] = this.version;
      json[r'openedAt'] = this.openedAt.toUtc().toIso8601String();
    if (this.closedAt != null) {
      json[r'closedAt'] = this.closedAt!.toUtc().toIso8601String();
    } else {
      json[r'closedAt'] = null;
    }
      json[r'currency'] = this.currency;
      json[r'currencyExponent'] = this.currencyExponent;
    return json;
  }

  /// Returns a new [Shift] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Shift? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "Shift[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "Shift[id]" has a null value in JSON.');
        assert(json.containsKey(r'outletId'), 'Required key "Shift[outletId]" is missing from JSON.');
        assert(json[r'outletId'] != null, 'Required key "Shift[outletId]" has a null value in JSON.');
        assert(json.containsKey(r'status'), 'Required key "Shift[status]" is missing from JSON.');
        assert(json[r'status'] != null, 'Required key "Shift[status]" has a null value in JSON.');
        assert(json.containsKey(r'openedById'), 'Required key "Shift[openedById]" is missing from JSON.');
        assert(json[r'openedById'] != null, 'Required key "Shift[openedById]" has a null value in JSON.');
        assert(json.containsKey(r'openingFloatMinor'), 'Required key "Shift[openingFloatMinor]" is missing from JSON.');
        assert(json[r'openingFloatMinor'] != null, 'Required key "Shift[openingFloatMinor]" has a null value in JSON.');
        assert(json.containsKey(r'cashSalesMinor'), 'Required key "Shift[cashSalesMinor]" is missing from JSON.');
        assert(json[r'cashSalesMinor'] != null, 'Required key "Shift[cashSalesMinor]" has a null value in JSON.');
        assert(json.containsKey(r'paidInMinor'), 'Required key "Shift[paidInMinor]" is missing from JSON.');
        assert(json[r'paidInMinor'] != null, 'Required key "Shift[paidInMinor]" has a null value in JSON.');
        assert(json.containsKey(r'paidOutMinor'), 'Required key "Shift[paidOutMinor]" is missing from JSON.');
        assert(json[r'paidOutMinor'] != null, 'Required key "Shift[paidOutMinor]" has a null value in JSON.');
        assert(json.containsKey(r'expectedCashMinor'), 'Required key "Shift[expectedCashMinor]" is missing from JSON.');
        assert(json[r'expectedCashMinor'] != null, 'Required key "Shift[expectedCashMinor]" has a null value in JSON.');
        assert(json.containsKey(r'version'), 'Required key "Shift[version]" is missing from JSON.');
        assert(json[r'version'] != null, 'Required key "Shift[version]" has a null value in JSON.');
        assert(json.containsKey(r'openedAt'), 'Required key "Shift[openedAt]" is missing from JSON.');
        assert(json[r'openedAt'] != null, 'Required key "Shift[openedAt]" has a null value in JSON.');
        assert(json.containsKey(r'currency'), 'Required key "Shift[currency]" is missing from JSON.');
        assert(json[r'currency'] != null, 'Required key "Shift[currency]" has a null value in JSON.');
        assert(json.containsKey(r'currencyExponent'), 'Required key "Shift[currencyExponent]" is missing from JSON.');
        assert(json[r'currencyExponent'] != null, 'Required key "Shift[currencyExponent]" has a null value in JSON.');
        return true;
      }());

      return Shift(
        id: mapValueOfType<String>(json, r'id')!,
        outletId: mapValueOfType<String>(json, r'outletId')!,
        status: ShiftStatusEnum.fromJson(json[r'status'])!,
        openedById: mapValueOfType<String>(json, r'openedById')!,
        closedById: mapValueOfType<String>(json, r'closedById'),
        openingFloatMinor: mapValueOfType<int>(json, r'openingFloatMinor')!,
        cashSalesMinor: mapValueOfType<int>(json, r'cashSalesMinor')!,
        paidInMinor: mapValueOfType<int>(json, r'paidInMinor')!,
        paidOutMinor: mapValueOfType<int>(json, r'paidOutMinor')!,
        expectedCashMinor: mapValueOfType<int>(json, r'expectedCashMinor')!,
        countedCashMinor: mapValueOfType<int>(json, r'countedCashMinor'),
        discrepancyMinor: mapValueOfType<int>(json, r'discrepancyMinor'),
        closeNote: mapValueOfType<String>(json, r'closeNote'),
        version: mapValueOfType<int>(json, r'version')!,
        openedAt: mapDateTime(json, r'openedAt', r'')!,
        closedAt: mapDateTime(json, r'closedAt', r''),
        currency: mapValueOfType<String>(json, r'currency')!,
        currencyExponent: mapValueOfType<int>(json, r'currencyExponent')!,
      );
    }
    return null;
  }

  static List<Shift> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Shift>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Shift.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Shift> mapFromJson(dynamic json) {
    final map = <String, Shift>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Shift.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Shift-objects as value to a dart map
  static Map<String, List<Shift>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Shift>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Shift.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'outletId',
    'status',
    'openedById',
    'openingFloatMinor',
    'cashSalesMinor',
    'paidInMinor',
    'paidOutMinor',
    'expectedCashMinor',
    'version',
    'openedAt',
    'currency',
    'currencyExponent',
  };
}


enum ShiftStatusEnum {
  OPEN._(r'OPEN'),
  CLOSED._(r'CLOSED'),
  ;

  /// Instantiate a new enum with the provided value.
  const ShiftStatusEnum._(this._value);

  /// The underlying value of this enum member.
  final String _value;

  @override
  String toString() => _value;

  /// Encodes this enum as a value suitable for JSON.
  String toJson() => _value;

  /// Returns the instance of [ShiftStatusEnum] that was successfully decoded
  /// from the passed [value] on success, null otherwise.
  static ShiftStatusEnum? fromJson(dynamic value) => ShiftStatusEnumTypeTransformer().decode(value);

  /// Returns a [List] containing instances of [ShiftStatusEnum]
  /// that were successfully decoded from the passed [JSON][json].
  static List<ShiftStatusEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ShiftStatusEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ShiftStatusEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ShiftStatusEnum] to String,
/// and [decode] dynamic data back to [ShiftStatusEnum].
class ShiftStatusEnumTypeTransformer {
  factory ShiftStatusEnumTypeTransformer() => _instance ??= const ShiftStatusEnumTypeTransformer._();

  const ShiftStatusEnumTypeTransformer._();

  String encode(ShiftStatusEnum data) => data._value;

  /// Returns the instance of [ShiftStatusEnum] that was successfully decoded
  /// from the passed [data] value on success, null otherwise.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ShiftStatusEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data is ShiftStatusEnum) {
      return data;
    }
    if (data != null) {
      switch (data) {
        case r'OPEN': return ShiftStatusEnum.OPEN;
        case r'CLOSED': return ShiftStatusEnum.CLOSED;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// The singleton instance of this transformer.
  static ShiftStatusEnumTypeTransformer? _instance;
}


