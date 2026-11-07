//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Finalized {
  /// Returns a new [Finalized] instance.
  Finalized({
    required this.sale,
    required this.replayed,
  });

  Sale sale;

  bool replayed;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Finalized &&
    other.sale == sale &&
    other.replayed == replayed;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (sale.hashCode) +
    (replayed.hashCode);

  @override
  String toString() => 'Finalized[sale=$sale, replayed=$replayed]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'sale'] = this.sale;
      json[r'replayed'] = this.replayed;
    return json;
  }

  /// Returns a new [Finalized] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Finalized? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'sale'), 'Required key "Finalized[sale]" is missing from JSON.');
        assert(json[r'sale'] != null, 'Required key "Finalized[sale]" has a null value in JSON.');
        assert(json.containsKey(r'replayed'), 'Required key "Finalized[replayed]" is missing from JSON.');
        assert(json[r'replayed'] != null, 'Required key "Finalized[replayed]" has a null value in JSON.');
        return true;
      }());

      return Finalized(
        sale: Sale.fromJson(json[r'sale'])!,
        replayed: mapValueOfType<bool>(json, r'replayed')!,
      );
    }
    return null;
  }

  static List<Finalized> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Finalized>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Finalized.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Finalized> mapFromJson(dynamic json) {
    final map = <String, Finalized>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Finalized.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Finalized-objects as value to a dart map
  static Map<String, List<Finalized>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Finalized>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Finalized.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'sale',
    'replayed',
  };
}

