//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PurchaseOrderReceipt {
  /// Returns a new [PurchaseOrderReceipt] instance.
  PurchaseOrderReceipt({
    required this.purchaseOrder,
    required this.line,
    required this.movement,
  });

  PurchaseOrder purchaseOrder;

  PurchaseOrderLine line;

  Movement movement;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PurchaseOrderReceipt &&
    other.purchaseOrder == purchaseOrder &&
    other.line == line &&
    other.movement == movement;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (purchaseOrder.hashCode) +
    (line.hashCode) +
    (movement.hashCode);

  @override
  String toString() => 'PurchaseOrderReceipt[purchaseOrder=$purchaseOrder, line=$line, movement=$movement]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'purchaseOrder'] = this.purchaseOrder;
      json[r'line'] = this.line;
      json[r'movement'] = this.movement;
    return json;
  }

  /// Returns a new [PurchaseOrderReceipt] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PurchaseOrderReceipt? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'purchaseOrder'), 'Required key "PurchaseOrderReceipt[purchaseOrder]" is missing from JSON.');
        assert(json[r'purchaseOrder'] != null, 'Required key "PurchaseOrderReceipt[purchaseOrder]" has a null value in JSON.');
        assert(json.containsKey(r'line'), 'Required key "PurchaseOrderReceipt[line]" is missing from JSON.');
        assert(json[r'line'] != null, 'Required key "PurchaseOrderReceipt[line]" has a null value in JSON.');
        assert(json.containsKey(r'movement'), 'Required key "PurchaseOrderReceipt[movement]" is missing from JSON.');
        assert(json[r'movement'] != null, 'Required key "PurchaseOrderReceipt[movement]" has a null value in JSON.');
        return true;
      }());

      return PurchaseOrderReceipt(
        purchaseOrder: PurchaseOrder.fromJson(json[r'purchaseOrder'])!,
        line: PurchaseOrderLine.fromJson(json[r'line'])!,
        movement: Movement.fromJson(json[r'movement'])!,
      );
    }
    return null;
  }

  static List<PurchaseOrderReceipt> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PurchaseOrderReceipt>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PurchaseOrderReceipt.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PurchaseOrderReceipt> mapFromJson(dynamic json) {
    final map = <String, PurchaseOrderReceipt>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PurchaseOrderReceipt.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PurchaseOrderReceipt-objects as value to a dart map
  static Map<String, List<PurchaseOrderReceipt>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PurchaseOrderReceipt>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PurchaseOrderReceipt.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'purchaseOrder',
    'line',
    'movement',
  };
}

