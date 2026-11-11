//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class SplitResult {
  /// Returns a new [SplitResult] instance.
  SplitResult({
    required this.parentOrder,
    this.bills = const [],
  });

  Order parentOrder;

  List<Order> bills;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SplitResult &&
    other.parentOrder == parentOrder &&
    _deepEquality.equals(other.bills, bills);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (parentOrder.hashCode) +
    (bills.hashCode);

  @override
  String toString() => 'SplitResult[parentOrder=$parentOrder, bills=$bills]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'parentOrder'] = this.parentOrder;
      json[r'bills'] = this.bills;
    return json;
  }

  /// Returns a new [SplitResult] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SplitResult? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'parentOrder'), 'Required key "SplitResult[parentOrder]" is missing from JSON.');
        assert(json[r'parentOrder'] != null, 'Required key "SplitResult[parentOrder]" has a null value in JSON.');
        assert(json.containsKey(r'bills'), 'Required key "SplitResult[bills]" is missing from JSON.');
        assert(json[r'bills'] != null, 'Required key "SplitResult[bills]" has a null value in JSON.');
        return true;
      }());

      return SplitResult(
        parentOrder: Order.fromJson(json[r'parentOrder'])!,
        bills: Order.listFromJson(json[r'bills']),
      );
    }
    return null;
  }

  static List<SplitResult> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SplitResult>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SplitResult.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SplitResult> mapFromJson(dynamic json) {
    final map = <String, SplitResult>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SplitResult.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SplitResult-objects as value to a dart map
  static Map<String, List<SplitResult>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SplitResult>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SplitResult.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'parentOrder',
    'bills',
  };
}

