//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class SupplierWrite {
  /// Returns a new [SupplierWrite] instance.
  SupplierWrite({
    required this.name,
    this.reference,
    this.contact,
  });

  String name;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? reference;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? contact;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SupplierWrite &&
    other.name == name &&
    other.reference == reference &&
    other.contact == contact;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (name.hashCode) +
    (reference == null ? 0 : reference!.hashCode) +
    (contact == null ? 0 : contact!.hashCode);

  @override
  String toString() => 'SupplierWrite[name=$name, reference=$reference, contact=$contact]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'name'] = this.name;
    if (this.reference != null) {
      json[r'reference'] = this.reference;
    } else {
      json[r'reference'] = null;
    }
    if (this.contact != null) {
      json[r'contact'] = this.contact;
    } else {
      json[r'contact'] = null;
    }
    return json;
  }

  /// Returns a new [SupplierWrite] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SupplierWrite? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'name'), 'Required key "SupplierWrite[name]" is missing from JSON.');
        assert(json[r'name'] != null, 'Required key "SupplierWrite[name]" has a null value in JSON.');
        return true;
      }());

      return SupplierWrite(
        name: mapValueOfType<String>(json, r'name')!,
        reference: mapValueOfType<String>(json, r'reference'),
        contact: mapValueOfType<String>(json, r'contact'),
      );
    }
    return null;
  }

  static List<SupplierWrite> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SupplierWrite>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SupplierWrite.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SupplierWrite> mapFromJson(dynamic json) {
    final map = <String, SupplierWrite>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SupplierWrite.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SupplierWrite-objects as value to a dart map
  static Map<String, List<SupplierWrite>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SupplierWrite>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SupplierWrite.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'name',
  };
}

