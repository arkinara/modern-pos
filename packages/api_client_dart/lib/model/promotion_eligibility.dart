//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PromotionEligibility {
  /// Returns a new [PromotionEligibility] instance.
  PromotionEligibility({
    this.variantIds = const [],
    this.menuItemIds = const [],
    this.customerEmails = const [],
  });

  List<String> variantIds;

  List<String> menuItemIds;

  List<String> customerEmails;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PromotionEligibility &&
    _deepEquality.equals(other.variantIds, variantIds) &&
    _deepEquality.equals(other.menuItemIds, menuItemIds) &&
    _deepEquality.equals(other.customerEmails, customerEmails);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (variantIds.hashCode) +
    (menuItemIds.hashCode) +
    (customerEmails.hashCode);

  @override
  String toString() => 'PromotionEligibility[variantIds=$variantIds, menuItemIds=$menuItemIds, customerEmails=$customerEmails]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'variantIds'] = this.variantIds;
      json[r'menuItemIds'] = this.menuItemIds;
      json[r'customerEmails'] = this.customerEmails;
    return json;
  }

  /// Returns a new [PromotionEligibility] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PromotionEligibility? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        return true;
      }());

      return PromotionEligibility(
        variantIds: json[r'variantIds'] is Iterable
            ? (json[r'variantIds'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        menuItemIds: json[r'menuItemIds'] is Iterable
            ? (json[r'menuItemIds'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        customerEmails: json[r'customerEmails'] is Iterable
            ? (json[r'customerEmails'] as Iterable).cast<String>().toList(growable: false)
            : const [],
      );
    }
    return null;
  }

  static List<PromotionEligibility> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PromotionEligibility>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PromotionEligibility.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PromotionEligibility> mapFromJson(dynamic json) {
    final map = <String, PromotionEligibility>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PromotionEligibility.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PromotionEligibility-objects as value to a dart map
  static Map<String, List<PromotionEligibility>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PromotionEligibility>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PromotionEligibility.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

