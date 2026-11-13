//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ConsolidatedOutlet {
  /// Returns a new [ConsolidatedOutlet] instance.
  ConsolidatedOutlet({
    required this.outletId,
    required this.outletName,
    required this.timezone,
    required this.currency,
    required this.currencyExponent,
    required this.grossItemSalesMinor,
    required this.reversalItemValueMinor,
    required this.netItemSalesMinor,
    required this.refundMoneyMinor,
    required this.saleCount,
    required this.reversalCount,
    required this.averageBillMinor,
    this.paymentBreakdown = const [],
    required this.stockValueMinor,
    required this.stockValueUnavailableReason,
    required this.shiftsOpened,
    required this.shiftsClosed,
    required this.attendanceClockIns,
  });

  String outletId;

  String outletName;

  String timezone;

  String currency;

  /// Minimum value: 0
  /// Maximum value: 3
  int currencyExponent;

  /// Minimum value: 0
  int grossItemSalesMinor;

  /// Minimum value: 0
  int reversalItemValueMinor;

  int netItemSalesMinor;

  /// Minimum value: 0
  int refundMoneyMinor;

  /// Minimum value: 0
  int saleCount;

  /// Minimum value: 0
  int reversalCount;

  /// Minimum value: 0
  int averageBillMinor;

  List<PaymentBreakdownEntry> paymentBreakdown;

  /// Minimum value: 0
  int? stockValueMinor;

  String? stockValueUnavailableReason;

  /// Minimum value: 0
  int shiftsOpened;

  /// Minimum value: 0
  int shiftsClosed;

  /// Minimum value: 0
  int attendanceClockIns;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ConsolidatedOutlet &&
    other.outletId == outletId &&
    other.outletName == outletName &&
    other.timezone == timezone &&
    other.currency == currency &&
    other.currencyExponent == currencyExponent &&
    other.grossItemSalesMinor == grossItemSalesMinor &&
    other.reversalItemValueMinor == reversalItemValueMinor &&
    other.netItemSalesMinor == netItemSalesMinor &&
    other.refundMoneyMinor == refundMoneyMinor &&
    other.saleCount == saleCount &&
    other.reversalCount == reversalCount &&
    other.averageBillMinor == averageBillMinor &&
    _deepEquality.equals(other.paymentBreakdown, paymentBreakdown) &&
    other.stockValueMinor == stockValueMinor &&
    other.stockValueUnavailableReason == stockValueUnavailableReason &&
    other.shiftsOpened == shiftsOpened &&
    other.shiftsClosed == shiftsClosed &&
    other.attendanceClockIns == attendanceClockIns;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (outletId.hashCode) +
    (outletName.hashCode) +
    (timezone.hashCode) +
    (currency.hashCode) +
    (currencyExponent.hashCode) +
    (grossItemSalesMinor.hashCode) +
    (reversalItemValueMinor.hashCode) +
    (netItemSalesMinor.hashCode) +
    (refundMoneyMinor.hashCode) +
    (saleCount.hashCode) +
    (reversalCount.hashCode) +
    (averageBillMinor.hashCode) +
    (paymentBreakdown.hashCode) +
    (stockValueMinor == null ? 0 : stockValueMinor!.hashCode) +
    (stockValueUnavailableReason == null ? 0 : stockValueUnavailableReason!.hashCode) +
    (shiftsOpened.hashCode) +
    (shiftsClosed.hashCode) +
    (attendanceClockIns.hashCode);

  @override
  String toString() => 'ConsolidatedOutlet[outletId=$outletId, outletName=$outletName, timezone=$timezone, currency=$currency, currencyExponent=$currencyExponent, grossItemSalesMinor=$grossItemSalesMinor, reversalItemValueMinor=$reversalItemValueMinor, netItemSalesMinor=$netItemSalesMinor, refundMoneyMinor=$refundMoneyMinor, saleCount=$saleCount, reversalCount=$reversalCount, averageBillMinor=$averageBillMinor, paymentBreakdown=$paymentBreakdown, stockValueMinor=$stockValueMinor, stockValueUnavailableReason=$stockValueUnavailableReason, shiftsOpened=$shiftsOpened, shiftsClosed=$shiftsClosed, attendanceClockIns=$attendanceClockIns]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'outletId'] = this.outletId;
      json[r'outletName'] = this.outletName;
      json[r'timezone'] = this.timezone;
      json[r'currency'] = this.currency;
      json[r'currencyExponent'] = this.currencyExponent;
      json[r'grossItemSalesMinor'] = this.grossItemSalesMinor;
      json[r'reversalItemValueMinor'] = this.reversalItemValueMinor;
      json[r'netItemSalesMinor'] = this.netItemSalesMinor;
      json[r'refundMoneyMinor'] = this.refundMoneyMinor;
      json[r'saleCount'] = this.saleCount;
      json[r'reversalCount'] = this.reversalCount;
      json[r'averageBillMinor'] = this.averageBillMinor;
      json[r'paymentBreakdown'] = this.paymentBreakdown;
    if (this.stockValueMinor != null) {
      json[r'stockValueMinor'] = this.stockValueMinor;
    } else {
      json[r'stockValueMinor'] = null;
    }
    if (this.stockValueUnavailableReason != null) {
      json[r'stockValueUnavailableReason'] = this.stockValueUnavailableReason;
    } else {
      json[r'stockValueUnavailableReason'] = null;
    }
      json[r'shiftsOpened'] = this.shiftsOpened;
      json[r'shiftsClosed'] = this.shiftsClosed;
      json[r'attendanceClockIns'] = this.attendanceClockIns;
    return json;
  }

  /// Returns a new [ConsolidatedOutlet] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ConsolidatedOutlet? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'outletId'), 'Required key "ConsolidatedOutlet[outletId]" is missing from JSON.');
        assert(json[r'outletId'] != null, 'Required key "ConsolidatedOutlet[outletId]" has a null value in JSON.');
        assert(json.containsKey(r'outletName'), 'Required key "ConsolidatedOutlet[outletName]" is missing from JSON.');
        assert(json[r'outletName'] != null, 'Required key "ConsolidatedOutlet[outletName]" has a null value in JSON.');
        assert(json.containsKey(r'timezone'), 'Required key "ConsolidatedOutlet[timezone]" is missing from JSON.');
        assert(json[r'timezone'] != null, 'Required key "ConsolidatedOutlet[timezone]" has a null value in JSON.');
        assert(json.containsKey(r'currency'), 'Required key "ConsolidatedOutlet[currency]" is missing from JSON.');
        assert(json[r'currency'] != null, 'Required key "ConsolidatedOutlet[currency]" has a null value in JSON.');
        assert(json.containsKey(r'currencyExponent'), 'Required key "ConsolidatedOutlet[currencyExponent]" is missing from JSON.');
        assert(json[r'currencyExponent'] != null, 'Required key "ConsolidatedOutlet[currencyExponent]" has a null value in JSON.');
        assert(json.containsKey(r'grossItemSalesMinor'), 'Required key "ConsolidatedOutlet[grossItemSalesMinor]" is missing from JSON.');
        assert(json[r'grossItemSalesMinor'] != null, 'Required key "ConsolidatedOutlet[grossItemSalesMinor]" has a null value in JSON.');
        assert(json.containsKey(r'reversalItemValueMinor'), 'Required key "ConsolidatedOutlet[reversalItemValueMinor]" is missing from JSON.');
        assert(json[r'reversalItemValueMinor'] != null, 'Required key "ConsolidatedOutlet[reversalItemValueMinor]" has a null value in JSON.');
        assert(json.containsKey(r'netItemSalesMinor'), 'Required key "ConsolidatedOutlet[netItemSalesMinor]" is missing from JSON.');
        assert(json[r'netItemSalesMinor'] != null, 'Required key "ConsolidatedOutlet[netItemSalesMinor]" has a null value in JSON.');
        assert(json.containsKey(r'refundMoneyMinor'), 'Required key "ConsolidatedOutlet[refundMoneyMinor]" is missing from JSON.');
        assert(json[r'refundMoneyMinor'] != null, 'Required key "ConsolidatedOutlet[refundMoneyMinor]" has a null value in JSON.');
        assert(json.containsKey(r'saleCount'), 'Required key "ConsolidatedOutlet[saleCount]" is missing from JSON.');
        assert(json[r'saleCount'] != null, 'Required key "ConsolidatedOutlet[saleCount]" has a null value in JSON.');
        assert(json.containsKey(r'reversalCount'), 'Required key "ConsolidatedOutlet[reversalCount]" is missing from JSON.');
        assert(json[r'reversalCount'] != null, 'Required key "ConsolidatedOutlet[reversalCount]" has a null value in JSON.');
        assert(json.containsKey(r'averageBillMinor'), 'Required key "ConsolidatedOutlet[averageBillMinor]" is missing from JSON.');
        assert(json[r'averageBillMinor'] != null, 'Required key "ConsolidatedOutlet[averageBillMinor]" has a null value in JSON.');
        assert(json.containsKey(r'paymentBreakdown'), 'Required key "ConsolidatedOutlet[paymentBreakdown]" is missing from JSON.');
        assert(json[r'paymentBreakdown'] != null, 'Required key "ConsolidatedOutlet[paymentBreakdown]" has a null value in JSON.');
        assert(json.containsKey(r'stockValueMinor'), 'Required key "ConsolidatedOutlet[stockValueMinor]" is missing from JSON.');
        assert(json.containsKey(r'stockValueUnavailableReason'), 'Required key "ConsolidatedOutlet[stockValueUnavailableReason]" is missing from JSON.');
        assert(json.containsKey(r'shiftsOpened'), 'Required key "ConsolidatedOutlet[shiftsOpened]" is missing from JSON.');
        assert(json[r'shiftsOpened'] != null, 'Required key "ConsolidatedOutlet[shiftsOpened]" has a null value in JSON.');
        assert(json.containsKey(r'shiftsClosed'), 'Required key "ConsolidatedOutlet[shiftsClosed]" is missing from JSON.');
        assert(json[r'shiftsClosed'] != null, 'Required key "ConsolidatedOutlet[shiftsClosed]" has a null value in JSON.');
        assert(json.containsKey(r'attendanceClockIns'), 'Required key "ConsolidatedOutlet[attendanceClockIns]" is missing from JSON.');
        assert(json[r'attendanceClockIns'] != null, 'Required key "ConsolidatedOutlet[attendanceClockIns]" has a null value in JSON.');
        return true;
      }());

      return ConsolidatedOutlet(
        outletId: mapValueOfType<String>(json, r'outletId')!,
        outletName: mapValueOfType<String>(json, r'outletName')!,
        timezone: mapValueOfType<String>(json, r'timezone')!,
        currency: mapValueOfType<String>(json, r'currency')!,
        currencyExponent: mapValueOfType<int>(json, r'currencyExponent')!,
        grossItemSalesMinor: mapValueOfType<int>(json, r'grossItemSalesMinor')!,
        reversalItemValueMinor: mapValueOfType<int>(json, r'reversalItemValueMinor')!,
        netItemSalesMinor: mapValueOfType<int>(json, r'netItemSalesMinor')!,
        refundMoneyMinor: mapValueOfType<int>(json, r'refundMoneyMinor')!,
        saleCount: mapValueOfType<int>(json, r'saleCount')!,
        reversalCount: mapValueOfType<int>(json, r'reversalCount')!,
        averageBillMinor: mapValueOfType<int>(json, r'averageBillMinor')!,
        paymentBreakdown: PaymentBreakdownEntry.listFromJson(json[r'paymentBreakdown']),
        stockValueMinor: mapValueOfType<int>(json, r'stockValueMinor'),
        stockValueUnavailableReason: mapValueOfType<String>(json, r'stockValueUnavailableReason'),
        shiftsOpened: mapValueOfType<int>(json, r'shiftsOpened')!,
        shiftsClosed: mapValueOfType<int>(json, r'shiftsClosed')!,
        attendanceClockIns: mapValueOfType<int>(json, r'attendanceClockIns')!,
      );
    }
    return null;
  }

  static List<ConsolidatedOutlet> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ConsolidatedOutlet>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ConsolidatedOutlet.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ConsolidatedOutlet> mapFromJson(dynamic json) {
    final map = <String, ConsolidatedOutlet>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ConsolidatedOutlet.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ConsolidatedOutlet-objects as value to a dart map
  static Map<String, List<ConsolidatedOutlet>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ConsolidatedOutlet>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ConsolidatedOutlet.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'outletId',
    'outletName',
    'timezone',
    'currency',
    'currencyExponent',
    'grossItemSalesMinor',
    'reversalItemValueMinor',
    'netItemSalesMinor',
    'refundMoneyMinor',
    'saleCount',
    'reversalCount',
    'averageBillMinor',
    'paymentBreakdown',
    'stockValueMinor',
    'stockValueUnavailableReason',
    'shiftsOpened',
    'shiftsClosed',
    'attendanceClockIns',
  };
}

