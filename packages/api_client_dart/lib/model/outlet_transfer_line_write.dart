//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class OutletTransferLineWrite {
  /// Returns a new [OutletTransferLineWrite] instance.
  OutletTransferLineWrite({
    required this.stockItemId,
    required this.quantity,
  });

  String stockItemId;

  /// Nonnegative fixed-point quantity. Business validation rejects zero where a positive quantity is required.
  String quantity;

  @override
  bool operator ==(Object other) => identical(this, other) || other is OutletTransferLineWrite &&
    other.stockItemId == stockItemId &&
    other.quantity == quantity;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (stockItemId.hashCode) +
    (quantity.hashCode);

  @override
  String toString() => 'OutletTransferLineWrite[stockItemId=$stockItemId, quantity=$quantity]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'stockItemId'] = this.stockItemId;
      json[r'quantity'] = this.quantity;
    return json;
  }

  /// Returns a new [OutletTransferLineWrite] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static OutletTransferLineWrite? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'stockItemId'), 'Required key "OutletTransferLineWrite[stockItemId]" is missing from JSON.');
        assert(json[r'stockItemId'] != null, 'Required key "OutletTransferLineWrite[stockItemId]" has a null value in JSON.');
        assert(json.containsKey(r'quantity'), 'Required key "OutletTransferLineWrite[quantity]" is missing from JSON.');
        assert(json[r'quantity'] != null, 'Required key "OutletTransferLineWrite[quantity]" has a null value in JSON.');
        return true;
      }());

      return OutletTransferLineWrite(
        stockItemId: mapValueOfType<String>(json, r'stockItemId')!,
        quantity: mapValueOfType<String>(json, r'quantity')!,
      );
    }
    return null;
  }

  static List<OutletTransferLineWrite> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <OutletTransferLineWrite>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = OutletTransferLineWrite.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, OutletTransferLineWrite> mapFromJson(dynamic json) {
    final map = <String, OutletTransferLineWrite>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = OutletTransferLineWrite.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of OutletTransferLineWrite-objects as value to a dart map
  static Map<String, List<OutletTransferLineWrite>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<OutletTransferLineWrite>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = OutletTransferLineWrite.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'stockItemId',
    'quantity',
  };
}

