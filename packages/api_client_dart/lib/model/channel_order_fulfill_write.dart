//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ChannelOrderFulfillWrite {
  /// Returns a new [ChannelOrderFulfillWrite] instance.
  ChannelOrderFulfillWrite({
    required this.collectedMinor,
    this.reference,
  });

  String collectedMinor;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? reference;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ChannelOrderFulfillWrite &&
    other.collectedMinor == collectedMinor &&
    other.reference == reference;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (collectedMinor.hashCode) +
    (reference == null ? 0 : reference!.hashCode);

  @override
  String toString() => 'ChannelOrderFulfillWrite[collectedMinor=$collectedMinor, reference=$reference]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'collectedMinor'] = this.collectedMinor;
    if (this.reference != null) {
      json[r'reference'] = this.reference;
    } else {
      json[r'reference'] = null;
    }
    return json;
  }

  /// Returns a new [ChannelOrderFulfillWrite] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ChannelOrderFulfillWrite? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'collectedMinor'), 'Required key "ChannelOrderFulfillWrite[collectedMinor]" is missing from JSON.');
        assert(json[r'collectedMinor'] != null, 'Required key "ChannelOrderFulfillWrite[collectedMinor]" has a null value in JSON.');
        return true;
      }());

      return ChannelOrderFulfillWrite(
        collectedMinor: mapValueOfType<String>(json, r'collectedMinor')!,
        reference: mapValueOfType<String>(json, r'reference'),
      );
    }
    return null;
  }

  static List<ChannelOrderFulfillWrite> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ChannelOrderFulfillWrite>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ChannelOrderFulfillWrite.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ChannelOrderFulfillWrite> mapFromJson(dynamic json) {
    final map = <String, ChannelOrderFulfillWrite>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ChannelOrderFulfillWrite.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ChannelOrderFulfillWrite-objects as value to a dart map
  static Map<String, List<ChannelOrderFulfillWrite>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ChannelOrderFulfillWrite>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ChannelOrderFulfillWrite.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'collectedMinor',
  };
}

