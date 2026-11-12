//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Supplier {
  /// Returns a new [Supplier] instance.
  Supplier({
    required this.id,
    required this.name,
    required this.reference,
    required this.contact,
    required this.createdAt,
  });

  String id;

  String name;

  String? reference;

  String? contact;

  DateTime createdAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Supplier &&
    other.id == id &&
    other.name == name &&
    other.reference == reference &&
    other.contact == contact &&
    other.createdAt == createdAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (name.hashCode) +
    (reference == null ? 0 : reference!.hashCode) +
    (contact == null ? 0 : contact!.hashCode) +
    (createdAt.hashCode);

  @override
  String toString() => 'Supplier[id=$id, name=$name, reference=$reference, contact=$contact, createdAt=$createdAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
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
      json[r'createdAt'] = this.createdAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [Supplier] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Supplier? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "Supplier[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "Supplier[id]" has a null value in JSON.');
        assert(json.containsKey(r'name'), 'Required key "Supplier[name]" is missing from JSON.');
        assert(json[r'name'] != null, 'Required key "Supplier[name]" has a null value in JSON.');
        assert(json.containsKey(r'reference'), 'Required key "Supplier[reference]" is missing from JSON.');
        assert(json.containsKey(r'contact'), 'Required key "Supplier[contact]" is missing from JSON.');
        assert(json.containsKey(r'createdAt'), 'Required key "Supplier[createdAt]" is missing from JSON.');
        assert(json[r'createdAt'] != null, 'Required key "Supplier[createdAt]" has a null value in JSON.');
        return true;
      }());

      return Supplier(
        id: mapValueOfType<String>(json, r'id')!,
        name: mapValueOfType<String>(json, r'name')!,
        reference: mapValueOfType<String>(json, r'reference'),
        contact: mapValueOfType<String>(json, r'contact'),
        createdAt: mapDateTime(json, r'createdAt', r'')!,
      );
    }
    return null;
  }

  static List<Supplier> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Supplier>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Supplier.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Supplier> mapFromJson(dynamic json) {
    final map = <String, Supplier>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Supplier.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Supplier-objects as value to a dart map
  static Map<String, List<Supplier>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Supplier>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Supplier.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'name',
    'reference',
    'contact',
    'createdAt',
  };
}

