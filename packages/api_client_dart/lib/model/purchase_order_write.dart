//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PurchaseOrderWrite {
  /// Returns a new [PurchaseOrderWrite] instance.
  PurchaseOrderWrite({
    required this.supplierId,
    this.reference,
    this.lines = const [],
  });

  String supplierId;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? reference;

  List<PurchaseOrderLineWrite> lines;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PurchaseOrderWrite &&
    other.supplierId == supplierId &&
    other.reference == reference &&
    _deepEquality.equals(other.lines, lines);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (supplierId.hashCode) +
    (reference == null ? 0 : reference!.hashCode) +
    (lines.hashCode);

  @override
  String toString() => 'PurchaseOrderWrite[supplierId=$supplierId, reference=$reference, lines=$lines]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'supplierId'] = this.supplierId;
    if (this.reference != null) {
      json[r'reference'] = this.reference;
    } else {
      json[r'reference'] = null;
    }
      json[r'lines'] = this.lines;
    return json;
  }

  /// Returns a new [PurchaseOrderWrite] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PurchaseOrderWrite? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'supplierId'), 'Required key "PurchaseOrderWrite[supplierId]" is missing from JSON.');
        assert(json[r'supplierId'] != null, 'Required key "PurchaseOrderWrite[supplierId]" has a null value in JSON.');
        assert(json.containsKey(r'lines'), 'Required key "PurchaseOrderWrite[lines]" is missing from JSON.');
        assert(json[r'lines'] != null, 'Required key "PurchaseOrderWrite[lines]" has a null value in JSON.');
        return true;
      }());

      return PurchaseOrderWrite(
        supplierId: mapValueOfType<String>(json, r'supplierId')!,
        reference: mapValueOfType<String>(json, r'reference'),
        lines: PurchaseOrderLineWrite.listFromJson(json[r'lines']),
      );
    }
    return null;
  }

  static List<PurchaseOrderWrite> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PurchaseOrderWrite>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PurchaseOrderWrite.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PurchaseOrderWrite> mapFromJson(dynamic json) {
    final map = <String, PurchaseOrderWrite>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PurchaseOrderWrite.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PurchaseOrderWrite-objects as value to a dart map
  static Map<String, List<PurchaseOrderWrite>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PurchaseOrderWrite>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PurchaseOrderWrite.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'supplierId',
    'lines',
  };
}

